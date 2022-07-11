//
//  YXMarketDetailSecu.m
//  uSmartOversea
//
//  Created by ellison on 2019/1/7.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXMarketDetailSecu.h"

@implementation YXMarketDetailSecu

+ (NSDictionary<NSString *, id> *)modelCustomPropertyMapper{
    return @{
        @"market": @"trdMarket",
        @"symbol": @"secuCode",
        @"name": @"chsNameAbbr",
        @"now": @"latestPrice",
        @"change": @"netChng",
        @"roc": @"pctChng",
        @"priceBase": @"priceBase",
        @"amount": @"turnover",
        @"amp": @"amplitude",
        @"pe": @"peStatic",
        @"turnoverRate": @"turnoverRate",
        @"marketValue": @"outstandingCap", // 流通市值
        @"volumeRatio": @"volRatio",
        @"totalMarketvalue": @"totalMarketValue" // 总市值
    };
}

@end
