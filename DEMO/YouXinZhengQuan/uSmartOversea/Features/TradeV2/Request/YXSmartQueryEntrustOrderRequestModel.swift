//
//  YXSmartQueryEntrustOrderRequestModel.swift
//  YouXinZhengQuan
//
//  Created by Mac on 2020/4/20.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXSmartQueryEntrustOrderRequestModel: YXJYBaseRequestModel {
    @objc var conId = ""    //智能订单id
    
    override func yx_requestUrl() -> String {
        "/stock-order-server/api/query-entrust-order/v1"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXQueryEntruesOrderResponseModel.self
    }
    
//    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
//        return ["Content-Type": "application/json"]
//    }
}
