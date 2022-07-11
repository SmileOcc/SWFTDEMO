//
//  YXLaunchGuideManager.swift
//  uSmartOversea
//
//  Created by Mac on 2019/10/25.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation

class YXLaunchGuideManager : NSObject {
    class func isGuideToLogin() -> Bool {
        MMKV.default().bool(forKey: "YXGuideToLoginKey", defaultValue: false)
    }
    
    class func setGuideToLogin(withFlag flag:Bool) {
        MMKV.default().set(flag, forKey: "YXGuideToLoginKey")
    }
}
