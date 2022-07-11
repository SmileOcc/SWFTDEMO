//
//  YXCheckShareActivityRequestModel.swift
//  uSmartOversea
//
//  Created by Evan on 2022/1/24.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

/// 判断盲盒活动是否存在 所有用户
class YXCheckShareActivityRequestModel: YXJYBaseRequestModel {
    #if PRD
    @objc var activityId: String = "1000"
    #else
    @objc var activityId: String = "127"
    #endif
    
    @objc var orderId: String = ""
    
    override func yx_requestUrl() -> String {
        return "/activity-server-sg/api/bind-box-is-exist/v1"
    }

    override func yx_responseModelClass() -> AnyClass {
        YXCheckShareActivityRespoonseModel.self
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return .GET
    }
}

class YXCheckShareActivityRespoonseModel: YXResponseModel {
    @objc var result: Bool = false

    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        ["result": "data"];
    }
}
