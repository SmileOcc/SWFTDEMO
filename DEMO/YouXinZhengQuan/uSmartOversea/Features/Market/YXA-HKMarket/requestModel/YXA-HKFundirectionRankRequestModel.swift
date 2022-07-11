//
//  YXA-HKRankRequestModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/3/18.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXA_HKFundDirectionRankRequestModel: YXHZBaseRequestModel {
    
    @objc var direction = ""
    @objc var market = ""
    @objc var day: Int64 = 0
    @objc var offset = 0
    @objc var count = 10
    @objc var sortKey = ""
    @objc var sortType = "desc"
    
    override func yx_requestUrl() -> String {
        "/quotes-scm/api/v1/capflow-rank"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
}
