//
//  YXHoldSmartOrderRequestModel.swift
//  YouXinZhengQuan
//
//  Created by ellison on 2019/2/13.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXSmartOrderQuery: NSObject {
    @objc var conditionType: String = ""    // 1：Breakthrough Buy、2：Buy-Low、3：Sell-High、4：Breakdown Sell
    @objc var market: String = ""   // 交易类别(HK-香港,US-美股,HGT-沪港通,SGT-深港通)
    @objc var orderStatus: String = ""  // 订单状态；0：Active、1：Triggered、2：Expired
    @objc var securityType: String = "" // 业务类型；1：Stock、2：Warrants、3：Options
    @objc var stockCode = ""
    @objc var transactionTime: String = ""  // 交易时间；1：Today、2：1 Week、3：1 Month、4：3 Months、5：1 Year、6：This Year
    @objc var transactionTimeStart = "" // 交易时间起，如果不传时间默认从最新前一天倒序,规则yyyy-MM-dd
    @objc var transactionTimeEnd = ""   // 交易时间止，如果不传时间默认从最新前一天倒序,规则yyyy-MM-dd
}

class YXHoldSmartOrderRequestModel: YXJYBaseRequestModel {
    @objc var query: YXSmartOrderQuery?
    @objc var pageNum = 1   // 当前页 1开始
    @objc var pageSize = 30 // 每页结果数,最大200条

    @objc var isQueryTodayConditionOrder = false // 标记是否在下单页

    override func yx_requestUrl() -> String {
        if isQueryTodayConditionOrder {
            return "/condition-center-sg/api/query-today-condition-order/v1"
        }

        return "/condition-center-sg/api/query-condition/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXConditionOrderResponseModel.self
    }


    class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["query": YXSmartOrderQuery.self]
    }
}
