//
//  OSSVCoinInforModel.m
// XStarlinkProject
//
//  Created by Kevin on 2021/3/18.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVCoinInforModel.h"

@implementation OSSVCoinInforModel

+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
             @"coinSave" : @"coin_save",
             @"coinText1" : @"text_1",
             @"coinText2" : @"text_2",
             @"usedCoins" : @"used_coin"

             };
}


+ (NSArray *)modelPropertyWhitelist
{
    return @[
             @"coinSave",
             @"coinText1",
             @"coinText2",
             @"usedCoins"
            ];
}

@end


