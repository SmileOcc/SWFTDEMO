//
//  ZFAnalyticsTimeManager.h
//  ZZZZZ
//
//  Created by YW on 2016/12/19.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ZFRequestTime) {
    ZFRequestTimeBegin,
    ZFRequestTimeEnd
};

@interface ZFAnalyticsTimeManager : NSObject
@property (nonatomic,strong) NSMutableDictionary *recodeTimeDict;

+ (ZFAnalyticsTimeManager *)sharedManager;

- (void)logTimeWithEventName:(NSString*)name;

/**
 统计某个请求的耗时

 @param requestStatus Request Successful/Request Failure
 @param requestAction 请求action
 @param requestTime 开始还是结束
 */
- (void)requestTimeWithRequestStatus:(NSString *)requestStatus requestAction:(NSString *)requestAction requestTime:(ZFRequestTime)requestTime;
- (void)requestSuccessTimeWithRequestAction:(NSString *)requestAction requestTime:(ZFRequestTime)requestTime;


+ (void)recordRequestStartTime:(NSString *)requestURL;
+ (void)recordRequestEndTime:(NSString *)requestURL;

@end
