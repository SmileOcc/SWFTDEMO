//
//  YXMarketDetailItem.swift
//  uSmartOversea
//
//  Created by ellison on 2019/1/7.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

struct YXMarketIPOTodayCountModel: Codable {
    let applying: Int?
    let list: Int?
    let publish: Int?
    let todayDark: Int?
}

class YXMarketHSSCMResponseModel: Codable {
    var list: [YXMarketHSSCMItem]?
}

class YXMarketHSSCMItem: Codable {
    
    //额度状态 0 额度不可用 1 额度可用
    var amountStatus: Int?
    
    //资金流向,取值参考 0 南下 1 北上
    var captialFlow: Int?
    
    var code: String?
    
    //净成交额
    var netTurnover: Int64?
    
    //日中剩余额度
    var posAmt: Int64?
    
    var priceBase: Int?
    
    //每日初始额度
    var thresholdAmount : Int64?
    
    
    var time: Int64?
    
    //买成交额
    var turnoverBuy: Int64?
    
    //卖成交额
    var turnoverSel: Int64?
}
