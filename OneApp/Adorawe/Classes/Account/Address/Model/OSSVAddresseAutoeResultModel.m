//
//  OSSVAddresseAutoeResultModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAddresseAutoeResultModel.h"

@implementation OSSVAddresseAutoeResultModel

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"desc"        : @"description",
             @"place_id"    : @"place_id",
             @"highlight"   : @"highlight"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"highlight"    : [STLAddressHighlightItem class]
             };
}


+ (NSArray *)modelPropertyWhitelist {
    
    return @[
             @"desc",
             @"place_id",
             @"highlight"
             ];
}

@end


@implementation STLAddressHighlightItem


+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"length"               : @"length",
             @"offset"                  : @"offset"
             };
}

+ (NSArray *)modelPropertyWhitelist {
    
    return  @[
              @"length",
              @"offset",
              ];
}

@end
