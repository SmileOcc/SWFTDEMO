//
//  YXDebugJSEntranceViewModel.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/1/21.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import URLNavigator

class YXDebugJSEntranceViewModel: ServicesViewModel  {
    
    typealias Services = HasYXUserService
    
    var navigator: NavigatorServicesType!
    
    var services: Services! {
        didSet {
            
        }
    }
    
    init() {
        
        
    }
}
