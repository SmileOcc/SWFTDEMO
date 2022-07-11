//
//  YXPrivatelyRequestModel.swift
//  YouXinZhengQuan
//
//  Created by 井超 on 2019/9/4.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXPrivatelyRequestModel: YXJYBaseRequestModel {

    override func yx_requestUrl() -> String {
        "/user-server/api/hidden-risk-autograph/v1"
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
