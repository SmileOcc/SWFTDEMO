//
//  YXCommunityViewModel.swift
//  uSmartOversea
//
//  Created by lennon on 2022/1/10.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import URLNavigator

class YXCommunityViewModel: HUDServicesViewModel  {

 
    typealias Services = HasYXUserService
    var navigator: NavigatorServicesType!
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    var services: Services! {
        didSet {
            
        }
    }
    
    
}

