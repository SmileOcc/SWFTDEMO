//
//  CityModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/2/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "CityModel.h"

@implementation CityModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"city"   : @"city",
             @"cityId" : @"city_id",
             @"provinceId":@"province_id",
             @"area"   :   @"area"};
}

+ (NSDictionary *)modelContainerPropertyGenericClass
{
    return @{@"area" : [STLVillageModel class]};
}


+ (NSArray *)modelPropertyWhitelist {
    return @[@"city",
             @"cityId",
             @"provinceId",
             @"area"];
}

@end
