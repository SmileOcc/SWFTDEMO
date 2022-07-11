//
//  YXStockDetailOCTool.h
//  uSmartOversea
//
//  Created by youxin on 2021/4/15.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class YXV2Quote;
@interface YXStockDetailOCTool : NSObject

//A股时，是否允许A股交易 沪股通或深股通 才可以交易
+ (BOOL)notAllowedTradeAStock:(YXV2Quote *)quote;

/**
 * 沪股通  香港用户 是否可以买 沪股
 */
+ (BOOL)hkCanTradeSH:(YXV2Quote *)quote;

/**
 * 深股通   香港用户 是否可以买 深股
 */
+ (BOOL)hkCanTradeSZ:(YXV2Quote *)quote;

/**
 * 港股通（沪）上海用户 是否可以买 港股
 */
+ (BOOL)shCanTradeHK:(YXV2Quote *)quote;

/**
 * 港股通（深） 深圳用户 是否可以买 港股
 */
+ (BOOL)szCanTradeHK:(YXV2Quote *)quote;

/**
 * 同时支持 香港 和 内地用户 交易
 */
+ (BOOL)canTradeBothHKAndSH:(YXV2Quote *)quote;

+ (NSString *)getQuoteExchangeName:(int64_t)exchangeId;

+ (NSString *)sectorLabelString:(YXV2Quote * _Nullable)quotaModel;

+ (NSString *)levelLabelString:(NSInteger)level;

/**
 *  是否为美股三大指数
 */
+ (BOOL)isUSIndex:(YXV2Quote *)quote;
@end

NS_ASSUME_NONNULL_END
