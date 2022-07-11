//
//  YXResetQuoteLevelRequestModel.swift
//  uSmartOversea
//
//  Created by youxin on 2021/1/22.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXResetQuoteLevelRequestModel: YXHZBaseRequestModel {

    override func yx_requestUrl() -> String {
        return "/quotes-authcheck/api/v1/reset"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}

class YXNewDiscussRequestModel: YXHZBaseRequestModel {

    @objc var stock_id = ""
    override func yx_requestUrl() -> String {
        return "/zt-stock-discussion-apiserver/api/sg/v1/has-new-post"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}
