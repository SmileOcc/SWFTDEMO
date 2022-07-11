//
//  YXAssetModel.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/5/10.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation

struct YXAssetModel: Codable {
    // 股票市值、债券市值、基金市值
    var anticipatedInterest: String?
    var creditAmount: String?
    var creditRatio: String?
    var marginRatioDay: String?
    var marginRatioYear: String?
    var mortgageMarketValue: String?
    var callMarginCall: String?
    var debitBalance: String?
    var mv: String?
    var riskStatusCode: Int?
    var riskStatusName: String?
    var purchasePower: String?
    let marketValue: String?
    let stockMarketValue, bondMarketValue, fundMarketValue: String?
    let asset: String?              //总资产
    let enableBalance: String?      //可用金额
    let withdrawBalance: String?    //可取金额
    let frozenBalance: String?      //冻结金额
    let userQuote: String?  //剩余可融资金额
    let onWayBalance: String?               //在途资金
    let totalDailyBalance: String?          //今日盈亏金额
    let dailyBalance: String?
    let dailyBalancePercent: String?
    let totalDailyBalancePercent: String?   //今日盈亏占比
    var totalHoldingBalance: String?        //持仓盈亏金额
    var totalHoldingBalancePercent: String? //持仓盈亏占比
    let holdStockProfitList: [YXStockHoldingList]? //股票持仓列表
    let holdFundProfitList: [YXHoldFundModel]?     //基金持仓列表
    let holdBondProfitList: [YXHoldBondModel]?     //债券持仓列表
    let groupByStockDTOList: [YXDTOModel]?       //日内融持仓列表
    let holdList: [YXHoldShortSellModel]?
    // TODO: 债券持仓列表,待债
    // let holdBondProfitList: [Any]?
    let holdCount: Int?
    
    let holdingBalance: String?
    let holdingBalancePercent: String?
    let totalMarketValue: String?
    let holdDTOList: [YXOptionHoldingList]?
    let afBalance: String?
    let penaltyCapitalBalance: String?
    let penaltyCouponBalance: String?
    let sessionType : Int?     //0/不传-正常订单交易（默认），1-盘前，2-盘后交易，3-暗盘交易
    
    let mvRate: String?
    let totalMMBalance: String?
    let totalIMBalance: String?
    let totalCMBalance: String?
    let totalHoldingProfit: String?
    let totalTodayProfit: String?
    let elvBalance: String?
    let holdingProfitPercent: String?
}

struct YXHoldBondModel: Codable {
    let bondCode: String?
    let bondId: String?
    let bondName: String?
    // 成本价
    let costPrice: String?
    // 持仓数量
    let currentAmount: String?
    // 当日盈亏金额
    let dailyBalance: String?
    // 当日盈亏占比
    let dailyBalancePercent: String?
    let exchangeType: Int
    // 历史市值
    let hisMarketValue: String?
    // 持仓盈亏金额
    let holdingBalance: String?
    // 持仓盈亏占比
    let holdingBalancePercent: String?
    // 最新价
    let lastPrice: String?
    // 市值
    let marketValue: String?
}

struct YXOptionHoldingList: Codable {
    let buyPrice: String?
    let code: String?
    let currentAmount: String?
    let dailyBalance: String?
    let dailyBalancePercent: String?
    let holdType: Int?
    let holdingBalance: String?
    let holdingBalancePercent: String?
    let holdingPercent: String?
    let id: String?
    let lastPrice: String?
    let marketValue: String?
    let moneyType: Int?
    let multiplier: String?
    let name: String?
}

struct YXHoldShortSellModel: Codable {
    
    let costPrice: String?
    let curHoldNum: String?
    let code: String?
    let name: String?
    let exchangeType: Int?
    let marketValue: String?
    let lastPrice: String?
    let imBalance: String?
    let holdingProfit: String?
    let holdingProfitPercent: String?
    let todayProfit: String?
    let todayProfitPercent: String?
    let capitalBalance: String?
    let id: String?
    let moneyType: Int?
}

struct YXDTOModel: Codable {
    let stockCode: String?
    let holdDTOList: [YXStockHoldingList]?
}

struct YXStockHoldingList: Codable {
    let exchangeType: Int
    let stockCode, stockName, currentAmount, oddAmount: String?
    let lastPrice, marketValue, costPrice, dailyBalance: String?
    let dailyBalancePercent, holdingBalance, holdingBalancePercent: String?
    let quoteType, stockType: String?
    
    let heaverRatio: String?
    let heaverMaxRatio: String?
    let buyPrice: String?
    let stopLossPrice: String?
    let stopLessCeilIng: String?
    let stopLossRate: String?
    let stopWinPrice: String?
    let stopWinRate: String?
    let seqNo: String?
    let holdFrontStatus: Int?
    let holdId: Int64?
    let entrustCash: String?
    let orderStatus: Int?
    let buildTime: Int?
    let sessionType: Int?
}

struct YXAppSystemModel: Codable {
    let list: [YXAppSystemInfo]?
}

struct YXAppSystemInfo: Codable {
    let content: String?  //配置内容
    let defaultValue: String? //默认选项
    let orderSwitch: Int? //下单开关 0-不可下单 1-可下单
    let serviceId: String? //配置ID
}
