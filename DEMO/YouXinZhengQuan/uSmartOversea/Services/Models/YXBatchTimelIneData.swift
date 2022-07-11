//
//  YXBatchTimelIneData.swift
//  YouXinZhengQuan
//
//  Created by ellison on 2019/5/8.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation

struct YXBatchTimeLineData: Codable {
    let list: [YXBatchTimeLine]?
}

public struct YXBatchTimeLine: Codable, Equatable {
    public let priceBase: Int?
    public let market: String?
    public let symbol: String?
    public let delay: Bool?
    public let type: Int?
    public let data: [SimpeTimeLine]?
    
    enum CodingKeys: String, CodingKey {
        case priceBase = "price_base"
        case market = "market"
        case symbol = "symbol"
        case delay = "delay"
        case data = "data"
        case type
    }
    
    public init(priceBase: Int?, market: String?, symbol: String?, delay: Bool?, type: Int?, data: [SimpeTimeLine]?) {
        self.priceBase = priceBase
        self.market = market
        self.symbol = symbol
        self.delay = delay
        self.data = data
        self.type = type
    }
}

public struct SimpeTimeLine: Codable, Equatable {
    public let time: Int64?
    public let pclose: Int?
    public let price: Int?
    
    enum CodingKeys: String, CodingKey {
        case time = "time"
        case pclose = "pclose"
        case price = "price"
    }
    
    public init(time: Int64?, pclose: Int?, price: Int?) {
        self.time = time
        self.pclose = pclose
        self.price = price
    }
}
