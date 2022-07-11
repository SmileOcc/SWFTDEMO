
//
//  File.swift
//  uSmartOversea
//
//  Created by ellison on 2019/3/25.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

//涡轮/牛熊 - 简况

struct YXHkwarrantListModel: Codable {
    let list: [YXHkwarrantModel]?
}


struct YXHkwarrantModel: Codable {
    let symbol, secuCode, secuName: String?
    let trdMarket, warrantCategory, ifListed: Int?
    let targetName: String?
    let targetType, targetCode, targetCurrencyUnit: Int?
    let targetPerValue: Double?
    let warrantType, warrantCharacter, exerciseStyle, settlementMode: Int?
    let issuer: String?
    let leverageRatio, effectiveGearing, impliedVolatility: Double?
    let listedDate: String?
    let tradingUnit: Int?
    let lastTradeDay, maturityDate: String?
    let issueVol: Int?
    let premium: Double?
    let positiveSecuCode: String?
    let stillOutVol: Int?
    let exercisePrice, percOfStillOut, recoveryPrice: Double?
    let daysRemain: Int?
    let moneyness, breakEvenPrice, gearing, entRatio: Double?
    let positiveSecuAbbr: String?
    let priceFloor: Double?
    let priceCeiling: Double?
    
    enum CodingKeys: String, CodingKey {
        case symbol
        case secuCode = "secu_code"
        case secuName = "secu_name"
        case trdMarket = "trd_market"
        case warrantCategory = "warrant_category"
        case ifListed = "if_listed"
        case targetName = "target_name"
        case targetType = "target_type"
        case targetCode = "target_code"
        case targetCurrencyUnit = "target_currency_unit"
        case targetPerValue = "target_per_value"
        case warrantType = "warrant_type"
        case warrantCharacter = "warrant_character"
        case exerciseStyle = "exercise_style"
        case settlementMode = "settlement_mode"
        case issuer
        case leverageRatio = "leverage_ratio"
        case effectiveGearing = "effective_gearing"
        case impliedVolatility = "implied_volatility"
        case listedDate = "listed_date"
        case tradingUnit = "trading_unit"
        case lastTradeDay = "last_trade_day"
        case maturityDate = "maturity_date"
        case issueVol = "issue_vol"
        case premium
        case positiveSecuCode = "positive_secu_code"
        case stillOutVol = "still_out_vol"
        case percOfStillOut = "perc_of_still_out"
        case exercisePrice = "exercise_price"
        case recoveryPrice = "recovery_price"
        case daysRemain = "days_remain"
        case entRatio = "ent_ratio"
        case moneyness
        case breakEvenPrice = "break_even_price"
        case gearing
        case positiveSecuAbbr = "positive_secu_abbr"
        case priceFloor = "price_floor"
        case priceCeiling = "price_ceiling"
    }
}

