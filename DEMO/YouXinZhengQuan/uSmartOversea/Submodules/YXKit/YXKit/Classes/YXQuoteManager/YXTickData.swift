//
//  YXTickData.swift
//  YXKit
//
//  Created by 付迪宇 on 2019/9/19.
//

import Foundation

@objcMembers public class YXTickPageCtxData: NSObject, Codable {
    public let seq: Int64?
    public let from: Int64?
    public let session: Int64?
    
    public enum CodingKeys: String, CodingKey {
        case seq, from, session
    }
    
    public init(seq: Int64? = nil, from: Int64? = nil, session: Int64? = nil) {
        self.seq = seq
        self.from = from
        self.session = session

    }
}

@objcMembers public class YXTickData: NSObject, Codable {
    public let market: String?  // 市场代码
    public let symbol: String?  // 股票代码
    public let ID: QuoteID?   //市场，代码
    public var priceBase: NumberUInt32? // 价格小数计算基数，10的幂次表示
    public let start: NumberInt64?   // 起始 数字货币是Int类型，正常是String类型
    public var list: [YXTick]?
    public var type: NumberUInt32?  //QuoteType
    public let nextPageStart: NumberInt64? //数字货币 下一页的起始位置
//    public var count: NumberInt32?  //回传请求参数的count
//    public var sortDirection: NumberInt32?  //回传请求参数的sortDirection
    public let greyMarket: NumberInt32? //1：辉立，2：富途
    public var nextPageCtx: YXTickPageCtxData? //3-1接口的分页数据
    public var level: NumberInt32? // 行情权限 等同QuoteLevel的值
    

    public enum CodingKeys: String, CodingKey {
        case ID = "id"
        case market, symbol, priceBase, type, start
        case list, nextPageStart, greyMarket
        case nextPageCtx
        case level
    }

    public init(market: String? = nil, symbol: String? = nil, ID: QuoteID? = nil, priceBase: NumberUInt32? = nil, start: NumberInt64? = nil, list: [YXTick]? = nil, type: NumberUInt32? = nil, nextPageStart: NumberInt64? = nil, greyMarket: NumberInt32? = nil, nextPageCtx: YXTickPageCtxData? = nil, level: NumberInt32? = nil) {
        self.market = market
        self.symbol = symbol
        self.ID = ID
        self.priceBase = priceBase
        self.start = start
        self.list = list
        self.type = type
        self.nextPageStart = nextPageStart
        self.greyMarket = greyMarket
        self.nextPageCtx = nextPageCtx
        self.level = level
    }
    
    @objc public func greyMarketType() -> YXSocketGreyMarketType {
        
        if let value = self.greyMarket?.value, value == YXSocketGreyMarketType.futu.rawValue {
            return .futu
        }
        return .phillip
    }
}


@objcMembers public class YXTick: NSObject, Codable {
    public let id: NumberUInt64?         // 对于客户端请求，用于区分同一时间内不同的分笔数据，同一时间内递增
    public let time: NumberUInt64?              // 时间
    public let latestTime: NumberUInt64?       // 时间
    public let price: NumberInt64?          // 现价  数字货币String, 正常Int64
    public let volume: NumberUInt64?         // 现量  数字货币String, 正常Int64
    public let direction: NumberInt32?  // 方向 0: 默认，1：买，2：卖
    public let tick: NumberUInt32?           // 成交笔数 暂不使用
    public let bidOrderNo: NumberInt64?     // 暂不使用
    public let bidOrderSize: NumberUInt64?   // 暂不使用
    public let askOrderNo: NumberInt64?     // 暂不使用
    public let askOrderSize: NumberUInt64?   // 暂不使用
    public let trdType: NumberUInt32?        // tick交易类型，港股、美股有 （ps：目前前端产品需求不需要用这个字段）
    public var trdTypeString: String?
    public let exchange: NumberInt32?   // 交易所id

    public init(id: NumberUInt64? = nil, time: NumberUInt64? = nil, latestTime: NumberUInt64? = nil, price: NumberInt64? = nil, volume: NumberUInt64? = nil, direction: NumberInt32? = nil, tick: NumberUInt32? = nil, bidOrderNo: NumberInt64? = nil, bidOrderSize: NumberUInt64? = nil, askOrderNo: NumberInt64? = nil, askOrderSize: NumberUInt64? = nil, trdType: NumberUInt32? = nil, exchange: NumberInt32? = nil) {
        self.id = id
        self.time = time
        self.latestTime = latestTime
        self.price = price
        self.volume = volume
        self.direction = direction
        self.tick = tick
        self.bidOrderNo = bidOrderNo
        self.bidOrderSize = bidOrderSize
        self.askOrderNo = askOrderNo
        self.askOrderSize = askOrderSize
        self.trdType = trdType
        self.exchange = exchange
    }
}


