//
//  YXBullBearFundFlowListReqModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/4/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXBullBearFundFlowListReqModel: YXHZBaseRequestModel {
    @objc var derivativeType = ""
    @objc var capflowType = ""
    @objc var nextPageRef = 0
    @objc var size = 20
    
    override func yx_requestUrl() -> String {
        "/quotes-derivative-app/api/v1/capflow/list"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
}
