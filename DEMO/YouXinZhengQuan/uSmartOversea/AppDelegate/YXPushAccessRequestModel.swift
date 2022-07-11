//
//  YXPushAccessRequestModel.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2020/2/24.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXPushAccessRequestModel: YXHZBaseRequestModel {
    override func yx_requestUrl() -> String {
        "/yxpush-deviceregister/api/v1/device/access/get"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
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
