//
//  GoodsDetailSizeColorModel.m
//  ZZZZZ
//
//  Created by ZJ1620 on 16/9/19.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "GoodsDetailSizeColorModel.h"

@implementation GoodsDetailSizeColorModel

+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
        @"size"  : @"size",
        @"color" : @"color",
    };
}
+ (NSDictionary *)modelContainerPropertyGenericClass
{
    return @{
             @"size"   : [GoodsDetialSizeModel class],
             @"color"  : [GoodsDetialColorModel class]
             };
}
// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist
{
    return @[
            @"size",
            @"color",
    ];
}

@end

