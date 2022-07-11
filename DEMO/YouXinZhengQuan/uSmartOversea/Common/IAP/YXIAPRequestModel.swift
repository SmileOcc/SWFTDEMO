//
//  YXIAPRequestModel.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2020/3/23.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXIAPRequestModel: YXJYBaseRequestModel {
    @objc var paymentNo: Int64 = 0
    @objc var paymentType: Int = 3
    @objc var receiptData = ""
    
    override func yx_requestUrl() -> String {
        "/payment-server/api/payment-order-by-supplement/v1"
    }
    
    override func yx_baseUrl() -> String {
        YXUrlRouterConstant.jyBaseUrl()
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXIAPResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.POST
    }
}
