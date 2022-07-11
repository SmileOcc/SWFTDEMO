//
//  YXTradeActiveResponseModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/3/19.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

// 接口文档地址http://szshowdoc.youxin.com/web/#/23?page_id=1145

class YXTradeActiveResponseModel: YXModel {
    @objc var priceBase: Int = 0
    @objc var records: [YXTradeActiveItem] = []
    
    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:];
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["records": YXTradeActiveItem.self]
    }
}

class YXTradeActiveItem: YXModel {
    @objc var name: String?
    @objc var code: String?
    @objc var market: String?
    @objc var bid: Int64 = 0
    @objc var ask: Int64 = 0
    @objc var total: Int64 = 0
    @objc var netFlow: Int64 = 0
    @objc var priceBase: Int = 0
    
    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:];
    }
}
