//
//  ZFGoodsShowsDetailViewController.m
//  ZZZZZ
//
//  Created by YW on 2019/3/2.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsShowsDetailViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "Constants.h"
#import "ZFFrameDefiner.h"
#import "ZFGoodsDetailNavigationView.h"
#import "ZFGoodsShowsAddCartView.h"
#import "ZFGoodsShowsHeadSelectView.h"
#import "ZFGoodsShowsFooterView.h"
#import <YYWebImage/YYWebImage.h>
#import "YWCFunctionTool.h"
#import "ZFCartViewController.h"
#import "ZFCustomerManager.h"
#import "ExchangeManager.h"
#import "SystemConfigUtils.h"
#import "ZFGoodsDetailSelectTypeView.h"
#import "ZFGoodsShowsViewModel.h"
#import "ZFAnalytics.h"
#import "ZFAppsflyerAnalytics.h"
#import "ZFFireBaseAnalytics.h"
#import "ZFGrowingIOAnalytics.h"

#import "ZFGoodsDetailViewModel.h"
#import "GoodsDetailModel.h"
#import "ZFProgressHUD.h"
#import "ZFBTSManager.h"

#import "ZFAnalyticsTimeManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFBranchAnalytics.h"
#import "ZFLocalizationString.h"

#define kTopImageViewHeight    (150.0)
#define kAddCartViewHeight     (kiphoneXHomeBarHeight + 49.0)
#define kNavigationViewHeight  (NAVBARHEIGHT + STATUSHEIGHT)

@interface ZFGoodsShowsTableView : UITableView <UIGestureRecognizerDelegate>
@end
@implementation ZFGoodsShowsTableView
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
@end

@interface ZFGoodsShowsDetailViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, copy) NSString                        *goods_id;
@property (nonatomic, strong) ZFGoodsDetailNavigationView   *navigationView;
@property (nonatomic, strong) UIImageView                   *topImageView;
@property (nonatomic, strong) ZFGoodsShowsTableView         *superTableView;
@property (nonatomic, strong) ZFGoodsShowsAddCartView       *addCartView;
@property (nonatomic, strong) ZFGoodsShowsHeadSelectView    *headSelectView;
@property (nonatomic, strong) ZFGoodsShowsFooterView        *footerView;
@property (nonatomic, strong) ZFGoodsDetailSelectTypeView   *selectView;
@property (nonatomic, assign) BOOL                          canScroll;
@property (nonatomic, assign) BOOL                          hasOpenSizeView;
@property (nonatomic, assign) NSInteger                     goodsNumber;
@property (nonatomic, assign) NSInteger                     selectSkuCount;
@property (nonatomic, assign) BOOL                          lastChangeFlag;
@property (nonatomic, strong) ZFGoodsShowsViewModel         *viewModel;
@end

@implementation ZFGoodsShowsDetailViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.canScroll = YES;
    self.goodsNumber = 1;
    self.selectSkuCount = 0;
    self.goods_id = self.detailModel.goods_id;
    self.fd_prefersNavigationBarHidden = YES;
    [self.view addSubview:self.superTableView];
    [self.view addSubview:self.navigationView];
    [self.view addSubview:self.selectView];
    [self.view addSubview:self.addCartView];
    [self.footerView showDataWithSku:self.detailModel.goods_sn];
    [self addNotification];
    //添加一个透明视图让事件传递到顶层,使其能够侧滑返回
    [self shouldShowLeftHoledSliderView:KScreenHeight];
    
     [self addAnalysics];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self.addCartView selector:@selector(refreshCartCountWithAnimation) name:kCartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSuperCanScrollStatus:) name:kGoodsShowsDetailViewSuperScrollStatus object:nil];
}

- (void)setSuperCanScrollStatus:(NSNotification *)notice {
    NSDictionary *dic = notice.userInfo;
    NSNumber *status = dic[@"status"];
    self.canScroll = [status boolValue];
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.headSelectView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kSelectViewHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"ZFGoodsShowsDetailCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    return cell;
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (![scrollView isEqual:self.superTableView]) return;
    
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat headerOffsetY = kTopImageViewHeight - kNavigationViewHeight;
    self.navigationView.refreshAlpha = offsetY/headerOffsetY;
    //YWLog(@"父 表格滚动=0==%.2f==%d", offsetY, self.canScroll);
    
    // 不要重复改变
    if (self.lastChangeFlag != self.canScroll) {
        self.lastChangeFlag = self.canScroll;
        CGSize size = self.canScroll ? CGSizeMake(14, 14) : CGSizeZero;
        [self.headSelectView zfAddCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:size];
    }
    
    if (offsetY < 0) {
        CGFloat totalOffset = kTopImageViewHeight + ABS(offsetY);
        CGFloat f = totalOffset / kTopImageViewHeight;
        self.topImageView.frame = CGRectMake(- (KScreenWidth * f - KScreenWidth) / 2, offsetY, KScreenWidth * f, totalOffset);
    }
    
    // 限制最大下拉高度
    if (offsetY < -kTopImageViewHeight) {
        scrollView.contentOffset = CGPointMake(0, -kTopImageViewHeight);
    }
    
    if (self.canScroll) {
        if (scrollView.contentOffset.y >= headerOffsetY) {
            scrollView.contentOffset = CGPointMake(0, headerOffsetY);
            [self sendSubTabCanScroll:YES];
        } else {
            [self sendSubTabCanScroll:NO];
        }
    } else {
        scrollView.contentOffset = CGPointMake(0, headerOffsetY);
        if (!scrollView.isDragging) {
            [self sendSubTabCanScroll:YES];
        }
    }
}

- (void)sendSubTabCanScroll:(BOOL)status {
    NSDictionary *dic = @{@"status":@(status),
                          @"type":@(self.headSelectView.currentType)
                          };
    [[NSNotificationCenter defaultCenter] postNotificationName:kGoodsShowsDetailViewSubScrollStatus object:nil userInfo:dic];
}

- (void)jumpToCartViewController {
    ZFCartViewController *cartVC = [[ZFCartViewController alloc] init];
    [self.navigationController pushViewController:cartVC animated:YES];
}

- (void)jumpToCustomerAction {
    NSString *goodsInfo = [NSString stringWithFormat:@"%@-%@%@-%@", self.detailModel.goods_sn, self.detailModel.shop_price, [ExchangeManager localCurrencyName], self.detailModel.goods_name];
    [[ZFCustomerManager shareInstance] presentLiveChatWithGoodsInfo:goodsInfo];
}

- (void)addCartAction {
    self.addCartView.userInteractionEnabled = NO;
    if (self.hasOpenSizeView) {
        [self requestAddGoodsToCart];
    } else {
        self.hasOpenSizeView = YES;
        [self.selectView openSelectTypeView];
    }
}

#pragma mark - ===========请求数据===========

/// 加购
- (void)requestAddGoodsToCart {
    [self.viewModel requestAddToCart:self.goods_id
                                goodsNumber:self.goodsNumber
                                 freeGiftId:self.freeGiftId
                                loadingView:self.view
                                 completion:^(id _Nonnull obj) {
                                     [self.selectView hideSelectTypeView];
                                     self.addCartView.userInteractionEnabled = YES;
                                     
                                     //添加商品至购物车事件统计
                                     NSString *goodsSN = self.detailModel.goods_sn;
                                     NSString *spuSN = @"";
                                     if (goodsSN.length > 7) {  // sn的前7位为同款id
                                         spuSN = [goodsSN substringWithRange:NSMakeRange(0, 7)];
                                     }else{
                                         spuSN = goodsSN;
                                     }
                                     NSMutableDictionary *valuesDic = [NSMutableDictionary dictionary];
                                     valuesDic[AFEventParamContentId] = ZFToString(goodsSN);
                                     valuesDic[@"af_spu_id"] = ZFToString(spuSN);
                                     valuesDic[AFEventParamPrice] = ZFToString(self.detailModel.shop_price);
                                     valuesDic[AFEventParamQuantity] = [NSString stringWithFormat:@"%zd",self.goodsNumber];
                                     valuesDic[AFEventParamContentType] = @"product";
                                     valuesDic[@"af_content_category"] = ZFToString(self.detailModel.long_cat_name);
                                     valuesDic[AFEventParamCurrency] = @"USD";
                                     valuesDic[@"af_inner_mediasource"] = [ZFAppsflyerAnalytics sourceStringWithType:ZFAppsflyerInSourceTypeZMeRemommendItemsShow sourceID:@""];
                                     valuesDic[@"af_changed_size_or_color"] = (self.selectSkuCount > 0) ? @"1" : @"0";
                                     valuesDic[BigDataParams]           = @[[self.detailModel gainAnalyticsParams]];
                                     valuesDic[@"af_purchase_way"] = @"1";//V5.0.0增加, 判断是否为一键购买(0)还是正常加购(1)
                                     
                                     [ZFAnalytics appsFlyerTrackEvent:@"af_add_to_bag" withValues:valuesDic];
                                     //Branch
                                     [[ZFBranchAnalytics sharedManager] branchAddToCartWithProduct:self.detailModel number:self.goodsNumber];
                                     self.detailModel.buyNumbers = self.goodsNumber;
                                     [ZFAnalytics addToCartWithProduct:self.detailModel fromProduct:YES];
                                     [ZFFireBaseAnalytics addToCartWithGoodsModel:self.detailModel];
                                     [ZFGrowingIOAnalytics ZFGrowingIOAddCart:self.detailModel];

                                     
                                 } failure:^(id _Nonnull obj) {
                                     [self.selectView hideSelectTypeView];
                                     self.addCartView.userInteractionEnabled = YES;
                                 }];
}

/// 选择规则请求商详
- (void)requestBySelectType {
    NSDictionary *dict = @{@"manzeng_id"  : ZFToString(self.freeGiftId),
                           @"goods_id"    : ZFToString(self.goods_id) };
    ShowLoadingToView(self.view);
    self.selectSkuCount += 1;
    @weakify(self)
    [[ZFGoodsDetailViewModel new] requestGoodsDetailData:dict completion:^(GoodsDetailModel *goodsDetailModel) {
        @strongify(self)
        HideLoadingFromView(self.view);
        self.selectView.model = goodsDetailModel;
        self.addCartView.model = goodsDetailModel;
        self.detailModel = goodsDetailModel;
        
        if (goodsDetailModel.detailMainPortSuccess) {
            [self addAnalysics];
        }
        
    } failure:^(NSError *error) {
        @strongify(self)
        ShowToastToViewWithText(self.view, error.domain);
    }];
}

// 添加统计代码
- (void)addAnalysics {
    if (self.detailModel) {
        [ZFFireBaseAnalytics scanGoodsWithGoodsModel:self.detailModel];
        // 谷歌统计
        [[ZFAnalyticsTimeManager sharedManager] logTimeWithEventName:kFinishLoadingProductDetail];
        [ZFAnalytics scanProductDetailWithProduct:self.detailModel screenName:@"Product Detail"];
        
        //用户点击查看商品
        NSMutableDictionary *valuesDic     = [NSMutableDictionary dictionary];
        valuesDic[AFEventParamContentId]   = ZFToString(self.detailModel.goods_sn);
        valuesDic[AFEventParamContentType] = @"product";
        valuesDic[AFEventParamPrice]       = ZFToString(self.detailModel.shop_price);
        valuesDic[AFEventParamCurrency]    = @"USD";
        valuesDic[@"af_inner_mediasource"] = [ZFAppsflyerAnalytics sourceStringWithType:ZFAppsflyerInSourceTypeZMeRemommendItemsShow sourceID:nil];
        valuesDic[@"af_changed_size_or_color"] = (self.selectSkuCount > 0) ? @"1" : @"0";
        valuesDic[BigDataParams]           = [self.detailModel gainAnalyticsParams];
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_view_product" withValues:valuesDic];
        //Branch
        [[ZFBranchAnalytics sharedManager] branchViewItemDetailWithProduct:self.detailModel];
        //GrowingIO商品详情查看
        [ZFGrowingIOAnalytics ZFGrowingIOProductDetailShow:self.detailModel];
    }
}

- (void)actionForNavigation:(ZFDetailNavButtonActionType)actionType {
    if (actionType == ZFDetailNavButtonAction_BackType) {
        [self goBackAction];
        
    } else if (actionType == ZFDetailNavButtonAction_TapImageType) {
        self.canScroll = YES;
        [self.superTableView setContentOffset:CGPointZero animated:YES];
        
    } else if (actionType == ZFDetailNavButtonAction_CustomerType) {
        [self jumpToCustomerAction];
    }
}

#pragma mark - getter

- (ZFGoodsShowsViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFGoodsShowsViewModel alloc] init];
        _viewModel.controller = self;
    }
    return _viewModel;
}

- (ZFGoodsDetailNavigationView *)navigationView {
    if (!_navigationView) {
        CGRect rect = CGRectMake(0, 0, KScreenWidth, kNavigationViewHeight);
        _navigationView = [[ZFGoodsDetailNavigationView alloc] initWithFrame:rect];
        
        GoodsDetailPictureModel *pictureModel = self.detailModel.pictures.firstObject;
        [_navigationView setImageUrl:ZFToString(pictureModel.wp_image)];
        
        @weakify(self);
        _navigationView.navigationBlcok = ^(ZFDetailNavButtonActionType actionType) {
            @strongify(self);
            [self actionForNavigation:actionType];
        };
    }
    return _navigationView;
}

- (UIView *)createTableheaderView {
    UIImage *image = self.placeholderImage;
    if (![image isKindOfClass:[UIImage class]]) {
        image = [UIImage imageNamed:@"account_home_headerTopbg"];
    }
    CGRect rect = CGRectMake(0, 0, KScreenWidth, kTopImageViewHeight);
    UIImageView *topImageView = [[UIImageView alloc] initWithFrame:rect];
    topImageView.image = image;
    topImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.topImageView = topImageView;
    
    GoodsDetailPictureModel *pictureModel = self.detailModel.pictures.firstObject;
    [_topImageView yy_setImageWithURL:[NSURL URLWithString:ZFToString(pictureModel.wp_image)]
                          placeholder:image
                              options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                             progress:nil
                            transform:nil
                           completion:nil];
    
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.backgroundColor = [UIColor clearColor];
    [view addSubview:topImageView];
    return view;
}

- (ZFGoodsShowsTableView *)superTableView {
    if(!_superTableView){
        CGRect rect = CGRectMake(0, 0, KScreenWidth, KScreenHeight-kAddCartViewHeight);
        _superTableView = [[ZFGoodsShowsTableView alloc] initWithFrame:rect style:UITableViewStylePlain];
        _superTableView.backgroundColor = [UIColor clearColor];
        _superTableView.delegate = self;
        _superTableView.dataSource = self;
        _superTableView.showsVerticalScrollIndicator = NO;
        _superTableView.showsHorizontalScrollIndicator = NO;
        _superTableView.tableHeaderView = [self createTableheaderView];
        _superTableView.tableFooterView = self.footerView;
        if (@available(iOS 11.0, *)) {
            _superTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _superTableView;
}

- (ZFGoodsShowsHeadSelectView *)headSelectView {
    if (!_headSelectView) {
        CGRect rect = CGRectMake(0, 0, KScreenWidth, kSelectViewHeight);
        _headSelectView = [[ZFGoodsShowsHeadSelectView alloc] initWithFrame:rect];
        @weakify(self);
        _headSelectView.selectCompletionHandler = ^(ZFGoodsShowsHeadSelectType index) {
            @strongify(self);
            [self.footerView selectCustomIndex:index];
        };
        [_headSelectView zfAddCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(14, 14)];
    }
    return _headSelectView;
}

- (ZFGoodsShowsFooterView *)footerView {
    if (!_footerView) {
        CGRect rect = CGRectMake(0, 0, KScreenWidth, KScreenHeight-(0 + kTopImageViewHeight));
        _footerView = [[ZFGoodsShowsFooterView alloc] initWithFrame:rect];
        _footerView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        @weakify(self);
        _footerView.selectIndexCompletion = ^(NSInteger index) {
            @strongify(self);
            self.headSelectView.currentType = index;
        };
    }
    return _footerView;
}

- (ZFGoodsShowsAddCartView *)addCartView {
    if (!_addCartView) {
        CGRect rect = CGRectMake(0, KScreenHeight-kAddCartViewHeight, KScreenWidth, kAddCartViewHeight);
        _addCartView = [[ZFGoodsShowsAddCartView alloc] initWithFrame:rect];
        @weakify(self);
        [_addCartView setShowBottomViewBlock:^(GoodsShowsAddCartActionType actionType) {
            if (actionType == GoodsShowsAddCart_pushCarType) { // 查看购物车
               @strongify(self)
                [self jumpToCartViewController];
                
            } else if (actionType == GoodsShowsAddCart_addCartType) { // 添加到购物车
                @strongify(self)
                [self addCartAction];
            }
        }];
    }
    return _addCartView;
}

- (ZFGoodsDetailSelectTypeView *)selectView {
    if (!_selectView) {
        NSString *bagTitle = ZFLocalizedString(@"Detail_Product_AddToBag", nil);
        _selectView = [[ZFGoodsDetailSelectTypeView alloc] initSelectSizeView:YES bottomBtnTitle:bagTitle];
        _selectView.hidden = YES;
        _selectView.model = self.detailModel;
        
        @weakify(self);
        _selectView.openOrCloseBlock = ^(BOOL isOpen) {
            @strongify(self);
            self.addCartView.userInteractionEnabled = YES;
            if (!isOpen) {
                self.hasOpenSizeView = NO;
            }
        };
        _selectView.goodsDetailSelectTypeBlock = ^(NSString *goodsId) {
            @strongify(self);
            self.goods_id = goodsId;
            self.goodsNumber = 1;
            [self requestBySelectType];
        };
    }
    return _selectView;
}

@end
