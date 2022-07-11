//
//  YXCYQUtility.swift
//  uSmartOversea
//
//  Created by youxin on 2020/6/2.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import MMKV

class YXCYQUtility: NSObject {

    @objc class func saveCYQState(_ isShow: Bool) {
        MMKV.default().set(isShow, forKey: "CYQViewShowState")
    }

    @objc class func isShowCYQ() -> Bool {
        MMKV.default().bool(forKey: "CYQViewShowState", defaultValue: false)
    }
}
