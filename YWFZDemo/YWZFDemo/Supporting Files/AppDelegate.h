//
//  AppDelegate.h
//  ZZZZZ
//
//  Created by YW on 18/9/13.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFTabBarController.h"
@class MyOrdersModel;

typedef NS_ENUM(NSUInteger, AppForceOrientation) {
    AppForceOrientationPortrait,
    AppForceOrientationLandscape,
    AppForceOrientationJustOnceLandscape,
    AppForceOrientationALL,
};

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow              *window;
@property (nonatomic, strong) ZFTabBarController    *tabBarVC;
@property (nonatomic, assign) BOOL                  isDeepLink;         /// 是否要深度跳转
@property (nonatomic, strong) MyOrdersModel         *unpaidOrderModel;  /// 保存未支付的订单模型
@property (nonatomic, assign) NSInteger             allowRotation;

@property (assign , nonatomic) AppForceOrientation  forceOrientation;

/// 浮窗广告只能在主页的控制器上弹出
+ (BOOL)judgeCurrentIsHomeNavVC;

/// 显示首页浮窗广告
+ (void)judgeShowHomeFloatView;

/// 切换语言时需要重置
- (void)initAppRootVC;
    
@end

