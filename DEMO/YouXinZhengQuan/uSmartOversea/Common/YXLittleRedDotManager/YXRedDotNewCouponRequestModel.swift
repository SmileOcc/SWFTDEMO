//
//  YXLittleRedDotRequestModel.swift
//  uSmartOversea
//
//  Created by Mac on 2019/11/22.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXRedDotNewCouponRequestModel: YXJYBaseRequestModel {
    @objc var lastClickTime: Int64 = 0
    
    override func yx_requestUrl() -> String {
        "/product-server/api/get-user-new-coupon/v1"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        .GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
}



class YXRedDotIpoRequestModel: YXJYBaseRequestModel {
    
    override func yx_requestUrl() -> String {
        "/stock-order-server/api/ipo-red-point/v1"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        .POST
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        ["Content-Type": "application/json"]
    }
}

class YXRedDotActCenterReqModel: YXHZBaseRequestModel {
    @objc var last_effective_time: Int64 = 0
    
    override func yx_requestUrl() -> String {
        "/news-configserver/api/v1/query/activity_center_red_hot"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        .GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
}


