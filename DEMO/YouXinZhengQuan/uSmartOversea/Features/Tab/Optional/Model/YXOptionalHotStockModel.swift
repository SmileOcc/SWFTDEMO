//
//  YXOptionalHotStockModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/6/30.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXOptionalHotStockModel: NSObject {
    @objc var next_offset: Int = 0
    @objc var hot_stocks: [YXOptionalHotStockDetailInfo]?

    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["hot_stocks": YXOptionalHotStockDetailInfo.self]
    }
}


@objcMembers class YXOptionalHotStockDetailInfo: NSObject {
    var is_self_stock: Bool = false
    var market: String = ""
    var name: String = ""
    var recommend_reason: String = ""
    var symbol: String = ""
    //extern property
    var roc: String = ""
}

