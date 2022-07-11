//
//  YXETFRankViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2021/3/5.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import YXKit
import NSObject_Rx
import URLNavigator

class YXETFRankViewModel: ServicesViewModel ,HasDisposeBag{
    typealias Services = AppServices
    
    var navigator: NavigatorServicesType!
    
    var services: Services! {
        didSet {
            // we can do some data refactoring in order to display things exactly the way we want (this is the aim of a ViewModel)
        }
    }
}
