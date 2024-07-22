//
//  AppDelegate+ZFThirdLibrary.h
//  ZZZZZ
//
//  Created by YW on 2018/5/4.
//  Copyright © 2018年 YW. All rights reserved.
//
/**
 * 处理初始化必要第三方库相关类
 */

#import "AppDelegate.h"

@interface AppDelegate (ZFThirdLibrary)

/**
 * 启动首先初始化崩溃检测
 */
- (void)initConfigBugly;

/**
 配置BrainKeeper
 */
- (void)configBrainKeeper;

/**
 GA 代码统计设置，切换语言需要重置
 */
- (void)configurGAI;

/**
 * 处理程序进入前台
 */
- (void)dealwithApplicationBecomeActive;

/**
 * 初始化一些第三方库
 */
-(void)initThirdPartObjectsWithOptions:(NSDictionary *)launchOptions
                           application:(UIApplication *)application;

/**
 * 处理openURL打开应用跳转
 */
- (BOOL)dealwithSchemeApplication:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options;

/**
 * Reports app open from a Universal Link for iOS 9
 */
- (void)dealwithAppsFlyerUserActivity:(UIApplication *)application
                 continueUserActivity:(NSUserActivity *)userActivity
                   restorationHandler:(void (^)(NSArray *_Nullable))restorationHandler;
@end
