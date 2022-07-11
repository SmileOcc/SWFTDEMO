//
//  YXMarketMakerRankReqModel.swift
//  uSmartOversea
//
//  Created by youxin on 2021/1/6.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXMarketMakerRankReqModel: YXHZBaseRequestModel {
    
    var market = "hk"
    
    override func yx_requestUrl() -> String {
        return "quotes-analysis-app/api/v1/mktmaker/list"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}
