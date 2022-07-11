//
//  YXHSFinancialData.swift
//  uSmartOversea
//
//  Created by 井超 on 2019/9/29.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation

// MARK: - YXHSFinancialData
struct YXHSFinancialData: Codable {
    var list: [YXHSFinancialDetailData]?
}

// MARK: - List
class YXHSFinancialDetailData: Codable {
    var uniqueSecuCode, secuCode: String?
    var totalRevenues, totalAssets, retainedProfits, totalLiabilities, operationsCash, investingCash, financingCash: Float64?
    var retainedProfitsRate: Double?
    var reportPeriod, currName, year: String?
    var totalLiabilitiesRate: Double?
    var endDate: String?
    
    enum CodingKeys: String, CodingKey {
        case uniqueSecuCode = "unique_secu_code"
        case secuCode = "secu_code"
        case totalRevenues = "total_revenues"
        case retainedProfits = "retained_profits"
        case retainedProfitsRate = "retained_profits_rate"
        case reportPeriod = "report_period"
        case currName = "curr_name"
        case year
        case totalAssets = "total_assets"
        case totalLiabilities = "total_liabilities"
        case operationsCash = "operations_cash"
        case investingCash = "investing_cash"
        case financingCash = "financing_cash"
        case totalLiabilitiesRate = "total_liabilities_rate"
        case endDate = "end_date"
    }
}

