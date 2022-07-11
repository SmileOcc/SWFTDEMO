//
//  YXRegisterTokenRequestModel.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/12/26.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXDeviceUserList: YXModel {
    @objc var device: String = ""
    @objc var userList: [String] = []
}

class YXRegisterTokenRequestModel: YXHZBaseRequestModel {
    //    1：多个设备，增加user
    //    2：多个设备，删除user
    //    3：多个设备，重置user(s)
    //    4：删除设备
    //    5：删除用户
    @objc var operatorType: Int = 1
    
    //    平台。取值：”ios”、”android”
    @objc var platform: String = ""
    
    //    设备对应的用户列表数组
    //    操作是1、2、3时必须
    @objc var deviceList: [String] = []
    
    //    设备列表
    //    操作是4时必须
    @objc var userList: [String] = []
    
    //    操作是5时必须
    @objc var deviceUserList: [YXDeviceUserList] = []
    
    override func yx_requestUrl() -> String {
        "/yxpush-deviceregister/api/v1/device/user/operate"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.POST
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["deviceUserList": YXDeviceUserList.self]
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        let basicAuthCredentials = "\(YXPushService.appId):\(YXPushService.appSecret)".data(using: .utf8)
        let base64AuthCredentials = basicAuthCredentials?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        return [
            "Authorization" : "Basic \(base64AuthCredentials ?? "")"
        ]
    }
}
