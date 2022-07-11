//
//  OSSVCreateOrderModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/18.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//  创建订单成功后返回的模型

#import <Foundation/Foundation.h>
#import "OSSVCartOrderInfoViewModel.h"

@interface OSSVCreateOrderModel : NSObject
@property (nonatomic, strong) NSArray   *orderList;
@property (nonatomic, copy) NSString    *message;
@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, strong) NSArray   *goodsList;
@property (nonatomic, copy) NSString    *shippingFee;
@property (nonatomic, copy) NSString    *couponCode;
@property (nonatomic, copy) NSString    *payCode; //支付类型
@property (nonatomic, copy) NSString    *orderAmount;// 订单总金额
@property (nonatomic, copy) NSString    *payName; //支付方式名称
@end

#pragma mark - orderList中的模型

@interface STLOrderModel : NSObject

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *method;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, copy) NSString *order_sn;                         ///订单号
@property (nonatomic, copy) NSString *order_id;                         ///订单
@property (nonatomic, copy) NSString *cod_order_amount;                 ///汇率转换后的 符号和金额
@property (nonatomic, copy) NSString *order_amount;                     ///美元金额        用于统计接口
@property (nonatomic, copy) NSString *currency;                         ///货币 符号
@property (nonatomic, copy) NSString *order_amount_arab;                ///<COD 汇率转换后的 金额
@property (nonatomic, copy) NSString *pay_code;

@end
