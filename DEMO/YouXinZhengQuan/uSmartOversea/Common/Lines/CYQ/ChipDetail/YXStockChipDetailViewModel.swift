//
//  YXStockChipDetailViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/7/23.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YYModel
import URLNavigator
import YXKit

@objcMembers class YXStockChipDetailViewModel: NSObject, HUDServicesViewModel {

    // hud的信号
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()

    //step/service
    typealias Services = YXQuotesDataService
    var services: YXQuotesDataService! = YXQuotesDataService()

    var navigator: NavigatorServicesType!

    let newStockService = YXNewStockService()

    var isFromLand = false

    var name: String = ""
    var symbol: String = ""
    var market: String = ""
    //init
    convenience init(market: String, symbol: String, name: String?) {
        self.init()
        
        self.name = name ?? ""
        self.market = market
        self.symbol = symbol
    }
}

