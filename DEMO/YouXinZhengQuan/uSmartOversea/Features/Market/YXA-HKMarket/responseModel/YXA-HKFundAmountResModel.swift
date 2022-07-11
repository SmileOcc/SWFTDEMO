//
//  YXA-HKFundAmountResModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/3/19.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXA_HKFundAmountResModel: YXModel {
    @objc var priceBase: Int = 0
    @objc var shAmount: Int64 = 0
    @objc var shRatio: Int = 0
    @objc var totalAmount: Int64 = 0
    @objc var szAmount: Int64 = 0
    @objc var szRatio: Int = 0
    
    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:];
    }
}
