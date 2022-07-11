//
//  YXTradeMoreViewModel.swift
//  uSmartOversea
//
//  Created by Apple on 2020/4/24.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import URLNavigator

class YXTradeMoreViewModel: ServicesViewModel
{
    typealias Services = AppServices
    
    var navigator: NavigatorServicesType!
    
    var exchangeType: YXExchangeType = .hk
    var showGrey = false
    var ipoTagText: String?
    
    var services: Services! {
        didSet {
        }
    }
    
    init() {
    }
}

