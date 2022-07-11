//
//  YXNewStockSubsType.swift
//  uSmartOversea
//
//  Created by youxin on 2019/7/15.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit


//认购类型
enum YXNewStockSubsType: Int {
    case cashSubs = 1     //现金认购
    case financingSubs = 2 //融资认购
    case internalSubs = 3 //国际认购
    case reserveSubs = 4  //国际预付认购
    case internalAppointmentSubs = 14 //国际预约
    
    static func subscriptionType(_ type: Int?) -> YXNewStockSubsType {
        if let type = type, let subsType = YXNewStockSubsType.init(rawValue: type)  {
            return subsType
        }
        return .cashSubs
    }
}

//认购类型

enum YXNewStockEcmType: Int {
    case onlyPublic = 0
    case onlyInternal
    case bothButInternalEnd
    case both
}


//扣款状态
enum YXNewStockDeductStatus: Int {
    case frozen = 0  //已冻结
    case debited = 1 //已扣款
    case unfrozen = 2 //已解冻
}

struct YXNewStockDateFormatter {
    static let defaultFormatter: String = "yyyy-MM-dd HH:mm:ss"
    static let defaultShortFormatter: String = "yyyy-MM-dd"
    
    static func unixTime(_ timeString: String?) -> TimeInterval {
        var unixTime: TimeInterval = -1.0
        if let time = timeString, time.count >= YXNewStockDateFormatter.defaultFormatter.count {
            unixTime = YXDateHelper.unixTime(from: time, formatter: YXNewStockDateFormatter.defaultFormatter)
        } else if let time = timeString, time.count >= YXNewStockDateFormatter.defaultShortFormatter.count {
            unixTime = YXDateHelper.unixTime(from: time.subString(toCharacterIndex: UInt(YXNewStockDateFormatter.defaultShortFormatter.count)), formatter: YXNewStockDateFormatter.defaultShortFormatter)
        }
        return unixTime
    }
    
    static func shortUnixTime(_ timeString: String?) -> TimeInterval {
        var unixTime: TimeInterval = -1.0
        if let time = timeString, time.count >= YXNewStockDateFormatter.defaultShortFormatter.count {
            unixTime = YXDateHelper.unixTime(from: time.subString(toCharacterIndex: UInt(YXNewStockDateFormatter.defaultShortFormatter.count)), formatter: YXNewStockDateFormatter.defaultShortFormatter)
        }
        return unixTime
    }
    
    static func timeGreater(left: String?, right: String?) -> Bool {

        let leftUnixTime = self.unixTime(left)
        let rightUnixTime = self.unixTime(right)
        return leftUnixTime > rightUnixTime
    }
}

class YXNewStockMoneyFormatter: NSObject {
    static let thousandthBalanceNumber: Double = 0.0049
    static let internalBaseRate: Double = (1 + 0.01 + 0.00005 + 0.000027)
    static let usBaseRate: Double = 1.2
    
    static let shareInstance = YXNewStockMoneyFormatter()
    lazy var moneyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "zh")
        return formatter
    }()

    //判断base是不是increse的整数倍, base == 0时默认是整数倍
    static func isIntergerMultiple(_ base: Double, increse: Double, pointCount: Int) -> Bool {

        let powerBase = pow(10.0, Double(pointCount))
        let leftNumber = Int64(base * powerBase)
        let rightNumber = Int64(increse * powerBase)
        
        if leftNumber == 0 || rightNumber == 0 {
            return true
        } else if leftNumber % rightNumber == 0 {
            return true
        }
        return false
    }
    
    func formatterMoney(_ availAmount: Int64) -> String {
        
        self.moneyFormatter.positiveFormat = "###,##0"
        if let moneyString = self.moneyFormatter.string(from: NSNumber(value: availAmount)) {
            
            return moneyString
        }
        return String(availAmount)
    }
    
    func formatterMoney(_ availAmount: Int) -> String {
        
        self.moneyFormatter.positiveFormat = "###,##0"
        if let moneyString = self.moneyFormatter.string(from: NSNumber(value: availAmount)) {
            
            return moneyString
        }
        return String(availAmount)
    }
    
    func formatterMoney(_ availAmount: Double, pointCount: Int = 2) -> String {
        
        var format = "%.0lf"
        var moneyFomatter = "###,##0"
        if pointCount > 0 {
            format = String(format: "%@.0%d%@", "%", pointCount, "lf")
            moneyFomatter = "###,##0."
            for _ in 0..<pointCount {
                moneyFomatter += "0"
            }
        }
    
        self.moneyFormatter.positiveFormat = moneyFomatter
        if let doubleAmount = Double(String(format: format, availAmount)),
            let moneyString = self.moneyFormatter.string(from: NSNumber(value: doubleAmount)) {
            
            return moneyString
        }
        return String(format: format, availAmount)
    }
    
}


