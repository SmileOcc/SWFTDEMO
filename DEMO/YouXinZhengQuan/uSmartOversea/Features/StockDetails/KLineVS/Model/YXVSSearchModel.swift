//
//  YXVSSearchModel.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2021/2/3.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

@objcMembers class YXVSSearchModel: NSObject {

    var secu: YXSecu = YXSecu()
    //var klineData: YXKLineData?

    var closePriceList: [CGFloat] = []
    
    var closePriceKlineList = [YXKLine?].init(repeating: nil, count: 220)
    var closePriceAfterCalculateKlineList: [YXKLine?] = [] //

    var firstPrice: CGFloat = 0

    var highestRatio: CGFloat = 0
    var lowestRatio: CGFloat = 0

    var historyRatio: CGFloat = 0

    var priceBase: Int = 0
    var priceBasic: CGFloat = 0

    var startTime: UInt64 = 0
    var endTime: UInt64 = 0

    var marketSymbol: String {
        return secu.market + secu.symbol
    }
}
