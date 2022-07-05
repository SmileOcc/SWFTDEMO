//
//  HCHomeViewModel.swift
//  URLDEMO
//
//  Created by odd on 7/4/22.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import URLNavigator

class HCHomeViewModel: ServicesViewModel, HasDisposeBag {
    
    typealias Services = AppServices
    
    var navigator: NavigatorServicesType!
    
    var services: Services! {
        didSet {
            // we can do some data refactoring in order to display things exactly the way we want (this is the aim of a ViewModel)
        }
    }
}
