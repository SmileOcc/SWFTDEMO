//
//  ZFHackerPointModel.h
//  ZZZZZ
//
//  Created by YW on 2018/9/5.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 订单级别的
 hacker_point:{
 1.order_real_pay_amount(实际支付金额)
 2.order_origin_amount  (订单原金额)
 3.order_discount_amount  (折扣金额)
 4.order_pay_way (支付方式)
 5.order_point_value(积分使用值)积分数量
 6.order_point_amount(积分使用金额)
 7.order_shipping_way(物流方式) 名称
 8. order_market_type（营销类型，订单使用的营销类型，多种时用|拼接）
 }
 */
@interface ZFHackerPointOrderModel : NSObject
/**(实际支付金额)*/
@property (nonatomic, copy) NSString* order_real_pay_amount;
///(订单原金额)
@property (nonatomic, copy) NSString* order_origin_amount;
///(折扣金额)
@property (nonatomic, copy) NSString* order_discount_amount;
///(支付方式)
@property (nonatomic, copy) NSString* order_pay_way;
///(积分使用值)积分数量
@property (nonatomic, copy) NSString* order_point_value;
///(积分使用金额)
@property (nonatomic, copy) NSString* order_point_amount;
///(物流方式) 名称
@property (nonatomic, copy) NSString* order_shipping_way;
///营销类型，订单使用的营销类型，多种时用|拼接）
@property (nonatomic, copy) NSString* order_market_type;
///优惠券名字
@property (nonatomic, copy) NSString* coupon_name;
///优惠券使用数量
@property (nonatomic, copy) NSString* coupon_used;

@property (nonatomic, copy) NSString* coupon_deducted;
///优惠券类型
@property (nonatomic, copy) NSString* coupon_type;
///是否使用优惠券
@property (nonatomic, copy) NSString* if_coupon_used;
@end

/*
 商品级别
 hacker_point
 */
@interface ZFHackerPointGoodsModel : NSObject
///(实际支付金额)
@property (nonatomic, copy) NSString* goods_real_pay_amount;
///(折扣金额)
@property (nonatomic, copy) NSString* goods_pay_discount;
///(商品原价金额)乘以数量
@property (nonatomic, copy) NSString* goods_origin_amount;
///(营销类型,实际使用的类型)
@property (nonatomic, copy) NSString* goods_market_type;
///(商品库存)
@property (nonatomic, copy) NSString* goods_storage_num;
@end


@interface ZFHackerPointModel : NSObject

@end

