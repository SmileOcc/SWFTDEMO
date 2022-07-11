//
//  SubscribStrategyRequestModel.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/9.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class SubscribStrategyRequestModel: YXHZBaseRequestModel {

    @objc var strategy_id = 0   // 策略id
    @objc var strategy_type = 0 // 策略类型 4-人工策略 5-基金策略
    @objc var subscribe = 0 // 0-取消订阅 1-订阅

    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }

    override func yx_requestUrl() -> String {
        return "/news-strategyserver/api/v3/subscribe"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }

}
