//
//  YXBullBearFundFlowSelectionReqModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/4/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXBullBearFundFlowSelectionReqModel: YXHZBaseRequestModel {
    @objc var derivativeType = ""
    @objc var capflowType = ""
    
    override func yx_requestUrl() -> String {
        "/quotes-derivative-app/api/v1/capflow/top"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
}
