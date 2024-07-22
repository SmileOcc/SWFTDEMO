//
//  AppDelegate.m
//  ZZZZZ
//
//  Created by YW on 18/9/13.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "AppDelegate.h"
#import "FilterManager.h"
#import "BannerManager.h"
#import "ZFBannerModel.h"
#import "JumpModel.h"
#import "JumpManager.h"
#import "ZFLaunchAdvertView.h"
#import "ZFNewVersionGuideVC.h"
#import "ZF3DTouchManager.h"
#import "AppDelegate+ZFNotification.h"
#import "AppDelegate+ZFThirdLibrary.h"
#import "ZFPushAllowView.h"
#import "ZFHomeFloatingView.h"
#import "ZFHomeAnalysis.h"
#import <GGPaySDK/GGAppDelegate.h>
#import "YWLocalHostManager.h"
#import <YYWebImage/YYWebImage.h>
#if DEBUG
#import "ZFAnalyticsInjectProtocol.h"
#endif
#import "NSStringUtils.h"
#import "ZFAnalyticsTimeManager.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFCommonRequestManager.h"
#import "ZFRequestModel.h"
#import "Constants.h"
#import "ZFAppsflyerAnalytics.h"
#import "ZFGrowingIOAnalytics.h"
#import <GGAppsflyerAnalyticsSDK/GGAppsflyerAnalytics.h>
#import "AFNetworkReachabilityManager.h"
#import "ZFLaunchAnimationView.h"

#import <ZegoLiveRoom/ZegoLiveRoom.h>
#import "ZFZegoHelper.h"
#import "ZFUserSexSelectViewController.h"
#import "ZFLocalizationString.h"

//通用API
#ifdef DEBUG
#define kComputeCodeTime(timeName)  NSNumber *timeName = @(CFAbsoluteTimeGetCurrent());
#define kGetTimeLogStr(result,array)    NSString *result = [[NSMutableString alloc] initWithString:@""];\
                                        for (int i = 1; i < array.count-1; i++){\
                                            NSNumber *preNum = array[i-1];\
                                            NSNumber *num = array[i];\
                                            [(NSMutableString *)result appendFormat:@"%.3f\t", num.doubleValue-preNum.doubleValue];\
                                        }\
                                        NSNumber *startNum = [array firstObject];\
                                        NSNumber *stopNum = [array lastObject];\
                                        [(NSMutableString *)result appendFormat:@"%.3f\t", stopNum.doubleValue-startNum.doubleValue];\
                                        result = [result copy];
#else
#define kComputeCodeTime(timeName)
#define kGetTimeLogStr(result,array)
#endif


@interface AppDelegate ()
/// 是否已经显示过首页浮窗, App运行后只走一次首页浮窗广告
@property (nonatomic, assign) BOOL hasShowHomeFloatView;
@property (nonatomic, assign) BOOL hasShowAndCloseHomeFloatView;
@end

@implementation AppDelegate

#pragma mark -===========程序启动入口===========

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    kComputeCodeTime(startTime)

    // 通知打开的相关处理
    [YWLocalHostManager launchOptionsRemoteOpenAppOptions:launchOptions];
    
    // APP配置
    [self appConfig];
    
    double statrTime = [NSStringUtils getCurrentMSimestamp].doubleValue;
    // 启动设置常规,清理缓存
    [self setupRuleAndCleanAppCache:launchOptions];
    
    kComputeCodeTime(q1Time)
    // 请求是否需要清除缓存数据
    [ZFCommonRequestManager requestiSNeedCleanAppData];

    // 配置崩溃检测库bugly,(注意:必须放在方法入口)
    [self initConfigBugly];
    
    // 捕获全局崩溃
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
    
    // 请求用户信息定位接口
    [ZFCommonRequestManager requestLocationInfo];
    
    // 启动App配置所有必要的第三方库
    [self initThirdPartObjectsWithOptions:launchOptions application:application];
    
    // 异步请求必要接口数据
    [ZFCommonRequestManager requestNecessaryData];
       
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self.window makeKeyAndVisible];
       
    //切换语言后切换系统UI布局方式
    [UIViewController convertAppUILayoutDirection];
    

    // 判断显示App窗口根控制器
    [self judgeInitAppTabbar];
    kComputeCodeTime(q2Time)

    // 处理推送通知所有相关
    [self dealWithNotification:application launchingOptions:launchOptions];

#warning 每次发版前需要跑一次，排查方法名的正确性 【跑单元测试 testAnalyticsBeforeRelease】
    // 统计启动加载时间
    [self analyticsLaunchingTime:statrTime];

    // 国际版
    [ZFZegoHelper setAppType:ZegoAppTypeI18N];
    //[ZFZegoHelper api];
    
    
        //didFinishedLaunching
    kComputeCodeTime(stopTime)
    #ifdef DEBUG
        NSArray *array = @[startTime,q1Time,q2Time,stopTime];
        kGetTimeLogStr(result,array)
        YWLog(@"didFinishLaunchingWithOptions:%@",result);
    #endif
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSMutableArray *a = [NSArray array];
//        [a addObject:@"1"];
//    });
    
    // 判断是否为点击桌面3DTouch进入App
    return [self judgeLaunchFrom3DTouchiCon:launchOptions];
}

/**
 * 统计启动加载时间
 */
- (void)analyticsLaunchingTime:(double)statrTime {
    double endTime = [NSStringUtils getCurrentMSimestamp].doubleValue;
    double time = endTime - statrTime;
    //统计
    [ZFAnalytics logSpeedWithCategory:@"App_Cost_Time" eventName:@"AppLaunchingTime" interval:time label:@"AppLaunchingTime"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSStringUtils getCurrentTimestamp] forKey:@"AppLaunchingTime"];
}

/**
 * 判断显示App窗口根控制器
 */
- (void)judgeInitAppTabbar
{
    // app当前版本
    NSString *version = GetUserDefault(APPVIERSION);
    if ([version isEqualToString:ZFSYSTEM_VERSION]) {
        
        //如果版本号存在,直接初始化AppTabbar进入主页
        [self initAppRootVC];
        
        //启动App判断是否需要显示倒计时广告
        ZFBannerModel *bannerModel = nil;
        NSData *imageData = nil;
        NSArray *launchAdvertDataArr = GetUserDefault(kLaunchAdvertDataDictiontryKey);
        if (ZFJudgeNSArray(launchAdvertDataArr) && launchAdvertDataArr.count > 0) {
            
            //(V3.6.0)随机取一个广告显示 
            NSInteger count = launchAdvertDataArr.count;
            NSInteger x = arc4random() % count;
            NSDictionary *bannerDic = nil;
            if (x < count) {
                bannerDic = launchAdvertDataArr[x];
            } else {
                bannerDic = launchAdvertDataArr[0];
            }
            if (ZFJudgeNSDictionary(bannerDic)) {
                imageData = bannerDic[kLaunchAdvertImageDataKey];
                bannerModel = [ZFBannerModel yy_modelWithJSON:bannerDic[kLaunchAdvertModelJsonKey]];
            }
        }
//        [ZFLaunchAnimationView showAnimationViewCompletion:^{
            if (bannerModel && imageData) { //显示启动倒计时广告
                [AppDelegate showLaunchAdvertView:bannerModel imageData:imageData completeHandler:^{
                    [AppDelegate checkAppUpgradeCompleteShowHomeFloat:YES];
                }];
            } else { //没有倒计时广告就走App版本更新，弹出推送窗
                [self enterAppCheckPushStatus:YES];
            }
//        }];        
    } else {
        //记录首次安装App的时间,在后面下单时统计时用到
        [self recordFirstEnterAppTime];
        SaveUserDefault(APPVIERSION, ZFToString(ZFSYSTEM_VERSION));
        
        //首次安装, 先显示引导视频 -> 再显示推送通知图
        ZFNewVersionGuideVC *guideController = [[ZFNewVersionGuideVC alloc] init];
        self.window.rootViewController = guideController;
        @weakify(self);
        guideController.didFinishBlock = ^() {
            @strongify(self);
            if (![GetUserDefault(@"sex_select") boolValue]) {
                [self enterUserSexSelectVC];
            } else {
                //进入主页显示, 引导打开推送通知
                [self enterAppHomeShowRemotePushView];
            }
        };
    }
}

/**
 * 用户性别选择页
 */
- (void)enterUserSexSelectVC {
    ZFUserSexSelectViewController *userSexVC = [[ZFUserSexSelectViewController alloc] init];
    self.window.rootViewController = userSexVC;
    @weakify(self);
    userSexVC.didFinishBlock = ^{
        @strongify(self);
        //进入主页显示, 引导打开推送通知
        [self enterAppHomeShowRemotePushView];
    };
    SaveUserDefault(@"sex_select",@"1");
}

/**
 * 初始化AppTabbr
 */
- (void)initAppRootVC {
    self.tabBarVC = [[ZFTabBarController alloc] init];
    self.window.rootViewController = self.tabBarVC;
    [self.tabBarVC isShowNewCouponDot];
    
    // 当还没进入tabbar就有深度跳转，先保存，进入后再执行
    if (self.isDeepLink) {
        NSData *data = GetUserDefault(DeepLinkModel);
        if ([data isKindOfClass:[NSData class]]) {
            JumpModel *jumpModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [JumpManager doJumpActionTarget:[UIViewController currentTopViewController] withJumpModel:jumpModel];
            self.isDeepLink = NO;
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:DeepLinkModel];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

/**
 * 进入主页显示, 引导打开推送通知
 */
- (void)enterAppHomeShowRemotePushView
{
    //初始化AppTabbar进入主页
    [self initAppRootVC];
    [self enterAppCheckPushStatus:NO];
}

/**
 * 每次进入App时，判断是否显示打开推送页面
 */
- (void)enterAppCheckPushStatus:(BOOL)show
{
    [ZFPushAllowView AppDidFinishLanuchShowPushAllowView:^{
        YWLog(@"版本升级进来, 再检查版本升级(防止长时间未更新)");
        [AppDelegate checkAppUpgradeCompleteShowHomeFloat:show];
    }];
}

/**
 * 检查版本更新, 完成后是否需要显示首页浮窗
 */
+ (void)checkAppUpgradeCompleteShowHomeFloat:(BOOL)show
{
    // 推送通知打开 延迟请求处理
    BOOL isLaunchRemoteNotif = [YWLocalHostManager stateLaunchOptionsRemoteOpenApp];;
    
    CGFloat afterTime = isLaunchRemoteNotif ? [ZFCommonRequestManager randomSecondsForMaxMillisecond:1000] + 3 : [ZFCommonRequestManager randomSecondsForMaxMillisecond:800];
    
    // 检查更新 延迟请求处理
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(afterTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ZFCommonRequestManager checkUpgradeZFApp:^(BOOL hasNoNewVersion) {
            if (show) { //是否显示首页广告浮窗
                [AppDelegate judgeShowHomeFloatView];
            }
        }];
    });
}

#pragma mark -===========启动判断显示页面跳转逻辑===========

/**
 * 显示启动倒计时广告
 */
+ (void)showLaunchAdvertView:(ZFBannerModel *)bannerModel
                   imageData:(NSData *)imageData
             completeHandler:(void(^)(void))completeHandler
{
    NSDictionary *appsflyerParams = @{@"af_content_type" : @"banner impression",  //固定值 banner impression
                                      @"af_banner_name" : ZFToString(bannerModel.name), //banenr名，如叫拼团
                                      @"af_channel_name" : ZFToString(bannerModel.menuid), //菜单id，如Homepage / NEW TO SALE
                                      @"af_ad_id" : ZFToString(bannerModel.banner_id), //banenr id，数据来源于后台配置返回的id
                                      @"af_component_id" : ZFToString(bannerModel.componentId),//组件id，数据来源于后台返回的组件id
                                      @"af_col_id" : ZFToString(bannerModel.colid), //坑位id，数据来源于后台返回的坑位id
                                      @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                      };
    void (^jumpBannerBlock)(void) = ^(void){
        YWLog(@"点击了倒计时广告");
        if(completeHandler){
            completeHandler();
        }
        //获取到的应该是主页的控制器
        UIViewController *homeVC = [UIViewController currentTopViewController];
        if (homeVC && bannerModel) {
            [BannerManager doBannerActionTarget:homeVC withBannerModel:bannerModel];
            NSString *GABannerName = [NSString stringWithFormat:@"%@_%@", ZFGAHomeCountDownBannerInternalPromotion, ZFToString(bannerModel.name)];
            [ZFAnalytics clickAdvertisementWithId:ZFToString(bannerModel.banner_id) name:GABannerName position:nil];
            
            NSMutableDictionary *afParams = [NSMutableDictionary dictionaryWithDictionary:appsflyerParams];
            afParams[@"af_page_name"] = @"splash_screen"; // 当前页面名称
            afParams[@"af_first_entrance"] = @"splash_screen"; // 一级入口名
            
            [ZFAppsflyerAnalytics zfTrackEvent:@"af_banner_click" withValues:afParams];
            
//            [ZFGrowingIOAnalytics ZFGrowingIOActivityClickByCMS:bannerModel];
            [ZFGrowingIOAnalytics ZFGrowingIObannerClickWithBannerModel:bannerModel page:GIOSourceSplashScreen sourceParams:@{
                GIOFistEvar : GIOSourceSplashScreen,
                GIOSndIdEvar : ZFToString(bannerModel.banner_id),
                GIOSndNameEvar : ZFToString(bannerModel.name)
            }];
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [AccountManager sharedManager].hasShowAdvertIntoApp = NO;
        });
    };
    
    //记录已经显示了启动倒计时广告进入App
    [AccountManager sharedManager].hasShowAdvertIntoApp = YES;
    
    [ZFLaunchAdvertView showAdvertWithImageData:imageData
                                jumpBannerBlock:(ZFIsEmptyString(bannerModel.deeplink_uri) ? nil : jumpBannerBlock)
                                skipBannerBlock:^{
        YWLog(@"倒计时广告跳过后, 显示版本更新弹框");
        [AccountManager sharedManager].hasShowAdvertIntoApp = NO;
        if(completeHandler){
            completeHandler();
        }
    }];
    NSString *GABannerName = [NSString stringWithFormat:@"%@_%@", ZFGAHomeCountDownBannerInternalPromotion, ZFToString(bannerModel.name)];
    [ZFAnalytics showAdvertisementWithBanners:@[@{@"name" : GABannerName}] position:nil screenName:nil];
    
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_banner_impression" withValues:appsflyerParams];
//    [ZFGrowingIOAnalytics ZFGrowingIOActivityImpByCMS:bannerModel];
    [ZFGrowingIOAnalytics ZFGrowingIOBannerImpWithBannerModel:bannerModel page:GIOSourceSplashScreen];
}

/**
 * 显示首页浮窗广告
 */
+ (void)judgeShowHomeFloatView {
    // 没有网络则此次不弹框
    if (![AFNetworkReachabilityManager sharedManager].reachable) return;
    
    // 在所有的弹框中 首页未支付订单弹框的优先级最低
    if ([AccountManager sharedManager].hasRequestUnpaidOrderAlertUrl) {
        if (APPDELEGATE.unpaidOrderModel) {
            [ZFCommonRequestManager showUnpaidOrderViewToHomeVC:APPDELEGATE.unpaidOrderModel];
        }
        return;
    }
    if (APPDELEGATE.hasShowHomeFloatView) {
        if (APPDELEGATE.hasShowAndCloseHomeFloatView &&
            [AccountManager sharedManager].hasRequestUnpaidOrderAlertUrl == NO) {
            [ZFCommonRequestManager requestUnpaidOrderDate];
        }
        return;
    }
    // (临时强制更新是: 有时有紧急bug导致的App不能启动, 提示用户需要卸载此版本重新安装)
    if ([AccountManager sharedManager].hasShowTempForceUpgrade) return;
    
    // 首次安装或更新APP是不要弹框的
    if (![GetUserDefault(APPVIERSION) isEqualToString:ZFSYSTEM_VERSION]) return;
    
    // 如果还没检查App版本号, 则先不显示浮窗广告
    if ([AccountManager sharedManager].hasCheckAppStoreVersion == NO) return;
    
    // 如果是从桌面重按图标3DTouch进入App, 则先不显示浮窗广告
    if ([AccountManager sharedManager].isAppIcon3DTouchIntoApp == YES) return;
    
    // 如果已经显示了启动倒计时广告, 则先不显示浮窗广告
    if ([AccountManager sharedManager].hasShowAdvertIntoApp == YES) return;
    
    // 浮窗广告只能在主页的控制器上弹出
    if (![self judgeCurrentIsHomeNavVC]) return;
    
    // 主页弹框提示有未支付订单提示
    void (^showNoPayOrderAlert)(void) = ^(void){
        APPDELEGATE.hasShowHomeFloatView = YES;
        APPDELEGATE.hasShowAndCloseHomeFloatView = YES;
        if ([AccountManager sharedManager].hasRequestUnpaidOrderAlertUrl) return;
        [ZFCommonRequestManager requestUnpaidOrderDate];
    };

    NSData *floatModelData = GetUserDefault(kHomeFloatModelKey);
    ZFBannerModel *floatModel = [NSKeyedUnarchiver unarchiveObjectWithData:floatModelData];
    if (![floatModel isKindOfClass:[ZFBannerModel class]] ||
        ZFIsEmptyString(floatModel.popupNumber)) {
        showNoPayOrderAlert();
        return;
    }
    
    NSInteger totalPopupNum = [floatModel.popupNumber integerValue];
    if (totalPopupNum == 0) {
        YWLog(@"需求:=0是一直弹浮窗广告");
    } else {
        NSInteger hasShowPopupNum = floatModel.hasShowPopupNum;
        YWLog(@"浮窗广告弹框总次数=%zd,已弹框次数=%zd",totalPopupNum, hasShowPopupNum);
        if (totalPopupNum < hasShowPopupNum) {
            showNoPayOrderAlert();
            return;
        }
        //显示了浮窗广告, 弹框数需要加1
        floatModel.hasShowPopupNum = (hasShowPopupNum + 1);
        NSData *floatModelData = [NSKeyedArchiver archivedDataWithRootObject:floatModel];
        SaveUserDefault(kHomeFloatModelKey, floatModelData);
    }
    
    APPDELEGATE.hasShowHomeFloatView = YES;
    [ZFHomeAnalysis showHomeFloatingAdvertWindow:floatModel];
    
    [ZFHomeFloatingView showFloatingViewWithUrl:floatModel.image tapBlock:^{
        YWLog(@"点击浮窗广告内容");
        APPDELEGATE.hasShowAndCloseHomeFloatView = YES;
        [ZFHomeAnalysis clickHomeFloatingAdvertWindow:floatModel];
        //获取到的应该是主页的控制器
        UIViewController *homeVC = [UIViewController currentTopViewController];
        if (!homeVC) {
            showNoPayOrderAlert();
            return;
        }
        [BannerManager doBannerActionTarget:homeVC withBannerModel:floatModel];
    } closeBlock:^{
        YWLog(@"点击关闭首页广告浮窗。。。");
        showNoPayOrderAlert();
    }];
}

/// 浮窗广告只能在主页的控制器上弹出
+ (BOOL)judgeCurrentIsHomeNavVC {
    if (!APPDELEGATE.tabBarVC) return NO;
    ZFNavigationController *homeNav = [APPDELEGATE.tabBarVC navigationControllerWithMoudle:(TabBarIndexHome)];
    UIViewController *homeVC = [homeNav.viewControllers firstObject];
    UIViewController *tempVC = [UIViewController currentTopViewController];
    if (!homeVC || !tempVC) return NO;
    NSArray *homeVcArr = homeVC.childViewControllers;
    if (homeVcArr.count > 0) {
        if (![homeVcArr containsObject:tempVC]) return NO;
    } else {
        if (![homeVC isEqual:tempVC]) return NO;
    }
    return YES;
}


/**
 APP配置
 */
- (void)appConfig {
    // 注册大数据统计SDK, AppKey暂时传空
    [GGAppsflyerAnalytics registerBigDataWithAppKey:@""];
    [GGAppsflyerAnalytics registerBigDataWithUserId:[NSStringUtils isEmptyString:USERID] ? @"0" : USERID];
    
    // 配置BrainKeeper
    [self configBrainKeeper];
}

/**
 * 记录首次安装App时的时间,在后面下单时统计时用到
 */
- (void)recordFirstEnterAppTime {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kIsFirstLaunching]) {
        NSString *currTimeStr = [NSStringUtils getCurrentTimestamp];// 当前时间截
        NSInteger currTime = [currTimeStr integerValue];
        [[NSUserDefaults standardUserDefaults] setInteger:currTime forKey:kAPPInstallTime];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsFirstLaunching];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

/**
 * 捕获全局崩溃, 防止主页数据有脏数据缓存导致启动App崩溃, 需要清除所有接口的缓存数据
 * 如果某一个时段内崩溃次数较多, 需要清掉有的NSUserDefaults数据
 */
void UncaughtExceptionHandler(NSException *exception) {
    @try {
        YWLog(@"Google Analytics cathed exception:%@", exception.description);
        // ShowAlertSingleBtnView(@"处理全局崩溃", exception.description, @"确定");
    }
    @catch (NSException *exception) {
        // 清除所有的YYCache缓存
        [ZFCommonRequestManager cleanAppNetWorkCahceData];
    }
}

/**
 * 启动设置常规, 清理缓存
 */
- (void)setupRuleAndCleanAppCache:(NSDictionary *)launchOptions
{
    [[ZFAnalyticsTimeManager sharedManager] logTimeWithEventName:kStartLaunching];
    [SYNetworkConfig sharedInstance].baseURL = [YWLocalHostManager appBaseUR];
    [SYNetworkConfig sharedInstance].communityBaseURL = [YWLocalHostManager communityAppBaseURL];
    
    // 货到付款临时数据清空
    [FilterManager removeCurrency];
    
    // 预发布处理
    if ([YWLocalHostManager isPreRelease]) {
        addZZZZZCookie();
    } else {
        deleteZZZZZCookie();
    }
    
    //仅供测试时使用:测试国家ip
    addCountryIPCookie();
    
    //记录是从桌面重按图标3DTouch进入App
    UIApplicationShortcutItem *shortcutItem = [launchOptions objectForKey:UIApplicationLaunchOptionsShortcutItemKey];
    if ([shortcutItem isKindOfClass:[UIApplicationShortcutItem class]]) {
        [AccountManager sharedManager].isAppIcon3DTouchIntoApp = YES;
    } else {
        [AccountManager sharedManager].isAppIcon3DTouchIntoApp = NO;
    }
    
    // 设置服务器返回webp图片
    [YYWebImageManager sharedManager].headersFilter = ^NSDictionary<NSString *,NSString *> * _Nonnull(NSURL * _Nonnull url, NSDictionary<NSString *,NSString *> * _Nullable header) {
        NSMutableDictionary *headersDict = [NSMutableDictionary dictionaryWithDictionary:header];
        headersDict[@"X-IM-Format"] = @"chrome"; // chrome or safari
        return headersDict;
    };
}

/**
 * 判断iOS9以上系统点击桌面3DTouch快捷按钮打开进入App
 */
- (BOOL)judgeLaunchFrom3DTouchiCon:(NSDictionary *)launchOptions {
    if (!IOS9UP) return YES;
    [ZF3DTouchManager register3DTouchShortcut];
    
    UIApplicationShortcutItem *shortcutItem = [launchOptions objectForKey:UIApplicationLaunchOptionsShortcutItemKey];    
    if ([shortcutItem isKindOfClass:[UIApplicationShortcutItem class]]) {
        [ZF3DTouchManager dealWith3DTouchPushVC:shortcutItem];
        return NO;//return NO的话开启不再执行响应快捷按钮的函数
    }
    return YES;
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    //处理3DTouch页面跳转
    if (shortcutItem) {
        [ZF3DTouchManager dealWith3DTouchPushVC:shortcutItem];
    }
}

#pragma mark -===========UIApplication系统方法===========
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    if([GGAppDelegate applicationOpenUrl:url]) {
        return YES;
    }

    return [self dealwithSchemeApplication:app openURL:url options:options];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //在层序进入前台时,重新初始化AppsFlyer, <历史代码,暂时不要改动>
    [self dealwithApplicationBecomeActive];
    //清除角标
    [self clearPushBadge:application];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAppDidBecomeActiveNotification object:nil];
    
    [GGAppDelegate applicationDidBecomeActive];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [GGAppDelegate applicationWillResignActive];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // 实现如下代码，才能使程序处于后台时被杀死，调用applicationWillTerminate:方法
//    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(){}];
}

- (void)applicationWillTerminate:(UIApplication*)application {
    YWLog(@"程序被杀死，applicationWillTerminate");
    // 统计
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_exit_app" withValues:@{@"af_content_type" : @"exit app"}];
    // 延迟主线程时间，迟延APP被杀死，执行其他异步操作
    [NSThread sleepForTimeInterval:1.5];
}

// Reports app open from a Universal Link for iOS 9
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray * __nullable restorableObjects))restorationHandler {
    [self dealwithAppsFlyerUserActivity:application
                   continueUserActivity:userActivity
                     restorationHandler:restorationHandler];
    return YES;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    YWLog(@"❌❌❌❌❌❌❌❌❌❌===接收到内存警告===❌❌❌❌❌❌❌❌❌❌");
    [[YYWebImageManager sharedManager].cache.memoryCache removeAllObjects];
    [[YYWebImageManager sharedManager].queue cancelAllOperations];
    [ZFNetworkHttpRequest cancelGlobleAllRequestMangerTask];
}


- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    
    if (self.forceOrientation) {
        if (self.forceOrientation == AppForceOrientationPortrait) {
            return UIInterfaceOrientationMaskPortrait;
            
        } else if(self.forceOrientation == AppForceOrientationLandscape) {
            return UIInterfaceOrientationMaskLandscape;
            
        } else if(self.forceOrientation == AppForceOrientationJustOnceLandscape) {
            self.forceOrientation = AppForceOrientationALL;
            return UIInterfaceOrientationMaskLandscape;
        } else if(self.forceOrientation == AppForceOrientationALL) {
            return UIInterfaceOrientationMaskAll;
        }
    }
        
    return UIInterfaceOrientationMaskPortrait;
}


@end
