//
//  ZFNativeGoodsModel.m
//  ZZZZZ
//
//  Created by YW on 25/12/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFNativeNavgationGoodsModel.h"
#import "ZFGoodsModel.h"

@implementation ZFNativeNavgationGoodsModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"goodsList"          : [ZFGoodsModel class]
             };
}


@end
