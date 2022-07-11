//
//  SearchStrategyModel.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/4.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

@objc enum SearchStrategyType: Int {
    case manual = 4
    case fund = 5
}

/// 策略
@objcMembers class SearchStrategyModel: YXModel {
    var strategyId = 0 // 策略ID
    var type: SearchStrategyType = .manual // 策略类型： 4：人工策略，5：基金策略
    var brief = "" // 简介
    var name = "" // 名称
    var pctChngThisYear: Double = 0 // 近一年收益率，真实值除以10000
}
