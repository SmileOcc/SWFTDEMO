//
//  YXNewStockECMOrderInfoModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/7/20.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

struct YXNewStockECMOrderInfoModel: Codable {
    
    let stockCode, stockName: String?
    let agreeProtocol: String?
    let ecmFee: Double?
    let ecmFeeOriginal: String?
    let ecmId, ipoId: String?
    let ecmLetterList: [YXNewStockEcmInfoLetterModel]?
    let exchangeType, feeType: Int?
    let incrementalAmount, leastAmount, priceMax, priceMin: Double?
    let kindlyReminder: String?
    let riskReminder: String?
    let serverTime: String?
    let moneyType: Int?
    let defineName: String?
    let ecmAppLinkDto: YXNewStockEcmAppLinkDto?
    let piFlag: Int?
    let prospectusLink: String?
    let applyAmount: Double? //意向投资金额
    //let ecmPrepayRemainingTime: String? //国际认购待缴清剩余时间
    //let intentionAmount: Double?
    let incrementalQuantity: Int64?
    let leastQuantity: Int64?
    //let prepayStatus: Int?
    //let serviceFeeRate: Double?
    //let subscribeApplyId: Int64?
    //let subscribeStatus: Int?
    let ecmRecord: YXNewStockECMRecordInfo?
    
    let listExchanges: String?
}


struct YXNewStockEcmInfoLetterModel: Codable {
    let placeLetterName, placeLetterUrl: String?
}


struct YXNewStockECMRecordInfo: Codable {
    let applyAmount: Double?
    let applyId: Int64?
    let applyQuantity: Int?
    let applyType: Int?
    let capitalStatus: Int?
    let subscripSelect: Int?
}

struct YXNewStockECMExsitModel: Codable {
    
    let exist: Bool?
}

struct YXNewStockECMCompensateModel: Codable {
    
    let couponName: String?
    let couponType: Int?  //优惠券类型 1 返现, 2 送股, 3 免佣, 4 行情, 5 礼品
}
