//
//  ZFCartRecommendAnalyticsAOP.h
//  ZZZZZ
//
//  Created by YW on 2018/12/19.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//  购物车推荐商品AOP

#import <Foundation/Foundation.h>
#import "AnalyticsInjectManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    RecommendPageNullCart,
    RecommendPageCart,
    RecommendPagePaysuccessView,
} RecommendPage;

@interface ZFCartRecommendAnalyticsAOP : NSObject
<
    ZFAnalyticsInjectProtocol
>

///数据来源 默认为ZFAppsflyerInSourceTypeCarRecommend
@property (nonatomic, assign) ZFAppsflyerInSourceType sourceType;

@property (nonatomic, assign) RecommendPage aopTpye;

@end

NS_ASSUME_NONNULL_END
