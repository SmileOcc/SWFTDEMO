//
//  YXAggregatedOrderListViewModel.swift
//  uSmartOversea
//
//  Created by Evan on 2021/12/27.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

@objc enum YXAggregatedOrderListTab: UInt {
    case normal
    case smartOrder
}

class YXAggregatedOrderListViewModel: ServicesViewModel {
    typealias Services = AppServices

    var navigator: NavigatorServicesType!

    var services: Services! {
        didSet {
        }
    }

    var defaultTab: YXAggregatedOrderListTab
    var exchangeType: YXExchangeType?

    init(defaultTab: YXAggregatedOrderListTab?, exchangeType: YXExchangeType?) {
        self.defaultTab = defaultTab ?? .normal
        self.exchangeType = exchangeType
    }
}
