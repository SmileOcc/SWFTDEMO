
//
//  ZFAddressCityModel.m
//  ZZZZZ
//
//  Created by YW on 2017/9/7.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFAddressCityModel.h"
#import "YWCFunctionTool.h"

@implementation ZFAddressCityModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"cityId"       : @"id",
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"town_list" : [ZFAddressTownModel class]
             };
}

@end



@implementation ZFAddressHintCityModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"desc"     :@"description",
             };
}
@end
