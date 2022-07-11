//
//  YXShareBindBoxRequestModel.swift
//  uSmartOversea
//
//  Created by Evan on 2022/1/14.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXShareBindBoxRequestModel: YXJYBaseRequestModel {
    #if PRD
    @objc var activityId: String = "1000"
    #else
    @objc var activityId: String = "127"
    #endif

    @objc var orderId: String = ""

    override func yx_requestUrl() -> String {
        return "/activity-server-sg/api/bind-box-share/v1"
    }

    override func yx_responseModelClass() -> AnyClass {
        YXShareBindBoxResponseModel.self
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return .GET
    }
}

class YXShareBindBoxResponseModel: YXResponseModel {
    @objc var result: Bool = false

    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        ["result": "data"];
    }
}
