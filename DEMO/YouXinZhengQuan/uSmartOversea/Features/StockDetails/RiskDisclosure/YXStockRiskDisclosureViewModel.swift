//
//  YXStockRiskDisclosureViewModel.swift
//  uSmartOversea
//
//  Created by Mac on 2019/9/3.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import URLNavigator

class YXStockRiskDisclosureViewModel: HUDServicesViewModel {
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    var navigator: NavigatorServicesType!
    
    typealias Services = HasYXLoginService & HasYXAggregationService
    
    
    var services: Services! {
        didSet {
        }
    }
}
