//
//  YXNewStockDetailInfoModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/5/10.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXNewStockDetailInfoModel: Codable {
    let ipoID, stockName, englishName: String?
    let financingAccountDiff: Int?
    //普通账户融资手续费
    let financingOrdinaryFee: Double?
    
    //高级账户融资手续费
    let financingSeniorFee: Double?
    
    //普通账户融资利率
    let financingOrdinaryRate: Double?
    
    //高级账户融资利率
    let financingSeniorRate: Double?
    
    let market: Int?
    let stockCode: String?
    let status: Int?
    let statusName: String?
    let exchangeType: Int?
    let exchangeTypeName: String?
    let moneyType: Int?
    let bookingFee: Double?
    let handAmount: Int?
    let bookFeeOriginal, beginTime, endTime: String?
    let remainingTime: Int?
    let publishTime, listingTime: String?
    let listingPrice: Double?
    let priceMin, priceMax: Double?
    let officialBegin, officialEnd: String?
    let leastAmount: Double?
    let successRate, bookingRatio: Double?
    let sponsor: String?
    let publishQuantity, totalQuantity, marketValueMin, marketValueMax: Double?
    let prospectusLink, stockIntroduction: String?
    let applied: Bool?
    let updateTime: String?
    let serverTime: String?
    var qtyAndCharges: [YXNewStockQtyAndChargeModel]?
    let tips: String?
    let cash: Double?
    let compFinancingSurplus: Double?
    let financingEndTime, interestBeginDate, interestEndDate: String?
    let financingFee, interestRate: Double?
    let financingMultiple, interestDay: Int?
    let ipoFinancingRatios: [YXNewStockFinanceRatioModel]?
    let subscribeWay: String?
    let depositRate: Double?
    let financingTips: String?
    let bookFeeOriginalFinancing: String?
    let ecmEndTime, latestEndtime: String?
    let ecmStatus: Int? //ecm新股状态(0-待认购,1-认购中，2-待扣款，3-待扣款[未全部扣款成功]，4-待提交，5-待分配，6-待返款，7-待返款[未全部返款成功]，8-待返券，9-待返券[未全部返券成功]，10-待CCASS确认，11-待上市，12-已上市，13-暂停认购)
    let greyFlag: Int?
    let greyTradeDate, greyTimeBegin, greyTimeEnd: String?
    let ecmAppLinkDto: YXNewStockEcmAppLinkDto?
    let ecmLeastAmount: Double? //国际认购起购资金
    let ecmRemainingTime: Int? //国际认购认购剩余时间（秒）
    let piFlag: Int?
    let ipoRemainingTime: Int?
    let publicEndTime: String?
    let listExchanges: String?
    let enableEnough: Bool?
    
    enum CodingKeys: String, CodingKey {
        case ipoID = "ipoId"
        case stockCode, stockName, englishName, status, statusName, exchangeType, exchangeTypeName, moneyType, handAmount, bookingFee, bookFeeOriginal, beginTime, endTime, remainingTime, publishTime, listingTime, listingPrice, priceMin, priceMax, officialBegin, officialEnd, leastAmount, successRate, bookingRatio, sponsor, publishQuantity, totalQuantity, marketValueMin, marketValueMax, prospectusLink, stockIntroduction, applied, updateTime, serverTime, qtyAndCharges, tips, market, financingOrdinaryFee, financingSeniorFee, financingOrdinaryRate, financingSeniorRate, financingAccountDiff
        case cash, compFinancingSurplus, financingEndTime, financingFee, financingMultiple, interestBeginDate, interestDay, interestEndDate
        case interestRate, ipoFinancingRatios, subscribeWay, depositRate, financingTips, bookFeeOriginalFinancing
        case ecmEndTime, latestEndtime, ecmStatus
        case greyFlag, greyTradeDate, greyTimeBegin, greyTimeEnd
        case ecmAppLinkDto, ecmLeastAmount, ecmRemainingTime, piFlag, ipoRemainingTime, publicEndTime
        case listExchanges, enableEnough
    }
}

struct YXNewStockEcmAppLinkDto: Codable {
    let ecmLabel: String?
    let ecmText: String?
    let link: String?
    let name: String?
    
    enum CodingKeys: String, CodingKey {
        case ecmLabel
        case ecmText
        case link
        case name
    }
}

struct YXNewStockFinanceRatioModel: Codable {
    let exchangeType: Int?
    let financingAmountBegin: Double?
    let financingAmountEnd: Double?
    let interestRate: Double?
    let stockCode: String?
    
    enum CodingKeys: String, CodingKey {
        case exchangeType = "exchange_type"
        case financingAmountBegin = "financing_amount_begin"
        case financingAmountEnd = "financing_amount_end"
        case interestRate = "interest_rate"
        case stockCode = "stock_code"
    }
}

class YXNewStockQtyAndChargeModel: Codable {
    let stockCode: String?
    let exchangeType, sharedApplied: Int?
    let appliedAmount: Double?
    let allottedAmount: Double?
    let leastCash: Double?
    let financingMultiple: Int?
    var moneyType: Int?
    var availableAmount: Double?
    var purchaseNum: Int?
    var purchaseAmount: Double?
    var cashHandlingFee: Double?
    var financeHandlingFee: Double?
    
    enum CodingKeys: String, CodingKey {
        case stockCode = "stock_code"
        case exchangeType = "exchange_type"
        case sharedApplied = "shared_applied"
        case appliedAmount = "applied_amount"
        case allottedAmount = "allotted_amount"
        case leastCash, financingMultiple
        case moneyType, availableAmount, purchaseNum, purchaseAmount, cashHandlingFee, financeHandlingFee
    }
}

struct YXNewStockAvailbleAmountModel: Codable {
    let moneyType, currentBalance, enableBalance, foregiftBalance: String?
    let frozenBalance, unfrozenBalance, withdrawBalance, marketValue: String?
    let asset, ipoBalance, cashOnHold: String?
    let yxIpoBalance: String?
}

struct YXNewStockApplyPurchaseModel: Codable {

    let status: Int? //申购状态(0-已提交,1-已认购,2-等待改单, 3-等待撤销,4-已撤销,5-已扣款,6-待公布中签,7-全部中签,8-部分中签,9-未中签,10-认购失败,20-申请额度中)
}

struct YXNewStockAddFocusModel: Codable {
    
}

class YXPurchaseDetailParams {
    var exchangeType: Int
    let ipoId: String
    let stockCode: String
    let applyId: Int64
    let isModify: Int  //0-正常下单 1-改单
    var shared_applied: Int   //认购数量
    var applied_amount: Double //认购金额
    let moneyType: Int  //2- 港币， 1-美元， 0-人民币
    let financeAmount: Double
    let applyType: YXNewStockSubsType //认购类型(1-现金，2-融资, 3-国际配售)
    let interestAmount: Double
    let ipoType: YXNewStockEcmType
    let ecmApplyAmount: Double //ecm改单时的认购金额，存在手续费会中途变化的情况
    
    init (exchangeType: Int = 0, ipoId: String = "", stockCode: String = "", applyId: Int64 = 0, isModify: Int = 0, shared_applied: Int = 0, applied_amount: Double = 0.0, moneyType: Int = 2, applyType: YXNewStockSubsType = .cashSubs, financeAmount: Double = 0.0, interestAmount: Double = 0.0, ipoType: YXNewStockEcmType = .onlyPublic, ecmApplyAmount: Double = 0.0) {
        self.exchangeType = exchangeType
        self.ipoId = ipoId
        self.stockCode = stockCode
        self.applyId = applyId
        self.isModify = isModify
        self.shared_applied = shared_applied
        self.applied_amount = applied_amount
        self.moneyType = moneyType
        self.applyType = applyType
        self.financeAmount = financeAmount
        self.interestAmount = interestAmount
        self.ipoType = ipoType
        self.ecmApplyAmount = ecmApplyAmount
    }
}

enum YXNewStockPurcahseStatus: Int {
    case waited = 0  //待认购
    case purchasing  //认购中
    case waitForPurchase //代扣款
    case purchaseConfirmed //已扣款待确认
    case confirmWaitAnnounce //已确认待公布
    case announceedWaitMarket = 5 //已公布待上市
    case marketed = 6         //已上市
    case cancelMarket       //取消上市
    case slowMarket         //暂缓上市
    case delayMarket = 9       //延迟上市
    case ecmWaitMarket = 11 //ecm待上市
    case ecmMarketed = 12 //ecm已上市
    
    case ecmReconfirm = 15 //ecm重新确认中
    case ecmReCancel = 16 //ecm撤销确认中
    case none
    
    
    static func currentStatus(_ status: Int?) -> YXNewStockPurcahseStatus {
        var purcahseStatus: YXNewStockPurcahseStatus = YXNewStockPurcahseStatus.none
        if let sStatus = status,
            let tempStatus = YXNewStockPurcahseStatus(rawValue: sStatus) {
            if tempStatus == .ecmWaitMarket {
                purcahseStatus = .announceedWaitMarket
            } else if tempStatus == .ecmMarketed {
                purcahseStatus = .marketed
            } else {
                purcahseStatus = tempStatus
            }
        }
        return purcahseStatus
    }
}

extension YXNewStockPurcahseStatus: Codable {
    public init(from decoder: Decoder) throws {
        self = try YXNewStockPurcahseStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .none
    }
}

