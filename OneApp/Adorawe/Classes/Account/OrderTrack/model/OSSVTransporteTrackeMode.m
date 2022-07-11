//
//  OSSVTransporteTrackeMode.m
// XStarlinkProject
//
//  Created by Kevin on 2020/11/13.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVTransporteTrackeMode.h"


@implementation OSSVTransporteTrackeMode
+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"detail"              : @"detail",
             @"desc"                : @"desc",
             @"date"                : @"origin_time"
             };
}
// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    
    return  @[
              @"detail",
              @"desc",
              @"date"
              ];
}

@end
