//
//  YXA-HKLimitWarningResModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/3/19.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXA_HKLimitWarningResModel: YXModel {
    @objc var priceBase: Int = 0
    @objc var records: [YXA_HKLimitWarningItem] = []
    
    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:];
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["records": YXA_HKLimitWarningItem.self]
    }
}

class YXA_HKLimitWarningItem: YXModel {
    @objc var name: String?
    @objc var code: String?
    @objc var market: String?
    @objc var holdVolume: Int64 = 0
    @objc var tradeDay: String?
    @objc var ratio: Int = 0
    @objc var priceBase: Int = 0
    
    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:];
    }
}
