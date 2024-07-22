//
//  ZFGoodsDetailShowExploreAOP.h
//  ZZZZZ
//
//  Created by YW on 2019/6/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCMSBaseAnalyticsAOP.h"
#import "AnalyticsInjectManager.h"
#import "ZFAnalyticsInjectProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface ZFGoodsDetailShowExploreAOP : ZFCMSBaseAnalyticsAOP
<
ZFAnalyticsInjectProtocol
>

- (void)baseConfigureSource:(ZFAnalyticsAOPSource)source analyticsId:(NSString *)idx;

@end

@interface ZFGoodsDetailShowExploreSet : NSObject

+ (instancetype)sharedInstance;

- (void)addObject:(NSString *)object analyticsId:(NSString *)idx;

- (BOOL)containsObject:(NSString *)object analyticsId:(NSString *)idx;

- (void)removeObject:(NSString *)object analyticsId:(NSString *)idx;

- (void)removeAllObjectsAnalyticsId:(NSString *)idx;

@end

NS_ASSUME_NONNULL_END
