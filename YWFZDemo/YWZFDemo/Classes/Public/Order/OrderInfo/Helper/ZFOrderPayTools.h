//
//  ZFOrderPayTools.h
//  ZZZZZ
//
//  Created by YW on 2018/10/31.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//  订单支付工具, 全站统一调用这个

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZFFiveThModel.h"
#import "ZFOrderPayResultModel.h"

//支付渠道
typedef NS_ENUM(NSInteger) {
    PayChannel_PayModel,    //使用后台接口的payModel判断
    PayChannel_Default      //默认的时候需要请求后台接口获取payModel, 用于订单列表和订单详情
}PayChannel;

@class ZFOrderPayResultModel;

@interface ZFOrderPayTools : NSObject

+(instancetype)paytools;

//开始支付, 默认使用push方式
- (void)startPay;

/**
 *  支付渠道
 *  默认为 PayChannel_PayModel
 */
@property (nonatomic, assign) PayChannel channel;

/**
 *  支付Url, 由后台返回, 不能为空
 */
@property (nonatomic, copy) NSString *payUrl;

/**
 *  H5支付的链接是特殊的，目前只针对提交订单页面必传
 */
@property (nonatomic, copy) NSString *payUrlH5;

/**
 *  支付orderId, 由后台返回
 */
@property (nonatomic, copy) NSString *orderId;

/**
 *  由后台返回的支付模式
 *  channel = PayChannel_PayModel时，这个值必须传
 *  默认为1
 *  1 使用原生支付模式
 *  0 使用H5支付模式
 */
@property (nonatomic, assign) NSInteger payModel;

/**
 *  承载支付页面的父视图
 */
@property (nonatomic, weak) UIViewController *parentViewController;

/**
 *  电子钱包修改密码url
 *  channel == PayChannel_PayModel时，需要从外部设置值
 */
@property (nonatomic, strong) NSString *walletPasswordUrl;

/**
 支付完成的回调
 @param model 支付的结果
 */
@property (nonatomic, copy) void(^paySuccessCompletionHandle)(ZFOrderPayResultModel *orderPayResultMoedl);

/**
 支付取消
 */
@property (nonatomic, copy) void(^payCancelCompolementHandle)(void);
/**
 支付失败的回调
 @param code 支付错误代码
 @param msg 支付错误信息
 */
@property (nonatomic, copy) void(^payFailureCompletionHandle)(void);

/**
 加载H5的load，用于统计代码
 */
@property (nonatomic, copy) void(^loadH5PaymentHandle)(void);

/**
 *  支付问卷调查回调
 */
@property (nonatomic, copy) void(^paymentSurveyHandle)(void);

@end


