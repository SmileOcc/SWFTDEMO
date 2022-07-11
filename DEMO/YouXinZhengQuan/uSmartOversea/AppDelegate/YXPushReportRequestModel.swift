//
//  YXPushReportRequestModel.swift
//  uSmartOversea
//
//  Created by 深圳市秀软科技有限公司 on 2020/2/7.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXPushReportRequestModel: YXHZBaseRequestModel {
    //    任务Id
    @objc var taskId: String = ""
    
    override func yx_requestUrl() -> String {
        "/yxpush-statistic/api/v1/ctr/report"
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
