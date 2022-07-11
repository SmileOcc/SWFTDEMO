//
//  YXDiscoverViewModel.swift
//  uSmartOversea
//
//  Created by lennon on 2022/1/10.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import YXKit
import NSObject_Rx
import URLNavigator

class YXDiscoverViewModel: ServicesViewModel, HasDisposeBag {
    
    typealias Services = AppServices
    
    var navigator: NavigatorServicesType!
    
    var services: Services! {
        didSet {
            // we can do some data refactoring in order to display things exactly the way we want (this is the aim of a ViewModel)
        }
    }
    
}
