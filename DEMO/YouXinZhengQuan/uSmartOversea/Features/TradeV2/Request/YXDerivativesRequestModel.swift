//
//  YXDerivativesRequestModel.swift
//  YouXinZhengQuan
//
//  Created by mac on 2019/5/16.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXDerivativesRequestModel: YXJYBaseRequestModel {
    
    var data = ""

    override func yx_requestUrl() -> String {
        "/user-account-server/api/update-cust-derivatives-status/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.POST
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        ["Content-Type": "application/json"]
    }
}
