//
//  CartGoodsModel.m
//  ZZZZZ
//
//  Created by 7FD75 on 16/9/19.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "CartGoodsModel.h"

@implementation CartGoodsModel

+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{
             @"goods_list"         : [CheckOutGoodListModel class],
             };
}


@end
