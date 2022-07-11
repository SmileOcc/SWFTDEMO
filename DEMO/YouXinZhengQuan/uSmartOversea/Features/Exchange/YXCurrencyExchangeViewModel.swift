//
//  YXCurrencyExchangeViewModel.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/4/28.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator

class YXCurrencyExchangeViewModel: NSObject, HUDServicesViewModel {
    typealias Services = HasYXTradeService & HasYXMessageCenterService

    var navigator: NavigatorServicesType!
    
    // hud的信号
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    @objc dynamic var market: String
    
    var services: Services! {
        didSet {
            
        }
    }
    
    init(market: String) {
        self.market = market
    }
}
