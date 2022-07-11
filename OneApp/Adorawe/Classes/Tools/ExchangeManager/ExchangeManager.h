//
//  ExchangeManager.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/1.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger) {
    PriceType_ProductPrice,             ///商品价格
    PriceType_ShippingCost,             ///物流运费
    PriceType_Insurance,                ///保险费
    //以上的类型需要向上取整
    PriceType_Coupon,                   ///优惠券
    PriceType_Point,                    ///<积分
    PriceType_Activity,                 ///活动
    PriceType_Off,                      ///支付折扣
    //以上的类型需要向下取整
    PriceType_Normal                    ///默认的模式
}PriceType;

typedef NS_ENUM(NSInteger) {
    UpDownFetchType_Up,                 ///向上取整
    UpDownFetchType_Down,               ///向下取整
    UpDownFetchType_Normal              ///默认类型
}UpDownFetchType;

@class RateModel;
@interface ExchangeManager : NSObject

/**
 *  启动获取货币处理
 */
+ (void)handInitCurrencyData:(NSArray<RateModel*> *)rateArray;
/**
 *  货币、汇率、国别信息本地存储
 */
+ (void)saveLocalExchange:(NSArray *)array;
/**
 *  获取货币列表
 */
+ (NSArray *)currencyList;

/**
 *  获取本地选择的货币对应的汇率
 */
+ (NSString *)localRate;
/**
 *  获取本地货币类型+货币符号(Model)
 */
+ (RateModel *)localCurrency;
/**
 *  获取本地货币类型
 */
+ (NSString *)localTypeCurrency;
/**
 *  存储本地货币类型
 */ 
+ (void)updateLocalCurrencyWithRteModel:(RateModel *)model;
/**
 *  价格汇率转换
 */
+ (NSString *)transforPrice:(NSString *)price;
+ (NSString *)changeRateModel:(RateModel *)rateModel transforPrice:(NSString *)price;

///这个方法返回的是纯数字文本的价格，没有拼接符号的
+ (NSString *)changeRateModel:(RateModel *)rateModel transforPrice:(NSString *)price priceType:(PriceType)type;
+ (NSString *)appenSymbol:(RateModel *)rateModel price:(NSString *)value;

+ (NSString *)transforUSD_Price:(NSString *)price;

@end
