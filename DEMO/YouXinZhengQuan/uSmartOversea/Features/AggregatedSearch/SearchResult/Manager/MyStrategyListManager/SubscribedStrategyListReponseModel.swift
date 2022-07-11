//
//  SubscribedStrategyListReponseModel.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/9.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

@objcMembers class SubscribedStrategyListReponseModel: YXResponseModel {

    var list: [SubscribedStrategyModel] = []

    @objc class func modelCustomPropertyMapper() -> [String : Any]? {
        return [
            "list": "data.strategy_list"
        ]
    }

    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [
            "list": SubscribedStrategyModel.self
        ]
    }
    
}

/// 策略
@objcMembers class SubscribedStrategyModel: YXModel {
    var strategyId = 0 // 策略ID
    var type = 0 // 策略类型

    @objc override class func modelCustomPropertyMapper() -> [String : Any]? {
        return [
            "strategyId": "StrategyId",
            "type": "StrategyType"
        ]
    }
}
