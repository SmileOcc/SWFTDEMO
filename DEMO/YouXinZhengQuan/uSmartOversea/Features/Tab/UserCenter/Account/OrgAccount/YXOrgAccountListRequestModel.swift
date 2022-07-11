//
//  YXOrgAccountListRequestModel.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2020/6/20.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXOrgAccountListRequestModel: YXJYBaseRequestModel {
    
    override func yx_requestUrl() -> String {
        return "/user-server-dolphin/api/get-user-org-trader-info/v1"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/json"]
    }
}


class YXOrgSwitchUserTraderInfoRequestModel: YXJYBaseRequestModel {
    
    @objc var traderId = ""
    @objc var traderStatus = ""
    
    override func yx_requestUrl() -> String {
        return "/user-server-dolphin/api/switch-user-org-trader-info/v1"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/json"]
    }
}
