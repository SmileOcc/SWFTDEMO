//
//  YXSquareViewModel.swift
//  YouXinZhengQuan
//
//  Created by lennon on 2022/3/12.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import URLNavigator

class YXCommunityContainViewModel: HUDServicesViewModel {

    typealias Services = HasYXUserService
    var navigator: NavigatorServicesType!
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    var services: Services! {
        didSet {
            
        }
    }
}
