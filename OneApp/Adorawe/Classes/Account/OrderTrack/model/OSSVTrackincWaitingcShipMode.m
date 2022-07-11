//
//  OSSVTrackincWaitingcShipMode.m
// XStarlinkProject
//
//  Created by Kevin on 2020/11/13.
//  Copyright © 2020 starlink. All rights reserved.
// -----------待发货------------

#import "OSSVTrackincWaitingcShipMode.h"

@implementation OSSVTrackincWaitingcShipMode
+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"logistics_status"       : @"logistics_status",
             @"desc"                   : @"desc",
             @"date"               : @"pay_time"
             };
}
// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    
    return  @[
              @"logistics_status",
              @"desc",
              @"date"
              ];
}

@end
