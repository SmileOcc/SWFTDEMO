//
//  YXConditionTimeRequestModel.swift
//  YouXinZhengQuan
//
//  Created by rrd on 2019/2/14.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXConditionTimeRequestModel: YXJYBaseRequestModel {

    @objc var exchangeType = 0   //交易类别(0-香港,5-美股,67-A股)
    
    override func yx_requestUrl() -> String {
        "/stock-order-server/api/condition-validtime/v1"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
}
