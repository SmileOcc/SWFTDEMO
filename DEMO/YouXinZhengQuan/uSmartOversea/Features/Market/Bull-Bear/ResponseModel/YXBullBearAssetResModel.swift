//
//  YXBullBearAssetResModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/4/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXWarrantBullBearModel: YXModel {
    @objc var bull: YXBullBearItem?
    @objc var bear: YXBullBearItem?
    @objc var call: YXBullBearItem?
    @objc var put: YXBullBearItem?
    @objc var rise: [String: AnyObject]?
    @objc var fall: [String: AnyObject]?
    
    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:];
    }
}


class YXBullBearAssetResModel: YXModel {
    @objc var asset: YXBullBearAsset?
    @objc var rise: YXBullBearItem?
    @objc var fall: YXBullBearItem?
    var derivativeType: YXDerivativeType?
    
    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:];
    }
    
//    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
//        return ["asset": YXBullBearAsset.self, "rise": YXBullBearItem.self, "fall": YXBullBearItem.self]
//    }
}

class YXBullBearAssetListModel: YXModel {
    
    @objc var list: [YXBullBearAsset] = []
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["list": YXBullBearAsset.self]
    }
}

class YXBullBearAsset: YXModel {
    @objc var market: String?
    @objc var symbol: String?
    @objc var name: String?
    @objc var type1 = 0
    @objc var type2 = 0
    @objc var type3 = 0
    @objc var latestPrice: Int64 = 0
    @objc var pctchng: Int = 0
    @objc var netchng: Int64 = 0
    @objc var priceBase: Int = 0
    @objc var delay: Bool = false

    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:]
    }
    
}

class YXBullBearItem: YXModel {
    @objc var market: String?
    @objc var symbol: String?
    @objc var name: String?
    @objc var exercisePrice: Int64 = 0
    @objc var impliedVolatility: Int64 = 0
    @objc var recoveryPrice: Int64 = 0
    @objc var effectiveGearing: Int64 = 0 // 有效杠杆
    @objc var gearing: Int64 = 0 // 杠杆比例
    @objc var maturityDate = ""
    @objc var type1 = 0
    @objc var type2 = 0
    @objc var type3 = 0
    @objc var priceBase: Int = 0

    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:]
    }
    
}
