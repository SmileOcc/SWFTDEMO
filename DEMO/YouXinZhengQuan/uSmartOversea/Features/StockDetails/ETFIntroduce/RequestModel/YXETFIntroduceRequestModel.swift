//
//  YXETFIntroduceRequestModel.swift
//  uSmartOversea
//
//  Created by youxin on 2021/3/5.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXETFBriefRequestModel: YXHZBaseRequestModel {

    @objc var code = "" //股票id,如：hk00700

    override func yx_requestUrl() -> String {
        return "/quotes-basic-service/api/v1/company-profile"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }

    func yx_responseSerializerType() -> YTKResponseSerializerType {
        return YTKResponseSerializerType.JSON
    }
}
