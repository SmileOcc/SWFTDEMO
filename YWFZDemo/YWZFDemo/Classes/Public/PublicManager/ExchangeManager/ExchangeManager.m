//
//  ExchangeManager.m
//  Yoshop
//
//  Created by YW on 16/6/1.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "ExchangeManager.h"
#import "ZFDecimalNumberBehavior.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import "Constants.h"

static BOOL isEmptyRate = NO;
static BOOL isNeedToSave = YES;
///当前正在使用的货币模型列表, 保存到内存里面, 使用的时候不用每次I/O取值
static NSArray *currencyList = nil;

@implementation ExchangeManager
+ (void)saveLocalExchange:(NSArray *)array {
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:array forKey:kExchangeKey];
    [archiver finishEncoding];
    [data writeToFile:[ZFPATH_DIRECTORY stringByAppendingPathComponent:kRateName] atomically:YES];
    currencyList = array;
}

+ (NSArray *)currencyList {
    if (currencyList) {
        return currencyList;
    }
    NSData *data = [[NSData alloc] initWithContentsOfFile:[ZFPATH_DIRECTORY stringByAppendingPathComponent:kRateName]];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSArray *array = [unarchiver decodeObjectForKey:kExchangeKey];
    [unarchiver finishDecoding];//一定不要忘记finishDecoding，否则会报错
    currencyList = array;
    return array;
}

+ (double)rateOfCurrency:(NSString *)currency {
    double rate = 0.0;
    RateModel *rateModel = [self rateModelOfCurrency:currency];
    rate = [rateModel.rate doubleValue];
    return rate;
}

+ (RateModel *)rateModelOfCurrency:(NSString *)currency
{
    NSArray *currencyList = [self currencyList];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"code == %@", currency];
    NSArray *filteredArray = [currencyList filteredArrayUsingPredicate:predicate];
    if(filteredArray.count == 0) {
        predicate = [NSPredicate predicateWithFormat:@"symbol == %@", currency];
        filteredArray = [currencyList filteredArrayUsingPredicate:predicate];
    }
    RateModel *model = nil;
    if ([filteredArray count]) {
        model = filteredArray[0];
    } else {
        model = [self localCurrencyModel];
    }
    return model;
}

+ (double)localRate {
    NSArray *array = [[self localCurrency] componentsSeparatedByString:@" "];
    NSString *country = [array lastObject];
    return [self rateOfCurrency:country];
}

+ (NSString *)localCurrency {
    
    if (isNeedToSave) {
        isNeedToSave = NO;
        isEmptyRate = [self currencyList].count == 0 ? YES : NO;
    }
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *currencyValue = [user objectForKey:kNowCurrencyKey];
    
    if (ZFIsEmptyString(currencyValue)) {
        
        ZFInitExchangeModel *exchangeModel = [AccountManager sharedManager].initializeModel.exchange;
        NSString *name = ZFToString(exchangeModel.name);
        NSString *sign = ZFToString(exchangeModel.sign);
        NSString *rate = ZFToString(exchangeModel.rate);
        if (name.length>0 && sign.length>0 && rate.length>0) {
            currencyValue = [NSString stringWithFormat:@"%@ %@", sign, name];
            if (isEmptyRate) {
                isEmptyRate = NO;
                RateModel *model = [[RateModel alloc] init];
                model.code = name;
                model.symbol = sign;
                model.rate = rate;
                model.exponet = exchangeModel.exponet;
                model.position = ZFToString(exchangeModel.position);
                model.thousandSign = ZFToString(exchangeModel.thousandSign);
                NSString *decimal = @".";
                if (![self isEmptyString:exchangeModel.decimalSign]) {
                    decimal = ZFToString(exchangeModel.decimalSign);
                }
                model.decimalSign = decimal;
                [ExchangeManager saveLocalExchange:@[model]];
            }
        } else {
            if (isEmptyRate) {
                isEmptyRate = NO;
                RateModel *model = [[RateModel alloc] init];
                model.code = @"USD";
                model.symbol = @"$";
                model.rate = @"1";
                model.exponet = 2;
                model.decimalSign = @".";
                model.thousandSign = @"";
                model.position = @"1";
                [ExchangeManager saveLocalExchange:@[model]];
            }
            NSString *languageCode = [ZFLocalizationString shareLocalizable].nomarLocalizable;
            //启动APP当系统语言为法语和西语的时候，APP商品的显示价格默认为欧元
            if ([languageCode hasPrefix:@"es"] || [languageCode hasPrefix:@"fr"]) {
                currencyValue = @"€ EUR";
            } else {
                currencyValue = @"$ USD";
            }
        }
    }
    return currencyValue;
}

+ (NSString *)localCurrencyName
{
    NSString *localCurrency = [self localCurrency];
      return [localCurrency componentsSeparatedByString:@" "].lastObject;
}

+ (NSString *)localTypeCurrency {
    NSString *localCurrency = [self localCurrency];
    return [localCurrency componentsSeparatedByString:@" "].firstObject;
}

+ (void)updateLocalCurrency:(NSString *)currency {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:currency forKey:kNowCurrencyKey];
    [user synchronize];
}

+ (NSString *)symbolOfCurrency:(NSString *)currency {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"code == %@", currency];
    NSArray *filteredArray = [[self currencyList] filteredArrayUsingPredicate:predicate];
    if(filteredArray.count == 0) {
        predicate = [NSPredicate predicateWithFormat:@"symbol == %@", currency];
        filteredArray = [[self currencyList] filteredArrayUsingPredicate:predicate];
    }
    if(filteredArray.count > 0) {
        RateModel *model = filteredArray[0];
        return model.symbol;
    }
    return @"";
}

+ (RateModel *)localCurrencyModel
{
    NSString *currency = [self localCurrencyName];
    NSArray *currencyList = [self currencyList];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"code == %@", currency];
    NSArray *filteredArray = [currencyList filteredArrayUsingPredicate:predicate];
    if(filteredArray.count == 0) {
        predicate = [NSPredicate predicateWithFormat:@"symbol == %@", currency];
        filteredArray = [currencyList filteredArrayUsingPredicate:predicate];
    }
    RateModel *model = nil;
    if (filteredArray.count) {
        model = filteredArray[0];
    }
    if (ZFIsEmptyString(model.code) || ZFIsEmptyString(model.symbol)) {
        //最后没有找到汇率模型的时候，默认设置为美国货币模型
        RateModel *temModel = [[RateModel alloc] init];
        temModel.code = @"USD";
        temModel.symbol = @"$";
        temModel.rate = @"1";
        temModel.exponet = 2;
        temModel.position = @"1";
        temModel.thousandSign = @"";
        temModel.decimalSign = @".";
        [ExchangeManager saveLocalExchange:@[temModel]];
        model = temModel;
    }
    return model;
}

/**
 *  是否需要向上取整
 *  YES 需要
 *  NO 不需要
 */
+(BOOL)isNeedUpFetch:(RateModel *)model
{
    if (model.exponet == 0) {
        return YES;
    }
    return NO;
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

///货币空串判断，不能用全局判空方法，此处单独处理
+ (BOOL)isEmptyString:(id)string {
    return string==nil || string==[NSNull null] || ![string isKindOfClass:[NSString class]] || [(NSString *)string length] == 0;
}

#pragma mark - 计算方法

+ (NSString *)transforPrice:(NSString *)price {
    //乘法运算
    NSDecimalNumber *transfor = [self decimalNumberByMultiplyingBy:price rate:[self localRate]];
//    NSString *currency = [[self localCurrency] componentsSeparatedByString:@" "].firstObject;

    RateModel *rateModel = [self localCurrencyModel];
    
    NSDecimalNumber *value = [self handleRound:transfor scale:rateModel.exponet upOrDown:UpDownFetchType_Up];

    NSString *str = [self currencyIsRightOrLeftWithRateModel:rateModel price:value];
    return str;
}

/**
 *  用于提交订单页面的汇率转换方法
 */
+ (NSString *)transforPirceUseCheckOutPage:(NSString *)price priceType:(PriceType)type currency:(NSString *)currency
{
    //乘法运算
    UpDownFetchType fetchType = [self isUpFetchPrice:type];
    RateModel *model = nil;
    if (currency) {
        model = [self rateModelOfCurrency:currency];
    }else{
        model = [self localCurrencyModel];
    }
    
    NSDecimalNumber *transfor = [self decimalNumberByMultiplyingBy:price rate:model.rate.doubleValue];
    NSDecimalNumber *value = [self handleRound:transfor scale:model.exponet upOrDown:fetchType];
    
    NSString *str = [self currencyIsRightOrLeftWithRateModel:model price:value];
    return str;
}

+ (NSString *)transPurePriceforPrice:(NSString *)price currency:(NSString *)currency priceType:(PriceType)type
{
    //乘法运算
    RateModel *model = nil;
    if (currency) {
        model = [self rateModelOfCurrency:currency];
    }else{
        model = [self localCurrencyModel];
    }
    UpDownFetchType fetchType = [self isUpFetchPrice:type];
    NSDecimalNumber *transfor = [self decimalNumberByMultiplyingBy:price rate:model.rate.doubleValue];
    NSDecimalNumber *value = [self handleRound:transfor scale:model.exponet upOrDown:fetchType];

    return [NSString stringWithFormat:@"%.2f", value.doubleValue];
}

+ (NSString *)transPurePriceforCurrencyPrice:(NSString *)price currency:(NSString *)currency priceType:(PriceType)type
{
    //乘法运算
    RateModel *model = nil;
    if (currency) {
        model = [self rateModelOfCurrency:currency];
    }else{
        model = [self localCurrencyModel];
    }
    UpDownFetchType fetchType = [self isUpFetchPrice:type];
    NSDecimalNumber *transfor = [self decimalNumberByMultiplyingBy:price rate:model.rate.doubleValue];
    NSDecimalNumber *value = [self handleRound:transfor scale:model.exponet upOrDown:fetchType];

//    return [NSString stringWithFormat:@"%@%.2f", model.symbol,value.doubleValue];
    return [self currencyIsRightOrLeftWithRateModel:model price:value];
}

+ (NSString *)transPurePriceForCurrencyPrice:(NSString *)price sourceCurrency:(NSString *)sourceCurrency purposeCurrency:(NSString *)purposeCurrency priceType:(PriceType)type isSpace:(BOOL)space isAppendCurrency:(BOOL)appendCurrency{
    
    //来源货币源
    RateModel *sourceModel = nil;
    if (sourceCurrency) {
        sourceModel = [self rateModelOfCurrency:sourceCurrency];
    }else{
        sourceModel = [self localCurrencyModel];
    }
    double sourceRateValue = sourceModel.rate.doubleValue<=0 ? 1 : sourceModel.rate.doubleValue;
    
    //转换成改货币
    RateModel *purposeModel = nil;
    if (purposeCurrency) {
        purposeModel = [self rateModelOfCurrency:purposeCurrency];
    }else{
        purposeModel = [self localCurrencyModel];
    }
    double purposeRateValue = purposeModel.rate.doubleValue<=0 ? 1 : purposeModel.rate.doubleValue;

    //防止直接取服务器返回的数据返回非String类型
    price = [NSString stringWithFormat:@"%@", price];

    NSDecimalNumber *purposeCurrencyResult = [[NSDecimalNumber alloc] initWithString:@"0"];
    if (price.doubleValue > 0) {

        NSDecimalNumber *priceNumber = [NSDecimalNumber decimalNumberWithString:price];
        NSDecimalNumber *sourceRateNumber = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%lf", sourceRateValue]];
        NSDecimalNumber *sourcePriceResult = [priceNumber decimalNumberByDividingBy:sourceRateNumber];
        
        NSDecimalNumber *purposeRateNumber = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%lf", purposeRateValue]];
        purposeCurrencyResult = [sourcePriceResult decimalNumberByMultiplyingBy:purposeRateNumber];

    }
    NSDecimalNumber *value = [self handleRound:purposeCurrencyResult scale:purposeModel.exponet upOrDown:UpDownFetchType_Down];
    
    NSString *str = [ExchangeManager currencyIsRightOrLeftWithRateModel:purposeModel price:value isSpace:space isAppendCurrency:appendCurrency];
    
    return str;
}

+ (NSString *)transPurePriceForCurrencyPrice:(NSString *)price purposeCurrency:(NSString *)purposeCurrency priceType:(PriceType)type isSpace:(BOOL)space isAppendCurrency:(BOOL)appendCurrency {
    
    //转换成改货币
    RateModel *purposeModel = nil;
    if (purposeCurrency) {
        purposeModel = [self rateModelOfCurrency:purposeCurrency];
    }else{
        purposeModel = [self localCurrencyModel];
    }

    //防止直接取服务器返回的数据返回非String类型
    price = [NSString stringWithFormat:@"%@", price];

    NSDecimalNumber *purposeCurrencyResult = [[NSDecimalNumber alloc] initWithString:@"0"];
    if (price.doubleValue > 0) {
        purposeCurrencyResult = [NSDecimalNumber decimalNumberWithString:price];
    }
    NSDecimalNumber *value = [self handleRound:purposeCurrencyResult scale:purposeModel.exponet upOrDown:UpDownFetchType_Down];
    
    NSString *str = [ExchangeManager currencyIsRightOrLeftWithRateModel:purposeModel price:value isSpace:space isAppendCurrency:appendCurrency];
    
    return str;
}


+ (NSDecimalNumber *)transDecimalNumberPurePriceforPrice:(NSString *)price currency:(NSString *)currency priceType:(PriceType)type
{
    //乘法运算
    RateModel *model = nil;
    if (currency) {
        model = [self rateModelOfCurrency:currency];
    }else{
        model = [self localCurrencyModel];
    }
    UpDownFetchType fetchType = [self isUpFetchPrice:type];
    NSDecimalNumber *transfor = [self decimalNumberByMultiplyingBy:price rate:model.rate.doubleValue];
    NSDecimalNumber *value = [self handleRound:transfor scale:model.exponet upOrDown:fetchType];
    return value;
}

///拼接一下纯数字和货币符号
+ (NSString *)transAppendPrice:(NSString *)price currency:(NSString *)currency
{
    
//    RateModel *model = nil;
//    if (currency) {
//        model = [self rateModelOfCurrency:currency];
//    }else{
//        model = [self localCurrencyModel];
//    }
//
//    NSString *str = [self currencyIsRightOrLeftWithRateModel:model price:[NSNumber numberWithDouble:price.doubleValue]];
    return [self transAppendPrice:price currency:currency rateModel:nil];
}

+ (NSString *)transAppendPrice:(NSString *)price currency:(NSString *)currency rateModel:(RateModel *)rateModel
{
    if (!rateModel) {
        if (currency) {
            rateModel = [self rateModelOfCurrency:currency];
        }else{
            rateModel = [self localCurrencyModel];
        }
    }
    
    NSString *str = [self currencyIsRightOrLeftWithRateModel:rateModel price:[NSNumber numberWithDouble:price.doubleValue]];
    return str;
}

+ (NSString *)transPurePriceforPrice:(NSString *)price {
    //乘法运算
    double rate = [self localRate];
    NSDecimalNumber *transfor = [self decimalNumberByMultiplyingBy:price rate:rate];
//    NSString *currency = [[self localCurrency] componentsSeparatedByString:@" "].firstObject;
    
    NSDecimalNumber *value = nil;
    RateModel *rateModel = [self localCurrencyModel];
    value = [self handleRound:transfor scale:rateModel.exponet upOrDown:UpDownFetchType_Up];
    NSString *str = [self currencyIsRightOrLeftWithRateModel:rateModel price:value isSpace:YES isAppendCurrency:NO];

    return str;
}

+ (NSString *)transPurePriceforPriceOnlyNumber:(NSString *)price {
    //乘法运算
    double rate = [self localRate];
    NSDecimalNumber *transfor = [self decimalNumberByMultiplyingBy:price rate:rate];
    
    NSDecimalNumber *value = nil;
    RateModel *rateModel = [self localCurrencyModel];
    value = [self handleRound:transfor scale:rateModel.exponet upOrDown:UpDownFetchType_Up];
    NSString *str = [NSString stringWithFormat:@"%.2f", value.doubleValue];
    return str;
}

+ (NSString *)transforCeilOrFloorPrice:(NSString *)price currency:(NSString *)currency numberOfdigits:(NSInteger)digits upDownType:(UpDownFetchType)type
{
//    NSMutableString *str = [NSMutableString string];
    RateModel *model = [self rateModelOfCurrency:currency];
    double transfor = [self gainCeilOrFloorWithType:type price:price digits:digits];
//    [str appendFormat:@"%.0f", transfor];
    return [[self currencyIsRightOrLeftWithRateModel:model price:[NSNumber numberWithFloat:transfor]] copy];
}

+ (NSString *)transforCeilOrFloorDifferencePrice:(NSString *)price currency:(NSString *)currency numberOfdigits:(NSInteger)digits upDownType:(UpDownFetchType)type
{
    double transfor = [self gainCeilOrFloorWithType:type price:price digits:digits];
    double difference = 0.0;
    if (type == UpDownFetchType_Up) {
        difference = transfor - price.doubleValue;
    } else if (type == UpDownFetchType_Down) {
        difference = price.doubleValue - transfor;
    }
//    NSMutableString *str = [NSMutableString string];
//    [str appendFormat:@"%.2f", difference];
    RateModel *model = [self rateModelOfCurrency:currency];
    NSString *str = [[self currencyIsRightOrLeftWithRateModel:model price:[NSNumber numberWithFloat:difference]] copy];
    return str;
}

+ (double)gainDigitsIntergerNumber:(NSInteger)digits
{
    if (digits <= -1) {
        return 1.0;
    } else {
        double result = powf(10.0, digits);
        return result;
    }
}

+ (double)gainCeilOrFloorWithType:(UpDownFetchType)type price:(NSString *)price digits:(NSInteger)digits
{
    double result = [self gainDigitsIntergerNumber:digits];
    double transfor = [price doubleValue];
    transfor = transfor / result;
    if (type == UpDownFetchType_Up) {
        transfor = ceilf(transfor);
    } else if (type == UpDownFetchType_Down) {
        transfor = floorf(transfor);
    }
    transfor = transfor * result;
    return transfor;
}

///货币符号在左边还是右边
///某些特定的货币符号要放到价格的右边
///http://jira.hqygou.com/browse/ZF-4107
+ (NSString *)currencyIsRightOrLeftWithRateModel:(RateModel *)rateModel price:(NSNumber *)price
{
    return [self currencyIsRightOrLeftWithRateModel:rateModel price:price isSpace:YES isAppendCurrency:YES];
}

/**
 *  货币符号拼接方法
 *  @params currency 货币符号
 *  @params price 价格
 *  @params space 货币拼接是否有空隙
 *  @params appendCurrency 是否拼接货币符号
 */
+ (NSString *)currencyIsRightOrLeftWithRateModel:(RateModel *)rateModel price:(NSNumber *)price isSpace:(BOOL)space isAppendCurrency:(BOOL)appendCurrency
{
    NSString *str = [NSString string];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    numberFormatter.minimumIntegerDigits = 1; //最小整数位 1
    numberFormatter.currencySymbol = @"";
    numberFormatter.groupingSize = 3; //分区分割区
    
    NSString *decimalSeparator = @".";
    if (![self isEmptyString:rateModel.decimalSign]) {
        decimalSeparator = ZFToString(rateModel.decimalSign);
    }
    
    NSString *thousandSeparator = @"";
    if (![self isEmptyString:rateModel.thousandSign]) {
        thousandSeparator = ZFToString(rateModel.thousandSign);
    }
    
    numberFormatter.currencyDecimalSeparator = decimalSeparator; //小数点分隔符 '.'
    numberFormatter.currencyGroupingSeparator = thousandSeparator; //分区分隔符 '.'
    
    //如果需要拼接货币符号
    if (appendCurrency) {
        //货币位置
        if ([ZFToString(rateModel.position) isEqualToString:@"2"]) {
            // 右
            if (space) {
                numberFormatter.positiveSuffix = [NSString stringWithFormat:@" %@", rateModel.symbol];
            } else {
                numberFormatter.positiveSuffix = [NSString stringWithFormat:@"%@", rateModel.symbol];
            }
        } else {
            if (space) {
                numberFormatter.positivePrefix = [NSString stringWithFormat:@"%@ ", rateModel.symbol];
            } else {
                numberFormatter.positivePrefix = [NSString stringWithFormat:@"%@", rateModel.symbol];
            }
        }
    }
    
    // 精度处理
    if (rateModel.exponet < 0) {
        rateModel.exponet = 2;
    }
    
    numberFormatter.minimumFractionDigits = rateModel.exponet;
    numberFormatter.maximumFractionDigits = rateModel.exponet;
    numberFormatter.alwaysShowsDecimalSeparator = rateModel.exponet > 0 ? YES : NO;
    
    str = [numberFormatter stringFromNumber:price];
    return str;
}

/**
 *  取整方法
 *  value 价格
 *  scale 保留小数点精度
 *  fetchType 是否向上/向下取整
 */
+(NSDecimalNumber *)handleRound:(NSDecimalNumber *)value scale:(NSInteger)scale upOrDown:(UpDownFetchType)fetchType
{
    if (scale < 0) {
        scale = 2;
    }
    NSDecimalNumber *subtotal = [NSDecimalNumber decimalNumberWithDecimal:value.decimalValue];
    ZFDecimalNumberBehavior *behavior = [ZFDecimalNumberBehavior shareInstance];
    behavior.behaviorNumberScale = scale;
    NSRoundingMode roundingModel = NSRoundPlain;
    if (fetchType == UpDownFetchType_Up) {
        roundingModel = NSRoundUp;
    } else if (fetchType == UpDownFetchType_Down) {
        roundingModel = NSRoundDown;
    }
    behavior.behaviorRoundingMode = roundingModel;
    NSDecimalNumber *total = [subtotal decimalNumberByRoundingAccordingToBehavior:behavior];
    return total;
}

///乘法运算
+(NSDecimalNumber *)decimalNumberByMultiplyingBy:(NSString *)price rate:(double)rateValue
{
    price = [NSString stringWithFormat:@"%@", price]; //防止直接取服务器返回的数据返回非String类型
    if (rateValue < 0) {
        rateValue = 1;
    }
    if (price.doubleValue > 0) {
        NSDecimalNumber *priceNumber = [NSDecimalNumber decimalNumberWithString:price];
        NSDecimalNumber *rateNumber = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%lf", rateValue]];
        NSDecimalNumber *result = [priceNumber decimalNumberByMultiplyingBy:rateNumber];
        return result;
    }
    return [[NSDecimalNumber alloc] initWithString:@"0"];
}


+ (NSString *)localCouponContent:(NSString *)sourceCurrency youhuilv:(NSString *)youhuilv fangshi:(NSString *)fangshi {
    
    if (ZFIsEmptyString(youhuilv)) {
        return @"";
    }
    
    NSString *currency = !ZFIsEmptyString(sourceCurrency) ? sourceCurrency : @"USD";
    youhuilv = ZFToString(youhuilv);
    fangshi = ZFToString(fangshi);
    
    //本地货币金额符号
    NSString *localTypeCurrency = [ExchangeManager localTypeCurrency];
    //本地货币名称
//    NSString *localCurrencyName = [ExchangeManager localCurrencyName];
//    
//    RateModel *localCurrencyRateModel = [ExchangeManager rateModelOfCurrency:localTypeCurrency];
    
    // fangshi=1 百分比 2 满减
    __block NSMutableArray *resultsArray = [[NSMutableArray alloc] init];
    NSArray *youhuilvArrays = [youhuilv componentsSeparatedByString:@","];
    
    [youhuilvArrays enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        //示例： 12-10
        if ([obj containsString:@"-"]) {
            
            NSArray *subArrays = [obj componentsSeparatedByString:@"-"];
            NSString *firstString = @"";
            NSString *lastString = [NSString stringWithFormat:@"%@%%",subArrays.lastObject];
            
            firstString = [ExchangeManager transPurePriceForCurrencyPrice:subArrays.firstObject sourceCurrency:currency purposeCurrency:localTypeCurrency priceType:PriceType_Coupon isSpace:NO isAppendCurrency:YES];
            
            if (![fangshi isEqualToString:@"1"]) {//满减
                lastString = [ExchangeManager transPurePriceForCurrencyPrice:subArrays.lastObject sourceCurrency:currency purposeCurrency:localTypeCurrency priceType:PriceType_Coupon isSpace:NO isAppendCurrency:YES];
            }
            
            firstString = [firstString stringByAppendingFormat:@"-%@",lastString];
            [resultsArray addObject:firstString];
            
        } else {//示例：12
            NSString *firstString = [NSString stringWithFormat:@"%@%%",obj];
            if (![fangshi isEqualToString:@"1"]) {
                firstString = [ExchangeManager transPurePriceForCurrencyPrice:obj sourceCurrency:currency purposeCurrency:localTypeCurrency priceType:PriceType_Coupon isSpace:NO isAppendCurrency:YES];
            }
            [resultsArray addObject:firstString];
        }
    }];
    
    
    NSString *resultString = @"";
    if (resultsArray.count > 1) {
        resultString = [resultsArray componentsJoinedByString:@","];
    } else {
        resultString = resultsArray.firstObject;
    }
    
    NSString *content = resultString;
    return content;
}
@end
