//
//  OSSVSecondsCategorysModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVSecondsCategorysModel.h"

@implementation OSSVSecondsCategorysModel

+ (NSDictionary *)modelCustomPropertyMapper
{
    
    return @{@"cat_id"              : @"cat_id",
             @"cat_name"            : @"cat_name",
             @"have_child"          : @"have_child",
             @"img_addr"            : @"img_addr",
             @"child"               : @"child",
             @"recommend_img_addr"  : @"recommend_img_addr",
             @"is_op_cat"           : @"is_op_cat"
             };
}
+ (NSDictionary *)modelContainerPropertyGenericClass
{
    return @{@"child":[OSSVCatagorysChildModel class]};
}

@end
