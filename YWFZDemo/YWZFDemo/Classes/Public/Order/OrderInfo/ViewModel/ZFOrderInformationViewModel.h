//
//  ZFOrderInformationViewModel.h
//  ZZZZZ
//
//  Created by YW on 2018/11/12.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "BaseViewModel.h"

@class ZFOrderCheckInfoModel;
@class ZFOrderCheckDoneModel;
@class ZFOrderManager;
@class ZFOrderCheckInfoDetailModel;
@class ZFAddressInfoModel;

@interface ZFOrderInformationViewModel : BaseViewModel


/**
 * 从商详一键(快速)购买过来时,需要带入相应参数到 cart/done, checkout_info接口
 */
@property (nonatomic, strong) NSDictionary *detailFastBuyInfo;


/**
 * 获取订单信息接口 参数
 */
- (NSDictionary *)queryCheckoutInfoPublicParmas:(ZFOrderManager *)manager;

/**
 * 获取上传done 接口 参数
 */
- (NSDictionary *)queryCheckDonePublicParmas:(ZFOrderManager *)manager;

/**
 * 获取拆单模式下更改地址后接口请求参数集
 */
- (NSArray *)queryCheckInfoRequestParmasWithPayCode:(NSInteger)paycode managerArray:(NSArray *)managerArray ZF_DEPRECATED_MSG_ATTRIBUTE("v4.4.0 后废弃使用");

/**
 * 获取拆单模式下生成订单信息接口请求参数集
 */
- (NSArray *)queryCheckDoneRequestParmasWithPayCode:(NSInteger)paycode managerArray:(NSArray *)managerArray ZF_DEPRECATED_MSG_ATTRIBUTE("v4.4.0 后废弃使用");

#pragma mark - 接口请求

/**
 * 获取订单信息  chekout_info接口
 */
- (void)requestCheckInfoNetwork:(NSDictionary *)parmaters completion:(void (^)(NSArray<ZFOrderCheckInfoModel *>* dataArray))completion failure:(void (^)(id))failure;

/**
 * 生成订单信息  Done接口
 */
- (void)requestCheckDoneOrder:(NSDictionary *)parmaters completion:(void (^)(NSArray<ZFOrderCheckDoneModel *> *dataArray))completion failure:(void (^)(id))failure;

/**
 * 选择支付流程 1 老的   2 新的 拆单  -1没有库存
 */
- (void)requestPaymentProcess:(id)parmaters  Completion:(void (^)(NSInteger state))completion failure:(void (^)(id obj))failure;

/**
 * 发送cod手机验证码
 */
- (void)sendPhoneCod:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

/**
 * 请求购物车数字
 */
- (void)requestCartBadgeNum;

/**
 * 支付打点接口
 * step有4个值，place,load,cancel,completed 分别代表生单完成开始进入支付页，支付url加载完成，取消支付，支付成功
 */
+ (void)requestPayTag:(NSString *)orderSN step:(NSString *)step;

@end
