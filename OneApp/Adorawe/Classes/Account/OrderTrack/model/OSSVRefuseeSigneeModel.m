//
//  OSSVRefuseeSigneeModel.m
// XStarlinkProject
//
//  Created by Kevin on 2020/12/2.
//  Copyright © 2020 starlink. All rights reserved.
//  拒绝签收

#import "OSSVRefuseeSigneeModel.h"

@implementation OSSVRefuseeSigneeModel
+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"status"              : @"logistics_status",
             @"desc"                : @"desc",
             @"date"                : @"refused_time"
             };
}
// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    
    return  @[
              @"status",
              @"desc",
              @"date"
              ];
}
@end
