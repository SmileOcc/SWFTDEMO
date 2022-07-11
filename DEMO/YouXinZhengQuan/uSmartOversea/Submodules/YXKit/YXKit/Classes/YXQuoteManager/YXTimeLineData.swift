//
//  YXTimeLineData.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2019/9/16.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation

@objcMembers public class YXFullSubTimeLineData: NSObject {
    
    public var date: NumberInt64 = NumberInt64.init(0)
    public var preList: [YXTimeLine] = []      // 盘前
    public var intraList: [YXTimeLine] = []      // 盘中
    public var afterList: [YXTimeLine] = []      // 盘后
    public var isHalf: Bool = false              // 是否是半日分时
}

@objcMembers public class YXFullTimeLineData: NSObject, Codable {
    public var priceBase: NumberUInt32? // 价格小数计算基数，10的幂次表示
    public let days: NumberUInt32?      // 几日分时
    public var data: JSONAny?
    public let market: String?          // 市场代码
    public let symbol: String?          // 股票代码
    public let session: NumberUInt32?      // QuoteType
    public let greyMarket: NumberInt32? //1：辉立，2：富途
    public var dayList: [YXFullSubTimeLineData]?
    
    enum CodingKeys: String, CodingKey {
        case priceBase, days, market, symbol, session, greyMarket, data
    }
    
    public init(priceBase: NumberUInt32? = nil, days: NumberUInt32? = nil, market: String? = nil, symbol: String? = nil, session: NumberUInt32? = nil, greyMarket: NumberInt32? = nil, data: JSONAny? = nil) {
        self.priceBase = priceBase
        self.days = days
        self.market = market
        self.symbol = symbol
        self.session = session
        self.greyMarket = greyMarket
        self.data = data
    }
    
    @objc public func greyMarketType() -> YXSocketGreyMarketType {
        
        if let value = self.greyMarket?.value, value == YXSocketGreyMarketType.futu.rawValue {
            return .futu
        }
        return .phillip
    }
    
    func decodeTimeList() {

        var dayList: [YXFullSubTimeLineData] = []
        if let list = data?.value as? [[String: Any]] {
            list.forEach { dic in
                let timeLineModel = YXFullSubTimeLineData.init()
                let date = (dic["date"] as? Int64) ?? 0
                timeLineModel.date = NumberInt64.init(date)
                dayList.append(timeLineModel)
                if let dayList = dic["list"] as? [[String: Any]] {
                    dayList.forEach { dayDic in
                        //0：普通盘中行情，1：暗盘全日（16:15~18:30），2：暗盘半日（14:15~16:30）,3：科创版分时, 4：盘前行情，5：盘后行情，6：美股盘后半日市（13:00~17:00）。
                        let type = (dayDic["type"] as? Int64) ?? 0
                        let timeList = dayDic["list"] as? [[String: Any]]
                        if let json = timeList, JSONSerialization.isValidJSONObject(timeList) {
                            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
                            if let data = data {
                                let a = (try? JSONDecoder().decode([YXTimeLine].self, from: data)) ?? [YXTimeLine]()
                                if type == 0 {
                                    timeLineModel.intraList.append(contentsOf: a)
                                } else if type == 4 {
                                    timeLineModel.preList.append(contentsOf: a)
                                } else if type == 5 {
                                    timeLineModel.afterList.append(contentsOf: a)
                                } else if type == 6 {
                                    timeLineModel.isHalf = true
                                    timeLineModel.afterList.append(contentsOf: a)
                                }
                            }
                        }
                        
                    }
                }
            }
        }
        
        self.dayList = dayList
        
    }
    
    func transformTimeLineData() -> YXTimeLineData {
        let timeLine = YXTimeLineData.init(priceBase: priceBase, days: days, list: nil, market: market, symbol: symbol, type: NumberUInt32.init(20), greyMarket: greyMarket, isAll: NumberBool.init(true))
        
        var list: [YXTimeLine] = []
        dayList?.forEach({ timeData in
            if let a = timeData.preList.last?.latestTime, let b = timeData.intraList.first?.latestTime {
                if a.value == b.value {
                    //盘前最后一个和盘中的第一个,丢弃掉一个
                    timeData.preList.removeLast()
                }
            }
            if let a = timeData.intraList.last?.latestTime, let b = timeData.afterList.first?.latestTime {
                if a.value == b.value {
                    //盘前最后一个和盘中的第一个,丢弃掉一个
                    timeData.afterList.removeFirst()
                }
                if timeData.isHalf {
                    timeLine.type = NumberUInt32.init(6)
                }
            }
            list.append(contentsOf: timeData.preList)
            list.append(contentsOf: timeData.intraList)
            list.append(contentsOf: timeData.afterList)
        })
        
        timeLine.list = list
        return timeLine
    }
}

@objcMembers public class YXTimeLineData: NSObject, Codable {
    public var priceBase: NumberUInt32? // 价格小数计算基数，10的幂次表示
    public let days: NumberUInt32?      // 几日分时
    public var list: [YXTimeLine]?
    public let market: String?          // 市场代码
    public let symbol: String?          // 股票代码
    public var type: NumberUInt32?      // QuoteType
    public let greyMarket: NumberInt32? //1：辉立，2：富途
    public let isAll: NumberBool?             // 是否是全部分时
    
    enum CodingKeys: String, CodingKey {
        case priceBase, days, list, market, symbol, type, greyMarket, isAll
    }
    
    public init(priceBase: NumberUInt32? = nil, days: NumberUInt32? = nil, list: [YXTimeLine]? = nil, market: String? = nil, symbol: String? = nil, type: NumberUInt32? = nil, greyMarket: NumberInt32? = nil, isAll: NumberBool? = nil) {
        self.priceBase = priceBase
        self.days = days
        self.list = list
        self.market = market
        self.symbol = symbol
        self.type = type
        self.greyMarket = greyMarket
        self.isAll = isAll
    }
    
    @objc public func greyMarketType() -> YXSocketGreyMarketType {
        
        if let value = self.greyMarket?.value, value == YXSocketGreyMarketType.futu.rawValue {
            return .futu
        }
        return .phillip
    }
}

// MARK: - List
@objcMembers public class YXTimeLine: NSObject, Codable {
    public let latestTime: NumberUInt64?    // 时间
    public let preClose: NumberInt64?       // 昨收
    public let price: NumberInt64?          // 现价
    public let avg: NumberInt64?            // 均价
    public let volume: NumberUInt64?        // 成交量
    public let amount: NumberInt64?         // 成交金额
    public let netchng: NumberInt64?        // 涨跌值
    public let pctchng: NumberInt32?        // 涨跌幅, 使用时除以 100
    public var priceBase: NumberUInt32?

    public var klineEvents: [YXKLineInsideEvent]?
    
    public init(latestTime: NumberUInt64? = nil, preClose: NumberInt64? = nil, price: NumberInt64? = nil, avg: NumberInt64? = nil, volume: NumberUInt64? = nil, amount: NumberInt64? = nil, netchng: NumberInt64? = nil, pctchng: NumberInt32? = nil) {
        self.latestTime = latestTime
        self.preClose = preClose
        self.price = price
        self.avg = avg
        self.volume = volume
        self.amount = amount
        self.netchng = netchng
        self.pctchng = pctchng
    }
}


