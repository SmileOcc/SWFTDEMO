//
//  YXNotiViewModel.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/13.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import URLNavigator

class YXNotiViewModel: HUDServicesViewModel  {

    typealias Services = HasYXUserService
    var navigator: NavigatorServicesType!
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    var services: Services! {
        didSet {
            
        }
    }
}
