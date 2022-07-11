//
//  YXWarrantsMainViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/1/3.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import YXKit
import NSObject_Rx
import URLNavigator

class YXWarrantsMainViewModel: ServicesViewModel {
    typealias Services = YXQuotesDataService
    
    var services: Services! = YXQuotesDataService()
    
    var navigator: NavigatorServicesType!
}
