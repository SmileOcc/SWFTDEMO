//
//  YXMarketDetailItem.swift
//  uSmartOversea
//
//  Created by ellison on 2019/1/7.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXMarketDetailItem2: YXModel {
    @objc var from: Int = 0
    @objc var count: Int = 0
    @objc var total: Int = 0
    @objc var up: Int = 0
    @objc var unchange: Int = 0
    @objc var down: Int = 0
    @objc var limitUp: Int = 0
    @objc var limitDown: Int = 0
    @objc var suspend: Int = 0
    @objc var level: Int = 1
    @objc var list: [[String: Any]] = []
    @objc var detail: [Int] = []
    @objc var rankCode = ""
    
    override class func modelCustomPropertyMapper() -> [String : Any]? {
        nil
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["list": [String: Any].self, "detail": [Int].self]
    }
}
