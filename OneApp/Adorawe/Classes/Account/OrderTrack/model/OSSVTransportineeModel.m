//
//  OSSVTransportineeModel.m
// XStarlinkProject
//
//  Created by Kevin on 2020/11/13.
//  Copyright © 2020 starlink. All rights reserved.
//------------------运输中---------------

#import "OSSVTransportineeModel.h"
#import "OSSVTransporteTrackeMode.h"
@implementation OSSVTransportineeModel
+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"logistics_status"       : @"logistics_status",
             @"desc"                   : @"desc",
             @"date"                   : @"date",
             @"trackArray"             : @"transit_info",
             @"loc"                    : @"loc"
             };
}
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"trackArray"      : [OSSVTransporteTrackeMode class],
             };
}
// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    
    return  @[
              @"logistics_status",
              @"desc",
              @"date",
              @"trackArray",
              @"loc"
              ];
}
@end
