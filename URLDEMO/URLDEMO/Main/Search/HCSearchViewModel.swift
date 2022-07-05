//
//  HCSearchViewModel.swift
//  URLDEMO
//
//  Created by odd on 7/4/22.
//

import UIKit
import URLNavigator
import RxSwift
import RxCocoa

class HCSearchViewModel: ServicesViewModel {
    
    var navigator: NavigatorServicesType!

    typealias Services = HasHCLoginService
    
    
    var services: Services! {
        didSet {
            
        }
    }

}
