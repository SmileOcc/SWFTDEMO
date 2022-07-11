//
//  YXOptionCancelOrderRequestModel.swift
//  YouXinZhengQuan
//
//  Created by Apple on 2020/12/3.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

@objcMembers class YXOptionCancelOrderRequestModel: YXJYBaseRequestModel {
    ///订单ID
    var orderId: String = ""

    override func yx_requestUrl() -> String {
        return "/order-center-sg/api/option/option-order-cancel/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}
@objcMembers class YXOptionChangeOrderRequestModel: YXJYBaseRequestModel {
    ///订单ID
    var orderId: String = ""
    ///改单价格
    var entrustPrice: String = ""
    ///改单数量
    var entrustQty: Int64 = 0

    override func yx_requestUrl() -> String {
        return "/order-center-sg/api/option/option-order-update/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}

@objcMembers class YXOptionTradeRequestModel: YXJYBaseRequestModel {
    ///委托价格，市价单和竞价单传递0
    var entrustPrice: String?
    ///委托属性,限价单:LMT,增强限价单:ELMT,市价单:MKT,竟价市价单:AM,竟价限价单:AL
    var entrustProp: String?
    ///委托数量
    var entrustQty:Int64 = 0
    ///委托方向,买入:B,卖出:S
    var entrustSide: String = "B"
    ///是否强制委托标识,默认false
    var forceEntrustFlag: Bool = false
    ///市场，美股期权传US
    var market: String = "US"
    ///代码
    var symbol: String?

    override func yx_requestUrl() -> String {
        return "/order-center-sg/api/option/option-order-create/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}

class YXOptionAggravateRequestModel: YXHZBaseRequestModel {
    @objc var market = ""
    @objc var code = ""

    //http://szshowdoc.youxin.com/web/#/23?page_id=2057
    override func yx_requestUrl() -> String {
        return "/quotes-dataservice-app/api/v1/optionaggregate"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}
