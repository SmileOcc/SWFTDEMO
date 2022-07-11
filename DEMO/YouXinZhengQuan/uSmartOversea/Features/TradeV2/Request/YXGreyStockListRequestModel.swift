//
//  YXGreyStockListRequestModel.swift
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2020/4/24.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXGreyStockListRequestModel: YXJYBaseRequestModel {
    override func yx_requestUrl() -> String {
        "/stock-order-server/api/query-ipo-grey/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.POST
    }
    
//    func yx_responseSerializerType() -> YTKResponseSerializerType {
//        return .HTTP
//    }
}

class YXHoldCheckBtnFlagRequestModel: YXJYBaseRequestModel {
    override func yx_requestUrl() -> String {
        "/stock-order-server/api/btn-flag/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.POST
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        ["Content-Type": "application/json"]
    }
}

