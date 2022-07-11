//
//  YXLatestTradeRequestModel.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2020/5/19.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXLatestTradeRequestModel: YXHZBaseRequestModel {
    override func yx_requestUrl() -> String {
        "/quotes-selfstock/api/v2/get-last-deal-info"
    }
      
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }
      
    override func yx_responseModelClass() -> AnyClass {
        YXSecuGroupResponseModel.self
    }
}
