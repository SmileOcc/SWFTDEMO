//
//  AppDelegate+ZFThirdLibrary.m
//  ZZZZZ
//
//  Created by YW on 2018/5/4.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "AppDelegate+ZFThirdLibrary.h"
#import "Constants.h"
#import "AppDelegate+ZFNotification.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <GoogleSignIn/GoogleSignIn.h>
//#import <Bolts/Bolts.h>
#import <Firebase/Firebase.h>
#import "PDKClient.h"
#import "GGAppsflyerAnalytics.h"

#import "VKSdk.h"


#ifdef BuglyEnabled
#   import <Bugly/Bugly.h>
#endif

#ifdef LeandCloudEnabled
#   import <AVOSCloud/AVOSCloud.h>
#endif

#ifdef AppsFlyerAnalyticsEnabled
#   import <AppsFlyerLib/AppsFlyerTracker.h>

#ifdef googleAnalyticsV3Enabled
#   import "GAI.h"
#   import "GAITracker.h"
#   import "GAIDictionaryBuilder.h"
#endif

#endif

#import "Growing.h"
#import "ZFActionSheetView.h"
#import <GGPaySDK/GGPaySDK.h>
#import "Branch/Branch.h"
#import "YWLocalHostManager.h"
#import "ZFThemeManager.h"
#import "IQKeyboardManager.h"
#import "NSStringUtils.h"
#import "NSString+Extended.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "NSDictionary+SafeAccess.h"
#import "ZFFireBaseAnalytics.h"
#import "ZFAnalytics.h"
#import "ZFAnalyticsTimeManager.h"
#import "BannerManager.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "YSAlertView.h"
#import "ZFBannerModel.h"
#import <GGBrainKeeper/BrainKeeperManager.h>
#import "AFNetworkReachabilityManager.h"
#import "ZFBKManager.h"
#import "ZFCommonRequestManager.h"

@import GlobalegrowIMSDK;
#pragma mark - occ修改：----------3.8.0 暂时去掉，不使用地图--------
//@import GoogleMaps;


@implementation NSURLRequest(DataController)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host {
    return YES;
}
@end

@interface AppDelegate ()<AppsFlyerTrackerDelegate, FIRMessagingDelegate>

@end

@implementation AppDelegate (ZFThirdLibrary)

#pragma mark -===========初始化必要第三方库===========

/**
 * 启动首先初始化崩溃检测
 */
- (void)initConfigBugly
{
#ifdef BuglyEnabled
    BuglyConfig *config = [[BuglyConfig alloc] init];
    config.reportLogLevel = BuglyLogLevelWarn;
    config.debugMode = !([YWLocalHostManager isOnlineRelease]);;
    config.blockMonitorEnable = YES;
    [Bugly startWithAppId:[YWLocalHostManager appBuglyAppId]
#ifdef DEBUG
        developmentDevice:YES
#endif
                   config:config];
#endif
}

/**
 * 启动Ap初始化各种必要的第三方库
 */
-(void)initThirdPartObjectsWithOptions:(NSDictionary *)launchOptions
                           application:(UIApplication *)application
{
    // 配置ZZZZZ全局App外观
    [self configZZZZZAppearanceUI];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 配置FireBase统计
        [self configurFireBase];
    });
    
    // 配置AppsFlyer统计
    [self configurAppsFlyer:launchOptions];
    
    // 配置GA统计
    [self configurGAI];
    
    // 配置GrowingIO统计
    [self configurGrowingIO];
    
    // 配置LeandCloud推送
    [self configurLeandCloud:launchOptions];
    
    // ------下面的SDK初始化可延迟初始化------
    
    // 配置facebook登录, google+登录, 谷歌地图, PinterestSDK
    [self configurThirdPartLoginAndGooleMap:launchOptions application:application];
    
    // 配置IQ键盘设置
    [self configurIQKeyboard];
    
    // 设置原生支付SDK配置
    [self fonfigGGPaySDK];
    
    // branch 统计
    [self configBranchWithOptions:launchOptions application:application];
    
    [VKSdk initializeWithAppId:ZF_VKApply_ID];
    [VKSdk wakeUpSession:@[VK_PER_WALL, VK_PER_PHOTOS, VK_PER_EMAIL] completeBlock:^(VKAuthorizationState state, NSError *error) {
        YWLog(@"VKSDK-----Start %lu",(unsigned long)state);
        
        if (state == VKAuthorizationAuthorized) {
            // Authorized and ready to go
            YWLog(@"VKSDK-----Authorized");
        } else if (error) {
            // Some error happened, but you may try later
            YWLog(@"VKSDK-----Start %@",error);

        }
    }];
}

/**
 配置BrainKeeper
 */
- (void)configBrainKeeper {
    // 配置请求代理
    [ZFNetworkConfigPlugin sharedInstance].delegate = [ZFBKManager sharedManager];
    
    [BrainKeeperManager sharedManager].appName = @"ZZZZZ-m-app";
    [BrainKeeperManager sharedManager].isDevelopStatus = [YWLocalHostManager isDevelopStatus];
    [BrainKeeperManager sharedManager].delegate = (id<BrainKeeperDelegate>)self;
#if DEBUG
//    [BrainKeeperManager sharedManager].isOpenBrainKeeperLog = YES;
#endif
}

- (void)configBranchWithOptions:(NSDictionary *)launchOptions
                    application:(UIApplication *)application {
    Branch *branch = [Branch getInstance];
#if DEBUG
    // 调式模式，上线前需要关闭
//    [branch setAppleSearchAdsDebugMode];
    // if you are using the TEST key
//    [Branch setUseTestBranchKey:YES];
    // for debug and development only
//    [branch setDebug];
//    [branch validateSDKIntegration]
#endif
    // 打开苹果搜索广告归因
    [branch delayInitToCheckForSearchAds];
    // 公共参数
    NSString *linkid = [NSStringUtils getLkid];
    [branch setRequestMetadataKey:@"fz_app_name" value:@"ZZZZZ"];
    [branch setRequestMetadataKey:@"fz_platform" value:@"iOS"];
    if (!ZFIsEmptyString(linkid)) {  // 注意：空的值不能上传，否规则会造成数据丢失
        [branch setRequestMetadataKey:@"fz_linkid" value:ZFToString(linkid)];
    }
    // listener for Branch Deep Link data
    [branch initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary * _Nonnull params, NSError * _Nullable error) {
        // do stuff with deep link data (nav to page, display content, etc)
        // params are the deep linked params associated with the link that the user clicked before showing up.
        if (params[@"$3p"] && params[@"$web_only"]) {
            NSURL *url = [NSURL URLWithString:params[@"$original_url"]];
            if (url) {
                [application openURL:url options:@{} completionHandler:nil]; // check to make sure your existing deep linking logic, if any, is not executed, perhaps by returning early
            }
        } else {
            // it is a deep link
            YWLog(@"%@", params);
            // 优先取branch_dp参数，没有配置再取$canonical_url做跳转处理
            NSString *url = params[@"branch_dp"];
            if (ZFIsEmptyString(url)) {
                url = params[@"$canonical_url"];
            }
            
            if (!ZFIsEmptyString(url)) {
                NSURL *urlString = [NSURL URLWithString:url];
                if (!urlString) { //防止url有空格
                    urlString = [NSURL URLWithString:ZFEscapeString(url, YES)];
                }
                [self deepLinkCallingWithURL:urlString
                                 deepLinkUrl:nil
                                deeplinkType:@"branch"
                          remoteNotification:nil];
            }
            
            // 存储其他参数，下单时带到订单
            id linkid = params[@"linkid"];
            id utm_source = params[@"utm_source"];
            id utm_campaign = params[@"utm_campaign"];
            id utm_medium = params[@"utm_medium"];
            id postback_id = params[@"postback_id"];
            id aff_mss_info = params[@"aff_mss_info"];
            if (linkid || utm_source || utm_campaign || utm_medium || postback_id || aff_mss_info) {
                NSString *curTimeStr = [NSStringUtils getCurrentTimestamp]; // 因为此参数在AF中无时间限制，但在此入口有时间限制，所以把时间传给后台，让后台区分linkid时效问题
                NSDictionary *branchParams = @{
                                               BRANCH_PARAMS_TIME : ZFToString(curTimeStr),
                                               BRANCH_LINKID : ZFToString(linkid),
                                               UTM_SOURCE : ZFToString(utm_source),
                                               UTM_CAMPAIGN : ZFToString(utm_campaign),
                                               UTM_MEDIUM : ZFToString(utm_medium),
                                               POSTBACK_ID : ZFToString(postback_id),
                                               AFF_MSS_INFO : ZFToString(aff_mss_info)
                                               };
                
                NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
                [us setObject:branchParams forKey:BRANCH_PARAMS];
                [us removeObjectForKey:APPFLYER_PARAMS];
                [us synchronize];
            }
            
            // 统计
            BOOL isFirstInstall = [params[@"+is_first_session"] boolValue];
            if (isFirstInstall && [params isKindOfClass:[NSDictionary class]]) {
                [ZFAnalytics appsFlyerTrackEvent:@"af_branch_information" withValues:params];
            }
        }
        
    }];
}

/**
 * YSAlertView配置全局App弹框外观
 */
- (void)configZZZZZAppearanceUI {
    UIColor *fontColor = [UIColor colorWithHex:0x2D2D2D];
    UIFont *font = [UIFont systemFontOfSize:14.0];
    NSMutableDictionary *alertAtttrDic = [NSMutableDictionary dictionary];
    alertAtttrDic[NSFontAttributeName] = font;
    alertAtttrDic[NSForegroundColorAttributeName] = fontColor;
    // 全局配置中间弹框样式
    [[YSAlertView appearance] setTitleTextAttributes:alertAtttrDic];
    [[YSAlertView appearance] setMessageTextAttributes:alertAtttrDic];
    [[YSAlertView appearance] setOtherBtnTitleAttributes:alertAtttrDic];
    
    NSDictionary *alertMainAtttrDic = @{
        NSForegroundColorAttributeName:ZFC0xFE5269(),
        NSFontAttributeName:ZFFontBoldSize(14)
    };
    [[YSAlertView appearance] setThemeColorBtnTitleAttributes:alertMainAtttrDic];
    
    // 全局配置底部弹框样式
    UIColor *actionSheetColor = ZFCOLOR(45, 45, 45, 1);
    UIFont *actionSheetFont = [UIFont systemFontOfSize:18.0];
    NSMutableDictionary *actionSheetAtttrDic = [NSMutableDictionary dictionary];
    actionSheetAtttrDic[NSFontAttributeName] = actionSheetFont;
    actionSheetAtttrDic[NSForegroundColorAttributeName] = actionSheetColor;
    //[[ZFActionSheetView appearance] setTitleTextAttributes:actionSheetAtttrDic];
    [[ZFActionSheetView appearance] setOtherBtnTitleAttributes:actionSheetAtttrDic];
    
    NSDictionary *actionSheetMainAtttrDic = @{
        NSForegroundColorAttributeName:ZFC0xFE5269(),
        NSFontAttributeName:ZFFontBoldSize(18)
    };
    [[ZFActionSheetView appearance] setThemeColorBtnTitleAttributes:actionSheetMainAtttrDic];
    
    //配置全局输入框光标颜色
    UIColor *cursorColor = [UIColor colorWithHex:0x000000];
    [[UITextField appearance] setTintColor:cursorColor];
    [[UITextView appearance] setTintColor:cursorColor];
    
    //全局禁止视图多指点击
    [[UIView appearance] setExclusiveTouch:YES];
    
    //全局表格分割线设置统一颜色值
    [UITableView appearance].separatorColor = ZFC0xDDDDDD();
}

/**
 * 设置原生支付SDK配置
 */
- (void)fonfigGGPaySDK {
//    [GGPaySDKConfiguration shareConfiguration].baseLocalizeable = [[ZFLocalizationString shareLocalizable] currentLanguageMR];
    [GGPaySDKConfiguration shareConfiguration].paymentResult = @"soa_pay/payok";//@"soa_pay/result";
    [GGPaySDKConfiguration shareConfiguration].siteName = @"ZZZZZ";
    [GGUncaughtExceptionHandler installUncaughtExceptionHandler];
}

/**
 * 配置FireBase统计
 */
- (void)configurFireBase {
//#if DEBUG
//    YWLog(@"❌❌❌: 经测试发现初始化FireBase第三方库会在启动时卡住全局断点, 因此在 DEBUG 环境下暂不初始化FireBase库");
//    return;
//#else
//#endif
    NSString *fileName = [YWLocalHostManager fireBaseAppKey];
    NSString *googleServicePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    FIROptions *firOptions = [[FIROptions alloc] initWithContentsOfFile:googleServicePath];
    [FIRApp configureWithOptions:firOptions];
    [FIRMessaging messaging].delegate = (id<FIRMessagingDelegate>)self;
}

#pragma mark - BrainKeeperDelegate
- (NSString *)brainKeeperUserId {
    return [NSStringUtils isEmptyString:USERID] ? @"0" : USERID;
}

- (NSString *)brainKeeperRegionCode {
    return [AccountManager sharedManager].accountCountryModel.region_code;
}

#pragma mark - FCMMessagingDelegate
- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    YWLog(@"FCM registration token: %@", fcmToken);
    // TODO: If necessary send token to application server.
    // Note: This callback is fired at each app startup and whenever a new token is generated.
    BOOL hasShowUserNotification = [GetUserDefault(kHasShowSystemNotificationAlert) boolValue];
    // 没注册推送前，不往服务器上传设备信息
    if (hasShowUserNotification) {
        //保存FCM推送的信息
        [AccountManager uploadFCMTokenToServerToken:ZFToString(fcmToken)];
    }
    
}

- (void)messaging:(FIRMessaging *)messaging didReceiveMessage:(FIRMessagingRemoteMessage *)remoteMessage {
    YWLog(@"Received data message: %@", remoteMessage.appData);
}

/**
 *  配置AppsFlyer统计
 */
- (void)configurAppsFlyer:(NSDictionary *)launchOptions
{
#ifdef AppsFlyerAnalyticsEnabled
    [AppsFlyerTracker sharedTracker].appsFlyerDevKey = [YWLocalHostManager appAppsFlyerKey];
    [AppsFlyerTracker sharedTracker].appleAppID = kZZZZZAppId;
    [AppsFlyerTracker sharedTracker].delegate = self;
    [AppsFlyerTracker sharedTracker].customerUserID = [NSStringUtils isEmptyString:USERID] ? @"0" : USERID;
    //注册大数据统计用户id
    [GGAppsflyerAnalytics registerBigDataWithUserId:[NSStringUtils isEmptyString:USERID] ? @"0" : USERID];
    
    //线上发布时一定不能显示开关
    [AppsFlyerTracker sharedTracker].isDebug = !([YWLocalHostManager isOnlineRelease]);
    //[[AppsFlyerTracker sharedTracker] trackAppLaunch];
    //#ifdef DEBUG
    //[AppsFlyerTracker sharedTracker].useUninstallSandbox = NO;
    //#endif
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 保存到数据共享组
        NSUserDefaults *myDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.ZZZZZ.ZZZZZ"];
        [myDefaults setObject:ZFToString([AppsFlyerTracker sharedTracker].getAppsFlyerUID) forKey:@"appsFlyerid"];
        [myDefaults synchronize];
    });
    
    // BrainKeeper配置
    [BrainKeeperManager sharedManager].deviceId = [AppsFlyerTracker sharedTracker].getAppsFlyerUID;
#endif
    
}

/**
 * 配置GA统计
 */
- (void)configurGAI {
#ifdef googleAnalyticsV3Enabled
    //UA-87302294-3
    NSString *trackingId = kTrackingId;
    [[GAI sharedInstance] trackerWithTrackingId:trackingId];
    if (![YWLocalHostManager isOnlineRelease]) {
        [GAI sharedInstance].trackUncaughtExceptions = YES;
    } else{
        [GAI sharedInstance].trackUncaughtExceptions = NO;
    }
    [GAI sharedInstance].dispatchInterval = 5;
    [[GAI sharedInstance] setDryRun:NO];
#if DEBUG
//    [GAI sharedInstance].logger = self;
#endif
    // 谷歌统计
    [ZFAnalytics screenViewQuantityWithScreenName:@"Launch"];
    [[ZFAnalyticsTimeManager sharedManager] logTimeWithEventName:kFinishLaunching];
#endif
}

/**
 * 配置GrowingIO统计
 */
- (void)configurGrowingIO {
    // 启动GrowingIO
    [Growing startWithAccountId:kGrowingIOAppId];
    
    // 可以开启Growing调试日志 (可选)
//#ifdef DEBUG
//    [Growing setEnableLog:YES];
//#endif
    
    // 不采集任何关于 UIWebView / WKWebView 的统计信息
    [Growing enableAllWebViews:NO];
    [Growing enableHybridHashTag:NO];
    //YWLog(@"Growing sdkVersion===%@",[Growing sdkVersion]);

    //初始化时传一个语言标识
    NSString *lang = [ZFLocalizationString shareLocalizable].nomarLocalizable;
    [Growing setPeopleVariableWithKey:@"language" andStringValue:ZFToString(lang)];
    //上传国家站信息
    [Growing setPeopleVariableWithKey:@"national_code" andStringValue:ZFToString(GetUserDefault(kLocationInfoPipeline))];
    [Growing setVisitor:@{@"appLanguage" : ZFToString(lang),
                          @"national_code" : ZFToString(GetUserDefault(kLocationInfoPipeline))
    }];
}

/**
 * 配置LeandCloud推送
 */
- (void)configurLeandCloud:(NSDictionary *)launchOptions {
#ifdef LeandCloudEnabled
    NSString *appLeanCloudApplicationID = [YWLocalHostManager appLeanCloudApplicationID];
    NSString *appLeanCloudClientKey = [YWLocalHostManager appLeanCloudClientKey];
    
    // 设置美国节点
    [AVOSCloud setServiceRegion:AVServiceRegionUS];
    [AVOSCloud setApplicationId:appLeanCloudApplicationID clientKey:appLeanCloudClientKey];
    [AVAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    YWLog(@"%@----------------------%@",appLeanCloudApplicationID,appLeanCloudClientKey);
#endif
}

/**
 * 配置facebook登录, google+登录, 谷歌地图
 */
- (void)configurThirdPartLoginAndGooleMap:(NSDictionary *)launchOptions application:(UIApplication *)application
{
    // facebook 登录
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    if (launchOptions[UIApplicationLaunchOptionsURLKey] == nil) {
        [FBSDKAppLinkUtility fetchDeferredAppLink:^(NSURL *url, NSError *error) {
            if (error) {
                YWLog(@"Received error while fetching deferred app link %@", error);
            }
            if (url) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                if ([url.scheme.lowercaseString isEqualToString:kZZZZZScheme]) {
                    [self deepLinkCallingWithURL:url
                                     deepLinkUrl:nil
                                    deeplinkType:@"facebook"
                              remoteNotification:nil];
                }
            }
        }];
    }
    
    // google+登录支持
    [GIDSignIn sharedInstance].clientID = kGoogleLoginKey;
    
    // Pinsterest
    [PDKClient configureSharedInstanceWithAppId:kPinterestSDKAppId];
    
#pragma mark - occ修改：----------3.8.0 暂时去掉，不使用地图--------
    // 谷歌地图
    //[GMSServices provideAPIKey:kGoogleMapKey];
}

/**
 * 配置IQ键盘设置
 */
- (void)configurIQKeyboard
{
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    [IQKeyboardManager sharedManager].shouldToolbarUsesTextFieldTintColor = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    [IQKeyboardManager sharedManager].toolbarDoneBarButtonItemText = ZFLocalizedString(@"GoodsPage_VC_Done", nil);
}

#pragma mark -===========UIApplication系统方法===========

/**
 * 处理openURL打开应用跳转
 */
- (BOOL)dealwithSchemeApplication:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    [[Branch getInstance] application:app openURL:url options:options];
    
    NSString *absoluteUrl = [url absoluteString];
    BOOL handled = YES;
    
    if ([url.scheme.lowercaseString isEqualToString:kFacebookSchemeKey]) {
        handled = [[FBSDKApplicationDelegate sharedInstance] application:app openURL:url options:options];
        
    } else if ([absoluteUrl containsString:kPinterestSDKAppId]) { //pinsterest分享
        handled = [[PDKClient sharedInstance] handleCallbackURL:url];
        
    } else if ([url.scheme.lowercaseString isEqualToString:kZZZZZScheme]) {
        handled = [self deepLinkCallingWithURL:url
                                   deepLinkUrl:nil
                                  deeplinkType:@"deeplink"
                            remoteNotification:nil];
        
    } else if ([Growing handleUrl:url]) { // GrowingIO 统计SDK
        handled = YES;
        
    } else {
        handled = [[GIDSignIn sharedInstance] handleURL:url];
//        handled =  [[GIDSignIn sharedInstance] handleURL:url
//                                       sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
//                                              annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    }
    [[AppsFlyerTracker sharedTracker] handleOpenUrl:url options:options];
    
    [VKSdk processOpenURL:url fromApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]];
    
    return handled;
}

/**
 * Reports app open from a Universal Link for iOS 9
 */
- (void)dealwithAppsFlyerUserActivity:(UIApplication *)application
                 continueUserActivity:(NSUserActivity *)userActivity
                   restorationHandler:(void(^)(NSArray * __nullable restorableObjects))restorationHandler
{
    [[Branch getInstance] continueUserActivity:userActivity];
    
    [[AppsFlyerTracker sharedTracker] continueUserActivity:userActivity restorationHandler:restorationHandler];
    
    /* 处理 Universal Links, Onelink跳转, app_dl, af_dp的值必须先encodel编码
     * Universal: https://m.ZZZZZ.com?app_dl=ZZZZZ%3a%2f%2faction%3factiontype%3d2%26url%3d66%26name%3dwoment%26source%3ddeeplink
     * https://m.ZZZZZ.com?app_dl=ZZZZZ://action?actiontype=2&url=66&name=woment&source=deeplink
     */
    NSURL *url = userActivity.webpageURL;
    NSMutableDictionary *params = [BannerManager parseDeeplinkParamDicWithURL:url];
    NSString *deeplink = nil;
    
    if ([url.host.lowercaseString isEqualToString:@"m.ZZZZZ.com"] ||
        [url.host.lowercaseString isEqualToString:@"www.ZZZZZ.com"]) {
        NSString *app_dl_url = params[@"app_dl"];
        if (!ZFIsEmptyString(app_dl_url)) {
            deeplink = [app_dl_url stringByRemovingPercentEncoding];;
        }
    }
    
    if (!deeplink) return;
    ZFBannerModel *bannerModel = [[ZFBannerModel alloc] init];
    bannerModel.deeplink_uri = ZFToString(deeplink);
    
    UIViewController *homeVC = [UIViewController currentTopViewController];
    if (homeVC && bannerModel) {
        [BannerManager doBannerActionTarget:homeVC withBannerModel:bannerModel];
    }
}

/**
 * 在层序进入前台时,重新初始化AppsFlyer
 */
- (void)dealwithApplicationBecomeActive
{
#ifdef AppsFlyerAnalyticsEnabled
    //AppsFlyer 统计
    [AppsFlyerTracker sharedTracker].customerUserID = [NSStringUtils isEmptyString:USERID] ? @"0" : USERID;
    [[AppsFlyerTracker sharedTracker] trackAppLaunch];
    //注册大数据统计用户id
    [GGAppsflyerAnalytics registerBigDataWithUserId:[NSStringUtils isEmptyString:USERID] ? @"0" : USERID];
    //#ifdef DEBUG
    //    [AppsFlyerTracker sharedTracker].isDebug = YES;
    //    [AppsFlyerTracker sharedTracker].useUninstallSandbox = NO;
    //#endif
#endif
    
    [FBSDKAppEvents activateApp];
    [ZFFireBaseAnalytics appOpen];
}

#pragma mark -===========AppsFlyerTrackerDelegate===========
/**
 * 点击OneLink广告带入的安装走的回调
 */
-(void)onConversionDataReceived:(NSDictionary*)installData
{
    // AppsFlyer推广数据回调
    id status = [installData objectForKey:@"af_status"];
    BOOL isFirstLaunch = [installData ds_boolForKey:@"is_first_launch"];
    if([status isEqualToString:@"Non-organic"]
       && isFirstLaunch) {
        NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
        
        if (installData) {
            [us setObject:installData forKey:APPFLYER_ALL_PARAMS];
        }
        
        id sourceID = [installData objectForKey:@"media_source"];// 推广来源
        id campaign = [installData objectForKey:@"campaign"];// 营销数据
        id lkid = [installData objectForKey:@"af_sub1"];// lkid
        if (sourceID || campaign || lkid) {
            NSDictionary *afParams = @{
                                       LKID  : ZFToString(lkid),
                                       MEDIA_SOURCE : ZFToString(sourceID),
                                       CAMPAIGN     : ZFToString(campaign)
                                       };
            [us setObject:afParams forKey:APPFLYER_PARAMS];
            [us removeObjectForKey:BRANCH_PARAMS];
        }
        
        id adId = [installData objectForKey:@"ad_id"];
        if (adId) {
            [us setObject:adId forKey:ADID];
        }
        //v4.1.0 新增af字段
        id af_adgroup_name = [installData objectForKey:AFADGroup];
        if (ZFToString(af_adgroup_name).length) {
            [us setObject:af_adgroup_name forKey:AFADGroup];
        }
        
        NSString *urlStr = [installData objectForKey:@"af_dp"];// DeepLink跳转数据
        urlStr = [ZFToString(urlStr) stringByRemovingPercentEncoding];
        if (ZFToString(urlStr).length) {
            [us setObject:urlStr forKey:@"af_dp"];
        }
        [us synchronize];
        
        //上传广告信息到Appflyer,其他值都传空
        NSDictionary *params = @{@"af_content_type" : @"cold start info",
                                 @"af_extra_info" : @{
                                                        @"adgroup":ZFToString(af_adgroup_name),
                                                        @"af_deeplink" : ZFToString(urlStr)
                                                    },
                                 };
        dispatch_async(dispatch_get_main_queue(), ^{
            /**
             * 在启动时报[self gainBtsModelList]子线程操作UI错误
             *  modify at: V4.7.0, by: mwx
             */
            [ZFAnalytics appsFlyerTrackEvent:@"af_cold_start_info" withValues:params];
        });
        [[NSNotificationCenter defaultCenter] postNotificationName:kAdGroupGoodsKey object:nil];
        
        if (![NSStringUtils isEmptyString:urlStr]) {
            NSURL *url = [NSURL URLWithString:urlStr];
            id deepLink = [installData objectForKey:@"url"];// DeepLink跳转参数
            deepLink = [ZFToString(deepLink) stringByRemovingPercentEncoding];
            
            [self deepLinkCallingWithURL:url
                             deepLinkUrl:deepLink
                            deeplinkType:@"appsflyer"
                      remoteNotification:nil];
            
            /** V4.5.1需求: 通过点击短信内容的OneLink进来时
             *  执行Deeplink里面有source=notifications,pid和c参数就不需要弹"Open"框, 但是需要统计点击量
             */
            NSMutableDictionary *urlParamDic = [BannerManager parseDeeplinkParamDicWithURL:url];
            NSString *source = urlParamDic[@"source"];
            NSString *pid = urlParamDic[@"pid"];
            NSString *cString = urlParamDic[@"c"];
            NSString *pushId    = urlParamDic[@"push_id"];
            
            if ([ZFToString(source) isEqualToString:@"notifications"] &&
                !ZFIsEmptyString(pid) && !ZFIsEmptyString(cString)) {
                // 同步点击远程推送的信息给服务端
                [ZFCommonRequestManager syncClickRemotePushWithPid:ZFToString(pid) cString:ZFToString(cString) pushId:ZFToString(pushId)];
                
                NSMutableDictionary *notifyInfo = [NSMutableDictionary dictionaryWithDictionary:urlParamDic];
                notifyInfo[@"pid"] = ZFToString(pid);
                notifyInfo[@"c"] = ZFToString(cString);
                //保存推送通知参数, 在下单时用到
                NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                [userDefault setObject:notifyInfo forKey:NOTIFICATIONS_PAYMENT_PARMATERS];// 推送摧付参数=
                [userDefault setInteger:[[NSStringUtils getCurrentTimestamp] integerValue] forKey:SAVE_NOTIFICATIONS_PARMATERS_TIME];// 推送时间
                [userDefault synchronize];
            }
        }
        YWLog(@"This is a none organic install. installData: %@, %@",installData, [NSThread currentThread]);
        
    } else if([status isEqualToString:@"Organic"]) {
        YWLog(@"This is an organic install. == %@", [NSThread currentThread]);
    }
}

-(void)onConversionDataRequestFailure:(NSError *) error {
    YWLog(@"%@",error);
}

/**
 * OneLink 延迟深度链接回调
 */
- (void)onAppOpenAttribution:(NSDictionary*)attributionData {
    NSString *link = [attributionData ds_stringForKey:@"link"];
    if (!link || [link length] == 0) return;
    
    NSMutableDictionary *deepLinkTypeDic = [[NSMutableDictionary alloc] init];
    NSArray *rootArr = [link componentsSeparatedByString:@"?"];
    NSString *sourceID = @"";
    NSString *campaign = @"";
    NSString *sub1 = @"";
    if (rootArr.count < 2) {
        // 运营配置的短链接: https://ZZZZZ.onelink.me/737960948/f53ebe8c
        sourceID = ZFToString([attributionData objectForKey:@"pid"]);
        campaign = ZFToString([attributionData objectForKey:@"c"]);
        sub1 = ZFToString([attributionData objectForKey:@"af_sub1"]);
        NSString *af_dp = attributionData[@"af_dp"];
        if (!ZFIsEmptyString(af_dp)) {
            deepLinkTypeDic = [NSMutableDictionary dictionaryWithDictionary:attributionData];
        }
    } else {
        // 运营配置的长链接: https://ZZZZZ.onelink.me/737960948?pid=test1026&is_retargeting=true&af_dp=ZZZZZ%3A%2F%2Faction%3Factiontype%3D15%26url%3D161
        NSArray *arr = [rootArr[1] componentsSeparatedByString:@"&"];
        for (NSString *str in arr) {
            if ([str rangeOfString:@"="].location != NSNotFound) {
                NSString *key = [str componentsSeparatedByString:@"="][0];
                NSString *value = [str componentsSeparatedByString:@"="][1];
                [deepLinkTypeDic setObject:value forKey:key];
            }
        }
        sourceID = ZFToString(deepLinkTypeDic[@"pid"]);
        campaign = ZFToString(deepLinkTypeDic[@"c"]);
        sub1     = ZFToString(deepLinkTypeDic[@"af_sub1"]);
    }
    
    if (![NSStringUtils isEmptyString:sub1] || ![NSStringUtils isEmptyString:sourceID] || ![NSStringUtils isEmptyString:campaign]) {
        NSDictionary *afParams = @{
                                   LKID  : ZFToString(sub1),
                                   MEDIA_SOURCE : ZFToString(sourceID),
                                   CAMPAIGN     : ZFToString(campaign)
                                   };
        NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
        [us setObject:afParams forKey:APPFLYER_PARAMS];
        [us removeObjectForKey:BRANCH_PARAMS];
        [us synchronize];
    }
    
    NSString *stringUrl = [deepLinkTypeDic ds_stringForKey:@"af_dp"];
    stringUrl  = [stringUrl decodeFromPercentEscapeString:stringUrl];
    NSURL *url = [NSURL URLWithString:stringUrl];
    if ([url.scheme.lowercaseString isEqualToString:kZZZZZScheme]) {
        [self deepLinkCallingWithURL:url
                         deepLinkUrl:nil
                        deeplinkType:@"appsflyer"
                  remoteNotification:nil];
        
    } else { // 处理Onelink跳转
        ///Onelink: https://ZZZZZ.onelink.me/737960948?pid=APP_Share&c=ThematicTemplate&af_dp=ZZZZZ%253A%252F%252Faction%253Factiontype%253D15%2526url%253D202&is_retargeting=true&utm_source=appshare&utm_medium=copylink&utm_campaign=share
        
        NSURL *onelinkURL = [NSURL URLWithString:link];
        NSMutableDictionary *params = [BannerManager parseDeeplinkParamDicWithURL:onelinkURL];
        NSString *deeplink = nil;
        
        if ([onelinkURL.host.lowercaseString isEqualToString:@"ZZZZZ.onelink.me"]) {
            NSString *af_dp_url = params[@"af_dp"];
            if (!ZFIsEmptyString(af_dp_url)) {
                deeplink = [af_dp_url stringByRemovingPercentEncoding];
                
                /** V4.5.1需求: 通过点击短信内容的OneLink进来时
                 *  执行Deeplink里面有source=notifications,pid和c参数就不需要弹"Open"框, 但是需要统计点击量
                 */
                NSDictionary *deeplinkDict = [BannerManager parseDeeplinkParamDicWithURL:[NSURL URLWithString:ZFToString(deeplink)]];
                NSString *source = deeplinkDict[@"source"];
                NSString *pid = deeplinkDict[@"pid"];
                NSString *cString = deeplinkDict[@"c"];
                NSString *pushId    = deeplinkDict[@"push_id"];
                
                if ([ZFToString(source) isEqualToString:@"notifications"] &&
                    !ZFIsEmptyString(pid) && !ZFIsEmptyString(cString)) {
                    // 同步点击远程推送的信息给服务端
                    [ZFCommonRequestManager syncClickRemotePushWithPid:ZFToString(pid) cString:ZFToString(cString) pushId:ZFToString(pushId)];
                    
                    NSMutableDictionary *notifyInfo = [NSMutableDictionary dictionaryWithDictionary:deeplinkDict];
                    notifyInfo[@"pid"] = ZFToString(pid);
                    notifyInfo[@"c"] = ZFToString(cString);
                    //保存推送通知参数, 在下单时用到
                    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                    [userDefault setObject:notifyInfo forKey:NOTIFICATIONS_PAYMENT_PARMATERS];// 推送摧付参数=
                    [userDefault setInteger:[[NSStringUtils getCurrentTimestamp] integerValue] forKey:SAVE_NOTIFICATIONS_PARMATERS_TIME];// 推送时间
                    [userDefault synchronize];
                }
            }
        }        
        if (!deeplink) return;
        ZFBannerModel *bannerModel = [[ZFBannerModel alloc] init];
        bannerModel.deeplink_uri = ZFToString(deeplink);
        
        UIViewController *homeVC = [UIViewController currentTopViewController];
        if (homeVC && bannerModel) {
            [BannerManager doBannerActionTarget:homeVC withBannerModel:bannerModel];
        }
    }
}

@end
