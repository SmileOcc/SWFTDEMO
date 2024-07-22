//
//  ZFCheckShippingAddressModel.m
//  ZZZZZ
//
//  Created by YW on 2018/12/22.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFCheckShippingAddressModel.h"

@implementation ZFCheckShippingAddressItemModel

@end



@implementation ZFCheckShippingAddressModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"original_address"     : [ZFCheckShippingAddressItemModel class],
             @"suggested_address"    : [ZFCheckShippingAddressItemModel class]
             };
}
@end



