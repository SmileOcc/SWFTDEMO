//
//  YXModuleMoreViewModel.swift
//  uSmartOversea
//
//  Created by Evan on 2022/3/18.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

enum ModuleCategory: Int {
    case trade
    case smartOrder
    case allOrders
    case fractionalTrading
    case deposit
    case withdrawal
    case exchange
    case cashFlow
    case myBankAcc
    case stockDeposit
    case statement
    case more

    var title: String {
        switch self {
        case .trade:
            return YXLanguageUtility.kLang(key: "account_trade")
        case .smartOrder:
            return YXLanguageUtility.kLang(key: "hold_trade_smart_order")
        case .allOrders:
            return YXLanguageUtility.kLang(key: "account_all_orders")
        case .fractionalTrading:
            return YXLanguageUtility.kLang(key: "fractional_trading")
        case .deposit:
            return YXLanguageUtility.kLang(key: "account_deposit")
        case .withdrawal:
            return YXLanguageUtility.kLang(key: "account_withdrawal")
        case .exchange:
            return YXLanguageUtility.kLang(key: "account_exchange")
        case .cashFlow:
            return YXLanguageUtility.kLang(key: "account_cash_flow")
        case .myBankAcc:
            return YXLanguageUtility.kLang(key: "account_my_bank_acc")
        case .stockDeposit:
            return YXLanguageUtility.kLang(key: "account_stock_deposit")
        case .statement:
            return YXLanguageUtility.kLang(key: "statement")
        case .more:
            return YXLanguageUtility.kLang(key: "share_info_more")
        }
    }

    var icon: String {
        switch self {
        case .trade:
            return "entrance_trade"
        case .smartOrder:
            return "entrance_smartorder"
        case .allOrders:
            return "entrance_transactions"
        case .fractionalTrading:
            return "entrance_fractional_trade"
        case .deposit:
            return "entrance_deposit"
        case .withdrawal:
            return "entrance_withdrawal"
        case .exchange:
            return "entrance_cx"
        case .cashFlow:
            return "entrance_cash_flow"
        case .myBankAcc:
            return "entrance_my_bank_acc"
        case .stockDeposit:
            return "entrance_stock_deposit"
        case .statement:
            return "entrance_statement"
        case .more:
            return "entrance_more"
        }
    }
}

class YXModuleMoreViewModel: ServicesViewModel {

    typealias Services = AppServices

    var navigator: NavigatorServicesType!

    var services: Services!

    var market = ""

    init(market: String = "") {
        self.market = market
    }

}
