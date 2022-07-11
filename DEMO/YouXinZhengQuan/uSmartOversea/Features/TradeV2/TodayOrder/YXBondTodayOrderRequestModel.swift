//
//  YXBondTodayOrderRequestModel.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2019/8/6.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXBondTodayOrderRequestModel: YXJYBaseRequestModel {
    @objc var market: Int = 2
    
    override func yx_requestUrl() -> String {
        "/finance-server/api/get-bond-order-today/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXBondTodayOrderResponseModel.self
    }
}
