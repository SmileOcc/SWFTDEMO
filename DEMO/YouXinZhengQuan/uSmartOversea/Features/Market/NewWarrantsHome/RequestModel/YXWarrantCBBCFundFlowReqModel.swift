//
//  YXWarrantCBBCFundFlowReqModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/9/23.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXWarrantCBBCFundFlowReqModel: YXHZBaseRequestModel {
    @objc var market: String = "hk"
    
    override func yx_requestUrl() -> String {
        return "/quotes-derivative-app/api/v1/warrantcbbc/caplfow"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}
