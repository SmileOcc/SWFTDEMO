//
//  ZFHomePageViewController.m
//  ZZZZZ
//
//  Created by YW on 10/5/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFHomePageViewController.h"
#import "ZFHomeNavigationBar.h"
#import "ZFHomePageMenuListView.h"
#import "ZFHomePageMenuViewModel.h"
#import "ZFHomeManager.h"
#import "ZFSkinViewModel.h"
#import "ZFCommunityRedDotViewModel.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "ZFHomeCMSViewController.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "NSArray+SafeAccess.h"
#import "ZFProgressHUD.h"
#import "UIView+LayoutMethods.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "ZFFireBaseAnalytics.h"
#import "ZFAnalytics.h"
#import "SystemConfigUtils.h"
#import "BannerManager.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "ZFCommonRequestManager.h"
#import "ZFRefreshHeader.h"
#import "ZFRefreshFooter.h"
#import "Constants.h"
#import "ZFApiDefiner.h"
#import "YWLocalHostManager.h"
#import "NSDictionary+SafeAccess.h"
#import "UINavigationItem+ZFChangeSkin.h"
#import "ZFStatistics.h"
#import "ZFSearchViewController.h"
#import "LBXPermission.h"
#import "LBXPermissionSetting.h"
#import "ZFBTSManager.h"
#import "ZFBTSModel.h"
#import "ZFAppsflyerAnalytics.h"
#import "ZFGrowingIOAnalytics.h"
#import "UIImage+ZFExtended.h"
#import "ZFPorpularSearchManager.h"
#import "ZFTimerManager.h"
#import "ZFCategoryParentViewController.h"

static CGFloat const kTabMenuHeight       = 44.0f;

@interface ZFHomePageViewController ()
@property (nonatomic, strong) ZFHomePageMenuViewModel           *pageMenuViewModel;
@property (nonatomic, strong) ZFHomeNavigationBar               *homeNavigationBar;
@property (nonatomic, strong) ZFHomePageMenuListView            *menuListView;
@property (nonatomic, strong) UIView                            *bottomLine;
@property (nonatomic, strong) CAGradientLayer                   *menuGradientLayer;
@property (nonatomic, strong) UIButton                          *menuExpansionButton;
@property (nonatomic, strong) ZFCommunityRedDotViewModel        *redDotModel;/** 社区 消息红点 */
@property (nonatomic, strong) YYAnimatedImageView               *floatBannerImageView;
@property (nonatomic, strong) ZFBannerModel                     *floatBannerModel;
@property (nonatomic, copy) NSString                            *requestTempKey;
@property (nonatomic, assign) BOOL                              isCache;//数据是否缓存，用于区分统计代码
@property (nonatomic, assign) NSInteger                         timeCount;//搜索热词计时更换

/** 当前顶部输入显示状态*/
@property (nonatomic, assign) BOOL                              changeShowFloatInputBarFlag;
/// 首页展示次数
@property (nonatomic, assign) NSInteger             openCount;

@end

@implementation ZFHomePageViewController

#pragma mark - Life cycle
- (instancetype)init {
    if (self = [super init]) {
        self.titleSizeNormal    = 14;
        self.titleSizeSelected  = 14.0f;
        self.menuViewStyle      = WMMenuViewStyleLine;
        self.itemMargin         = 20.0f;
        self.titleColorSelected = ZFCOLOR(45, 45, 45, 1.0);
        self.titleColorNormal   = ZFCOLOR(178, 178, 178, 1.0);
        self.progressHeight     = 3.0f;
        self.automaticallyCalculatesItemWidths = YES;
        self.timeCount = 0;
        self.openCount = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    [self.view addSubview:self.homeNavigationBar];
    [self addNotification];
    
    [self requestHomePageTabMenus:YES];
    [ZFCommonRequestManager requestZFSkin];
    [ZFCommonRequestManager asyncRequestOtherApi];
    [ZFCommonRequestManager requestUserOfflinePaySuccessOrder];
    [self performSelector:@selector(loadFloatBannerView) withObject:nil afterDelay:3];
    [ZFCommonRequestManager firstOpenPOSTGoogleApi];
    [self requestRecommendSearchItem];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //推送启动APP首页统计过滤
    self.openCount ++;
    if (self.openCount <= 1 && [AccountManager sharedManager].isPushOpen && [AccountManager sharedManager].isHadDeeplink) {
        // 推送启动APP后，首次展示先不曝光事件
        [AccountManager sharedManager].isFilterAnalytics = YES;
    } else {
        if ([AccountManager sharedManager].isFilterAnalytics && [AccountManager sharedManager].filterAnalyticsArray.count > 0) {
            // 推送页面返回首页后再做曝光统计
            for (ZFCMSItemModel *itemModel in [AccountManager sharedManager].filterAnalyticsArray) {
                NSDictionary *appsflyerParams =  @{
                                                   @"af_content_type" : @"banner impression",  //固定值 banner impression
                                                   @"af_banner_name" : ZFToString(itemModel.name), //banenr名，如叫拼团
                                                   @"af_channel_name" : ZFToString([AccountManager sharedManager].channelId), //菜单id，如Homepage / NEW TO SALE
                                                   @"af_ad_id" : ZFToString(itemModel.ad_id), //banenr id，数据来源于后台配置返回的id
                                                   @"af_component_id" : ZFToString(itemModel.component_id),//组件id，数据来源于后台返回的组件id
                                                   @"af_col_id" : ZFToString(itemModel.col_id), //坑位id，数据来源于后台返回的坑位id
                                                   @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type) //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                                   };
                [ZFAppsflyerAnalytics zfTrackEvent:@"af_banner_impression" withValues:appsflyerParams];
                [ZFGrowingIOAnalytics ZFGrowingIOBannerImpWithCMSItemModel:itemModel page:[AccountManager sharedManager].channelName channelID:[AccountManager sharedManager].channelId floorVar:nil];
            }
            // 消除临时数据
            [[AccountManager sharedManager].filterAnalyticsArray removeAllObjects];
            
            NSDictionary *afParams = @{ @"af_content_type" : @"view homepage",  //固定值 banner impression
                                        @"af_channel_name" : ZFToString([AccountManager sharedManager].channelName),
                                        @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                        @"af_channel_id" : ZFToString([AccountManager sharedManager].channelId)
                                        };
            
            [ZFAnalytics appsFlyerTrackEvent:@"af_view_homepage" withValues:afParams];
        }
        [AccountManager sharedManager].isFilterAnalytics = NO;
    }
    
    [self showFloatBannerImageView:YES]; //显示浮动按钮
    [self.homeNavigationBar setBagValues];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //显示首页浮窗广告
    [AppDelegate judgeShowHomeFloatView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hiddenMenus];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMenuSkin) name:kChangeSkinNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchNavTitleChange) name:kTimerManagerUpdate object:nil];
    
    if (![YWLocalHostManager isDistributionOnlineRelease]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(convertSiftCondition) name:kCMSTestSiftDataNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(convertToBackupData:) name:kConvertToBackupsDataNotification object:nil];
    }
}

#pragma mark - Notification

/// 测试环境下: 切换主页请求到S3备份数据
- (void)convertToBackupData:(NSNotification *)notify {
    if ([YWLocalHostManager isDistributionOnlineRelease]) return;
    [self.pageMenuViewModel shouldResetMenuData];
    BOOL isMainCMSType = [[notify object] boolValue];
    [self requestHomePageTabMenus:isMainCMSType];
}

/// 测试环境下: 改变CMS筛选条件刷新CMS列表
- (void)convertSiftCondition {
    if ([YWLocalHostManager isDistributionOnlineRelease]) return;
    [self.pageMenuViewModel shouldResetMenuData];
    [self requestHomePageTabMenus:YES];
}

// 处理导航栏换肤
- (void)updateMenuSkin {
    [ZFSkinViewModel isNeedToShow:^(BOOL needShow) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ZFSkinModel *appHomeSkinModel = [AccountManager sharedManager].currentHomeSkinModel;
            
            if (needShow && [appHomeSkinModel.channelBackColor length] > 0
                && [appHomeSkinModel.channelSelectedColor length] > 0
                && [appHomeSkinModel.channelTextColor length] > 0) {
                
                UIViewController *currentVC = [UIViewController currentTopViewController];
                if (currentVC) {
                    NSArray *vcArr = self.childViewControllers;
                    if ([currentVC isKindOfClass:[self class]] ||
                        [vcArr containsObject:currentVC]){
                        [currentVC setNeedsStatusBarAppearanceUpdate];
                    }
                }
                self.titleColorSelected = [UIColor colorWithHexString:appHomeSkinModel.channelSelectedColor];
                self.titleColorNormal   = [UIColor colorWithHexString:appHomeSkinModel.channelTextColor];
                self.menuView.lineColor = [UIColor colorWithHexString:appHomeSkinModel.channelSelectedColor];
                self.menuView.backgroundColor = [UIColor colorWithHexString:appHomeSkinModel.channelBackColor];
                self.bottomLine.backgroundColor = [UIColor colorWithHexString:appHomeSkinModel.channelBackColor];
                self.menuGradientLayer.hidden = YES;
                [self.menuListView refreshMenuColor:appHomeSkinModel
                                         resetColor:YES];
            } else {
                self.menuView.backgroundColor   = ZFCOLOR_WHITE;
                self.bottomLine.backgroundColor = ZFCOLOR_WHITE;
                self.titleColorNormal   = ZFCOLOR(178, 178, 178, 1.0);
                self.titleColorSelected = ZFCOLOR(45, 45, 45, 1.0);
                self.menuView.lineColor = ZFCOLOR(45, 45, 45, 1.0);
                [self.menuListView refreshMenuColor:appHomeSkinModel
                                         resetColor:NO];
            }
            [self.menuView reload];
            [self arMenuViewHandle];
            [self.homeNavigationBar updateNavigationBar:needShow];
        });
    }];
}

- (void)searchNavTitleChange {
    self.timeCount ++;
    if (self.timeCount % 5 == 0) {  // 每5秒更换搜索热词
        NSString *keyword = [[ZFPorpularSearchManager sharedManager] getRandomPorpularSearchKey];
        self.homeNavigationBar.inputPlaceHolder = keyword;
    }
}

#pragma mark - 处理滑动浮窗
/**
 * 延迟请求加载浮窗banner按钮UI
 */
- (void)loadFloatBannerView {
    [ZFHomeManager requestBottomFloatBanner:^(ZFBannerModel *bannerModel) {
        self.floatBannerModel = bannerModel;
        
        self.floatBannerImageView.hidden = YES;//下载完才显示
        [self.floatBannerImageView yy_setImageWithURL:[NSURL URLWithString:bannerModel.image]
                                    placeholder:nil//[UIImage imageNamed:@"index_banner_loading"]
                                        options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                       progress:nil
                                      transform:^UIImage *(UIImage *image, NSURL *url) {
                                          return image;
                                          
                                      } completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                          self.floatBannerImageView.hidden = NO;
                                          //v4.1.0 显示首页浮窗统计
                                          NSString *GAfloatbannerName = [NSString stringWithFormat:@"%@_%@", ZFGAHomeFloatBannerInternalPromotion, ZFToString(bannerModel.name)];
                                          [ZFAnalytics showAdvertisementWithBanners:@[@{@"name" : GAfloatbannerName}] position:nil screenName:@"首页"];
                                      }];
    }];
}

/**
 * 是否显示浮窗banner按钮
 */
- (void)showFloatBannerImageView:(BOOL)show {
    if (!_floatBannerImageView || _floatBannerImageView.hidden) return ;
    if (show) {
        [UIView animateWithDuration:0.6 animations:^{
            self.floatBannerImageView.alpha = 1.0;
            
            if ([SystemConfigUtils isRightToLeftShow]) {
                self.floatBannerImageView.x = 10;
            } else {
                self.floatBannerImageView.x = KScreenWidth-(68+10);
            }
        } completion:^(BOOL finished) {
            self.floatBannerImageView.userInteractionEnabled = YES;
        }];
    } else {
        self.floatBannerImageView.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.6 animations:^{
            self.floatBannerImageView.alpha = 0.5;
            
            if ([SystemConfigUtils isRightToLeftShow]) {
                self.floatBannerImageView.x = -48;
            } else {
                self.floatBannerImageView.x = KScreenWidth-20;
            }
        }];
    }
}

#pragma mark - Request
- (void)requestHomePageTabMenus:(BOOL)isCMSType {
    @weakify(self)
    ShowLoadingToView(self.view);
    [self.pageMenuViewModel requestHomePageMenuData:isCMSType completeHandler:^(BOOL isSucceess) {
        @strongify(self)
        HideLoadingFromView(self.view);
        CGFloat showErrorOffset = kTabMenuHeight;
        if (isSucceess) {
            [self removeEmptyView];
            [self setupChannelMenu];
            
        } else if (self.pageMenuViewModel.tabMenuTitles.count == 0) {
            showErrorOffset = 0;
            [self showEmptyView];
        }
        [ZFHomeManager showNoNetWorkError:self.view offset:showErrorOffset];
    }];
}

#pragma mark -WMPageControllerDelegate / WMPageControllerDatasource
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return self.pageMenuViewModel.tabMenuTitles.count;
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    return [self.pageMenuViewModel.tabMenuTitles stringWithIndex:index];
}

- (UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index
{
    ZFHomeCMSViewController *cmsHomeChannelVC = [[ZFHomeCMSViewController alloc] init];
    if (index == 0) { //警告: CMS频道接口只返回第一页的列表数据
        cmsHomeChannelVC.homeSectionModelArr = self.pageMenuViewModel.homeSectionModelArr;
    }
    cmsHomeChannelVC.btsModel = self.pageMenuViewModel.homeBtsModel;
    cmsHomeChannelVC.title = [self.pageMenuViewModel.tabMenuTitles stringWithIndex:index];
    cmsHomeChannelVC.contentHeight = [self pageController:pageController preferredFrameForContentView:self.scrollView].size.height;
    cmsHomeChannelVC.firstChannelId = [[self.pageMenuViewModel values] firstObject];
    @weakify(self)
    cmsHomeChannelVC.showFloatBannerBlock = ^(BOOL show){
        @strongify(self)
        [self showFloatBannerImageView:show]; //滑动列表时是否隐藏浮动按钮
    };
    cmsHomeChannelVC.showFloatInputBarBlock = ^(BOOL showFloatInputBar, CGFloat offsetY) {
        @strongify(self)
        [self showTopInputBarView:showFloatInputBar offsetY:offsetY];
    };
    return cmsHomeChannelVC;
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    CGFloat menuHeight = self.pageMenuViewModel.tabMenuTitles.count == 1 ? 0.0f : kTabMenuHeight;
    return CGRectMake(0, self.homeNavigationBar.height, KScreenWidth, menuHeight);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    CGFloat menuMaxY = CGRectGetMaxY([self pageController:pageController preferredFrameForMenuView:self.menuView]);
    return CGRectMake(0, menuMaxY, KScreenWidth, KScreenHeight - menuMaxY - TabBarHeight);
}

- (void)pageController:(WMPageController *)pageController willEnterViewController:(__kindof UIViewController *)viewController withInfo:(NSDictionary *)info {
    self.menuListView.selectedIndex = self.selectIndex;
    // firebase 点击统计
    NSString *tabTitle = self.pageMenuViewModel.tabMenuTitles[self.selectIndex];
    NSString *itemId = [NSString stringWithFormat:@"Click_Home_Channel_%@", tabTitle];
    [ZFFireBaseAnalytics selectContentWithItemId:itemId itemName:tabTitle ContentType:@"Home - Channel" itemCategory:@"channel"];
    [ZFAnalytics clickButtonWithCategory:@"channel" actionName:itemId label:itemId];
    
    if (self.menuExpansionButton.isSelected) {
        [self hiddenMenus];
    }
}

#pragma mark - Private method

- (void)requestRecommendSearchItem {
    @weakify(self)
    [ZFCommonRequestManager requestHotSearchKeyword:nil completion:^(NSArray *array) {
        @strongify(self)
        [ZFPorpularSearchManager sharedManager].homePorpularSearchArray = array;
        NSString *keyword = [[ZFPorpularSearchManager sharedManager] getRandomPorpularSearchKey];
        if (ZFIsEmptyString(keyword)) {
            keyword = ZFLocalizedString(@"homeSearchTitle", nil);
        }
        self.homeNavigationBar.inputPlaceHolder = keyword;
    }];
}

- (void)showTopInputBarView:(BOOL)showFloatInputBar offsetY:(CGFloat)offsetY {
    if (self.changeShowFloatInputBarFlag != showFloatInputBar) {
        YWLog(@"showFloatInputBar===%d", showFloatInputBar);
        self.changeShowFloatInputBarFlag = showFloatInputBar;
        [self.homeNavigationBar zf_showInputView:showFloatInputBar offsetY:offsetY];
    }
}

//occ阿语适配
- (void)arMenuViewHandle {
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

- (void)setupChannelMenu {
    self.keys   = [self.pageMenuViewModel keys].mutableCopy;
    self.values = [self.pageMenuViewModel values].mutableCopy;
    [self reloadData];
    [self.view addSubview:self.floatBannerImageView];
    
    // 可滑动才会显示
    if (self.menuView.scrollView.contentSize.width > self.menuView.width) {
        [self addMenuListView];
    }
    [self addSeparetorView];
    
    BOOL isHiddenMenu = self.pageMenuViewModel.tabMenuTitles.count == 1;
    self.menuView.progressView.hidden = isHiddenMenu ? YES : NO;
    self.bottomLine.hidden = isHiddenMenu ? YES : NO;
    [self.homeNavigationBar zf_setBottomLineHidden:isHiddenMenu ? NO : YES];
    
    [self arMenuViewHandle];
}

- (void)addMenuListView {
    self.menuView.rightView = self.menuExpansionButton;
    self.menuListView = [[ZFHomePageMenuListView alloc] initWithMenuTitles:[self.pageMenuViewModel tabMenuTitles] selectedIndex:self.selectIndex];
    @weakify(self)
    self.menuListView.selectedMenuIndex = ^(NSInteger index) {
        @strongify(self)
        [self menuExpansionAction];
        if (index >= 0) {
            self.selectIndex = (int)index;
        }
    };
}

- (void)showEmptyView {
    self.edgeInsetTop = kiphoneXTopOffsetY + 44;
    self.emptyImage = [UIImage imageNamed:@"blankPage_favorites"];
    self.emptyTitle = ZFLocalizedString(@"EmptyCustomViewManager_titleLabel",nil);
    @weakify(self)
    [self showEmptyViewHandler:^{
        @strongify(self)
        ShowLoadingToView(self.view);
        [AccountManager sharedManager].isFilterAnalytics = NO;
        [self requestHomePageTabMenus:YES];
        // 还没有请求成功过的可以重新加载
        [ZFSkinViewModel isNeedToShow:^(BOOL need) {
            if (!need) {
                [ZFCommonRequestManager requestZFSkin];
            }
        }];
    }];
}

- (void)showMenus {
    [self.menuListView showWithOffsetY:self.menuView.y + self.menuView.height];
    [UIView animateWithDuration:0.25 animations:^{
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
        [self.menuExpansionButton.imageView setTransform:transform];
    }];
}

- (void)hiddenMenus {
    self.menuExpansionButton.selected = NO;
    [self.menuListView hidden];
    [UIView animateWithDuration:0.25 animations:^{
        CGAffineTransform transform = CGAffineTransformIdentity;
        [self.menuExpansionButton.imageView setTransform:transform];
    }];
}

- (void)addSeparetorView {
    [self.bottomLine removeFromSuperview];
    [self.menuView addSubview:self.bottomLine];
    [self.menuView bringSubviewToFront:self.bottomLine];
}

#pragma mark - Public method
- (void)scrollToTargetVCWithChannelID:(NSString *)channelID {
    self.selectIndex = 0;
    if ([self.pageMenuViewModel.values containsObject:channelID]) {
        NSUInteger index = [self.pageMenuViewModel.values indexOfObject:channelID];
        self.selectIndex = (int)index;
    }
    [self reloadData];
    [self arMenuViewHandle];
}

- (void)firingNavBarActionType:(HomeNavigationBarActionType)actionType {
    
    switch (actionType) {
        case HomeNavBarLeftButtonAction://左侧按钮
        {
            [self pushToCategoryParentVC];
            [self.class homeLeftButtonActionStatistics:@"search_category"];
        }
            break;
        case HomeNavBarRightButtonAction://右侧按钮
        {            
            [self pushToViewController:@"ZFCartViewController" propertyDic:nil];
            [self homeCartActionstatistics];
        }
            break;
        case HomeNavBarSearchCategoryButtonAction://搜索分类按钮
        {
            [self pushToSearchVC];
            [self.class homeLeftButtonActionStatistics:@"search"];
        }
            break;
        case HomeNavBarSearchImageButtonAction://搜图按钮
        {
            @weakify(self);
            [LBXPermission authorizeWithType:LBXPermissionType_Camera completion:^(BOOL granted, BOOL firstTime) {
                @strongify(self)
                if (granted) {
                    [self pushToViewController:@"ZFCameraViewController" propertyDic:nil];
                    
                } else if(!firstTime) {
                    NSString *title = ZFLocalizedString(@"Can not use camera", nil);
                    NSString *msg = [NSString stringWithFormat:ZFLocalizedString(@"cameraPermisson", nil), @"ZZZZZ"];
                    NSString *cancelTitle = ZFLocalizedString(@"Cancel", nil);
                    NSString *setting = ZFLocalizedString(@"Setting_VC_Title", nil);
                    [LBXPermissionSetting showAlertToDislayPrivacySettingWithTitle:title msg:msg cancel:cancelTitle setting:setting];
                }
            }];
        }
            break;
        default:
            break;
    }
}

- (void)pushToSearchVC {
    ZFSearchViewController *searchVC = [[ZFSearchViewController alloc] init];
    // searchVC.placeholder = self.homeNavigationBar.inputPlaceHolder;
    [self.navigationController pushViewController:searchVC animated:YES];
}

- (void)pushToCategoryParentVC {
    ZFCategoryParentViewController *categoryVC = [[ZFCategoryParentViewController alloc] init];
    [self.navigationController pushViewController:categoryVC animated:YES];
}

#pragma mark - <Statistics>

+ (void)homeLeftButtonActionStatistics:(NSString *)af_button_name {
    NSString *af_user_type = [AccountManager sharedManager].af_user_type;
    NSDictionary *appsflyerParams = @{@"af_button_name"     : ZFToString(af_button_name),
                                      @"af_user_type"       : ZFToString(af_user_type),
                                      @"af_page_name"       : @"homepage"};
    
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_search_category_click" withValues:appsflyerParams];
}

- (void)homeCartActionstatistics {
    NSString *af_user_type = [AccountManager sharedManager].af_user_type;
    NSDictionary *appsflyerParams = @{@"af_button_name"     : ZFToString(@"homepage_cart"),
                                      @"af_user_type"       : ZFToString(af_user_type),
                                      @"af_page_name"       : @"homepage" };
    
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_homepage_cart_click" withValues:appsflyerParams];
}

#pragma mark - Action
- (void)menuExpansionAction {
    [ZFFireBaseAnalytics selectContentWithItemId:@"Click_Channel_Fast_Menu" itemName:@"Fast_Menu" ContentType:@"Channel - Menu" itemCategory:@"Button"];
    self.menuExpansionButton.selected = !self.menuExpansionButton.selected;
    self.menuExpansionButton.isSelected ? [self showMenus] : [self hiddenMenus];
}

- (void)floatBannerImageViewAction {
    if (!self.floatBannerModel) return;
    [BannerManager doBannerActionTarget:self withBannerModel:self.floatBannerModel];
    NSString *GAfloatBannerName = [NSString stringWithFormat:@"%@_%@", ZFGAHomeFloatBannerInternalPromotion, ZFToString(self.floatBannerModel.name)];
    [ZFAnalytics clickAdvertisementWithId:nil name:GAfloatBannerName position:nil];
    
    //增加AppsFlyer统计
    NSDictionary *appsflyerParams = @{@"af_content_type" : @"banner impression",  //固定值 banner impression
                                      @"af_banner_name" : ZFToString(self.floatBannerModel.name), //banenr名，如叫拼团
                                      @"af_channel_name" : ZFToString(self.floatBannerModel.menuid), //菜单id，如Homepage / NEW TO SALE
                                      @"af_ad_id" : ZFToString(self.floatBannerModel.banner_id), //banenr id，数据来源于后台配置返回的id
                                      @"af_component_id" : ZFToString(self.floatBannerModel.componentId),//组件id，数据来源于后台返回的组件id
                                      @"af_col_id" : ZFToString(self.floatBannerModel.colid), //坑位id，数据来源于后台返回的坑位id
                                      @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                      @"af_page_name" : @"homepage",    // 当前页面名称
                                      @"af_first_entrance" : @"small_float_window"  // 一级入口名
                                      };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_banner_click" withValues:appsflyerParams];
    
//    [ZFGrowingIOAnalytics ZFGrowingIOActivityClickByCMS:self.floatBannerModel];
    [ZFGrowingIOAnalytics ZFGrowingIObannerClickWithBannerModel:self.floatBannerModel page:GIOSourceHomeSmallFloat sourceParams:@{
        GIOFistEvar : ZFToString(self.floatBannerModel.name)
    }];
}

/// 监听: 重复单击当前控制器的TabbarItem
- (void)repeatTapTabBarCurrentController {
    // 监听单击事件: 下面只服务于首页tab子控制器的单击
    NSArray *VCArray = self.childViewControllers;
    if (VCArray.count > 0) {
        ZFPerformSelectorLeakWarning( //忽略警告
            SEL sel = @selector(repeatTouchTabBarToViewController);
            if ([VCArray.firstObject respondsToSelector:sel]) {
                [VCArray.firstObject performSelector:sel];
            }
        );
    }
}

#pragma mark - Getter
- (ZFCommunityRedDotViewModel *)redDotModel {
    if (!_redDotModel) {
        _redDotModel = [[ZFCommunityRedDotViewModel alloc] init];
    }
    return _redDotModel;
}

- (ZFHomePageMenuViewModel *)pageMenuViewModel {
    if (!_pageMenuViewModel) {
        _pageMenuViewModel = [[ZFHomePageMenuViewModel alloc] init];
        _pageMenuViewModel.controller = self;
    }
    return _pageMenuViewModel;
}

- (ZFHomeNavigationBar *)homeNavigationBar {
    if (!_homeNavigationBar) {
        _homeNavigationBar = [[ZFHomeNavigationBar alloc] init];
        @weakify(self)
        _homeNavigationBar.navigationBarActionBlock = ^(HomeNavigationBarActionType actionType) {
            @strongify(self)
            [self firingNavBarActionType:actionType];
        };
    }
    return _homeNavigationBar;
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.frame = CGRectMake(0.0, kTabMenuHeight - 0.5, self.view.width, 0.5);
        _bottomLine.backgroundColor = [UIColor colorWithHex:0xdddddd];
    }
    return _bottomLine;
}

- (UIButton *)menuExpansionButton {
    if (!_menuExpansionButton) {
        _menuExpansionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _menuExpansionButton.frame = CGRectMake(0.0, 0.0, kTabMenuHeight, kTabMenuHeight);
        _menuExpansionButton.backgroundColor =  [UIColor clearColor];
        _menuExpansionButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, -3.0f, 0.0, 3.0f);
        [_menuExpansionButton setImage:[UIImage imageNamed:@"cart_unavailable_arrow_down"] forState:UIControlStateNormal];
        [_menuExpansionButton addTarget:self action:@selector(menuExpansionAction) forControlEvents:UIControlEventTouchUpInside];
        
        self.menuGradientLayer = [[CAGradientLayer alloc] init];
        self.menuGradientLayer.colors = @[(__bridge id)ZFCOLOR(255.0, 255.0, 255.0, 0.0).CGColor, (__bridge id)ZFCOLOR(255.0, 255.0, 255.0, 1.0).CGColor];
        self.menuGradientLayer.frame = CGRectMake(-24.0, 0.0, 24.0, self.menuExpansionButton.height);
        self.menuGradientLayer.startPoint = CGPointMake(0, 0);
        self.menuGradientLayer.endPoint   = CGPointMake(1, 0);
        [_menuExpansionButton.layer addSublayer:self.menuGradientLayer];
    }
    return _menuExpansionButton;
}

- (YYAnimatedImageView *)floatBannerImageView {
    if (!_floatBannerImageView) {
        _floatBannerImageView = [[YYAnimatedImageView alloc] init];
        _floatBannerImageView.backgroundColor = [UIColor clearColor];
        _floatBannerImageView.contentMode = UIViewContentModeScaleAspectFit;
        _floatBannerImageView.clipsToBounds = YES;
        CGFloat floatBtnY = KScreenHeight- (68 + TabBarHeight + 20);
        if ([SystemConfigUtils isRightToLeftShow]) {
            _floatBannerImageView.frame = CGRectMake(10, floatBtnY, 68, 68);
        } else {
            _floatBannerImageView.frame = CGRectMake(KScreenWidth-(68+10), floatBtnY, 68, 68);
        }
        _floatBannerImageView.hidden = YES;//下载完才显示
        
        _floatBannerImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
        [tapGesture addTarget:self action:@selector(floatBannerImageViewAction)];
        [_floatBannerImageView addGestureRecognizer:tapGesture];
    }
    return _floatBannerImageView;
}

@end
