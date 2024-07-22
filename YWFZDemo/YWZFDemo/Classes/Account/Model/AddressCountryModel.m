//
//  AddressCountryModel.m
//  Dezzal
//
//  Created by 7FD75 on 16/8/12.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import "AddressCountryModel.h"

@implementation AddressCountryModel
// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    
    return @[
             @"region_code",
             @"region_id",
             @"region_name",
             @"code",
             @"supplier_number_list",
             @"number",
             @"is_state",
             @"configured_number"
             ];
}
@end
