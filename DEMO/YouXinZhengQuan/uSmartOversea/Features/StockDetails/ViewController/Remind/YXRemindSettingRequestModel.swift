//
//  YXRemindSettingRequestModel.swift
//  uSmartOversea
//
//  Created by 姜轶群 on 2018/12/21.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

import UIKit

class YXRemindSettingRequestModel: YXHZBaseRequestModel {
    
    @objc var stockCode = ""
    @objc var stockMarket = ""
    
    override func yx_requestUrl() -> String {
        return "/quotes-stock-alerts-front/api/v1/get/rules"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/json"]
    }
}

class YXRemindGetAllUserSettingRequestModel: YXHZBaseRequestModel {
    
    override func yx_requestUrl() -> String {
        return "/quotes-stock-alerts-front/api/v1/getall/rules"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/json"]
    }
}
