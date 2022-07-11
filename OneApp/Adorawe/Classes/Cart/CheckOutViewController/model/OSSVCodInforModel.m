//
//  OSSVCodInforModel.m
// XStarlinkProject
//
//  Created by Kevin on 2021/3/18.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVCodInforModel.h"

@implementation OSSVCodInforModel


+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
             @"codTextStr" : @"text",
             @"codDiscount" : @"cod_discount",
             @"codRedPrice" :@"cod_discount_red"
             };
}


+ (NSArray *)modelPropertyWhitelist
{
    return @[
             @"codTextStr",
             @"codDiscount",
             @"codRedPrice"
            ];
}

@end
