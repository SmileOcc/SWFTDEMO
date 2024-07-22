//
//  ZFAnalyticsQueueManager.h
//  ZZZZZ
//
//  Created by YW on 2019/6/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFAnalyticsOperation.h"

typedef NS_ENUM(NSInteger) {
    ZFAnalyticsQueueUploadType_TEST,      ///测试环境，实时上传
    ZFAnalyticsQueueUploadType_Release,
    ZFAnalyticsQueueUploadType_Union
} ZFAnalyticsQueueUploadType;

@interface ZFAnalyticsQueueManager : NSObject

+ (void)asyncAnalyticsEvent:(NSString *)event withValues:(NSDictionary *)values;

@end
