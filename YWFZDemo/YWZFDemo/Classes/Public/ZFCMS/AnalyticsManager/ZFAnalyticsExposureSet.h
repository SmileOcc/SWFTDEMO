//
//  ZFAnalyticsExposureSet.h
//  ZZZZZ
//
//  Created by YW on 2019/6/20.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFAnalyticsExposureSet : NSObject

/// 原生专题统计去重数组
@property (nonatomic, strong) NSMutableArray *nativeThemeAnalyticsArray;

+ (instancetype)sharedInstance;

- (void)addObject:(NSString *)object analyticsId:(NSString *)idx;

- (BOOL)containsObject:(NSString *)object analyticsId:(NSString *)idx;

- (void)removeObject:(NSString *)object analyticsId:(NSString *)idx;

- (void)removeAllObjectsAnalyticsId:(NSString *)idx;

- (void)removeAllObjects;
@end

NS_ASSUME_NONNULL_END
