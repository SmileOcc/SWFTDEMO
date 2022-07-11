//
//  YXGuessUpAndDowReqModel.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2021/3/18.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXGuessUpAndDowReqModel: YXJYBaseRequestModel {
    @objc var market = "" // 市场类型，0：港股，5：美股
    @objc var index = 0
    @objc var amount = 4
    @objc var extraStockCodes: [String] = []
    
    override func yx_requestUrl() -> String {
        return "/activity-server/api/get-intraday-stock-infos/v1"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}
