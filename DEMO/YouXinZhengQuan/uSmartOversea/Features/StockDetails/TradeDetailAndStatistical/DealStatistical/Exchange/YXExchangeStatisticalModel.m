//
//  YXExchangeStatisticalModel.m
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2022/1/14.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

#import "YXExchangeStatisticalModel.h"

@implementation YXExchangeStatisticalSubModel

@end


@implementation YXExchangeStatisticalModel

+ (NSDictionary *)modelContainerPropertyGenericClass{
    
    return @{
             @"exchangeData": [YXExchangeStatisticalSubModel class]
             };
    
}

@end
