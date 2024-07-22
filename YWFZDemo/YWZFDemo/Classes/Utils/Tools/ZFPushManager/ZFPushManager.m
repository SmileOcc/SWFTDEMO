//
//  ZFPushManager.m
//  ZZZZZ
//
//  Created by YW on 2018/8/20.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFPushManager.h"
#import <UserNotifications/UserNotifications.h>
#import "NSStringUtils.h"
#import "Constants.h"
#import "YWCFunctionTool.h"

@implementation ZFPushManager

/**保存显示弹窗时间戳*/
+ (void)saveShowAlertTimestamp {
    NSString *timestamp = [NSStringUtils getCurrentTimestamp];
    SaveUserDefault(kShowNotificationAlertTimestamp, timestamp);
    YWLog(@"&&&&&&&&🐔🐔🐔🐔🐔🐔🐔🐔🐔🐔推送时间戳：%@",timestamp)
}

/**超过间隔时间重新显示 3天*/
+ (void)canShowAlertView:(void(^)(BOOL canShow))result {
    
    [ZFPushManager isRegisterRemoteNotification:^(BOOL isRegister) {
        if (isRegister) {
            YWLog(@"&&&&&&&&🐔🐔🐔🐔🐔🐔🐔🐔🐔🐔推送已开启");
            result(NO);
        } else {
            
            NSString *lastTimesTamp = GetUserDefault(kShowNotificationAlertTimestamp);
            NSString *currentTimesTamp = [NSStringUtils getCurrentTimestamp];

            YWLog(@"&&&&&&&&🐔🐔🐔🐔🐔🐔🐔🐔🐔🐔推送时间间隔：%li",[currentTimesTamp integerValue] - [lastTimesTamp integerValue]);
            if ([currentTimesTamp integerValue] - [lastTimesTamp integerValue] >= sec_per_day * 3) {
                //不能在这保存时间，有些地方只做显示处理
                result(YES);
            } else {
                result(NO);
            }
        }
    }];
}

#pragma mark - 查询用户是否开启了推送通知
+ (void)isRegisterRemoteNotification:(void(^)(BOOL isRegister))result
{
    if (result) {
        result ([UIApplication sharedApplication].isRegisteredForRemoteNotifications);
    }
}

+ (BOOL)isShowPushTipsView
{
    BOOL isPopAlert = [GetUserDefault(kHasShowSystemNotificationAlert) boolValue];
    return isPopAlert && ![UIApplication sharedApplication].isRegisteredForRemoteNotifications;
}

#pragma mark - 个人中心推送
/**保存显示弹窗时间戳*/
+ (void)saveShowAlertTimestampWithKey:(NSString *)key {
    NSString *timestamp = [NSStringUtils getCurrentTimestamp];
    SaveUserDefault(ZFToString(key), timestamp);
}

/**超过间隔时间重新显示 dayTime天*/
+ (BOOL)canShowAlertViewWithKey:(NSString *)key time:(NSInteger)dayTime {
    BOOL show = NO;
    if ([self isShowPushTipsView]) {
        NSString *lastTimesTamp = GetUserDefault(ZFToString(key));
        NSString *currentTimesTamp = [NSStringUtils getCurrentTimestamp];
        if ([currentTimesTamp integerValue] - [lastTimesTamp integerValue] >= sec_per_day * dayTime) {
//        if ([currentTimesTamp integerValue] - [lastTimesTamp integerValue] >= 30) {
            show = YES;
        }
    }
    return show;
}
@end
