//
//  ZFOrderDetailPriceModel.h
//  ZZZZZ
//
//  Created by YW on 2018/3/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 "TotalPrice_Cell_ProductTotal"  = "Product(s) Total";
 "TotalPrice_Cell_Shipping"      = "Shipping";
 "TotalPrice_Cell_Insurance"     = "Insurance";
 "TotalPrice_Cell_EventDiscount" = "Event Discount";
 "TotalPrice_Cell_Coupon"        = "Coupon";
 "TotalPrice_Cell_ZPoints"       = "Z Points";
 "TotalPrice_Cell_VAT"           = "VAT (FREE)";
 "TotalPrice_Cell_GrandTotal"    = "Grand Total";
 "TotalPrice_Cell_CODDiscount"   = "COD Discount";
 "TotalPrice_Cell_TotalPayable"  = "Total Payable";
 */
typedef NS_ENUM(NSInteger ,ZFOrderDetailPriceType) {
    ZFOrderDetailPriceTypeProductTotal = 0,
    ZFOrderDetailPriceTypeShipping,
    ZFOrderDetailPriceTypeInsurance,
    ZFOrderDetailPriceTypeCodCost,
    ZFOrderDetailPriceTypeOnlinePayDiscount,            //在线支付折扣，没有时不显示
    ZFOrderDetailPriceTypeStudentDiscount,              //学生卡折扣，没有时不显示
    ZFOrderDetailPriceTypeEventDiscount,
    ZFOrderDetailPriceTypeCoupon,                       //优惠券折扣, 没有是不显示
    ZFOrderDetailPriceTypeZPoints,
    ZFOrderDetailPriceTypeGrandTotal,
    ZFOrderDetailPriceTypeCODDiscount,
    ZFOrderDetailPriceTypeWallet,                       //电子钱包
    ZFOrderDetailPriceTypeOnlinePayment,                //在线支付
    ZFOrderDetailPriceTypeDeliveryShipping,
};

@interface ZFOrderDetailPriceModel : NSObject
@property (nonatomic, assign) ZFOrderDetailPriceType            type;
@end
