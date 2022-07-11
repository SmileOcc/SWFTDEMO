//
//  YXBondHoldListResponseModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/8/8.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation

class YXBondHoldListResponseModel: Codable {
    var bondPositionList : [YXBondHoldModel]?
    var marketValue : String? = ""
    var profit : String? = ""
    var totalProfit : String? = ""
}

class YXBondHoldModel : Codable {

    var availableQuantity : String? = ""
    var bondId : Int? = 0
    var bondName : String? = ""
    var costPrice : String? = ""
    var currency : YXBondHoldCurrency? = YXBondHoldCurrency()
    var frozenQuantity : String? = ""
    var market : YXBondHoldMarket? = YXBondHoldMarket()
    var marketValue : String? = ""
    var positionQuantity : String? = ""
    var price : String? = ""
    var profit : String? = ""
    var profitRatio : String? = ""
    var totalProfit : String? = ""
    var totalProfitRatio : String? = ""
}

class YXBondHoldCurrency : Codable {
    
    var name : String? = ""
    var type : Int? = 0
}

class YXBondHoldMarket : Codable {
    
    var name : String? = ""
    var type : Int? = 0
}


