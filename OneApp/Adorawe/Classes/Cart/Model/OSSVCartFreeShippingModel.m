//
//  OSSVCartFreeShippingModel.m
// XStarlinkProject
//
//  Created by Kevin on 2021/6/9.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVCartFreeShippingModel.h"

@implementation OSSVCartFreeShippingModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"freeShipLeft"     : @"free_shipping_left",
             @"freeShipRight"    : @"free_shipping_right",
             @"specialId"        : @"special_id",
             @"amount"           : @"need_amount"

             };
}

+ (NSArray *)modelPropertyWhitelist {
    return @[@"freeShipLeft",
             @"freeShipRight",
             @"specialId",
             @"amount"];
}

@end
