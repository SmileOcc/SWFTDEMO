//
//  OSSVCategorysModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCategorysModel.h"
#import "OSSVAdvsEventsModel.h"
#import "OSSVSecondsCategorysModel.h"

@implementation OSSVCategorysModel

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{@"category" : @"category",
             @"guide"    : @"guide",
             @"banner"   : @"banner",
             @"cat_id"   : @"cat_id",
             @"title"    : @"title",
             @"link"    : @"link"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"category" : [OSSVSecondsCategorysModel class],
             @"guide"    : [OSSVAdvsEventsModel class],
             @"banner"   : [OSSVAdvsEventsModel class]
             };
}

+ (NSArray *)modelPropertyWhitelist {
    
    return @[@"category",
             @"guide",
             @"banner",
             @"cat_id",
             @"title",
             @"link"
             ];
}

@end
