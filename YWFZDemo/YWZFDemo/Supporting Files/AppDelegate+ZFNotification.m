//
//  AppDelegate+ZFNotification.m
//  ZZZZZ
//
//  Created by YW on 2018/5/4.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "AppDelegate+ZFNotification.h"
#import "JumpModel.h"
#import "JumpManager.h"
#import "Constants.h"
#ifdef LeandCloudEnabled
#import <AVOSCloud/AVOSCloud.h>
#endif
#import "FirebaseMessaging.h"
#import "Branch/Branch.h"
#import "NSStringUtils.h"
#import "NSString+Extended.h"
#import "ZFLocalizationString.h"
#import "ZFAnalytics.h"
#import "ZFGrowingIOAnalytics.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "YSAlertView.h"
#import "ZFCommonRequestManager.h"
#import "AFNetworkReachabilityManager.h"
#import "ZFAppsflyerAnalytics.h"
#import "BannerManager.h"
#import "YWLocalHostManager.h"

@import GlobalegrowIMSDK;
@implementation AppDelegate (ZFNotification)
/**
 * （10.0以上系统在前台收到通知调用）推送通知即将从屏幕上方弹出
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
    YWLog(@"推送通知即将从屏幕上方弹出");
    if ([notification.request.identifier isEqualToString:[ChatConfig share].kLocalNotificationIdentifer]) {
        [[ChatConfig share] didReceiveNotificationWithNotification:notification];
    } else {
        completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
    }
}

/**
 * （iOS 10.0以上系统) 接受到远程推送通知
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)(void))completionHandler
{
    if ([response.notification.request.identifier isEqualToString:[ChatConfig share].kLocalNotificationIdentifer]) {
        [[ChatConfig share] didReceiveNotificationWithNotification:response.notification];
    } else {
        //处理远程推送跳转
        NSDictionary *userInfo = response.notification.request.content.userInfo;
        YWLog(@"(iOS 10.0以上上上上上上系统, 处理远程推送跳转====%ld",[UIApplication sharedApplication].applicationState);
        [self dealwithRemotePushNotification:userInfo];
        completionHandler();
    }
}

#pragma mark -===========注册推送===========

- (void)dealWithNotification:(UIApplication *)application launchingOptions:(NSDictionary *)launchOptions
{
    //是否为推送启动APP，0为非推送打开，1为推送打开
    NSString *isFromPush = @"0";
    // 判断是否为杀死App时: 点击通知启动App
    if (ZFJudgeNSDictionary(launchOptions)) {
        NSDictionary *userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        if (userInfo && ![userInfo isKindOfClass:[NSNull class]]) {
            [self dealwithRemotePushNotification:userInfo];
            isFromPush = @"1";
        }
    }
    
    //统计首页进入次数
    [ZFAnalytics appsFlyerTrackEvent:@"af_enter_app" withValues:@{
        @"af_content_type" : @"enter app",
        @"af_from_push" : ZFToString(isFromPush)
    }];
    
    BOOL hasShowUserNotification = [GetUserDefault(kHasShowSystemNotificationAlert) boolValue];
    // 判断非首次, 并且已经弹过系统推送框 进来每次才重新注册远程推送通知
    if (hasShowUserNotification) {
        // 非首次注册
        [AppDelegate registerZFRemoteNotification:nil];
        
        if (![UIApplication sharedApplication].isRegisteredForRemoteNotifications) {
            // 保存LeandCloud数据
            [AccountManager saveLeandCloudData];
        }
    }
}

/**
 * 注册远程推送通知
 */
+ (void)registerZFRemoteNotification:(void(^)(NSInteger openFlag))completionBlock
{
    // 根据系统版本注册远程推送通知
    UIApplication *application = [UIApplication sharedApplication];
    
    UNUserNotificationCenter *uncenter = [UNUserNotificationCenter currentNotificationCenter];
    // 必须写代理，不然无法监听通知的接收与点击
    uncenter.delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [uncenter requestAuthorizationWithOptions:(UNAuthorizationOptionAlert+UNAuthorizationOptionBadge+UNAuthorizationOptionSound)
                            completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [application registerForRemoteNotifications];
                                    YWLog(@"获取授权状态===%@", granted ? @"授权成功" : @"授权失败");
                                    
                                    //标记已经注册推送通知
                                    SaveUserDefault(kHasRegisterRemotePush, @(YES));
                                    if (completionBlock) {
                                        completionBlock((granted ? 1 : 0));
                                    }
                                    //                                        // 保存LeandCloud数据
                                    //                                        [AccountManager saveLeandCloudData];
                                });
                            }];
    //标记已经弹过系统推送框
    SaveUserDefault(kHasShowSystemNotificationAlert, @(YES));
}

#pragma mark -========= 处理推送跳转逻辑 =========

/**
 * 处理点击通知跳转逻辑
 */
- (void)dealwithRemotePushNotification:(NSDictionary *)pushUserInfo
{
    if (ZFJudgeNSDictionary(pushUserInfo)) {
        pushUserInfo = [self formateNotificationsDic:pushUserInfo savePaymentParmaters:YES];
        NSString *urlStr = NullFilter(pushUserInfo[@"url"]);
        if (urlStr.length > 0) {
            urlStr = ZFEscapeString(urlStr, YES);
            NSURL *url = [NSURL URLWithString:urlStr];
            if ([url.scheme.lowercaseString isEqualToString:kZZZZZScheme]) {
                [self deepLinkCallingWithURL:url
                                 deepLinkUrl:nil
                                deeplinkType:@"push"
                          remoteNotification:pushUserInfo];
            }
        }
    }
    // 统计用户收到推送的AF和点击量次数
    [self analyticsNotifyAFTapRate:pushUserInfo];
}

/**
 * 点击通知不管在前后台都需要调用此方法: 统计用户收到推送的AF和点击量次数
 */
- (void)analyticsNotifyAFTapRate:(NSDictionary *)userInfo
{
    /*
     aps =     {
         alert =         {
             body = 666666666888;
             title = 6666666888;
         };
         "content-available" = 1;    //此字段为静默推送参数
         "mutable-content" = 1;
         sound = default;
     };
     */
    if (!ZFJudgeNSDictionary(userInfo)) return;
    
    // AF统计
    [[AppsFlyerTracker sharedTracker] handlePushNotification:userInfo];
    
#ifdef LeandCloudEnabled
    [AVAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
#endif
    
    YWLog(@"用户收到推送统计点击量===%@", userInfo);
    NSString *pushId    = ZFToString(userInfo[@"push_id"]);
    NSString *pid       = ZFToString(userInfo[@"pid"]);
    NSString *cString   = ZFToString(userInfo[@"c"]);
    
    NSDictionary *af = userInfo[@"af"];
    if (ZFJudgeNSDictionary(af)) {
        NSString *af_pid = af[@"pid"];
        if (!ZFIsEmptyString(af_pid)) {
            pid = af_pid;
        }
        NSString *af_c = af[@"c"];
        if (!ZFIsEmptyString(af_c)) {
            cString = af_c;
        }
    }
    [ZFGrowingIOAnalytics ZFGrowingIOClickPush:pid pushName:cString];
    
#ifdef BranchEnabled
    [[Branch getInstance] handlePushNotification:userInfo];
    NSString *branchUrl = [NSString stringWithFormat:@"https://ZZZZZ.app.link?~feature=push&~channel=%@&~campaign=%@", pid, cString];
    [[Branch getInstance] handleDeepLinkWithNewSession:[NSURL URLWithString:branchUrl]];
#endif
    
    // 同步点击远程推送的信息给服务端
    [ZFCommonRequestManager syncClickRemotePushWithPid:pid cString:cString pushId:pushId];
    
    //统计推送点击量事件
    NSString *deeplink = NullFilter(userInfo[@"url"]);
    [ZFAnalytics appsFlyerTrackEvent:@"af_push_click" withValues:@{
        @"af_content_type" : @"push_click",
        @"af_push_deeplink" : ZFToString(deeplink)
    }];
}

#pragma mark - 推送数据格式处理
/**
 * 包装推送数据参数
 * userInfo: 源数据
 * save: 保存推送通知参数
 * 推送数据处理: Leancloud or FCM 推送数据不同
 大体格式：
FCM:

远程推送通知: {
    aps =     {
        alert =         {
            body = ZZZZZZZZ;
            title = KKKK;
        };
    };
    body = ZZZZZZZZ;
    c = "FCM-EN";
    channel = FCM;
    "gcm.message_id" = "0:1535431449688591%557a9cf1557a9cf1";
    "google.c.a.e" = 1;
    "is_retargeting" = true;
    pid = "PUSH-EN";
    title = KKKK;
    url = "";
}

Len:

{
    action = "com.ZZZZZ.UPDATE_STATUS";
    af =     {
        "is_retargeting" = true;
        pid = "PUSH-ES";
    };
    aps =     {
        alert =         {
            body = "\U8fd9\U4e2a\U662fLeav";
            title = "\U5357\U4e0b";
        };
        badge = 1;
    };
    "message_id" = 8575571df9e5f44652b8218bcf536554;
    title = "\U5357\U4e0b";
    url = "";
}
*/

- (NSDictionary *)formateNotificationsDic:(NSDictionary *)userInfo savePaymentParmaters:(BOOL)save
{
    NSMutableDictionary *userInfoDic = [[NSMutableDictionary alloc] initWithDictionary:userInfo];
    ///有或处理了推送数据
    if (!ZFIsEmptyString(userInfo[@"channel"]) && !ZFJudgeNSDictionary(userInfoDic[@"af"])) {
        if ([userInfo[@"channel"] isEqualToString:@"FCM"]) {
            NSDictionary *afDict = @{
                                     @"pid" : ZFToString(userInfo[@"pid"]),
                                     @"c" : ZFToString(userInfo[@"c"]),
                                     @"is_retargeting" : userInfo[@"is_retargeting"] ?: @"false"
                                     };
            [userInfoDic setValue:afDict forKey:@"af"];
        }
    }
    if (save) {
        //保存推送通知参数
        NSDictionary *parmaters = userInfoDic[@"af"];
        if (ZFJudgeNSDictionary(parmaters)) {
            NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
            // 推送摧付参数
            [us setObject:parmaters forKey:NOTIFICATIONS_PAYMENT_PARMATERS];
            // 推送时间
            [us setInteger:[[NSStringUtils getCurrentTimestamp] integerValue] forKey:SAVE_NOTIFICATIONS_PARMATERS_TIME];
            [us synchronize];
        }
    }
    return userInfoDic;
}

#pragma mark -===========处理接收推送通知===========

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *appToken = [NSStringUtils hexadecimalStringFromData:deviceToken];
    [AccountManager sharedManager].appDeviceToken = appToken;
    YWLog(@"远程推送deviceToken=====%@",appToken);
    
#ifdef LeandCloudEnabled
    AVInstallation *installation = [AVInstallation defaultInstallation];
    // 二进制数据（device token）转化为正确的十六进制字符串，
    // 同时配置苹果开发者账号的 Team ID
    [installation setDeviceTokenFromData:deviceToken teamId:kZZZZZTeamId];
    // 上传有效的十六进制字符串和 Team ID
//    [currentInstallation1 saveInBackground]; // 在后面方法统一保存
#endif
    
    [[AppsFlyerTracker sharedTracker] registerUninstall:deviceToken];
    
    // 保存LeandCloud数据
    [AccountManager saveLeandCloudData];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    YWLog(@"did Fail Register Notifications = %@", [error description]);
}

/**
 * 清除角标 
 */
- (void)clearPushBadge:(UIApplication *)application {
    NSInteger num = application.applicationIconBadgeNumber;
    if(num != 0) {
        AVInstallation *currentInstallation = [AVInstallation defaultInstallation];
        [currentInstallation setBadge:0];
        [currentInstallation saveEventually];
        application.applicationIconBadgeNumber = 0;
    }
}

#pragma mark -===========处理deepLink, 推送跳转逻辑===========

-(BOOL)deepLinkCallingWithURL:(NSURL *)url
                  deepLinkUrl:(NSString *)deepLinkUrl
                 deeplinkType:(NSString *)deeplinkType   // 统计来源类型
           remoteNotification:(NSDictionary *)userInfo
{
    //v4.1.0 从Appsflyer跳进来的时候，是非主线程的，因为后续要操作UI，强制回到主线程
    self.isDeepLink = YES;
    
    NSMutableDictionary *urlParamDic = [BannerManager parseDeeplinkParamDicWithURL:url];
    
    JumpModel *jumpModel = [[JumpModel alloc] init];
    jumpModel.actionType = JumpDefalutActionType;
    jumpModel.url  = @"";
    jumpModel.name = @"";
    jumpModel.featuring = @"";
    if (urlParamDic.count > 0) {
        jumpModel.actionType = [urlParamDic[@"actiontype"] integerValue];
        jumpModel.url        = NullFilter(urlParamDic[@"url"]);
        jumpModel.name       = NullFilter(urlParamDic[@"name"]);
        jumpModel.featuring  = NullFilter(urlParamDic[@"featuring"]);
        jumpModel.sort       = NullFilter(urlParamDic[@"sort"]);
        jumpModel.refine     = NullFilter(urlParamDic[@"refine"]);
        jumpModel.minprice   = NullFilter(urlParamDic[@"minPrice"]);
        jumpModel.maxprice   = NullFilter(urlParamDic[@"maxPrice"]);
        jumpModel.isCouponListDeeplink = [NullFilter(urlParamDic[@"isCouponListDeeplink"]) boolValue];
        jumpModel.giftId     = NullFilter(urlParamDic[@"giftId"]);
        jumpModel.source     = NullFilter(urlParamDic[@"source"]);
        jumpModel.bucketid   = NullFilter(urlParamDic[@"buckid"]);
        jumpModel.versionid  = NullFilter(urlParamDic[@"versionid"]);
        jumpModel.planid     = NullFilter(urlParamDic[@"planid"]);
        
        //如果推送中包含pts实验参数
        if (ZFToString(userInfo[@"bts"]).length) {
            jumpModel.pushPtsModel = [ZFPushPtsModel yy_modelWithJSON:userInfo[@"bts"]];
        }
        
        // 是否有deeplink且跳转落地页非首页
        BOOL isNotHomePage = jumpModel.actionType != JumpDefalutActionType || jumpModel.actionType != JumpHomeActionType;
        if (isNotHomePage && ![NSStringUtils isEmptyString:jumpModel.url]) {
            [AccountManager sharedManager].isHadDeeplink = YES;
        }
    }
    
    // 推送
    if ([NullFilter(urlParamDic[@"source"]) isEqualToString:@"notifications"]) {
        [YWLocalHostManager tipRemoteNotificatAlertEvent];
        [self doRemotePushJumpDeepLinkAction:jumpModel analyticsDict:userInfo deeplinkType:deeplinkType];
    } else {
        if (deepLinkUrl && [NSStringUtils isEmptyString:jumpModel.url]) {
            jumpModel.url = NullFilter(deepLinkUrl);
        }
        //处理DeepLink跳转, 非Open不要穿userInfo则不要统计点击量
        [self doRemotePushJumpDeepLinkAction:jumpModel analyticsDict:nil deeplinkType:deeplinkType];
    }
    return YES;
}

/**
 * 处理推送DeepLink跳转
 */
- (void)doRemotePushJumpDeepLinkAction:(JumpModel *)jumpModel analyticsDict:(NSDictionary *)userInfo deeplinkType:(NSString *)deeplinkType
{
    //从appsflyer 进来时不是主线程，回到主线程再操作UI
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self doRemotePushJumpDeepLinkAction:jumpModel analyticsDict:userInfo deeplinkType:deeplinkType];
        });
    } else {
        // 此时应该已经创建tabbr,加个判断防止异常
        if (jumpModel.actionType != JumpDefalutActionType &&
            self.tabBarVC.viewControllers.count > 0) {
            self.isDeepLink = NO;
            
            // Deeplink 跳转
            [JumpManager doJumpActionTarget:[UIViewController currentTopViewController] withJumpModel:jumpModel];
        } else {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:jumpModel];
            NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
            [us setObject:data forKey:DeepLinkModel];
            [us synchronize];
        }
        
        //增加AppsFlyer统计
        NSDictionary *appsflyerParams = @{
                                          @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                          @"af_deeplink_url" : ZFToString(jumpModel.url),
                                          @"af_page_name" : ZFToString(deeplinkType),    // 当前页面名称
                                          @"af_first_entrance" : ZFToString(deeplinkType)  // 一级入口名
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_linkopen " withValues:appsflyerParams];
        [ZFGrowingIOAnalytics ZFGrowingIOSetEvar:@{GIOFistEvar : ZFToString(deeplinkType)}];
    }
}

@end
