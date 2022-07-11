//
//  OSSVCategoryListsModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/4.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCategoryListsModel.h"
#import "OSSVCategoriyDetailsGoodListsModel.h"
#import "OSSVCategoryFiltersModel.h"

@implementation OSSVCategoryListsModel

+ (NSDictionary *)modelCustomPropertyMapper
{
    
    return @{@"pageCount": @"pageCount",
             @"goodList" : @"goodList",
             @"pageSize" : @"page_size",
             @"page"     : @"page",
             @"filteItemArray": @"filter"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass
{
    return @{@"goodList" : [OSSVCategoriyDetailsGoodListsModel class],
             @"filteItemArray": [OSSVCategoryFiltersModel class]
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist
{
    
    return @[
             @"pageCount",
             @"goodList",
             @"pageSize",
             @"page",
             @"filteItemArray"
             ];
}


@end
