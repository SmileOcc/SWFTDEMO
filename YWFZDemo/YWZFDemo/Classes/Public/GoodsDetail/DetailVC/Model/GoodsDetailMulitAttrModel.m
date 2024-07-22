//
//  GoodsDetailMulitAttrModel.m
//  ZZZZZ
//
//  Created by YW on 2018/11/20.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "GoodsDetailMulitAttrModel.h"

@implementation GoodsDetailMulitAttrModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"value"       : [GoodsDetailMulitAttrInfoModel class],

             };
}
@end
