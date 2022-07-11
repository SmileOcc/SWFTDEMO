//
//  YXGuessUpAndDownResModel.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2021/3/18.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import IGListKit

class YXGuessUpAndDownResModel: YXModel {
    @objc var stockInfos : [YXGuessUpAndDownStockInfo] = []
    @objc var extraInfos : [YXGuessUpAndDownStockInfo] = []
    @objc var total = 0
    
    // 手动更改该值,导致ig刷新, 取反就好了
    @objc var refreshRecord = false
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["stockInfos": YXGuessUpAndDownStockInfo.self, "extraInfos": YXGuessUpAndDownStockInfo.self]
    }
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:]
    }
}

class YXGuessUpAndDownStockInfo: YXModel {
    @objc var downCount : String?
    @objc var guessChange : String? // 0：跌，1：涨
    @objc var stockCode : String?
    @objc var transDate : String?
    @objc var upCount : String?
    @objc var quote: YXV2Quote?
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [:]
    }
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:]
    }
}

extension YXGuessUpAndDownResModel: ListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        return self
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        
        guard self !== object else { return true }
        guard let object = object as? YXGuessUpAndDownResModel else { return false }
        
        return isEqual(object) && refreshRecord == object.refreshRecord
    }
}
