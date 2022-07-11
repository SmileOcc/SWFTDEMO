//
//  YXDealStatisticalDateRequestModel.swift
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2020/7/28.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXDealStatisticalDateRequestModel: YXHZBaseRequestModel {
    
    @objc var market = ""
    override func yx_requestUrl() -> String {
        "/quotes-dataservice-app/api/v1/statisticdays"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
}


class YXDealStatisticalExchangeRequestModel: YXHZBaseRequestModel {
    
    @objc var market = ""
    @objc var symbol = ""
    @objc var type: Int = 0
    @objc var bidOrAskType: Int = 0
    @objc var marketTimeType: Int = 0
    @objc var tradeDay: Int64 = 0
    
    override func yx_requestUrl() -> String {
        "/quotes-dataservice-app/api/v1/statisticexchange"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
}
