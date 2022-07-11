//
//  YXTokenRequestModel.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2018/12/20.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import UIKit

class YXTokenRequestModel: YXJYBaseRequestModel {
    override func yx_requestUrl() -> String {
        "/user-server-dolphin/api/tokens/v1"
    }

    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
}
