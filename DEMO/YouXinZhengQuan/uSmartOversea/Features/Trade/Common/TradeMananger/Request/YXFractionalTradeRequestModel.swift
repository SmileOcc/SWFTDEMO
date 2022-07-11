//
//  YXFractionalTradeRequestModel.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2022/4/21.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import Foundation

@objcMembers class YXFractionalCancelOrderRequestModel: YXJYBaseRequestModel {
    ///订单ID
    var orderId: String = ""

    override func yx_requestUrl() -> String {
        return "/order-center-sg/api/odd/odd-order-cancel/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}

@objcMembers class YXFractionalChangeOrderRequestModel: YXJYBaseRequestModel {
    ///订单ID
    var orderId: String = ""
    ///改单价格
    var entrustPrice: String = ""
    ///改单金额
    var entrustAmount: String?
    ///改单数量
    var entrustQty: String?
    ///强制下单,  默认false
    var forceEntrustFlag: Bool = false

    override func yx_requestUrl() -> String {
        return "/order-center-sg/api/odd/odd-order-modify/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}

@objcMembers class YXFractionalTradeRequestModel: YXJYBaseRequestModel {
    ///委托价格，市价单和竞价单传递0
    var entrustPrice: String?
    ///委托属性,限价单:LMT,增强限价单:ELMT,市价单:MKT,竟价市价单:AM,竟价限价单:AL
    var entrustProp: String?
    ///委托数量
    var entrustQty: String?
    ///委托金额
    var entrustAmount: String?
    ///委托方向,买入:B,卖出:S
    var entrustSide: String = "B"
    ///委托选项,1:按股数,2:按金额,默认:1
    var entrustTab: Int = 1
    ///是否强制委托标识,默认false
    var forceEntrustFlag: Bool = false
    ///市场
    var market: String = "US"
    ///代码
    var symbol: String?
    ///交易时段N-正常下单交易,G-暗盘交易,盘前盘后:AB,默认:正常
    var tradePeriod: String?
    
    override func yx_requestUrl() -> String {
        return "/order-center-sg/api/odd/odd-order-create/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}
