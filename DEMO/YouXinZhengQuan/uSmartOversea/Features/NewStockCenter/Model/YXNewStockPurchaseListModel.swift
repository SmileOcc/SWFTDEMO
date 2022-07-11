//
//  YXNewStockPurchaseListModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/5/10.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import Differentiator

struct YXNewStockPurchaseListModel: Codable {
    let pageNum, pageSize, total: Int?
    let list: [YXNewStockPurchaseListDetailModel]?
}

struct YXNewStockPurchaseListDetailModel: Codable {
    let applyID, stockName: String?
    let stockCode: String?
    let exchangeType: Int?
    let statusName: String?
    let applyQuantity: Int?
    let applyAmount: Double?
    let allottedQuantity: Int?
    let publishTime: String?
    let moneyType: Int?
    let labelCode, status: Int?
    let cash: Double?
    let financingAmount: Double?
    let financingBalance: Double?
    let interestRate: Double?
    let latestEndtime: String?
    let applyType: Int? //认购类型(1-现金，2-融资)
    let applyTypeName: String?
    let totalAmount: Double?
    let applyTime: String? //预约时间
    let intentionAmount: Double? //预约意向金
    let recordType: Int?  //记录类型(1-预约记录、2、认购记录)
    let subApplyAmount: Double? //意向投资金额
    let subscribeStatus: Int?  //预约认购状态(客户预约状态 10已预约 20已撤销 30预约失败 40已认购
    let subscribeStatusName: String? //预约认购状态名称
    let listExchanges: String?
    let applyCompnay: String?
    let xchannel: Int?  //部外渠道ID：0-默认，1-团购，其它渠道参考营销   
    
    enum CodingKeys: String, CodingKey {
        case applyID = "applyId"
        case stockName, stockCode, exchangeType, status, statusName, applyQuantity, applyAmount, allottedQuantity, publishTime, moneyType, labelCode
        case cash, financingAmount, financingBalance, interestRate, latestEndtime, applyType, applyTypeName
        case totalAmount, applyTime, intentionAmount, recordType, subApplyAmount, subscribeStatus, subscribeStatusName, listExchanges, applyCompnay
        case xchannel
    }
}

extension YXNewStockPurchaseListDetailModel: IdentifiableType {
    typealias Identity = String
    
    var identity: String {
        (stockName ?? "") + (stockCode ?? "")
    }
}

//认购状态(0-已提交,1-已认购,2-等待改单, 3-等待撤销,4-已撤销,5-已扣款,6-待公布中签,7-全部中签,8-部分中签,9-未中签,10-认购失败)
enum YXNewStockPurchaseType: Int {
    case commited = 0
    case purchased = 1
    case waitChange = 2
    case waitCancel = 3
    case canceled = 4
    case deducted = 5
    case waitAnnounceWined = 6
    case totalWined = 7
    case partWined = 8
    case notWined = 9
    case purchaseFailed = 10
    case reconfirmed = 13  //待重新确认
    case pendingConfirmation = 15  //待撤销确认
    case financeApplying = 20  //融资认购排队中
    case none = 9999
    
    static func currentStatus(_ status: Int?) -> YXNewStockPurchaseType {
        var type = YXNewStockPurchaseType.none
        if let tempStatus = status,
            let tempType = YXNewStockPurchaseType(rawValue: tempStatus) {
            type = tempType
        }
        return type
    }
}

extension YXNewStockPurchaseType: Codable {
    public init(from decoder: Decoder) throws {
        self = try YXNewStockPurchaseType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .none
    }
}

//预约认购状态(客户预约状态 10已预约 20已撤销 30预约失败 40已认购
enum YXNewStockSubscribeStatusType: Int {
    case alreadyReserved = 10
    case cancel = 20
    case fail = 30
    case subscribe = 40
    case needConfirm = 9999 //待确认

    
    static func currentStatus(_ status: Int?) -> YXNewStockSubscribeStatusType {
        var type = YXNewStockSubscribeStatusType.needConfirm
        if let tempStatus = status,
            let tempType = YXNewStockSubscribeStatusType(rawValue: tempStatus) {
            type = tempType
        }
        return type
    }
}
