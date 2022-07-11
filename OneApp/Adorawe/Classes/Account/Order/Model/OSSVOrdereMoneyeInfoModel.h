//
//  OSSVOrdereMoneyeInfoModel.h
// XStarlinkProject
//
//  Created by odd on 2021/3/10.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVOrdereMoneyeInfoModel : NSObject

//1，没有带后缀的就是美元价格
//2，_converted 后缀代表转换后的不带货币符号的价格
//3，_converted_symbol 后缀代表转换后带货币符号的价格。


// 订单最终支付 total
@property (nonatomic,copy) NSString *payable_amount_converted_symbol;
@property (nonatomic,copy) NSString *payable_amount_converted;
@property (nonatomic,copy) NSString *payable_amount;

// cod total
@property (nonatomic,copy) NSString *order_amount_converted_symbol;
@property (nonatomic,copy) NSString *order_amount_converted;
@property (nonatomic,copy) NSString *order_amount;

@property (nonatomic,copy) NSString *activity_save_converted_symbol;
@property (nonatomic,copy) NSString *activity_save_converted;
@property (nonatomic,copy) NSString *activity_save;

@property (nonatomic,copy) NSString *pay_discount_amount_converted_symbol;
@property (nonatomic,copy) NSString *pay_discount_amount_converted;
@property (nonatomic,copy) NSString *pay_discount_amount;

@property (nonatomic,copy) NSString *coupon_save_converted_symbol;
@property (nonatomic,copy) NSString *coupon_save_converted;
@property (nonatomic,copy) NSString *coupon_save;



@property (nonatomic,copy) NSString *goods_market_amount_converted_symbol;
@property (nonatomic,copy) NSString *goods_market_amount_converted;
@property (nonatomic,copy) NSString *goods_market_amount;

@property (nonatomic,copy) NSString *goods_amount_converted_symbol;
@property (nonatomic,copy) NSString *goods_amount_converted;
@property (nonatomic,copy) NSString *goods_amount;

@property (nonatomic,copy) NSString *shipping_fee_converted_symbol;
@property (nonatomic,copy) NSString *shipping_fee_converted;
@property (nonatomic,copy) NSString *shipping_fee;

@property (nonatomic,copy) NSString *cod_cost_converted_symbol;
@property (nonatomic,copy) NSString *cod_cost_converted;
@property (nonatomic,copy) NSString *cod_cost;

@property (nonatomic,copy) NSString *cod_discount_converted_symbol;
@property (nonatomic,copy) NSString *cod_discount_converted;
@property (nonatomic,copy) NSString *cod_discount;


/////订单上单个商品
@property (nonatomic,copy) NSString *market_total_converted_symbol;
@property (nonatomic,copy) NSString *market_total_converted;
@property (nonatomic,copy) NSString *market_total;

@property (nonatomic,copy) NSString *market_price_converted_symbol;
@property (nonatomic,copy) NSString *market_price_converted;
@property (nonatomic,copy) NSString *market_price;

@property (nonatomic,copy) NSString *goods_total_converted_symbol;
@property (nonatomic,copy) NSString *goods_total_converted;
@property (nonatomic,copy) NSString *goods_total;

@property (nonatomic,copy) NSString *goods_price_converted_symbol;
@property (nonatomic,copy) NSString *goods_price_converted;
@property (nonatomic,copy) NSString *goods_price;


//金币相关的
@property (nonatomic,copy) NSString *coin_save_converted_symbol; //带货币的金币优惠
@property (nonatomic,copy) NSString *coin_save; //金币优惠----不带货币符号
@property (nonatomic,copy) NSString *coin_save_converted; //金币优惠----不带货币符号

@property (nonatomic,copy) NSString *shipping_insurance_converted_symbol; //邮费保险费--带货币符号
@property (nonatomic,copy) NSString *shipping_insurance_converted; //邮费保险-----不带货币符号
@end

NS_ASSUME_NONNULL_END
