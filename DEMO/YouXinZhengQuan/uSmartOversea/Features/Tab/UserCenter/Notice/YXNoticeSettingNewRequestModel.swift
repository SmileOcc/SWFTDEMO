//
//  YXNoticeSettingNewRequestModel.swift
//  YouXinZhengQuan
//
//  Created by suntao on 2021/4/1.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXNoticeSettingNewRequestModel: YXHZBaseRequestModel {
    
    override func yx_requestUrl() -> String {
        return "/push-adapter/api/v1/app-setting/list"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/json"]
    }
}

//设置App推送开关
class YXNoticeSettingAPPRequestModel: YXHZBaseRequestModel {
    
    @objc var switchId : String = ""
    @objc var flag : Int = 0
    
    override func yx_requestUrl() -> String {
        return "/push-adapter/api/v1/app-setting/update"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/json"]
    }
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any]! {
        return ["switchId" : "switch"]
    }
}


