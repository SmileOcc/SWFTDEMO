//
//  YXHistoryBizType.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/1/9.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation

public enum YXHistoryBizType: Int {
    case All
    case Deposit
    case Withdraw
    case Exchange
}

extension YXHistoryBizType: CaseIterable {
    var index:Int {
        switch self {
        case .All:
            return 0
        case .Deposit:
            return 1
        case .Withdraw:
            return 2
        case .Exchange:
            return 3
        }
    }

    var title: String {
        switch self {
        case .All:
            return YXLanguageUtility.kLang(key: "history_biz_type_all")
        case .Deposit:
            return YXLanguageUtility.kLang(key: "history_biz_type_deposit")
        case .Withdraw:
            return YXLanguageUtility.kLang(key: "history_biz_type_withdraw")
        case .Exchange:
            return YXLanguageUtility.kLang(key: "history_biz_type_exchange")
        }
    }
}
