//
//  YXKLineOrderModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/7/16.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXKLineOrderModel: NSObject {
    @objc var market: String = ""
    @objc var symbol: String = ""
    @objc var beginDate: Int64 = 0
    @objc var EndDate: Int64 = 0

    @objc var list: [YXKLineEventInfo]?

    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["list": YXKLineEventInfo.self]
    }
}

class YXKLineEventInfo: NSObject {
    @objc var latestTime: Int64 = 0

    @objc var list: [YXKLineOrderInfo]?

    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["list": YXKLineOrderInfo.self]
    }
}

class YXKLineOrderInfo: NSObject {
    @objc var type: Int32 = 0 //事件类型：0：交易订单，1：发布财报，2：分红派息

    @objc var context: String = "" //字段为 1：发布财报，2：分红派息 时的展示信息
    @objc var bought: [YXKLineOrderDetail]? //买订单
    @objc var sold: [YXKLineOrderDetail]? //卖订单

    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        return ["bought": "content.bought",
                "sold": "content.sold",
                "context": "content.context"];
    }

    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["bought": YXKLineOrderDetail.self, "sold": YXKLineOrderDetail.self]
    }
}


class YXKLineOrderDetail: NSObject {

    @objc var price: String = "0" //金额
    @objc var volume: Int64 = 0   //量
    @objc var orderType: Int32 = 0 //订单类型，0：普通，1：日内融，2：期权
}

