//
//  YXBullBearFundFlowResModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/4/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXBullBearFundFlowResModel: YXModel {
    @objc var list: [YXBullBearFundFlowItem] = []
    @objc var delay = false
    @objc var nextPageRef = 0
    @objc var hasMore = true
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["list": YXBullBearFundFlowItem.self]
    }
    
    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:];
    }
}

class YXBullBearFundFlowItem: YXModel {
    @objc var asset: YXBullBearFundFlowAsset?
    @objc var top: YXBullBearAsset?
    
    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:];
    }
}

class YXBullBearFundFlowAsset: YXModel {
    @objc var market: String?
    @objc var symbol: String?
    @objc var name: String?
    @objc var netInflow: Int64 = 0
    @objc var type: YXBullAndBellType = YXBullAndBellType.all
    
    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:];
    }
}
