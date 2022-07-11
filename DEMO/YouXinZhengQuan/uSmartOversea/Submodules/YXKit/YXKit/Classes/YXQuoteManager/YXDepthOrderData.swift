//
//  YXDepthOrderData.swift
//  YXKit
//
//  Created by youxin on 2021/6/25.
//

import UIKit

@objcMembers public class YXDepthOrderData: NSObject, Codable {
    public var market: String?  // 市场代码
    public var symbol: String?  // 股票代码
    public let type: NumberInt32?   //摆盘类型
    public var priceBase: NumberUInt32? // 价格小数计算基数，10的幂次表示
    public var merge: NumberBool? // 是否合并
    public let time: NumberUInt64? // 时间
    public var ask: [YXDepthOrder]? //卖盘
    public var bid: [YXDepthOrder]? //买盘
    
    public enum CodingKeys: String, CodingKey {
        case market, symbol, priceBase, type, merge, time
        case ask, bid
    }

    public init(market: String? = nil, symbol: String? = nil, type: NumberInt32? = nil, priceBase: NumberUInt32? = nil, merge: NumberBool? = nil, time: NumberUInt64? = nil, ask: [YXDepthOrder]? = nil, bid: [YXDepthOrder]? = nil) {
        self.market = market
        self.symbol = symbol
        self.type = type
        self.priceBase = priceBase
        self.merge = merge
        self.time = time
        self.ask = ask
        self.bid = bid
    }
}


@objcMembers public class YXDepthOrder: NSObject, Codable {
   
    public let price: NumberInt64?        // 现价
    public let size: NumberInt64?        // 成交量
    
    public var colorIndex: NumberInt32?
  
    public init(price: NumberInt64? = nil, size: NumberInt64? = nil) {
        self.price = price
        self.size = size
    }
}
