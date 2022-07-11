//
//  YXCbbcDetailRequestModel.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/11/18.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXCbbcDetailRequestModel: YXHZBaseRequestModel {
    @objc var market: String = ""
    @objc var symbol: String = ""
    @objc var range: Double = 0.0
    @objc var date: Int64 = 0
    
    override func yx_requestUrl() -> String {
        "quotes-cbbc/api/v1/details"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXCbbcDetailResponseModel.self
    }
}
