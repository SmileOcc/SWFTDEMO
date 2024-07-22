//
//  OrderDetailOrderModel.h
//  Dezzal
//
//  Created by 7FD75 on 16/8/12.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import "ZFVATModel.h"
#import "ZFBaseOrderModel.h"

@interface OrderDetailOrderModel : ZFBaseOrderModel

///添加时间
@property (nonatomic, copy) NSString *add_time;
///地址
@property (nonatomic, copy) NSString *address;
///城市
@property (nonatomic, copy) NSString *city;
///省
@property (nonatomic, copy) NSString *province;
/// 城镇、村
@property (nonatomic, copy) NSString *barangay;

///收货人
@property (nonatomic, copy) NSString *consignee;
///电话号码
@property (nonatomic, copy) NSString *tel;
///邮政编码
@property (nonatomic, copy) NSString *zipcode;
///国家
@property (nonatomic, copy) NSString *country_str;
///国家id
@property (nonatomic, copy) NSString *country;
///国家id
@property (nonatomic, copy) NSString *country_id;
///商品总价
@property (nonatomic, copy) NSString *goods_amount;
///支付总价
@property (nonatomic, copy) NSString *grand_total;
///物流保险费用
@property (nonatomic, copy) NSString *insurance;
///订单总价
@property (nonatomic, copy) NSString *order_amount;
///支付方式名称
@property (nonatomic, copy) NSString *pay_name;
///支付时间
@property (nonatomic, copy) NSString *pay_time;
///支付状态
@property (nonatomic, copy) NSString *pay_status;
///积分价值
@property (nonatomic, copy) NSString *point_money;
///物流id
@property (nonatomic, copy) NSString *shipping;
///物流名称
@property (nonatomic, copy) NSString *shipping_name;
///总费用
@property (nonatomic, copy) NSString *total_cost;
///用户id
@property (nonatomic, copy) NSString *user_id;
///订单货币
@property (nonatomic, copy) NSString *order_currency;
///cod费用
@property (nonatomic, copy) NSString *formalities_fee;
///区号
@property (nonatomic, copy) NSString *code;
///运营商号
@property (nonatomic, copy) NSString *supplier_number;
///COD取整标志位
@property (nonatomic, copy) NSString *cod_orientation;


/*
 * 底部价格计算
 */
@property (nonatomic, copy) NSString *subtotal;
///优惠券金额
@property (nonatomic, copy) NSString *coupon;
///积分金额
@property (nonatomic, copy) NSString *z_point;
///物流保险金额
@property (nonatomic, copy) NSString *insure_fee;
///TAX金额
@property (nonatomic, strong) ZFVATModel *VATModel;
///COD 折扣金额
@property (nonatomic, copy) NSString *cod_discount;
///总支付金额
@property (nonatomic, copy) NSString *total_payable;
///EventDiscount
@property (nonatomic, copy) NSString *other_discount;
///studentDiscount
@property (nonatomic, copy) NSString *student_discount;
///onliePayDiscount
@property (nonatomic, copy) NSString *pay_deduct;
///是否显示修改地址按钮 0不显示， 1显示
@property (nonatomic, assign) NSInteger change_address_show;

///剩余取消订单时间
@property (nonatomic, copy) NSString *pay_left_time;
///是否系统删除订单 YES是 NO不是
@property (nonatomic, assign) BOOL is_system_cancel;
///订单取消原因
@property (nonatomic, copy) NSString *cancel_reason;
///电子钱包使用金额
@property (nonatomic, copy) NSString *used_wallet;
///电子钱包金额
@property (nonatomic, copy) NSString *online_payment;
///拆单提示语
@property (nonatomic, copy) NSString *order_part_hint;

- (BOOL)isOfflinePayment;

//是否 klarna支付
- (BOOL)isKlarnaPayment;

@end
