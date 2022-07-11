//
//  YXHSStockIntroduceModel.swift
//  uSmartOversea
//
//  Created by 井超 on 2019/9/30.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXHSStockIntroduceModel: Codable {

    var profile: YXHSIntroduceProfile?
    var conception: [YXHSConception]?
    var maincompbus, maincomparea: [YXHSIntroduceMaincomp]?
    var holder: YXHSIntroduceHolder?
    var dividend: [YXHSIntroduceDividend]?
}

// MARK: - YXHSIntroduceHolder
struct YXHSIntroduceHolder: Codable {
    let holderNum: Double?
    let holdingEach: Double?
    let topShareHolderName: String?
    let topShareHoldingRate, shareHoldingRate: Double?
    let shareHoldingCount, floatHoldingRate, floatHoldingCount: Double?
    let organHoldingRate: Double?
    let organHoldingCount: Double?
    let pledgeNum: Double?
    
    enum CodingKeys: String, CodingKey {
        case holderNum = "holder_num"
        case holdingEach = "holding_each"
        case topShareHolderName = "top_share_holder_name"
        case topShareHoldingRate = "top_share_holding_rate"
        case shareHoldingRate = "share_holding_rate"
        case shareHoldingCount = "share_holding_count"
        case floatHoldingRate = "float_holding_rate"
        case floatHoldingCount = "float_holding_count"
        case organHoldingRate = "organ_holding_rate"
        case organHoldingCount = "organ_holding_count"
        case pledgeNum = "pledge_num"
    }
}


struct YXHSConception: Codable {
    let conceptionCode, conceptionName, conceptionCodeYx: String?
    let conceptionPctchng: Double?
    
    enum CodingKeys: String, CodingKey {
        case conceptionCode = "conception_code"
        case conceptionName = "conception_name"
        case conceptionPctchng = "conception_pctchng"
        case conceptionCodeYx = "conception_code_yx"
    }
}

struct YXHSIntroduceProfile: Codable {
    let uniqueSecuCode, secuCode, windCode, reportPeriod: String?
    let compID, compName, compSname, listedDate: String?
    let chairman, crncyCode, compBrief, mainBusiness: String?
    let industryCode: String?
    let industryCodeYx: String?
    let industryName: String?
    let industryPctchng: Double?
    
    enum CodingKeys: String, CodingKey {
        case uniqueSecuCode = "unique_secu_code"
        case secuCode = "secu_code"
        case windCode = "wind_code"
        case reportPeriod = "report_period"
        case compID = "comp_id"
        case compName = "comp_name"
        case compSname = "comp_sname"
        case listedDate = "listed_date"
        case chairman
        case crncyCode = "crncy_code"
        case compBrief = "comp_brief"
        case mainBusiness = "main_business"
        case industryCode = "industry_code"
        case industryCodeYx = "industry_code_yx"
        case industryName = "industry_name"
        case industryPctchng = "industry_pctchng"
    }
}

struct YXHSIntroduceMaincomp: Codable {
    let reportPeriod, crncyCode, classification, mainBusiness: String?
    let businessIncome, businessIncomeRate: Double?
    let businessIncomeRateYoy: Double?
    let businessProfit, businessProfitRate, businessProfitRateYoy, businessCost: Double?
    let businessCostRate, businessCostRateYoy: Double?
    
    enum CodingKeys: String, CodingKey {
        case reportPeriod = "report_period"
        case crncyCode = "crncy_code"
        case classification
        case mainBusiness = "main_business"
        case businessIncome = "business_income"
        case businessIncomeRate = "business_income_rate"
        case businessIncomeRateYoy = "business_income_rate_yoy"
        case businessProfit = "business_profit"
        case businessProfitRate = "business_profit_rate"
        case businessProfitRateYoy = "business_profit_rate_yoy"
        case businessCost = "business_cost"
        case businessCostRate = "business_cost_rate"
        case businessCostRateYoy = "business_cost_rate_yoy"
    }
}




// MARK: - YXHSIntroduceMaincomp
struct YXHSDividendRecord: Codable {
    let list: [YXHSIntroduceDividend]?
}

// MARK: - List
struct YXHSIntroduceDividend: Codable {
    let uniqueSecuCode, secuCode, exDate, divPayoutDate: String?
    let exDesc, exType: String?
    
    enum CodingKeys: String, CodingKey {
        case uniqueSecuCode = "unique_secu_code"
        case secuCode = "secu_code"
        case exDate = "ex_date"
        case divPayoutDate = "div_payout_date"
        case exDesc = "ex_desc"
        case exType = "ex_type"
    }
}


