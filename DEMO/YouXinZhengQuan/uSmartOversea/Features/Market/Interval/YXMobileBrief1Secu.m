//
//  YXMobileBrief1Secu.m
//  uSmartOversea
//
//  Created by ellison on 2019/1/7.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXMobileBrief1Secu.h"
#import "uSmartOversea-Swift.h"

@implementation YXMobileBrief1Secu
@synthesize now = _now;
@synthesize change = _change;
@synthesize roc = _roc;
@synthesize priceBase = _priceBase;
@synthesize amount = _amount;
@synthesize amp = _amp;
@synthesize pb = _pb;
@synthesize peTtm = _peTtm;
@synthesize pe = _pe;
@synthesize volume = _volume;
@synthesize turnoverRate = _turnoverRate;
@synthesize marketValue = _marketValue;
@synthesize volumeRatio = _volumeRatio;
@synthesize tradingStatus = _tradingStatus;
@synthesize marketStatus = _marketStatus;
@synthesize level = _level;
@synthesize totalMarketvalue = _totalMarketvalue;
@synthesize expireDate = _expireDate;
@synthesize premium = _premium;
@synthesize outstandingRatio = _outstandingRatio;
@synthesize leverageRatio = _leverageRatio;
@synthesize exchangeRatio = _exchangeRatio;
@synthesize strikePrice = _strikePrice;
@synthesize isWarrants = _isWarrants;
@synthesize effectiveLeverage = _effectiveLeverage;
@synthesize moneyness = _moneyness;
@synthesize impliedVolatility = _impliedVolatility;
@synthesize callPrice = _callPrice;
@synthesize toCallPrice = _toCallPrice;
@synthesize priceCeiling = _priceCeiling;
@synthesize priceFloor = _priceFloor;
@synthesize toPriceCeiling = _toPriceCeiling;
@synthesize toPriceFloor = _toPriceFloor;
@synthesize greyFlag = _greyFlag;
@synthesize accer3 = _accer3;
@synthesize netInflow = _netInflow;
@synthesize mainInflow = _mainInflow;
@synthesize dividendYield = _dividendYield;
@synthesize score = _score;
@synthesize adrExchangePrice = _adrExchangePrice;
@synthesize adrPctchng = _adrPctchng;
@synthesize adrPriceSpread = _adrPriceSpread;
@synthesize adrPriceSpreadRate = _adrPriceSpreadRate;
@synthesize adrDisplay = _adrDisplay;
@synthesize adrCode = _adrCode;
@synthesize adrMarket = _adrMarket;
@synthesize ahLastestPrice = _ahLastestPrice;
@synthesize ahPctchng = _ahPctchng;
@synthesize ahPriceSpreadRate = _ahPriceSpreadRate;
@synthesize hNameAbbr = _hNameAbbr;
@synthesize marginRatio = _marginRatio;
@synthesize bail = _bail;
@synthesize accer5 = _accer5;
@synthesize pct_chg_5day = _pct_chg_5day;
@synthesize pct_chg_10day = _pct_chg_10day;
@synthesize pct_chg_30day = _pct_chg_30day;
@synthesize pct_chg_60day = _pct_chg_60day;
@synthesize pct_chg_120day = _pct_chg_120day;
@synthesize pct_chg_250day = _pct_chg_250day;
@synthesize pct_chg_1year = _pct_chg_1year;
@synthesize gearingRatio = _gearingRatio;
@synthesize prevClose = _prevClose;
@synthesize closePrice = _closePrice;
@synthesize quoteTime = _quoteTime;


- (instancetype)initWithV2Quote:(YXV2Quote *)quote {
    if (self = [super init]) {
        self.name = quote.name;
        self.symbol = quote.symbol;
        self.market = quote.market;
        self.now = quote.latestPrice.value;
        self.change = quote.netchng.value;
        self.roc = quote.pctchng.value;
        self.priceBase = quote.priceBase.value;
        self.amount = quote.amount.value;
        self.amp = quote.amp.value;
        self.pb = quote.pb.value;
        self.pe = quote.pe.value;
        self.peTtm = quote.peTTM.value;
        self.volume = quote.volume.value;
        self.turnoverRate = quote.turnoverRate.value;
        self.marketValue = quote.floatCap.value;
        self.volumeRatio = quote.volumeRatio.value;
        self.tradingStatus = quote.trdStatus.value;
        self.marketStatus = quote.msInfo.status.value;
        self.level = quote.level.value;
        self.totalMarketvalue = quote.mktCap.value;
        self.expireDate = quote.maturityDate.value;
        self.premium = quote.premium.value;
        self.outstandingRatio = quote.outstandingPct.value;
        self.leverageRatio = quote.effgearing.value;
        self.exchangeRatio = quote.conversionRatio.value;
        self.strikePrice = quote.strikePrice.value;
        self.isWarrants = (quote.wrnType != nil && quote.wrnType.value != 0);
        self.effectiveLeverage = _effectiveLeverage;
        self.moneyness = quote.moneyness.value;
        self.impliedVolatility = quote.impliedVolatility.value;
        self.callPrice = quote.callPrice.value;
        self.toCallPrice = 0; // v2quote里暂时没有这个字段，所以无法赋值
        self.priceCeiling = quote.strikeUpper.value;
        self.priceFloor = quote.strikeLower.value;
        self.toPriceCeiling = quote.fromUpper.value;
        self.toPriceFloor = quote.fromLower.value;
        
    }

    return self;
}

@end
