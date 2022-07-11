//
//  OSSWMHomeVC.m
// OSSWMHomeVC
//
//  Created by 10010 on 2017/8/28.
//  Copyright © 2017年 XStarlinkProject. All rights reserved.
//

#import "OSSWMHomeVC.h"
#import "STLAlertControllerView.h"
#import "AppDelegate+STLCategory.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "OSSVWishListVC.h"
#import "OSSVMyHelpVC.h"
#import "OSSVCountrySelectVC.h"
#import "OSSVHomeMainVC.h"
#import "STLActivityWWebCtrl.h"
#import "OSSVMessageVC.h"
#import "OSSVSearchVC.h"
#import "OSSVCartVC.h"
#import "OSSVCategorysNewZeroListVC.h"
#import "OSSVAppNewThemeVC.h"

#import "OSSVHomeNavBar.h"
#import "OSSVHomeFloatAdvView.h"

#import "OSSVCommonnRequestsManager.h"

#import "OSSVHomesViewModel.h"
#import "OSSVHomeChannelsModel.h"
#import "OSSVAdvsViewsManager.h"


#import "OSSVHomesAdvsViewModel.h"
#import "CacheFileManager.h"
#import "OSSVConfigDomainsManager.h"
#import "STLTabbarManager.h"
#import "OSSVOrdersWarnsCountrysInfoModel.h"
#import "CountryModel.h"

#import "OSSVLocaslHosstManager.h"
#import "AppDelegate.h"

#import "STLAlertSelectMessageView.h"
#import "STLALertTitleMessageView.h"
#import "STLAlertBottomView.h"
#import "OSSVCommonnRequestsManager.h"
#import "STLPreference.h"
#import "OSSVHomesBottomAdvsView.h"

#import "Adorawe-Swift.h"

@interface OSSWMHomeVC ()<HomeNavigationBarDelegate>

@property (nonatomic, assign) BOOL                     firstEnter;
@property (nonatomic, strong) OSSVHomesViewModel            *viewModel;
@property (nonatomic, strong) NSArray                  *dataArray;
@property (nonatomic, strong) OSSVHomeNavBar     *navigationBar;
@property (nonatomic, strong) UIScrollView             *emptyBackView;
@property (nonatomic, strong) OSSVMessageListModel      *msgListModel;
@property (nonatomic, strong) OSSVHomesAdvsViewModel         *homeAdvModel;
@property (nonatomic, strong) OSSVAdvsEventsModel         *homeAdvEventModel;
@property (nonatomic, strong) OSSVAdvsEventsModel         *homeAdvBannerEventModel;

@property (nonatomic, strong) UIView                   *menuLineView;


@property (nonatomic, strong) OSSVHomeFloatAdvView   *floatBannerView;

//暂时
@property (nonatomic, assign) BOOL                     homeAdvRequestEnd;
@property (nonatomic, assign) BOOL                     isCache;
@property (nonatomic, assign) BOOL                     analyticsTime;
@property (nonatomic, strong) NSArray                  *hotWordArray;

@property (nonatomic,strong) PrivacySheet              *privacySheet;
@end

@implementation OSSWMHomeVC

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    if (self = [super init]) {
        self.titleFontName = @"Arial-BoldMT";
        self.pageAnimatable = NO;
//        self.menuHeight = 40;
//        self.showOnNavigationBar = YES;
        self.postNotification = YES;
        self.bounces = YES;
        self.titleSizeNormal = 15;
        self.titleSizeSelected = 15;
        
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            self.titleFontName = @"Almarai-Bold";
        } else {
            self.titleFontName = @"Lato-Bold";
        }
        
        self.menuViewStyle = WMMenuViewStyleLine;
        self.itemMargin = 15;
//        self.menuViewLayoutMode = WMMenuViewLayoutModeCenter;
        self.automaticallyCalculatesItemWidths = YES;
        self.titleColorSelected = [OSSVThemesColors col_0D0D0D];
        self.titleColorNormal = [OSSVThemesColors col_666666];
        self.progressColor = [OSSVThemesColors col_0D0D0D];
        self.progressViewBottomSpace = 10;
//        self.menuBGColor = [UIColor clearColor];;
        self.firstEnter = YES;
//        self.viewFrame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - kTabHeight - 40 - 20 - kIPHONEX_TOP_SPACE);
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (![OSSVAdvsViewsManager sharedManager].isEndSheetAdv) {
        [OSSVAdvsViewsManager sharedManager].isAcrossHome = YES;
    }
    //只在首页弹窗
    [[OSSVAdvsViewsManager sharedManager] removeHomeAdv];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
        
    
    if (!self.firstEnter) {
        self.firstEnter = NO;
        [self refreshOnLine];
    }

    [self.navigationBar showCartOrMessageCount];
    
    if (![[STLPreference objectForKey:@"noNeedShowPrivacy"] boolValue] && [OSSVAccountsManager sharedManager].sysIniModel.is_show_privacy) {
        [self.privacySheet showInParentView:self.view bottomAncher:nil offset:@12];
        for (UIView *sub in self.view.subviews) {///1.4.6 privacy 优先级 > 广告
            if ([sub isKindOfClass:OSSVHomesBottomAdvsView.class]) {
                [sub removeFromSuperview];
            }
        }
    }else{
        [self alertAdv];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.privacySheet.superview == self.view) {
        [self.view bringSubviewToFront:self.privacySheet];
    }
}

-(void)alertAdv{
    // 未结束 重新回来
    if (![OSSVAdvsViewsManager sharedManager].isEndSheetAdv) {
        [self showHomeAdv];
    }else{
        if ([OSSVAdvsViewsManager sharedManager].currentAdvView && ![OSSVAdvsViewsManager sharedManager].currentAdvView.isHidden) {
            return;
        }
        [self showBottomBanner];
    }
}

- (void)refreshOnLine {
    [OSSVCommonnRequestsManager refreshAppOnLineDomain];
}

//更新悬浮banner 数据
- (void)reloadFloatBannerRequest {
    [self loadFloatBannerView];
}

- (void)reloadOnlineRequest {
    [self requestData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    [self.view addSubview:self.navigationBar];
    
    
    [[OSSVAnalyticPagesManager sharedManager] pageStartTime:@"WMHomeViewController"];
    STLLog(@"=====时区：%@",[[NSTimeZone systemTimeZone] name]);

    [self settingNotifice];
    [self createEmptyViews];
    [self requestData];
    [self updateLogoWithModel:[STLTabbarManager sharedInstance].model];

    [OSSVCommonnRequestsManager asyncRequestOtherApi];
    [self requestHotSearchWords];

    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [APPDELEGATE localDeeplinkAction];
        
        //暂时只请求一次
        [self loadMessageData];
    });
    
        
    [self performSelector:@selector(loadFloatBannerView) withObject:nil afterDelay:3];
    
#if DEBUG
    
    STLLog(@"ccccccccccccccccccc:%@",STL_PATH_CACHE);
//    NSAttributedString *att =  [NSString couponUseDesc];
//    [OSSVAlertsViewNew showAlertWithFrame:[UIScreen mainScreen].bounds alertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:YES showHeightIndex:2 title:@"xxx title 1234567 88 xxx title  vvvvv bbbbxxx title 1234567 88 xxx title  vvvvv bbbb" message:STLLocalizedString_(@"CashBackHeadline", nil) buttonTitles:@[@"xxx",@"yyy",@"mmm"] buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
//        STLLog(@"--- %li   %@",(long)index,title);
//    } closeBlock:^{
//        
//    }];
//    
//    [OSSVAlertsViewNew showAlertWithFrame:[UIScreen mainScreen].bounds alertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:YES showHeightIndex:0 title:@"xxx title 1234567 88 xxx title  vvvvv bbbbxxx title 1234567 88 xxx title  vvvvv bbbb" message:att buttonTitles:@[@"xxx",@"yyy"] buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
//        STLLog(@"--- %li   %@",(long)index,title);
//    } closeBlock:^{
//        
//    }];
    
//        [STLPushManager showPushTipMessage:@"" message:@"dsfasd dfafd fd fd  fdao jfda ifd jfdaj jfdafi jdfja dja jfdj dfja jfd1234 22" hours:@"12"];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [STLPushManager jundgePushViewToTop];
//
//    });

#endif
    
#if APP_TYPE == 1
    STLLog(@"============当前项目1：%@",[OSSVLocaslHosstManager appName]);
#elif APP_TYPE == 2
    STLLog(@"============当前项目2：%@",[OSSVLocaslHosstManager appName]);

#elif APP_TYPE == 3
    STLLog(@"============当前项目3：%@",[OSSVLocaslHosstManager appName]);

#endif
}

#pragma mark ---请求热搜词， 用于顶部搜索框文案滚动
- (void)requestHotSearchWords {
    
    NSString *groupId = @"index";
    OSSVHotsSearchsWordsAip *api = [[OSSVHotsSearchsWordsAip alloc] initWithGroupId:groupId cateId:@""];
    @weakify(self)
    [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        @strongify(self)
        id requestJSON = [OSSVNSStringTool desEncrypt:request];
        
        if ([requestJSON[kStatusCode] integerValue] == kStatusCode_200){
            
            self.hotWordArray = [NSArray yy_modelArrayWithClass:[OSSVHotsSearchWordsModel class] json:requestJSON[kResult]];
            self.navigationBar.hotWordsArray = self.hotWordArray;

        }else{
            self.navigationBar.hotWordsArray = @[];
            [HUDManager showHUDWithMessage:requestJSON[@"message"]];
        }
        
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        [HUDManager showHUDWithMessage:STLLocalizedString_(@"networkNotAvailable", nil)];
        self.navigationBar.hotWordsArray = @[];
    }];
}


- (void)settingNotifice {
    // 通知 登录、退出、改变性别
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHomeChannel:) name:kNotif_Login object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHomeChannel:) name:kNotif_Logout object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHomeChannel:) name:kNotif_HomeChannel object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHomeChannel:) name:kNotif_ChangeGender object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(homeAdvNotif:) name:kNotif_HomeAdv object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkUpdateApp) name:kNotif_UpdateApp object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MonitorSliding:) name:kNotif_HomeScroll object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadOnlineRequest) name:kNotif_OnlineAddressUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFloatBannerRequest) name:kNotif_updateHomeFloatBannerData object:nil];
    // 首页底部banner获取成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showBottomBanner) name:kNotif_getHomeBottomBannerSuccess object:nil];

}

- (void)homeAdvNotif:(NSNotification *)notift {
    
    NSString *isShow = notift.object;
    ///1.4.6 隐私政策
    if (![[STLPreference objectForKey:@"noNeedShowPrivacy"] boolValue]  && ![[notift.userInfo objectForKey:@"privacyClose"] isEqualToString:@"1"] && [OSSVAccountsManager sharedManager].sysIniModel.is_show_privacy) {
        self.privacySheet.notification = notift;
        [self.privacySheet showInParentView:self.view bottomAncher:nil offset:@12];
    }else{
        if ([isShow isEqualToString:@"1"] && !self.privacySheet.isShow) {
            [OSSVAdvsViewsManager sharedManager].isAcrossHome = YES;
            [self showHomeAdv];
        }
    }
    
}

- (BOOL)checkUpdateApp {
    //判断是否更新
    if ([OSSVAdvsViewsManager sharedManager].isUpdateApp) {
        BOOL isForce = [OSSVAdvsViewsManager sharedManager].is_force;
        OSSVTabBarVC *tabBar = AppDelegate.mainTabBar;
        if (tabBar) {
            UINavigationController *currentNav = tabBar.selectedViewController;
            
            NSString *updateMsg = [OSSVAdvsViewsManager sharedManager].updateContent;
            if (STLIsEmptyString(updateMsg)) {
                updateMsg = STLLocalizedString_(@"The_current_version_APP_updated_info", nil);
            }
            [STLAlertControllerView showCtrl:[currentNav visibleViewController]
                                  alertTitle:STLLocalizedString_(@"Tip", nil)
                                     message:updateMsg
                                      oneMsg:STLLocalizedString_(@"update", nil)
                                      twoMsg:!isForce ? STLLocalizedString_(@"cancel", nil).uppercaseString : nil
                           completionHandler:^(NSInteger flag) {
                if (flag == 1) {
                    [[OSSVAdvsViewsManager sharedManager] goUpdateApp];
                } else {
                    [OSSVAdvsViewsManager sharedManager].isUpdateApp = NO;
                }
            }];
            
            [STLPushManager jundgePushViewRemove];
        }
        return YES;
    }
    return NO;
}

- (void)showHomeAdv {

    if (self.homeAdvEventModel) {
        [[OSSVAdvsViewsManager sharedManager] showAdvEventModel:self.homeAdvEventModel];
        
    } else {
        
        if (self.homeAdvRequestEnd) {//请求成功，但是没数据
            [OSSVAdvsViewsManager sharedManager].isEndSheetAdv = YES;
            return;
        }
        
        @weakify(self)
        [self.homeAdvModel requestNetwork:@{} completion:^(NSDictionary *obj) {
            NSLog(@"----- ----- showHomeAdv");
            @strongify(self)
            
            if (!obj) {
                self.homeAdvRequestEnd = YES;
                [OSSVAdvsViewsManager sharedManager].isEndSheetAdv = YES;
                [OSSVAdvsViewsManager sharedManager].isLaunchAdv = NO;
                self.homeAdvEventModel = nil;
                self.homeAdvEventModel.advType = AdverTypeHomeActity;
                [[OSSVAdvsViewsManager sharedManager] showAdvEventModel:self.homeAdvEventModel];
                return;
            }
            
            
            self.homeAdvRequestEnd = YES;
            NSArray *banners = obj[@"banner"];
            if ([banners isKindOfClass:[NSArray class]]) {
                NSDictionary *homeAdvDic = banners.firstObject;

                if ([homeAdvDic isKindOfClass:[NSDictionary class]]) {
                    self.homeAdvEventModel = [OSSVAdvsEventsModel yy_modelWithJSON:homeAdvDic];
                    self.homeAdvEventModel.advType = AdverTypeHomeActity;
                    [[OSSVAdvsViewsManager sharedManager] showAdvEventModel:self.homeAdvEventModel];
                }
            }
            
        } failure:^(id obj) {
            @strongify(self)
            self.homeAdvRequestEnd = YES;
            [OSSVAdvsViewsManager sharedManager].isEndSheetAdv = YES;
            [OSSVAdvsViewsManager sharedManager].isLaunchAdv = NO;
            [[OSSVAdvsViewsManager sharedManager] showAdvEventModel:self.homeAdvEventModel];
        }];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLogo:) name:kNotif_LoadFinishTabbarIcon object:nil]; // 下载完成首页气氛消息通知

}

#pragma mark -- showBottomBanner

- (void)showBottomBanner{
    if (![OSSVAdvsViewsManager sharedManager].isDidShowHomeBanner) {
        NSDictionary *homeBanner = [OSSVAccountsManager sharedManager].homeBanner;
        if ([homeBanner isKindOfClass:[NSDictionary class]]) {
            self.homeAdvBannerEventModel = [OSSVAdvsEventsModel yy_modelWithJSON:homeBanner];
            self.homeAdvBannerEventModel.advType = AdverTypeHomeBanner;
            [[OSSVAdvsViewsManager sharedManager] showAdvEventModel:self.homeAdvBannerEventModel];
        }
    }
}

#pragma mark - 处理滑动浮窗
/**
 * 延迟请求加载浮窗banner按钮UI
 */
- (void)loadFloatBannerView {
    
    @weakify(self);
    [self.viewModel requestHomeFloatWithCompletion:^(OSSVAdvsEventsModel *advModel) {
        @strongify(self);
        if (advModel) {
            self.floatBannerView.advModel = advModel;
            [self.floatBannerView.floatBannerImageView yy_setImageWithURL:[NSURL URLWithString:STLToString(advModel.imageURL)]
                                        placeholder:nil//[UIImage imageNamed:@"index_banner_loading"]
                                            options:kNilOptions
                                           progress:nil
                                          transform:^UIImage *(UIImage *image, NSURL *url) {
                                              return image;

                                          } completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                              self.floatBannerView.hidden = NO;
                                          }];
        }
        
    } failure:^(id obj) {
        
    }];
}
#pragma mark ---ScrollView 滚动接收的通知
//滚动检测的通知
- (void)MonitorSliding:(NSNotification *)notification {

//    UIScrollView *scrollView = (UIScrollView *)notification.object;
//    CGFloat scrollerOffsetY = scrollView.contentOffset.y;
//    if (scrollerOffsetY > 220.f) {
//        [self.navigationBar showOrHideSearchViewAnimation:YES];
//  
//    }else {
//        [self.navigationBar showOrHideSearchViewAnimation:NO];
//    }
}
#pragma mark - MakeUI------导航栏设置

- (OSSVHomeNavBar *)navigationBar {
    if (!_navigationBar) {
        _navigationBar = [[OSSVHomeNavBar alloc] init];
        
        [_navigationBar stl_showBottomLine:NO];
        _navigationBar.delegate = self;
        @weakify(self)
        _navigationBar.navBarActionBlock = ^(HomeNavBarActionType actionType) {
            @strongify(self)
            if (actionType == HomeNavBarLeftSearchAction) {
                //改为滚动代理
                [self jumpToSearchWithKey:@""];
            } else if(actionType == HomeNavBarRightCarAction) {
                [self actionCart];
            } else if (actionType == HomeNavBarRighMessageAction) {
//                [self actionHelp];
                [self actionMessage];
            } else {
                [self actionCollect];
            }
        };
    }
    return _navigationBar;
}

#pragma mark - Request------数据请求

- (OSSVHomesViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[OSSVHomesViewModel alloc] init];
    }
    return _viewModel;
}

- (OSSVHomesAdvsViewModel *)homeAdvModel {
    if (!_homeAdvModel) {
        _homeAdvModel = [[OSSVHomesAdvsViewModel alloc] init];
    }
    return _homeAdvModel;
}


- (void)refreshHomeChannel:(NSNotification *)notifi {
//    NSLog(@"%@",notifi.name);
    [self requestData];
}

- (void)requestData {
    
    @weakify(self)
    [self.viewModel homeRequest:nil completion:^(id result, BOOL isCache, BOOL isEqualData) {
        @strongify(self)
        
        self.isCache = isCache;
        if (isEqualData) {//与缓存数据相同 用于第一个控制器刷新数据
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_HomeDataRefresh object:nil];
        } else {
            
            self.dataArray = [NSArray arrayWithArray:STLJudgeNSArray(result) ? result : @[]];
            [self reloadData];
            [self.view addSubview:self.floatBannerView];
            [self arMenuViewHandle];
            
            if (!STLJudgeEmptyArray(self.dataArray)) {
                self.emptyBackView.hidden = YES;
                [self.emptyBackView removeFromSuperview];
                [self.emptyBackView showRequestTip:@{}];
            } else if(self.emptyBackView.superview){
                self.emptyBackView.hidden = NO;
                [self.emptyBackView showRequestTip:@{}];
            }
        }
        
    } failure:^(id obj) {
        @strongify(self)
        
        if(self.emptyBackView && self.emptyBackView.superview) {
            self.emptyBackView.hidden = NO;
            [self.emptyBackView showRequestTip:nil];
        }
    }];
}

- (void)loadMessageData {
    
    if ([OSSVAccountsManager sharedManager].isSignIn) {
        
        @weakify(self)
        [self.viewModel messageRequest:nil completion:^(OSSVMessageListModel *obj) {
            @strongify(self)
            self.msgListModel = obj;
            [self updateMessageWithModel:obj];
        } failure:^(id obj) {
            
        }];
    }
}

- (void)updateMessageWithModel:(OSSVMessageListModel *)model {
    [OSSVAccountsManager sharedManager].appUnreadMessageNum = [model.total_count integerValue];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_ChangeMessageCountDot object:nil];
}

- (void)updateLogo:(NSNotification *)nofi {
    ////fffff 氛围隐藏
    return;
    
    NSDictionary *dict = [nofi userInfo];
    STLTabbarModel *model = [dict objectForKey:@"model"];
    [self updateLogoWithModel:model];
}

-(void)updateLogoWithModel:(STLTabbarModel *)model {
    if (![STLTabbarManager sharedInstance].model.isDownLoadNaviIcon) {
        return;
    }
    STLTabbarManager *manager = [STLTabbarManager sharedInstance];
    
    NSString *titleUrl = @"";
    NSString *searchUrl = @"";
    NSString *naviBgUrl = @"";
    NSString *messageUrl = @"";
    
    if (manager.type == STLDeviceImageTypeIphoneX) {
        titleUrl = model.title_bar.logo_url_3x;
        searchUrl = model.title_bar.search_url_3x;
        naviBgUrl = model.title_bar.bg_img_url_iphonx;
        messageUrl = model.title_bar.message_url_3x;
        
    } else if (manager.type == STLDeviceImageType3X) {
        titleUrl = model.title_bar.logo_url_3x;
        searchUrl = model.title_bar.search_url_3x;
        naviBgUrl = model.title_bar.bg_img_url_3x;
        messageUrl = model.title_bar.message_url_3x;
        
    } else {
        titleUrl = model.title_bar.logo_url_2x;
        searchUrl = model.title_bar.search_url_2x;
        naviBgUrl = model.title_bar.bg_img_url_2x;
        messageUrl = model.title_bar.message_url_2x;
    }

    
    YYImageCache *imageCache = [YYImageCache sharedCache];
    UIImage *naviImage = [imageCache getImageForKey:naviBgUrl withType:YYImageCacheTypeDisk];
    
    if (naviImage) {
        [self.navigationController.navigationBar setBackgroundImage:naviImage forBarMetrics:UIBarMetricsDefault];
    }
    
    YYImage *titleImage = [imageCache getImageForKey:titleUrl withType:YYImageCacheTypeDisk];
    if (titleImage) {
        [self.navigationBar stl_setLogoImage:titleImage];
    }

//    UIImage *searchImage = [imageCache getImageForKey:searchUrl withType:YYImageCacheTypeDisk];
//    if (searchImage) {
//        [self.rightButton setImage:searchImage?searchImage:[UIImage imageNamed:@"search_icon"] forState:UIControlStateNormal];
//    }
//
//    UIImage *messageImage = [imageCache getImageForKey:messageUrl withType:YYImageCacheTypeDisk];
//    if (messageImage) {
//        [self.messageBtn setImage:messageImage forState:UIControlStateNormal];
//    }
}
//occ阿语适配
- (void)arMenuViewHandle {
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        self.menuView.transform = CGAffineTransformMakeScale(-1.0,1.0);
        self.scrollView.transform = CGAffineTransformMakeScale(-1.0,1.0);
        
        NSArray *subMenuViews = self.menuView.scrollView.subviews;
        for (UIView *subView in subMenuViews) {
            if ([subView isKindOfClass:[WMMenuItem class]]) {
                subView.transform = CGAffineTransformMakeScale(-1.0,1.0);
            }
        }
    }
    
    self.menuLineView = [[UIView alloc] initWithFrame:CGRectZero];
    self.menuLineView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    
    
    if (self.menuView) {
        [self.menuView addSubview:self.menuLineView];
        [self.menuLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.bottom.trailing.mas_equalTo(self.menuView);
            make.height.mas_equalTo(0.5);
        }];
    }
}

#pragma mark - WMPageControllerDataSource
- (void)pageControllerWithCountrySelect:(WMPageController *)pageController {
    //select country
//    OSSVCountrySelectVC *vc = [[OSSVCountrySelectVC alloc]init];
//    vc.viewModel.countryName = [OSSVAccountsManager sharedManager].countryModel.countryName;
//    vc.countryBlock = ^(CountryModel *model) {
//        UIButton *countryBtn =[pageController.menuView viewWithTag:101];
//        [countryBtn yy_setImageWithURL:[NSURL URLWithString:model.picture] forState:UIControlStateNormal options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation];
//        [OSSVAccountsManager sharedManager].countryModel = model;
//    };
//    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return self.dataArray.count;
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    OSSVHomeChannelsModel *model = self.dataArray[index];
    return model.channelName;
}

- (__kindof UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    OSSVHomeChannelsModel *model = self.dataArray[index];
    OSSVHomeMainVC *discoveryItemVC = [[OSSVHomeMainVC alloc] init];
    discoveryItemVC.channelName = model.channelName;
    discoveryItemVC.channelName_en = model.en_name;
    discoveryItemVC.channel_id = model.channelId;
    discoveryItemVC.index = index;
    if (index == 0) {
        discoveryItemVC.isCache = self.isCache;
    }
    
    @weakify(self)
    discoveryItemVC.showFloatBannerBlock = ^(BOOL show){
        @strongify(self)
        [self showFloatBannerImageView:show]; //滑动列表时是否隐藏浮动按钮
    };
    
    discoveryItemVC.requestCompleteBlock = ^(BOOL state) {
        @strongify(self)
        if (!self.analyticsTime) {
            self.analyticsTime = YES;
            
            NSString *startTime = [[OSSVAnalyticPagesManager sharedManager] startPageTime:@"WMHomeViewController"];
            NSString *endTime = [[OSSVAnalyticPagesManager sharedManager] endPageTime:@"WMHomeViewController"];

            NSString *timeLeng = [[OSSVAnalyticPagesManager sharedManager] pageEndTimeLength:@"WMHomeViewController"];
            [OSSVAnalyticsTool analyticsSensorsEventWithName:@"key_page_load" parameters:@{@"$screen_name":NSStringFromClass(OSSWMHomeVC.class),
                                                                                      @"$referrer":@"",
                                                                                      @"$title":STLToString(self.title),
                                                                                        @"$url":STLToString(model.channelId),
                                                                                        @"load_begin":startTime,
                                                                                        @"load_end":endTime,
                                                                                      @"load_time":timeLeng}];
        }
    };
    

    return discoveryItemVC;
}
//当viewController完全显示时调用 --info包含了（index， title）
- (void)pageController:(WMPageController *)pageController didEnterViewController:(__kindof UIViewController *)viewController withInfo:(NSDictionary *)info {
    [self showFloatBannerImageView:YES];
    
    if (STLJudgeNSDictionary(info)) {
        //NSInteger indxe = [info[@"index"] integerValue];
        NSString *title = STLToString(info[@"title"]);
        
        [OSSVAnalyticsTool analyticsGAEventWithName:@"top_navigation" parameters:@{
               @"screen_group":@"Home",
               @"action":[NSString stringWithFormat:@"%@",STLToString(title)]}];
    }
    
    if (self.privacySheet.superview == self.view) {
        [self.view bringSubviewToFront:self.privacySheet];
    }
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    CGFloat menuHeight = self.dataArray.count == 1 ? 0.0f : 44;
    return CGRectMake(0, self.navigationBar.height, SCREEN_WIDTH, menuHeight);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    
    CGFloat menuMaxY = CGRectGetMaxY([self pageController:pageController preferredFrameForMenuView:self.menuView]);
    return CGRectMake(0, menuMaxY, SCREEN_WIDTH, SCREEN_HEIGHT - menuMaxY - self.tabBarController.tabBar.bounds.size.height);
}

#pragma mark - 点击搜索框滚动文字的代理
- (void)jumpToSearchWithKey:(NSString *)searchKey {
    OSSVSearchVC * searchVC = [[OSSVSearchVC alloc] init];
    searchVC.enterName = @"Home";
    searchVC.searchTitle = searchKey;
    [self.navigationController pushViewController:searchVC animated:true];
    
    [OSSVAnalyticsTool analyticsGAEventWithName:@"top_function" parameters:@{
           @"screen_group":@"Home",
           @"button_name":@"Search_box"}];

}

//点击购物车Action
- (void)actionCart {

    OSSVCartVC *cartVC = [[OSSVCartVC alloc] init];
    [self.navigationController pushViewController:cartVC animated:YES];
    
    [OSSVAnalyticsTool analyticsGAEventWithName:@"top_function" parameters:@{
           @"screen_group":@"Home",
           @"button_name":@"Cart"}];
}
//帮助中心
- (void)actionHelp {
    OSSVMyHelpVC *helpVC = [[OSSVMyHelpVC alloc] init];
    [self.navigationController pushViewController:helpVC animated:YES];
}
//收藏
- (void)actionCollect {
    //用户未登录
    if (![OSSVAccountsManager sharedManager].isSignIn) {
        SignViewController *signVC = [SignViewController new];
        signVC.modalPresentationStyle = UIModalPresentationFullScreen;
        @weakify(self)
        signVC.modalBlock = ^{
            @strongify(self)
            [self jumpToWishListVc];
        };
        [self presentViewController:signVC animated:YES completion:nil];
        
    } else {
        [self jumpToWishListVc];
    }
}

-(void)actionMessage{
    //用户未登录
    if (![OSSVAccountsManager sharedManager].isSignIn) {
        SignViewController *signVC = [SignViewController new];
        signVC.modalPresentationStyle = UIModalPresentationFullScreen;
        @weakify(self)
        signVC.modalBlock = ^{
            @strongify(self)
            [self jumpToMessage];
        };
        [self presentViewController:signVC animated:YES completion:nil];
        
    } else {
        [self jumpToMessage];
    }
    
    [OSSVAnalyticsTool analyticsGAEventWithName:@"top_function" parameters:@{
           @"screen_group":@"Home",
           @"button_name":@"Message"}];
}

-(void)jumpToMessage{
    OSSVMessageVC *messageVC = [[OSSVMessageVC alloc] init];
    [self.navigationController pushViewController:messageVC animated:YES];
}

-(void)jumpToWishListVc {

    OSSVWishListVC *couponVC = [[OSSVWishListVC alloc] init];
    [self.navigationController pushViewController:couponVC animated:YES];

}

/**
 * 是否显示浮窗banner按钮
 */
- (void)showFloatBannerImageView:(BOOL)show {
    if (!_floatBannerView || _floatBannerView.hidden) return ;
    if (show) {
        [UIView animateWithDuration:0.6 animations:^{
//            self.floatBannerView.alpha = 1.0;
            
            if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
                self.floatBannerView.x = 8;
            } else {
                self.floatBannerView.x = SCREEN_WIDTH-(72+8);
            }
        } completion:^(BOOL finished) {
            self.floatBannerView.userInteractionEnabled = YES;
        }];
    } else {
        self.floatBannerView.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.6 animations:^{
//            self.floatBannerView.alpha = 0.5;
            
            if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
                self.floatBannerView.x = -72;
            } else {
                self.floatBannerView.x = SCREEN_WIDTH;
            }
        }];
    }
}

//- (void)messageBtnTouch:(UIButton *)sender {
//
//    if (USERID) {
//        @weakify(self)
//        OSSVMessageVC *vc = [OSSVMessageVC new];
//        vc.msgListModel = self.msgListModel;
//        vc.messageRefresh = ^(OSSVMessageListModel *model) {
//             @strongify(self)
//            self.msgListModel = model;
//            [self updateMessageWithModel:model];
//        };
//        [self.navigationController pushViewController:vc animated:YES];
//
//    } else {
//        SignViewController *signVC = [SignViewController new];
//        @weakify(self)
//        signVC.signBlock = ^{
//            @strongify(self)
//            OSSVMessageVC *vc = [OSSVMessageVC new];
//            vc.msgListModel = self.msgListModel;
//            @weakify(self)
//            vc.messageRefresh = ^(OSSVMessageListModel *model) {
//                 @strongify(self)
//                self.msgListModel = model;
//                [self updateMessageWithModel:model];
//            };
//            [self.navigationController pushViewController:vc animated:YES];
//        };
//        [self.navigationController presentViewController:signVC animated:YES completion:^{
//        }];
//    }
//}

- (OSSVHomeFloatAdvView *)floatBannerView {
    if (!_floatBannerView) {
        _floatBannerView = [[OSSVHomeFloatAdvView alloc] initWithFrame:CGRectZero];
        _floatBannerView.backgroundColor = [UIColor clearColor];
        CGFloat floatBtnY = SCREEN_HEIGHT- (72 + kTabHeight + 120);
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _floatBannerView.frame = CGRectMake(8, floatBtnY, 72, 72);
        } else {
            _floatBannerView.frame = CGRectMake(SCREEN_WIDTH-(60+12+8), floatBtnY, 72, 72);
        }
        _floatBannerView.hidden = YES;//下载完才显示
        
        @weakify(self);
        _floatBannerView.floatEventBlock = ^(OSSVAdvsEventsModel *advEventModel) {
            @strongify(self);
            
            if (advEventModel) {
                NSString *pageName = [UIViewController currentTopViewControllerPageName];
                NSDictionary *sensorsDic = @{@"page_name":STLToString(pageName),
                                             @"attr_node_1":@"home_bubble",
                                             @"attr_node_2":@"",
                                             @"attr_node_3":@"",
                                             @"position_number":@(0),
                                             @"venue_position":@(0),
                                             @"action_type":@([advEventModel advActionType]),
                                             @"url":[advEventModel advActionUrl],
                };
                [OSSVAnalyticsTool analyticsSensorsEventWithName:@"BannerClick" parameters:sensorsDic];
                
                //数据GA埋点曝光 广告点击
                                    
                                    // item
                                    NSMutableDictionary *item = [@{
                                //          kFIRParameterItemID: $itemId,
                                //          kFIRParameterItemName: $itemName,
                                //          kFIRParameterItemCategory: $itemCategory,
                                //          kFIRParameterItemVariant: $itemVariant,
                                //          kFIRParameterItemBrand: $itemBrand,
                                //          kFIRParameterPrice: $price,
                                //          kFIRParameterCurrency: $currency
                                    } mutableCopy];


                                    // Prepare promotion parameters
                                    NSMutableDictionary *promoParams = [@{
                                //          kFIRParameterPromotionID: $promotionId,
                                //          kFIRParameterPromotionName:$promotionName,
                                //          kFIRParameterCreativeName: $creativeName,
                                //          kFIRParameterCreativeSlot: @"Top Banner_"+$index,
                                //          @"screen_group":@"Home"
                                    } mutableCopy];

                                    // Add items
                                    promoParams[kFIRParameterItems] = @[item];
                                    
                                    [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventSelectPromotion parameters:promoParams];
                
                
                [OSSVAdvsEventsManager advEventTarget:self withEventModel:advEventModel];
            }

        };
    }
    return _floatBannerView;
}

- (NSArray *)hotWordArray {
    if (!_hotWordArray) {
        _hotWordArray = [NSArray array];
    }
    return _hotWordArray;
}
#pragma mark - 空白View
- (void)createEmptyViews {
    self.emptyBackView = [[UIScrollView alloc] init];
    self.emptyBackView.frame = self.view.bounds;
    self.emptyBackView.backgroundColor = [OSSVThemesColors col_F5F5F5];
    self.emptyBackView.blankPageImageViewTopDistance = 40;
    self.emptyBackView.hidden = YES;
    [self.view addSubview:self.emptyBackView];
    [self.emptyBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.navigationBar.mas_bottom);
    }];
    
    // 这样做是为了增加  菊花的刷新效果
    @weakify(self)
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        
        [self refreshOnLine];

        @weakify(self)
        [self.viewModel homeRequest:STLRefresh completion:^(id result, BOOL isCache, BOOL isEqualData) {
            @strongify(self)
            [self requestData];
            [self.emptyBackView.mj_header endRefreshing];
        } failure:^(id obj) {
            @strongify(self)
            [self.emptyBackView.mj_header endRefreshing];
            [self.emptyBackView showRequestTip:nil];
        }];
    }];
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;

    // 隐藏状态
    header.stateLabel.hidden = YES;
    self.emptyBackView.mj_header = header;
    if (app_type == 3) {
        self.emptyBackView.emptyDataBtnTitle = STLLocalizedString_(@"retry", nil);
    } else {
        self.emptyBackView.emptyDataBtnTitle = STLLocalizedString_(@"retry", nil).uppercaseString;
    }
    self.emptyBackView.blankPageViewActionBlcok = ^(STLBlankPageViewStatus status) {
        @strongify(self)
        [self.emptyBackView.mj_header beginRefreshing];
    };

}

- (PrivacySheet *)privacySheet{
    if (!_privacySheet) {
        _privacySheet = [[PrivacySheet alloc] initWithFrame:CGRectZero];
    }
    return _privacySheet;
}

@end
