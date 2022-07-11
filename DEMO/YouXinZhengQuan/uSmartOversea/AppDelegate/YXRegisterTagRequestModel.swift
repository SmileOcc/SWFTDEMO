//
//  YXRegisterTagRequestModel.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/12/26.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXRegisterTagRequestModel: YXHZBaseRequestModel {    
    //    1：单个设备，添加单个tag
    //    2：单个设备，删除单个tag
    //    3：单个设备，添加多个tag
    //    4：单个设备，删除多个tag
    //    5：单个设备，删除所有tag
    //    6：单个设备，重置tag(s)
    @objc var operatorType: Int = 1
    
    //    平台。取值：”ios”、”android”
    @objc var platform: String = ""
    
    //    设备列表
    @objc var deviceList: [String] = []
    @objc var tagList: [String] = []
    
    override func yx_requestUrl() -> String {
        "/yxpush-deviceregister/api/v1/device/tag"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.POST
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        let basicAuthCredentials = "\(YXPushService.appId):\(YXPushService.appSecret)".data(using: .utf8)
        let base64AuthCredentials = basicAuthCredentials?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        return [
            "Authorization" : "Basic \(base64AuthCredentials ?? "")"
        ]
    }
}
