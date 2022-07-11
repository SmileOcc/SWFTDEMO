//
//  YXA-HKFundAmountRequestModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/3/19.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXA_HKFundAmountRequestModel: YXHZBaseRequestModel {
    @objc var direction = ""
    
    override func yx_requestUrl() -> String {
        "/quotes-scm/api/v1/amount"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
}
