//
//  YXUSOptionStatusRequestModel.swift
//  uSmartOversea
//
//  Created by ysx on 2022/1/13.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXUSOptionStatusRequestModel: YXJYBaseRequestModel {
    
    override func yx_requestUrl() -> String {
       "/user-account-server-sg/api/get-options-account-status/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXUSOptionStatusResponse.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        ["Content-Type":"application/x-www-form-urlencoded"]
    }
}

class YXUSOptionStatusResponse: YXResponseModel {
    @objc var annualNetIncome: String = ""
    @objc var customerName: String = ""
    @objc var netWorth: String = ""
    @objc var openedAccount: Bool = false  //是否开通期权
    @objc var sgOptionsInvestmentExpVO:Dictionary<String, Any> = [:]
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        ["openedAccount": "data.openedAccount",
         "customerName":"data.customerName"];
    }
}
