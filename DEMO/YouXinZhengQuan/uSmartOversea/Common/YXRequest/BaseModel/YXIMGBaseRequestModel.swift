//
//  YXIMGBaseRequestModel.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2018/12/20.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import UIKit

class YXIMGBaseRequestModel: YXModel, YXRequestProtocol {
    func yx_requestUrl() -> String {
        assertionFailure("须自行实现")
        return String()
    }
    
    func yx_responseModelClass() -> AnyClass {
        assertionFailure("须自行实现")
        return YXIMGBaseRequestModel.self
    }
    
    func yx_baseUrl() -> String {
        YXUrlRouterConstant.imgResourceBaseUrl()
    }
}
