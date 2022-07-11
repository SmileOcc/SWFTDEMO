//
//  YXWarrantsFundFlowKLineResModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/9/27.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXWarrantsFundFlowKLineResModel: YXModel {
    @objc var longPos: YXWarrantsFundFlowKLine?
    @objc var shortPos: YXWarrantsFundFlowKLine?
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:];
    }
}

class YXWarrantsFundFlowKLine: YXModel {
    @objc var priceBase: Double = 0.0
    @objc var data: [YXWarrantsFundFlowKLineItem] = []
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["data": YXWarrantsFundFlowKLineItem.self]
    }
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:];
    }
}

class YXWarrantsFundFlowKLineItem: YXModel {
    @objc var time: Int64 = 0
    @objc var inFlow: Int64 = 0 //流入金额
    @objc var out: Int64 = 0 //流出金额
    @objc var netin: Int64 = 0 //净流入
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return ["inFlow": "in"];
    }
}
