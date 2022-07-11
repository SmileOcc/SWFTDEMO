//
//  YXFinancialData.swift
//  uSmartOversea
//
//  Created by Kelvin on 2019/5/1.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import YXKit

struct YXFinancialData: Codable {
    var list: [YXFinancialDetailData]?
    init(list: [YXFinancialDetailData]?) {
        self.list = list
    }
}

class YXFinancialDetailData: Codable {
    
    var currUnit: String?
    var fiscalYear: Int?
    var fiscalQuarter: Int?
    var calendarYear: Int?
    var calendarQuarter: Int?
    
    var operatingIncome: Float64?
    var netIncome: Float64?
    var retainedProfitsRate: Float64?
    
    var totalAssets: Float64?
    var totalLiabilities: Float64?
    var totalLiabilitiesRate: Double?
    
    var cashFromOperations: Float64?
    var cashFromFinancing: Float64?
    var cashFromInvesting: Float64?
    
    var currName: String?

    var endDate: String?
    
    var isHS = false
    
    enum CodingKeys: String, CodingKey {
        case operatingIncome = "operating_income"
        case netIncome = "net_income"
        case totalAssets = "total_assets"
        case totalLiabilities = "total_liabilities"
        case currUnit = "curr_unit"
        case cashFromOperations = "cash_from_operations"
        case cashFromFinancing = "cash_from_financing"
        case cashFromInvesting = "cash_from_investing"
        case fiscalYear = "fiscal_year"
        case fiscalQuarter = "fiscal_quarter"
        case calendarYear = "calendar_year"
        case calendarQuarter = "calendar_quarter"
        case currName = "curr_name"
        case retainedProfitsRate = "retained_profits_rate"
        case totalLiabilitiesRate = "total_liabilities_rate"
        case endDate = "end_date"
    }
    
    init() {
        
    }
    
}

