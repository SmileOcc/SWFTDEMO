//
//  YXRangesResponseModel.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/11/18.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXRangesResponseModel: YXResponseModel {
    @objc var symbol: String = ""
    @objc var market: String = ""
    @objc var currency: Int = 0
    @objc var priceBase: Int = 0
    @objc var range: [NSNumber] = []
    @objc var date: [NSNumber] = []
    
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        ["symbol": "data.symbol",
                "market": "data.market",
                "currency": "data.currency",
                "priceBase": "data.priceBase",
                "range": "data.range",
                "date": "data.date",
                ];
    }
}
