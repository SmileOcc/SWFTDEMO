//
//  YXBrokenOrderRequestModel.swift
//  YouXinZhengQuan
//
//  Created by mac on 2019/5/17.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXBrokenOrderRequestModel: YXJYBaseRequestModel {
    

    @objc var entrustAmount:Int64 = 0    //委托数量
    @objc var entrustPrice = ""     //价格(竞价单价格传0)
    @objc var entrustType = 1      //委托类别(0-买，1-卖)
    @objc var exchangeType = 0     //交易类别(0-香港,5-美股,67-A股)
    @objc var stockCode = ""       //股票代码
    @objc var requestId = ""       //请求id
    
   
    override func yx_requestUrl() -> String {
        "/stock-order-server/api/odd-entrust/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
    
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.POST
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        ["X-Request-Id": requestId]
    }
    
    func yx_requestTimeoutInterval() -> TimeInterval {
        30
    }
}
