//
//  AppDelegate+STLThirdLibrary.h
// XStarlinkProject
//
//  Created by odd on 2020/7/10.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "AppDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate (STLThirdLibrary)


-(void)initThirdPartObjectsWithOptions:(NSDictionary *)launchOptions application:(UIApplication *)application;

- (BOOL)stl_application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options;

- (void)stl_application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray * __nullable restorableObjects))restorationHandler;

/**
 * 配置 神策
 */
- (void)configurAppsSensors:(NSDictionary *)launchOptions;

- (void)configurAppsFlyer:(NSDictionary *)launchOptions;

- (void)configurFireBase;

/**
 * 在层序进入前台时,重新初始化AppsFlyer
 */
- (void)dealwithApplicationBecomeActive;


/**
* AppsFlyer:设置customerID
*/
+ (void)appsFlyerTracekerCustomerUserID;
@end

NS_ASSUME_NONNULL_END
