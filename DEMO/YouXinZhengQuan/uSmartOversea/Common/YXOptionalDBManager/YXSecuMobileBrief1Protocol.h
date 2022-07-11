//
//  YXSecuMobileBrief1Protocol.h
//  uSmartOversea
//
//  Created by ellison on 2018/12/10.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "proto.h"
/**
 排列顺序
 
 - YXSortStateNormal: 添加顺序
 - YXSortStateDescending: 从高到低
 - YXSortStateAscending: 从低到高
 */
typedef NS_ENUM(NSUInteger, YXSortState){
    YXSortStateNormal     = 0,
    YXSortStateDescending = 1,
    YXSortStateAscending  = 2,
};


/**
 显示类型
 
 - YXMobileBrief1TypeRoc: 涨跌幅
 - YXMobileBrief1TypeChange: 涨跌额
 - YXMobileBrief1TypeMarketValue: 总市值
 - YXMobileBrief1TypeNow: 价格
 - YXMobileBrief1TypeTurnoverRate: 换手率
 - YXMobileBrief1TypeVolume: 成交量
 - YXMobileBrief1TypeAmount: 成交额
 - YXMobileBrief1TypeAmp: 振幅
 - YXMobileBrief1TypeVolumeRatio: 量比
 - YXMobileBrief1TypePeTtm: 市盈率
 - YXMobileBrief1TypePb: 市净率
 */

typedef NS_ENUM(NSUInteger, YXMobileBrief1Type){
    YXMobileBrief1TypeNow           = 0,
    YXMobileBrief1TypeRoc           = 1,
    YXMobileBrief1TypeChange        = 2, //最新价
    YXMobileBrief1TypeTurnoverRate  = 3,
    YXMobileBrief1TypeVolume        = 4,
    YXMobileBrief1TypeAmount        = 5,
    YXMobileBrief1TypeAmp           = 6,
    YXMobileBrief1TypeVolumeRatio   = 7,
    YXMobileBrief1TypeMarketValue   = 8,
    YXMobileBrief1TypePe            = 9,
    YXMobileBrief1TypePb            = 10,
    
    YXMobileBrief1TypeMaturityDate  = 11, //到期日
    YXMobileBrief1TypePremium       = 12, // 溢价
    YXMobileBrief1TypeOutstandingPct= 13, //街货比
    YXMobileBrief1TypeGearing       = 14, //杠杆比率
    YXMobileBrief1TypeConversionRatio= 15, //换股比率
    YXMobileBrief1TypeStrike        = 16, //行使价
    
    YXMobileBrief1TypePurchaseMoney = 18, //起购资金
    YXMobileBrief1TypePurchaseEndDay = 19, //认购截止日
    
    YXMobileBrief1TypeMarketDate    = 22, //上市日期
    YXMobileBrief1TypePublishPrice  = 23, //发行价
    YXMobileBrief1TypeTotalChange   = 27, //累计涨跌幅
    YXMobileBrief1TypeMarketDays    = 24, //上市天数
    YXMobileBrief1TypeFirstOpen     = 25, //首日收盘
    YXMobileBrief1TypeFirstChange   = 26, //首日涨幅
    YXMobileBrief1TypeGreyChgPct   = 28, //暗盘涨跌幅
    YXMobileBrief1TypeWinningRate   = 29, //一手中签率
    
    YXMobileBrief1TypeMarketValueAndNumber,
    YXMobileBrief1TypeLastAndCostPrice,
    YXMobileBrief1TypeHoldingBalance,
    YXMobileBrief1TypeDailyBalance,
    YXMobileBrief1TypeInitialMargin,
    YXMobileBrief1TypeInterestBearing,
    
    YXMobileBrief1TypeOutsidePrice      = 91, //价内价外
    YXMobileBrief1TypeImpliedVolatility = 92, //引申波幅
    YXMobileBrief1TypeActualLeverage    = 93, //实际杠杆
    YXMobileBrief1TypeRecoveryPrice     = 94, //回收价
    YXMobileBrief1TypeToRecoveryPrice   = 95, //距回收价
    
    YXMobileBrief1TypePriceCeiling      = 96, //上限价
    YXMobileBrief1TypePriceFloor        = 97, //下限价
    YXMobileBrief1TypeToPriceCeiling    = 98, //距上限
    YXMobileBrief1TypeToPriceFloor      = 99, //距下限
    
    YXMobileBrief1TypeAccer3            = 100, //3分钟涨跌幅
    YXMobileBrief1TypeMainInflow        = 101, //主力净流入
    YXMobileBrief1TypeNetInflow         = 102, //资金净流入
    YXMobileBrief1TypeDividendYield     = 103, //股息率
    
    YXMobileBrief1TypeDealAmount        = 104, //买卖净股数（A股通）
    YXMobileBrief1TypeFundFlow          = 105, //资金净流向
    YXMobileBrief1TypeDealRatio         = 106, //买卖股数占流通股比例
    YXMobileBrief1TypeYXScore           = 107, //盈立评分
    
    YXMobileBrief1TypeAHSpread          = 108, //AH股溢价
    YXMobileBrief1TypeMarginRatio       = 109, //融资抵押率
    YXMobileBrief1TypeBail              = 110, //最低保证金
    
    YXMobileBrief1TypeYXSelection       = 111, //盈立精选
    YXMobileBrief1TypeLongPosition      = 112, //好仓
    YXMobileBrief1TypeWarrantBuy        = 113, //认购证
    YXMobileBrief1TypeWarrantBull       = 114, //牛证
    YXMobileBrief1TypeShortPosition     = 115, //淡仓
    YXMobileBrief1TypeWarrantSell       = 116, //认沽证
    YXMobileBrief1TypeWarrantBear       = 117, //熊证
    
    YXMobileBrief1TypeGearingRatio      = 118, //杠杆比例

    YXMobileBrief1TypePreAndClosePrice  = 119, //盘前/收盘价
    YXMobileBrief1TypePreRoc            = 120, //盘前涨跌幅
    YXMobileBrief1TypeAfterAndClosePrice= 121, //盘后/收盘价
    YXMobileBrief1TypeAfterRoc          = 122, //盘后涨跌幅
    
    YXMobileBrief1TypeAccer5            = 125, //5分钟涨速
    YXMobileBrief1TypePctChg5day        = 126, //5日历史涨幅
    YXMobileBrief1TypePctChg10day       = 127, //10日涨幅
    YXMobileBrief1TypePctChg30day       = 128, //30日涨幅
    YXMobileBrief1TypePctChg60day       = 129, //60日涨幅
    YXMobileBrief1TypePctChg120day      = 130, //120日涨幅
    YXMobileBrief1TypePctChg250day      = 131, //250日涨幅
    YXMobileBrief1TypePctChg1year       = 132, //1年涨幅
    
    YXMobileBrief1TypeAvgSpread     = 232, //平均买卖差价
    YXMobileBrief1TypeOpenOnTime    = 233, //准时开盘率
    YXMobileBrief1TypeLiquidity     = 234, //流通量
    YXMobileBrief1TypeOneTickSpreadProducts     = 235, //一格差价只数
    YXMobileBrief1TypeOneTickSpreadDuration     = 236, //一格差价时间占比

};

NS_ASSUME_NONNULL_BEGIN

@protocol YXSecuMobileBrief1Protocol <NSObject>

/**
 最新价格，数据字段 1
 */
@property(nonatomic, assign) int64_t now;

/**
 昨收价
 */
@property(nonatomic, assign) int64_t prevClose;

/**
 收盘价
 */
@property(nonatomic, assign) int64_t closePrice;

/**
 涨跌值，数据字段 24
 */
@property(nonatomic, assign) int64_t change;

/**
 涨跌幅, 使用时除以 100，数据字段 25
 */
@property(nonatomic, assign) int32_t roc;

/**
 价格小数计算基数，10的幂次表示，数据字段 price_base
 */
@property(nonatomic, assign) uint32_t priceBase;

/**
 换手率, 使用时除以 100，数据字段 turnover_rate
 */
@property(nonatomic, assign) int32_t turnoverRate;

/**
 周期成交量
 */
@property(nonatomic, assign) uint64_t volume;

/**
 周期成交金额
 */
@property(nonatomic, assign) int64_t amount;

/**
 振幅, 使用时除以 100
 */
@property(nonatomic, assign) int32_t amp;

/**
 量比, 使用时除以 10000，数据字段 volume_ratio
 */
@property(nonatomic, assign) int32_t volumeRatio;

/**
 总市值（流通市值）
 */
@property(nonatomic, assign) int64_t marketValue;

/**
 总市值
 */
@property(nonatomic, assign) int64_t totalMarketvalue;

/**
 市净率，使用时除以 10000
 */
@property(nonatomic, assign) int32_t pb;

/**
 TTM市盈率，使用时除以 10000
 */
@property(nonatomic, assign) int32_t peTtm;

/**
 静态市盈率，使用时除以 10000
 */
@property(nonatomic, assign) int32_t pe;

/**
 交易状态，数据字段 trading_status
 */
@property(nonatomic, assign) OBJECT_QUOTETradingStatus tradingStatus;

@property(nonatomic, assign) OBJECT_MARKETMarketStatus marketStatus;

@property(nonatomic, strong) OBJECT_QUOTESimpleQuote *preQuote;

@property(nonatomic, strong) OBJECT_QUOTESimpleQuote *afterQuote;

/**
 权限级别
 */
@property(nonatomic, assign) int level;

/**
 更新cell时是否用动画
 */
@property(nonatomic, assign) BOOL isUpdatCellAnimation;


/**
 轮证新增字段
 */

/**
是否是轮证
 */
@property (nonatomic, assign) BOOL isWarrants;

/**
  到期日
 */
@property (nonatomic, assign) long long expireDate;

/**
 溢价
 */
@property (nonatomic, assign) int64_t premium;

/**
 街货比
 */
@property (nonatomic, assign) int64_t outstandingRatio;

/**
 有效杠杆
 */
@property (nonatomic, assign) int64_t leverageRatio;

/**
 换股比率
 */
@property (nonatomic, assign) int64_t exchangeRatio;

/**
 行使价
 */
@property (nonatomic, assign) int64_t strikePrice;

/**
 有效杠杆（实际杠杆)
 */
@property (nonatomic, assign) int64_t effectiveLeverage;

/**
 价内/价外
 */
@property (nonatomic, assign) int64_t moneyness;

/**
 引申波幅
 */
@property (nonatomic, assign) int64_t impliedVolatility;

/**
 回收价
 */
@property (nonatomic, assign) int64_t callPrice;

/**
 距回收价
 */
@property (nonatomic, assign) int64_t toCallPrice;


/**
 界内证新增字段
 */

/**
 上限价*10000
 */
@property (nonatomic, assign) int64_t priceCeiling;

/**
 下限价*10000
 */
@property (nonatomic, assign) int64_t priceFloor;

/**
  距上限*100
 */
@property (nonatomic, assign) int64_t toPriceCeiling;

/**
  距下限*100
 */
@property (nonatomic, assign) int64_t toPriceFloor;

/**
 是否暗盘
 */
@property (nonatomic, assign) int greyFlag;

/**
 3分钟涨速
 */
@property (nonatomic, assign) int32_t accer3;

/**
 股息率
 */
@property (nonatomic, assign) int32_t dividendYield;

/**
 资金净流入
 */
@property (nonatomic, assign) int64_t netInflow;

/**
 主力净流入
 */
@property (nonatomic, assign) int64_t mainInflow;

/**
 盈立评分
*/
@property (nonatomic, assign) int score;

/**
 ADR名称
*/
@property (nonatomic, strong) NSString *adrDisplay;

/**
 ADR代码
*/
@property (nonatomic, strong) NSString *adrCode;

/**
 ADR市场
*/
@property (nonatomic, strong) NSString *adrMarket;

/**
 ADR换算价
*/
@property (nonatomic, assign) int64_t adrExchangePrice;

/**
 ADR换算价涨跌幅
*/
@property (nonatomic, assign) int32_t adrPctchng;

/**
 ADR相对港股
*/
@property (nonatomic, assign) int64_t adrPriceSpread;

/**
 ADR相对港股涨跌幅
*/
@property (nonatomic, assign) int32_t adrPriceSpreadRate;

/**
 ah a股最新价
*/
@property (nonatomic, assign) int64_t ahLastestPrice;

/**
 ah a股涨跌
*/
@property (nonatomic, assign) int32_t ahPctchng;

/**
 ah a股涨跌
*/
@property (nonatomic, assign) int32_t ahPriceSpreadRate;

/**
 ah a股涨跌
*/
@property (nonatomic, strong) NSString *hNameAbbr;

/**
 融资抵押率
*/
@property (nonatomic, assign) double marginRatio;

/**
 最低保证金
*/
@property (nonatomic, assign) int32_t bail;

/**
 5分钟涨幅
*/
@property (nonatomic, assign) int32_t accer5;
/**
 5日涨幅
*/
@property (nonatomic, assign) int32_t pct_chg_5day;
/**
 10日涨幅
*/
@property (nonatomic, assign) int32_t pct_chg_10day;
/**
 30日涨幅
*/
@property (nonatomic, assign) int32_t pct_chg_30day;
/**
 60日涨幅
*/
@property (nonatomic, assign) int32_t pct_chg_60day;
/**
 120日涨幅
*/
@property (nonatomic, assign) int32_t pct_chg_120day;
/**
 250日涨幅
*/
@property (nonatomic, assign) int32_t pct_chg_250day;
/**
 1年涨幅
*/
@property (nonatomic, assign) int32_t pct_chg_1year;


/**
 杠杆比例
*/
@property (nonatomic, assign) int32_t gearingRatio;

/**
 时间
*/
@property (nonatomic, strong) NSString *quoteTime;



@end

NS_ASSUME_NONNULL_END
