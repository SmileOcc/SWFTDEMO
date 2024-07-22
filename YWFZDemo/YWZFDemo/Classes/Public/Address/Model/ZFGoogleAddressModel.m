//
//  ZFGoogleAddressModel.m
//  ZZZZZ
//
//  Created by YW on 2018/7/10.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFGoogleAddressModel.h"

@implementation ZFGoogleHighlightModel
@end

@implementation ZFGoogleStructuredModel
@end


@implementation ZFGoogleAddressModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"structured_formatting" : [ZFGoogleStructuredModel class],
             @"highlight" : [ZFGoogleHighlightModel class]
             };
}

@end



@implementation ZFGoogleAddressComponentsModel
@end


@implementation ZFGoogleDetailAddressModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"address_components" : [ZFGoogleAddressComponentsModel class],
             };
}

@end

