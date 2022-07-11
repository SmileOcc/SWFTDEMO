//
//  YXUpdateService.swift
//  uSmartOversea
//
//  Created by ellison on 2019/2/22.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import PluggableApplicationDelegate

class YXUpdateService: NSObject, ApplicationService{
    
    func checkUpdate() {
       YXUpdateManager.shared.checkUpdate()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        checkUpdate()
        return true
    }
}
