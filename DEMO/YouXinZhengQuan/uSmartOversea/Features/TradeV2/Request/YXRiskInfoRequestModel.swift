//
//  YXRiskInfoRequestModel.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2020/3/28.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXRiskInfoRequestModel: YXJYBaseRequestModel {
    @objc var userId: NSNumber?
    
    override func yx_requestUrl() -> String {
        "/stock-order-server/api/user-risk-info/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXRiskInfoResponseModel.self
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        ["Content-Type": "application/json"]
    }
}
