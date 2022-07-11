//
//  YXA-HKFundTrendRequestModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/3/25.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXA_HKFundTrendRequestModel: YXHZBaseRequestModel {
    @objc var ktype = ""
    @objc var offset: Int64 = 0
    @objc var count = 60
    @objc var codeList: [String] = []
    
    override func yx_requestUrl() -> String {
        "/quotes-scm/api/v1/capflow-kline"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
}
