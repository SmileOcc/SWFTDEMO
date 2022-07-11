//
//  YXRemindTool.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/11/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXRemindTool.h"
#import "uSmartOversea-Swift.h"

@implementation YXRemindTool

+ (NSString *)getTitleWithType: (YXReminderType)type {
    NSString *title = @"";
    switch (type) {
        case YXReminderTypePriceUp:
            title = [YXLanguageUtility kLangWithKey:@"remind_price_up"];
            break;
        case YXReminderTypePricDown:
            title = [YXLanguageUtility kLangWithKey:@"remind_price_dowm"];
            break;
        case YXReminderTypeDayUp:
            title = [YXLanguageUtility kLangWithKey:@"remind_rate_up"];
            break;
        case YXReminderTypeDayDown:
            title = [YXLanguageUtility kLangWithKey:@"remind_rate_dowm"];
            break;
        case YXReminderTypePriceFiveMinUp:
            title = [YXLanguageUtility kLangWithKey:@"remind_5min_roc_up"];
            break;
        case YXReminderTypePriceFiveMinDown:
            title = [YXLanguageUtility kLangWithKey:@"remind_5min_roc_down"];
            break;
        case YXReminderTypeTurnoverMore:
            title = [YXLanguageUtility kLangWithKey:@"remind_vol_exceed"];
            break;
        case YXReminderTypeVolumnMore:
            title = [YXLanguageUtility kLangWithKey:@"remind_turnover_exceed"];
            break;
        case YXReminderTypeTurnoverRateMore:
            title = [YXLanguageUtility kLangWithKey:@"remind_turnover_rate_exceed"];
            break;
        case YXReminderTypeOvertopBuyOne:
            title = [YXLanguageUtility kLangWithKey:@"remind_bid_price_exceed"];
            break;
        case YXReminderTypeOvertopSellOne:
            title = [YXLanguageUtility kLangWithKey:@"remind_ask_price_exceed"];
            break;
        case YXReminderTypeOvertopBuyOneTurnover:
            title = [YXLanguageUtility kLangWithKey:@"remind_bid_volumn_exceed"];
            break;
        case YXReminderTypeOvertopSellOneTurnover:
            title = [YXLanguageUtility kLangWithKey:@"remind_ask_volumn_exceed"];
            break;
        case YXReminderTypeClassicTechnical:
            title = [YXLanguageUtility kLangWithKey:@"remind_classic_form"];
            break;
        case YXReminderTypeKline:
            title = [YXLanguageUtility kLangWithKey:@"remind_kline_form"];
            break;
        case YXReminderTypeIndex:
            title = [YXLanguageUtility kLangWithKey:@"remind_indicator_form"];
            break;
        case YXReminderTypeShock:
            title = [YXLanguageUtility kLangWithKey:@"remind_shock_form"];
            break;
        case YXReminderTypeAnnouncement:
            title = [YXLanguageUtility kLangWithKey:@"remind_announcement_alert"];
            break;
        case YXReminderTypePositive:
            title = [YXLanguageUtility kLangWithKey:@"remind_long_signal"];
            break;
        case YXReminderTypeBad:
            title = [YXLanguageUtility kLangWithKey:@"remind_short_signal"];
            break;
        case YXReminderTypeFinancialReport:
            title = [YXLanguageUtility kLangWithKey:@"financial_remind"];
            break;
        default:
            break;
    }
    
    return title;
}

+ (NSString *)getImageNameWithType: (YXReminderType)type {
    NSString *title = @"";
    switch (type) {
        case YXReminderTypePriceUp:
            title = @"price_up";
            break;
        case YXReminderTypePricDown:
            title = @"price_down";
            break;
        case YXReminderTypeDayUp:
            title = @"day_up";
            break;
        case YXReminderTypeDayDown:
            title = @"day_down";
            break;
        case YXReminderTypePriceFiveMinUp:
            title = @"price_five_min_up";
            break;
        case YXReminderTypePriceFiveMinDown:
            title = @"price_five_min_down";
            break;
        case YXReminderTypeTurnoverMore:
            title = @"turnover_more";
            break;
        case YXReminderTypeVolumnMore:
            title = @"volumn_more";
            break;
        case YXReminderTypeTurnoverRateMore:
            title = @"turnover_rate_more";
            break;
        case YXReminderTypeOvertopBuyOne:
            title = @"overtop_buy_one";
            break;
        case YXReminderTypeOvertopSellOne:
            title = @"overtop_sell_one";
            break;
        case YXReminderTypeOvertopBuyOneTurnover:
            title = @"overtop_buy_one_turnover";
            break;
        case YXReminderTypeOvertopSellOneTurnover:
            title = @"overtop_sell_one_turnover";
            break;
        case YXReminderTypeClassicTechnical:
            title = @"classics_type";
            break;
        case YXReminderTypeKline:
            title = @"kline_type";
            break;
        case YXReminderTypeIndex:
            title = @"index_type";
            break;
        case YXReminderTypeShock:
            title = @"shock_type";
            break;
        case YXReminderTypeAnnouncement:
            title = @"announcement_type";
            break;
        case YXReminderTypePositive:
            title = @"positive_type";
            break;
        case YXReminderTypeBad:
            title = @"bear_news_type";
            break;
        case YXReminderTypeFinancialReport:
            title = @"icon_financial_report";
            break;
        default:
            break;
    }
    
    return title;
}


+ (NSString *)getUnitStrWithType: (YXReminderType)type {
    NSString *title = @"";
    switch (type) {
        case YXReminderTypePriceUp:
            title = @"";
            break;
        case YXReminderTypePricDown:
            title = @"";
            break;
        case YXReminderTypeDayUp:
            title = @"%";
            break;
        case YXReminderTypeDayDown:
            title = @"%";
            break;
        case YXReminderTypePriceFiveMinUp:
            title = @"%";
            break;
        case YXReminderTypePriceFiveMinDown:
            title = @"%";
            break;
        case YXReminderTypeTurnoverMore:
            if (YXUserManager.isENMode) {
                title = @"K SHR";
            } else {
                title = [YXLanguageUtility kLangWithKey:@"ten_thousand_shares"];
            }
            break;
        case YXReminderTypeVolumnMore:
            if (YXUserManager.isENMode) {
                title = @"K";
            } else {
                title = [YXLanguageUtility kLangWithKey:@"stock_detail_ten_thousand"];
            }
            break;
        case YXReminderTypeTurnoverRateMore:
            title = @"%";
            break;
        case YXReminderTypeOvertopBuyOne:
            title = @"";
            break;
        case YXReminderTypeOvertopSellOne:
            title = @"";
            break;
        case YXReminderTypeOvertopBuyOneTurnover:
            title = [YXLanguageUtility kLangWithKey:@"remind_stock_thousand_shares"];
            break;
        case YXReminderTypeOvertopSellOneTurnover:
            title = [YXLanguageUtility kLangWithKey:@"remind_stock_thousand_shares"];
            break;
        default:
            title = @"";
            break;
    }
    
    return title;
}


+ (BOOL)isFormWithType: (YXReminderType)type {
    if (type == YXReminderTypeClassicTechnical || type == YXReminderTypeKline || type == YXReminderTypeIndex || type == YXReminderTypeShock || type == YXReminderTypeAnnouncement || type == YXReminderTypePositive  || type == YXReminderTypeBad || type == YXReminderTypeFinancialReport) {
        // 形态
        return YES;
    } else {
        return NO;
    }
}

+ (YXReminderType)getTypeWithReminderModel: (YXReminderModel *)model {
    
    if (model.ntfType > 0) {
        return model.ntfType;
    } else {
        return model.formShowType;
    }
}

+ (NSString *)getPlaceHoldStrWithType: (YXReminderType)type {
    NSString *title = @"";
    switch (type) {
        case YXReminderTypePriceUp:
            title = [YXLanguageUtility kLangWithKey:@"remind_target_price"];
            break;
        case YXReminderTypePricDown:
            title = [YXLanguageUtility kLangWithKey:@"remind_target_price"];
            break;
        case YXReminderTypeDayUp:
            title = [YXLanguageUtility kLangWithKey:@"remind_placeholder_change"];
            break;
        case YXReminderTypeDayDown:
            title = [YXLanguageUtility kLangWithKey:@"remind_placeholder_change"];
            break;
        case YXReminderTypePriceFiveMinUp:
            title = [YXLanguageUtility kLangWithKey:@"remind_placeholder_change"];
            break;
        case YXReminderTypePriceFiveMinDown:
            title = [YXLanguageUtility kLangWithKey:@"remind_placeholder_change"];
            break;
        case YXReminderTypeTurnoverMore:
            title = [YXLanguageUtility kLangWithKey:@"remind_placeholder_volume"];
            break;
        case YXReminderTypeVolumnMore:
            title = [YXLanguageUtility kLangWithKey:@"remind_placeholder_turnover"];
            break;
        case YXReminderTypeTurnoverRateMore:
            title = [YXLanguageUtility kLangWithKey:@"remind_placeholder_turnover_rate"];
            break;
        case YXReminderTypeOvertopBuyOne:
            title = [YXLanguageUtility kLangWithKey:@"remind_placeholder_bid_price"];
            break;
        case YXReminderTypeOvertopSellOne:
            title = [YXLanguageUtility kLangWithKey:@"remind_placeholder_ask_price"];
            break;
        case YXReminderTypeOvertopBuyOneTurnover:
            title = [YXLanguageUtility kLangWithKey:@"remind_placeholder_bid_volume"];
            break;
        case YXReminderTypeOvertopSellOneTurnover:
            title = [YXLanguageUtility kLangWithKey:@"remind_placeholder_ask_volume"];
            break;
        default:
            break;
    }
    
    return title;
}


+ (NSString *)getSimplifiedTitleWithType: (YXReminderType)type {
    NSString *title = @"";
    switch (type) {
        case YXReminderTypePriceUp:
            title = @"股价涨到";
            break;
        case YXReminderTypePricDown:
            title = @"股价跌到";
            break;
        case YXReminderTypeDayUp:
            title = @"日涨幅超过";
            break;
        case YXReminderTypeDayDown:
            title = @"日跌幅超过";
            break;
        case YXReminderTypePriceFiveMinUp:
            title = @"5分钟涨幅超过";
            break;
        case YXReminderTypePriceFiveMinDown:
            title = @"5分钟跌幅超过";
            break;
        case YXReminderTypeTurnoverMore:
            title = @"成交量超过";
            break;
        case YXReminderTypeVolumnMore:
            title = @"成交额超过";
            break;
        case YXReminderTypeTurnoverRateMore:
            title = @"换手率高于";
            break;
        case YXReminderTypeOvertopBuyOne:
            title = @"买一价高于";
            break;
        case YXReminderTypeOvertopSellOne:
            title = @"卖一价低于";
            break;
        case YXReminderTypeOvertopBuyOneTurnover:
            title = @"买一量高于";
            break;
        case YXReminderTypeOvertopSellOneTurnover:
            title = @"卖一量高于";
            break;
        case YXReminderTypeClassicTechnical:
            title = @"经典形态";
            break;
        case YXReminderTypeKline:
            title = @"K线形态";
            break;
        case YXReminderTypeIndex:
            title = @"指标形态";
            break;
        case YXReminderTypeShock:
            title = @"震荡形态";
            break;
        case YXReminderTypeAnnouncement:
            title = @"公告提醒";
            break;
        case YXReminderTypePositive:
            title = @"利好信号提醒";
            break;
        case YXReminderTypeBad:
            title = @"利空信号提醒";
            break;
        default:
            break;
    }
    
    return title;
}

+ (int)getUnitWithType: (YXReminderType)type {
    int a = 1;
    if (type == YXReminderTypeTurnoverMore || type == YXReminderTypeVolumnMore) {
        if ([YXUserManager isENMode]) {
            a = 1000;
        } else {
            a = 10000;
        }
    } else if (type == YXReminderTypeOvertopBuyOneTurnover || type == YXReminderTypeOvertopSellOneTurnover) {
        a = 1000;
    }
    
    return a;
}


+ (NSString *)formatFloat:(double)value andType: (YXReminderType)type {
    if (type == YXReminderTypePriceFiveMinUp || type == YXReminderTypePriceFiveMinDown || type == YXReminderTypeDayUp || type == YXReminderTypeDayDown || type == YXReminderTypeTurnoverRateMore) {
        return [NSString stringWithFormat:@"%.2f", value];
    }
    
    return [NSString stringWithFormat:@"%.3f", value];
}

@end
