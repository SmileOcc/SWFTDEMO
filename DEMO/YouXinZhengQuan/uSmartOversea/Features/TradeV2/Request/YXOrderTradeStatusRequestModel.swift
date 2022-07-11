//
//  YXTradeStatusRequest.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2020/5/8.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXOrderTradeStatusRequestModel: YXJYBaseRequestModel {
    @objc var exchangeType: Int = 5
    @objc var stockCode: String = ""
    
    override func yx_requestUrl() -> String {
        "/stock-order-server/api/trade-status/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.POST
    }
}

