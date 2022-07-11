//
//  YXLearningMainViewModel.swift
//  uSmartOversea
//
//  Created by wangfengnan on 2022/3/17.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Differentiator
import NSObject_Rx
import YXKit
import URLNavigator

class YXLearningMainViewModel: ServicesViewModel, HasDisposeBag {
    typealias Services = HasYXLearningService

    var navigator: NavigatorServicesType!
    
    var services: Services!

}
