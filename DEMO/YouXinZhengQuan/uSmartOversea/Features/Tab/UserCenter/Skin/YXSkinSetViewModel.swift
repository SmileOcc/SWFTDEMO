//
//  YXSkinSetViewModel.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2022/3/21.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import URLNavigator

class YXSkinSetViewModel: HUDServicesViewModel  {

    typealias Services = HasYXUserService
    var navigator: NavigatorServicesType!
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    var services: Services! {
        didSet {
            
        }
    }
}
