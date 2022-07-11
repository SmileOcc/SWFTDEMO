//
//  STLThemeCouponsModel.m
// XStarlinkProject
//
//  Created by Starlinke on 2021/7/5.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVThemesCouponssModel.h"

@implementation Btn_multi

@end


@implementation Btn

@end


@implementation Coupon_itemModel

@end


@implementation OSSVThemesCouponssModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"coupon_items"      : [Coupon_itemModel class],
             @"btn"       : [Btn class],
             @"btn_multi"   : [Btn_multi class],
             };
}

@end
