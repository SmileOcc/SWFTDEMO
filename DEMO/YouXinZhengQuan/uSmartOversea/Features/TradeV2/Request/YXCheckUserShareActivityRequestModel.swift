//
//  YXCheckUserShareActivityRequestModel.swift
//  uSmartOversea
//
//  Created by 欧冬冬 on 2022/4/18.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

/// 判断盲盒活动是否存在 个人用户
class YXCheckUserShareActivityRequestModel: YXJYBaseRequestModel {
    #if PRD
    @objc var activityId: String = "1000"
    #else
    @objc var activityId: String = "127"
    #endif
    
    @objc var orderId: String = ""
    
    override func yx_requestUrl() -> String {
        return "/activity-server-sg/api/bind-box-show/v1"
    }

    override func yx_responseModelClass() -> AnyClass {
        YXCheckUserShareActivityRespoonseModel.self
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return .GET
    }
}

class YXCheckUserShareActivityRespoonseModel: YXResponseModel {
    @objc var result: Bool = false

    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        ["result": "data"];
    }
}
