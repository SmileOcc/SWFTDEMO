//
//  YXExchangeStatisticalModel.h
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2022/1/14.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXExchangeStatisticalSubModel : NSObject
///价格，真实值除以10^priceBase
@property (nonatomic, assign) int64_t tradePrice;
///成交量
@property (nonatomic, assign) int64_t volume;
///成交额
@property (nonatomic, assign) int64_t amount;
///主卖成交量
@property (nonatomic, assign) int64_t askSize;
///主买成交量
@property (nonatomic, assign) int64_t bidSize;
///平盘成交量
@property (nonatomic, assign) int64_t bothSize;
///成交额占比，真实值除以10000
@property (nonatomic, assign) int64_t amtRate;
///成交量占比，真实值除以10000
@property (nonatomic, assign) int64_t volRate;
/////交易所
@property (nonatomic, assign) int64_t exchange;
@end

@interface YXExchangeStatisticalModel : NSObject

@property (nonatomic, assign) NSInteger priceBase;
///1：辉立，2：富途
@property (nonatomic, assign) int greyMarket;
///平均成交价
@property (nonatomic, assign) int64_t avgTradePrice;
///总成交量
@property (nonatomic, assign) int64_t totalTradeVol;
///总成交笔数
@property (nonatomic, assign) int64_t totalTradeCount;
///主动卖出股数
@property (nonatomic, assign) int64_t totalAskCount;
///主动买入股数
@property (nonatomic, assign) int64_t totalBidCount;
///中性盘股数
@property (nonatomic, assign) int64_t totalBothCount;

@property (nonatomic, strong) NSArray<YXExchangeStatisticalSubModel *> *exchangeData;

///最后更新时间
@property (nonatomic, strong) NSString *latestTime;


@end

NS_ASSUME_NONNULL_END
