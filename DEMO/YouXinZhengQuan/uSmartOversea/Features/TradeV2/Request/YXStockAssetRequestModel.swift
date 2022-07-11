//
//  YXStockassetRequestModel.swift
//  YouXinZhengQuan
//
//  Created by ellison on 2019/1/28.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit


class YXStockAssetRequestModel: YXJYBaseRequestModel {
    
    @objc var exchangeType: Int = 0
    @objc var extendStatusBit: Int = 0
    
    override func yx_requestUrl() -> String {
        "/aggregation-server/api/user-asset-aggregation/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXStockAssetResponseModel.self
    }
}

class YXStockSingleAssetRequestModel: YXJYBaseRequestModel {
    
    @objc var exchangeType: Int = 0
    
    @objc var stockCode = ""
    
    override func yx_requestUrl() -> String {
        "/stock-order-server/api/stock-holding-single/v1"
    }

    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
}
