//
//  YXTradeStatusRequestModel.swift
//  YouXinZhengQuan
//
//  Created by rrd on 2019/2/13.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXTradeStatusRequestModel: YXJYBaseRequestModel {
    
    override func yx_requestUrl() -> String {
        "/user-account-server-dolphin/api/get-trade-status/v1"
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
