//
//  YXTodayHotStockReqModel.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2020/12/22.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXTodayHotStockReqModel: YXHZBaseRequestModel {
    
    @objc var market = "hk"
    
    override func yx_requestUrl() -> String {
        return "/zt-hot-stock-server/api/v1/hot-stock/market-hot-stock-list"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}
