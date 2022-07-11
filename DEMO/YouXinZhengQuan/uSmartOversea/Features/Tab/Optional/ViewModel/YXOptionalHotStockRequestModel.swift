//
//  YXOptionalHotStockRequestModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/6/30.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXOptionalHotStockRequestModel: YXHZBaseRequestModel {
    @objc var offset: Int = 0
    override func yx_requestUrl() -> String {
        "/zt-hot-stock-server/api/v1/hot-stock/get-stock-attack"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
}
