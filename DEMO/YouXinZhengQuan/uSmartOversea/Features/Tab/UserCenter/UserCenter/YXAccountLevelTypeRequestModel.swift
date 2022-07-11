//
//  YXAccountLevelTypeRequestModel.swift
//  uSmartOversea
//
//  Created by ysx on 2022/1/6.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit


class YXAccountLevelTypeRequestModel: YXJYBaseRequestModel {
    
    override func yx_requestUrl() -> String {
        "/user-account-manage-sg/api/get-user-account-type-info/v1"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.POST
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXAccountTypeResponse.self
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        ["Content-Type": "application/json"]
    }
}

class YXAccountTypeResponse: YXResponseModel {
    @objc var accountType: Int = 0 //0 trade 1 standat 2 intel
    
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        ["accountType": "data.accountType"];
    }
    
}
