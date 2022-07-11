//
//  YXBondCancelOrderRequestModel.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2019/8/7.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXBondCancelOrderRequestModel: YXJYBaseRequestModel {
    @objc var orderNo: String = ""
    @objc var tradeToken: String = ""
    
    override func yx_requestUrl() -> String {
        "/finance-server/api/cancel-bond-order/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
}
