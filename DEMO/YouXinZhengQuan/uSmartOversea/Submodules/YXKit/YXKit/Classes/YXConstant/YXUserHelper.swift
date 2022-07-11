//
//  YXUserHelper.swift
//  Alamofire
//
//  Created by 付迪宇 on 2019/8/23.
//

import MMKV
import SwiftyJSON
import SAMKeychain

@objc public enum YXUserLevel: Int {
    case none = -1
    case usDelay = 0
    case usLevel1 = 1
    case hkDelay = 2
    case hkBMP = 3
    case hkLevel2 = 4
    case hkWorldLevel2 = 5
    case cnDelay = 6
    case cnLevel1 = 7
    case usoLevel1 = 11         //美股期权
    case usaArcaLevel2 = 14      //美股arca深度摆盘
    case usaThreeLevel1 = 15    //美股三大指数
    case hkLevel1 = 16
    case usNation = 17          // 全美行情
    case sgDelay = 18            //新加坡延迟
    case sgLevel1Overseas = 19   //新加坡海外lv1
    case sgLevel2Overseas = 20   //新加坡海外lv2
    case sgLevel1CN = 21         //新加坡中国lv1
    case sgLevel2CN = 22         //新加坡中国lv2
}

fileprivate let YXUser =        "YXUser"
fileprivate let YXLanguage =    "YXLanguage"
fileprivate let YXUserToken =   "YXUserToken"
fileprivate let YXUserUUID =    "YXUser_UUID"

fileprivate let YXCurBroker = "YXCurBroker"   //当前登陆的券商
fileprivate let YXCurBrokerToken = "YXCurBrokerToken"   //当前登陆的券商

@objcMembers public class YXUserHelper: NSObject {
    
    @objc public static func currentUUID() -> UInt64 {
        var uuid: UInt64 = 0
        
        if let obj = MMKV.default().object(of: NSNumber.self, forKey: YXUserUUID) as? NSNumber {
            uuid = obj.uint64Value
        }
        
        if uuid < 1 {
            let service = YXKeyChainUtil.serviceName(serviceType: .Guest, bizType: .GuestUUID)
            let account = YXKeyChainUtil.accountName(serviceType: .Guest)
            if let uuidString = SAMKeychain.password(forService: service, account: account) {
                uuid = UInt64(uuidString) ?? 0
            }
        }
        
        return uuid
    }
    
    @objc public static func currentToken() -> String {
        if let token = MMKV.default().string(forKey: YXUserToken) {
            return token
        }
        return ""
    }
    
    @objc public static func currentLanguage() -> Int32 {
        let mmkv = MMKV.default()
        let lang = mmkv.int32(forKey: YXLanguage)
        return lang
    }
    
    @objc public static func currentUsLevel() -> YXUserLevel {
        // 有全美行情下,直接用全美的
        if currentUsNationLevel() == .usNation {
            return .usNation
        }
        
        if let data = MMKV.default().data(forKey: YXUser), let json = try? JSON(data: data) {
            let path = ["userQuotationVOList","usa","productCode"]
            if let level = YXUserLevel(rawValue: json[path].intValue) {
                return level
            }
        }
        return .usDelay
    }
    @objc public static func currentUsNationLevel() -> YXUserLevel {
        if let data = MMKV.default().data(forKey: YXUser), let json = try? JSON(data: data) {
            let path = ["userQuotationVOList","usaNation","productCode"]
            if let level = YXUserLevel(rawValue: json[path].intValue) {
                return level
            }
        }
        return .usDelay
    }
    
    @objc public static func currentHkLevel() -> YXUserLevel {
        if let data = MMKV.default().data(forKey: YXUser), let json = try? JSON(data: data) {
            let path = ["userQuotationVOList","hk","productCode"]
            if let level = YXUserLevel(rawValue: json[path].intValue) {
                return level
            }
        }
        return .hkDelay
    }
    
    @objc public static func currentCnLevel() -> YXUserLevel {
        if let data = MMKV.default().data(forKey: YXUser), let json = try? JSON(data: data) {
            let path = ["userQuotationVOList","zht","productCode"]
            if let level = YXUserLevel(rawValue: json[path].intValue) {
                return level
            }
        }
        if YXConstant.appTypeValue == .CN {
            return .cnLevel1
        } else {
            return .cnLevel1
        }
    }
    
    @objc public static func currentUSOptionLevel() -> YXUserLevel {
        if let data = MMKV.default().data(forKey: YXUser), let json = try? JSON(data: data) {
            let path = ["userQuotationVOList","uso","productCode"]
            if json[path].intValue == 11 {
                return .usLevel1
            }
        }
        return .usDelay
    }
    
    @objc public static func currentUSIndexLevel() -> YXUserLevel {
        if let data = MMKV.default().data(forKey: YXUser), let json = try? JSON(data: data) {
            let path = ["userQuotationVOList","usaThree","productCode"]
            if json[path].intValue == 15 {
                return .usLevel1
            }
        }
        return .none
    }
    
    @objc public static func currentSGLevel() -> YXUserLevel {
        if let data = MMKV.default().data(forKey: YXUser), let json = try? JSON(data: data) {
            let path = ["userQuotationVOList","sg","productCode"]
            let lv = json[path].intValue
            if  let level = YXUserLevel.init(rawValue: lv) {
                return level
            }
        }
        return .sgDelay
    }
    
    @objc public static func currentBroker() -> String {
        if let broker = MMKV.default().string(forKey: YXCurBroker) {
            return broker
        }
        return ""
    }
    @objc public static func currentBrokerToken() -> String {
        if let token = MMKV.default().string(forKey: YXCurBrokerToken) {
            return token
        }
        return ""
    }
}
