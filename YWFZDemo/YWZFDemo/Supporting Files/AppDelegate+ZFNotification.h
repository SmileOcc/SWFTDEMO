//
//  AppDelegate+ZFNotification.h
//  ZZZZZ
//
//  Created by YW on 2018/5/4.
//  Copyright © 2018年 YW. All rights reserved.
//
/**
 * 处理推送通知相关类
 */
#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate (ZFNotification) <UNUserNotificationCenterDelegate>

- (void)dealWithNotification:(UIApplication *)application
            launchingOptions:(NSDictionary *)launchOptions;

-(BOOL)deepLinkCallingWithURL:(NSURL *)url
                  deepLinkUrl:(NSString *)deepLinkUrl
                 deeplinkType:(NSString *)deeplinkType
           remoteNotification:(NSDictionary *)userInfo;

/**
 * 注册远程推送通知
 */
+ (void)registerZFRemoteNotification:(void(^)(NSInteger openFlag))completionBlock;

/**
 * 清除角标
 */
- (void)clearPushBadge:(UIApplication *)application;

/**
 * 点击通知不管在前后台都需要调用此方法: 统计用户收到推送的AF和点击量次数
 */
- (void)analyticsNotifyAFTapRate:(NSDictionary *)userInfo;

@end
