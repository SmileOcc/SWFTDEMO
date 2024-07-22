//
//  ZFWaitCommentModel.m
//  ZZZZZ
//
//  Created by YW on 2019/11/29.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFWaitCommentModel.h"

@implementation ZFWaitCommentModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"coupon_msg"          : [ZFCouponYouHuiLvModel class],
             @"second_coupon_msg"   : [ZFCouponYouHuiLvModel class]
            };
}

@end


@implementation ZFMyCommentModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
     @"coupon_msg"          : [ZFCouponYouHuiLvModel class],
     @"second_coupon_msg"   : [ZFCouponYouHuiLvModel class]
    };
}
@end
