//
//  YXA-HKFundDirectionRankModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/3/18.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXA_HKFundDirectionRankModel: YXModel {
    @objc var priceBase: Int = 0
    @objc var records: [YXA_HKFundDirectionRankItem] = []
    
    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:];
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["records": YXA_HKFundDirectionRankItem.self]
    }
}

class YXA_HKFundDirectionRankItem: YXModel {
    @objc var name: String?
    @objc var code: String?
    @objc var market: String?
    @objc var volume: Int = 0
    @objc var amount: Int64 = 0
    @objc var ratio: Int = 0
    @objc var priceBase: Int = 0
    
    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:];
    }
}
