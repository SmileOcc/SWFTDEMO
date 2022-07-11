//
//  YXWJBaseRequestModel.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2021/3/5.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXWJBaseRequestModel: YXModel, YXRequestProtocol {
    func yx_requestUrl() -> String {
        assertionFailure("须自行实现")
        return String()
    }
    
    func yx_responseModelClass() -> AnyClass {
        assertionFailure("须自行实现")
        return YXWJBaseRequestModel.self
    }
    
    func yx_baseUrl() -> String {
        return YXUrlRouterConstant.wjBaseUrl()
    }
    
    func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:];
    }
}
