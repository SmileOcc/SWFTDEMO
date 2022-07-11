//
//  YXCheckIsNeedPromptRequestModel.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2020/3/31.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXCheckIsNeedPromptRequestModel: YXJYBaseRequestModel {
    
    override func yx_requestUrl() -> String {
        "/order-center-sg/api/margin/get-upsuccess-confim-flag/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXCheckIsNeedPromptResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.POST
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/json"]
    }
}

class YXCheckIsNeedPromptResponseModel: YXResponseModel {
    // 1 已确认，不需要弹了 0 未确认
    @objc var shouldPrompt: Int = -1
    
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        ["shouldPrompt": "data"]
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        [:]
    }
}
