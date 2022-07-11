//
//  YXTradeActiveRequest.swift
//  uSmartOversea
//
//  Created by youxin on 2020/3/19.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXTradeActiveRequestModel: YXHZBaseRequestModel {
    @objc var direction = ""
    @objc var market = ""
    @objc var day: Int64 = 0
    @objc var offset = 0
    @objc var count = 10
    
    override func yx_requestUrl() -> String {
        "/quotes-scm/api/v1/traded-active"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
}
