//
//  YXAccountAssetResModel.swift
//  uSmartOversea
//
//  Created by 覃明明 on 2021/7/8.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXAccountAssetResModel: YXModel {

    /// 账户属性 (0:未知; 1:现金; 2:margin)
    @objc var accountProp: String?
    @objc var userId : String?
    @objc var moneyType : String?
    @objc var fundAccount : String?
    @objc var assetSingleInfoRespVOS: [YXAccountAssetData] = []
    @objc var totalData : YXAccountAssetData?

    // 即期汇率
    var exchangeRateList: [YXExchangeRateModel]? {
        didSet {
            calculateTotalData()
        }
    }

    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["assetSingleInfoRespVOS": YXAccountAssetData.self]
    }

    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:]
    }

}

extension YXAccountAssetResModel {

    /// 更新行情数据
    /// - Parameter quotes: 行情
    @objc func refreshQuotes(_ quotes: [YXV2Quote]?) {
        guard let quotes = quotes, !quotes.isEmpty else {
            return
        }

        var needUpdate = false
        var hasUSQuote = false

        for quote in quotes {
            // 1、根据 market 查找所对应账户的 assetData
            for assetData in self.assetSingleInfoRespVOS where assetData.exchangeType?.lowercased() == quote.market {
                // 2、查找 assetData 中的持仓列表中对应的股票
                guard let holdListItem = assetData.holdInfos.first(where: { $0.stockCode == quote.symbol }) else {
                    continue
                }

                // 资产接口返回的股票名称可能没有多语言，使用行情数据修正下
                if let name = quote.name {
                    holdListItem.stockName = name
                }

                // 3. 更新行情
                holdListItem.update(with: quote)

                // 3.重新计算账户的 assetData
                assetData.calculate(needCaculateHoldInfos: false)

                needUpdate = true

                if quote.market?.lowercased() == "us" {
                    hasUSQuote = true
                }
            }
        }

        if !needUpdate {
            return
        }

        // 4.重新计算美股正股账户总资产
        if hasUSQuote {
            recalculateUSAsset()
        }

        // 5.重新计算总资产
        calculateTotalData()
    }

    @objc func calculate() {
        // 屏蔽当前版本不包含的账户类型
        assetSingleInfoRespVOS.removeAll(where: { !YXAccountBusinessType.allCases.contains($0.accountBusinessType) })

        assetSingleInfoRespVOS.forEach { assetData in
            assetData.calculate()
        }

        recalculateUSAsset()
        calculateTotalData()
    }

    /// 修正美股正股账的总资产（要包含美股正股、期权和碎股单的总资产之和）
    @objc func recalculateUSAsset() {
        if let usAssetData = assetSingleInfoRespVOS.first(where: { $0.exchangeType == "US" && $0.accountBusinessType == .normal }) {
            var usAsset = usAssetData.marketValue?.adding(usAssetData.cashBalance ?? .zero)

            if let usOptionAssetData = assetSingleInfoRespVOS.first(where: { $0.exchangeType == "US" && $0.accountBusinessType == .usOption }),
               let asset = usOptionAssetData.asset  {
                usAsset = usAsset?.adding(asset)
            }

            if let usFractionAssetData = assetSingleInfoRespVOS.first(where: { $0.exchangeType == "US" && $0.accountBusinessType == .usFraction }),
               let asset = usFractionAssetData.asset  {
                usAsset = usAsset?.adding(asset)
            }

            usAssetData.asset = usAsset
        }
    }

    /// 计算总资产
    @objc func calculateTotalData() {
        guard let exchangeRateList = exchangeRateList, !exchangeRateList.isEmpty else {
            return
        }

        var totalMarketValue: NSDecimalNumber = .zero

        assetSingleInfoRespVOS.forEach { assetData in
            // 查找对应账户货币与总资产的货币之间的汇率
            if let exchangeRateModel = exchangeRateList.first(where: { $0.fromMoneyType == assetData.moneyType }),
               let exchangeRate = exchangeRateModel.exchangeRate {

                if let marketValue = assetData.marketValue {
                    let exchangedValue = marketValue.multiplying(by: exchangeRate)
                    totalMarketValue = totalMarketValue.adding(exchangedValue)
                }
            }
        }

        totalData?.marketValue = totalMarketValue
        totalData?.asset = totalMarketValue.adding(totalData?.cashBalance ?? .zero)
    }

}


class YXCconfigMortgageRateQueryResModel: YXModel {

    @objc var margin: Int32 = 0
    @objc var mortgageRatio: Double = 0.0
    @objc var stockCode: String = ""

    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:]
    }

}

