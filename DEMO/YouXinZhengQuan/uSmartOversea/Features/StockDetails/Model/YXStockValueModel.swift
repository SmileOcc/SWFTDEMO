//
//  YXStockValueModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/3/20.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

// MARK: - DataClass
struct YXStockValueModel: Codable {
    let info: YXStockValueInfo?
    let permissionFlag: Bool?
    let notShowFlag: Bool?

    enum CodingKeys: String, CodingKey {
        case info
        case permissionFlag = "permission_flag"
        case notShowFlag = "not_show_flag"
    }
}

// MARK: - Info
struct YXStockValueInfo: Codable {
    //let currentFundamentalBrief: YXStockValueCurrentFundamentalBrief?
    //let industry: YXStockValueIndustry?
    //let instrument: YXStockValueInstrument?
    let valueStatus: YXStockValueStatus?
}

// MARK: - CurrentFundamentalBrief
struct YXStockValueCurrentFundamentalBrief: Codable {
    let annualReportDate: String?
}

// MARK: - Industry
struct YXStockValueIndustry: Codable {
    let industryName, stockName: YXStockValueIndustryName?

    enum CodingKeys: String, CodingKey {
        case industryName = "IndustryName"
        case stockName = "StockName"
    }
}

// MARK: - Name
struct YXStockValueIndustryName: Codable {
    let nameCN, nameEn, nameTw: String?

    enum CodingKeys: String, CodingKey {
        case nameCN = "nameCn"
        case nameEn, nameTw
    }
}

// MARK: - Instrument
struct YXStockValueInstrument: Codable {
    let exchangeSymbol, instrumentID, isin, market: String?
    let name, symbol: String?

    enum CodingKeys: String, CodingKey {
        case exchangeSymbol
        case instrumentID = "instrumentId"
        case isin, market, name, symbol
    }
}

// MARK: - ValueStatus
struct YXStockValueStatus: Codable {
    let rateOfReturnEstimate: Double?
    let status: String? //(under,fair, over) //comment:"低估（),公平（fair）,高估（over）"
}


// **************    YXStockTechnicalModel      ***************** //

// MARK: - YXStockTechnicalModel
struct YXStockTechnicalModel: Codable {
    let itemID: Int?
    let market: String?
    let notShowFlag: Bool?
    let productType: Int?
    let jumpH5Flag: Bool?
    let signRankList: [YXStockTechnicalSignRankList]?
    let summaryData: YXStockTechnicalSummaryData?
    let userRight: YXStockTechnicalUserRight?

    enum CodingKeys: String, CodingKey {
        case itemID = "item_id"
        case market
        case notShowFlag = "not_show_flag"
        case jumpH5Flag = "jump_h5_flag"
        case productType = "product_type"
        case signRankList = "sign_rank_list"
        case summaryData = "summary_data"
        case userRight = "user_right"
    }
}

// MARK: - SignRankList
struct YXStockTechnicalSignRankList: Codable {
    let endDate, eventTypeID, eventTypeName, tradeType: String?
    let tradingHorizon: String?

    enum CodingKeys: String, CodingKey {
        case endDate = "end_date"
        case eventTypeID = "event_type_id"
        case eventTypeName = "event_type_name"
        case tradeType = "trade_type"
        case tradingHorizon = "trading_horizon"
    }
}

// MARK: - SummaryData
struct YXStockTechnicalSummaryData: Codable {
    let bearishCount, bullishCount: Int?
    let normalizedScore, resistance, stopsLower, support: String?

    enum CodingKeys: String, CodingKey {
        case bearishCount = "bearish_count"
        case bullishCount = "bullish_count"
        case normalizedScore = "normalized_score"
        case resistance
        case stopsLower = "stops_lower"
        case support
    }
}


// MARK: - UserRight
struct YXStockTechnicalUserRight: Codable {
    let createTime, expireDate, itemID, productType: Int?
    let remainTimes, rightType, updateTime, userID: Int?

    enum CodingKeys: String, CodingKey {
        case createTime = "create_time"
        case expireDate = "expire_date"
        case itemID = "item_id"
        case productType = "product_type"
        case remainTimes = "remain_times"
        case rightType = "right_type"
        case updateTime = "update_time"
        case userID = "user_id"
    }
}



// 大事提醒model
class YXStockEventReminderModel: Codable {
    let noteList: [YXStockEventReminderDetailInfo]?
}


class YXStockEventReminderDetailInfo: Codable {
    let eventId: String?   //事件标志
    let eventContent: String? //事件内容
    let eventDate: String?  //事件发生日期
    let eventTitle: String? //事件标题
    let detailUrl: String? //详情URL
    var isExpand: Bool? = false
    var showYear: Bool? = false
    var openHeight: CGFloat?
    var folderHeight: CGFloat?
    var titleHeight: CGFloat?
}


// 资讯提醒model
class YXStockImportantNewsModel: Codable {
    let list: [YXStockImportantNewsDetailInfo]?
}


class YXStockImportantNewsDetailInfo: Codable {
    let news_id: String?   //资讯id
    let title: String?     //文章标题

}
