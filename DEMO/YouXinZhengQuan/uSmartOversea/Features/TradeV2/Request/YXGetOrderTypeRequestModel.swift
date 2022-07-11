//
//  YXGetOrderTypeRequestModel.swift
//  YouXinZhengQuan
//
//  Created by 井超 on 2020/2/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXGetOrderTypeRequestModel: YXJYBaseRequestModel {

    @objc var market = "hk"
    
    override func yx_requestUrl() -> String {
        "/config-manager-dolphin/api/get-order-type/v1"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.POST
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
}
