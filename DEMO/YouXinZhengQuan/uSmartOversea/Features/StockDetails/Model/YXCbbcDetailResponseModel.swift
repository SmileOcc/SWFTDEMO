//
//  YXCbbcDetailResponseModel.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/11/18.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXCbbcDetailResponseModel: YXResponseModel {
    @objc var symbol: String = ""
    @objc var market: String = ""
    @objc var range: Double = 0
    @objc var currency: Int = 0
    @objc var priceBase: Int = 0
    @objc var date: Int64 = 0
    @objc var bullRatio: Int = 0
    @objc var bearRatio: Int = 0
    @objc var close: Int = 0
    @objc var bearCell: [CbbcCell] = []
    @objc var bullCell: [CbbcCell] = []
    
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        ["symbol": "data.symbol",
                "market": "data.market",
                "currency": "data.currency",
                "priceBase": "data.priceBase",
                "range": "data.range",
                "date": "data.date",
                "bullRatio": "data.bullRatio",
                "bearRatio": "data.bearRatio",
                "close": "data.close",
                "bearCell": "data.bearCell",
                "bullCell": "data.bullCell",
                ];
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["bearCell": CbbcCell.self,
                "bullCell": CbbcCell.self]
    }
}

class CbbcCell: YXModel {
    @objc var callPutFlag: Int = 0
    @objc var prcLower: Int = 0
    @objc var prcUpper: Int = 0
    @objc var outstanding: Int = 0
    @objc var change: Int = 0
    @objc var heavyCargo: Bool = false
    @objc var maxIncrease: Bool = false

    @objc var percent: Double = 0
}

//        callPutFlag = 3;
//        change = "-46";
//        heavyCargo = 0;
//        maxIncrease = 0;
//        outstanding = 562;
//        prcLower = 275000;
//        prcUpper = 279999;
