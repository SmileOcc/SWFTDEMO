//
//  OSSVCategorysSectionsModel.m
// XStarlinkProject
//
//  Created by odd on 2020/9/29.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVCategorysSectionsModel.h"

@implementation OSSVCategorysSectionsModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"child_item" : [OSSVCategoryFiltersModel class]
            };
}

@end
