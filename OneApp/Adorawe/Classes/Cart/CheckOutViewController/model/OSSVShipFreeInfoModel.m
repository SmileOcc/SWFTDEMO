//
//  OSSVShipFreeInfoModel.m
// XStarlinkProject
//
//  Created by Kevin on 2021/3/18.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVShipFreeInfoModel.h"

@implementation OSSVShipFreeInfoModel

+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
             @"shipFreeTextStr" : @"text",
             @"shipFreeDiscount" : @"cod_discount",
             @"shipFreeRedPrice" :@"cod_discount_red"
             };
}


+ (NSArray *)modelPropertyWhitelist
{
    return @[
             @"shipFreeTextStr",
             @"shipFreeDiscount",
             @"shipFreeRedPrice"
            ];
}
@end
