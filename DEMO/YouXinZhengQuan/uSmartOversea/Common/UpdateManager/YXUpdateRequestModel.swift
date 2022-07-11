//
//  YXUpdateRequestModel.swift
//  uSmartOversea
//
//  Created by ellison on 2019/2/22.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXUpdateRequestModel: YXJYBaseRequestModel {
    @objc var channel: String = "AppStore"
    @objc var yhc: String = ""  // https证书的md5值
    
    override func yx_requestUrl() -> String {
        return "/config-manager-dolphin/api/check-app-update/v1"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return .GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXUpdateResponseModel.self
    }
    
    override func yx_baseUrl() -> String {
        return YXUrlRouterConstant.jyBuildInBaseUrl()
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["X-Challenge" : "Cancel", "Content-Type" : "application/json"]
    }
}
