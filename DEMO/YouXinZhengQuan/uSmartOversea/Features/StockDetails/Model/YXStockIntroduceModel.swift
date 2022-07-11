//
//  YXStockIntroduceModel.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/7/22.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXStockIntroduceConfigModel: NSObject {
    // 选中的
    var isSelectCompbus = true
    // 是否展开
    var isMainBusinessIsExpand = false
    var isMainAeraIsExpand = false
    var isTenStockIsExpand = false
    var isDividendExpand = false
    var isSplitshareExpand = false
    var isBuyBackExpand = false

    var isConceptionExpand = false
}

class YXStockIntroduceModel: Codable {
    var profile: YXIntroduceProfile?
    var maincompbus, maincomparea: [YXIntroduceMaincomp]?
    var toptenshareholders: [YXIntroduceToptenshareholder]?
    
    var dividend: [YXIntroduceDividend]?
    var splitshare: [YXIntroduceSplitshare]?
    var buyback: [YXIntroduceBuyback]?
}

// MARK: - YXIntroduceMaincomp
struct YXIntroduceMaincomp: Codable {
    let mainBusiness: String?
    let operatingIncome: Double?
    let proportion: Double?
    let year, month, tradingCurrUnit: Int?
    let tradingCurrName: String?
    
    enum CodingKeys: String, CodingKey {
        case mainBusiness = "main_business"
        case operatingIncome = "operating_income"
        case proportion, year, month
        case tradingCurrUnit = "trading_curr_unit"
        case tradingCurrName = "trading_curr_name"
    }
}

// MARK: - YXIntroduceProfile
struct YXIntroduceProfile: Codable {
    let secuCode, companyName, companyEngName, listDate: String?
    let companyBriefText, chairman, companyBriefTextSimple, companyBriefTextTrad: String?
    let pctchng: Double?
    let mainBusiness: String?
    let industryCode: Int?
    let industryCodeYx: String?
    let industryDesc: String?
    let isSubnew: Int?
    
    enum CodingKeys: String, CodingKey {
        case secuCode = "secu_code"
        case companyName = "company_name"
        case companyEngName = "company_eng_name"
        case listDate = "list_date"
        case companyBriefText = "company_brief_text"
        case chairman
        case companyBriefTextSimple = "company_brief_text_simple"
        case companyBriefTextTrad = "company_brief_text_trad"
        case pctchng
        case mainBusiness = "main_business"
        case industryCode = "industry_code"
        case industryCodeYx = "industry_code_yx"
        case industryDesc = "industry_desc"
        case isSubnew = "is_sub_new"
    }
}

// MARK: - YXIntroduceToptenshareholder
struct YXIntroduceToptenshareholder: Codable {
    let investor: String?
    let heldSharesVolume: Double?
    let proportion: Double?
    let shareholdingChange: Double?
    let holdType, stockType: Int?
    let holdTypeDesc, infoSource: String?
    
    enum CodingKeys: String, CodingKey {
        case investor
        case heldSharesVolume = "held_shares_volume"
        case proportion
        case shareholdingChange = "shareholding_change"
        case holdType = "hold_type"
        case stockType = "stock_type"
        case holdTypeDesc = "hold_type_desc"
        case infoSource = "info_source"
    }
}

// MARK: - YXIntroduceBuyback
struct YXIntroduceBuyback: Codable {
    let secuCode, backDate: String?
    let buyBackSum: Double?
    let buyBackMoney: Double?
    let currencyType: Int?
    let currencyTypeDesc: String?
    
    enum CodingKeys: String, CodingKey {
        case secuCode = "secu_code"
        case backDate = "back_date"
        case buyBackSum = "buy_back_sum"
        case buyBackMoney = "buy_back_money"
        case currencyType = "currency_type"
        case currencyTypeDesc = "currency_type_desc"
    }
}

// MARK: - YXIntroduceDividend
struct YXIntroduceDividend: Codable {
    let secuCode, exdate, divPayableDate, statements: String?
    
    enum CodingKeys: String, CodingKey {
        case secuCode = "secu_code"
        case exdate
        case divPayableDate = "div_payable_date"
        case statements
    }
}

// MARK: - YXIntroduceSplitshare
struct YXIntroduceSplitshare: Codable {
    let secuCode, dirDeciPublDate, effectDate: String?
    let statements: String?
    
    enum CodingKeys: String, CodingKey {
        case secuCode = "secu_code"
        case dirDeciPublDate = "dir_deci_publ_date"
        case effectDate = "effect_date"
        case statements
    }
}
