//
//  STLPushManager.m
// XStarlinkProject
//
//  Created by odd on 2020/8/14.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "STLPushManager.h"
#import <UserNotifications/UserNotifications.h>
#import "OSSVNSStringTool.h"
#import "STLCFunctionTool.h"
#import "Adorawe-Swift.h"

#define STLALertPushMessageTag  (12712020)


@implementation STLPushManager

+(instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static STLPushManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[STLPushManager alloc] init];
    });
    return manager;
}

/**保存显示弹窗时间戳*/
+ (void)saveShowAlertTimestamp {
    NSString *timestamp = [OSSVNSStringTool getCurrentTimestamp];
    STLUserDefaultsSet(kShowNotificationAlertTimestamp, timestamp);
    STLLog(@"&&&&&&&&🐻🐻🐻🐻🐻🐻推送时间戳：%@",timestamp);
}

/**超过间隔时间重新显示 3天*/
+ (void)canShowAlertView:(void(^)(BOOL canShow))result {
    
    [STLPushManager isRegisterRemoteNotification:^(BOOL isRegister) {
        if (isRegister) {
            STLLog(@"&&&&&&&&🐻🐻🐻🐻🐻🐻推送已开启");
            result(NO);
        } else {
            
            NSString *lastTimesTamp = STLUserDefaultsGet(kShowNotificationAlertTimestamp);
            NSString *currentTimesTamp = [OSSVNSStringTool getCurrentTimestamp];

            STLLog(@"&&&&&&&&🐻🐻🐻🐻🐻🐻推送时间间隔：%li",[currentTimesTamp integerValue] - [lastTimesTamp integerValue]);
            if ([currentTimesTamp integerValue] - [lastTimesTamp integerValue] >= sec_per_day * 3) {
                //不能在这保存时间，有些地方只做显示处理
                result(YES);
            } else {
                result(NO);
            }
        }
    }];
}

+(BOOL)isPopPushViewWhenAppLanuch
{
    //只会弹一次
    NSUserDefaults *UD = [NSUserDefaults standardUserDefaults];
    NSString *isPop = [UD objectForKey:@"STLonePopPushView"];
    if (!isPop) {
        STLUserDefaultsSet(@"STLonePopPushView", @"YES");
        return YES;
    }
    return NO;
}

#pragma mark - 查询用户是否开启了推送通知
+ (void)isRegisterRemoteNotification:(void(^)(BOOL isRegister))result
{
    __block BOOL enabled = NO;
    dispatch_semaphore_t sem;
    sem = dispatch_semaphore_create(0);
    
    STLLog(@"通知状态:==== kkkkkkkkk");
    
    UNUserNotificationCenter *notificationCenter=[UNUserNotificationCenter currentNotificationCenter];
    [notificationCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        STLLog(@"通知状态:==== %li",(long)settings.authorizationStatus);
        switch (settings.authorizationStatus) {
            case UNAuthorizationStatusAuthorized:
                enabled = YES;
                break;
            default:
                break;
        }
        dispatch_semaphore_signal(sem);
    }];
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER); //获取通知设置的过程是异步的，这里需要等待
    STLLog(@"通知状态 是否开启了推送通知 ：%i",enabled);
    if (result) {
        result (enabled);
    }
}

+ (BOOL)isShowPushTipsView
{
    BOOL isPopAlert = [STLUserDefaultsGet(kHadShowSystemNotificationAlert) boolValue];
    __block BOOL isRegisterflag = NO;
    //同步的
    [STLPushManager isRegisterRemoteNotification:^(BOOL isRegister) {
        isRegisterflag = isRegister;
    }];
    return isPopAlert && !isRegisterflag;
}

#pragma mark - 个人中心推送
/**保存显示弹窗时间戳*/
+ (void)saveShowAlertTimestampWithKey:(NSString *)key {
    NSString *timestamp = [OSSVNSStringTool getCurrentTimestamp];
    STLUserDefaultsSet(STLToString(key), timestamp);
}

/**超过间隔时间重新显示 dayTime天*/
+ (BOOL)canShowAlertViewWithKey:(NSString *)key time:(NSInteger)dayTime {
    BOOL show = NO;
    if ([self isShowPushTipsView]) {
        NSString *lastTimesTamp = STLUserDefaultsGet(STLToString(key));
        NSString *currentTimesTamp = [OSSVNSStringTool getCurrentTimestamp];
        if ([currentTimesTamp integerValue] - [lastTimesTamp integerValue] >= sec_per_day * dayTime) {
//        if ([currentTimesTamp integerValue] - [lastTimesTamp integerValue] >= 30) {
            show = YES;
        }
    }
    return show;
}


+ (void)showPushTipMessage:(NSString *)title message:(NSString *)msg hours:(NSString *)hours{
    
    NSString *lastTimesTamp = STLUserDefaultsGet(kShowAppNotificationAlertTimestamp);
    NSString *currentTimesTamp = [OSSVNSStringTool getCurrentTimestamp];
    
    CGFloat hoursF = [STLToString(hours) floatValue];
    NSInteger tiemLength = [currentTimesTamp integerValue] - [lastTimesTamp integerValue];
    if (tiemLength >= sec_per_hour * hoursF) {

        if (![OSSVAdvsViewsManager sharedManager].isUpdateApp) {
            
            NSString *timestamp = [OSSVNSStringTool getCurrentTimestamp];
            STLUserDefaultsSet(kShowAppNotificationAlertTimestamp, timestamp);
            STLLog(@"&&&&&&&&🐻🐻🐻🐻🐻🐻app推送弹窗时间戳：%@",timestamp);
            
            OSSVAlertsViewNew *alertTipView = [[OSSVAlertsViewNew alloc] initWithFrame:[UIScreen mainScreen].bounds alertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:1 title:@"" message:STLToString(msg) buttonTitles:@[STLLocalizedString_(@"later",nil).uppercaseString,STLLocalizedString_(@"open", nil).uppercaseString] buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
                
                if (index == 1) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                }
                
            } closeBlock:nil];
            alertTipView.tag = STLALertPushMessageTag;

            
        } else {
            STLLog(@"======== 通知 强制更新中 ");
        }
    }
}

+ (void)jundgePushViewToTop {
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    for (UIView *windowSubView in window.subviews) {
        if ([windowSubView isKindOfClass:[OSSVAlertsViewNew class]]) {
            
            if (windowSubView.tag == STLALertPushMessageTag) {
                [window bringSubviewToFront:windowSubView];
            } else {
                [windowSubView removeFromSuperview];
            }
            break;
        }
    }
}

+ (void)jundgePushViewRemove {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    for (UIView *windowSubView in window.subviews) {
        if ([windowSubView isKindOfClass:[OSSVAlertsViewNew class]]) {
            [windowSubView removeFromSuperview];
            break;
        }
    }
}
@end
