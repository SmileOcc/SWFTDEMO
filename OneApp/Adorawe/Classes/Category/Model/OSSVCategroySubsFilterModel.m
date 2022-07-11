//
//  OSSVCategroySubsFilterModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/18.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCategroySubsFilterModel.h"

@implementation OSSVCategroySubsFilterModel

+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
//        @"order": @"order",
             @"searchValueID": @"search_value_id",
             @"searchValue": @"search_value",
             @"isSelected": @"selected"
             };
}

@end
