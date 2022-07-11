//
//  OSSVCategoryFiltersModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/18.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCategoryFiltersModel.h"

@implementation OSSVCategoryFiltersModel

+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
//        @"order": @"order",
             @"searchAttrID": @"search_attr_id",
             @"searchAttrName": @"search_attr_name",
             @"subItemValues": @"search_values"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass
{
    return @{@"subItemValues" : [OSSVCategroySubsFilterModel class]};
}

@end
