//
//  OSSVTrackingcInformationcModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/6.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVTrackingcInformationcModel.h"

@implementation OSSVTrackingcInformationcModel


+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"goodList"                    : @"goods_list",
             @"shippingName"                : @"shipping_name",
             @"shippingNumber"              : @"shipping_no",
             @"tracking_detail"             : @"tracking_detail"
             };
}
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"goodList"                    : [OSSVTrackingcGoodListcModel class],
             @"tracking_detail"             : [OSSVTrackingcMessagecModel class]
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    
    return  @[
              @"goodList",
              @"shippingName",
              @"shippingNumber",
              @"tracking_detail"
              ];
}



@end
