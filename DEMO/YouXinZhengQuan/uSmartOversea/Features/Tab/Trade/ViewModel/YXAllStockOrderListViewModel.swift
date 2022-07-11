//
//  YXAllStockOrderListViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/4/24.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import URLNavigator

class YXAllStockOrderListViewModel: HUDServicesViewModel {
    typealias Services = HasYXTradeService
    
    let exchangeType: YXExchangeType
    
    let allOrderType: YXAllOrderType
    
    var navigator: NavigatorServicesType!

    var externParams: [String : Any] = [:]
    
    // hud的信号
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    var services: Services! {
        didSet {
            // we can do some data refactoring in order to display things exactly the way we want (this is the aim of a ViewModel)
        }
    }
    
    init(exchangeType: YXExchangeType, allOrderType: YXAllOrderType = .normal) {
        self.exchangeType = ((exchangeType == .sh || exchangeType == .sz) ? .hs : exchangeType)
        self.allOrderType = allOrderType
    }
}
