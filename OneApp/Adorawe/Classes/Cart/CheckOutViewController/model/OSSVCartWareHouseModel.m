//
//  OSSVCartWareHouseModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/14.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCartWareHouseModel.h"

@implementation OSSVCartWareHouseModel

+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
             @"wid" : @"wid",
             @"subtotal" : @"subtotal",
             @"activeSave" : @"active_save",
             @"couponSave" : @"coupon_save",
             @"insurance" : @"insurance",
             @"shippingCost" : @"shipping_cost",
             @"codCost" : @"cod_cost",
             @"isShowSubtotal" : @"is_show_subtotal",
             @"goodsList" : @"goods_list",
             @"pointSave" : @"point_save",
             @"disCountSave" : @"pay_discount_save"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass
{
    return @{
             @"goodsList" : [OSSVCartGoodsModel class],
             };
}

+ (NSArray *)modelPropertyWhitelist
{
    return @[
             @"wid",
             @"subtotal",
             @"activeSave",
             @"couponSave",
             @"insurance",
             @"shippingCost",
             @"codCost",
             @"isShowSubtotal",
             @"goodsList",
             @"pointSave",
             @"disCountSave"
             ];
}

@end
