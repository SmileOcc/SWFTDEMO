//
//  FilterManager.h
//  ZZZZZ
//
//  Created by YW on 2017/3/9.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExchangeManager.h"

// COD取整方式
typedef NS_ENUM(NSUInteger, CashOnDeliveryTruncType){
    //不显示不取整
    CashOnDeliveryTruncTypeDefault = 0,
    //向上
    CashOnDeliveryTruncTypeUp = 1,
    //向下取整
    CashOnDeliveryTruncTypeDown = 2
};

@interface FilterManager : NSObject

+ (void)saveLocalFilter:(NSDictionary *)dict;
//是否支持COD付款方式
+ (NSString *)isSupportCOD:(NSString *)addressId;
//该地区的COD是否支持向下取整
+ (CashOnDeliveryTruncType)cashOnDeliveryTruncType:(NSString *)addressId;
//获取该地区COD取整的位数
+ (NSInteger)cashOnDeliveryTruncNumberOfDigits:(NSString *)addressId;

+ (BOOL)requireCardNumWithAddressId:(NSString *)addressId;

+ (void)saveTempFilter:(NSString *)currency;

+ (NSString *)tempCurrency;

+ (void)removeCurrency;

+ (NSString *)adapterCodWithAmount:(NSString *)amount andCod:(BOOL)cod priceType:(PriceType)type;

+ (NSString *)changeCodCurrencyToFront:(NSString *)price;

@end

