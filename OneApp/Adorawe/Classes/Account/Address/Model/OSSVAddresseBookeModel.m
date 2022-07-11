

//
//  AddressListModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/6.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAddresseBookeModel.h"

@implementation OSSVAddresseBookeModel

+ (NSDictionary *)modelCustomPropertyMapper {
    ///phone_head  phone second_phone_head second_phone
    return @{
             @"addressId"               : @"address_id",
             @"cityId"                  : @"city_id",
             @"stateId"                 : @"state_id",
             @"city"                    : @"city",
             @"country"                 : @"country",
             @"district"                : @"district",
             @"countryId"               : @"country_id",
             @"email"                   : @"email",
             @"firstName"               : @"first_name",
             @"lastName"                : @"last_name",
             @"phone"                   : @"phone",
             @"state"                   : @"state",
             @"zipPostNumber"           : @"zip",
             @"isDefault"               : @"is_default",
             @"street"                  : @"street",
             @"streetMore"              : @"streetmore",
             @"isPaypal"                : @"is_paypal",
             @"countryCode"             : @"code",
             @"phoneHead"               : @"phone_head",
             @"secondPhoneHead"         : @"second_phone_head",
             @"secondPhone"             : @"second_phone",
             @"phoneHeadArr"            : @"phone_head_arr",
             @"latitude"                : @"latitude",
             @"longitude"               : @"longitude",
             @"idCard"                  : @"id_card",
             @"addressType"             : @"address_type",
             @"country_Code"            : @"code_name",
             
             @"has_citys"               : @"has_citys",
             @"user_id"                 : @"user_id",
             @"phone_remain_length"     : @"phone_remain_length",
             @"area"                    : @"area",
             @"area_id"                 : @"area_id",
             @"need_zip_code"           : @"need_zip_code",
             @"map_check"               : @"map_check"
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    
    return  @[
              @"addressId" ,
              @"city" ,
              @"country",
              @"district",
              @"cityId",
              @"stateId",
              @"countryId",
              @"email" ,
              @"firstName",
              @"lastName",
              @"phone",
              @"state",
              @"street",
              @"streetMore",
              @"zipPostNumber",
              @"isDefault",
              @"isPaypal",
              @"province",
              @"countryCode",
              @"phoneHead",
              @"secondPhoneHead",
              @"secondPhone",
              @"phoneHeadArr",
              @"latitude",
              @"longitude",
              @"idCard",
              @"addressType",
              @"country_Code",
                           
              @"has_citys",
              @"user_id",
              @"phone_remain_length",
              @"area",
              @"area_id",
              @"need_zip_code",
              @"map_check"
              ];
}


@end
