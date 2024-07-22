//
//  ZFOrderCheckInfoDetailModel.h
//  ZZZZZ
//
//  Created by YW on 26/10/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PaymentListModel.h"
#import "ShippingListModel.h"
#import "CartCodModel.h"
#import "ZFAddressInfoModel.h"
#import "CartGoodsModel.h"
#import "PointModel.h"
#import "CartCheckOutTotalModel.h"
#import "ZFOrderInfoFooterModel.h"
#import "CheckOutGoodListModel.h"
#import "ZFOrderCouponModel.h"
#import "ZFMyCouponModel.h"
#import "ZFVATModel.h"
#import "ZFInitializeModel.h"
#import "GoodsDetailModel.h"
@class ZFTaxVerifyModel;

// 支付类型
typedef NS_ENUM(NSUInteger, PayCodeType){
    // cod
    PayCodeTypeCOD        = 1,
    // online
    PayCodeTypeOnline     = 2,
    // combine
    PayCodeTypeCombine    = 3,
    // 老接口
    PayCodeTypeOld        = 9
};

@interface ZFOrderCheckInfoDetailModel : NSObject

@property (nonatomic, strong) CartCodModel   *cod;

@property (nonatomic, strong) ZFAddressInfoModel *address_info;

@property (nonatomic, strong) CartGoodsModel *cart_goods;

@property (nonatomic, copy) NSString *default_shipping_id;

@property (nonatomic, copy) NSString *notice_msg;

@property (nonatomic, strong) NSArray *payment_list;

@property (nonatomic, strong) PointModel *point;

@property (nonatomic, strong) NSArray *shipping_list;

@property (nonatomic, strong) CartCheckOutTotalModel *total;

@property (nonatomic, strong) ZFOrderInfoFooterModel   *footer;

@property (nonatomic,assign) BOOL ifNeedInsurance; // 是否需要保险

@property (nonatomic, strong) ZFOrderCouponModel *coupon_list;

@property (nonatomic, strong) ZFVATModel   *VATModel;

///是否需要填写税号标志 1 需要 0 不需要
@property (nonatomic, assign) NSInteger   is_use_tax_id;

///税号 校验规则
@property (nonatomic, strong) ZFTaxVerifyModel   *taxVerify;

///1 cod会员  0 非会员
@property (nonatomic, assign) NSInteger   is_cod_service;

/************************下面参数用于快速支付***************************/
@property (nonatomic,copy) NSString *payertoken;
@property (nonatomic,copy) NSString *payerId;

///总的商品数量，拿到接口参数后本地计算的
@property (nonatomic, assign) NSInteger totalGoodsNum;

@property (nonatomic, strong) ZFInitCountryInfoModel *change_coutry;

///是否需要重新修改地址
@property (nonatomic, assign) BOOL is_valid_address;

///支付方式是否包含信用卡 0 不显示  1显示
@property (nonatomic, assign) NSInteger is_have_credit;

/// 修改地址时，是否清空地址相关数据 清空州省验证 blank ='12' 清空city 验证 blank='11' 验证邮编 不需要清空 保持四位
@property (nonatomic, strong) NSDictionary *checkPHAddress;

/// 使用积分提示
@property (nonatomic, copy) NSString *get_points;
/// 首单送coupon提示语
@property (nonatomic, copy) NSString *first_order_Coupon;
/// 首单送coupon提示金额
@property (nonatomic, copy) NSString *first_order_Coupon_amount;

@property (nonatomic, strong) AFparams  *first_order_bts_result;

@end

//"checkPHAddress": {
//    "code": 0,
//    "msg": ""
//}


@interface ZFTaxVerifyModel : NSObject

@property (nonatomic, copy) NSString *pcc_name;
/**校验规则*/
@property (nonatomic, copy) NSString *reg;
/**是否需要验证*/
@property (nonatomic, copy) NSString *is_pcc;
/**描述*/
@property (nonatomic, copy) NSString *note;
/**规则错误提示*/
@property (nonatomic, copy) NSString *error_msg;


@property (nonatomic, strong) NSAttributedString             *namehtmlAttr;
@property (nonatomic, strong) NSAttributedString             *notehtmlAttr;


- (void)handleHtml;
- (NSAttributedString *)configNameHtmlAttr:(NSString *)fontName
fontSize:(CGFloat)fontSize;

- (NSAttributedString *)configNoteHtmlAttr:(NSString *)fontName
                                  fontSize:(CGFloat)fontSize;
@end
