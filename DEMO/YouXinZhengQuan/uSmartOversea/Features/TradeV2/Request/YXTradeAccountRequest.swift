//
//  YXtradeAccountRequest.swift
//  uSmartOversea
//
//  Created by ysx on 2021/11/16.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit



class YXTradeAccountRequest: YXJYBaseRequestModel {
    
    @objc var BrokerNo:String = ""   
  
    
    override func yx_requestUrl() -> String {
        "/user-account-server-dolphin/api/get-trade-account-info/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXTradeAccountResponse.self
    }
    
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.POST
    }
    
}
//http://jy-uat.usmartnz.com/user-account-server-sg/doc/doc.html#/1-API/SG-交易业务处理/getSgTradeAccountInfoUsingPOST
class YXTradeAccountResponse: YXResponseModel {
    @objc var accountType: String = "" //账户类型：CASH，MARGIN
    
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        ["accountType": "data.accountType"];
    }
    
}

