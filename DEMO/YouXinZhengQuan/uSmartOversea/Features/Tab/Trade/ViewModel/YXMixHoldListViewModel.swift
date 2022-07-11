//
//  YXMixHoldListViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/8/14.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import URLNavigator

class YXMixHoldListViewModel: HUDServicesViewModel {
    typealias Services = HasYXTradeService
    
    var navigator: NavigatorServicesType!
    
    let exchangeType: YXExchangeType
    // hud的信号
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    var services: Services! {
        didSet {
            // we can do some data refactoring in order to display things exactly the way we want (this is the aim of a ViewModel)
        }
    }
    
    init(exchangeType: YXExchangeType) {
        self.exchangeType = exchangeType
    }
    

}
