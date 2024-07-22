//
//  ZFOrderReviewGoodsModel.m
//  ZZZZZ
//
//  Created by YW on 2018/3/15.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderReviewGoodsModel.h"

@implementation ZFOrderReviewGoodsModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"review_show_extra_coupon"          : [ZFCouponYouHuiLvModel class],
             @"review_coupon"          : [ZFCouponYouHuiLvModel class]
            };
}

@end
