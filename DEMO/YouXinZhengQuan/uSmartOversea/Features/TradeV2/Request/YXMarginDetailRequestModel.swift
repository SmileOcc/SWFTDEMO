//
//  YXMarginDetailRequestModel.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2020/3/24.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXMarginDetailRequestModel: YXJYBaseRequestModel {
    @objc var exchangeType: Int = 0
    //@objc var userId: Int64 = 0
    
    override func yx_requestUrl() -> String {
        "/stock-order-server/api/margin-detail/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXStockAssetResponseModel.self
    }
}
