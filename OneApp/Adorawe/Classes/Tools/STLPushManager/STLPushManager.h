//
//  STLPushManager.h
// XStarlinkProject
//
//  Created by odd on 2020/8/14.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface STLPushManager : NSObject


+(instancetype)sharedInstance;

///每次APP打开提示推送弹窗信息
@property (nonatomic, copy) NSString *pushShowAlertStatus;
@property (nonatomic, copy) NSString *pushShowAlertHours;
@property (nonatomic, copy) NSString *pushShowAlertContent;
//注册banner文案
@property (nonatomic, copy) NSString *tip_reg_page_text;
//个人用户页面文案
@property (nonatomic, copy) NSString *tip_user_page_text;

@property (nonatomic, assign) BOOL  pushShowAlertHasRequest;



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

+(BOOL)isPopPushViewWhenAppLanuch;

+ (BOOL)isShowPushTipsView;


+ (void)showPushTipMessage:(NSString *)title message:(NSString *)msg hours:(NSString *)hours;
+ (void)jundgePushViewToTop;
+ (void)jundgePushViewRemove;
@end

NS_ASSUME_NONNULL_END
