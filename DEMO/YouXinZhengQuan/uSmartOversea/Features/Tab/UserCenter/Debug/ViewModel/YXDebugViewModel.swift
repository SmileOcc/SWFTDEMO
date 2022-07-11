//
//  YXDebugViewModel.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/1/19.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import URLNavigator

class YXDebugViewModel: ServicesViewModel  {
    
    typealias Services = HasYXUserService

    var navigator: NavigatorServicesType!
    
    var services: Services! {
        didSet {
            
        }
    }
    
    init() {
        
        
    }
    
    func jsEntrance() {
        let context = YXNavigatable(viewModel: YXDebugJSEntranceViewModel())
        self.navigator.push(YXModulePaths.jsDebugInfo.url, context: context)
    }
}
