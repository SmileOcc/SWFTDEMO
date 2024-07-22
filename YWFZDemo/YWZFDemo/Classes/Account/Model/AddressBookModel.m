//
//  AddressListModel.m
//  Yoshop
//
//  Created by Qiu on 16/6/6.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "AddressBookModel.h"
@implementation AddressBookModel
// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[
             @"address_id",
             @"is_default",
             @"user_id",
             @"firstname",
             @"lastname",
             @"id_card",
             @"email",
             @"tel",
             @"country_id",
             @"country_str",
             @"ownState",
             @"province_id",
             @"province",
             @"ownCity",
             @"city",
             @"addressline1",
             @"addressline2",
             @"supplier_number_list",
             @"supplier_number",
             @"number",
             @"zipcode",
             @"code",
             @"configured_number"
//             @"country_code"
             ];
}
@end
