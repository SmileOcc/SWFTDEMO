

//
//  ZFOrderReviewInfoModel.m
//  ZZZZZ
//
//  Created by YW on 2018/3/14.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderReviewInfoModel.h"

@implementation ZFOrderReviewInfoModel
+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{
             @"reviewPic" : [ZFOrderReviewImageInfoModel class],
             @"reviewSize" : [GoodsDetailsReviewsSizeModel class],
             @"review_success_coupon":[ZFCouponYouHuiLvModel class],
             @"review_success_coupon1":[ZFCouponYouHuiLvModel class],
             };
}
@end
