//
//  YXEntrustData.swift
//  uSmartOversea
//
//  Created by ellison on 2019/5/17.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation

struct YXEntrustData: Codable, Equatable {
    let pageNum, pageSize, total: Int?
    let list: [YXOrderItem]?
    let nowDate: String?
}

enum YXOrderFlag: String {
    // 订单类型0-普通单1-条件单2-碎股单3-月供股单7-智能订单
    case normal = "0"
    case condition = "1"
    case odd = "2"
    case month = "3"
    case smart = "7"
    case unknown
    
    public init?(flag: String) {
        switch flag {
        case "0":
            self = .normal
        case "1":
            self = .condition
        case "2":
            self = .odd
        case "3":
            self = .month
        case "7":
            self = .smart
        default:
            self = .normal
        }
    }
    
    var text: String? {
        switch self {
        case .condition:
            return YXLanguageUtility.kLang(key: "hold_tracks")
        case .odd:
            return YXLanguageUtility.kLang(key: "broken_order")
        case .month:
            return YXLanguageUtility.kLang(key: "hold_monthly_order")
        case .smart:
            return YXLanguageUtility.kLang(key: "hold_smart_order")
        default:
            return nil
        }
    }

    var textColor: UIColor? {
        switch self {
        case .condition, .smart:
            return UIColor.qmui_color(withHexString: "#3471E9")
        case .odd:
            return UIColor.qmui_color(withHexString: "#25A5B7")
        case .month:
            return UIColor.qmui_color(withHexString: "#5B3BE8")
        default:
            return nil
        }
    }
}

extension YXOrderFlag: Codable {
    public init(from decoder: Decoder) throws {
        self = try YXOrderFlag(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

enum YXEntrustType: Int {
    case buy = 0
    case sell = 1
    case unknown
    
    var text: String {
        switch self {
        case .buy,
             .unknown:
            return YXLanguageUtility.kLang(key: "hold_buy")
        case .sell:
            return YXLanguageUtility.kLang(key: "hold_sell")
        }
    }
    
    var textColor: UIColor? {
        switch self {
        case .buy,
             .unknown:
            return QMUITheme().stockRedColor()
        default:
            return QMUITheme().stockGreenColor()
        }
    }
}

enum YXEntrustType2: String {
    case buy = "B"
    case sell = "S"
    case unknown = ""
    
    var text: String {
        switch self {
        case .buy,
             .unknown:
            return YXLanguageUtility.kLang(key: "hold_buy")
        case .sell:
            return YXLanguageUtility.kLang(key: "hold_sell")
        }
    }
    
    var textColor: UIColor? {
        switch self {
        case .buy,
             .unknown:
            return QMUITheme().stockRedColor()
        default:
            return QMUITheme().stockGreenColor()
        }
    }
}
extension YXEntrustType2: Codable {
    public init(from decoder: Decoder) throws {
        self = try YXEntrustType2(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

extension YXEntrustType: Codable {
    public init(from decoder: Decoder) throws {
        self = try YXEntrustType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

enum YXFinalStateFlag: String {
    case normal = "0"
    case final = "1"
    case unknown
}

extension YXFinalStateFlag: Codable {
    public init(from decoder: Decoder) throws {
        self = try YXFinalStateFlag(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

class YXOrderItem:NSObject, Codable {
    var entrustId, entrustNo, id: String?
    var status: Int?
    var statusName: String?
    var entrustType: YXEntrustType? //买卖方向,委托类型(0-买，1-卖)
    var entrustProp: String? //委托属性('0'-美股限价单,'d'-竞价单,'e' -增强限价单,'g'-竞价限价单,'h'-港股限价单,'j'-特殊限价单)
    var entrustAmount, businessAmount: Double?
    var businessQty,entrustQty: Double?
    var entrustPrice, businessAveragePrice,businessAvgPrice: Double?
    var stockCode,symbol, stockName,symbolName: String?
    var moneyType: Int?
    var createTime, createDate: String?
    var finalStateFlag: YXFinalStateFlag?
    var flag: String? //订单类型-普通单1-条件单2-碎股单3-月供股单7-智能订单
    var dayEnd: Int?
    var conId: JSONAny?
    var strategyEnddate: String?
    var strategyEnddateDesc: String?
    var statusDes: String?
    var conditionPrice: Double?
    var entrustTotalMoney: Double?
    var sessionType: Int? //交易阶段标志（0/不传-正常订单交易（默认），1-盘前，2-盘后交易，3-暗盘交易）
    var market :String?
    var entrustSide : YXEntrustType2?//买卖方向,委托类型(0-B，1-S)
    var symbolType: String?
    
    init(entrustId: String? = nil,
         entrustNo: String? = nil,
         id: String? = nil,
         status: Int? = nil,
         statusName: String? = nil,
         entrustType: YXEntrustType?  = nil,
         entrustProp: String? = nil,
         entrustAmount: Double? = nil,
         businessAmount: Double? = nil,
         entrustPrice: Double? = nil,
         businessAveragePrice: Double? = nil,
         stockCode: String? = nil,
         stockName: String? = nil,
         moneyType: Int? = nil,
         createTime: String? = nil,
         createDate: String? = nil,
         flag: String? = nil,
         finalStateFlag: YXFinalStateFlag? = nil,
         dayEnd: Int? = nil,
         conId: JSONAny? = nil,
         strategyEnddate: String? = nil,
         strategyEnddateDesc: String? = nil,
         statusDes: String? = nil,
         conditionPrice: Double? = nil,
         entrustTotalMoney: Double? = nil,
         sessionType: Int? = nil) {
        self.entrustId = entrustId
        self.entrustNo = entrustNo
        self.id = id
        self.status = status
        self.statusName = statusName
        self.entrustType = entrustType
        self.entrustProp = entrustProp
        self.entrustAmount = entrustAmount
        self.businessAmount = businessAmount
        self.entrustPrice = entrustPrice
        self.businessAveragePrice = businessAveragePrice
        self.stockCode = stockCode
        self.stockName = stockName
        self.moneyType = moneyType
        self.createTime = createTime
        self.createDate = createDate
        self.flag = flag
        self.finalStateFlag = finalStateFlag
        self.dayEnd = dayEnd
        self.conId = conId
        self.strategyEnddate = strategyEnddate
        self.strategyEnddateDesc = strategyEnddateDesc
        self.statusDes = statusDes
        self.conditionPrice = conditionPrice
        self.entrustTotalMoney = entrustTotalMoney
        self.sessionType = sessionType
    }
}
