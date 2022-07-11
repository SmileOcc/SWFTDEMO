//
//  YXUpdatePromptRequestModel.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2020/3/31.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXUpdatePromptRequestModel: YXJYBaseRequestModel {
    
    override func yx_requestUrl() -> String {
        "/order-center-sg/api/margin/set-upsuccess-confim-flag/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.POST
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/json"]
    }
}
