//
//  ZFAddressLocationModel.m
//  ZZZZZ
//
//  Created by YW on 2017/12/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFAddressLocationModel.h"
#import "ZFLocationInfoModel.h"

@implementation ZFAddressLocationModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"data"          :     [ZFLocationInfoModel class] ,
             };
}
@end
