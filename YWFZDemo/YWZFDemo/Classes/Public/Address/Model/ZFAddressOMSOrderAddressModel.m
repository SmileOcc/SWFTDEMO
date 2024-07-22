//
//  ZFAddressOMSOrderAddressModel.m
//  ZZZZZ
//
//  Created by YW on 2019/6/21.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAddressOMSOrderAddressModel.h"

@implementation ZFAddressOMSOrderAddressModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"countryList"          :     [ZFAddressOMSOrderAddressDataModel class] ,
             };
}

@end



@implementation ZFAddressOMSOrderAddressDataModel

@end
