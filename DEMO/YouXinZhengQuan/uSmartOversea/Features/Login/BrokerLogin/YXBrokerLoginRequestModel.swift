//
//  YXBrokerLoginRequestModel.swift
//  uSmartOversea
//
//  Created by ysx on 2021/11/10.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXBrokerLoginRequestModel: YXJYBaseRequestModel {
    @objc var clientId:String = ""
    @objc var traderPassword:String = ""  //rsa加密
    var brokerNo :String = ""
    
    override func yx_requestUrl() -> String {
        return "/user-account-server-dolphin/api/broker-login/v1"
    }
    
    override func yx_baseUrl() -> String {
        return YXUrlRouterConstant.jyBaseUrl()
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXBrokerLoginResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        ["X-BrokerNo": brokerNo]
    }
    
}


class YXBrokerLoginResponseModel : YXResponseModel {
    @objc var clientId: String? = ""
    @objc var expiration:String? = ""
    @objc var firstLogin: Bool = true
    @objc var token: String? = ""
    
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        return ["clientId": "data.clientId",
                "expiration":"data.expiration",
                "firstLogin":"data.firstLogin",
                "token":"data.token"];
    }
    
}

