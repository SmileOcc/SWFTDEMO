//
//  ZFNativePlateGoodsModel.m
//  ZZZZZ
//
//  Created by YW on 27/12/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFNativePlateGoodsModel.h"
#import "ZFGoodsModel.h"

@implementation ZFNativePlateGoodsModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"plate_title" : @"navName",
             @"goodsArray"  : @"goodsList"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"goodsArray" : [ZFGoodsModel class],
             };
}


@end
