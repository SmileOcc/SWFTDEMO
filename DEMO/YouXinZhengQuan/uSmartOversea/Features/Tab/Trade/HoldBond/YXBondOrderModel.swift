//
//  YXBondOrderModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/8/6.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation

class YXBondOrderModel: NSObject, Codable {
    
    var bondId : Int64? = 0
    var bondName : String? = ""
    var clinchPrice : String? = ""
    var clinchQuantity : String? = ""
    var createTime : Int64? = 0
    var direction : Direction? = Direction()
    var entrustPrice : String? = ""
    var entrustQuantity : String? = ""
    var entrustPartQuantity: String?
    var externalStatus : Int? = 0
    var externalStatusName : String? = ""
    var failedRemark : String? = ""
    var bondMarket : Market? = Market()
    var finalStatus: Bool? = false
    var minFaceValue: Int?
    var orderNo : String?
    var orderDirection: String?
//    var exchangeType: YXExchangeType = .us
}

class Direction : Codable {
    var name : String? = ""
    var type : Int? = 0
}

class Market : Codable {
    var name : String? = ""
    var type : Int? = 0
}
