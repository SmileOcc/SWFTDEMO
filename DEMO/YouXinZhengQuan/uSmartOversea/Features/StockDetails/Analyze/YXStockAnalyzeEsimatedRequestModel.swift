//
//  YXStockAnalyzeEsimatedRequestModel.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2021/3/5.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXStockAnalyzeEsimatedRequestModel: YXHZBaseRequestModel {

    @objc var market = ""
    @objc var code = ""
    // pb,pe,ps
    @objc var item = "pb"

    override func yx_requestUrl() -> String {
        return "/quotes-basic-service/api/v2/value-data"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}
