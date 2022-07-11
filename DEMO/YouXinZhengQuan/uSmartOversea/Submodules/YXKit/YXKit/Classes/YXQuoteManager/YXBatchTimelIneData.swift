//
//  YXBatchTimelIneData.swift
//  YouXinZhengQuan
//
//  Created by ellison on 2019/5/8.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation

@objcMembers public class YXBatchTimeLineData: NSObject, Codable {
    public let priceBase: UInt32?
    public let days: Int?
    public let list: [YXBatchTimeLine]?
    
    enum CodingKeys: String, CodingKey {
        case priceBase, days, list
    }
}

@objcMembers public class YXBatchTimeLine: NSObject, Codable {
    public let priceBase: UInt32?
    public let market: String?
    public let symbol: String?
    public let delay: Bool?
    public let type: Int?
    public let data: [SimpeTimeLine]?
    
    enum CodingKeys: String, CodingKey {
        case priceBase, market, symbol, delay, data, type
    }
    
    public init(priceBase: UInt32?, market: String?, symbol: String?, delay: Bool?, type: Int?, data: [SimpeTimeLine]?) {
        self.priceBase = priceBase
        self.market = market
        self.symbol = symbol
        self.delay = delay
        self.data = data
        self.type = type
    }
}

 @objcMembers public class SimpeTimeLine: NSObject, Codable {
    public let latestTime: UInt64?
    public let preClose: Int64?
    public let price: Int64?
                
    enum CodingKeys: String, CodingKey {
        case latestTime, preClose, price
    }
    
    public init(latestTime: UInt64?, preClose: Int64?, price: Int64?) {
        self.latestTime = latestTime
        self.preClose = preClose
        self.price = price
    }
}
