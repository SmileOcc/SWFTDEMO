//
//  YXStockRemindSettingModel.swift
//  uSmartOversea
//
//  Created by 陈明茂 on 2019/5/24.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXStockRemindSettingModel: NSObject {
    
    var condition_type = 0
    var condition_value: Double?
    var isOpen: Bool = false
}

class YXStockRemindListModel: Codable {
    let list: [YXStockRemindModel]?
}

// MARK: - List
class YXStockRemindModel: Codable {
    
    let uuid: Double?
    let stockCode, stockMarket: String?
    let notifyType: Int? //提醒类型：1-仅提醒一次，2-每日提醒一次，3-持续提醒
    let updateTime: String?
    let condition: [YXRemindCondition]?
    var qutoaModel: YXV2Quote?
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case stockCode = "stock_code"
        case stockMarket = "stock_market"
        case notifyType = "notify_type"
        case updateTime = "update_time"
        case condition
    }
    
    init(uuid: Double?, stockCode: String?, stockMarket: String?, notifyType: Int?, updateTime: String?, condition: [YXRemindCondition]?) {
        self.uuid = uuid
        self.stockCode = stockCode
        self.stockMarket = stockMarket
        self.notifyType = notifyType
        self.updateTime = updateTime
        self.condition = condition
    }
}

// MARK: - Condition
class YXRemindCondition: Codable {
    let conditionType: Int?
    let conditionValue: Double?
    
    enum CodingKeys: String, CodingKey {
        case conditionType = "condition_type"
        case conditionValue = "condition_value"
    }
    
    init(conditionType: Int?, conditionValue: Double?) {
        self.conditionType = conditionType
        self.conditionValue = conditionValue
    }
}
