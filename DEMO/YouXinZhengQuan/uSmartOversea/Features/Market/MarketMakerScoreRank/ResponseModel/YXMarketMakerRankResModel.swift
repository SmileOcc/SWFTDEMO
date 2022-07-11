//
//  YXMarketMakerRankResModel.swift
//  uSmartOversea
//
//  Created by youxin on 2021/1/6.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXMarketMakerRankResModel: YXModel {
    @objc var list: [YXMarketMakerRankItem] = []
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["list": YXMarketMakerRankItem.self]
    }
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:]
    }
}

class YXMarketMakerRankItem: YXModel {
    @objc var avgAmount : Double = 0
    @objc var avgSpread : Double = 0
    @objc var avgVolume : Int = 0
    @objc var ID : String?
    @objc var latestTime : Int = 0
    @objc var liquidity : Int = 0
    @objc var name : String?
    @objc var nameChs : String?
    @objc var nameCht : String?
    @objc var nameEn : String?
    @objc var oneTickSpreadDuration : Double = 0
    @objc var oneTickSpreadProducts : Int = 0
    @objc var openOnTime : Double = 0
    @objc var score : Int = 0
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [:]
    }
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return ["ID": "id"]
    }
}
