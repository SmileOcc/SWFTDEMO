//
//  YXMarketViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/12/11.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import YXKit
import NSObject_Rx
import URLNavigator

class YXMarketViewModel: ServicesViewModel, HasDisposeBag {
    
    typealias Services = AppServices
    
    var navigator: NavigatorServicesType!
    
    var services: Services! {
        didSet {
            // we can do some data refactoring in order to display things exactly the way we want (this is the aim of a ViewModel)
        }
    }
    
    var selectIndex = BehaviorRelay<Int>(value: 0)
    
    var quoteNoticeModels:[YXNoticeModel]?
    var watchlistsNoticeModels:[YXNoticeModel]?
    var hkNoticeModels:[YXNoticeModel]?
    var usNoticeModels:[YXNoticeModel]?
    var sgNoticeModels:[YXNoticeModel]?
}
