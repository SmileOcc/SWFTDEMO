//
//  YXStockAnalyzeModel.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/7/29.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation

// MARK: - YXStockAnalyzeListModel
struct YXStockAnalyzeListModel: Codable {
    let base, currency: Int?
    let list: YXStockAnalyzeModel?
}

// MARK: - YXStockAnalyzeModel
struct YXStockAnalyzeModel: Codable {
    let symbol: String?
    let score: Double?
    let name, hkRankings, industryRankings, industryName: String?
    let updateTime: String?
    let roeScore, avgRoeScore, growthScore, avgGrowthScore: Double?
    let capacityScore, avgCapacityScore, rateDividendScore, avgRateDividendScore: Double?
    let valuationScore, avgValuationScore, trendScore, avgTrendScore: Double?
    let capitalFlowsScore, avgCapitalFlowsScore, prospectScore: Double?
    
    enum CodingKeys: String, CodingKey {
        case symbol, score, name
        case hkRankings = "hk_rankings"
        case industryRankings = "industry_rankings"
        case industryName = "industry_name"
        case updateTime = "update_time"
        case roeScore = "roe_score"
        case avgRoeScore = "avg_roe_score"
        case growthScore = "growth_score"
        case avgGrowthScore = "avg_growth_score"
        case capacityScore = "capacity_score"
        case avgCapacityScore = "avg_capacity_score"
        case rateDividendScore = "rate_dividend_score"
        case avgRateDividendScore = "avg_rate_dividend_score"
        case valuationScore = "valuation_score"
        case avgValuationScore = "avg_valuation_score"
        case trendScore = "trend_score"
        case avgTrendScore = "avg_trend_score"
        case capitalFlowsScore = "capital_flows_score"
        case avgCapitalFlowsScore = "avg_capital_flows_score"
        case prospectScore = "prospect_score"
    }
}


// MARK: - YXStockAnalyzeCapitalModel
struct YXStockAnalyzeCapitalModel: Codable {
    let priceBase, days: Int?
    let time: Double?
    let total, bin, min, sin: Double?
    let bout, mout, sout, netbin: Double?
    let netmin, netsin, yxStockAnalyzeCapitalModelIn, out: Double?
    let netin, binprop, minprop, sinprop: Double?
    let boutprop, moutprop, soutprop: Double?
    let market, symbol: String?
    
    enum CodingKeys: String, CodingKey {
        case priceBase = "price_base"
        case days, time, total, bin, min, sin, bout, mout, sout, netbin, netmin, netsin
        case yxStockAnalyzeCapitalModelIn = "in"
        case out, netin, binprop, minprop, sinprop, boutprop, moutprop, soutprop, market, symbol
    }
}


// MARK: - YXStockAnalyzeCashFlowListModel
struct YXStockAnalyzeCashFlowListModel: Codable {
    let list: [YXStockAnalyzeCashFlowModel]?
    let price_base: Int?
}

// MARK: - YXStockAnalyzeCashFlowModel
struct YXStockAnalyzeCashFlowModel: Codable {
    let time: Double?
    let listIn, out, netin: Double?
    
    enum CodingKeys: String, CodingKey {
        case time
        case listIn = "in"
        case out, netin
    }
}

struct YXStockShortSellModel: Codable {

    let feeRate, shortStart: Double?
    let maxAvailable: Int?
}



