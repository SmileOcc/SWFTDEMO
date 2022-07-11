//
//  YXOrderDetailData.swift
//  uSmartOversea
//
//  Created by ellison on 2019/5/20.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation

class YXOrderDetailData: NSObject, Codable {
    /*sg返回的数据202111**/
    let entrustSide: String?
//    let finalStateFlag: String? //注释掉了nz的
    let market: String? //nz貌似不返还exchangeType了，从int型市场变成了字符串的market
    let status: Int? //1-等待提交，5-待报单，10-报单中，11-待成交，12-等待撤单，13-等待改单，20-部分成交，27-成交处理中，28-部成撤单，29-全部成交，30-已撤单，31-下单失败，32-废单，33-收市撤单
    let statusName: String?
    let symbol: String?
    let symbolName: String?
    let tradePeriod: String?

    /*sg返回的数据**/

//    let statusName: String?
//    let stockCode: String?
//    let stockName: String?
    let document: String?
    var detailList: [YXOrderInfoItem]?
    var entrustType: YXEntrustType?
    var exchangeType: YXExchangeType?
    let finalStateFlag: YXFinalStateFlag? //是否终态标识,0非终态，1是终态
//    let status: Int? //
    var sessionType: UInt?
    /*
     var sessionType: UInt? {
         get {
             //交易阶段标志（0/不传-正常订单交易（默认），1-盘前，2-盘后交易，3-暗盘交易, 12-允许盘前盘后交易）
             if let tradePeriod1 = self.tradePeriod {
                 switch tradePeriod1 {
                 case "N":
                     return 0
                 case "B":
                     return 2
                 case "A":
                     return 1
                 case "AB":
                     return 12
                 default:
                     return nil
                 }
             } else {
                 return nil
             }
         }
     }
     **/
    
    
    let orderType: Int? //订单类型：普通单-0，条件单-1，碎股单-2，月供单-3

    // 日内融返回的模型又以下字段
    let entrustName: String?
    let businessAmount: JSONAny? // 成交数量
    let businessAveragePrice: JSONAny? // 成交均价/成交价格
    let businessBalance: JSONAny?
    let commissionFee: Double? // 港，美，A股,佣金
    let entrustQty: JSONAny? // 委托数量
    let entrustBalance: JSONAny? // 委托金额
    let entrustFee: Double? // 总费用
    let entrustPrice: JSONAny? // 委托价格
    let entrustProp: String?
    let entrustPropName: String?
    let moneyType: Int?
    let payFee: Double? // 港美，交收费
    let platformUseFee: Double? // 港，美，A股,平台使用费
    let stampDutyFee: Double? // 港，A股，印花税
    let tradingSystemUsage: Double? // 港，交易系统使用费
    let transactionFee: Double? // 港：交易费，美：证监会规费
    let transactionLevyFee: Double? // 港，交易征费，美：交易活动费
    let transferFee: Double? // A股过户费
    let superviseFee: Double? // A股证管费
    let registerTransferFee:Double? // A股登记过户费
    let handleFee: Double? // A股经手费

    let depositStockDay: String?
    let retractMark: Int?
    let failReason: String?
    let createTime: String? // 委托时间
    let transactionTime: String? // 订单结束时间
    let finalStatusName: String? // 订单结束状态名
    let symbolType:String? //symbolType  证券类别：1-股票；3-涡轮牛熊；4-期权， 美股期权的时候 market 还是US
    let oddTradeType:Int? // 1-股数 2-金额

    var entrustId: String?

    enum CodingKeys: String, CodingKey {

        case entrustSide
        case finalStateFlag
        case market
        case status
        case statusName
        case symbol
        case symbolName
        case tradePeriod
        
        
//        case stockCode = "stockCode"
//        case stockName = "stockName"
        case document = "document"
        case detailList = "detailList"
        case entrustType = "entrustType"
        case exchangeType = "exchangeType"
        case sessionType = "sessionType"
        case orderType
        case entrustName
        case businessAmount
        case businessAveragePrice
        case businessBalance
        case commissionFee
        case entrustQty
        case entrustBalance
        case entrustFee
        case entrustPrice
        case entrustProp
        case entrustPropName
        case moneyType
        case payFee
        case platformUseFee
        case stampDutyFee
        case tradingSystemUsage
        case transactionFee
        case transactionLevyFee
        case transferFee
        case superviseFee
        case registerTransferFee
        case handleFee
        case depositStockDay
        case retractMark
        case failReason
        case createTime
        case transactionTime
        case finalStatusName
        case symbolType
        case oddTradeType
    }
}

enum YXOrderModifyState: Int {
    case processing = 1
    case successful
    case failed
}

class YXOrderInfoItem: NSObject, Codable {
    var entrustProp: String?
    var entrustPropName: String?
//    var entrustAmount: JSONAny?
//    var businessAmount: JSONAny?
    var businessQty: JSONAny?

    var entrustPrice: JSONAny?
    var entrustBalance: JSONAny?
    //    var businessAveragePrice: JSONAny?
    var entrustQty: JSONAny? // 委托数量

    var businessAvgPrice: JSONAny?
    var businessBalance: JSONAny?
    var moneyType: Int?
    var currency: String?

    var createTime: String?
    var commissionFee: String?
    var platformUseFee: String?
    var stampDutyFee: String?
    var payFee: String?
    var transactionFee: String?
    var transactionLevyFee: String?
    var tradingSystemUsage: String?
    var entrustFee: String?
//    var orderStatus: Int?
    var detailStatus: Int?

//    var orderStatusName: String?
    var detailStatusName: String?

    var depositStockDay: String?
    var handleFee: String?
    var superviseFee: String?
    var transferFee: String?
    var registerTransferFee: String?
    var retractMark: Int? //是否支持展开收起(1-支持)
    var failReason: String?
    var frcTransactionLevyFee: String?
    var exciseFee:String? //消费税（港股，美股，新股，美期）

    var modifyOrderNote: String? // 改单状态文案
    var operateStatus: Int? // 改单状态 1：处理中 2：成功 3：失败

    enum CodingKeys: String, CodingKey {
        case entrustProp = "entrustProp"
        case entrustPropName = "entrustPropName"
        case entrustQty = "entrustQty"

        case businessQty = "businessQty"
        case entrustPrice = "entrustPrice"
        case entrustBalance = "entrustBalance"
        case businessAvgPrice = "businessAvgPrice"
        case businessBalance = "businessBalance"
        case moneyType = "moneyType"
        case currency = "currency"

        case createTime = "createTime"
        case commissionFee = "commissionFee"
        case platformUseFee = "platformUseFee"
        case stampDutyFee = "stampDutyFee"
        case payFee = "payFee"
        case transactionFee = "transactionFee"
        case transactionLevyFee = "transactionLevyFee"
        case tradingSystemUsage = "tradingSystemUsage"
        case entrustFee = "entrustFee"
        case detailStatus = "detailStatus"
        case detailStatusName = "detailStatusName"
        case depositStockDay = "depositStockDay"
        case handleFee = "handleFee"
        case superviseFee = "superviseFee"
        case transferFee = "transferFee"
        case registerTransferFee = "registerTransferFee"
        case retractMark = "retractMark"
        case failReason
        case frcTransactionLevyFee = "frcTransactionLevyFee"
        case exciseFee
        case modifyOrderNote
        case operateStatus
    }
}

//class YXOrderDetailData: NSObject,Codable {
//    var detailList : [YXOrderInfoItem]!
//    var entrustSide : Int!
//    var finalStateFlag : String!
//    var market : Int!
//    var status : Int!
//    var statusName : String!
//    var symbol : String!
//    var symbolName : String!
//
//}
//class YXOrderInfoItem : NSObject,Codable{
//
//    var businessAvgPrice : Int!
//    var businessBalance : Int!
//    var businessQty : Int!
//    var commissionFee : String!
//    var createTime : String!
//    var currency : String!
//    var depositStockDay : String!
//    var detailStatus : Int!
//    var detailStatusName : String!
//    var entrustBalance : Int!
//    var entrustFee : String!
//    var entrustPrice : Int!
//    var entrustProp : String!
//    var entrustPropName : String!
//    var entrustQty : Int!
//    var failReason : String!
//    var handleFee : String!
//    var payFee : String!
//    var platformUseFee : String!
//    var registerTransferFee : String!
//    var stampDutyFee : String!
//    var superviseFee : String!
//    var tradingSystemUsage : String!
//    var transactionFee : String!
//    var transactionLevyFee : String!
//    var transferFee : String!
//
//}
