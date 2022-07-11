//
//  YXTickerTradeTypeDefine.h
//  YouXinZhengQuan
//
//  Created by youxin on 2021/4/13.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#ifndef YXTickerTradeTypeDefine_h
#define YXTickerTradeTypeDefine_h

typedef NS_ENUM(NSInteger, YXTickerTrdType) {
    //以下枚举用于港股ticker类型
    AUTO_MATCH_NORMAL       = 0,    //Automatch normal (Public  Trade Type <space>)
    LATE_TRADE              = 4,    //Late Trade (Off-exchange  previous day) (Public Trade Type “P”)
    NON_DIRECT_OFF_EXCHANGE = 22,   //Non-direct Off-Exchange Trade (Public Trade Type “M”)
    AUTO_MATCH_INTERNALIZED = 100,  //Automatch internalized (Public  Trade Type “Y”)
    DIRECT_OFF_EXCHANGE     = 101,  //Direct off-exchange Trade(Public Trade Type “X”)
    ODD_LOT_TRADE           = 102,  //Odd-Lot Trade (Public Trade Type “D”)
    AUCTION_TRADE           = 103,  //Auction Trade (Public Trade Type “U”)
    OVERSEAS_TRADE          = 104,  // Overseas Trade

    //以下枚举用于美股ticker类型，从200开始
    US_REGULAR              = 200,  // @, Regular Settlement
    US_BUNCHED              = 201,  // B, Bunched
    US_CASH                 = 202,  // C, Cash Settlement
    US_INTERMARKET_SWEEP    = 203,  // F, Intermarket Sweep
    US_BUNCHED_SOLD         = 204,  // G, Bunched Sold Trade
    US_PRICE_VIRIATION      = 205,  // H, Price Variation Trade
    US_ODD_LOT              = 206,  // I, Odd Lot Trade
    US_RULE_127_Rule_155    = 207,  // K, Rule 127 or Rule 155
    US_SOLD_LAST            = 208,  // L, Sold Last
    US_MARKET_CENTER_CLOSE  = 209,  // M, Market Center Close Price
    US_NEXT_DAY             = 210,  // N, Next Day
    US_MARKET_CENTER_OPENING= 211,  // O, Market Center Opening Trade
    US_PRIOR_REFERENCE_PRICE= 212,  // P, Prior Reference Price
    US_MARKET_CENTER_OPEN   = 213,  // Q, Market Center Open Price
    US_SELLER               = 214,  // R, Seller
    US_FORM_T               = 215,  // T, Form T(Pre-Open and Post-Close Market Trade)
    US_EXTENDED_TRADE_HOUR  = 216,  // U, Extended Trading Hours/Sold out of sequence
    US_CONTINGENT           = 217,  // V, Contingent Trade
    US_AVERAGE_PRICE        = 218,  // W, Average Price Trade
    US_SOLD_OUT_OF_SEQUENCE = 219,  // Z, Sold(Out of Sequence)
    US_ODD_LOT_CROSS        = 220,  // 0, Odd lot cross trade
    US_DERIVATIVELY_PRICED  = 221,  // 4, Derivatively Priced
    US_RE_OPENING_PRICE     = 222,  // 5, Re-Opening Price
    US_CLOSING_PRICE        = 223,  // 6, Closing Price
    US_QUALIFIED_CONTINGENT = 224,  // 7, Qualified Contingent Trade
    US_CONSOLIDATED_LATE_PRC= 225,  // 9, Consolidated late price per listing packet
};


#endif /* YXTickerTradeTypeDefine_h */
