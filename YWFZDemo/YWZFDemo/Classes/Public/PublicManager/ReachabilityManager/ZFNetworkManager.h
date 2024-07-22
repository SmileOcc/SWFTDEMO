//
//  ZFNetworkManager.h
//  ZZZZZ
//
//  Created by YW on 2017/9/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworkReachabilityManager.h"

@interface ZFNetworkManager : NSObject

/**
 监听网络改变回调
 
 @param block   网络状态改变回调,
 currentStatus: 当前状态,
 lastStatus:    改变前的网络状态
 */
+ (void)reachabilityChangeBlock:(void (^)(AFNetworkReachabilityStatus currentStatus, AFNetworkReachabilityStatus beforeStatus))block;

/**
 *  网络是否可用
 */
+ (BOOL)isReachable;

/**
 *  是否为手机运营商网络
 */
+ (BOOL)isReachableViaWWAN;

/**
 *  是否为WIFI网络
 */
+ (BOOL)isReachableViaWiFi;

@end
