//
//  YXWarrantCBBCFundFlowResModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/9/23.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXWarrantCBBCFundFlowResModel: YXModel {
    @objc var priceBase: Int = 0
    @objc var capFlow: [YXWarrantCBBCFundFlowItem] = []
    @objc var shortPosNetInflow: Int64 = 0
    @objc var longPosNetInflow: Int64 = 0
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["capFlow": YXWarrantCBBCFundFlowItem.self]
    }
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:];
    }
    
}

class YXWarrantCBBCFundFlowItem: YXModel {
    @objc var type: YXWarrantType = .buy
    @objc var inflow: Int64 = 0
    @objc var out: Int64 = 0
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return ["inflow": "in"];
    }
}
