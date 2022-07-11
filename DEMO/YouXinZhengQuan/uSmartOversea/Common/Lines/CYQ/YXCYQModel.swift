//
//  YXCYQModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/6/1.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

// MARK: - YXCYQModel
@objcMembers class YXCYQModel: NSObject {
    var priceBase: Int = 1
    var rights: String = ""
    var list: [YXCYQList]?
    var nextPageRef: UInt64 = 0
    var hasMore: Bool = false

    class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["list": YXCYQList.self]
    }
}

// MARK: - YXCYQList
@objcMembers class YXCYQList: YXModel {
    var tradeDay: UInt64 = 0
    var close: Int = 0
    var winnerRate: Int = 0
    var avgCost: Int = 0
    var supPosition: Int = 0
    var pressPosition: Int = 0
    var chipCoincidence: Int = 0
    var ninetyPer: YXCYQTyPer?
    var seventyPer: YXCYQTyPer?
    var column: [YXCYQColumn]?

    class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["column": YXCYQColumn.self, "ninetyPer": YXCYQTyPer.self, "seventyPer": YXCYQTyPer.self]
    }

}

// MARK: - YXCYQColumn
@objcMembers class YXCYQColumn: YXModel {
    var price: Int = 0
    var vol: Int = 0
}

// MARK: - YXCYQTyPer
@objcMembers class YXCYQTyPer: YXModel {
    var beginPrice: Int = 0
    var endPrice: Int = 0
}
