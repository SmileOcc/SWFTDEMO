//
//  OSSVAnalyticSensorrs.h
// XStarlinkProject
//
//  Created by odd on 2021/2/24.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVAnalyticSensorrs : NSObject

+ (void)sensorsDynamicConfigure;

+ (void)sensorsLogEvent:(NSString *)eventName parameters:(NSDictionary *)parameters;

///强制上传
+ (void)sensorsLogEventFlush;
@end

NS_ASSUME_NONNULL_END
