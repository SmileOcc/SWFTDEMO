//
//  YXAccountAssetHoldListItem.swift
//  uSmartOversea
//
//  Created by Evan on 2022/4/25.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXAccountAssetHoldListItem: YXModel {

    /// 帐号业务类型
    @objc var accountBusinessType: YXAccountBusinessType = .normal
    var level: QuoteLevel?
    /// 持仓数量
    @objc var currentAmount: NSDecimalNumber?
    /// 汇率，市场所属币种换到交易币种
    @objc var exchangeRate: NSDecimalNumber?
    /// 前端状态: 0-不展示，1-展示
    @objc var frontStatus: Int = 1
    /// 持仓盈亏金额
    @objc var holdingBalance: NSDecimalNumber?
    /// 持仓盈亏占比
    @objc var holdingBalancePercent: NSDecimalNumber?
    /// 持仓占比
    @objc var holdingPercent: NSDecimalNumber?
    /// 最新价
    @objc var lastPrice: NSDecimalNumber?
    /// 市场类型
    @objc var exchangeType: String?
    /// 市值
    @objc var marketValue: NSDecimalNumber?
    /// 币种
    @objc var moneyType : String?
    /// 乘数，期权使用
    @objc var multiplier: NSDecimalNumber?
    /// 昨日市值
    @objc var preMarketValue: NSDecimalNumber?
    /// 市场状态: 0-正常 1-盘前 2-盘后。期权没有盘前盘后
    @objc var sessionType: Int = 0
    /// 买入成本价
    @objc var startPrice: NSDecimalNumber?
    /// 代码
    @objc var stockCode: String?
    /// 名称
    @objc var stockName: String?
    /// 股票类型
    @objc var stockType: String?
    /// 今日入账变化
    @objc var todayDeltaIn: NSDecimalNumber?
    /// 日出账变化
    @objc var todayDeltaOut: NSDecimalNumber?
    /// 今日盈亏变量 0 或者 1，默认情况是 1
    @objc var todayProfitVar: NSDecimalNumber?
    /// 建仓成本总额
    @objc var totalCost: NSDecimalNumber?
    /// 今日盈亏
    @objc var todayProfit: NSDecimalNumber?
    /// 前端展示的今日盈亏
    @objc var displayTodayProfit: NSDecimalNumber?
    /// 今日盈亏占比
    @objc var todayProfitPercent: NSDecimalNumber?
    /// 是否是轮证
    @objc var isWarrants = false

    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:]
    }

}

extension YXAccountAssetHoldListItem {

    /// 更新行情
    func update(with quote: YXV2Quote) {
        self.isWarrants = quote.stockType == .stWarrant || quote.stockType == .stCbbc || quote.stockType == .stInlineWarrant

        if let price = quote.latestPrice?.value, let priceBase = quote.priceBase?.value  {
            var priceValue = price
            // 如果是盘前盘后阶段，需要取盘前盘后的最新价 (sQuote.latestPrice)
            if YXStockDetailTool.isUSPreAfter(quote), let sPrice = quote.sQuote?.latestPrice?.value, sPrice > 0 {
                priceValue = sPrice
            }
            let priceString = YXToolUtility.stockPriceData(Double(priceValue), deciPoint: Int(priceBase), priceBase: Int(priceBase))
            self.lastPrice = NSDecimalNumber(string: priceString)
        }

        if let levelType = quote.level?.value {
            self.level = QuoteLevel(rawValue: Int(levelType))
        }

        calculate()
    }

    /// 根据当前价格重新计算
    func calculate() {
        calculate(lastPrice?.stringValue)
    }

    /// 根据价格计算(http://wiki.yxzq.com/pages/viewpage.action?pageId=35585112)
    /// - Parameter priceString: 价格
    func calculate(_ priceString: String?) {
        let multiplier = self.multiplier ?? .one

        // 当前市值 = 最新价 * currentAmount
        marketValue = (lastPrice ?? .zero).multiplying(by: currentAmount ?? .zero).multiplying(by: multiplier)

        // 建仓成本总额 = startPrice * currentAmount
        totalCost = (startPrice ?? .zero).multiplying(by: currentAmount ?? .zero).multiplying(by: multiplier)

        // 今日盈亏（todayProfit）= 当前市值 -  preMarketValue + today_Delta_out - today_Delta_in
        todayProfit = marketValue?.subtracting(preMarketValue ?? .zero).adding(todayDeltaOut ?? .zero).subtracting(todayDeltaIn ?? .zero)

        // 持仓盈亏（holdProfit）= 当前市值 - 建仓成本总额
        holdingBalance = marketValue?.subtracting(totalCost ?? .zero)

        // 持仓盈亏占比 = 持仓盈亏 / 建仓成本总额
        if let totalCost = totalCost, totalCost.floatValue > 0 {
            holdingBalancePercent = holdingBalance?.dividing(by: totalCost)
        }

        // 前端展示的今日盈亏 = 今日盈亏 * 今日盈亏变量( todayProfitVar)
        displayTodayProfit = todayProfit?.multiplying(by: todayProfitVar ?? .one)

        // 今日盈亏占比 = 前端展示的今日盈亏 / (preMarketValue + todayDeltaIn)
        if let preMarketValue = preMarketValue, let todayDeltaIn = todayDeltaIn {
            let value = preMarketValue.adding(todayDeltaIn)
            if value.doubleValue > 0 {
                todayProfitPercent = displayTodayProfit?.dividing(by: value)
            }
        }
    }

}

extension YXAccountAssetHoldListItem {

    @objc func market() -> String {
        switch self.exchangeType {
        case "HK":
            return "hk"
        case "SG":
            return "sg"
        case "US":
            switch accountBusinessType {
            case .usOption:
                return "usoption"
            default:
                return "us"
            }
        default:
            return "hk"
        }
    }

}
