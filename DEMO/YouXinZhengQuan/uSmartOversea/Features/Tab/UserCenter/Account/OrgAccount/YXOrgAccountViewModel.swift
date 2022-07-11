//
//  YXAccountViewModel.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/10.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import URLNavigator

class YXOrgAccountViewModel: HUDServicesViewModel  {

    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    typealias Services = HasYXUserService
    var navigator: NavigatorServicesType!
    
    var services: Services! {
        didSet {

        }
    }
    
    init() {
        
        
    }
}
