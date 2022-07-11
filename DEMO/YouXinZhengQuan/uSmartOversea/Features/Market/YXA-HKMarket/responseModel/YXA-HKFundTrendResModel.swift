//
//  YXA-HKFundTrendResModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/3/25.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXA_HKFundTrendResModel: YXModel {
    @objc var codeKlineList: [YXA_HKFundTrendItem] = []
    @objc var hasMore = false
    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:];
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["codeKlineList": YXA_HKFundTrendItem.self]
    }
}

class YXA_HKFundTrendItem: YXModel {
    @objc var code: String?
    @objc var klineList: [YXA_HKFundTrendKlineItem] = []
    @objc var priceBase: Int = 0
    @objc var nextReqDay:Int64 = 0
    
    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:];
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["klineList": YXA_HKFundTrendKlineItem.self]
    }
}

class YXA_HKFundTrendKlineItem: YXModel {
    @objc var amount: Int64 = 0
    @objc var price: Int64 = 0
    @objc var time = ""
    @objc var index: NSNumber = 0
    
    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:];
    }
}

class YXA_HKFundTrendKlineCustomModel: YXModel {
    @objc var totalAmount: Double = 0.0
    @objc var shAmount: Double = 0.0
    @objc var szAmount: Double = 0.0
    @objc var shIndexPrice: Double = 0.0
    @objc var shIndexChangeAmount: Int64 = 0 // 涨跌额，用来判断是涨还是跌
    @objc var szIndexPrice: Double = 0.0
    @objc var szIndexChangeAmount: Int64 = 0
    @objc var HSIIndexPrice: Double = 0.0
    @objc var HSIIndexChangeAmount: Int64 = 0
    @objc var time = ""
    @objc var fundPriceBase = 0
    @objc var indexPriceBase = 0
    @objc var index: NSNumber = 0
    
}
