//
//  YXUndoEntrustRequestModel.swift
//  YouXinZhengQuan
//
//  Created by rrd on 2019/2/15.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXUndoEntrustRequestModel: YXJYBaseRequestModel {

    @objc var businessId = ""    //委托id
    @objc var actionType = 0    //操作类型(0-撤单，1-改单)
    @objc var amountPerHand = 0
    @objc var entrustAmount = 0
    @objc var entrustPrice = 0
    override func yx_requestUrl() -> String {

        return "/stock-entrust-server-dolphin/api/cancel-order/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.POST
    }
    
    
}

class YXUndoEntrustRequestModel2: YXJYBaseRequestModel {
    @objc var orderId = ""   //订单id
    
    override func yx_requestUrl() -> String {
        return "/order-center-dolphin/api/order/stock-order-cancel/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.POST
    }
}
