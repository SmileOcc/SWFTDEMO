
//
//  ZFCartListResultModel.m
//  ZZZZZ
//
//  Created by YW on 2017/9/16.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCartListResultModel.h"
#import "ZFCartGoodsListModel.h"
#import "ZFMyCouponModel.h"

@implementation ZFCartCouponListModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"available" : [ZFMyCouponModel class],
             @"disabled" : [ZFMyCouponModel class],
             };
}
@end

@implementation ZFOfferMessageMOdel
@end


@implementation ZFCartListResultModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"goodsBlockList" : [ZFCartGoodsListModel class],
             @"couponListModel" : [ZFCartCouponListModel class],
             @"offerMessageModel" : [ZFOfferMessageMOdel class],
             };
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"totalNumber"         : @"cart_total_number",
             @"totalAmount"         : @"cart_total_amount",
             @"goodsBlockList"      : @"goods_list",
             @"is_show_fast_payment" : @"is_show_fast_payment",
             @"couponListModel"     : @"coupon_list",
             @"offerMessageModel"   : @"offer_message"
             };
}
@end
