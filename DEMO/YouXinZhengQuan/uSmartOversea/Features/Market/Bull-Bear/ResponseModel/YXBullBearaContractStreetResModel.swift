//
//  YXBullBearaContractStreetResModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/4/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXBullBearaContractStreetResModel: YXModel {
    @objc var bearList: [YXBullBearaContractStreetItem] = [] //熊证
    @objc var bullList: [YXBullBearaContractStreetItem] = [] //牛证
    @objc var asset: YXBullBearAsset?
    @objc var delay = false
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["bearList": YXBullBearaContractStreetItem.self, "bullList": YXBullBearaContractStreetItem.self]
    }
    
    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:];
    }
}

class YXBullBearaContractStreetItem: YXModel {
    @objc var top: YXBullBearaContractStreetStock? //精选权证行情
    @objc var outstanding: YXBullBearaContractStreetOutstanding? //街货占比信息
    @objc var priceBase = 0
    
    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:];
    }
}

class YXBullBearaContractStreetStock: YXModel {
    @objc var market: String?
    @objc var symbol: String?
    @objc var name: String?
    
    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:];
    }
}

class YXBullBearaContractStreetOutstanding: YXModel {
    @objc var CallPutFlag = 0 //牛熊标记
    @objc var PrcLower: Int64 = 0 // 价格下限
    @objc var PrcUpper: Int64 = 0 // 价格上限
    @objc var Outstanding: Int64 = 0 // 街货量
    @objc var Change: Int64 = 0 // 街货量变化
    @objc var HeavyCargo: Bool = false // 重货区标识
    @objc var MaxIncrease: Bool = false // 最大变化区标识
    
    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:];
    }
}

class YXWarrantsStreetTopResModel: YXModel {
    @objc var items: [YXWarrantsStreetTopItem] = [] //熊证
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["items": YXWarrantsStreetTopItem.self]
    }
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:];
    }
}

class YXWarrantsStreetTopItem: YXModel {
    @objc var bullRatio: Double = 0
    @objc var bearRatio: Double = 0
    @objc var asset: YXBullBearaContractStreetStock?
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:];
    }
}
