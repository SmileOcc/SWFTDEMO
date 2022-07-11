//
//  YXStockAnalyzeRequestModel.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/7/15.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXStockAnalyzeBrokerListRequestModel: YXHZBaseRequestModel {

    @objc var market = ""

    @objc var type = 0

    @objc var symbol = ""

    override func yx_requestUrl() -> String {
        "/quotes-analysis-app/api/v1/broker/list"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
    // 暂时
//    override func yx_baseUrl() -> String {
//        return "http://hz-dev.yxzq.com"
//    }
}

class YXBrokerHoldDetailRequestModel: YXHZBaseRequestModel {

    @objc var market = ""
    @objc var symbol = ""
    @objc var brokerCode = ""
    // 翻页方向，0：由最新的时间开始，1：由最老的时间开始
    @objc var direction = ""
    // 下一页的起始点，由上一页的结果返回
    @objc var nextPageRef: String?
    @objc var size = ""
    override func yx_requestUrl() -> String {
        "/quotes-analysis-app/api/v1/broker/history"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
}
