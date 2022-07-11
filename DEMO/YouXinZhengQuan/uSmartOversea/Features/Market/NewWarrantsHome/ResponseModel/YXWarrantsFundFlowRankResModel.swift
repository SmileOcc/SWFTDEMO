//
//  YXWarrantsFundFlowRankResModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/9/25.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXWarrantsFundFlowRankResModel: YXModel {
    
    @objc var count : Int = 0
    @objc var data : [YXWarrantsFundFlowRankItem] = []
    @objc var hasMore : Bool = false
    @objc var nextPageFrom : Int = 0
    @objc var total : Int = 0
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["data": YXWarrantsFundFlowRankItem.self]
    }
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:]
    }
}

class YXWarrantsFundFlowRankItem: YXModel {
    @objc var level = 1
    @objc var asset : YXWarrantsFundFlowRankAsset?
    @objc var derivative : YXWarrantsFundFlowRankDerivative?
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:]
    }
}

class YXWarrantsFundFlowRankAsset: YXModel {
    @objc var bearNetIn : Int64 = 0
    @objc var bullNetIn : Int64 = 0
    @objc var longPosNetIn : Int64 = 0
    @objc var market : String?
    @objc var name : String?
    @objc var priceBase : Int = 0
    @objc var putNetIn : Int64 = 0
    @objc var secuCode : String?
    @objc var shortPosNetIn : Int64 = 0
    @objc var subNetIn : Int64 = 0
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:]
    }
}

class YXWarrantsFundFlowRankDerivative: YXModel {
    @objc var effectiveGearing : Int = 0
    @objc var exercisePrice : Int = 0
    @objc var gearing : Int = 0
    @objc var impliedVolatility : Int = 0
    @objc var latestTime : Int = 0
    @objc var market : String?
    @objc var maturityDate : Int = 0
    @objc var maturityDateScore : Int = 0
    @objc var moneynessScore : Int = 0
    @objc var name : String?
    @objc var outstandingScore : Int = 0
    @objc var priceBase : Int = 0
    @objc var rank : Int = 0
    @objc var recoveryPrice : Int = 0
    @objc var score : Int = 0
    @objc var spreadScore : Int = 0
    @objc var symbol : String?
    @objc var type1 : Int = 0
    @objc var type2 : Int = 0
    @objc var type3 : Int = 0
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:]
    }
}
