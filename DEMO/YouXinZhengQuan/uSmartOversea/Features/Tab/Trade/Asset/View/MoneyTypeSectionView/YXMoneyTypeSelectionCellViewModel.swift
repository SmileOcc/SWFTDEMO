//
//  YXMoneyTypeSelectionCellViewModel.swift
//  uSmartOversea
//
//  Created by Evan on 2022/4/18.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXMoneyTypeSelectionCellViewModel: NSObject {

    let model: YXExchangeRateModel
    var selected: Bool = false
    var icon: String = ""
    var moneyType: YXCurrencyType = .us
    var exchangeRateString = ""

    init(model: YXExchangeRateModel) {
        self.model = model
        selected = model.fromMoneyType == model.toMoneyType
        moneyType = YXCurrencyType.currenyType(model.fromMoneyType)
        icon = moneyType.iconName()

        let toMoneyType = YXCurrencyType.currenyType(model.toMoneyType)

        let exchangeRateStr = String(format: "%.4f", model.exchangeRate?.doubleValue ?? 1)
        exchangeRateString = "1 \(moneyType.name()) = \(exchangeRateStr) \(toMoneyType.name())"
    }

}
