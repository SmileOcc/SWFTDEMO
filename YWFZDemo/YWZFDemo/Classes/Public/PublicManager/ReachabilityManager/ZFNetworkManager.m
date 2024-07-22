//
//  ZFNetworkManager.m
//  ZZZZZ
//
//  Created by YW on 2017/9/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFNetworkManager.h"
#import <objc/runtime.h>
#import "ZFNotificationDefiner.h"

/** 记住上一次的网络状态key */
static char const * const kRememberReachabilityStatusKey = "kRememberReachabilityStatusKey";

@implementation ZFNetworkManager

//+ (void)load {
//    //开始监听网络
//    [self startMonitoringZFReachability];
//}

///2018年12月05日11:38:26 替换load方法，优化main函数之前的启动时间
+(void)initialize
{
    //开始监听网络
    [self startMonitoringZFReachability];
}

/**
 *  开始监听网络状态
 */
+ (void)startMonitoringZFReachability {
    AFNetworkReachabilityManager *reachManager = [AFNetworkReachabilityManager sharedManager];
    [reachManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        //1.记住改变网络后的网络状态
        objc_setAssociatedObject([AFNetworkReachabilityManager sharedManager], kRememberReachabilityStatusKey, @(status), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        //2.如果其他地方需要监听网络,可以发通知
        [[NSNotificationCenter defaultCenter] postNotificationName:kNetWorkStatusChangeNotification object:nil];
    }];
    [reachManager startMonitoring];
}

/**
 *  监听网络改变回调
 */
+ (void)reachabilityChangeBlock:(void (^)(AFNetworkReachabilityStatus currentStatus, AFNetworkReachabilityStatus beforeStatus))block {
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
        id obj = objc_getAssociatedObject(manager, kRememberReachabilityStatusKey);
        if (obj) {
            AFNetworkReachabilityStatus oldStatus = [obj integerValue];
            if (block) {
                block(status,oldStatus);
            }
        } else {
            if (block) {
                block(status,AFNetworkReachabilityStatusUnknown);
            }
        }
        //记住改变网络后的网络状态
        objc_setAssociatedObject(manager, kRememberReachabilityStatusKey, @(status), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }];
}

/**
 *  网络是否可用
 */
+ (BOOL)isReachable  {
    BOOL reachable = [AFNetworkReachabilityManager sharedManager].isReachable;
    return reachable;
}

/**
 *  是否为手机运营商网络
 */
+ (BOOL)isReachableViaWWAN {
    BOOL isWWAN = [AFNetworkReachabilityManager sharedManager].isReachableViaWWAN;
    return isWWAN;
}

/**
 *  是否WIFI网络
 */
+ (BOOL)isReachableViaWiFi {
    BOOL isWiFi = [AFNetworkReachabilityManager sharedManager].isReachableViaWiFi;
    return isWiFi;
}

@end

