//
//  CartCodModel.m
//  ZZZZZ
//
//  Created by YW on 24/8/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "CartCodModel.h"

@implementation CartCodModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"totalMax"   : @"max",
             @"totalMin"   : @"min",
             @"codFee"     : @"fee"
             };
}

@end
