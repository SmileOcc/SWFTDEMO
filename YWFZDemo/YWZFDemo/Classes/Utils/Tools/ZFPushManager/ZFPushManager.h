//
//  ZFPushManager.h
//  ZZZZZ
//
//  Created by YW on 2018/8/20.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFPushManager : NSObject

/**保存显示弹窗时间戳*/
+ (void)saveShowAlertTimestamp;
/**超过间隔时间重新显示  3天*/
+ (void)canShowAlertView:(void(^)(BOOL canShow))result;

/**
 * 查询用户是否开启了推送通知
 */
+ (void)isRegisterRemoteNotification:(void(^)(BOOL isRegister))result;

/**保存显示弹窗时间戳*/
+ (void)saveShowAlertTimestampWithKey:(NSString *)key;

/**超过间隔时间重新显示 dayTime天*/
+ (BOOL)canShowAlertViewWithKey:(NSString *)key time:(NSInteger)dayTime;
@end
