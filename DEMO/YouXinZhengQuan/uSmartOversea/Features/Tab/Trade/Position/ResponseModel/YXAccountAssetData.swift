//
//  YXAccountAssetData.swift
//  uSmartOversea
//
//  Created by Evan on 2022/4/25.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

@objc enum YXAccountBusinessType: Int {
    case normal = 100       // 正股
    case usFraction = 106   // 碎股
    case usOption = 300     // 期权
}

extension YXAccountBusinessType: CaseIterable {


}

@objc enum YXAccountStatus: Int {
    case opened = 1
    case unopened = 2
}

class YXAccountAssetData: YXModel {

    /// 当前业务是否开通的状态
    @objc var fundAccountStatus: YXAccountStatus = .opened
    /// 帐号业务类型
    @objc var accountBusinessType: YXAccountBusinessType = .normal
    /// 总资产(注意：美股正股总资产包含美股正股、期权和碎股单)
    @objc var asset: NSDecimalNumber?
    /// 可用金额
    @objc var availableBalance: NSDecimalNumber?
    /// 现金
    @objc var cashBalance: NSDecimalNumber?
    /// 负债金额
    @objc var debitBalance: NSDecimalNumber?
    /// 应收利息（债券用）
    @objc var dueInterest: NSDecimalNumber?
    /// 市场
    @objc var exchangeType: String?
    /// 冻结金额
    @objc var frozenBalance: NSDecimalNumber?
    /// 业务账户
    @objc var fundAccount: String?
    /// 证券市值
    @objc var marketValue: NSDecimalNumber?
    /// 币种类型
    @objc var moneyType: String?
    /// 风险比率Sum(MM)/ELV
    @objc var mv: String?
    /// 风险等级描述
    @objc var mvLevelDesc: String?
    /// 购买力
    @objc var purchasePower: NSDecimalNumber?
    /// 风控等级，1-安全，2-预警，3-追保，4-强平
    @objc var riskCode: YXAccountRiskType = .safe
    /// 风控等级名称
    @objc var riskCodeName: String?
    /// 今日盈亏金额
    @objc var todayProfit: NSDecimalNumber?
    /// 前端展示的今日盈亏
    @objc var displayTodayProfit: NSDecimalNumber?
    /// 今日盈亏占比
    @objc var todayProfitPercent: NSDecimalNumber?
    /// 持仓盈亏金额，基金为近7日收益
    @objc var totalHoldingBalance: NSDecimalNumber?
    /// 持仓盈亏率
    @objc var totalHoldingBalancePercent: NSDecimalNumber?
    /// 用户uuid
    @objc var userId: String?
    /// 可取资金
    @objc var withdrawBalance: NSDecimalNumber?
    /// 首页股票信息
    @objc var holdInfos: [YXAccountAssetHoldListItem] = []

    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["holdInfos": YXAccountAssetHoldListItem.self]
    }

    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:]
    }

}

extension YXAccountAssetData {

    /// 计算资产数据(http://wiki.yxzq.com/pages/viewpage.action?pageId=26442020)
    /// - Parameter needCaculateHoldInfos: 持仓列表是否需要重新计算, 默认为 true
    @objc func calculate(needCaculateHoldInfos: Bool = true) {
        if needCaculateHoldInfos {
            holdInfos.forEach { $0.calculate() }
        }

        if holdInfos.count > 0 {
            // 当前市值
            marketValue = holdInfos.map {
                ($0.marketValue ?? .zero).multiplying(by: $0.exchangeRate ?? .one)
            }
            .reduce(NSDecimalNumber.zero, { result, number in
                result.adding(number)
            })

            // 建仓成本总额
            let totalCost = holdInfos.map {
                ($0.totalCost ?? .zero).multiplying(by: $0.exchangeRate ?? .one)
            }
            .reduce(NSDecimalNumber.zero, { result, number in
                result.adding(number)
            })

            // 持仓盈亏 = 当前市值 - 建仓成本总额
            totalHoldingBalance = marketValue?.subtracting(totalCost)

            // 持仓盈亏占比 = 持仓盈亏 / 建仓成本总额
            if totalCost.doubleValue > 0 {
                totalHoldingBalancePercent = totalHoldingBalance?.dividing(by: totalCost)
            }

            // 今日盈亏
            self.todayProfit = holdInfos.map {
                ($0.todayProfit ?? .zero).multiplying(by: $0.exchangeRate ?? .one)
            }
            .reduce(NSDecimalNumber.zero, { result, number in
                result.adding(number)
            })

            // 前端展示的今日盈亏
            self.displayTodayProfit = holdInfos.map {
                ($0.displayTodayProfit ?? .zero).multiplying(by: $0.exchangeRate ?? .one)
            }
            .reduce(NSDecimalNumber.zero, { result, number in
                result.adding(number)
            })

            // preMarketValue + todayDeltaIn
            let preMarketValueAndTodayDeltaIn = holdInfos.map {
                let value = $0.preMarketValue?.adding($0.todayDeltaIn ?? .zero)
                return (value ?? .zero).multiplying(by: $0.exchangeRate ?? .one)
            }
            .reduce(NSDecimalNumber.zero, { result, number in
                result.adding(number)
            })

            // 前端展示的今日盈亏占比 = 前端展示的今日盈亏 / (preMarketValue + todayDeltaIn)
            if let todayProfit = self.todayProfit, preMarketValueAndTodayDeltaIn.doubleValue > 0 {
                self.todayProfitPercent = todayProfit.dividing(by: preMarketValueAndTodayDeltaIn)
            }

            if let marketValue = self.marketValue {
                // 注意：如果是美股正股账号，那么这个总资产计算的值是不对的，会在 '-recalculateUSAsset'方法中重新修正
                asset = marketValue.adding(cashBalance ?? .zero)
            }
        }
    }

    func allSecus() -> [Secu] {
        var secus: [Secu] = []

        for item in holdInfos {
            if let symbol = item.stockCode,
               var market = item.exchangeType {
                // 修正下期权的 market （为了订阅行情区分是期权还是正股）
                if accountBusinessType == .usOption {
                    market = "usoption"
                }
                secus.append(Secu(market: market.lowercased(), symbol: symbol))
            }
        }

        return secus
    }

}
