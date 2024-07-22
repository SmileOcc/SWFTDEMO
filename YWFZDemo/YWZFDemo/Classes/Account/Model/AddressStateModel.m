//
//  AddressStateModel.m
//  ZZZZZ
//
//  Created by YW on 2017/4/27.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "AddressStateModel.h"

@implementation AddressStateModel
+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"provinceName"     :@"name",
             @"provinceId"       :@"id",
             @"is_city"          :@"is_city"
             };
}
@end
