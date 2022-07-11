//
//  YXIQKeyboardService.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2018/10/24.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import PluggableApplicationDelegate

class YXIQKeyboardService: NSObject, ApplicationService {
    func configrueIQKeyboardManager() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        configrueIQKeyboardManager()
        return true
    }
    
    
    @objc class func updateEnabled(enabled: Bool) {
        IQKeyboardManager.shared.enable = enabled
    }
}
