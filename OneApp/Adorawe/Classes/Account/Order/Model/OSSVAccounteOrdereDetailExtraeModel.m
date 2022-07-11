//
//  OSSVAccounteOrdereDetailExtraeModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/26.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAccounteOrdereDetailExtraeModel.h"

@implementation OSSVAccounteOrdereDetailExtraeModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"orderAmount" : @"order_amount",
             @"orderShipping" : @"order_shipping",
             @"order_amount_new" : @"new_order_amount"
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[
             @"url",
             @"method",
             @"data",
             @"coupon",
             @"orderAmount",
             @"orderShipping",
             @"order_amount_new",
             ];
}

@end
