//
//  ExchangeManager.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/1.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "ExchangeManager.h"
#import "RateModel.h"

static RateModel *localRateModel = nil;
@implementation ExchangeManager

+ (void)handInitCurrencyData:(NSArray<RateModel*> *)rateArray {
    
    if (!STLJudgeNSArray(rateArray)) {
        rateArray = @[];
    }
    [ExchangeManager saveLocalExchange:rateArray];

    
    __block RateModel *defaultModel = nil;

    NSUserDefaults *versionDefaults = [NSUserDefaults standardUserDefaults];
    if ([versionDefaults boolForKey:kIsSettingCurrentKey]) {
        ///如果手动设置过货币,更新最新的
        RateModel *currentRateModel = [ExchangeManager localCurrency];
        __block BOOL isFind = NO;
        [rateArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            RateModel *model = obj;
            if (model.is_default == 1) {
                defaultModel = model;
            }
            if ([model.code isEqualToString:currentRateModel.code]) {
                defaultModel = model;
                // 如果本地设置过，才更新本地的
                [ExchangeManager updateLocalCurrencyWithRteModel:defaultModel];
                isFind = YES;
                *stop = YES;
            }
        }];
        
    } else {//没有设置过
        
        [rateArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            RateModel *model = obj;
            if (model.is_default == 1) {
                STLLog(@"没有设置过，初始语言");
                defaultModel = model;
                *stop = YES;
            }
            
        }];
    }
    
    //没有匹配到已设置的，或没有默认的
    if (!defaultModel) {
        defaultModel = [[RateModel alloc] init];
        defaultModel.code = @"USD";
        defaultModel.rate = @"1";
        defaultModel.symbol = @"US $";
        defaultModel.exponent = @"2";
    }
    
    localRateModel = defaultModel;
}

+ (void)saveLocalExchange:(NSArray *)array {
    
    if (!STLJudgeNSArray(array)) {
        array = @[];
    }
    NSMutableData *data = [[NSMutableData alloc] init];
    
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    [archiver encodeObject:array forKey:kExchangeKey];

    [archiver finishEncoding];
    
    [data writeToFile:[STL_PATH_DIRECTORY stringByAppendingPathComponent:kRateName] atomically:YES];
}

+ (NSArray *)currencyList {
    NSData *data = [[NSData alloc] initWithContentsOfFile:[STL_PATH_DIRECTORY stringByAppendingPathComponent:kRateName]];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSArray *array = [unarchiver decodeObjectForKey:kExchangeKey];
    [unarchiver finishDecoding];//一定不要忘记finishDecoding，否则会报错
    return array;
}

+ (NSString *)localRate {
    return [self localCurrency].rate;
}

+ (RateModel *)localCurrency {
    if (localRateModel) {
        return localRateModel;
    }
    NSData *data = [[NSData alloc] initWithContentsOfFile:[STL_PATH_DIRECTORY stringByAppendingPathComponent:kCurRateName]];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [unarchiver setClass:RateModel.class forClassName:kCurRateName];
    RateModel *currencyRateModel = [unarchiver decodeObjectForKey:kCurExchangeKey];
    [unarchiver finishDecoding];//一定不要忘记finishDecoding，否则会报错
    
    if (!currencyRateModel) {
        currencyRateModel = [[RateModel alloc] init];
        currencyRateModel.code = @"USD";
        currencyRateModel.rate = @"1";
        currencyRateModel.symbol = @"US $";
        currencyRateModel.exponent = @"2";
    }
    if (STLIsEmptyString(currencyRateModel.symbol)) {
        currencyRateModel.symbol = @"";
    }
    if (STLIsEmptyString(currencyRateModel.exponent)) {
        currencyRateModel.exponent = @"";
    }
    localRateModel = currencyRateModel;
    return currencyRateModel;
}

+ (NSString *)localTypeCurrency {
    return [self localCurrency].code;
}

+ (void)updateLocalCurrencyWithRteModel:(RateModel *)model {
    
    //设置当前的货币
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setBool:YES forKey:kIsSettingCurrentKey];
    [user synchronize];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    [NSKeyedArchiver setClassName:kCurRateName forClass:model.class];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    [archiver encodeObject:model forKey:kCurExchangeKey];
    
    [archiver finishEncoding];
    
    localRateModel = model;
    
    [data writeToFile:[STL_PATH_DIRECTORY stringByAppendingPathComponent:kCurRateName] atomically:YES];
}

//不是四舍五入，是到小数点后2位
+ (NSString *)transforPrice:(NSString *)price {
    NSString *currency = [self localCurrency].symbol;
    NSDecimalNumber *resultNumber = [self decimalNumberByMultiplyingBy:price rate:[self localRate]];
    NSMutableString *str = [NSMutableString string];
    if (STLIsEmptyString(currency)) {
        currency = @"";
    }
    [str appendString:currency];
    if ([self isNeedUpFetch:[self localCurrency]]) {
        NSDecimalNumber *value = [self handleUpFloat:resultNumber scale:0];
        [str appendFormat:@"%.2f", value.doubleValue];
    }else{
        NSDecimalNumber *value = [self handleUpFloat:resultNumber scale:2];
        [str appendFormat:@"%.2f", value.doubleValue];
    }
    return str;
}

//不是四舍五入，是到小数点后2位
+ (NSString *)changeRateModel:(RateModel *)rateModel transforPrice:(NSString *)price {
    
    if (rateModel) {
        NSString *currency = rateModel.symbol;
        NSDecimalNumber *resultNumber = [self decimalNumberByMultiplyingBy:price rate:rateModel.rate];
        NSMutableString *str = [NSMutableString string];
        [str appendString:currency];
        if ([self isNeedUpFetch:[self localCurrency]]) {
            NSDecimalNumber *value = [self handleUpFloat:resultNumber scale:0];
            [str appendFormat:@"%@", value];
        }else{
            NSDecimalNumber *value = [self handleUpFloat:resultNumber scale:2];
            [str appendFormat:@"%@", value];
        }
        return str;
    }
    
    return [ExchangeManager transforPrice:price];
}

+ (NSString *)changeRateModel:(RateModel *)rateModel transforPrice:(NSString *)price priceType:(PriceType)type
{
    if (rateModel) {
        UpDownFetchType fetchType = [self isUpFetchPrice:type];
        NSDecimalNumber *resultNumber = [self decimalNumberByMultiplyingBy:price rate:rateModel.rate];
        if (fetchType == UpDownFetchType_Up && rateModel.exponent.integerValue == 0){
            NSDecimalNumber *value = [self handleUpFloat:resultNumber scale:0];
            return [NSString stringWithFormat:@"%.2f", value.doubleValue];
        }else if (fetchType == UpDownFetchType_Down && rateModel.exponent.integerValue == 0){
            NSDecimalNumber *value = [self handleDownFloat:resultNumber scale:0];
            return [NSString stringWithFormat:@"%.2f", value.doubleValue];
        }else{
            NSDecimalNumber *value;
            if (fetchType == UpDownFetchType_Up) {
                value = [self handleUpFloat:resultNumber scale:2];
            }else{
                value = [self handleDownFloat:resultNumber scale:2];
            }
            return [NSString stringWithFormat:@"%.2f", value.doubleValue];
        }
    }
    return [ExchangeManager transforPrice:price];
}

+ (NSString *)appenSymbol:(RateModel *)rateModel price:(NSString *)value
{
    return [NSString stringWithFormat:@"%@%@", rateModel.symbol, value];
}

+ (NSString *)transforUSD_Price:(NSString *)price {
    CGFloat transfor = [price floatValue] / [self localRate].floatValue;
    NSString *str = [NSString stringWithFormat:@"%.2f", transfor];
    return str;
}

/**
 *  return YES 向上取整
 *  return NO 向下取整
 */
+(UpDownFetchType)isUpFetchPrice:(PriceType)type
{
    if (type == PriceType_ProductPrice || type == PriceType_ShippingCost || type == PriceType_Insurance) {
        return UpDownFetchType_Up;
    }
    if (type == PriceType_Coupon || type == PriceType_Point || type == PriceType_Activity || type == PriceType_Off) {
        return UpDownFetchType_Down;
    }
    return UpDownFetchType_Normal;
}

/**
 *  是否需要向上取整
 *  YES 需要
 *  NO 不需要
 */
+(BOOL)isNeedUpFetch:(RateModel *)model
{
    if (model.exponent.integerValue == 0) {
        return YES;
    }
    return NO;
}

+(NSDecimalNumber *)handleUpFloat:(NSDecimalNumber *)value scale:(NSInteger)scale
{
    NSDecimalNumberHandler *roundUp = [NSDecimalNumberHandler
                                      
                                      decimalNumberHandlerWithRoundingMode:NSRoundUp
                                      
                                      scale:scale
                                      
                                      raiseOnExactness:NO
                                      
                                      raiseOnOverflow:NO
                                      
                                      raiseOnUnderflow:NO
                                      
                                      raiseOnDivideByZero:YES];
    
    NSDecimalNumber *subtotal = [NSDecimalNumber decimalNumberWithDecimal:value.decimalValue];
    NSDecimalNumber *total = [subtotal decimalNumberByRoundingAccordingToBehavior:roundUp];
    return total;
}

+(NSDecimalNumber *)handleDownFloat:(NSDecimalNumber *)value scale:(NSInteger)scale
{
    NSDecimalNumberHandler *roundUp = [NSDecimalNumberHandler
                                       
                                       decimalNumberHandlerWithRoundingMode:NSRoundDown
                                       
                                       scale:scale
                                       
                                       raiseOnExactness:NO
                                       
                                       raiseOnOverflow:NO
                                       
                                       raiseOnUnderflow:NO
                                       
                                       raiseOnDivideByZero:YES];
    
    NSDecimalNumber *subtotal = [NSDecimalNumber decimalNumberWithDecimal:value.decimalValue];
    NSDecimalNumber *total = [subtotal decimalNumberByRoundingAccordingToBehavior:roundUp];
    return total;
}

///乘法运算
+(NSDecimalNumber *)decimalNumberByMultiplyingBy:(NSString *)price rate:(NSString *)rateValue
{
    if (![OSSVNSStringTool isEmptyString:price] && ![OSSVNSStringTool isEmptyString:rateValue]) {
        NSDecimalNumber *priceNumber = [NSDecimalNumber decimalNumberWithString:price];
        NSDecimalNumber *rateNumber = [NSDecimalNumber decimalNumberWithString:rateValue];
        NSDecimalNumber *result = [priceNumber decimalNumberByMultiplyingBy:rateNumber];
        return result;
    }
    return [[NSDecimalNumber alloc] initWithString:@"0"];
}

@end
