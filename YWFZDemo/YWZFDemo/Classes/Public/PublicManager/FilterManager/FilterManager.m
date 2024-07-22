//
//  FilterManager.m
//  ZZZZZ
//
//  Created by YW on 2017/3/9.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "FilterManager.h"
#import "NSStringUtils.h"
#import "Constants.h"

static NSString *codFilter = @"codFilter";
static NSString *addressFilter = @"addressFilter";
static NSString *discountFilter = @"discountFilter";

@interface FilterManager ()
@property (nonatomic, assign) NSInteger   currentPayType;
@end

@implementation FilterManager

// 写数据
+ (void)saveLocalFilter:(NSDictionary *)dict {
    NSMutableData *data = [[NSMutableData alloc] init];
    
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    [archiver encodeObject:dict forKey:kFilterKey];
    
    [archiver finishEncoding];
    
    [data writeToFile:[ZFPATH_DIRECTORY stringByAppendingPathComponent:kFilterName] atomically:YES];
}

// 读数据
+ (NSDictionary *)filterDict {
    NSData *data = [[NSData alloc] initWithContentsOfFile:[ZFPATH_DIRECTORY stringByAppendingPathComponent:kFilterName]];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *dict = [unarchiver decodeObjectForKey:kFilterKey];
    [unarchiver finishDecoding];//一定不要忘记finishDecoding，否则会报错
    return dict;
}

/**
 * 根据国家id判断是否支持 COD 付款方式   目前有 172,251,309支持
 * 否则去获取币种
 */
+ (NSString *)isSupportCOD:(NSString *)addressId{
    
    NSDictionary *dict = [self filterDict][codFilter];
    
    if ([[dict allKeys] containsObject:addressId]) {
        return dict[addressId];
    } else {
        return [ExchangeManager localCurrencyName];
    }
    return nil;
}

/**
 * 根据国家id判断是如何取整
 * CashOnDeliveryTruncTypeDefault 0  不显示不取整
 * CashOnDeliveryTruncTypeUp      1
 */
+ (CashOnDeliveryTruncType)cashOnDeliveryTruncType:(NSString *)addressId {
    NSDictionary *dict = [self filterDict][discountFilter];
    //orientation:向上向下取整 （旧字段）
    //digit:取整位数,0个位1十位2百位3千位4万为5十万位6百万位（新字段）
    
    if ([[dict allKeys] containsObject:addressId]) {
        NSDictionary *params = dict[addressId];
        return [params[@"orientation"] integerValue];
    } else {
        return CashOnDeliveryTruncTypeDefault;
    }
}

//获取该地区COD取整的位数
+ (NSInteger)cashOnDeliveryTruncNumberOfDigits:(NSString *)addressId
{
    NSDictionary *dict = [self filterDict][discountFilter];
    
    if ([[dict allKeys] containsObject:addressId]) {
        NSDictionary *params = dict[addressId];
        return [params[@"digit"] integerValue];
    } else {
        return -1;
    }
}

+ (BOOL)requireCardNumWithAddressId:(NSString *)addressId {
    NSArray *array = [self filterDict][addressFilter];
    if ([array containsObject:addressId]) {
        return YES;
    }
    return NO;
}

+ (void)saveTempFilter:(NSString *)currency {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:currency forKey:kTempFilterKey];
    [defaults synchronize];
}

 + (NSString *)tempCurrency {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *tempCurrency = [defaults objectForKey:kTempFilterKey];
    return tempCurrency;
}

+ (void)removeCurrency {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kTempFilterKey];
    [defaults synchronize];
}

///用于提交订单页面的方法
+ (NSString *)adapterCodWithAmount:(NSString *)amount andCod:(BOOL)cod priceType:(PriceType)type
{
    NSString *result;
    
    if (cod && ![NSStringUtils isEmptyString:[FilterManager tempCurrency]]) {
        ///如果是COD, 使用COD的汇率
        result = [NSString stringWithFormat:@"%@", [ExchangeManager transforPirceUseCheckOutPage:amount priceType:type currency:[FilterManager tempCurrency]]];
    } else {
        ///使用系统用户自己选择的汇率
        result = [NSString stringWithFormat:@"%@", [ExchangeManager transforPirceUseCheckOutPage:amount priceType:type currency:nil]];
    }
    return result;
}

+ (NSString *)changeCodCurrencyToFront:(NSString *)price {
    NSString *symbol = [ExchangeManager symbolOfCurrency:[FilterManager tempCurrency]];
    NSString *result;
    if ([symbol isEqualToString:@"TL"] || [symbol isEqualToString:@"JD"]) {
        result = [NSString stringWithFormat:@"%@%@",[ExchangeManager symbolOfCurrency:[FilterManager tempCurrency]],price];
    }else{
        result = [NSString stringWithFormat:@"%@%@",price,[ExchangeManager symbolOfCurrency:[FilterManager tempCurrency]]];
    }
    return result;
}

@end

