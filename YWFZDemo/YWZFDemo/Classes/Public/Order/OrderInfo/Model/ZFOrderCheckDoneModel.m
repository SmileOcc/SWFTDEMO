//
//  ZFOrderCheckDoneModel.m
//  ZZZZZ
//
//  Created by YW on 24/10/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderCheckDoneModel.h"
#import "ZFOrderCheckDoneDetailModel.h"

@implementation ZFOrderCheckDoneModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"order_info" : [ZFOrderCheckDoneDetailModel class]
             };
}

@end
