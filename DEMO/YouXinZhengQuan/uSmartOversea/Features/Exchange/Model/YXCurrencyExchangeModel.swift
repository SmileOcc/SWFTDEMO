//
//  YXCurrencyExchangeModel.swift
//  uSmartOversea
//
//  Created by Kelvin on 2019/1/31.
//  Copyright © 2019年 RenRenDai. All rights reserved.
//

import Foundation

class YXCurrencyExchangeModel: NSObject, Codable {
    var baseCurrency: String?    // 源币种
    var rate: String?              // 最优汇率
    var sourceCurrency: String?    // 源币种
    var targetCurrency: String?    // 目标币种
    var sourceWithdrawBalance: String?   // 源币种可取金额
    var targetWithdrawBalance: String?   // 目标币种可取金额
}

extension YXCurrencyExchangeModel {

    /// 接口返回的 rate 是根据 baseCurrency 决定的, 不一定是 sourceCurrency -> targetCurrency 方向
    /// 这里返回 sourceCurrency -> targetCurrency 单方向的汇率，用于兑入与兑出的计算
    var calculateRate: Double? {
        guard
            let baseCurrency = self.baseCurrency,
            let sourceCurrency = self.sourceCurrency,
            let str = rate,
            let value = Double(str) else {
            return nil
        }

        if baseCurrency == sourceCurrency {
            return value
        }

        return 1.0 / value
    }
}
