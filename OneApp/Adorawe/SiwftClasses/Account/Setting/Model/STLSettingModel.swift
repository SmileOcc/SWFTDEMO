//
//  STLSettingModel.swift
// XStarlinkProject
//
//  Created by odd on 2021/8/31.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

@objc public enum STLSettingType : Int {
    case country = 0
    case currency
    case language
    case clear
    case rate
    case version
    case notification
    case aboutUs
    case privacy
    case termsOfUsage
}

class STLSettingModel: NSObject {
    var title: String?
    var detailTitle: String?
    var isArrow: Bool = true
    var type: STLSettingType = .currency
}
