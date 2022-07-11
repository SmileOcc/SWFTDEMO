//
//  YXKLineData.swift
//  YXKit
//
//  Created by 付迪宇 on 2019/9/18.
//

import Foundation

@objcMembers public class YXBatchKLineData: NSObject, Codable {
    public var list: [YXKLineData]?

    @objc public init(list: [YXKLineData]?) {
        self.list = list
    }
}

@objcMembers public class YXKLineData: NSObject, Codable {
    public var priceBase: NumberUInt32? // 价格小数计算基数，10的幂次表示
    public let type: NumberInt32?            // k线类型
    public let start: NumberInt64?           // 起始时间
    public var direction: String?       // 复权类型
    public var list: [YXKLine]?
    public let market: String?          // 市场代码
    public let symbol: String?          // 股票代码
    public let nextPageStart: NumberInt64? //数字货币 下一页的起始位置
    public let ID: QuoteID?   //市场，代码
    public let count: NumberInt32?  //回传请求参数的count
    public let greyMarket: NumberInt32? //1：辉立，2：富途

    public enum CodingKeys: String, CodingKey {
        case ID = "id"
        case market, symbol, priceBase, type, start, direction
        case list, nextPageStart, count, greyMarket
    }
    
    @objc public init(priceBase: NumberUInt32? = nil, type: NumberInt32? = nil , start: NumberInt64? = nil, direction: String? = nil, list: [YXKLine]? = nil, market: String? = nil, symbol: String? = nil, nextPageStart: NumberInt64? = nil, ID: QuoteID? = nil, count: NumberInt32? = nil, greyMarket: NumberInt32? = nil) {
        self.priceBase = priceBase
        self.type = type
        self.start = start
        self.direction = direction
        self.list = list
        self.market = market
        self.symbol = symbol
        self.nextPageStart = nextPageStart
        self.ID = ID
        self.count = count
        self.greyMarket = greyMarket
    }
    
    @objc public func greyMarketType() -> YXSocketGreyMarketType {
        
        if let value = self.greyMarket?.value, value == YXSocketGreyMarketType.futu.rawValue {
            return .futu
        }
        return .phillip
    }
}

@objcMembers public class YXKLine: NSObject, Codable {
    public let latestTime: NumberUInt64?         // 时间
    public let preClose: NumberInt64?       // 昨收
    public let open: NumberInt64?           // 开盘价
    public let close: NumberInt64?          // 收盘价
    public let high: NumberInt64?           // 最高价
    public let low: NumberInt64?            // 最低价
    public let avg: NumberInt64?                 // 均价
    public let volume: NumberUInt64?        // 成交量
    public let amount: NumberInt64?         // 成交金额
    public let netchng: NumberInt64?        // 涨跌额
    public let pctchng: NumberInt32?        // 涨跌幅
    public let turnoverRate: NumberInt32?        // 换手率
    public let postVolume: NumberUInt64?         // 盘后量 科创板使用
    public let postAmount: NumberInt64?          // 盘后额 科创板使用
    public let impliedVolatility: NumberInt32?   // 隐含波动率
    
    public var priceBase: NumberUInt32?
    public var index: NumberInt64?
    
    public var closePoint: NumberDouble?
    
    public var ma5: NumberDouble?
    public var ma20: NumberDouble?
    public var ma60: NumberDouble?
    public var ma120: NumberDouble?
    public var ma250: NumberDouble?

    public var ema5: NumberDouble?
    public var ema12: NumberDouble?
    public var ema20: NumberDouble?
    public var ema26: NumberDouble?
    public var ema60: NumberDouble?
    public var ema120: NumberDouble?
    public var ema250: NumberDouble?
    
    public var BOLL_SUBMD: NumberDouble?
    public var BOLL_SUBMD_SUM: NumberDouble?
    public var bollMD: NumberDouble?
    public var bollUP: NumberDouble?
    public var bollMB: NumberDouble?
    public var bollDN: NumberDouble?
    public var bollMA20: NumberDouble?
    
    public var MACD: NumberDouble?
    public var MACD_MA12: NumberDouble?
    public var MACD_MA26: NumberDouble?
    public var DIF: NumberDouble?
    public var DEA: NumberDouble?
    public var fabs_MACD: NumberDouble?
    
    public var NineClocksMinPrice: NumberDouble?
    public var NineClocksMaxPrice: NumberDouble?
    public var RSV_9: NumberDouble?
    public var KDJ_K: NumberDouble?
    public var KDJ_D: NumberDouble?
    public var KDJ_J: NumberDouble?
    
    public var RSI_6: NumberDouble?
    public var RSI_12: NumberDouble?
    public var RSI_24: NumberDouble?
    public var rsi_up_sma6: NumberDouble?
    public var rsi_sum_sma6: NumberDouble?
    public var rsi_up_sma12: NumberDouble?
    public var rsi_sum_sma12: NumberDouble?
    public var rsi_up_sma24: NumberDouble?
    public var rsi_sum_sma24: NumberDouble?

    public var RSI_6_flag: NumberInt32?
    public var RSI_12_flag: NumberInt32?
    public var RSI_24_flag: NumberInt32?
    
    public var sar: NumberDouble?
    
    public var mDIF: NumberDouble?
    public var mAMA: NumberDouble?
    
    public var AR: NumberDouble?
    public var BR: NumberDouble?
    
    public var WR1: NumberDouble?
    public var WR2: NumberDouble?
    
    public var EMV: NumberDouble?
    public var AEMV: NumberDouble?
    
    public var CR: NumberDouble?
    public var CR1: NumberDouble?
    public var CR2: NumberDouble?
    public var CR3: NumberDouble?
    public var CR4: NumberDouble?
    
    public var MVOL5: NumberDouble?
    public var MVOL10: NumberDouble?
    public var MVOL20: NumberDouble?
    
    public var usmartMA20: NumberDouble?
    public var usmartA: NumberDouble?
    public var usmartA20: NumberDouble?
    public var usmartUp: NumberDouble?
    public var usmartDown: NumberDouble?
    
    public var usmartSignalHold: NumberInt64?
    public var usmartSignalChg: NumberInt64?

    public var klineEvents: [YXKLineInsideEvent]?
    
    enum CodingKeys: String, CodingKey {
        case latestTime, preClose
        case open = "open"
        case close, high, low, avg, volume, amount, netchng, pctchng, turnoverRate
        case postVolume, postAmount, impliedVolatility
    }
    
    public init(latestTime: NumberUInt64? = nil, preClose: NumberInt64? = nil, open: NumberInt64? = nil, close: NumberInt64? = nil, high: NumberInt64? = nil, low: NumberInt64? = nil, avg: NumberInt64? = nil, volume: NumberUInt64? = nil, amount: NumberInt64? = nil, netchng: NumberInt64? = nil, pctchng: NumberInt32? = nil, turnoverRate: NumberInt32? = nil, postVolume: NumberUInt64? = nil, postAmount: NumberInt64? = nil, impliedVolatility: NumberInt32? = nil) {
        self.latestTime = latestTime
        self.preClose = preClose
        self.open = open
        self.close = close
        self.high = high
        self.low = low
        self.avg = avg
        self.volume = volume
        self.amount = amount
        self.netchng = netchng
        self.pctchng = pctchng
        self.turnoverRate = turnoverRate
        self.postVolume = postVolume
        self.postAmount = postAmount
        self.impliedVolatility = impliedVolatility
    }
}


@objcMembers public class YXKLineInsideEvent: NSObject, Codable {

    public var type: NumberInt32? //事件类型：0：交易订单，1：发布财报，2：分红派息
    public var context: String? //事件类型为（1：发布财报，2：分红派息）时的显示信息
    public var quarterType: String? //季度
    public var bought: [YXKLineInsideOrderDetail]?
    public var sold: [YXKLineInsideOrderDetail]?
}


@objcMembers public class YXKLineInsideOrderDetail: NSObject, Codable {
    public var price: NumberInt64?  //金额
    public var volume: NumberInt64? //量
    public var orderType: NumberInt32?  //订单类型，0：普通，1：日内融，2：期权
}
