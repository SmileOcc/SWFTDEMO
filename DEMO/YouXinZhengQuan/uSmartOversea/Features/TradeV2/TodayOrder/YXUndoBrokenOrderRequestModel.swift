//
//  YXUndoBrokenOrderRequestModel.swift
//  YouXinZhengQuan
//
//  Created by mac on 2019/5/17.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXUndoBrokenOrderRequestModel: YXJYBaseRequestModel {

    @objc var oddId:Int64 = 0     //碎股委托Id
    @objc var actionType = 0      //操作类型(0-撤单)
    
    override func yx_requestUrl() -> String {
        "/stock-order-server/api/odd-modify/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.POST
    }
    
    func yx_requestTimeoutInterval() -> TimeInterval {
        30
    }
}
