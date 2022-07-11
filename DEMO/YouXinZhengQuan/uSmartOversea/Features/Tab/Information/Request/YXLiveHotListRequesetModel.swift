//
//  YXLiveHotListRequesetModel.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2020/8/5.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXLiveHotListRequesetModel: YXHZBaseRequestModel {
    
    @objc var limit = 2
    
    override func yx_requestUrl() -> String {
        return "/zt-liveshow-api/api/v1/get-liveshow-hotlist"
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

class YXLiveReplayListRequesetModel: YXHZBaseRequestModel {
    @objc var offset = 0
    @objc var limit = 50
    @objc var show_limit = 6
    
    override func yx_requestUrl() -> String {
        return "/zt-liveshow-api/api/v1/get-demandshow-category-list"
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

