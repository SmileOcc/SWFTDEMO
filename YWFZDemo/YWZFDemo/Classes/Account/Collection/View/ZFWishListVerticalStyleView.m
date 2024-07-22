//
//  ZFWishListVerticalStyleView.m
//  ZZZZZ
//
//  Created by YW on 2019/7/22.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFWishListVerticalStyleView.h"
#import "ZFWishListVerticalStyleCell.h"
#import "ZFGoodsDetailSelectTypeView.h"
#import "ZFWebViewViewController.h"

#import "ZFGoodsDetailViewController.h"
#import "ZFUnlineSimilarViewController.h"

#import "Constants.h"
#import "ZFFrameDefiner.h"
#import "YWCFunctionTool.h"
#import "ZFThemeManager.h"
#import "ZFProgressHUD.h"
#import "YSAlertView.h"
#import "SystemConfigUtils.h"
#import "ZFLocalizationString.h"
#import "ZFCollectionViewModel.h"
#import "ZFGoodsDetailViewModel.h"

#import "ZFBannerModel.h"
#import "BannerManager.h"
#import "AccountManager.h"

#import "ZFWishListVerticalStyleAnalyticsAOP.h"

#import "UIScrollView+ZFBlankPageView.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import <Masonry/Masonry.h>

@interface ZFWishListVerticalStyleView ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    ZFWishListVerticalStyleCellDelegate
>
@property (nonatomic, strong) NSMutableArray *dataSourceList;
@property (nonatomic, strong) ZFCollectionViewModel *viewModel;
@property (nonatomic, strong) ZFGoodsDetailViewModel *goodsDetailViewModel;
@property (nonatomic, strong) ZFGoodsDetailSelectTypeView *attributeView;
@property (nonatomic, strong) ZFWishListVerticalStyleAnalyticsAOP *analyticsAop;
@end

@implementation ZFWishListVerticalStyleView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    
    if (self) {
        [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.analyticsAop];
        self.rowHeight = UITableViewAutomaticDimension;
        self.estimatedRowHeight = 144;
        self.delegate = self;
        self.tableFooterView = [UIView new];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;

        [self registerClass:[ZFWishListVerticalStyleCell class] forCellReuseIdentifier:@"ZFWishListVerticalStyleCell"];
        
        @weakify(self)
        [self addHeaderRefreshBlock:^{
            @strongify(self)
            [self requestPageData:YES];
        } footerRefreshBlock:^{
            @strongify(self)
            [self requestPageData:NO];
        } startRefreshing:NO];
        
        [self addObserver];
        [WINDOW addSubview:self.attributeView];
        [self.attributeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(WINDOW).insets(UIEdgeInsetsZero);
        }];
    }
    return self;
}

#pragma mark - notification

- (void)addObserver {
    // 登录刷新通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginChangeCollectionRefresh) name:kLoginNotification object:nil];
    // 登出刷新通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginChangeCollectionRefresh) name:kLogoutNotification object:nil];
}

- (void)loginChangeCollectionRefresh
{
    [self requestPageData:YES];
}

#pragma mark - table datasource&delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listModel.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZFWishListVerticalStyleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZFWishListVerticalStyleCell"];
    cell.goodsModel = self.listModel.data[indexPath.row];
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self gainRowAction];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZFGoodsModel *model = self.listModel.data[indexPath.row];
    ZFGoodsDetailViewController *detailVC = [[ZFGoodsDetailViewController alloc] init];
    detailVC.goodsId = model.goods_id;
    detailVC.sourceType = ZFAppsflyerInSourceTypeWishListSourceMedia;
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - private method

- (NSArray<UITableViewRowAction *> *)gainRowAction
{
    NSMutableArray <UITableViewRowAction *>*rowActionList = [[NSMutableArray alloc] init];
    UITableViewRowAction *rowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:ZFLocalizedString(@"Address_List_Cell_Delete", nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSString *title = ZFLocalizedString(@"CartRemoveProductTips", nil);
        NSArray *btnArr = @[ZFLocalizedString(@"CartRemoveProductYes", nil)];
        NSString *cancelTitle = ZFLocalizedString(@"CartRemoveProductNo", nil);
        @weakify(self)
        ShowAlertView(title, nil, btnArr, ^(NSInteger buttonIndex, id buttonTitle) {
            @strongify(self)
            [self requestDeleteLike:self.listModel.data[indexPath.row] indexPath:indexPath];
        }, cancelTitle, nil);
    }];
    rowAction.backgroundColor = ColorHex_Alpha(0xFF6262, 1.0);
    [rowActionList addObject:rowAction];
    return rowActionList.copy;
}

- (void)openWebInfoWithUrl:(NSString *)url title:(NSString *)title {
    if ([url hasPrefix:@"ZZZZZ:"]) {
        ZFBannerModel *model = [[ZFBannerModel alloc] init];
        model.deeplink_uri = url;
        [BannerManager doBannerActionTarget:self withBannerModel:model];
    }else{
        ZFWebViewViewController *webVC = [[ZFWebViewViewController alloc] init];
        webVC.link_url = url;
        webVC.title = title;
        [self.navigationController pushViewController:webVC animated:YES];
    }
}

- (void)handlerAddToBagSuccess:(GoodsDetailModel *)model
{
    if (self.styleViewdelegate && [self.styleViewdelegate respondsToSelector:@selector(ZFWishListVerticalStyleViewAddCartCompetion)]) {
        [self.styleViewdelegate ZFWishListVerticalStyleViewAddCartCompetion];
    }
}

- (void)showWishListTipsGif
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([AccountManager sharedManager].gifTipsModel.isShowWishListGifTips) {
            [AccountManager sharedManager].gifTipsModel.isShowWishListGifTips = YES;
            NSInteger rows = [self numberOfRowsInSection:0];
            if (rows) {
                CGRect rect = [self rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                ShowGifImageWithGifPathToTransparenceScreenView(CGRectGetMinY(rect), CGSizeMake(270, rect.size.height) , @"wishListDelete.gif", @"wishListTipsBackground", ^{});
            }
        }
    });
}

#pragma mark - public method

- (void)refreshRequest:(BOOL)isFirstPage
{
    [self requestPageData:isFirstPage];
}

#pragma mark - cell delegate

- (void)ZFWishListVerticalStyleCellDidClickAddCartBag:(ZFGoodsModel *)goodsModel
{
    @weakify(self)
    [self requestGoodsDetailInfo:goodsModel.goods_id successBlock:^(GoodsDetailModel *goodsDetailInfo) {
        @strongify(self)
        self.attributeView.model = goodsDetailInfo;
        [self.attributeView openSelectTypeView];
    }];
}

- (void)ZFWishListVerticalStyleCellDidClickFindRelated:(ZFGoodsModel *)goodsModel
{
    //2019年07月31日13:34:50 彭国光说暂时不需要来源统计
    ZFUnlineSimilarViewController *unlineSimilarViewController = [[ZFUnlineSimilarViewController alloc] initWithImageURL:goodsModel.wp_image sku:goodsModel.goods_sn];
    [self.navigationController pushViewController:unlineSimilarViewController animated:YES];
}

#pragma mark - network

- (void)requestPageData:(BOOL)firstPage {
    
    @weakify(self)
    [self.viewModel requestCollectGoodsPageData:firstPage completion:^(ZFCollectionListModel *listModel, NSArray *currentPageArray, NSDictionary *pageInfo) {
        @strongify(self)
        if (firstPage && !currentPageArray.count) {
            if (self.styleViewdelegate && [self.styleViewdelegate respondsToSelector:@selector(ZFWishListVerticalStyleViewNoData)]) {
                [self.styleViewdelegate ZFWishListVerticalStyleViewNoData];
            }
        } else {
            self.listModel = listModel;
            [self reloadData];
            [self showRequestTip:pageInfo];
        }
    }];
}

- (void)requestDeleteLike:(ZFGoodsModel *)goodsModel indexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = @{@"goods_id" : goodsModel.goods_id,
                           @"type"     : @"1"};
    @weakify(self);
    ShowLoadingToView(self);
    [ZFCollectionViewModel requestCollectionGoodsNetwork:dict completion:^(BOOL isOK) {
        @strongify(self);
        HideLoadingFromView(self);
        if (indexPath && indexPath.row < self.listModel.data.count) {
            [self.listModel.data removeObjectAtIndex:indexPath.row];
            [self deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
            [[NSNotificationCenter defaultCenter] postNotificationName:kCollectionGoodsNotification object:nil userInfo:dict];
            if (self.listModel.data.count == 0) {
                //
                @weakify(self)
                [self.viewModel requestCollectGoodsPageData:YES completion:^(ZFCollectionListModel *listModel, NSArray *currentPageArray, NSDictionary *pageInfo) {
                    @strongify(self)
                    if (!currentPageArray.count) {
                        if (self.styleViewdelegate && [self.styleViewdelegate respondsToSelector:@selector(ZFWishListVerticalStyleViewNoData)]) {
                            [self.styleViewdelegate ZFWishListVerticalStyleViewNoData];
                        }
                    } else {
                        self.listModel = listModel;
                        [self reloadData];
                        [self showRequestTip:pageInfo];
                    }
                }];
            }
        }
    } target:[UIViewController currentTopViewController]];
}

/**
 获取商品详情
 */
- (void)requestGoodsDetailInfo:(NSString *)goodsId successBlock:(void(^)(GoodsDetailModel *goodsDetailInfo))successBlock{
    if (ZFIsEmptyString(goodsId)) return;
    NSDictionary *dict = @{
        @"manzeng_id"  : @"",
        @"goods_id"    : ZFToString(goodsId)
    };
    ShowLoadingToView(self);
    ZFGoodsDetailViewModel *goodsDetailViewModel = [[ZFGoodsDetailViewModel alloc] init];
    [goodsDetailViewModel requestGoodsDetailData:dict completion:^(GoodsDetailModel *detaidlModel) {
        HideLoadingFromView(self);
        if ([detaidlModel isKindOfClass:[GoodsDetailModel class]]) {
            if (successBlock) {
                successBlock(detaidlModel);
            }
        }
    } failure:^(NSError *error) {
        HideLoadingFromView(self);
    }];
}

//添加购物车
- (void)addGoodsToCartOption:(NSString *)goodsId goodsCount:(NSInteger)goodsCount {
    @weakify(self);
    ZFGoodsDetailViewModel *goodsDetailViewModel = [[ZFGoodsDetailViewModel alloc] init];
    [goodsDetailViewModel requestAddToCart:ZFToString(goodsId) loadingView:self.window goodsNum:goodsCount completion:^(BOOL isSuccess) {
        @strongify(self);
        
        if (isSuccess) {
            CGFloat x = [SystemConfigUtils isRightToLeftShow] ? 30 :  (KScreenWidth - 30);
            @weakify(self)
            [self.attributeView startAddCartAnimation:WINDOW
                                             endPoint:CGPointMake(x, 24 + kiphoneXTopOffsetY)
                                              endView:nil
                                             endBlock:^{
                @strongify(self)
                [self.attributeView hideSelectTypeView];
            }];
            [self handlerAddToBagSuccess:self.attributeView.model];
            
        } else {
            [self.attributeView bottomCartViewEnable:YES];
        }
    }];
}

#pragma mark - Property Method

- (void)setListModel:(ZFCollectionListModel *)listModel
{
    _listModel = listModel;
    if (_listModel.total_page > 1) {
        self.mj_footer.hidden = NO;
        self.mj_footer.state = MJRefreshStateIdle;
    }
    if (_listModel.data.count) {
        self.dataSource = self;
        [self reloadData];
        [self showWishListTipsGif];
    }
}

- (NSMutableArray *)dataSourceList
{
    if (!_dataSourceList) {
        _dataSourceList = [[NSMutableArray alloc] init];
    }
    return _dataSourceList;
}

- (ZFCollectionViewModel *)viewModel
{
    if (!_viewModel) {
        _viewModel = [[ZFCollectionViewModel alloc] init];
        _viewModel.controller = [UIViewController currentTopViewController];
        _viewModel.listModel = self.listModel;
    }
    return _viewModel;
}

- (ZFGoodsDetailSelectTypeView *)attributeView {
    if (!_attributeView) {
        NSString *bagTitle = ZFLocalizedString(@"Detail_Product_AddToBag", nil);
        _attributeView = [[ZFGoodsDetailSelectTypeView alloc] initSelectSizeView:NO bottomBtnTitle:bagTitle];
        _attributeView.hidden = YES;
        @weakify(self);
        _attributeView.openOrCloseBlock = ^(BOOL isOpen) {
            @strongify(self);
            [self.attributeView bottomCartViewEnable:YES];
        };

        _attributeView.goodsDetailSelectTypeBlock = ^(NSString *goodsId) {
            @strongify(self);
            @weakify(self)
            [self requestGoodsDetailInfo:goodsId successBlock:^(GoodsDetailModel *goodsDetailInfo) {
                @strongify(self)
                self.attributeView.model = goodsDetailInfo;
            }];
        };
        
        _attributeView.goodsDetailSelectSizeGuideBlock = ^(NSString *url){
            @strongify(self);
            [self.attributeView hideSelectTypeView];
            [self openWebInfoWithUrl:self.attributeView.model.size_url title:ZFLocalizedString(@"Detail_Product_SizeGuides",nil)];
        };

        _attributeView.addCartBlock = ^(NSString *goodsId, NSInteger count) {
            @strongify(self);
            [self.attributeView bottomCartViewEnable:NO];
            
            [self addGoodsToCartOption:ZFToString(goodsId) goodsCount:count];
        };
    }
    return _attributeView;
}

- (ZFGoodsDetailViewModel *)goodsDetailViewModel
{
    if (!_goodsDetailViewModel) {
        _goodsDetailViewModel = [[ZFGoodsDetailViewModel alloc] init];
    }
    return _goodsDetailViewModel;
}

- (ZFWishListVerticalStyleAnalyticsAOP *)analyticsAop
{
    if (!_analyticsAop) {
        _analyticsAop = [[ZFWishListVerticalStyleAnalyticsAOP alloc] init];
    }
    return _analyticsAop;
}

@end
