//
//  OSSVOrderInfoeModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/6.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVOrderInfoeModel.h"

@implementation OSSVOrderInfoeModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"orderSn" : @"order_sn",@"orderAmount" : @"order_amount",@"orderShippingCost" : @"order_shipping",@"orderCoupon" : @"coupon",@"goodsList" : @"good_list",};
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"goodsList" : [OSSVCartGoodsModel class]};
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[@"orderSn",@"orderAmount",@"orderShippingCost",@"orderCoupon",@"goodsList"];
}

@end
