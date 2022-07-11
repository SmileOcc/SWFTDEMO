//
//  YXFinancingViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/8/5.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import URLNavigator

class YXFinancingViewModel {
    var navigator: NavigatorServicesType!
    var market: YXMarketType = .HK
    var rankType: YXRankType = .marginAble
    var uiStyle: YXFinancingUIStyle = .normal
}
