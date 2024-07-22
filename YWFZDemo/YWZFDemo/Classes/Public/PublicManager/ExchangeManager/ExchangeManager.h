//
//  ExchangeManager.h
//  Yoshop
//
//  Created by YW on 16/6/1.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RateModel.h"

typedef NS_ENUM(NSInteger) {
    ///商品价格
    PriceType_ProductPrice,
    ///物流运费
    PriceType_ShippingCost,
    ///保险费
    PriceType_Insurance,
    //以上的类型需要向上取整
    ///优惠券
    PriceType_Coupon,
    ///<积分
    PriceType_Point,
    ///活动
    PriceType_Activity,
    ///支付折扣
    PriceType_Off,
    //以上的类型需要向下取整
    PriceType_Normal                    ///默认的模式
}PriceType;

typedef NS_ENUM(NSInteger) {
    UpDownFetchType_Normal,             ///默认类型
    UpDownFetchType_Up,                 ///向上取整
    UpDownFetchType_Down,               ///向下取整
}UpDownFetchType;

///货币符号显示位置
//typedef NS_ENUM(NSInteger) {
//    CurrencyLeft,
//    CurrencyRight,
//    CurrencyMXN,
//}CurrencyPosition;

///货币类型
//typedef NS_ENUM(NSInteger) {
//    CurrencyType_Default,
//    CurrencyType_EU,
//    CurrencyType_RP,
//    CurrencyType_PY,
//    CurrencyType_JPY
//}CurrencyType;

@interface ExchangeManager : NSObject
/**
 *  货币、汇率、国别信息本地存储
 */
+ (void)saveLocalExchange:(NSArray *)array;
/**
 *  获取货币列表
 */
+ (NSArray *)currencyList;
/**
 *  获取货币对应的汇率
 */
+ (double)rateOfCurrency:(NSString *)currency;
/**
 *  获取本地选择的货币对应的汇率
 */
+ (double)localRate;
/**
 *  获取本地货币类型+货币符号
 */
+ (NSString *)localCurrency;

/**
 *  获取本地选择的币种名字, USA ,EUR....
 */
+ (NSString *)localCurrencyName;
/**
 *  获取本地货币类型
 */
+ (NSString *)localTypeCurrency;
/**
 *  存储本地货币类型
 */
+ (void)updateLocalCurrency:(NSString *)currency;
/**
 *  价格汇率转换
 */
+ (NSString *)transforPrice:(NSString *)price;

///COD支付返回的价格和货币的拼接，当currency=nil时，货币符号使用用户自己选择的符号
+ (NSString *)transforPirceUseCheckOutPage:(NSString *)price priceType:(PriceType)type currency:(NSString *)currency;
/**
 *  转换成纯价格 如 5.88前面没有币种符号
 *
 *  @param price 价格字符串
 *
 *  @return 转换后的价格
 */
+ (NSString *)transPurePriceforPrice:(NSString *)price;

/**
 *  转换成纯价格：只是数字，不特殊处理
 *
 *  @param price 价格字符串
 *
 *  @return 转换后的价格
 */
+ (NSString *)transPurePriceforPriceOnlyNumber:(NSString *)price;

///返回一个纯数字的价格
+ (NSString *)transPurePriceforPrice:(NSString *)price currency:(NSString *)currency priceType:(PriceType)type;

///返回一个:货币+价格
+ (NSString *)transPurePriceforCurrencyPrice:(NSString *)price currency:(NSString *)currency priceType:(PriceType)type;

///返回一个：货币转换成另一个货币 显示成：货币+价格
/// 里面没用到type,都是取金额货币的
+ (NSString *)transPurePriceForCurrencyPrice:(NSString *)price sourceCurrency:(NSString *)sourceCurrency purposeCurrency:(NSString *)purposeCurrency priceType:(PriceType)type isSpace:(BOOL)space isAppendCurrency:(BOOL)appendCurrency;


+ (NSString *)transPurePriceForCurrencyPrice:(NSString *)price purposeCurrency:(NSString *)purposeCurrency priceType:(PriceType)type isSpace:(BOOL)space isAppendCurrency:(BOOL)appendCurrency;

///把价格和货币符号进行拼接
+ (NSString *)transAppendPrice:(NSString *)price currency:(NSString *)currency;
+ (NSString *)transAppendPrice:(NSString *)price currency:(NSString *)currency rateModel:(RateModel *)rateModel;

///返回一个NSDecimalNumber格式的数字，用于订单详情页的价格计算
+ (NSDecimalNumber *)transDecimalNumberPurePriceforPrice:(NSString *)price currency:(NSString *)currency priceType:(PriceType)type;

/**
 *  COD 汇率取整
 *  @param price 价格
 *  @param currency 货币符号
 *  @param digits 取整位数,0个位1十位2百位3千位4万位
 *  @param type 取整方式 UpDownFetchType_Up 向上, UpDownFetchType_Down 向下
 */
+ (NSString *)transforCeilOrFloorPrice:(NSString *)price
                              currency:(NSString *)currency
                        numberOfdigits:(NSInteger)digits
                            upDownType:(UpDownFetchType)type;

/**
 *  COD 汇率取整后的差额计算
 *  @param price 价格
 *  @param currency 货币符号
 *  @param digits 取整位数,0个位1十位2百位3千位4万位
 *  @param type 取整方式 UpDownFetchType_Up 向上, UpDownFetchType_Down 向下
 */
+ (NSString *)transforCeilOrFloorDifferencePrice:(NSString *)price
                                        currency:(NSString *)currency
                                  numberOfdigits:(NSInteger)digits
                                      upDownType:(UpDownFetchType)type;

+ (NSString *)symbolOfCurrency:(NSString *)currency;


/**
*  货币符号拼接方法
*  @params currency 货币符号
*  @params price 价格
*  @params space 货币拼接是否有空隙
*  @params appendCurrency 是否拼接货币符号
*/
+ (NSString *)currencyIsRightOrLeftWithRateModel:(RateModel *)rateModel price:(NSNumber *)price isSpace:(BOOL)space isAppendCurrency:(BOOL)appendCurrency;


+ (RateModel *)rateModelOfCurrency:(NSString *)currency;

/**
 *  是否需要向上取整
 *  YES 需要
 *  NO 不需要
 */
+(BOOL)isNeedUpFetch:(RateModel *)model;



/// 本地优惠券显示处理
/// @param sourceCurrency 来源货币
/// @param youhuilv 优惠内容
/// @param fangshi 优惠方式 1 百分比 2 满减
+ (NSString *)localCouponContent:(NSString *)sourceCurrency youhuilv:(NSString *)youhuilv fangshi:(NSString *)fangshi;
@end
