//
//  YXAvailableCashCellViewModel.swift
//  uSmartOversea
//
//  Created by Evan on 2022/5/18.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXAvailableCashCellViewModel: NSObject {

    var icon: String = ""
    var title: String = ""
    var availableCash: String?

    var moneyType: YXCurrencyType = .us

    init(moneyType: YXCurrencyType, availableCash: NSDecimalNumber?) {
        super.init()
        self.moneyType = moneyType
        self.icon = moneyType.iconName()
        self.title = YXLanguageUtility.kLang(key: "available_\(moneyType.requestParam.lowercased())")
        self.availableCash = moneyFormatValue(value: availableCash)
    }

    private func moneyFormatValue(value: NSDecimalNumber?) -> String {
        guard let value = value else {
            return "--"
        }
        return moneyFormatter.string(from: value) ?? "--"
    }

    // 金额格式化
    fileprivate lazy var moneyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.positiveFormat = "###,##0.00";
        formatter.locale = Locale(identifier: "zh")
        return formatter;
    }()

}
