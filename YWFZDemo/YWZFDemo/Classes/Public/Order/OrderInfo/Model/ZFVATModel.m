//
//  ZFVATModel.m
//  ZZZZZ
//
//  Created by YW on 2017/12/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFVATModel.h"

@implementation ZFVATModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"taxPrice" : @"tax_price",
             @"taxRate"  : @"tax_rate",
             @"tips"     : @"tips"
             };
}

@end
