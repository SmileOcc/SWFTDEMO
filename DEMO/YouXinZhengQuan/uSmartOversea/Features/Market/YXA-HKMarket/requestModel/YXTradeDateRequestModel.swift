//
//  YXTradeDateRequestModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/3/19.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXTradeDateRequestModel: YXHZBaseRequestModel {
    @objc var market = ""
    @objc var day = 0
    @objc var count = 30
    @objc var type = 0 // T+2时传2
    override func yx_requestUrl() -> String {
        "/quotes-scm/api/v1/trade-date"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
}
