//
//  YXMarginQuantityModel.swift
//  YouXinZhengQuan
//
//  Created by Mac on 2020/3/19.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXMarginQuantityModel: YXModel {
    /// 现金可买数量-包含碎股 
    @objc var cashEnableAmount:Double = 0
    /// 现金购买力
    @objc var cashPurchasingPower = "--"
    /// 融资数量
    @objc var marginAmount: NSNumber = 0
    /// 融资金额
    @objc var marginBalance: NSNumber = 0
    
}
