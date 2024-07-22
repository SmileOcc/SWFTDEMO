//
//  ZFNativeBannerViewController.m
//  ZZZZZ
//
//  Created by YW on 31/7/18.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFNativeBannerViewController.h"
#import "YNPageViewController.h"
#import "ZFNativeCollectionView.h"

#import "ZFGoodsDetailViewController.h"
#import "ZFNativeGoodsViewController.h"
#import "ZFNativePlateGoodsViewController.h"

#import "ZFNativeBannerBranchCell.h"
#import "ZFNativeBannerSKUBannerCell.h"
#import "ZFNativeSlideBannerCell.h"
#import "ZFShare.h"

#import "ZFBannerModel.h"
#import "ZFGoodsModel.h"
#import "ZFNativeBannerResultModel.h"
#import "ZFNativeBannerModel.h"
#import "ZFNativeBannerViewModel.h"
#import "ZFThemeManager.h"
#import "NSArray+SafeAccess.h"
#import "ZFProgressHUD.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "ZFLocalizationString.h"
#import "ZFFireBaseAnalytics.h"
#import "ZFStatistics.h"
#import "ZFGrowingIOAnalytics.h"
#import "BannerManager.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "ZFRefreshHeader.h"
#import "ZFRefreshFooter.h"
#import "Constants.h"

@interface ZFNativeBannerViewController ()<YNPageViewControllerDataSource,YNPageViewControllerDelegate,UICollectionViewDelegate, UICollectionViewDataSource,ZFShareViewDelegate>
@property (nonatomic, strong) ZFNativeCollectionView            *collectionView;
@property (nonatomic, strong) ZFShareView                       *shareView;
@property (nonatomic, strong) UIButton                          *shoppingCarBtn;
@property (nonatomic, strong) ZFNativeBannerViewModel           *viewModel;
@property (nonatomic, strong) ZFNativeBannerResultModel         *dataModel;
@property (nonatomic, strong) YNPageViewController              *pageVC;
@property (nonatomic, strong) NSIndexPath                       *videoCellIndexPath;
@property (nonatomic, strong) ZFAnalyticsProduceImpression      *analyticsProduceImpression;//统计
@property (nonatomic, strong) NSMutableArray                    *analyticsSet;
@end

@implementation ZFNativeBannerViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.specialTitle;
    [self startRequestNativeBannerData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshShppingCarBag];
//    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    self.navigationController.navigationBarHidden = NO;
    //在部分机器上发现全屏播放完视频后会出现状态栏不显示, 导航栏消失的bug by: YW
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    showSystemStatusBar();
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self refreshShppingCarBag];
}

- (void)startRequestNativeBannerData {
    @weakify(self)
    ShowLoadingToView(self.view);
    [self requestNativeBannerDataCompletion:^{
        @strongify(self)
        [self configurePageVC];
    }];
}

#pragma mark - Request
- (void)requestNativeBannerDataCompletion:(void (^)(void))completion {
    @weakify(self);
    [self.viewModel requestNativeBannerDataWithSpecialId:self.specialId completion:^(ZFNativeBannerResultModel *bannerModel , BOOL isSuccess) {
        @strongify(self);
        HideLoadingFromView(self.view);
        if (!isSuccess) {
            [self showEmptyView];
            return;
        }
    
        [self removeEmptyView];
        self.dataModel = bannerModel;
        [self configureCollectionViewHeight];
        [self configureNavgationItem:ZFIsEmptyString(self.dataModel.infoModel.shareUrl) ? NO : YES];
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - YNPageViewControllerDataSource
- (UIScrollView *)pageViewController:(YNPageViewController *)pageViewController
                        pageForIndex:(NSInteger)index {
    UIViewController *vc = pageViewController.controllersM[index];
    if ([vc isKindOfClass:[ZFNativeGoodsViewController class]]) {
        return [(ZFNativeGoodsViewController *)vc querySubScrollView];
    } else {
        return [(ZFNativePlateGoodsViewController *)vc querySubScrollView];
    }
}

#pragma mark - YNPageViewControllerDelegate
- (NSString *)pageViewController:(YNPageViewController *)pageViewController
          customCacheKeyForIndex:(NSInteger )index {
    ZFNativeBannerPageModel *model = [self.dataModel.menuList objectWithIndex:index];
    return ZFToString(model.plateID);
}

#pragma mark - Private method

- (void)configurePageVC {
    YNPageConfigration *configration = [YNPageConfigration defaultConfig];
    configration.pageStyle              = YNPageStyleSuspensionTopPause;
    configration.headerViewScaleMode    = YNPageHeaderViewScaleModeTop;
    configration.scrollMenu             = YES;
    configration.bounces                = YES;
    configration.normalItemColor        = ZFCOLOR(153, 153, 153, 1.0);
    configration.selectedItemColor      = ZFCOLOR(183, 96, 42, 1.0);
    configration.lineColor              = ZFCOLOR(183, 96, 42, 1.0);
    configration.selectedItemFont       = ZFFontSystemSize(16);
    configration.menuHeight             = self.dataModel.menuList.count > 0 ? 44 : 0.5;
    configration.hideContentView        = (self.dataModel.menuList.count == 0 && self.dataModel.plateGoodsArray.count == 0);
    configration.showScrollLine         = self.dataModel.menuList.count > 0;
    
    YNPageViewController *vc = [YNPageViewController pageViewControllerWithControllers:[self queryChildViewControllers]
                                                                                titles:[self queryNavTitles]
                                                                                config:configration];
    self.pageVC = vc;
    vc.dataSource = self;
    vc.delegate = self;
    vc.headerView = self.collectionView;
    @weakify(self)
    vc.topViewHasDidScrollView = ^(CGFloat offsetY){
        @strongify(self)
        [self judgePuasePlayVideo:offsetY];
    };
    [vc addSelfToParentViewController:self];
    
    ZFRefreshHeader *header = [ZFRefreshHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self reloadPageVC];
        [vc.bgScrollView.mj_header endRefreshing];
    }];
    
    vc.bgScrollView.mj_header = header;
}

- (void)reloadPageVC {
    @weakify(self);
    [self requestNativeBannerDataCompletion:^{
        @strongify(self)
        self.pageVC.config.showScrollLine  = self.dataModel.menuList.count > 0;
        self.pageVC.config.menuHeight = self.dataModel.menuList.count > 0 ? 44 : 0.5;
        self.pageVC.config.hideContentView = (self.dataModel.menuList.count == 0 && self.dataModel.plateGoodsArray.count == 0);
        self.pageVC.titlesM = [self queryNavTitles].mutableCopy;
        self.pageVC.controllersM = [self queryChildViewControllers].mutableCopy;
        [self.analyticsSet removeAllObjects];
        [self.pageVC reloadData];
    }];
}

- (void)configureCollectionViewHeight {
    self.videoCellIndexPath = nil;
    [self.collectionView reloadData];
    __block CGFloat heigh = 0;
    heigh = self.collectionView.collectionViewLayout.collectionViewContentSize.height;
    self.collectionView.frame = CGRectMake(0, 0, KScreenWidth, ceil(heigh));
}

- (NSArray *)queryChildViewControllers {
    NSMutableArray *vcArray = [NSMutableArray array];
    if (self.dataModel.menuList.count > 0) {
        for (ZFNativeBannerPageModel *model in self.dataModel.menuList) {
            ZFNativeGoodsViewController *goodsListVC = [[ZFNativeGoodsViewController alloc] init];
            goodsListVC.plateID = model.plateID;
            goodsListVC.specialId = self.dataModel.infoModel.specialId;
            goodsListVC.specialTitle = self.dataModel.infoModel.specialTitle;
            [vcArray addObject:goodsListVC];
        }
    } else {
        ZFNativePlateGoodsViewController *plateGoodsVC = [[ZFNativePlateGoodsViewController alloc] init];
        plateGoodsVC.model = self.dataModel;
        plateGoodsVC.specialTitle = self.dataModel.infoModel.specialTitle;
        //occ v3.7.0hacker 添加 ok
        plateGoodsVC.analyticsProduceImpression = self.viewModel.analyticsProduceImpressionSpecial;
        [vcArray addObject:plateGoodsVC];
    }
    return [vcArray copy];
}

- (NSArray *)queryNavTitles {
    NSMutableArray *titleArray = [NSMutableArray array];
    if (self.dataModel.menuList.count > 0) {
        for (ZFNativeBannerPageModel *model in self.dataModel.menuList) {
            [titleArray addObject:model.plateTitle];
        }
    }else{
        [titleArray addObject:@""]; // 传空只是占位
    }
    return [titleArray copy];
}

- (void)dealCouponBannerClick:(ZFNativeBannerModel *)model {
    if (model.couponId.integerValue > 0) {
        @weakify(self)
        if (![AccountManager sharedManager].isSignIn) {
            [self judgePresentLoginVCCompletion:^{
                @strongify(self)
                [self reloadPageVC];
            }];
            return;
        }
        
        switch (model.couponStatuType) {
            case ZFBannerCouponStateTypeReceive:{
                [self.viewModel getCouponWithCouponId:model.couponId completion:^(id obj) {
                    @strongify(self)
                    [self reloadPageVC];
                }];
            }
                break;
            case ZFBannerCouponStateTypeClaimed:{
                ShowToastToViewWithText(self.view, ZFLocalizedString(@"My_Coupon_Alread_Get_Coupon", nil));
            }
                break;
            case ZFBannerCouponStateTypeExpired:{
                ShowToastToViewWithText(self.view, ZFLocalizedString(@"My_Coupon_Expired", nil));
            }
                break;
            case ZFBannerCouponStateTypeUsed:{
                ShowToastToViewWithText(self.view, ZFLocalizedString(@"My_Coupon_Have_Been_Claimed", nil));
            }
                break;
        }
    }
}

- (void)showEmptyView {
    self.emptyImage   = [UIImage imageNamed:@"blankPage_favorites"];
    self.emptyTitle   = ZFLocalizedString(@"EmptyCustomViewManager_titleLabel",nil);
    @weakify(self)
    [self showEmptyViewHandler:^{
        @strongify(self)
        [self startRequestNativeBannerData];
    }];
}

- (void)configureNavgationItem:(BOOL)showShareBtn {
    NSMutableArray *buttonArray = [NSMutableArray array];
    UIButton *bagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [bagBtn setFrame:CGRectMake(0, 0, NavBarButtonSize, NavBarButtonSize)];
    [bagBtn setImage:ZFImageWithName(@"public_bag") forState:UIControlStateNormal];
    [bagBtn addTarget:self action:@selector(bagBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    bagBtn.adjustsImageWhenHighlighted = NO;
    bagBtn.contentEdgeInsets = UIEdgeInsetsMake(0.0, 8.0, 0.0, -8.0);
    UIBarButtonItem *bagItem = [[UIBarButtonItem alloc] initWithCustomView:bagBtn];
    
    if (showShareBtn) {
        UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [shareButton setFrame:CGRectMake(0, 0, NavBarButtonSize, NavBarButtonSize)];
        [shareButton setImage:ZFImageWithName(@"GoodsDetail_shareIcon") forState:UIControlStateNormal];
        [shareButton addTarget:self action:@selector(shareBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        shareButton.adjustsImageWhenHighlighted = NO;
        shareButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 12.0, 0.0, -12.0);
        UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
        [buttonArray addObject:shareItem];
    }
    [buttonArray addObject:bagItem];
    self.navigationItem.rightBarButtonItems = buttonArray;
    self.shoppingCarBtn = bagBtn;
    [self refreshShppingCarBag];
}

- (void)refreshShppingCarBag {
    [self.shoppingCarBtn showShoppingCarsBageValue:[GetUserDefault(kCollectionBadgeKey) integerValue]];
}

#pragma mark - Action
- (void)bagBtnAction:(UIButton *)bagBtn {
    [ZFStatistics eventType:ZF_NativeBanner_Cars_type];
    [self pushToViewController:@"ZFCartViewController" propertyDic:nil];
}

- (void)shareBtnAction:(UIButton *)bagBtn {
    [self.shareView open];
    [ZFFireBaseAnalytics selectContentWithItemId:[NSString stringWithFormat:@"click_share_NativeBanner_%@", self.specialId] itemName:@"Share" ContentType:@"native_banner_detail" itemCategory:@"Button"];
}

#pragma mark - UICollectionDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.viewModel queryLayoutSections].count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    ZFNativeBannerBaseLayout *rowLayoutModel = [self.viewModel queryLayoutSections][section];
    return rowLayoutModel.rowCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFNativeBannerBaseLayout *rowLayout = [self.viewModel queryLayoutSections][indexPath.section];
    switch (rowLayout.type) {
        case ZFNativeBannerTypeBranch:
        case ZFNativeBannerTypeVideo:
        {
            ZFNativeBannerBranchLayout *branchLayout  = (ZFNativeBannerBranchLayout *)rowLayout;
            ZFNativeBannerBranchCell *branchBannerCell = [ZFNativeBannerBranchCell branchBannerCellWith:collectionView forIndexPath:indexPath];
            branchBannerCell.branch = branchLayout.branch;
            branchBannerCell.branchBannerModel = branchLayout.banners[indexPath.item];
            return branchBannerCell;
        }
            break;
        case ZFNativeBannerTypeSKUBanner:
        {
            ZFNativeBannerSKUBannerLayout *skuBannerLayout = (ZFNativeBannerSKUBannerLayout *)rowLayout;
            ZFNativeBannerSKUBannerCell *skuBannerCell = [ZFNativeBannerSKUBannerCell SKUBannerCellWith:collectionView forIndexPath:indexPath];
            skuBannerCell.goodsList = skuBannerLayout.goodsArray;
            // 统计
            if (![self.analyticsSet containsObject:ZFToString(skuBannerLayout.bannerModel.banner_id)]) {
                [self.analyticsSet addObject:ZFToString(skuBannerLayout.bannerModel.banner_id)];
                [ZFAppsflyerAnalytics trackGoodsList:skuBannerLayout.goodsArray inSourceType:ZFAppsflyerInSourceTypePromotion sourceID:self.specialTitle];
            }
            @weakify(self);
            skuBannerCell.skuBannerGoodsBlock = ^(ZFGoodsModel *model, NSInteger selectIndex) {
                @strongify(self);
                if (model) {
                    /// sku + banner 统计
                    [ZFAnalytics clickAdvertisementWithId:@"" name:model.nativeBannerName position:[NSString stringWithFormat:@"%ld%ld",indexPath.section, indexPath.row]];
                    [ZFAnalytics showProductsWithProducts:@[model] position:1 impressionList:@"NativeSKUBanner_List" screenName:@"NativeSkuBanner" event:@"load"];
                    
                    //occ v3.7.0hacker 添加 ok
                    self.analyticsProduceImpression = [ZFAnalyticsProduceImpression initAnalyticsProducePosition:1 impressionList:@"NativeSKUBanner_List" screenName:@"NativeSkuBanner" event:@"load"];
                    [ZFAnalytics clickProductWithProduct:model position:(int)indexPath.row actionList:@"NativeSKUBanner_List"];
//                    NSString *position = [NSString stringWithFormat:@"%ld", selectIndex];
                    // growingIO 活动 点击
//                    [ZFGrowingIOAnalytics ZFGrowingIOActivityClick:model.nativeBannerName
//                                                             floor:model.nativeBannerName
//                                                          position:position
//                                                              page:@"原生专题"];
                    [ZFGrowingIOAnalytics ZFGrowingIOProductClick:model page:@"原生专题" sourceParams:@{
                        GIOGoodsTypeEvar : GIOGoodsTypeOther,
                        GIOGoodsNameEvar : @"native_activety"
                    }];
                    // appflyer统计
                    NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(model.goods_sn),
                                                      @"af_spu_id" : ZFToString(model.goods_spu),
                                                      @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                                      @"af_page_name" : @"native_activety",    // 当前页面名称
                                                      };
                    [ZFAppsflyerAnalytics zfTrackEvent:@"af_sku_click" withValues:appsflyerParams];
                    
                    ZFGoodsDetailViewController *goodsDetailViewController = [[ZFGoodsDetailViewController alloc] init];
                    goodsDetailViewController.goodsId = model.goods_id;
                    goodsDetailViewController.sourceType = ZFAppsflyerInSourceTypePromotion;
                    goodsDetailViewController.sourceID = ZFToString(self.specialTitle);
                    goodsDetailViewController.analyticsProduceImpression = self.analyticsProduceImpression;
                    [self.navigationController pushViewController:goodsDetailViewController animated:YES];
                    return;
                }
                
                [BannerManager doBannerActionTarget:self withBannerModel:skuBannerLayout.bannerModel];
            };
            return skuBannerCell;
        }
            break;
        case ZFNativeBannerTypeSlide:
        {
            ZFNativeBannerSlideLayout *sliderLayout =(ZFNativeBannerSlideLayout *)rowLayout;
            ZFNativeSlideBannerCell *sliderCell = [ZFNativeSlideBannerCell sliderBannerCellWith:collectionView forIndexPath:indexPath];
            sliderCell.scrollerBannerArray = sliderLayout.slideArray;
            @weakify(self)
            sliderCell.sliderBannerClick = ^(ZFBannerModel *sliderBannerModel) {
                @strongify(self)
                [BannerManager doBannerActionTarget:self withBannerModel:sliderBannerModel];
            };
            return sliderCell;
        }
            break;
        default:
            break;
    }
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    ZFNativeBannerBaseLayout *rowLayout = [self.viewModel queryLayoutSections][indexPath.section];
    switch (rowLayout.type) {
        case ZFNativeBannerTypeBranch:
        {
            ZFNativeBannerBranchLayout *branchLayout  = (ZFNativeBannerBranchLayout *)rowLayout;
            ZFNativeBannerModel *branchBannerModel = branchLayout.banners[indexPath.item];
            
            if (branchBannerModel.bannerType == ZFBannerTypeNormal) {
                ZFBannerModel *bannerModel = [[ZFBannerModel alloc] init];
                bannerModel.deeplink_uri = branchBannerModel.deeplinkUri;
                [BannerManager doBannerActionTarget:self withBannerModel:bannerModel];
            
            } else if (branchBannerModel.bannerType == ZFBannerTypeCoupon) {
                [self dealCouponBannerClick:branchBannerModel];
            }
            
            if (branchBannerModel.bannerType != ZFBannerTypeCoupon) {
                //growingIO 活动点击统计, 去除优惠券
//                NSString *position = [NSString stringWithFormat:@"%ld", indexPath.row];
//                NSString *floor = [NSString stringWithFormat:@"impression_channel_banner_branch%ld_%@_%@", branchLayout.branch, position, branchBannerModel.bannerName];
//                [ZFGrowingIOAnalytics ZFGrowingIOActivityClick:branchBannerModel.bannerName
//                                                         floor:floor
//                                                      position:position
//                                                          page:@"首页"];
            }     
        }
            break;
        default:
            break;
    }
}

/**
 * 监听Cell已显示出来,判断是否需要暂停播放视频
 */
- (void)judgePuasePlayVideo:(CGFloat)offsetY {
    if (!self.videoCellIndexPath) {
        NSArray *dataArr = [self.viewModel queryLayoutSections];
        for (NSInteger section=0; section<dataArr.count; section++) {
            ZFNativeBannerBaseLayout *rowLayout = dataArr[section];
            
            if (rowLayout.type == ZFNativeBannerTypeBranch ||
                rowLayout.type == ZFNativeBannerTypeVideo) {
                
                ZFNativeBannerBranchLayout *branchLayout  = (ZFNativeBannerBranchLayout *)rowLayout;
                for (NSInteger row=0; row<branchLayout.banners.count; row++) {
                    
                    ZFNativeBannerModel *branchBannerModel = branchLayout.banners[row];
                    if (branchBannerModel.bannerType == ZFBannerTypeVideo ) { // 视频Cell
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                        self.videoCellIndexPath = indexPath;
                    }
                }
            }
        }
    }
    
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:self.videoCellIndexPath];
    if (cell && [cell isKindOfClass:[ZFNativeBannerBranchCell class]]) {
        ZFNativeBannerBranchCell *branchBannerCell = (ZFNativeBannerBranchCell *)cell;
        if (offsetY >= (CGRectGetMaxY(cell.frame) -20)) {//向上拖动视频Cell离开屏幕
            [branchBannerCell pausePlayVideo];
        }
        
        if ((offsetY + (KScreenHeight- (NAVBARHEIGHT + STATUSHEIGHT))) < (CGRectGetMinY(cell.frame))) {
            [branchBannerCell pausePlayVideo];//向下拖动视频Cell离开屏幕
        }
    }
}

#pragma mark - UICollectionDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.viewModel itemSizeAtIndexPath:indexPath];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    ZFNativeBannerBaseLayout *rowViewModel = [self.viewModel queryLayoutSections][section];
    return rowViewModel.minimumLineSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    ZFNativeBannerBaseLayout *rowViewModel = [self.viewModel queryLayoutSections][section];
    return rowViewModel.minimumInteritemSpacing;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    ZFNativeBannerBaseLayout *rowViewModel = [self.viewModel queryLayoutSections][section];
    return rowViewModel.edgeInsets;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    ZFNativeBannerBaseLayout *rowViewModel = [self.viewModel queryLayoutSections][section];
    return rowViewModel.headerSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    ZFNativeBannerBaseLayout *rowViewModel = [self.viewModel queryLayoutSections][section];
    return rowViewModel.footerSize;
}

#pragma mark - ZFShareViewDelegate
- (void)zfShsreView:(ZFShareView *)shareView didSelectItemAtIndex:(NSUInteger)index {
    NativeShareModel *model = [[NativeShareModel alloc] init];
    model.share_url = ZFToString(self.dataModel.infoModel.shareUrl);
    model.share_imageURL = shareView.topView.imageName;
    model.share_description = shareView.topView.title;
    model.fromviewController = self;
    model.sharePageType = ZFSharePage_NativeBannerType;
    [ZFShareManager shareManager].model = model;
    [ZFShareManager shareManager].currentShareType = index;
    switch (index) {
        case ZFShareTypeWhatsApp: {
            [[ZFShareManager shareManager] shareToWhatsApp];
        }
            break;
        case ZFShareTypeFacebook:{
            [[ZFShareManager shareManager] shareToFacebook];
        }
            break;
        case ZFShareTypeMessenger:{
            [[ZFShareManager shareManager] shareToMessenger];
        }
            break;
        case ZFShareTypePinterest: {
            [[ZFShareManager shareManager] shareToPinterest];
        }
            break;
        case ZFShareTypeCopy:{
            [[ZFShareManager shareManager] copyLinkURL];
        }
            break;
        case ZFShareTypeMore: {
            [[ZFShareManager shareManager] shareToMore];
        }
            break;
        case ZFShareTypeVKontakte: {
            [[ZFShareManager shareManager] shareVKontakte];
        }
            break;
    }
    //需求: 统计分享, 不管成功失败一点击就统计
    [self shareSuccessAppsFlyerEventByType:index];
}

/**
 * 统计分享facebook, Message事件
 */
- (void)shareSuccessAppsFlyerEventByType:(ZFShareType)shareType {
    if (ZFIsEmptyString(self.deeplinkSource))return;
    
    NSString *share_channel = [ZFShareManager fetchShareTypePlatform:shareType];
    if (ZFIsEmptyString(share_channel)) return;
    
    share_channel = [NSString stringWithFormat:@"Shared on %@", share_channel];
    NSMutableDictionary *valuesDic = [NSMutableDictionary dictionary];
    valuesDic[AFEventParamContentId] = ZFToString(@"unKnow");//@陈佳佳:说这里没有sn就传空
    valuesDic[AFEventParamContentType] = ZFToString(share_channel);
    valuesDic[@"af_country_code"] = ZFToString([AccountManager sharedManager].accountCountryModel.region_code);
    valuesDic[@"af_inner_mediasource"] = self.deeplinkSource;
    [ZFAnalytics appsFlyerTrackEvent:@"af_share" withValues:valuesDic];
}

#pragma mark - Getter
- (ZFNativeCollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[ZFNativeCollectionView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 0) collectionViewLayout:layout];
        _collectionView.delegate                       = self;
        _collectionView.dataSource                     = self;
        _collectionView.showsVerticalScrollIndicator   = YES;
        _collectionView.backgroundColor                = [UIColor whiteColor];
        if (@available(iOS 11.0, *)) _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        
        [_collectionView registerClass:[UICollectionViewCell class]  forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
    }
    return _collectionView;
}

- (ZFShareView *)shareView {
    if (!_shareView) {
        _shareView = [[ZFShareView alloc] init];
        _shareView.delegate = self;
        
        ZFShareTopView *shareTopView = [[ZFShareTopView alloc] init];
        [shareTopView updateImage:self.dataModel.infoModel.shareImgUrl
                       title:self.dataModel.infoModel.shareTitle
                     tipType:ZFShareDefaultTipTypeCommon];
        _shareView.topView = shareTopView;
        [ZFShareManager authenticatePinterest];
    }
    return _shareView;
}

- (ZFNativeBannerViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFNativeBannerViewModel alloc] init];
    }
    return _viewModel;
}

- (NSMutableArray *)analyticsSet {
    if (!_analyticsSet) {
        _analyticsSet = [NSMutableArray array];
    }
    return _analyticsSet;
}

- (void)dealloc {
    if (_shareView) {
        [self.shareView removeFromSuperview];
        self.shareView.delegate = nil;
        self.shareView = nil;
    }
}

@end
