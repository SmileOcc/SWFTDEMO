//
//  YXRemindSettingSaveRequestModel.swift
//  uSmartOversea
//
//  Created by 姜轶群 on 2018/12/21.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

import UIKit

// MARK: - 股价更新
class YXRemindSettingUpdatePriceRequestModel: YXHZBaseRequestModel {
    
    @objc var id = ""
    @objc var stockCode = ""
    @objc var stockMarket = ""
    @objc var ntfType: Int = 0
    @objc var ntfValue: Double = 0
    
    @objc var notifyType: Int = 1   //提醒类型：1-仅提醒一次，2-每日提醒一次，3-持续提醒
    
    @objc var status: Int = 1  // 1-开启状态, 2-关闭状态
    
    override func yx_requestUrl() -> String {
        return "/quotes-stock-alerts-front/api/v1/update/stockntfrule"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
}

// MARK: - 添加股价
class YXRemindSettingAddPriceRequestModel: YXHZBaseRequestModel {
    
    @objc var stockCode = ""
    @objc var stockMarket = ""
    @objc var ntfType: Int = 0
    @objc var ntfValue: Double = 0
    
    @objc var notifyType: Int = 1   //提醒类型：1-仅提醒一次，2-每日提醒一次，3-持续提醒
    
    @objc var status: Int = 1  // 1-开启状态, 2-关闭状态
    
    override func yx_requestUrl() -> String {
        return "/quotes-stock-alerts-front/api/v1/create/stockntfrule"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
}



// MARK: - 形态更新
class YXRemindSettingUpdateFormRequestModel: YXHZBaseRequestModel {
    
    @objc var id = ""
    @objc var stockCode = ""
    @objc var stockMarket = ""
    @objc var formShowType: Int = 0
    
    @objc var notifyType: Int = 1   //提醒类型：1-仅提醒一次，2-每日提醒一次，3-持续提醒
    
    @objc var status: Int = 1  // 1-开启状态, 2-关闭状态
    
    override func yx_requestUrl() -> String {
        return "/quotes-stock-alerts-front/api/v1/update/stockformrule"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
}

// MARK: - 添加形态
class YXRemindSettingAddFormRequestModel: YXHZBaseRequestModel {
    
    @objc var stockCode = ""
    @objc var stockMarket = ""
    @objc var formShowType: Int = 0
    
    @objc var notifyType: Int = 1   //提醒类型：1-仅提醒一次，2-每日提醒一次，3-持续提醒
    
    @objc var status: Int = 1  // 1-开启状态, 2-关闭状态
    
    override func yx_requestUrl() -> String {
        return "/quotes-stock-alerts-front/api/v1/create/stockformrule"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
}


// MARK: - 删除规则
class YXRemindSettingDeleteRuleRequestModel: YXHZBaseRequestModel {
    
    @objc var stockCode = ""
    @objc var stockMarket = ""
    @objc var delStockNtfs = [String]()
    @objc var delStockForms = [String]()
    
    override func yx_requestUrl() -> String {
        return "/quotes-stock-alerts-front/api/v1/del/rules"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/json"]
    }
}
