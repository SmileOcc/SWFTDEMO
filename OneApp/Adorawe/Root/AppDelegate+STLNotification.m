//
//  AppDelegate+STLNotification.m
// XStarlinkProject
//
//  Created by odd on 2020/7/10.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "AppDelegate+STLNotification.h"

#ifdef AppsFlyerAnalyticsEnabled
//#import <AppsFlyerLib/AppsFlyerLib.h>

#endif

#import "OSSVAdvsViewsManager.h"

@implementation AppDelegate (STLNotification)


#pragma mark - ===========注册推送===========

- (void)dealWithNotification:(UIApplication *)application launchingOptions:(NSDictionary *)launchOptions
{
    //是否为推送启动APP，0为非推送打开，1为推送打开
    NSString *isFromPush = @"0";
    // 判断是否为杀死App时: 点击通知启动App
    if (STLJudgeNSDictionary(launchOptions)) {
        NSDictionary *userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        if (userInfo && ![userInfo isKindOfClass:[NSNull class]]) {
            [self dealwithRemotePushNotification:userInfo];
            isFromPush = @"1";
        }
    }
    
    
    BOOL hasShowUserNotification = [STLUserDefaultsGet(kHadShowSystemNotificationAlert) boolValue];
    //判断非首次, 并且已经弹过系统推送框 进来每次才重新注册远程推送通知
    if (hasShowUserNotification) {
        // 非首次注册
        [AppDelegate stlRegisterRemoteNotification:nil];
        
        [STLPushManager isRegisterRemoteNotification:^(BOOL isRegister) {
            if (!isRegister) {
                // 保存LeandCloud数据
                [OSSVAccountsManager saveLeandCloudData];
            }
        }];
    }
}

/**
 * 注册远程推送通知
 */
+ (void)stlRegisterRemoteNotification:(void(^)(NSInteger openFlag))completionBlock {
    
    // 根据系统版本注册远程推送通知
    UIApplication *application = [UIApplication sharedApplication];
    
    UNUserNotificationCenter *uncenter = [UNUserNotificationCenter currentNotificationCenter];
    // 必须写代理，不然无法监听通知的接收与点击
    uncenter.delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [uncenter requestAuthorizationWithOptions:(UNAuthorizationOptionAlert+UNAuthorizationOptionBadge+UNAuthorizationOptionSound)
                            completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [application registerForRemoteNotifications];
                                    STLLog(@"获取授权状态===%@", granted ? @"授权成功" : @"授权失败");

                                    //标记已经注册推送通知
                                    STLUserDefaultsSet(kHadRegisterRemotePush, @(YES));
                                    NSString *lastTimesTamp = STLUserDefaultsGet(kShowAppNotificationAlertTimestamp);
                                    if (STLIsEmptyString(STLToString(lastTimesTamp))) {
                                        NSString *currentTimesTamp = [OSSVNSStringTool getCurrentTimestamp];
                                        STLUserDefaultsSet(kShowAppNotificationAlertTimestamp, currentTimesTamp);
                                    }

                                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_NotificationSuccess object:nil];
                                    
                                    if (completionBlock) {
                                        completionBlock((granted ? 1 : 0));
                                    }
                                });
                            }];
    //标记已经弹过系统推送框
    STLUserDefaultsSet(kHadShowSystemNotificationAlert, @(YES));
}
   

#pragma mark - ===========注册回调===========

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
    STLLog(@"推送通知即将从屏幕上方弹出");
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
}

/**
 * （iOS 10.0以上系统) 接受到远程推送通知
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)(void))completionHandler {
    
    [OSSVAccountsManager testLaunchMessage:@"didReceiveNotification--"];
    //处理远程推送跳转
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    STLLog(@"(iOS 10.0以上上上上上上系统, 处理远程推送跳转====%ld",[UIApplication sharedApplication].applicationState);

    [self dealwithRemotePushNotification:userInfo];
    completionHandler();
}
 

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    //正确写法
    NSString *deviceString = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceString = [deviceString stringByReplacingOccurrencesOfString:@" " withString:@""];
    STLLog(@"deviceToken===========%@",deviceString);
    
    NSString *appToken = [OSSVNSStringTool hexadecimalStringFromData:deviceToken];
    [OSSVAccountsManager sharedManager].appDeviceToken = appToken;

    [OSSVAccountsManager testLaunchMessage:[NSString stringWithFormat:@"-%@%@--",@"didRegisterForRemoteApiToken:",STLIsEmptyString(appToken) ? @"0" : @"1"]];
    
    #ifdef AppsFlyerAnalyticsEnabled
        //AppsFlyer 统计卸载
//        [[AppsFlyerLib shared] registerUninstall:deviceToken];
    #endif
    
    [OSSVAccountsManager saveLeandCloudData];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
}
    

#pragma mark - =========== 点击推送数据 ===========


/**
 * 处理点击通知跳转逻辑
 */

/**
 后台推送数据格式
{
    aps =     {
        alert =         {
            body = "\U6d4b\U8bd5\U901a\U77e5";
            title = "\U6d4b\U8bd5\U901a\U77e5";
        };
        "mutable-content" = 1;
        sound = default;
    };
    body = "\U6d4b\U8bd5\U901a\U77e5";
    c = "IOS_202011131019_0026";
    channel = FCM;
    "content_color" = "#000000";
    "gcm.message_id" = 1605234052304782;
    "google.c.a.e" = 1;
    "google.c.sender.id" = 492937043190;
    image = "";
    "image_type" = 0;
    pid = cid;
    "push_id" = "adorawe-4-1605234052-8ee66d4f6b7c91371414a702ca56d317";
    "push_time" = 1605234052055;
    sound = default;
    title = "\U6d4b\U8bd5\U901a\U77e5";
    "title_color" = "#000000";
    url = "adorawe://action?actiontype=1";
}
 
 FCM官网推送数据格式
 
 {
     aps =     {
         alert =         {
             body = "new shoping";
             title = Adorawe;
         };
         badge = 1;
         "mutable-content" = 1;
         sound = default;
     };
     "gcm.message_id" = 1605235296435032;
     "gcm.n.e" = 1;
     "gcm.notification.android_channel_id" = cf;
     "gcm.notification.sound2" = default;
     "google.c.a.c_id" = 8594852377652514422;
     "google.c.a.c_l" = "ppppp name";
     "google.c.a.e" = 1;
     "google.c.a.ts" = 1605235296;
     "google.c.a.udt" = 0;
     "google.c.sender.id" = 492937043190;
 #///自定义参数
     kkk = vvv;
     url = "adorawe://action?actiontype=2&url=20&name=category";
     "push_id" = "adorawe-4-1605234052-8ee66d4f6b7c91371414a702ca56d317";
     "push_time" = 1605234052055;
     channel = FCM;

 }
*/
- (void)dealwithRemotePushNotification:(NSDictionary *)pushUserInfo {
    
    [self clearPushBadge:SHAREDAPP];
    if (STLJudgeNSDictionary(pushUserInfo)) {
        STLLog(@"---处理点击通知:%@",pushUserInfo);
        
//        [[AppsFlyerLib shared] handlePushNotification:pushUserInfo];

        //接收保存推送摧付参数
        [OSSVAdvsEventsManager saveNotificationsPaymentParmaters:pushUserInfo];
        
        NSString* urlStr = STLToString(pushUserInfo[@"url"]);
        
        [OSSVAccountsManager testLaunchMessage:[NSString stringWithFormat:@"--\n%@%@--",@"dealwithRemoteOO:",urlStr]];

            if (urlStr.length>0) {
                ///因为后台返回的数据可能会带空格或者汉字或者特殊字符, 如果类型是actionType=7, 后台数据最好是把url先encode一下。不然可能会出现丢参数的情况
                urlStr = URLENCODING(urlStr);
                
                STLLog(@"notifications_url:%@", urlStr);
                
                ///拼接国家站点信息到URL中间
                NSString *str = pushUserInfo[@"country_site"];
                NSURLComponents *components = [NSURLComponents componentsWithString:urlStr];
                NSMutableArray *params = [[NSMutableArray alloc] init];
                if (components.queryItems.count > 0) {
                    [params addObjectsFromArray:components.queryItems];
                }
                
                if (str.length > 0) {
                    [params addObject:[[NSURLQueryItem alloc] initWithName:@"country_site" value:str]];
                }
                components.queryItems = params;
                NSURL *url = components.URL;
                
                if ([url.scheme.lowercaseString isEqualToString:[OSSVLocaslHosstManager appScheme]])
                {
                    [self application:nil deepLinkCallingWithURL:url sourceApplication:@"open" params:nil];
                }
            }
        
    }
    
    // 统计用户收到推送的AF和点击量次数
    [self analyticsNotifyAFTapRate:pushUserInfo];
    [self analyticsNotifyBranchTapRate:pushUserInfo];
}

/**
 * 点击通知不管在前后台都需要调用此方法: 统计用户收到推送的AF和点击量次数
 */
- (void)analyticsNotifyAFTapRate:(NSDictionary *)userInfo {
    
    if (!STLJudgeNSDictionary(userInfo)) return;
    
    // AF统计
//    [[AppsFlyerLib shared] handlePushNotification:userInfo];
    
    //统计推送点击量事件
    NSString *deeplink = STLToString(userInfo[@"url"]);
    [OSSVAnalyticsTool appsFlyerTrackEvent:@"af_push" withValues:@{
        @"af_content_type" : @"push_click",
        @"af_push_deeplink" : STLToString(deeplink),
        @"af_push_c":STLToString(userInfo[@"c"]),
        @"af_push_id":STLToString(userInfo[@"push_id"])
    }];
    
}

///点击通知不管在前后台都需要调用此方法: 统计用户收到推送点击量次数
- (void)analyticsNotifyBranchTapRate:(NSDictionary *)userInfo {
   
   if (!STLJudgeNSDictionary(userInfo)) return;
   
   // Branch统计
    [[Branch getInstance] handlePushNotification:userInfo];
   
   //统计推送点击量事件
   NSString *deeplink = STLToString(userInfo[@"url"]);
    NSDictionary *params = @{
        @"af_content_type" : @"push_click",
        @"af_push_deeplink" : STLToString(deeplink),
        @"af_push_c":STLToString(userInfo[@"c"]),
        @"af_push_id":STLToString(userInfo[@"push_id"])
    };
    //branch 埋点
    [OSSVBrancshToolss logPush:params];
    //埋神策
    [OSSVAnalyticsTool analyticsSensorsEventWithName:@"af_push" parameters:params];
}

// Appflyer推广跳转处理
-(BOOL)application:(UIApplication *)application deepLinkCallingWithURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication params:(id)params
{
    self.isDeepLinkEventing = YES;
    NSMutableDictionary *md = [OSSVAdvsEventsManager parseDeeplinkParamDicWithURL:url];
    [OSSVAdvsEventsManager saveOneLinkeParams:md];
    ///如果deeplink需要跳转内部地址链接并且带有&参数的话，需要把 url的参数连续两次 encode
    STLLog(@"url = %@ \n query = %@ \n host = %@", url.absoluteString, url.query, url.host);
    
    if (!STLIsEmptyString(md[@"channel"])) {
        [OSSVAccountsManager sharedManager].shareChannelSource = md[@"channel"];
    }
    if (!STLIsEmptyString(md[@"uid"])) {
        [OSSVAccountsManager sharedManager].shareSourceUid = md[@"uid"];
    }
    
    OSSVAdvsEventsModel *advEventModel = [[OSSVAdvsEventsModel alloc] init];
    advEventModel.actionType = AdvEventTypeDefault;
    advEventModel.url  = @"";
    advEventModel.name = @"";
    if (md.count>0) {
        advEventModel.actionType = [md[@"actiontype"] integerValue];
        advEventModel.url        = REMOVE_URLENCODING(STLToString(md[@"url"]));
        advEventModel.name       = REMOVE_URLENCODING(STLToString(md[@"name"]));
        advEventModel.country_site = REMOVE_URLENCODING(STLToString(md[@"country_site"]));
    }
    
    // 如果是推送跳转，则先提示用户是否打开
    if ([STLToString(md[@"source"]) isEqualToString:@"notifications"] && [sourceApplication isEqualToString:@"open"])
    {
        STLAlertViewController *alertController = [STLAlertViewController alertControllerWithTitle:STLLocalizedString_(@"notifications",nil) message:advEventModel.name preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:APP_TYPE == 3 ? STLLocalizedString_(@"cancel",nil) : STLLocalizedString_(@"cancel",nil).uppercaseString style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            self.isDeepLinkEventing = NO;
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:APP_TYPE == 3 ? STLLocalizedString_(@"open",nil) : STLLocalizedString_(@"open",nil).uppercaseString style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if (advEventModel.actionType  == AdvEventTypeDefault) {
                self.isDeepLinkEventing = NO;
            }
            if (self.isDeepLinkEventing) {
                [self applyDeepLinkCallingWithEventModel:advEventModel];
            }
        }]];
        [self.window.rootViewController presentViewController:alertController animated:YES completion:^{}];
    }else{
        if (advEventModel.actionType  == AdvEventTypeDefault) {
            self.isDeepLinkEventing = NO;
        }
        if (self.isDeepLinkEventing)
        {
            
            OSSVAdvsEventsModel *lastModel = [OSSVAdvsViewsManager sharedManager].lastDeeplinkModel;

            [OSSVAccountsManager testLaunchMessage:[NSString stringWithFormat:@"--lastModelyyy:%@ isDeep: %@--",lastModel ? @"lasModel" : @"yyy",self.isDeepLinkEventing ? @"1": @"0"]];

            if (lastModel && lastModel.actionType == advEventModel.actionType && [STLToString(lastModel.url) isEqualToString:STLToString(advEventModel.url)]) {
                //self.isDeepLinkEventing = NO;
                [OSSVAccountsManager testLaunchMessage:[NSString stringWithFormat:@"--%@ isDeep: %@--",@"isIgnore:",self.isDeepLinkEventing ? @"1": @"0"]];
                [OSSVAdvsViewsManager sharedManager].lastDeeplinkModel = nil;
                return YES;
            } else {
                [OSSVAdvsViewsManager sharedManager].lastDeeplinkModel = advEventModel;
            }
            
            [self applyDeepLinkCallingWithEventModel:advEventModel];

        }
    }
    return YES;
}


    
- (void)applyDeepLinkCallingWithEventModel:(OSSVAdvsEventsModel *)advEventModel {
    
    //从appsflyer 进来时不是主线程，回到主线程再操作UI
    if (![NSThread isMainThread]) {
        
        [OSSVAccountsManager testLaunchMessage:[NSString stringWithFormat:@"--%@ tabBarVC:%@--",@"NOMainDeepLinkCallingWith:",self.tabBarVC.viewControllers.count>0 ? @"1" : @"0"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self applyDeepLinkCallingWithEventModel:advEventModel];
        });
    } else {
        
        [OSSVAccountsManager testLaunchMessage:[NSString stringWithFormat:@"--%@ tabBarVC:%@ isDeep:: %@--",@"Mian DeepLinkCallingWith:",self.tabBarVC.viewControllers.count>0 ? @"1" : @"0",self.isDeepLinkEventing ? @"1": @"0"]];

        // 判断是否已创建tabbar
        if (self.tabBarVC.viewControllers.count>0) {
            self.isDeepLinkEventing = NO;
            [OSSVAdvsEventsManager advEventTarget:[UIViewController lastNavTopViewController] withEventModel:advEventModel];

        }else{
            NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:advEventModel];
            if (data) {
                [us setObject:data forKey:DeepLinkModel];
                [us synchronize];
            }
        }
    }
}


#pragma mark - ===========处理deepLink, 推送跳转逻辑===========

-(BOOL)deepLinkCallingWithURL:(NSURL *)url
                  deepLinkUrl:(NSString *)deepLinkUrl
                 deeplinkType:(NSString *)deeplinkType   // 统计来源类型
           remoteNotification:(NSDictionary *)userInfo
{
    return YES;
}




/**
 * 清除角标
 */
- (void)clearPushBadge:(UIApplication *)application {
    NSInteger num = application.applicationIconBadgeNumber;
    if(num != 0) {
        application.applicationIconBadgeNumber = 0;
    }
}
    
#pragma mark - 使用 user 信息，查询当前用户的状态

+ (void)checkAuthorizationStateCompleteHandler:(void(^)(BOOL authorized, NSString *msg)) completeHandler API_AVAILABLE(ios(13.0)) {
    
    NSString *bundleId = [NSBundle mainBundle].bundleIdentifier;
    NSString *userIdentifier = [SSKeychain passwordForService:bundleId account:kSTLCurrentAppIdentifier];
    
    if (userIdentifier == nil || userIdentifier.length <= 0) {
        if (completeHandler) {
            completeHandler(NO, @"用户标识符错误");
        }
        return;
    }

    if (@available(iOS 13.0, *)) {

        ASAuthorizationAppleIDProvider *provider = [[ASAuthorizationAppleIDProvider alloc]init];
        [provider getCredentialStateForUserID:userIdentifier completion:^(ASAuthorizationAppleIDProviderCredentialState credentialState, NSError * _Nullable error) {
            NSString *msg = @"未知";
            BOOL authorized = NO;
            switch (credentialState) {
                case ASAuthorizationAppleIDProviderCredentialRevoked:
                    msg = @"授权被撤销";
                    authorized = NO;
                    break;
                case ASAuthorizationAppleIDProviderCredentialAuthorized:
                    msg = @"已授权";
                    authorized = YES;
                    break;
                case ASAuthorizationAppleIDProviderCredentialNotFound:
                    msg = @"未查到授权信息";
                    authorized = NO;
                    break;
                case ASAuthorizationAppleIDProviderCredentialTransferred:
                    msg = @"授权信息变动";
                    authorized = NO;
                    break;
                default:
                    authorized = NO;
                    break;
            }
            if (completeHandler) {
                completeHandler(authorized, msg);
            }
        }];
    }

}

    
    
#pragma mark - 测试

//+ (void)testPushLocalNotification {
//    
//    #if DEBUG
//    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//    center.delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [AppDelegate createLocalizedUserNotification];
//    });
//    #endif
//}
//    
//    
////定时推送
//+ (void)createLocalizedUserNotification{
//
//    [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
//    return;
//    
//    // 设置触发条件 UNNotificationTrigger
//    UNTimeIntervalNotificationTrigger *timeTrigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:10.0f repeats:NO];
//
//    // 创建通知内容 UNMutableNotificationContent, 注意不是 UNNotificationContent ,此对象为不可变对象。
//    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
//    content.title = @"Dely 时间提醒 - title";
//    content.subtitle = [NSString stringWithFormat:@"Dely 装逼大会竞选时间提醒 - subtitle"];
//    content.body = @"Dely 装逼大会总决赛时间到，欢迎你参加总决赛！希望你一统X界 - body";
//    content.badge = @666;
//    content.sound = [UNNotificationSound defaultSound];
//    content.userInfo = @{@"key1":@"value1",@"key2":@"value2"};
//
//    // 创建通知标示
//    NSString *requestIdentifier = @"Dely.X.time";
//
//    // 创建通知请求 UNNotificationRequest 将触发条件和通知内容添加到请求中
//    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier content:content trigger:timeTrigger];
//
//    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
//    // 将通知请求 add 到 UNUserNotificationCenter
//    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
//        if (!error) {
//            STLLog(@"推送已添加成功 %@", requestIdentifier);
//            //你自己的需求例如下面：
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                
//            });
//            //此处省略一万行需求。。。。
//        }
//    }];
//    
//    
//    content = [[UNMutableNotificationContent alloc] init];
//    content.badge = [NSNumber numberWithInt:1];
//    content.title = @"磨蹭";
//    content.body = @"不要磨蹭了你个懒蛋";
//    content.sound = [UNNotificationSound defaultSound];
//    // 间隔多久推送一次
//    // 当前时间之后的没分钟推送一次(如果重复的话时间要大于等于60s)
//                UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:60 repeats:YES];
//    // 定时推送
//    NSDateComponents *dateCom = [[NSDateComponents alloc] init];
//    // 每天下午两点五十五分推送
//    dateCom.hour = 15;
//    dateCom.minute = 49;
////    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateCom repeats:YES];
//    
//    UNNotificationRequest *notificationRequest = [UNNotificationRequest requestWithIdentifier:@"request1" content:content trigger:trigger];
//    [center addNotificationRequest:notificationRequest withCompletionHandler:^(NSError * _Nullable error) {
//    }];
//
//}
@end
