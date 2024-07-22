//
//  ZFOrderCouponModel.m
//  ZZZZZ
//
//  Created by YW on 2017/12/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderCouponModel.h"
#import "ZFMyCouponModel.h"

@implementation ZFOrderCouponModel

+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{
             @"available" : [ZFMyCouponModel class],
             @"disabled": [ZFMyCouponModel class]
             };
}

@end
