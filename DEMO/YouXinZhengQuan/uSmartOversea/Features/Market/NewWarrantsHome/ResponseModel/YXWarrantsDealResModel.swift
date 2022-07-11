//
//  YXWarrantsDealResModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/9/23.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXWarrantsDealResModel: YXModel {
    @objc var market: String?
    @objc var priceBase: Int = 0
    @objc var warrant: YXWarrantsDealItem?
    @objc var cbbc: YXWarrantsDealItem?
    @objc var other: YXWarrantsDealItem?
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:];
    }
}

class YXWarrantsDealItem: YXModel {
    @objc var ratio: Double = 0
    @objc var amount: Int64 = 0
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:];
    }
}
