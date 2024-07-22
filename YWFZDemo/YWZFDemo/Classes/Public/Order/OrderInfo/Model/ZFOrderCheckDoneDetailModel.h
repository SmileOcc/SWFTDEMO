//
//  ZFOrderCheckDoneDetailModel.h
//  ZZZZZ
//
//  Created by YW on 26/10/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFBaseOrderModel.h"

// 快捷支付状态类型
typedef NS_ENUM(NSUInteger, FastPaypalOrderType){
    //快速支付成功
    FastPaypalOrderTypeSuccess = 1,
    //快速支付失败
    FastPaypalOrderTypeFail = 2,
    //普通支付
    FastPaypalOrderTypeCommon = 3,
    //SOA 快捷支付重新跳转
    FastPayPalOrderTypeRestJump = 4
};

typedef NS_ENUM(NSUInteger, PaymentStateType){
    // 支付失败
    PaymentStateTypeFailure   = 1,
    // 等待支付
    PaymentStateTypeWaite     = 2
};

@interface ZFOrderCheckDoneDetailModel : ZFBaseOrderModel

/**
 * 快捷支付状态类型
 */
@property (nonatomic, assign) FastPaypalOrderType   flag;
/**
 * 0 为 成功状态
 */
@property (nonatomic, assign) NSInteger             error;
/**
 * 正常情况下的金额
 */
@property (nonatomic, copy) NSString                *order_amount;
/**
 * cod取整后的金额
 */
@property (nonatomic, copy) NSString                *multi_order_amount;
/**
 * cod取整方向
 */
@property (nonatomic, copy) NSString                *cod_orientation;
/**
 * 支付方式
 */
@property (nonatomic, copy) NSString                *pay_method;
/**
 * 提示语
 */
@property (nonatomic, copy) NSString                *msg;

@property (nonatomic, copy) NSString                *promote_pcode;

//v4.1.0 新增 token, 格式 {@"pay_token" : @"value"}
@property (nonatomic, copy) NSDictionary            *pay_before_info;

// 下面参数不是 json 里的字段
@property (nonatomic, copy) NSString                *payName;

@property (nonatomic, assign) PaymentStateType      payState;

@end
