//
//  YXHoldFundModel.swift
//  uSmartOversea
//
//  Created by Mac on 2019/9/23.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit



struct YXHoldFundModel: Codable {
    let fundID: String?          //基金id
    let fundCode: String?           //基金code
    let fundName: String?           //基金名称
    let marketValue: String?        //基金市值
    let preEarningBalance: String?  //昨日收益
    let holdingBalance: String?     //持仓盈亏金额
    let lastPrice: String?          //最新价
    let positionShare: String?      //持有份额
    let redeemDeliveryShare: String? //待交收份额
    let inTransitAmount: String?
    let status: Int?                //状态 0:正常 1：部分交易中 2：交易中
    
    enum CodingKeys: String, CodingKey {
        case fundID = "fundId"
        case fundCode = "fundCode"
        case fundName = "fundName"
        case marketValue = "marketValue"
        case preEarningBalance = "preEarningBalance"
        case holdingBalance = "holdingBalance"
        case lastPrice = "lastPrice"
        case positionShare = "positionShare"
        case redeemDeliveryShare = "redeemDeliveryShare"
        case inTransitAmount = "inTransitAmount"
        case status = "status"
    }
    
}
