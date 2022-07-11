//
//  YXA-HKLimitWarningRequestModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/3/19.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXA_HKLimitWarningRequestModel: YXHZBaseRequestModel {
    @objc var market = ""
    @objc var offset = 0
    @objc var count = 10
    
    override func yx_requestUrl() -> String {
        "/quotes-scm/api/v1/outband-investment-holding"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
    
}
