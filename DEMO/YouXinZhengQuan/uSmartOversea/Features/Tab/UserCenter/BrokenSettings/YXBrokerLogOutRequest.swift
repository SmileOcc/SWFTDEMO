//
//  YXBrokerLogOutRequest.swift
//  uSmartOversea
//
//  Created by ysx on 2021/11/11.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXBrokerLogOutRequest: YXJYBaseRequestModel {
  
    override func yx_requestUrl() -> String {
        return "/user-account-server-dolphin/api/broker-logout/v1"
    }
    
    override func yx_baseUrl() -> String {
        return YXUrlRouterConstant.jyBaseUrl()
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
    
}
