//
//  YXBullBearContractStreetReqModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/4/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXBullBearContractStreetReqModel: YXHZBaseRequestModel {
    @objc var market = ""
    @objc var symbol = ""
    
    override func yx_requestUrl() -> String {
        "/quotes-derivative-app/api/v1/cbbc/top"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
}
