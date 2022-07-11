//
//  YXStockDetailOCTool.m
//  uSmartOversea
//
//  Created by youxin on 2021/4/15.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXStockDetailOCTool.h"
#import "uSmartOversea-Swift.h"

@implementation YXStockDetailOCTool

//A股时，是否允许A股交易 沪股通或深股通 才可以交易
+ (BOOL)notAllowedTradeAStock:(YXV2Quote *)quote {
    BOOL isForbid = NO;
    if ([quote.market isEqualToString:kYXMarketChinaSH] || [quote.market isEqualToString:kYXMarketChinaSZ]) {
        if ([self hkCanTradeSH:quote] || [self hkCanTradeSZ:quote]) {

        } else {
            isForbid = YES;
        }
    }
    return isForbid;
}

/**
 * 沪股通  香港用户 是否可以买 沪股
 */
+ (BOOL)hkCanTradeSH:(YXV2Quote *)quote {
    NSInteger kSHFLag = 0x1;
    if ([quote.market isEqualToString:kYXMarketChinaSH] && ((quote.scmType.value & kSHFLag) > 0)) {
        return YES;
    }
    return NO;
}

/**
 * 深股通   香港用户 是否可以买 深股
 */
+ (BOOL)hkCanTradeSZ:(YXV2Quote *)quote {
    NSInteger kSZFLag = 0x2;
    if ([quote.market isEqualToString:kYXMarketChinaSZ] && ((quote.scmType.value & kSZFLag) > 0)) {
        return YES;
    }
    return NO;
}

/**
 * 港股通（沪）上海用户 是否可以买 港股
 */
+ (BOOL)shCanTradeHK:(YXV2Quote *)quote {
    NSInteger kSZFLag = 0x4;
    if ([quote.market isEqualToString:kYXMarketHK] && ((quote.scmType.value & kSZFLag) > 0)) {
        return YES;
    }
    return NO;
}

/**
 * 港股通（深） 深圳用户 是否可以买 港股
 */
+ (BOOL)szCanTradeHK:(YXV2Quote *)quote {
    NSInteger kSZFLag = 0x8;
    if ([quote.market isEqualToString:kYXMarketHK] && ((quote.scmType.value & kSZFLag) > 0)) {
        return YES;
    }
    return NO;
}

/**
 * 同时支持 香港 和 内地用户 交易
 */
+ (BOOL)canTradeBothHKAndSH:(YXV2Quote *)quote {
    if (([self hkCanTradeSH:quote] || [self shCanTradeHK:quote]) && ([self hkCanTradeSZ:quote] || [self szCanTradeHK:quote])) {
        return YES;
    }
    return NO;
}

+ (NSString *)getQuoteExchangeName:(int64_t)exchangeId {
    NSString *exchangeStr = @"--";
    if (exchangeId == OBJECT_MARKETExchange_Sse) {
        exchangeStr = [YXLanguageUtility kLangWithKey:@"exchange_Sse"];
    } else if (exchangeId == OBJECT_MARKETExchange_Szse) {
        exchangeStr = [YXLanguageUtility kLangWithKey:@"exchange_Szse"];
    } else if (exchangeId == OBJECT_MARKETExchange_Neeq) {
        exchangeStr = [YXLanguageUtility kLangWithKey:@"exchange_Neeq"];
    } else if (exchangeId == OBJECT_MARKETExchange_Hkex) {
        exchangeStr = [YXLanguageUtility kLangWithKey:@"exchange_Hkex"];
    } else if (exchangeId == OBJECT_MARKETExchange_Nasdaq) {
        exchangeStr = [YXLanguageUtility kLangWithKey:@"exchange_Nasdaq"];
    } else if (exchangeId == OBJECT_MARKETExchange_Nyse) {
        exchangeStr = [YXLanguageUtility kLangWithKey:@"exchange_Nyse"];
    } else if (exchangeId == OBJECT_MARKETExchange_Arca) {
        exchangeStr = [YXLanguageUtility kLangWithKey:@"exchange_Arca"];
    } else if (exchangeId == OBJECT_MARKETExchange_Amex) {
        exchangeStr = [YXLanguageUtility kLangWithKey:@"exchange_Amex"];
    } else if (exchangeId == OBJECT_MARKETExchange_Bats) {
        exchangeStr = [YXLanguageUtility kLangWithKey:@"exchange_Bats"];
    } else if (exchangeId == OBJECT_MARKETExchange_Otc) {
        exchangeStr = [YXLanguageUtility kLangWithKey:@"exchange_Otc"];
    } else if (exchangeId == OBJECT_MARKETExchange_Iex) {
        exchangeStr = [YXLanguageUtility kLangWithKey:@"exchange_Iex"];
    } else if (exchangeId == OBJECT_MARKETExchange_Sgx) {
        exchangeStr = [YXLanguageUtility kLangWithKey:@"exchange_Sgx"];
    } else if (exchangeId == OBJECT_MARKETExchange_Otcpk) {
        exchangeStr = [YXLanguageUtility kLangWithKey:@"exchange_Otcpk"];
    } else if (exchangeId == OBJECT_MARKETExchange_Otcbb) {
        exchangeStr = [YXLanguageUtility kLangWithKey:@"exchange_Otcbb"];
    } else if (exchangeId == OBJECT_MARKETExchange_Aoe) {
        exchangeStr = [YXLanguageUtility kLangWithKey:@"exchange_Aoe"];
    } else if (exchangeId == OBJECT_MARKETExchange_Pho) {
        exchangeStr = [YXLanguageUtility kLangWithKey:@"exchange_Pho"];
    } else if (exchangeId == OBJECT_MARKETExchange_Pao) {
        exchangeStr = [YXLanguageUtility kLangWithKey:@"exchange_Pao"];
    } else if (exchangeId == OBJECT_MARKETExchange_Wcb) {
        exchangeStr = [YXLanguageUtility kLangWithKey:@"exchange_Wcb"];
    } else if (exchangeId == OBJECT_MARKETExchange_Iso) {
        exchangeStr = [YXLanguageUtility kLangWithKey:@"exchange_Iso"];
    } else if (exchangeId == OBJECT_MARKETExchange_Box) {
        exchangeStr = [YXLanguageUtility kLangWithKey:@"exchange_Box"];
    } else if (exchangeId == OBJECT_MARKETExchange_Opq) {
        exchangeStr = [YXLanguageUtility kLangWithKey:@"exchange_Opq"];
    } else if (exchangeId == OBJECT_MARKETExchange_Nox) {
        exchangeStr = [YXLanguageUtility kLangWithKey:@"exchange_Nox"];
    } else if (exchangeId == OBJECT_MARKETExchange_C2E) {
        exchangeStr = [YXLanguageUtility kLangWithKey:@"exchange_C2E"];
    } else if (exchangeId == OBJECT_MARKETExchange_Btx) {
        exchangeStr = [YXLanguageUtility kLangWithKey:@"exchange_Btx"];
    } else if (exchangeId == OBJECT_MARKETExchange_Mia) {
        exchangeStr = [YXLanguageUtility kLangWithKey:@"exchange_Mia"];
    } else if (exchangeId == OBJECT_MARKETExchange_Nbz) {
        exchangeStr = [YXLanguageUtility kLangWithKey:@"exchange_Nbz"];
    } else if (exchangeId == OBJECT_MARKETExchange_Isz) {
        exchangeStr = [YXLanguageUtility kLangWithKey:@"exchange_Isz"];
    } else if (exchangeId == OBJECT_MARKETExchange_Isj) {
        exchangeStr = [YXLanguageUtility kLangWithKey:@"exchange_Isj"];
    } else if (exchangeId == OBJECT_MARKETExchange_Bex) {
        exchangeStr = [YXLanguageUtility kLangWithKey:@"exchange_Bex"];
    } else if (exchangeId == OBJECT_MARKETExchange_Mpo) {
        exchangeStr = [YXLanguageUtility kLangWithKey:@"exchange_Mpo"];
    } else if (exchangeId == OBJECT_MARKETExchange_Mix) {
        exchangeStr = [YXLanguageUtility kLangWithKey:@"exchange_Mix"];
    }

    return exchangeStr;
}

+ (NSString *)sectorLabelString:(YXV2Quote * _Nullable)quotaModel {

    NSString *labelString = @"";
    if (quotaModel.listSector.value == OBJECT_MARKETListedSector_LsStar) {
        labelString = @"科创板";
    } else if (quotaModel.listSector.value == OBJECT_MARKETListedSector_LsGemb) {
        labelString = [YXLanguageUtility kLangWithKey:@"markets_news_gem"];
    } else if (quotaModel.listSector.value == OBJECT_MARKETListedSector_LsMain) {
        labelString = [YXLanguageUtility kLangWithKey:@"markets_news_mian_board"];
    } else if (quotaModel.listSector.value == OBJECT_MARKETListedSector_LsCatalist){
        labelString = [YXLanguageUtility kLangWithKey:@"markets_news_cata"];
    }
    

    return labelString;
}

+ (NSString *)levelLabelString:(NSInteger)level {
    NSString *levelString = @"L0";
    if (level == QuoteLevelDelay) {
        levelString = @"L0";
    } else if (level == QuoteLevelBmp || level == QuoteLevelLevel1) {
        levelString = @"L1";
    } else if (level == QuoteLevelLevel2) {
        levelString = @"L2";
    }
    return levelString;
}

+ (BOOL)isUSIndex:(YXV2Quote *)quote{
//    // 道琼斯指数
//    case DJI = ".DJI"
//    // 纳斯达克指数
//    case IXIC = ".IXIC"
//    // 标普500指数
//    case SPX = ".SPX"
    if ([quote.market isEqualToString:kYXMarketUS]) {
        if ([quote.symbol isEqualToString:@".DJI"]
            || [quote.symbol isEqualToString:@".IXIC"]
            || [quote.symbol isEqualToString:@".SPX"]) {
            return YES;
        }else{
            return NO;
        }
    }
    return  NO;
}
@end
