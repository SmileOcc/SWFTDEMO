//
//  YXOrderRangeRequestModel.swift
//  YouXinZhengQuan
//
//  Created by rrd on 2019/2/21.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXOrderRangeRequestModel: YXJYBaseRequestModel {
    
    @objc var orderId = ""        //委托id
    @objc var handQty: UInt32 = 0    //每手股数
    @objc var entrustPrice = ""

    override func yx_requestUrl() -> String {
        "/order-center-dolphin/api/order/stock-order-replace-max/v1"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.POST
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXTradeQuantityResponseModel.self
    }
}
