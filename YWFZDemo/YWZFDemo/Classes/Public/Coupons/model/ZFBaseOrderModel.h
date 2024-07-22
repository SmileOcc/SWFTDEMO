//
//  ZFBaseOrderModel.h
//  ZZZZZ
//
//  Created by YW on 2018/12/22.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//  基础订单完成类

#import <Foundation/Foundation.h>
#import "ZFHackerPointModel.h"
#import "ZFFiveThModel.h"
#import "ZFBaseOrderGoodsModel.h"
#import "RateModel.h"

//订单状态枚举类型释义
//    0    未付款    WaitingForPayment
//    1    已付款    Paid
//    2    备货    Processing
//    3    完全发货    Shipped
//    4    已收到货    Delivered
//    6    付款中  Pending
//    7    已授权 Authorized
//    8    部分付款  Partial paid
//    10    退款    Refunded
//    11    取消    Canceled
//    13    付款失败
//    14    审核不通过（驳回）--目前没有
//    15    部分配货    PartialOrderDispatched
//    16    完全配货    Dispatched
//    17    出库--目前没有
//    18    缺货--目前没有
//    19    待取消--目前没有
//    20    部分发货    PartialOrderShipped

NS_ASSUME_NONNULL_BEGIN

@interface ZFBaseOrderModel : NSObject

///订单状态
@property (nonatomic, copy) NSString *order_status;

///订单id
@property (nonatomic, copy) NSString *order_id;

///订单号
@property (nonatomic, copy) NSString *order_sn;

///订单状态显示文字
@property (nonatomic, copy) NSString *order_status_str;

///支付id
@property (nonatomic, copy) NSString *pay_id;

///支付url
@property (nonatomic, copy) NSString *pay_url;

///物流费用
@property (nonatomic, copy) NSString *shipping_fee;

///是否显示退款按钮(0 不显示 1显示退款按钮 2 显示退款处理中状态)
@property (nonatomic, copy) NSString *show_refund;

///总费用
@property (nonatomic, copy) NSString *total_fee;

///只有等于1的情况下显示返回购车按钮
@property (nonatomic, copy) NSString *add_to_cart;

///统计代码模型
@property (nonatomic, strong) ZFHackerPointOrderModel *hacker_point;

///支付完成后台返回的真实支付方式
@property (nonatomic, copy) NSString *realPayment;

///offline link (该参数是本地赋值，非后台返回) 线下支付地址
//@property (nonatomic, copy) NSString *offlineLine;

///五周年纪念日送积分优惠券字段(本地赋值 "order/query_pay_info"接口返回) v457
//@property (nonatomic, strong) ZFFiveThModel *fiveThModel;

///用于订单结果统计数据
@property (nonatomic, strong) NSArray <ZFBaseOrderGoodsModel *> *baseGoodsList;

///是否显示线下支付页面,客户端设置
@property (nonatomic, assign) BOOL showOfflinePageVC;

///是否COD支付
@property (nonatomic, assign) BOOL isCodPay;

///是否显示确认按钮 0不显示， 1显示
@property (nonatomic, assign) NSInteger confirm_btn_show;

///生单时的汇率
@property (nonatomic, strong) RateModel *order_exchange;

@end

NS_ASSUME_NONNULL_END

