//
//  YXWarrantsModel.swift
//  uSmartOversea
//
//  Created by 井超 on 2019/8/2.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import Differentiator

struct YXWarrantsModel: Codable {
    let count, total, from: Int?
    let warrants: [YXWarrantsDetailModel]?
}

struct YXWarrantsDetailModel: Codable {
    
    let callPrice: Double?
    let code, codeBelong: String?
    let delta, effectiveLeverage, exchangeRatio: Double?
    let expireDate: Double?
    let impliedVolatility, issuer: Double?
    let issuerName: String?
    let latestPrice, leverageRatio, moneyness: Double?
    let name: String?
    let outstandingQuantity, outstandingRatio, premium, priceChange: Double?
    let priceChangeRate: Double?
    let quoteTime: Double?
    let status, strikePrice, toCallPrice, turnover: Double?
    let type, volume: Double?
    let priceCeiling, pricelFoor, toPriceCeiling, toPriceFloor: Double?
    let score: Int?
    let bidSize, askSize: Int?
    
    enum CodingKeys: String, CodingKey {
        case callPrice = "call_price"
        case code
        case codeBelong = "code_belong"
        case delta
        case effectiveLeverage = "effective_leverage"
        case exchangeRatio = "exchange_ratio"
        case expireDate = "expire_date"
        case impliedVolatility = "implied_volatility"
        case issuer
        case issuerName = "issuer_name"
        case latestPrice = "latest_price"
        case leverageRatio = "leverage_ratio"
        case moneyness, name
        case outstandingQuantity = "outstanding_quantity"
        case outstandingRatio = "outstanding_ratio"
        case premium
        case priceChange = "price_change"
        case priceChangeRate = "price_change_rate"
        case quoteTime = "quote_time"
        case status
        case strikePrice = "strike_price"
        case toCallPrice = "to_call_price"
        case turnover, type, volume
        case priceCeiling = "price_ceiling"
        case pricelFoor = "price_floor"
        case toPriceCeiling = "to_price_ceiling"
        case toPriceFloor = "to_price_floor"
        case score
        case bidSize
        case askSize
    }
}

extension YXWarrantsDetailModel: IdentifiableType {
    typealias Identity = String
    
    var identity: String {
        code ?? ""
    }
}
