//
//  YXDoubelLoginSetRequestModel.swift
//  uSmartOversea
//
//  Created by ysx on 2022/2/16.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXDoubelLoginSetRequestModel: YXJYBaseRequestModel {
    @objc var optionType = 0 //0:关闭 1:开启 操作类型参数
    override func yx_requestUrl() -> String {
        "/user-server-sg/api/update-fa-status/v1"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.POST
    }

    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
}
