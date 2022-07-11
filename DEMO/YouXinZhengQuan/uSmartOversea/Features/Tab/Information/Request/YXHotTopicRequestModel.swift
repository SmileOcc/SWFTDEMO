//
//  YXHotTopicRequestModel.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2020/9/27.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import Foundation

class YXHotTopicRequestModel: YXHZBaseRequestModel {
    
    override func yx_requestUrl() -> String {
        return "/zt-hot-stock-server/api/v1/hot-stock/get-home-topic"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/json"]
    }
}

class YXTopicVoteRequestModel: YXHZBaseRequestModel {
    
    @objc var direction: Int = 1
    @objc var common = ["":""]
    
    override func yx_requestUrl() -> String {
        return "/like-server/api/v1/thumb-up-op"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.PUT
    }
    
//    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
//        return ["Content-Type": "application/json"]
//    }
}
