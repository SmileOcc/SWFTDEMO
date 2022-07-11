//
//  OSSVHomeOrdersWarnModel.m
// OSSVHomeOrdersWarnModel
//
//  Created by 10010 on 20/10/29.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVHomeOrdersWarnModel.h"
#import "OSSVOrdersWarnsGoodInfoModel.h"
#import "OSSVOrdersWarnsCountrysInfoModel.h"

@implementation OSSVHomeOrdersWarnModel

+ (NSDictionary *)modelContainerPropertyGenericClass
{
    return @{
             @"goodsInfo" : [OSSVOrdersWarnsGoodInfoModel class],
             @"countryInfo" : [OSSVOrdersWarnsCountrysInfoModel class]
             };
}


@end
