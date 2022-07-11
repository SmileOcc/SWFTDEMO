//
//  AppDelegate.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>

#import "AppDelegate.h"
#import "AppDelegate+STLNotification.h"
#import "AppDelegate+STLThirdLibrary.h"
#import "AppDelegate+STLCategory.h"

#import "OSSVCommonnRequestsManager.h"

#import "RealReachability.h"
#import "ExchangeApi.h"
#import "RateModel.h"
#import "CountryApi.h"
#import "AdvertApi.h"
#import "CountryListModel.h"
#import "CountryModel.h"
#import "OSSVAccountsManager.h"
#import "OSSVAdvsEventsModel.h"
#import "OSSWMHomeVC.h"
#import "OSSVItuneAppAip.h"
#import "OSSVCountrysCheckAip.h"

#import "OSSVLanuchsAdvView.h"
#import "STLAlertControllerView.h"

#import "STLPushManager.h"

//#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Bolts/Bolts.h>

#import "SSKeychain.h"
#import <AuthenticationServices/AuthenticationServices.h>


#import "GuideView.h" // 引导页


#import "STLTabbarManager.h"

// 引入神策分析 SDK
#import <SensorsAnalyticsSDK/SensorsAnalyticsSDK.h>

#if DEBUG
#import "JPFPSStatus.h"
#endif

#import "Adorawe-Swift.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

- (UIWindow *)window {
    if (!_window) {
        _window =[[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _window.backgroundColor = [UIColor whiteColor];
        [_window makeKeyAndVisible];
    }
    return _window;
}

/// - 这个方法允许你在显示app给用户之前执行最后的初始化操作
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
      //新增一个属性，控制使用优惠券顶部文案的显示与否  0：不显示  1：显示
    STLUserDefaultsSet(kAppShowCouponHeadTitle, @"1");

    
    // 启动App配置所有必要的第三方库
    [self initThirdPartObjectsWithOptions:launchOptions application:application];
    //网络状态改变通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChange:) name:kRealReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(homeBannerRefresh:) name:kNotif_Login object:nil];
    
    //谷歌地图和定位初始化
    [GMSServices provideAPIKey:[OSSVLocaslHosstManager googleSearchAddressApiKey]];
    [GMSPlacesClient provideAPIKey:[OSSVLocaslHosstManager googleSearchAddressApiKey]];

    
    //开始监听网络
    [GLobalRealReachability startNotifier];
    
    [YYWebImageManager sharedManager].cache.decodeForDisplay = NO;
    [YYWebImageManager sharedManager].cache.memoryCache.costLimit = 1024 * 1024 * 100;
    [YYWebImageManager sharedManager].cache.memoryCache.countLimit = 50;
    
    //切换语言后切换系统UI布局方式
    [UIViewController convertAppUILayoutDirection];
    
    STLLog(@"=============didFinishLaunchingWithOptions 0: %@",launchOptions);
    [OSSVAccountsManager testLaunchMessage:@"FinishLaunching0 ---"];
    
    // 启动配置
    [self launchingSetting:launchOptions];
    
    [self onlineAddressInfo:^{
        
        [OSSVAccountsManager testLaunchMessage:@"FinishLaunching1 ---"];

        // 启动配置
        [self launchingSetting:launchOptions];
        
        
        STLLog(@"=============didFinishLaunchingWithOptions 1: %@",launchOptions);

        [OSSVAccountsManager testLaunchMessage:@"FinishLaunching1.1 ---"];

        [self judgeInitAppTabbar];

        //预加载信息(获取国家列表，汇率，热更新等)
        [OSSVCommonnRequestsManager requestNecessaryData];
        
//        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//        [appDelegate initAppRootVC];
        
        [OSSVAccountsManager testLaunchMessage:@"FinishLaunching1.2 ---"];


        // 处理推送通知所有相关
        [self dealWithNotification:application launchingOptions:launchOptions];
        
        [OSSVAccountsManager testLaunchMessage:@"FinishLaunching1.3 ---"];

//        ///app版本首次（注册推送）+ 广告处理
//        [AppDelegate appVersionAdvertRegisterNotificationBlock:^{
//            //消息推送
//            [AppDelegate stlRegisterRemoteNotification:^(NSInteger openFlag) {
//
//            }];
//        }];
        
        
#if DEBUG
    [[JPFPSStatus sharedInstance] open];
#endif
    }];
    
    [OSSVAccountsManager testLaunchMessage:@"FinishLaunching2 ---"];

    STLLog(@"=============didFinishLaunchingWithOptions 2: %@",launchOptions);
    
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    [IQKeyboardManager sharedManager].toolbarDoneBarButtonItemText = STLLocalizedString_(@"done", nil);
    


    if (@available(iOS 13.0, *)) {
        [AppDelegate checkAuthorizationStateCompleteHandler:nil];
    }
    
    [OSSVAnalyticsTool appsFlyerTrackEvent:@"app_open" withValues:nil];
    
    [DotApi appStart];
    
     return YES;
}

/**
 * 判断显示App窗口根控制器
 */
- (void)judgeInitAppTabbar {
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate initAppRootVC];
    
    //启动App判断是否需要显示倒计时广告
    
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"kAdvertApiData"];
    if (STLJudgeNSDictionary(dict)) {
        OSSVAdvsEventsModel *advEventModel = [OSSVAdvsEventsModel yy_modelWithJSON:dict[kResult][@"advertInfo"]];
        [OSSVAdvsEventsManager sharedManager].advEventModel = advEventModel;
//        [OSSVAdvsViewsManager sharedManager].isLaunchAdv = YES;
    }
    OSSVAdvsEventsModel *advEventModel = [OSSVAdvsEventsManager sharedManager].advEventModel;
    
    
    if (advEventModel && [advEventModel.imageURL length] != 0) { //显示启动倒计时广告
        [OSSVAdvsViewsManager sharedManager].isLaunchAdv = YES;
        [AppDelegate showLaunchAdvertView:advEventModel imageData:nil completeHandler:^{
            [self enterAppCheckPushStatus:YES];
        }];
    } else {//没有倒计时广告就走App版本更新，弹出推送窗
        [self enterAppCheckPushStatus:YES];
    }
    
}

/**
 * 每次进入App时，判断是否显示打开推送页面
 */
- (void)enterAppCheckPushStatus:(BOOL)show {
    [STLPushManager isRegisterRemoteNotification:^(BOOL isRegister) {
        
        if (!isRegister && [STLPushManager isPopPushViewWhenAppLanuch]) {
            
            //消息推送
            [AppDelegate stlRegisterRemoteNotification:^(NSInteger openFlag) {
                
            }];
            
            
        } else if(!isRegister) {
            //请求推送检查接口  -----V1.3.2不再需要提示开启推送的弹窗了
            if (![STLPushManager sharedInstance].pushShowAlertHasRequest) {
                [OSSVCommonnRequestsManager checkPushTime:^(NSString *status, NSString *content, NSString *hours) {
//                    if ([STLToString(status) isEqualToString:@"1"]) {
//                        [STLPushManager showPushTipMessage:@"" message:content hours:hours];
//
//                    }
                }];
            } else if([[STLPushManager sharedInstance].pushShowAlertStatus integerValue] == 1 && [[STLPushManager sharedInstance].pushShowAlertHours floatValue] > 0){
//                [STLPushManager showPushTipMessage:@"" message:[STLPushManager sharedInstance].pushShowAlertContent hours:[STLPushManager sharedInstance].pushShowAlertHours];
            }
            
        }
        
        [AppDelegate showHomeAdv];
        STLLog(@"版本升级进来, 再检查版本升级(防止长时间未更新)");
        //[AppDelegate checkAppUpgradeCompleteShowHomeFloat:show];
    }];
}

/**
 * 检查版本更新, 完成后是否需要显示首页浮窗
 */
+ (void)checkAppUpgradeCompleteShowHomeFloat:(BOOL)show
{
//    // 推送通知打开 延迟请求处理
//    BOOL isLaunchRemoteNotif = [LocalHostManager stateLaunchOptionsRemoteOpenApp];;
//
//    CGFloat afterTime = isLaunchRemoteNotif ? [OSSVCommonnRequestsManager randomSecondsForMaxMillisecond:1000] + 3 : [OSSVCommonnRequestsManager randomSecondsForMaxMillisecond:800];
//
//    // 检查更新 延迟请求处理
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(afterTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [OSSVCommonnRequestsManager checkUpgradeSTLApp:^(BOOL hasNoNewVersion) {
//            if (show) { //是否显示首页广告浮窗
//                [AppDelegate judgeShowHomeFloatView];
//            }
//        }];
//    });
}


- (void)onlineAddressInfo:(void (^)())execute {
    [OSSVCommonnRequestsManager getOnlineAddress:0 complete:^(BOOL success) {
        [self appInitData:execute];
    }];
}

- (void)appInitData:(void (^)())execute {
    
    //请求推送检查接口-----目的就是取税务字段
    [OSSVCommonnRequestsManager checkPushTime:^(NSString *status, NSString *content, NSString *hours) {
        if (execute) {
            execute();
        }
    }];
}

#pragma mark - 通知网络状态
- (void)networkStatusChange:(NSNotification *)notification {
    if (!isOpenRealReachability) return;   // 关闭网络监控
    [self networkStatusChangeHandle:(RealReachability *)notification.object];
}

#pragma mark - 通知获取首页banner数据
- (void)homeBannerRefresh:(NSNotification *)notification{
    [OSSVCommonnRequestsManager getAppCopywriting];
}

///- app将要从前台切换到后台时需要执行的操作
- (void)applicationWillResignActive:(UIApplication *)application {
    
}
///- app已经进入后台后需要执行的操作
- (void)applicationDidEnterBackground:(UIApplication *)application {
    if ([OSSVAdvsViewsManager sharedManager].lastDeeplinkModel) {
        [OSSVAdvsViewsManager sharedManager].lastDeeplinkModel = nil;
    }

}
///- app将要从后台切换到前台需要执行的操作，但app还不是active状态
- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self isOpenLocationPush];
}

/// - app已经切换到active状态后需要执行的操作
- (void)applicationDidBecomeActive:(UIApplication *)application {

    
    [self dealwithApplicationBecomeActive];
    [self clearPushBadge:application];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAppDidBecomeActiveNotification object:nil];
}

///- app将要结束时需要执行的操作
- (void)applicationWillTerminate:(UIApplication *)application {
    
}


-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    STLLog(@"------kkkkkkk openURL: %@",url.absoluteString);
    return [self stl_application:app openURL:url sourceApplication:@"" annotation:@"" options:options];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return YES;
}

//Universal Link Example
- (BOOL) application:(UIApplication*)application continueUserActivity:(NSUserActivity*)userActivity restorationHandler:(nonnull void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler
{
    [self stl_application:application continueUserActivity:userActivity restorationHandler:restorationHandler];

    return YES;
}

#pragma mark - 异常捕获

void UncaughtExceptionHandler(NSException *exception)
{
    //崩溃前清缓存,防止因为缓存数据而导致重复崩溃
    [CacheFileManager clearCache:STL_PATH_CACHE];
}



- (void)applicationDidFinishLaunchingAction {
    
    [self localDeeplinkAction];
    
    // 当前时间截
    NSString *currTimeStr = [OSSVNSStringTool getCurrentTimestamp];
    NSInteger currTime = [currTimeStr integerValue];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstLaunchingYS"]) {
        [[NSUserDefaults standardUserDefaults] setInteger:currTime forKey:@"kAPPInstallTimeYS"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstLaunchingYS"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


- (void)localDeeplinkAction {

    [OSSVAccountsManager testLaunchMessage:@"localDeeplinkAction ---"];

    
    // 执行还没执行的DeepLink
    if (_isDeepLinkEventing) {
        _isDeepLinkEventing = NO;
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSData *data = [userDefault objectForKey:DeepLinkModel];
        if (data) {
            OSSVAdvsEventsModel *OSSVAdvsEventsModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            
            [OSSVAccountsManager testLaunchMessage:[NSString stringWithFormat:@"%@ data:%@",@"localDeeplinkAction ---",OSSVAdvsEventsModel.url]];

            [self applyDeepLinkCallingWithEventModel:OSSVAdvsEventsModel];
            [userDefault removeObjectForKey:DeepLinkModel];
            [userDefault synchronize];
        }
    }
}


#pragma mark ----判断是否开启系统通知， 然后回调给webView，目的是在web上开关是否开启或者关闭
- (void)isOpenLocationPush {
    [STLPushManager isRegisterRemoteNotification:^(BOOL isRegister) {
        if (isRegister) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_openPushSuccess object:nil userInfo:@{@"value":@(1)}];
            }
    }];
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [AppDelegate handleReceiveMemoryWarning];
}
@end
