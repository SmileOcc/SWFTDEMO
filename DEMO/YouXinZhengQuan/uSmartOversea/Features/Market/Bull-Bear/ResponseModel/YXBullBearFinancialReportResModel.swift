//
//  YXBullBearFinancialReportResModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/4/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXBullBearFinancialReportResModel: YXModel {
    @objc var list: [YXBullBearFinancialReportItem] = []
    @objc var nextPageRef = 0
    @objc var hasMore = true
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["list": YXBullBearFinancialReportItem.self]
    }
    
    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:];
    }
}

class YXBullBearFinancialReportItem: YXModel {
    @objc var finance: YXBullBearFinancial? //资产信息
    @objc var rise: YXBullBearItem?
    @objc var fall: YXBullBearItem?
    
    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:];
    }
}

class YXBullBearFinancial: YXModel {
    @objc var market: String?
    @objc var symbol: String?
    @objc var name: String?
    @objc var publishDate: String?
    
    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:];
    }
}

