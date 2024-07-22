//
//  ZFCollocationBuyViewController.m
//  ZZZZZ
//
//  Created by YW on 2019/8/13.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCollocationBuyViewController.h"
#import "ZFCollocationBuyModel.h"
#import "ZFCollocationBuyViewModel.h"
#import "ZFCollocationBuySubViewController.h"
#import "ZFGoodsModel.h"
#import "ZFThemeManager.h"
#import "ZFProgressHUD.h"
#import "UIView+LayoutMethods.h"
#import "ZFLocalizationString.h"
#import "NSDictionary+SafeAccess.h"
#import "ZFAnalytics.h"
#import "ExchangeManager.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFBottomToolView.h"
#import "ZFCollocationBuyModel.h"
#import "ZFGoodsDetailViewModel.h"
#import "ZFCartViewController.h"
#import "ZFPopDownAnimation.h"
#import "SystemConfigUtils.h"
#import "ZFFireBaseAnalytics.h"
#import "GoodsDetailModel.h"
#import "ZFBranchAnalytics.h"
#import "ZFAnalytics.h"
#import "ZFFireBaseAnalytics.h"
#import "ZFGrowingIOAnalytics.h"
#import "UIColor+ExTypeChange.h"

static CGFloat bottomViewHeight = 56;

@interface ZFCollocationBuyViewController ()
@property (nonatomic, strong) NSArray<ZFCollocationBuyTabModel *> *tabModelArray;
@property (nonatomic, strong) ZFCollocationBuyModel *collocationBuyModel;
@property (nonatomic, strong) UIButton              *shoppingCarBtn;
@property (nonatomic, strong) UIView                *menuBottomLine;
@property (nonatomic, strong) ZFBottomToolView      *bottomView;
@property (nonatomic, strong) NSArray               *currentSeletedIdArray;
@end

@implementation ZFCollocationBuyViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    if (self = [super init]) {
        self.titleSizeNormal    = 14.0f;
        self.titleSizeSelected  = 14.0f;
        self.menuViewStyle      = WMMenuViewStyleLine;
        self.itemMargin         = 15.0f;
        self.titleColorNormal   = ZFCOLOR(153, 153, 153, 1);
        self.titleColorSelected = ZFC0x2D2D2D();
        self.progressColor      = ZFC0x2D2D2D();
        self.progressHeight     = 3.0f;
        self.automaticallyCalculatesItemWidths = YES;
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self showNavigationBottomLine:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showNavigationBottomLine:NO];
    // 每次进来都刷
    [self requestCollocationBuyData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = ZFLocalizedString(@"Cart_MatchItems",nil);
    self.view.backgroundColor = [UIColor whiteColor];
    
    //添加一个透明视图让事件传递到顶层,使其能够侧滑返回
    [self shouldShowLeftHoledSliderView:self.view.height];
    [self.view addSubview:self.bottomView];
    [self configNavigationBar];
    [self addNotification];
}

- (void)showNavigationBottomLine:(BOOL)show
{
    //[self.navigationController.navigationBar setShadowImage:show ? nil : [UIImage new]];
}

#pragma mark - 网络请求

- (void)requestCollocationBuyData {
    ShowLoadingToView(self.view);
    [ZFCollocationBuyViewModel requestCollocationBuy:self.goods_sn
                                       showFirstPage:NO
                                          completion:^(ZFCollocationBuyModel *collocationBuyModel)
     {
         HideLoadingFromView(self.view);
         if ([collocationBuyModel isKindOfClass:[ZFCollocationBuyModel class]]) {
             self.collocationBuyModel = collocationBuyModel;
             [self setDefaultSeleteAllGoods:(self.currentSeletedIdArray.count>0)];
             [self reloadData];
             [self arMenuViewHandle];
         }
         if (!ZFJudgeNSArray(self.collocationBuyModel.collocationGoodsArr) || self.collocationBuyModel.collocationGoodsArr.count == 0) {
             [self showAgainRequestView];
         }
     }];
}

- (void)collocationAddToCart {
    if (self.currentSeletedIdArray.count == 0) return;
    NSString *addIds = [self.currentSeletedIdArray componentsJoinedByString:@","];
    ZFGoodsDetailViewModel *viewModel = [[ZFGoodsDetailViewModel alloc] init];
    viewModel.isCollocationBuy = YES;
    [viewModel requestAddToCart:addIds loadingView:self.view goodsNum:1 completion:^(BOOL isSuccess) {
        if (!isSuccess) return ;
        [ZFPopDownAnimation popDownRotationAnimation:self.shoppingCarBtn];
        
        NSArray *goodsModelArr = self.collocationBuyModel.collocationGoodsArr[self.selectIndex];
        for (ZFCollocationGoodsModel *model in goodsModelArr) {
            if ([self.currentSeletedIdArray containsObject:model.goods_id]) {
                GoodsDetailModel *goodsModel = [[GoodsDetailModel alloc] init];
                goodsModel.goods_id = model.goods_id;
                goodsModel.goods_sn = model.goods_sn;
                goodsModel.shop_price = model.shop_price;
                goodsModel.goods_name = model.goods_title;
                goodsModel.goods_number = [model.goods_number integerValue];
                goodsModel.buyNumbers = 1;
                [self analyticsCollocationGoodsModel:goodsModel];
            }
        }
    }];
}

/// 添加商品至购物车事件统计
- (void)analyticsCollocationGoodsModel:(GoodsDetailModel *)goodsModel
{
    NSString *spuSN = @"";
    if (goodsModel.goods_sn.length > 7) {  // sn的前7位为同款id
        spuSN = [goodsModel.goods_sn substringWithRange:NSMakeRange(0, 7)];
    } else {
        spuSN = goodsModel.goods_sn;
    }
    NSMutableDictionary *valuesDic = [NSMutableDictionary dictionary];
    valuesDic[AFEventParamContentId]    = ZFToString(goodsModel.goods_sn);
    valuesDic[@"af_spu_id"]             = ZFToString(spuSN);
    valuesDic[AFEventParamPrice]        = ZFToString(goodsModel.shop_price);
    valuesDic[AFEventParamQuantity]     = @"1";
    valuesDic[AFEventParamContentType]  = @"product";
    valuesDic[@"af_content_category"]   = @"";
    valuesDic[AFEventParamCurrency]     = @"USD";
    valuesDic[@"af_inner_mediasource"]  = [ZFAppsflyerAnalytics sourceStringWithType:ZFAppsflyerInSourceTypeCollocation sourceID:nil];/** 搭配购商品*/
    valuesDic[@"af_changed_size_or_color"] = @"0";
    valuesDic[@"af_sort"]              = @"";
    valuesDic[BigDataParams]           = @[];
    valuesDic[@"af_rank"]              = @"";
    valuesDic[@"af_purchase_way"]      = @"1"; //V5.0.0增加正常加购(1)
    
    //【af_add_to_bag】之前，要记得【af_view_product】show一下商品详情
    [ZFAnalytics appsFlyerTrackEvent:@"af_add_to_bag" withValues:valuesDic];
    //Branch
    [[ZFBranchAnalytics sharedManager] branchAddToCartWithProduct:goodsModel number:1];
    
    [ZFAnalytics addToCartWithProduct:goodsModel fromProduct:YES];
    
    [ZFFireBaseAnalytics addToCartWithGoodsModel:goodsModel];
    
    [ZFGrowingIOAnalytics ZFGrowingIOAddCart:goodsModel];
}

#pragma mark - <NSNotificationCenter>
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCartNumberInfo) name:kCartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGoodsSelectedStatus) name:kSetCollocationStatusNotification object:nil];
}

- (void)refreshGoodsSelectedStatus {
    NSArray *allGoodModel = self.collocationBuyModel.collocationGoodsArr;
    if (allGoodModel.count > self.selectIndex) {
        NSArray *currentGoodsArray = allGoodModel[self.selectIndex];
        if (!ZFJudgeNSArray(currentGoodsArray)) return;
        
        NSMutableArray *seletedArray = [NSMutableArray array];
        for (ZFCollocationGoodsModel *goodsModel in currentGoodsArray) {
            if (goodsModel.shouldSelected) {
                [seletedArray addObject:ZFToString(goodsModel.goods_id)];
            }
        }
        self.currentSeletedIdArray = seletedArray;
    }
    self.bottomView.bottomButton.enabled = (self.currentSeletedIdArray.count > 0);
}

- (void)setDefaultSeleteAllGoods:(BOOL)isRefersh {
    NSArray *allGoodModel = self.collocationBuyModel.collocationGoodsArr;
    for (NSInteger i=0; i<allGoodModel.count; i++) {
        NSArray *goodsSuperArr = allGoodModel[i];
        
        for (ZFCollocationGoodsModel *goodsModel in goodsSuperArr) {
            if (isRefersh && i == self.selectIndex) {
                if ([self.currentSeletedIdArray containsObject:goodsModel.goods_id]) {
                    goodsModel.shouldSelected = YES;
                }
            } else {
                goodsModel.shouldSelected = YES;
            }
        }
    }
    [self refreshGoodsSelectedStatus];
}

- (void)changeCartNumberInfo {
    NSNumber *badgeNum = [[NSUserDefaults standardUserDefaults] valueForKey:kCollectionBadgeKey];
    [self.shoppingCarBtn showShoppingCarsBageValue:[badgeNum integerValue]];
}

/// 外部控制器全部翻转,到里面的子控制器再次翻转
- (void)arMenuViewHandle {
    if (!_menuBottomLine && self.collocationBuyModel.collocationGoodsArr.count > 1) {
        self.menuBottomLine.hidden = NO;
        [self.menuView addSubview:self.menuBottomLine];
    }
    if ([SystemConfigUtils isRightToLeftShow]) {
        self.menuView.transform = CGAffineTransformMakeScale(-1.0,1.0);
        self.scrollView.transform = CGAffineTransformMakeScale(-1.0,1.0);
        
        NSArray *subMenuViews = self.menuView.scrollView.subviews;
        for (UIView *subView in subMenuViews) {
            if ([subView isKindOfClass:[WMMenuItem class]]) {
                subView.transform = CGAffineTransformMakeScale(-1.0,1.0);
            }
        }
    }
}


#pragma mark - privete method
- (void)showAgainRequestView {
    self.emptyImage = [UIImage imageNamed:@"blankPage_requestFail"];
    self.emptyTitle = ZFLocalizedString(@"Search_ResultViewModel_Tip",nil);
    self.edgeInsetTop = -TabBarHeight;
    @weakify(self)
    [self showEmptyViewHandler:^{
        @strongify(self)
        [self requestCollocationBuyData];
    }];
}

#pragma mark - private methods
- (void)configNavigationBar {
    UIButton *shoppingCarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shoppingCarBtn setFrame:CGRectMake(0, 0, NavBarButtonSize, NavBarButtonSize)];
    [shoppingCarBtn setImage:ZFImageWithName(@"public_bag") forState:UIControlStateNormal];
    [shoppingCarBtn addTarget:self action:@selector(showCartButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    shoppingCarBtn.adjustsImageWhenHighlighted = NO;
    
    UIBarButtonItem *shoppingCarItem = [[UIBarButtonItem alloc] initWithCustomView:shoppingCarBtn];
    self.shoppingCarBtn = shoppingCarBtn;
    self.navigationItem.rightBarButtonItems = @[shoppingCarItem];
    [self changeCartNumberInfo];
}

- (void)showCartButtonAction:(UIButton *)sender {
    [self pushOrPopToViewController:NSStringFromClass(ZFCartViewController.class)
                         withObject:nil
                          aSelector:nil
                           animated:YES];
}

#pragma mark -WMPageControllerDelegate / WMPageControllerDatasource
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return self.collocationBuyModel.collocationGoodsArr.count;
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    if (self.collocationBuyModel.collocationGoodsArr.count <= index) return nil;
    NSString *title = self.collocationBuyModel.collocationTitleArr[index];
    return ZFToString(title);
}

- (UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    if (self.collocationBuyModel.collocationGoodsArr.count <= index) return nil;
    
    ZFCollocationBuySubViewController *subVC = [[ZFCollocationBuySubViewController alloc] init];
    subVC.contentViewHeight = self.fetchSelfViewH;
    NSArray *goodsModelArr = self.collocationBuyModel.collocationGoodsArr[index];
    subVC.goodsModelArray = goodsModelArr;
    
    NSString *title = self.collocationBuyModel.collocationTitleArr[index];
    subVC.channel_id = ZFToString(title);
    return subVC;
}

- (void)pageController:(WMPageController *)pageController didEnterViewController:(__kindof UIViewController *)viewController withInfo:(NSDictionary *)info {
    [self refreshGoodsSelectedStatus];
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    CGFloat menuHeight = (self.collocationBuyModel.collocationGoodsArr.count <= 1) ? 0.0f : 44;
    return CGRectMake(0, 0, KScreenWidth, menuHeight);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    CGFloat menuMaxY = CGRectGetMaxY([self pageController:pageController preferredFrameForMenuView:self.menuView]);
    return CGRectMake(0, menuMaxY, KScreenWidth, self.fetchSelfViewH);
}

- (CGFloat)fetchSelfViewH {
    CGFloat menuMaxY = (self.collocationBuyModel.collocationGoodsArr.count <= 1) ? 0 : 44;
    CGFloat selfViewH = KScreenHeight - STATUSHEIGHT - NAVBARHEIGHT  - menuMaxY - (bottomViewHeight + (IPHONE_X_5_15 ? 34 : 0));
    return selfViewH;
}

#pragma mark - Getter
- (UIView *)menuBottomLine {
    if (!_menuBottomLine) {
        _menuBottomLine = [[UIView alloc] init];
        _menuBottomLine.frame = CGRectMake(0.0, 44 - 0.5, self.view.width, 0.5);
        _menuBottomLine.backgroundColor = [UIColor colorWithHex:0xdddddd];
        _menuBottomLine.hidden = YES;
    }
    return _menuBottomLine;
}

- (ZFBottomToolView *)bottomView {
    if(!_bottomView){
        _bottomView = [[ZFBottomToolView alloc] initWithFrame:CGRectZero];
        _bottomView.bottomTitle = [ZFLocalizedString(@"Detail_Product_AddToBag", nil) uppercaseString];
        @weakify(self)
        _bottomView.bottomButtonBlock = ^{
            @strongify(self)
            [self collocationAddToCart];
        };
        [self.view addSubview:_bottomView];
        [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.view);
            make.height.mas_equalTo(bottomViewHeight);
            make.bottom.mas_equalTo(self.view.mas_bottom).offset(-(IPHONE_X_5_15 ? 28 : 0));
        }];
    }
    return _bottomView;
}

@end
