//
//  AppDelegate+STLNotification.h
// XStarlinkProject
//
//  Created by odd on 2020/7/10.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
#import <AuthenticationServices/AuthenticationServices.h>
#import "AppDelegate+STLCategory.h"
#import "SSKeychain.h"

#import "OSSWMHomeVC.h"
#import "OSSVAdvsEventsManager.h"

@interface AppDelegate (STLNotification)<UNUserNotificationCenterDelegate>

- (void)dealWithNotification:(UIApplication *)application
            launchingOptions:(NSDictionary *)launchOptions;


/**
 * 注册远程推送通知
 */
+ (void)stlRegisterRemoteNotification:(void(^)(NSInteger openFlag))completionBlock;

/**
 * 清除角标
 */
- (void)clearPushBadge:(UIApplication *)application;


//////////
#pragma mark - deepLink
//// Appflyer推广跳转处理
-(BOOL)application:(UIApplication *)application deepLinkCallingWithURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication params:(id)params;

- (void)applyDeepLinkCallingWithEventModel:(OSSVAdvsEventsModel *)OSSVAdvsEventsModel;

/////////
+ (void)checkAuthorizationStateCompleteHandler:(void(^)(BOOL authorized, NSString *msg)) completeHandler API_AVAILABLE(ios(13.0));





@end
