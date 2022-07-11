//
//  OSSVCartCheckModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/13.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCartCheckModel.h"
#import "OSSVAddresseBookeModel.h"
#import "OSSVCartGoodsModel.h"
#import "OSSVCartPaymentModel.h"
#import "OSSVCartShippingModel.h"
#import "OSSVAdvsEventsManager.h"

@implementation OSSVCartCheckModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"goodList"     : @"good_list",
             @"paymentList"  : @"payment",
             @"shippingList" : @"shipping",
             @"currencyInfo" : @"currency_info",
             @"wareHouseList": @"war_order_list",
             @"usableCouponNum" : @"can_use_coupon_num",
             @"shipCouponIsExists": @"shipCouponIsExists",
             @"rebate_activity_info": @"rebate_activity_info",
             @"couponMsg"    : @"available_coupon_msg",
             @"shippingInsurance" : @"is_shipping_insurance"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"address"      : [OSSVAddresseBookeModel class],
             @"goodList"     : [OSSVCartGoodsModel class],
             @"paymentList"  : [OSSVCartPaymentModel class],
             @"shippingList" : [OSSVCartShippingModel class],
             @"wareHouseList": [OSSVCartWareHouseModel class],
             @"fee_data"     : [CartCheckFreeDataModel class],
             @"goods_shield_info" : [AddressGoodsShieldInfoModel class],
             @"coin_discount_info" : [OSSVCoinInforModel class],
             @"ship_free_info"     : [OSSVShipFreeInfoModel class],
             @"cod_discount_info"  : [OSSVCodInforModel class],

             };
}

+ (NSArray *)modelPropertyWhitelist {
    return @[
             @"address",
             @"goodList",
             @"insurance",
             @"paymentList",
             @"shippingList",
             @"coupon",
             @"points",
             @"currencyInfo",
             @"usableCouponNum",
             @"wareHouseList",
             @"flag",
             @"currency_list",
             @"cod_black_list_tip",
             @"fee_data",
             @"goods_shield_info",
             @"shipCouponIsExists",
             @"rebate_activity_info",
             @"coin_discount_info",
             @"cod_discount_info",
             @"ship_free_info",
             @"couponMsg",
             @"shippingInsurance"
             ];
}

#pragma mark - protocol

-(void)modalErrorMessage:(UIViewController *)viewController errorManager:(id<STLBaseModelErrorMessageProtocol>)manager
{
    if ([manager conformsToProtocol:@protocol(STLBaseModelErrorMessageProtocol)]
        && [manager respondsToSelector:@selector(modalErrorMessage:baseModel:)]) {
        UIViewController *modalVC = viewController;
        if (!modalVC) {
            modalVC = (STLBaseCtrl *)[OSSVAdvsEventsManager gainTopViewController];
        }
        [manager modalErrorMessage:modalVC baseModel:self];
    }else{
        NSLog(@"没有遵循协议BaseViewModelErrorMessageProtocol");
    }
}

@end

@implementation CurrencyList

@end;




@implementation CartCheckFreeDataModel

@end;


@implementation AddressGoodsShieldInfoModel

@end
