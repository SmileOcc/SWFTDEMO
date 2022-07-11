//
//  YXUSAuthStateWebViewModel.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/5/29.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXUSAuthStateWebViewModel: YXWebViewModel {
    
    var dragStyle = false
    
    var isFromeRegister = false
    
    @objc var isHideSkip = true
    
    @objc class func pushToWebVCForOC() {
        let context = YXNavigatable(viewModel: YXUSAuthStateWebViewModel(dictionary: [:]))
                    YXNavigationMap.navigator.push(YXModulePaths.USAuthState.url, context: context)
    }
    
    convenience init(dictionary: Dictionary<String, Any>, loginCallBack: (([String: Any])->Void)?, sourceVC: UIViewController?, hideSkip:Bool? = true) {
        self.init(dictionary: dictionary)
        self.loginCallBack = loginCallBack
        self.sourceVC = sourceVC
        
        if let skip = hideSkip {
            isHideSkip = skip
        }
        
    }
}
