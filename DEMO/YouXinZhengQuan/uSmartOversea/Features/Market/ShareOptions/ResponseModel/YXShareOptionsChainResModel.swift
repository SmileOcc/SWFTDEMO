//
//  YXShareOptionsChainResModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/11/24.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXShareOptionsChainResModel: YXModel {
    
    @objc var callGroup : [YXShareOptionsChainItem] = []
    @objc var putGroup : [YXShareOptionsChainItem] = []
    @objc var code : String?
    @objc var hasMore : Bool = true
    @objc var market : String?
    @objc var maturityDate : String?
    @objc var nextPageBegin : Double = 0
    
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["callGroup": YXShareOptionsChainItem.self, "putGroup": YXShareOptionsChainItem.self]
    }
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:]
    }
}

class YXShareOptionsChainItem: YXModel {
    @objc var amount : Double = 0
    @objc var askPrice : Double = 0
    @objc var askVolume : Int = 0
    @objc var bidPrice : Double = 0
    @objc var bidVolume : Int = 0
    @objc var code : String?
    @objc var delta : Double = 0
    @objc var gamma : Double = 0
    @objc var impliedVolatility : Double = 0
    @objc var latestPrice : Double = 0
    @objc var latestTime : Int64 = 0
    @objc var market : String?
    @objc var maturityDate : Int = 0
    @objc var name : String?
    @objc var netchng : Double = 0
    @objc var openInt : Int64 = 0
    @objc var pctchng : Double = 0
    @objc var premium : Double = 0
    @objc var priceBase : Double = 0
    @objc var rho : Double = 0
    @objc var strikePrice : Double = 0
    @objc var theta : Double = 0
    @objc var vega : Double = 0
    @objc var volume : Int64 = 0
    @objc var CAFlag : Bool = false

    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [:]
    }
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:]
    }

}
