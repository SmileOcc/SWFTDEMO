//
//  ZFCarPiecingAnalyticsAOP.h
//  ZZZZZ
//
//  Created by YW on 2018/10/25.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//  凑单页统计
//  适用于 ZFCarPiecingOrderSubVC

#import <Foundation/Foundation.h>
#import "AnalyticsInjectManager.h"
#import "ZFAnalyticsInjectProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFCarPiecingAnalyticsAOP : NSObject
<
    ZFAnalyticsInjectProtocol
>

@property (nonatomic, copy) NSString *title;

@end

NS_ASSUME_NONNULL_END
