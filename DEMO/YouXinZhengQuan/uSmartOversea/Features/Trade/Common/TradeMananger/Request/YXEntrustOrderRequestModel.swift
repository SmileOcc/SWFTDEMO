//
//  YXCommissionedOrderRequestModel.swift
//  YouXinZhengQuan
//
//  Created by rrd on 2019/1/16.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXEntrustOrderRequestModel: YXJYBaseRequestModel {
    
    @objc var entrustQty:Int64 = 0      //委托数量
    @objc var entrustPrice = ""         //价格(竞价单价格传0)
    @objc var entrustProp = ""          //委托属性,限价单:LMT,增强限价单:ELMT,市价单:MKT,竟价市价单:AM,竟价限价单:AL
    @objc var entrustSide = ""          //委托方向,买入:B,卖出:S
    @objc var market = ""               //市场(HK-香港,US-美股,HGT-沪港通,SGT-深港通)
    @objc var symbol = ""               //股票代码
    @objc var symbolName = ""           //股票名称
    @objc var forceEntrustFlag = false  //是否强制委托标识
    @objc var tradePeriod = "N"         //交易时段N-正常下单交易,G-暗盘交易,盘前盘后:AB,默认:正常
    
    
    override func yx_requestUrl() -> String {
        "/order-center-dolphin/api/order/stock-order-create/v1"
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

//class YXChangeEntrustRequestModel: YXJYBaseRequestModel {
//
//    @objc var entrustId = ""    //委托id
//    @objc var actionType = 0    //操作类型(0-撤单，1-改单)
//    @objc var amountPerHand: UInt32 = 0
//    @objc var entrustAmount: Int64 = 0
//    @objc var entrustPrice = ""
//    @objc var forceEntrustFlag = false  //是否强制委托标识
//
//    override func yx_requestUrl() -> String {
//        "/stock-entrust-server-dolphin/api/modify-order/v1"
//    }
//
//    override func yx_responseModelClass() -> AnyClass {
//        YXResponseModel.self
//    }
//
//    override func yx_requestMethod() -> YTKRequestMethod {
//        YTKRequestMethod.POST
//    }
//
//}

class YXChangeEntrustRequestModel: YXJYBaseRequestModel {

    @objc var orderId = ""    //订单ID
    @objc var entrustQty: Int64 = 0
    @objc var entrustPrice = ""
    @objc var forceEntrustFlag = false  //是否强制委托标识
    
    override func yx_requestUrl() -> String {
        "/order-center-sg/api/order/stock-order-replace/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.POST
    }
    
}

class YXStockHoldInfoRequestModel: YXJYBaseRequestModel {
    
    @objc var exchangeType = ""               //市场(HK-香港,US-美股,HGT-沪港通,SGT-深港通)
    @objc var stockCode = ""               //股票代码
    
    
    override func yx_requestUrl() -> String {
        "/asset-center-sg/api/app-stock-stockHoldInfoQuery"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
    
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.POST
    }
}
