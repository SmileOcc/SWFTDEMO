//
//  YXStockDetailUtility.m
//  uSmartOversea
//
//  Created by 姜轶群 on 2019/1/10.
//  Copyright © 2019年 RenRenDai. All rights reserved.
//

#import "YXStockDetailUtility.h"
#import "MMKV.h"
#import "uSmartOversea-Swift.h"
#import "YXUsmartSignalModel.h"

@implementation YXStockDetailUtility

+ (YXKlineAdjustType)getKLineAdjustType{
    
    NSString *adjustTypeString = [[MMKV defaultMMKV] getObjectOfClass:NSString.class forKey:@"adjustType"];
    YXKlineAdjustType kLineAdjustType;
    if (adjustTypeString.length <= 0) {
        kLineAdjustType = YXKlineAdjustTypePreAdjust; //默认 前复权
    } else {
        kLineAdjustType = adjustTypeString.integerValue;
    }
    return kLineAdjustType;
    
}

+ (void)setKlineAdjustType:(YXKlineAdjustType)adjustType{
    [[MMKV defaultMMKV] setObject:[NSString stringWithFormat:@"%ld", (long)adjustType] forKey:@"adjustType"];
}

+ (NSDictionary<NSString *, NSDictionary<NSString *, id>*> *)getKLineMaSetting{
    NSDictionary *maDic = [[MMKV defaultMMKV] getObjectOfClass:NSDictionary.class forKey:@"maAcessory"];
    if (maDic.allKeys.count <= 0) {
        maDic = @{@"ma5": @{@"maNum": @"5", @"isSelected" : @(1)}, @"ma20": @{@"maNum": @"20", @"isSelected" : @(1)}, @"ma60": @{@"maNum": @"60", @"isSelected" : @(1)}, @"ma120": @{@"maNum": @"120", @"isSelected" : @(1)}, @"ma250": @{@"maNum": @"250", @"isSelected" : @(0)}};
    }
    return maDic;
}

+ (void)setMaSetting:(NSDictionary *)maSettingDic{
    
    [[MMKV defaultMMKV] setObject:maSettingDic forKey:@"maAcessory"];
    
}

+ (YXStockMainAcessoryStatus)kLineMainAccessory {
    
    NSNumber *mainAccessory = [[MMKV defaultMMKV] getObjectOfClass:NSNumber.class forKey:@"kLineMainAccessory"];
    if (mainAccessory == nil) {
        return YXStockMainAcessoryStatusMA;
    } else {
        return mainAccessory.integerValue;
    }
    
}

+ (void)resetKlineMainAccessory:(YXStockMainAcessoryStatus)mainAccessory {
    
    [[MMKV defaultMMKV] setObject:@(mainAccessory) forKey:@"kLineMainAccessory"];
    
}

+ (YXStockSubAccessoryStatus)kLineSubAccessory {
    
    NSNumber *subAccessory = [[MMKV defaultMMKV] getObjectOfClass:NSNumber.class forKey:@"kLineSubAccessory"];
    if (subAccessory == nil) {
        return YXStockSubAccessoryStatus_MAVOL;
    } else {
        return subAccessory.integerValue;
    }
    
}

+ (void)resetKlineSubAccessory:(YXStockSubAccessoryStatus)subAccessory {
    
    [[MMKV defaultMMKV] setObject:@(subAccessory) forKey:@"kLineSubAccessory"];
    
}

+ (YXRtLineType)rtLineType {
    
    NSNumber *rtLineType = [[MMKV defaultMMKV] getObjectOfClass:[NSNumber class] forKey:@"rtLineType"];
    if (rtLineType == nil) {
        return YXRtLineTypeDayTimeLine;
    } else {
       return rtLineType.integerValue;
    }
    
    
}

+ (void)resetRtLineType:(YXRtLineType)lineType {
    
    [[MMKV defaultMMKV] setObject:@(lineType) forKey:@"rtLineType"];
    
}

+ (BOOL)paraViewExpand {
    NSNumber *rtLineType = [[MMKV defaultMMKV] getObjectOfClass:[NSNumber class] forKey:@"paraViewExpand"];
    if (rtLineType == nil) {
        return NO;
    } else {
        return rtLineType.boolValue;
    }
}

+ (void)resetParaViewExpand:(BOOL)isExpand {
    [[MMKV defaultMMKV] setObject:@(isExpand) forKey:@"paraViewExpand"];
}

+ (YXStockTickType)getStockTickType {
    NSNumber *tickType = [[MMKV defaultMMKV] getObjectOfClass:NSNumber.class forKey:@"stockTickType"];

    if (tickType == nil) {
        return YXStockTickTypeTick;
    } else {
        return tickType.integerValue;
    }
}

+ (void)resetStcokTickType:(YXStockTickType)tickType {
    [[MMKV defaultMMKV] setObject:@(tickType) forKey:@"stockTickType"];
}

+ (NSDictionary *)mergeUsmartSingalData:(NSArray *)list toTimeLineData:(YXKLineData *)klineData {

    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (YXUsmartSignalModel *info in list) {
        NSString *key = [NSString stringWithFormat:@"%@000000000", info.date?:@""];
        [dic setValue:info forKey:key];
    }
    if (klineData.type.value == 7) {
        // 日k才合并
        NSArray *allKeys = dic.allKeys;
        
        int usmartHold = 0;
        for (YXKLine *lineData in klineData.list) {
            NSString *orderKey = @(lineData.latestTime.value).stringValue;
            if ([allKeys containsObject:orderKey]) {
                YXUsmartSignalModel *info = dic[orderKey];
                [self mergeSingleSignalData:info toKlineData:lineData];
                
                if (info.signal_chg == 1 || info.signal_chg == 4) {
                    usmartHold = 50;
                } else if (info.signal_chg == 2 || info.signal_chg == 3) {
                    usmartHold = 100;
                } else {
                    usmartHold = 0;
                }
            }
            lineData.usmartSignalHold = [[NumberInt64 alloc] init:usmartHold];
        }
    }

    return dic;
}



+ (void)mergeSingleSignalData:(YXUsmartSignalModel *)info toKlineData:(YXKLine *)lineData {

    lineData.usmartSignalChg = [[NumberInt64 alloc] init:info.signal_chg];
}


+ (BOOL)showDepthTradeColorPrice {
    return [[MMKV defaultMMKV] getBoolForKey:@"DepthTradeColorPrice" defaultValue:YES];
}

+ (void)setDepthTradeColorPrice:(BOOL)show {
    [[MMKV defaultMMKV] setBool:show forKey:@"DepthTradeColorPrice"];
}

+ (BOOL)showDepthTradeOrderNumber {
    return [[MMKV defaultMMKV] getBoolForKey:@"DepthTradeOrderNumber" defaultValue:YES];
}

+ (void)setDepthTradeOrderNumber:(BOOL)show {
    [[MMKV defaultMMKV] setBool:show forKey:@"DepthTradeOrderNumber"];
}

+ (BOOL)showDepthTradeCombineSamePrice {
    return [[MMKV defaultMMKV] getBoolForKey:@"DepthTradeCombineSamePrice" defaultValue:NO];
}

+ (void)setDepthTradeCombineSamePrice:(BOOL)show {
    [[MMKV defaultMMKV] setBool:show forKey:@"DepthTradeCombineSamePrice"];
}

+ (BOOL)showDepthTradePriceDistribution {
    return [[MMKV defaultMMKV] getBoolForKey:@"DepthTradePriceDistribution" defaultValue:YES];
}

+ (void)setDepthTradePriceDistribution:(BOOL)show {
    [[MMKV defaultMMKV] setBool:show forKey:@"DepthTradePriceDistribution"];
}

+ (NSInteger)getDepthGearNumber {
    NSNumber *typeNumber = [[MMKV defaultMMKV] getObjectOfClass:NSNumber.class forKey:@"DepthTradeGearNumber"];
    if (typeNumber == nil) {
        return 10;
    } else {
        return typeNumber.integerValue;
    }
}

+ (void)setDepthGearNumber:(NSInteger)gear {
    [[MMKV defaultMMKV] setObject:@(gear) forKey:@"DepthTradeGearNumber"];
}

+ (YXUSPosQuoteType)getUsAskBidSelect {
    NSNumber *typeNumber = [[MMKV defaultMMKV] getObjectOfClass:NSNumber.class forKey:@"UsAskBidSelect"];
//    if (typeNumber.integerValue == YXUSPosQuoteTypeUsNation && [[YXUserManager shared] getLevelWith:kYXMarketUS] != QuoteLevelUsNational) {
//        // 如果选了全美,但是没有行情, 就重置为nsdq
//        [self setUsAskBidSelect:YXUSPosQuoteTypeNsdq];
//        return YXUSPosQuoteTypeNsdq;
//    } else if (typeNumber.integerValue == YXUSPosQuoteTypeNsdq && [YXUserManager usNsdqLevel] != YXUserLevelUsLevel1) {
//        // 如果选了纳斯达克,但是没有行情, 就重置为全美
//        [self setUsAskBidSelect:YXUSPosQuoteTypeUsNation];
//        return YXUSPosQuoteTypeUsNation;
//    }
    // 默认返回纳斯达克
    if (typeNumber.integerValue == YXUSPosQuoteTypeNone) {
        return YXUSPosQuoteTypeNsdq;
    }
    
    return typeNumber.integerValue;
}

+ (void)setUsAskBidSelect:(YXUSPosQuoteType)select {
    [[MMKV defaultMMKV] setObject:@(select) forKey:@"UsAskBidSelect"];
}

+ (NSString *)getRtStringWithType: (YXRtLineType)type {
    NSString *title = @"";
    switch (type) {
        case YXRtLineTypeDayTimeLine:
            title = [YXLanguageUtility kLangWithKey:@"stock_detail_high_line_one_day"];
            break;
        case YXRtLineTypeFiveDaysTimeLine:
            title = [YXLanguageUtility kLangWithKey:@"stock_detail_high_line_five_day"];
            break;
        case YXRtLineTypeDayKline:
            title = [YXLanguageUtility kLangWithKey:@"stock_detail_high_line_one_day_k"];
            break;
        case YXRtLineTypeWeekKline:
            title = [YXLanguageUtility kLangWithKey:@"stock_detail_high_line_week_k"];
            break;
        case YXRtLineTypeMonthKline:
            title = [YXLanguageUtility kLangWithKey:@"stock_detail_high_line_month_k"];
            break;
        case YXRtLineTypeSeasonKline:
            title = [YXLanguageUtility kLangWithKey:@"stock_detail_high_line_season_k"];
            break;
        case YXRtLineTypeYearKline:
            title = [YXLanguageUtility kLangWithKey:@"stock_detail_high_line_year_k"];
            break;
        case YXRtLineTypeOneMinKline:
            title = [YXLanguageUtility kLangWithKey:@"stock_detail_min_k"];
            break;
        case YXRtLineTypeFiveMinKline:
            title = [NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"common_mins"], 5];
            break;
        case YXRtLineTypeFifteenMinKline:
            title = [NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"common_mins"], 10];
            break;
        case YXRtLineTypeThirtyMinKline:
            title = [NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"common_mins"], 30];
            break;
        case YXRtLineTypeSixtyMinKline:
            title = [NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"common_mins"], 60];
            break;
        default:
            break;
    }
    
    return title;
}

+ (NSString *)getTimeShareStringWithType: (YXTimeShareLineType)type {
    NSString *title = @"";
    switch (type) {
        case YXTimeShareLineTypeNone:
            title = [YXLanguageUtility kLangWithKey:@"stock_detail_high_line_one_day"];
            break;
        case YXTimeShareLineTypeAll:
            title = [YXLanguageUtility kLangWithKey:@"time_line_intra_full"];
            break;
        case YXTimeShareLineTypePre:
            title = [YXLanguageUtility kLangWithKey:@"time_line_intra_pre"];
            break;
        case YXTimeShareLineTypeIntra:
            title = [YXLanguageUtility kLangWithKey:@"time_line_intra_opening"];
            break;
        case YXTimeShareLineTypeAfter:
            title = [YXLanguageUtility kLangWithKey:@"time_line_intra_after"];
            break;
        default:
            break;
    }
    return title;
}

+ (NSString *)getSubKlineStringWithType: (YXKLineSubType)type {
    NSString *title = @"";
    switch (type) {
        case YXKLineSubTypeOneMin:
            title = [YXLanguageUtility kLangWithKey:@"common_1_min"];
            break;
        case YXKLineSubTypeFiveMin:
            title = [NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"common_mins"], 5];
            break;
        case YXKLineSubTypeFifteenMin:
            title = [NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"common_mins"], 15];
            break;
        case YXKLineSubTypeThirtyMin:
            title = [NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"common_mins"], 30];
            break;
        case YXKLineSubTypeSixtyMin:
            title = [NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"common_mins"], 60];
            break;
        default:
            break;
    }
    return title;
}

+ (YXRtLineType)getRtKlineWithSubType: (YXKLineSubType)type {
    YXRtLineType klineType = YXRtLineTypeOneMinKline;
    switch (type) {
        case YXKLineSubTypeOneMin:
            klineType = YXRtLineTypeOneMinKline;
            break;
        case YXKLineSubTypeFiveMin:
            klineType = YXRtLineTypeFiveMinKline;
            break;
        case YXKLineSubTypeFifteenMin:
            klineType = YXRtLineTypeFifteenMinKline;
            break;
        case YXKLineSubTypeThirtyMin:
            klineType = YXRtLineTypeThirtyMinKline;
            break;
        case YXKLineSubTypeSixtyMin:
            klineType = YXRtLineTypeSixtyMinKline;
            break;
        default:
            break;
    }
    
    return klineType;
}


+ (YXKLineSubType)getRtSubKlineWithType: (YXRtLineType)type {
    YXKLineSubType klineType = YXKLineSubTypeOneMin;
    switch (type) {
        case YXRtLineTypeOneMinKline:
            klineType = YXKLineSubTypeOneMin;
            break;
        case YXRtLineTypeFiveMinKline:
            klineType = YXKLineSubTypeFiveMin;
            break;
        case YXRtLineTypeFifteenMinKline:
            klineType = YXKLineSubTypeFifteenMin;
            break;
        case YXRtLineTypeThirtyMinKline:
            klineType = YXKLineSubTypeThirtyMin;
            break;
        case YXRtLineTypeSixtyMinKline:
            klineType = YXKLineSubTypeSixtyMin;
            break;
        default:
            break;
    }
    
    return klineType;
}

+ (YXTimeShareLineType)getTimeShareTypeWithQuote:(YXV2Quote *)quote {
    YXTimeShareLineType type = YXTimeShareLineTypeIntra;
    if ([self canSupportTimelineExpand:quote]) {
//        [YXUserManager shared] getLevelWith
        // 是否有行情权限
        if ([[YXUserManager shared] getLevelWith:kYXMarketUS] != QuoteLevelDelay) {
            if ([[MMKV defaultMMKV] getBoolForKey:kSelectTimeShareingAllTabKey]) {
                type = YXTimeShareLineTypeAll;
            } else {
                if (quote.msInfo.status.value == OBJECT_MARKETMarketStatus_MsPreHours) {
                    // 盘前
                    type = YXTimeShareLineTypePre;
                } else if (quote.msInfo.status.value == OBJECT_MARKETMarketStatus_MsAfterHours) {
                    // 盘后
                    type = YXTimeShareLineTypeAfter;
                } else if (quote.msInfo.status.value >= OBJECT_MARKETMarketStatus_MsOpenCall && quote.msInfo.status.value <= OBJECT_MARKETMarketStatus_MsCloseCall) {
                    type = YXTimeShareLineTypeIntra;
                } else {
                    type = YXTimeShareLineTypeAll;
                }
            }
        } else {
            type = YXTimeShareLineTypeIntra;
        }
    };
    
    return type;
}

+ (BOOL)canSupportTimelineExpand:(YXV2Quote *)quote {
    if (![quote.market isEqualToString:kYXMarketUS]) {
        return NO;
    }
    
    if (quote.type2.value == OBJECT_SECUSecuType2_StLowAdr) {
        return NO;
    }
    
    if (quote.type1.value == OBJECT_SECUSecuType1_StSector) {
        return NO;
    }
    
    if (quote.type1.value == OBJECT_SECUSecuType1_StIndex) {
        return NO;
    }

    if ([quote.market isEqualToString:kYXMarketUsOption]) {
        return NO;
    }
    return YES;
}

+ (YXTimeShareLineType)getFiveDayTimeShareTypeWithQuote:(YXV2Quote *)quote {
    YXTimeShareLineType type = YXTimeShareLineTypeIntra;

    if ([self canSupportTimelineExpand:quote]) {
        
        if ([[YXUserManager shared] getLevelWith:kYXMarketUS] != QuoteLevelDelay && ![YXKLineConfigManager shareInstance].fiveDaysTimelineIntra) {
            type = YXTimeShareLineTypeAll;
        }
    }
    
    return type;
}
+ (YXRtLineType)resetOptionKline: (YXRtLineType)type {
    if (type == YXRtLineTypeWeekKline || type == YXRtLineTypeMonthKline || type == YXRtLineTypeSeasonKline || type == YXRtLineTypeYearKline || type == YXRtLineTypeThirtyMinKline) {
        return YXRtLineTypeDayTimeLine;
    }
    
    return type;
}

+ (BOOL)isUsTradingTime:(YXV2Quote *)quote {
    if (quote.msInfo.status.value == OBJECT_MARKETMarketStatus_MsPreHours) {
        // 盘前
        return YES;
    } else if (quote.msInfo.status.value == OBJECT_MARKETMarketStatus_MsAfterHours) {
        // 盘后
        return YES;
    } else if (quote.msInfo.status.value >= OBJECT_MARKETMarketStatus_MsOpenCall && quote.msInfo.status.value <= OBJECT_MARKETMarketStatus_MsCloseCall) {
        // 盘中
        return YES;
    }
    
    return NO;
}

@end
