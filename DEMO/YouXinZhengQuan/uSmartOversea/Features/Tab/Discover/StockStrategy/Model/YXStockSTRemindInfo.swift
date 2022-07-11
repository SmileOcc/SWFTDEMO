//
//  YXStockSTRemindInfo.swift
//  uSmartOversea
//
//  Created by youxin on 2019/9/17.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

// MARK: - DataClass
struct YXStockSTRemindInfo: Codable {
    let strategyremind: [YXStockSTStrategyremindModel]?
    let successcases: [YXStockSTSuccesscaseModel]?
}

// MARK: - Strategyremind
struct YXStockSTStrategyremindModel: Codable {
    let strategyID, strategyVersion, strategyType: Int?
    let strategyName, operDate, operDirectName, stockName: String?
    
    enum CodingKeys: String, CodingKey {
        case strategyID = "strategy_id"
        case strategyVersion = "strategy_version"
        case strategyType = "strategy_type"
        case strategyName = "strategy_name"
        case operDate = "oper_date"
        case operDirectName = "oper_direct_name"
        case stockName = "stock_name"
    }
}

// MARK: - Successcase
struct YXStockSTSuccesscaseModel: Codable {
    let strategyID, strategyVersion, strategyType: Int?
    let strategyName, stockName, returnRate, operInName: String?
    let operInDate, operOutName, operOutDate: String?
    
    enum CodingKeys: String, CodingKey {
        case strategyID = "strategy_id"
        case strategyVersion = "strategy_version"
        case strategyType = "strategy_type"
        case strategyName = "strategy_name"
        case stockName = "stock_name"
        case returnRate = "return_rate"
        case operInName = "oper_in_name"
        case operInDate = "oper_in_date"
        case operOutName = "oper_out_name"
        case operOutDate = "oper_out_date"
    }
}
