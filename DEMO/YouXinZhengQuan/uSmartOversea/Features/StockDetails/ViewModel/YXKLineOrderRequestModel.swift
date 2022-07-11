//
//  YXKLineOrderRequestModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/7/21.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXKLineOrderRequestModel: YXHZBaseRequestModel {

    @objc var market = ""
    @objc var symbol = ""
    @objc var type = "kline1Day"
    @objc var beginDate: Int64 = 0
    @objc var endDate: Int64 = 0

    override func yx_requestUrl() -> String {
        return "/quotes-userservice/api/v1/events"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}

class YXStockDetailTempCodeRequestModel: YXHZBaseRequestModel {
    //@objc var market = ""
    @objc var code = ""

    //http://szshowdoc.youxin.com/web/#/23?page_id=2064
    override func yx_requestUrl() -> String {
        return "/quotes-basic-service/api/v1/hk/temp-code"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}


class YXKLineUsmartSignalRequestModel: YXHZBaseRequestModel {

    @objc var stock_id = ""
    @objc var limit: Int64 = 0
    @objc var offset: Int64 = 0

    override func yx_requestUrl() -> String {
        return "/zt-channel-apiserver/api/v1/get_history_signal_by_stock"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}


class YXKLineGetUsmartSignalCountRequestModel: YXHZBaseRequestModel {

    @objc var stock_id = ""

    override func yx_requestUrl() -> String {
        return "/zt-channel-apiserver/api/v1/check-right"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }

    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}

