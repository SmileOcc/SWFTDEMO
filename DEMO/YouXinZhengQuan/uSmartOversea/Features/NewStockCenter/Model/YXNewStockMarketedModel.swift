//
//  YXNewStockMarketedModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/5/9.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import Differentiator


// MARK: - WelcomeData
struct YXMarketRankModel: Codable {
    let list: [YXMarketRankCodeModel]?
}

// MARK: - PurpleList
struct YXMarketRankCodeModel: Codable {
    let code: Int?
    let msg: String?
    let level: Int?
    let data: YXMarketRankCodeList?
}

// MARK: - ListData
struct YXMarketRankCodeList: Codable {
    let from, count, total, up: Int?
    let unchange, down, limitUp, limitDown: Int?
    let suspend: Int?
    //let detail: [Int]?
    let rankCode: String?
    let rankMarket: String?
    let sortType, sortDirection, pageDirection: Int?
    var list: [YXMarketRankCodeListInfo]?
    let detail: [Int]?
    var level: Int?
}

// MARK: - FluffyList
struct YXMarketRankCodeListInfo: Codable {
    let secuCode, trdMarket: String?
    let yxCode: String?
    let chsNameAbbr: String?
    let priceBase: Int?
    let quoteTime: Int64?
    let turnover: Int64?
    let quoteType, prevClose, openPrice, latestPrice, accer3, accer5, dividendYield: Int?
    let highPrice, lowPrice, closePrice, avgPrice: Int?
    let netChng, pctChng, volume: Int?
    let outstandingShares, outstandingCap, totalStockIssue, totalMarketValue: Int?
    let inner, outer, peStatic, peTtm: Int?
    let pb, amplitude, volRatio: Int?
    let turnoverRate: Double?
    let ipoFlag: Bool?
    let listDate, netInflow, mainInflow: Int64?
    let listDays, issuePrice, ipoDayPctchng, ipoDayClose: Int?
    let accuPctchng: Int? //累计涨幅
    let leadStock: YXMarketRankLeadStockInfo?
    let adrCode,adrMarket,adrDisplay: String?
    let adrExchangePrice, adrPctchng, adrPriceSpread, adrPriceSpreadRate: Int?
    let ahCode,ahMarket,hNameAbbr: String?
    let ahLastestPrice, ahPreclose, ahPctchng, ahExchangePrice,ahPriceSpread,ahPriceSpreadRate: Int?
    let bail: Int?
    let marginRatio: Double? // 融资抵押率
    let greyChgPct, winningRate: Double? // 暗盘涨跌幅 // 一手中签率
    let gearingRatio: Int?  // 杠杆比例
    let high_52week, low_52week: Int?
    let cittthan: Int64?
    let bid, bidSize: Int64? //买入
    let ask, askSize: Int64? //卖出
    let currency:String?
    let expiryDate: Int64? //货币 到期日
    let divAmountYear:Int64? //年股息
    let divYieldYear:Int64? //年股息率
    
}

struct YXMarketRankLeadStockInfo: Codable {
    let secuCode, trdMarket: String
    let chsNameAbbr: String?
    let priceBase: Int?
    let quoteTime: Int64?
    let turnover: Int64?
    let quoteType, prevClose, openPrice, latestPrice: Int?
    let highPrice, lowPrice, closePrice, avgPrice: Int?
    let netChng, pctChng, volume: Int?
    let outstandingShares, outstandingCap, totalStockIssue, totalMarketValue: Int?
    let inner, outer, peStatic, peTtm: Int?
    let pb, amplitude, volRatio: Int?
    let turnoverRate: Double?
    let ipoFlag: Bool?
    let listDate: Int64?
    let listDays, issuePrice, ipoDayPctchng, ipoDayClose: Int?
    let accuPctchng: Int?
}

extension YXMarketRankCodeListInfo: IdentifiableType {
    typealias Identity = String

    var identity: String {
        (trdMarket ?? "") + (secuCode ?? "")
    }
}


extension Decodable where Self: Any  {
    static func JSONModel(data:[String:Any]) throws -> Self? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []) else {
            return nil
        }
        let model = try? JSONDecoder().decode(self, from: jsonData)
        return model
    }
}
