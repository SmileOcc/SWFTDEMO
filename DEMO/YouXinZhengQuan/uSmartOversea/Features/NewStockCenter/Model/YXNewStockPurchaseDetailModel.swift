//
//  YXNewStockPurchaseDetailModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/5/10.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

struct YXNewStockPurchaseDetailModel: Codable {
    let applyID, stockName: String?
    let stockCode: String?
    let exchangeType: Int?
    let statusName: String?
    let applyQuantity: Int?
    let applyAmount: Double?
    let allottedQuantity: Int?
    let publishTime: String?
    let moneyType: Int?
    let createTime: String?
    let applyType: Int? //认购类型(1-现金，2-融资)
    let deductStatus: Int?
    let deductStatusName: String?
    let refundFlag: Int?
    let refundAmount: Double?
    let handlingFee: Double?
    let failReason: String?
    let endTime, ipoID: String?
    let labelCode, status: Int?
    let ipoStatus: Int? //新股状态(0-待认购，1-认购中，2-待扣款，3-已扣款待确认，4-已确认待公布，5-已公布待上市，6-已上市，7-取消上市，8-暂缓上市，9-延迟上市)
    let applyTypeName: String?
    let cash: Double?
    let financingAmount, financingBalance, interestRate: Double?
    let latestEndtime, serverTime: String?
    let interestDay: Int?
    let allocatQty: Int?
    let capitalStatus: Int? //扣款状态(0-已冻结，1-已扣款，2-已解冻)
    let capitalStatusName, ecmEndTime, orderTime: String?
    let ecmFee, totalAmount: Double?
    let ecmStatus: Int? //ecm新股状态(0-待认购,1-认购中，2-待扣款，3-待扣款[未全部扣款成功]，4-待提交，5-待分配，6-待返款，7-待返款[未全部返款成功]，8-待返券，9-待返券[未全部返券成功]，10-待CCASS确认，11-待上市，12-已上市，13-暂停认购)
    let channel: Int? //渠道类型(1-APP提交，2-中台提交，99-其它)
    let applyTime: String? //预约时间
    let intentionAmount: Double?
    let listingTime: String?
    let recordType: Int? //记录类型(1-预约记录、2、认购记录)
    let subApplyAmount: Double? //意向投资金额
    let subscribeStatus: Int?  //预约认购状态(客户预约状态 10已预约 20已撤销 30预约失败 40已认购
    let subscribeStatusName: String? //预约认购状态名称
    let subscripSelect: Int?
    let accountCanCancel: Bool?
    let accountCanModify: Bool?
    let listExchanges: String?
    let cancelDeductInterest: Int? // 融资撤销是否扣除利息(0-撤单无需收取利息，1-撤单需要收取利息，2-撤单利息收取中，3-撤单已收取利息)
    let proCancelGuide: Bool?
    
    enum CodingKeys: String, CodingKey {
        case applyID = "applyId"
        case stockName, stockCode, exchangeType, status, statusName, applyQuantity, applyAmount, allottedQuantity, publishTime, moneyType, labelCode, createTime, applyType, deductStatus, deductStatusName, refundFlag, refundAmount, handlingFee, failReason, endTime, ipoStatus
        case ipoID = "ipoId"
        case applyTypeName, cash, financingAmount, financingBalance, interestRate, latestEndtime, interestDay, serverTime
        case allocatQty, capitalStatus, capitalStatusName, ecmEndTime, ecmFee, orderTime, totalAmount, ecmStatus, channel
        case applyTime, intentionAmount, listingTime, recordType, subApplyAmount, subscribeStatus, subscribeStatusName, subscripSelect
        case accountCanCancel, accountCanModify, listExchanges, cancelDeductInterest, proCancelGuide
    }
}


struct YXNewStockPurchaseCancellModel: Codable {

}
