//
//  YXTokenRequestModel.swift
//  uSmartOversea
//
//  Created by lennon on 2022/1/21.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXGetTokenResponse: YXResponseModel {
    @objc var tokenKey: String = ""
    
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        ["tokenKey": "data.tokenKey"];
    }
}


class YXGetTokenRequestModel: YXJYBaseRequestModel {
    
    override func yx_requestUrl() -> String {
        return "/user-server-sg/api/get-token-key/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXGetTokenResponse.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        .POST
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        ["Content-Type":"application/json"]
    }
}


