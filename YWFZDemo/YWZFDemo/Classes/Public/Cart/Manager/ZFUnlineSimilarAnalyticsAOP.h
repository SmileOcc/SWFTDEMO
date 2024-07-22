//
//  ZFUnlineSimilarAnalyticsAOP.h
//  ZZZZZ
//
//  Created by YW on 2019/5/27.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFAnalyticsInjectProtocol.h"
#import "ZFAppsflyerAnalytics.h"
#import "ZFGoodsModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFUnlineSimilarAnalyticsAOP : NSObject
<
ZFAnalyticsInjectProtocol
>

-(instancetype)init;

@property (nonatomic, copy) NSString *page;
// 统计参数
@property (nonatomic, assign) ZFAppsflyerInSourceType sourceType;

@end

NS_ASSUME_NONNULL_END
