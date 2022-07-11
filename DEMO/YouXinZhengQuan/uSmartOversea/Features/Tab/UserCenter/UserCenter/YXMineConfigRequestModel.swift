//
//  YXMineConfigRequestModel.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2020/6/16.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXMineConfigRequestModel: YXJYBaseRequestModel {
    
    @objc var dataVersion = ""

    override func yx_requestUrl() -> String {
        "/product-server/api/get-user-ui-config/v1"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        ["Content-Type": "application/json"]
    }
}
