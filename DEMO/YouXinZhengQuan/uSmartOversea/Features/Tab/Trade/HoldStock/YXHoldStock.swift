//
//  YXHoldStock.swift
//  uSmartOversea
//
//  Created by ellison on 2019/4/26.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation

public struct YXHoldStock: Codable, Equatable {
    
    var costPrice: String?     //成本价
    var currentAmount: String? //持仓数量
    var dailyBalance: String?  //当日盈亏金额
    var dailyBalancePercent: String?   //当日盈亏占比
    var exchangeType: YXExchangeType?  //交易类型
    var holdingBalance: String?        //持仓盈亏金额
    var holdingBalancePercent: String? //持仓盈亏占比
    var lastPrice: String?     //最新价
    var marketValue: String?   //市值
    var stockCode: String? //股票代码
    var stockName: String? //股票名称
    var quoteType: String? //行情权限 0:延时行情1:bmp行情2:level1行情3:level2行情
    
    
    init() {
        costPrice = nil
        currentAmount = nil
        dailyBalance = nil
        dailyBalancePercent = nil
        exchangeType = nil
        holdingBalance = nil
        holdingBalancePercent = nil
        lastPrice = nil
        marketValue = nil
        stockCode = nil
        stockName = nil
        quoteType = nil
    }
}
