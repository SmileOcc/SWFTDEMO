//
//  YXShareOptionsDateReqModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/11/24.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXShareOptionsDateReqModel: YXHZBaseRequestModel {
    
    @objc var market = "us"
    @objc var code = ""
    
    override func yx_requestUrl() -> String {
        return "/quotes-dataservice-app/api/v1/optiondate"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}
