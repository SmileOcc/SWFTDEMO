//
//  YXPrivacyViewModel.swift
//  uSmartOversea
//
//  Created by ysx on 2022/3/30.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import RxCocoa
import URLNavigator
import RxSwift

class YXPrivacyViewModel: HUDServicesViewModel {
    typealias Services = HasYXUserService
    var navigator: NavigatorServicesType!
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    var services: Services! {
        didSet {
            
        }
    }
}
