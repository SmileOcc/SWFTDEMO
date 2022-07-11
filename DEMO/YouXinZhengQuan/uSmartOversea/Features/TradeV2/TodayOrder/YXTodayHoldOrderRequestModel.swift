//
//  YXTodayHoldOrderRequestModel.swift
//  YouXinZhengQuan
//
//  Created by ellison on 2019/1/29.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXTodayHoldOrderRequestModel: YXJYBaseRequestModel {

//    @objc var exchangeType: Int = 0
//    @objc var pageSizeZero: Bool = true
//    @objc var orderDirection: Int = 0
//    @objc var enEntrustStatus = ""
//    @objc var moneyType = "" // 0人民币 1美元，2港币

    @objc var categoryStatus: Int = 0
    @objc var market = ""

    override func yx_requestUrl() -> String {
//        "/stock-entrust-server-dolphin/api/today-entrust/v1"
//        "/order-center-dolphin/api/today-entrust/v1"
        "/order-center-dolphin/api/order/stock-order-today-list/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXOrderResponseModel.self
    }
    
}
