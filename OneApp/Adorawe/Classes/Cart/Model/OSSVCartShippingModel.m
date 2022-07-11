//
//  OSSVCartShippingModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/13.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCartShippingModel.h"

@implementation OSSVCartShippingModel
+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"sid"     : @"id",
             @"hasTrackingInfo" : @"has_tracking_info",
             @"needTraking" : @"need_traking",
             @"trackingFee" : @"tracking_fee",
             @"shipDesc"     : @"ship_desc",
             @"shipName" : @"ship_name",
             @"shipSave"     : @"ship_save",
             @"shippingFee"     : @"shipping_fee",
             @"sortOrder" : @"sort_order"
             };
}


-(BOOL)isCodShipping
{
    ///后台sid返回5的时候，是COD物流
    if (self.sid.integerValue == 5) {
        return YES;
    }
    return NO;
}

@end
