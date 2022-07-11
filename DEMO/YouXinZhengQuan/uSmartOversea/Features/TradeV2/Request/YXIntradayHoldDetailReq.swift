//
//  YXIntradayHoldDetailReq.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/6/29.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXIntradayHoldDetailReq: YXJYBaseRequestModel {
    
    @objc var id:Int64 = 0
    
    override func yx_requestUrl() -> String {
        return "/stock-order-server/api/intraday-stock-holding-detail/v1"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXIntradayHoldDetailModel.self
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/json"]
    }
}
