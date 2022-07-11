//
//  YXRangesRequestModel.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/11/18.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXRangesRequestModel: YXHZBaseRequestModel {
    @objc var market: String = ""
    @objc var symbol: String = ""
    
    override func yx_requestUrl() -> String {
        "quotes-cbbc/api/v1/ranges"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXRangesResponseModel.self
    }
}
