//
//  YXLaunchGurdeViewModel.swift
//  uSmartOversea
//
//  Created by Mac on 2019/10/25.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator

class YXLaunchGurdeViewModel: HUDServicesViewModel {
    typealias Services = HasYXNewsService
    
    var disposeBag = DisposeBag.init()

    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    var navigator: NavigatorServicesType!
    
    var services: Services! {
    didSet {
        
        }
    }
    
}
