//
//  OSSVCategorysFiltersNewModel.m
// XStarlinkProject
//
//  Created by odd on 2021/4/15.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVCategorysFiltersNewModel.h"

@implementation OSSVCategorysFiltersNewModel

+ (NSDictionary *)modelContainerPropertyGenericClass
{
    return @{@"values" : [STLCategoryFilterValueModel class]};
}

@end


@implementation STLCategoryFilterValueModel

+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{@"idx": @"id"};
}
@end


@implementation STLCategoryFilterExpandValueModel

@end
