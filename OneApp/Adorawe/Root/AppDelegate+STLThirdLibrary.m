//
//  AppDelegate+STLThirdLibrary.m
// XStarlinkProject
//
//  Created by odd on 2020/7/10.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "AppDelegate+STLThirdLibrary.h"
#import "OSSVLocaslHosstManager.h"
#import "AppDelegate+STLNotification.h"
#import "FIRMessaging.h"
#import "STLPushManager.h"
#import "STLTextField.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

#ifdef AppsFlyerAnalyticsEnabled
//#import <AppsFlyerLib/AppsFlyerTracker.h>
//#import <AppsFlyerLib/AppsFlyerLib.h>

#endif

// 引入神策分析 SDK
#import <SensorsAnalyticsSDK/SensorsAnalyticsSDK.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>

//#import <Firebase/Firebase.h>

#import <Branch.h>

#import "Adorawe-Swift.h"
@import RangersAppLog;

@interface AppDelegate ()
<
//AppsFlyerLibDelegate,
FIRMessagingDelegate
>

@end

@implementation AppDelegate (STLThirdLibrary)

- (void)configurBranch:(NSDictionary *)launchOptions {
    // if you are using the TEST key
//     [Branch setUseTestBranchKey:YES];
     // listener for Branch Deep Link data
//     [[Branch getInstance] enableLogging];
    [Branch setBranchKey:OSSVLocaslHosstManager.branchKey];
    
    
    Branch *branch = [Branch getInstance];
    
    // This will usually add less than 1 second on first time startup.  Up to 3.5 seconds if Apple Search Ads fails to respond.
    [branch delayInitToCheckForSearchAds];

    // Increases the amount of time the SDK waits for Apple Search Ads to respond. The default wait has a better than 90% success rate, however waiting longer can improve the success rate. This will increase the usual delay to about 3 seconds on first time startup.  Up to about 15 seconds if Apple Search Ads fails to respond.
//    [branch useLongerWaitForAppleSearchAds];

    // Branch won't callback with Apple's test data, this is still sent to the server.
    [branch ignoreAppleSearchAdsTestData];
    [branch checkPasteboardOnInstall];
     
     [[Branch getInstance] initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary * _Nonnull params, NSError * _Nullable error) {
       // do stuff with deep link data (nav to page, display content, etc)
         NSLog(@"----branch----%@", params);
         NSString* urlStr = [params objectForKey:@"$deeplink_path"];
         urlStr = [urlStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
         NSURL *url = [NSURL URLWithString:urlStr];
         if (url) {
             [self application:nil deepLinkCallingWithURL:url sourceApplication:@"branch" params:nil];
         }
         
         NSString *branch_adv_share_uid = params[@"custom_uid"];
         NSString *branch_adv_share_sku = params[@"custom_sku"];

         NSMutableDictionary *toSaved = [NSMutableDictionary new];

         // 拉新信息
         if (branch_adv_share_uid.intValue > 0) {
             toSaved[@"share_uid"] = branch_adv_share_uid;
         }
         if (branch_adv_share_sku.length > 0) {
             toSaved[@"share_sku"] = branch_adv_share_sku;
         }
         
          NSString *url_source = params[@"url_source"];
          NSString *url_medium = params[@"url_medium"];
          NSString *url_campaign = params[@"url_campaign"];
         if (url_source.length > 0 && url_medium.length > 0 && url_campaign.length > 0) {
             NSMutableDictionary *branchUtm = [[NSMutableDictionary alloc] init];
             branchUtm[@"url_source"] = url_source;
             branchUtm[@"url_medium"] = url_medium;
             branchUtm[@"url_campaign"] = url_campaign;
             [STLPreference setObject:branchUtm.copy key:kBranchUtmSource];
             [OSSVAdvsEventsManager saveOneLinkeParams:toSaved];
         }
         
        
     }];
//    [[Branch getInstance] validateSDKIntegration];
}

- (void)configurAppsFlyer:(NSDictionary *)launchOptions {
    
    //AppsFlyer 统计
    #ifdef AppsFlyerAnalyticsEnabled
//        [AppsFlyerLib shared].appleAppID = [OSSVLocaslHosstManager appStoreId];
//        [AppsFlyerLib shared].appsFlyerDevKey = [OSSVLocaslHosstManager appsFlyerKey];
//        [AppsFlyerLib shared].delegate = self;
    
        #ifdef DEBUG
//        测试卸载,大概需要9天后
//            [AppsFlyerLib shared].useUninstallSandbox = YES;
        #endif
    
//        if(![OSSVConfigDomainsManager isDistributionOnlineRelease]) {
//            //线上发布时一定不能显示开关
//            [AppsFlyerTracker sharedTracker].isDebug = !([OSSVConfigDomainsManager isDevelopStatus]);
//        }
    
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            // 保存到数据共享组
//            NSUserDefaults *myDefaults = [[NSUserDefaults alloc] initWithSuiteName:[[STLDeviceInfoManager sharedManager] appGroupSuitName]];
//            [myDefaults setObject:STLToString([AppsFlyerLib shared].getAppsFlyerUID) forKey:@"appsFlyerid"];
//            [myDefaults synchronize];
//        });
    #endif
}

/**
 * 配置 神策
 */
- (void)configurAppsSensors:(NSDictionary *)launchOptions {
    
    // 初始化配置
    SAConfigOptions *options = [[SAConfigOptions alloc] initWithServerURL:[OSSVLocaslHosstManager sensorsServerURL] launchOptions:launchOptions];
    // 开启全埋点
    options.autoTrackEventType = SensorsAnalyticsEventTypeAppStart |
    SensorsAnalyticsEventTypeAppEnd |
    SensorsAnalyticsEventTypeAppClick |
    SensorsAnalyticsEventTypeAppViewScreen;
    // 开启 App 打通 H5
    options.enableJavaScriptBridge = YES;
    #ifdef DEBUG
    // 开启 Log
    //options.enableLog = YES;
    #endif
    
    
    /**
     * 其他配置，如开启可视化全埋点
     */
    // 初始化 SDK
    [SensorsAnalyticsSDK startWithConfigOptions:options];
    
    // 将 AppName 注册为公共属性
    [[SensorsAnalyticsSDK sharedInstance] registerSuperProperties:@{@"brand_name" : [[OSSVLocaslHosstManager appName] lowercaseString]}];
    [[SensorsAnalyticsSDK sharedInstance] registerSuperProperties:@{@"platform_type" : @"ios"}];
    [[SensorsAnalyticsSDK sharedInstance] registerSuperProperties:@{@"national" : [OSSVLocaslHosstManager appName].lowercaseString}];

    //公共属性会保存在 App 本地缓存中，
    //可以通过 - unregisterSuperProperty: 删除一个公共属性，
    //或使用 - clearSuperProperties: 删除所有已设置的事件公共属性
    
    [OSSVAnalyticsTool sensorsDynamicConfigure];
    if ([OSSVAccountsManager sharedManager].isSignIn) {
        [[SensorsAnalyticsSDK sharedInstance] login:USERID_STRING];
        
        //[[SensorsAnalyticsSDK sharedInstance] set:@{@"Age" : [NSNumber numberWithInt:18]}];
    }
}

#pragma mark -===========配置第三方登录==============
/**
 * 配置facebook登录, google+登录, 谷歌地图
 */
- (void)configurThird:(NSDictionary *)launchOptions application:(UIApplication *)application
{
    // facebook 登录
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    [FBSDKSettings setAppID:[OSSVLocaslHosstManager facebookID]];
    [FBSDKApplicationDelegate initializeSDK:nil];
    
    if (launchOptions[UIApplicationLaunchOptionsURLKey] == nil) {
        [FBSDKAppLinkUtility fetchDeferredAppLink:^(NSURL *url, NSError *error) {

            if (error) {
                STLLog(@"Received error while fetching deferred app link %@", error);
            }
            if (url) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                if ([url.scheme.lowercaseString isEqualToString:[OSSVLocaslHosstManager appScheme]]) {
                    [self application:application
               deepLinkCallingWithURL:url
                    sourceApplication:nil
                           params:nil];
                }
            }
        }];
    }
    
    STLLog(@"----- google+登录支持key: %@",[OSSVLocaslHosstManager googleLoginKey]);
    // google+登录支持
    [GIDSignIn sharedInstance].clientID = [OSSVLocaslHosstManager googleLoginKey];
}

- (void)configurFireBase {
//#if DEBUG
//    STLLog(@"❌❌❌: 经测试发现初始化FireBase第三方库会在启动时卡住全局断点, 因此在 DEBUG 环境下暂不初始化FireBase库");
//    return;
//#else
//#endif

    //神奇的地方，
    NSString *fileName = [OSSVLocaslHosstManager fireBaseAppKey];
#if APP_TYPE == 1
    if ([[OSSVConfigDomainsManager sharedInstance] thirdConfigureEnvironment]) {
        fileName = @"GoogleService-InfoAD";
    } else {
        fileName = @"GoogleService-Info-DebugAD";
    }

#elif APP_TYPE == 2
    //直接跑线上
//    if ([[OSSVConfigDomainsManager sharedInstance] thirdConfigureEnvironment]) {
        fileName = @"GoogleService-InfoSM";
//    } else {
//        fileName = @"GoogleService-info-DebugSM";
//    }
    
#elif APP_TYPE == 3
    //直接跑线上
    if ([[OSSVConfigDomainsManager sharedInstance] thirdConfigureEnvironment]) {
        fileName = @"GoogleService-InfoVIV";
    } else {//这个暂时没有
        fileName = @"GoogleService-Info-DebugVIV";
    }

#endif

    NSString *googleServicePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    if (STLIsEmptyString(googleServicePath)) {
        return;
    }
    FIROptions *firOptions = [[FIROptions alloc] initWithContentsOfFile:googleServicePath];
    [FIRApp configureWithOptions:firOptions];
    [FIRMessaging messaging].delegate = (id<FIRMessagingDelegate>)self;
    
    NSString *appInstanceID = FIRAnalytics.appInstanceID;
    [FIRAnalytics setUserPropertyString:appInstanceID forName:@"app_instance_id"];
    if ([OSSVAccountsManager sharedManager].isSignIn) {
        [OSSVAnalyticsTool analyticsGASetUserID:USERID_STRING];
    } else {
        [OSSVAnalyticsTool analyticsGASetUserID:@""];
    }
}

#pragma mark - FCMMessagingDelegate
- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    STLLog(@"FCM registration token: %@", fcmToken);
    // TODO: If necessary send token to application server.
    // Note: This callback is fired at each app startup and whenever a new token is generated.
    BOOL hasShowUserNotification = [STLUserDefaultsGet(kHadShowSystemNotificationAlert) boolValue];
        
    [OSSVAccountsManager testLaunchMessage:[NSString stringWithFormat:@"--%@%@--",@"\nFCM registration token:",fcmToken]];
    // 没注册推送前，不往服务器上传设备信息
    if (hasShowUserNotification) {
        //保存FCM推送的信息
        [OSSVAccountsManager uploadFCMTokenToServerToken:STLToString(fcmToken)];
        
    }
    
}

//- (void)messaging:(FIRMessaging *)messaging didReceiveMessage:(FIRMessagingRemoteMessage *)remoteMessage {
//    STLLog(@"Received data message: %@", remoteMessage);
//}



#pragma mark - ===========初始化必要第三方库===========

-(void)initThirdPartObjectsWithOptions:(NSDictionary *)launchOptions application:(UIApplication *)application {
    
    // 配置AppsFlyer统计
    [self configurAppsFlyer:launchOptions];
    [self configurAppsSensors:launchOptions];
    
    // 配置Branch
    [self configurBranch:launchOptions];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 配置FireBase统计
        [self configurFireBase];
        
        [self configurThird:launchOptions application:application];

    });
    
    [ABTestTools.shared setupSDKWithLaunchOptions:launchOptions];
    
//#if DEBUG
//    //内存泄漏检测白名单
//    [AppDelegate addClassNamesToWhitelist:@[NSStringFromClass(STLTextField.class),NSStringFromClass(UITextField.class)]];
//    //UI圈选调试
//    if ([STLUserDefaultsGet(kAppShowFLEXManager) boolValue]) {
//        [[FLEXManager sharedManager] showExplorer];
//    }
//    
//#endif
}

/**
 * 在层序进入前台时,重新初始化AppsFlyer
 */
- (void)dealwithApplicationBecomeActive {
    #ifdef AppsFlyerAnalyticsEnabled
        //AppsFlyer 统计
//        [AppsFlyerLib shared].customerUserID = USERID_STRING;
//        [[AppsFlyerLib shared] start];
    #endif
    
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            // iOS 14 及以上记录激活事件。
//            #error 如果您之前使用 - trackInstallation:  触发的激活事件，需要继续保持原来的调用，无需改为 - trackAppInstall: , 否则会导致激活事件数据分离。
            [[SensorsAnalyticsSDK sharedInstance] trackAppInstallWithProperties:@{@"DownloadChannel": @"AppStore"}];
        }];
    } else {
        // iOS 13 及以下记录激活事件
//        #error 激活接口请与上面接口保持一致
        [[SensorsAnalyticsSDK sharedInstance] trackAppInstallWithProperties:@{@"DownloadChannel": @"AppStore"}];
    }
}

+ (void)appsFlyerTracekerCustomerUserID {
    #ifdef AppsFlyerAnalyticsEnabled
        //AppsFlyer 统计
//        [AppsFlyerLib shared].customerUserID = USERID_STRING;
    #endif
}


#pragma mark -===========UIApplication系统方法===========

/**
 * 处理openURL打开应用跳转
 */

- (BOOL)stl_application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    [OSSVAccountsManager testLaunchMessage:[NSString stringWithFormat:@"--%@%@--",@"applicationOpenURL:",url.absoluteString]];
    
    BOOL handled = YES;
    if ([url.scheme.lowercaseString isEqualToString:[OSSVLocaslHosstManager facebookSchemeKey]]) {
        handled = [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url options:options];
        
    } else if ([url.scheme.lowercaseString isEqualToString:@""]) {
        handled = [[GIDSignIn sharedInstance] handleURL:url];
        
    } else if ([url.scheme.lowercaseString isEqualToString:[OSSVLocaslHosstManager appScheme]]) {
        handled = [self application:application deepLinkCallingWithURL:url sourceApplication:sourceApplication params:nil];
        
    } else if ([url.scheme.lowercaseString isEqualToString:[OSSVLocaslHosstManager projectAppnameLowercaseString]]) {
        if (url.query)
        {
            NSString *queryStr = [url.query decodeFromPercentEscapeString:url.query];
            NSArray *arr = [queryStr componentsSeparatedByString:@"&"];
            for (NSString *str in arr)
            {
                if ([str containsString:@"source"]) {
                    NSRange range = [str rangeOfString:@"="];
                    if (range.location != NSNotFound) {
                        NSString *value = [str substringFromIndex:range.location+1];
                        
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [defaults setObject:value forKey:kSourceKey];
                        [defaults synchronize];
                    }
                }
            }
        }
    } else if ([[SensorsAnalyticsSDK sharedInstance] handleSchemeUrl:url]) {
        handled = YES;
    }
    
    [[Branch getInstance] application:application openURL:url options:options];
//    [[AppsFlyerLib shared] handleOpenUrl:url options:options];
    [[BDAutoTrackSchemeHandler sharedHandler] handleURL:url appID:OSSVLocaslHosstManager.abTestAppId scene:nil];

    return handled;
}


- (void)stl_application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray * __nullable restorableObjects))restorationHandler {
    
    [[Branch getInstance] continueUserActivity:userActivity];
//    [[AppsFlyerLib shared] continueUserActivity:userActivity restorationHandler:restorationHandler];
}

    
#pragma mark -===========AppsFlyerTrackerDelegate===========

//{
//    adgroup = "<null>";
//    "adgroup_id" = "<null>";
//    adset = "<null>";
//    "adset_id" = "<null>";
//    "af_click_lookback" = 7d;
//    "af_cpi" = "<null>";
//    "af_dp" = "adorawe://action?actiontype=3";
//    "af_siteid" = "<null>";
//    "af_status" = "Non-organic";
//    "af_sub1" = "<null>";
//    "af_sub2" = "<null>";
//    "af_sub3" = "<null>";
//    "af_sub4" = "<null>";
//    "af_sub5" = "<null>";
//    agency = "<null>";
//    campaign = "SMS_Adv";
//    "campaign_id" = "<null>";
//    channel = Facebook;
//    "click_time" = "2020-10-30 12:04:23.016";
//    "cost_cents_USD" = 0;
//    "engmnt_source" = "<null>";
//    "esp_name" = "<null>";
//    "http_referrer" = "http://api.adorawe.com.release.fpm.slktest.com/wap/download-app?lang=en&channel=Facebook&uid=0&device_id=06a6539fa7bd860e&currency=USD&version=1.1.2&platform=android&fbclid=IwAR3x0Eq5_aGj0cdAE82JIVe1LvOP3bxr8UvF7DUgz8oC6wEI2EKKDjcvc28";
//    "install_time" = "2020-10-30 12:06:07.890";
//    "is_branded_link" = "<null>";
//    "is_first_launch" = 0;
//    "is_universal_link" = "<null>";
//    iscache = 1;
//    "match_type" = probabilistic;
//    "media_source" = SMS;
//    "orig_cost" = "0.0";
//    "redirect_response_data" = "<null>";
//    "retargeting_conversion_type" = none;
//    uid = 0;
//    url = "7803,2";
//}
/**
* 点击OneLink广告带入的安装走的回调
* 这个方法在每次有后台唤醒都会调用
*/
//-(void)onConversionDataReceived:(NSDictionary*) installData
-(void)onConversionDataSuccess:(NSDictionary*) installData  {
    
    STLLog(@"------kkkkkkk onConversionDataSuccess: %@",installData);
    // AppsFlyer推广数据回调
    id status = [installData objectForKey:@"af_status"];
    BOOL firstLaunch = [[installData objectForKey:@"is_first_launch"] boolValue];
    
    [OSSVAccountsManager testLaunchMessage:[NSString stringWithFormat:@"--%@--first:%@",@"onConversionDataSuccess:",firstLaunch ? @"1" : @"0"]];
    
    //非自然安装
    if([status isEqualToString:@"Non-organic"] && firstLaunch) {
         
//        NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
//        if ([us boolForKey:FIRST_LOAD]) return;
        
//        [us setBool:YES forKey:FIRST_LOAD];
        
        
        //数据里用nil
//        if (STLJudgeNSDictionary(installData)) {
//            [us setObject:installData forKey:APPFLYER_ALL_PARAMS];
//        }
        [OSSVAnalyticsTool sharedManager].appsFlyerInstallData = installData;
        
//        id sourceID = [installData objectForKey:@"media_source"];// 推广来源
//        if (sourceID) {
//            [us setObject:STLToString(sourceID) forKey:MEDIA_SOURCE];
//        }
//
//        id campaign = [installData objectForKey:@"campaign"];// 营销数据
//        if (campaign) {
//            [us setObject:STLToString(campaign) forKey:CAMPAIGN];
//        }
        
//        id lkid = [installData objectForKey:@"af_sub1"];// lkid
//        if (lkid) {
//            [us setObject:STLToString(lkid) forKey:LKID];
//        }
        
//        id adId = [installData objectForKey:@"ad_id"];
//        if (adId) {
//            [us setObject:STLToString(adId) forKey:ADID];
//        }
//        //af字段
//        id af_adgroup_name = [installData objectForKey:AFADGroup];
//        if (STLToString(af_adgroup_name).length) {
//            [us setObject:STLToString(af_adgroup_name) forKey:AFADGroup];
//        }
//
        id urlStr = [installData objectForKey:@"af_dp"];// DeepLink跳转数据
//        if (STLToString(urlStr).length) {
//            [us setObject:STLToString(urlStr) forKey:@"af_dp"];
//        }
//
//        [us synchronize];
        
        //上传广告信息到Appflyer,其他值都传空
//        NSDictionary *params = @{@"af_content_type" : @"cold start info",
//                                 @"af_extra_info" : @{
//                                                        @"adgroup":STLToString(af_adgroup_name),
//                                                        @"af_deeplink" : STLToString(urlStr)
//                                                    },
//                                 };
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [OSSVAnalyticsTool appsFlyerTrackEvent:@"af_cold_start_info" withValues:params];
//        });
        
        if (!STLIsEmptyString(installData[@"channel"])) {
            [OSSVAccountsManager sharedManager].shareChannelSource = installData[@"channel"];
        }
        if (!STLIsEmptyString(installData[@"uid"])) {
            [OSSVAccountsManager sharedManager].shareSourceUid = installData[@"uid"];
        }
        
        // DeepLink跳转数据
        if (!STLIsEmptyString(urlStr)) {
            urlStr = REMOVE_URLENCODING(urlStr);
            NSURL *url = [NSURL URLWithString:urlStr];
            id deepLink = [installData objectForKey:@"url"];  // DeepLink跳转参数
            [self application:nil deepLinkCallingWithURL:url sourceApplication:nil params:deepLink];
        }
        
        STLLog(@"This is a none organic install. installData: %@",installData);
        
    } else if([status isEqualToString:@"Organic"]) {
        //自然安装
        STLLog(@"This is an organic install.");
    }
}

-(void)onConversionDataFail:(NSError *) error {
    STLLog(@"%@",error);
}
//-(void)onConversionDataRequestFailure:(NSError *) error {
//    STLLog(@"%@",error);
//}


/**
* OneLink 延迟深度链接回调
*/

- (void)onAppOpenAttribution:(NSDictionary*)attributionData
{
    NSString *link = STLToString([attributionData objectForKey:@"link"]);

    [OSSVAccountsManager testLaunchMessage:[NSString stringWithFormat:@"--%@%@--",@"onAppOpenAttribution:",link]];
    
    if (STLIsEmptyString(link)) return;

    
    NSMutableDictionary *eventLinkTypeDic = [[NSMutableDictionary alloc] init];
    NSArray *rootArr = [link componentsSeparatedByString:@"?"];
    NSString *sourceID = @"";
    NSString *campaign = @"";
    NSString *sub1 = @"";
    
    //分享拉新
    
    NSMutableDictionary *md = [OSSVAdvsEventsManager parseDeeplinkParamDicWithURL:[[NSURL alloc] initWithString:link]];
    if (!STLIsEmptyString(md[@"channel"])) {
        [OSSVAccountsManager sharedManager].shareChannelSource = md[@"channel"];
    }
    if (!STLIsEmptyString(md[@"uid"])) {
        [OSSVAccountsManager sharedManager].shareSourceUid = md[@"uid"];
    }

    if (link) {
        if (rootArr.count < 2) {
            //// 运营配置的短链接: https://**.onelink.me/737960948/f53ebe8c
            sourceID = STLToString([attributionData objectForKey:@"pid"]);
            campaign = STLToString([attributionData objectForKey:@"c"]);
            sub1 = STLToString([attributionData objectForKey:@"af_sub1"]);
            NSString *af_dp = attributionData[@"af_dp"];
            if (!STLIsEmptyString(af_dp)) {
                eventLinkTypeDic = [NSMutableDictionary dictionaryWithDictionary:attributionData];
            }
            
        } else {
            
            // 运营配置的长链接: https://**.onelink.me/737960948?pid=test1026&is_retargeting=true&af_dp=Adorawe%3A%2F%2Faction%3Factiontype%3D15%26url%3D161

            
            NSArray *arr = [rootArr[1] componentsSeparatedByString:@"&"];
            for (NSString *str in arr) {
                if ([str rangeOfString:@"="].location != NSNotFound) {
                    NSString *key = [str componentsSeparatedByString:@"="][0];
                    NSString *value = [str componentsSeparatedByString:@"="][1];
                    [eventLinkTypeDic setObject:STLToString(value) forKey:STLToString(key)];
                }
            }
            sourceID = STLToString(eventLinkTypeDic[@"pid"]);
            campaign = STLToString(eventLinkTypeDic[@"c"]);
            sub1     = STLToString(eventLinkTypeDic[@"af_sub1"]);
        };
    }
    
    
    NSString *deeplinkUrl = eventLinkTypeDic[@"af_dp"];
    deeplinkUrl = REMOVE_URLENCODING(deeplinkUrl);
    NSURL *url = [NSURL URLWithString:deeplinkUrl];
    
    if ([url.scheme.lowercaseString isEqualToString:[OSSVLocaslHosstManager appScheme]]) {
        UIApplication *application = [UIApplication sharedApplication];
        [self application:application deepLinkCallingWithURL:url sourceApplication:@"appsflyer" params:nil];
        
    } else { // 处理Onelink跳转
        ///Onelink: https://TestF.onelink.me/737960948?pid=APP_Share&c=ThematicTemplate&af_dp=TestF%253A%252F%252Faction%253Factiontype%253D15%2526url%253D202&is_retargeting=true&utm_source=appshare&utm_medium=copylink&utm_campaign=share
        
        NSURL *onelinkURL = [NSURL URLWithString:link];
        NSMutableDictionary *params = [OSSVAdvsEventsManager parseDeeplinkParamDicWithURL:onelinkURL];
        NSString *deeplink = nil;
        
        if (!STLIsEmptyString(params[@"channel"])) {
            [OSSVAccountsManager sharedManager].shareChannelSource = params[@"channel"];
        }
        if (!STLIsEmptyString(params[@"uid"])) {
            [OSSVAccountsManager sharedManager].shareSourceUid = params[@"uid"];
        }
        
        if ([onelinkURL.host.lowercaseString isEqualToString:[OSSVLocaslHosstManager appFlyerOnelink]]
            || [onelinkURL.host.lowercaseString isEqualToString:[OSSVLocaslHosstManager appFlyerOnelinkTwo]]) {
            
            NSString *af_dp_url = params[@"af_dp"];
            if (!STLIsEmptyString(af_dp_url)) {
                deeplink = [af_dp_url stringByRemovingPercentEncoding];
            }
        }
        
        if (!deeplink) {
            return;
        }
        [self application:nil deepLinkCallingWithURL:[NSURL URLWithString:deeplink] sourceApplication:@"appsflyer" params:nil];

    }
}

- (void) onAppOpenAttributionFailure:(NSError *)error {
  STLLog(@"onAppOpenAttributionFailure: %@",error);
}


@end
