//
//  YXCancelAccountRequestModel.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2020/5/19.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXCancelAccountRequestModel: YXJYBaseRequestModel {
    override func yx_requestUrl() -> String {
        "/user-server-dolphin/api/cancel-customer-account/v1"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        ["Content-Type": "application/x-www-form-urlencoded"]
    }

}
