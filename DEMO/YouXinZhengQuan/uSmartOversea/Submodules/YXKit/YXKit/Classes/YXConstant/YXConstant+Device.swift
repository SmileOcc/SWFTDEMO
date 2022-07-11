//
//  YXConstant+Device.swift
//  YouXinZhengQuan
//
//  Created by ellison on 2019/3/26.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import SAMKeychain
import CryptoSwift
import SystemConfiguration
import MMKV

private var SELECTED_MODE_PROPERTY = 0

extension YXConstant {

    /**
     系统名称
     e.g. @"iOS"

     @return 系统名称
     */
    @objc public static let systemName = UIDevice.current.systemName

    /**
     系统版本
     e.g. @"4.0"

     @return 系统版本
     */
    @objc public static let systemVersion = UIDevice.current.systemVersion

    /**
     设备名称
     e.g. "My iPhone"

     @return 设备名称
     */
    @objc public static let deviceName = UIDevice.current.name

    /**
     设备型号
     e.g. @"iPhone", @"iPod touch"

     @return 设备型号
     */
    @objc public static let deviceModel = UIDevice.current.model

    /**
     本地化型号

     @return 本地化型号
     */
    @objc public static let localizedModel = UIDevice.current.localizedModel
    
    /// 网络环境配置Key值
    fileprivate static let envModeMMKVKey = "yx_env_mode"
    
    /// 是否自动填充短信验证码
    fileprivate static let autoFillCaptchaMMKVKey = "yx_autofill_captcha"
    
    /// 为了提升效率，使用一个全局变量记住是否使用备份机房
    fileprivate static var isReadedBackupEnv = false
    fileprivate static var backupEnv = false
    
    fileprivate static let backupEnvMMKVKey = "yx_backup_env"
    
    fileprivate static let globalConfigMMKVKey = "kGlobalConfigSwitch"
    
    fileprivate static let httpDnsEnableMMKVKey = "kHttpDnsEnableMMKVKey"
    
    /// 系统版本号
    @objc public static var systemVersionValue: UInt32 {
        get {
            let array = YXConstant.systemVersion.components(separatedBy: ".")
            assert(array.count <= 3, "systemVersion字符串格式不对")
            var valueString = ""
            (array as NSArray).enumerateObjects({ obj, idx, stop in
                if let str = obj as? String {
                    if idx == 1 && str.count < 2 {
                        valueString += String(format: "%02d", Int(str) ?? 0)
                    } else if idx == 2 && str.count < 4 {
                        valueString += String(format: "%04d", Int(str) ?? 0)
                    } else {
                        valueString += str
                    }

                }
            })
            
            return UInt32(valueString) ?? 0
        }
    }
    
    /**
     当前选择的网络环境模式
     */
    fileprivate static var selectedMode: UInt32 {
        get {
            let result = objc_getAssociatedObject(self, &SELECTED_MODE_PROPERTY) as? UInt32
            if result == nil {
                return initTargetMode()
            }
            return result!
        }
        set {
            objc_setAssociatedObject(self, &SELECTED_MODE_PROPERTY, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    /// 初始化目标模式
    @objc public class func initTargetMode() -> UInt32 {
        let value = MMKV.default().uint32(forKey: YXConstant.envModeMMKVKey, defaultValue: UInt32.max)
        YXConstant.selectedMode = value
        return value
    }
    
    /// 读取当前存储的目标模式
    ///
    /// - Returns: 目标模式
    @objc public class func envMode() -> YXTargetMode {
        return YXTargetMode(rawValue: Int(MMKV.default().uint32(forKey: YXConstant.envModeMMKVKey, defaultValue: UInt32(YXConstant.targetMode().rawValue)))) ?? YXTargetMode.sit
    }
    
    /// 储存当前的目标模式
    ///
    /// - Parameter targeMode: 目标模式
    @objc public class func saveEnvMode(targeMode: YXTargetMode) {
        YXConstant.selectedMode = UInt32(targeMode.rawValue)
        MMKV.default().set(UInt32(targeMode.rawValue), forKey: YXConstant.envModeMMKVKey)
    }
    
    /// 是否自动填充短信验证码
    ///
    /// - Returns: 是否填充短信验证码
    @objc public class func isAutoFillCaptcha() -> Bool {
        if YXConstant.targetMode() == .prd || YXConstant.targetMode() == .prd_hk {
            return MMKV.default().bool(forKey: YXConstant.autoFillCaptchaMMKVKey, defaultValue: false)
        } else {
            return MMKV.default().bool(forKey: YXConstant.autoFillCaptchaMMKVKey, defaultValue: true)
        }
    }
    
    /// 设置是否自动填充短信验证码
    ///
    /// - Parameter fillCaptcha: 是否自动填充短信验证码
    @objc public class func saveAutoFillCaptcha(fillCaptcha: Bool) {
        MMKV.default().set(fillCaptcha, forKey: YXConstant.autoFillCaptchaMMKVKey)
    }
    
    /// 是否使用备份机房
    /// - Returns: 是否使用备份机房
    @objc public class func isBackupEnv() -> Bool {
        if (YXConstant.targetMode() == .prd || YXConstant.targetMode() == .prd_hk) && !YXConstant.isReadedBackupEnv {
            YXConstant.backupEnv = MMKV.default().bool(forKey: YXConstant.backupEnvMMKVKey, defaultValue: false)
            YXConstant.isReadedBackupEnv = true
            return YXConstant.backupEnv
        }
        return YXConstant.backupEnv
    }
    
    /// 设置是否使用备份机房
    /// - Parameter status: 是否使用备份机房
    @objc public class func saveBackupEnvStatus(status: Bool) {
        YXConstant.backupEnv = status
        MMKV.default().set(status, forKey: YXConstant.backupEnvMMKVKey)
    }
    
    /// 是否使用全局配置
    /// - Returns: 是否使用全局配置
    @objc public class func isGlobalConfig() -> Bool {
        if YXConstant.targetMode() == .prd || YXConstant.targetMode() == .prd_hk {
            return MMKV.default().bool(forKey: YXConstant.globalConfigMMKVKey, defaultValue: true)
        } else {
            return MMKV.default().bool(forKey: YXConstant.globalConfigMMKVKey, defaultValue: false)
        }
    }
    
    /// 设置是否使用全局配置
    /// - Parameter status: 是否使用全局配置
    @objc public class func saveGlobalConfigStatus(status: Bool) {
        MMKV.default().set(status, forKey: YXConstant.globalConfigMMKVKey)
    }
    
    /// 是否使用腾讯云HTTP DNS服务
    /// - Returns: 是否使用腾讯云HTTP DNS服务
    @objc public class func httpDnsEnable() -> Bool {
        return MMKV.default().bool(forKey: YXConstant.httpDnsEnableMMKVKey, defaultValue: true)
    }
    
    /// 设置是否使用腾讯云HTTP DNS服务
    /// - Parameter enable: 设置是否使用腾讯云HTTP DNS服务
    @objc public class func saveHttpDnsEnable(enable: Bool) {
        MMKV.default().set(enable, forKey: YXConstant.httpDnsEnableMMKVKey)
    }
    
    /**
     当前目标模式
     分为DEV、SIT、UAT、MOCK、PRD和PRD_HK模式
     根据XCConfig中不同的配置进行确定，请先确认Build Configuration是使用了哪个XCCONFIG

     @return 当前目标模式
     */
    @objc public static func targetMode() -> YXTargetMode {
    #if PRD
        return .prd
    #elseif PRD_HK
        return .prd_hk
    #else
        if YXConstant.selectedMode == UInt32.max {
        #if DEV
            return .dev
        #elseif SIT
            return .sit
        #elseif UAT
            return .uat
        #elseif MOCK
            return .mock
        #else
            return .sit
        #endif
        } else {
            if let targetMode = YXTargetMode(rawValue: Int(YXConstant.selectedMode)) {
                switch targetMode{
                case .dev, .sit, .uat, .mock:
                    return targetMode
                default:
                    return .sit;
                }
            } else {
                return .sit
            }
        }
    #endif
    }
    
    /**
     当前目标模式对应的Name
     分为DEV、SIT、UAT、MOCK、PRD和PRD_HK模式
     根据XCConfig中不同的配置进行确定，请先确认Build Configuration是使用了哪个XCCONFIG
     
     @return 当前目标模式对应的Name
     */
    @objc public static func targetModeName() -> String? {
        switch YXConstant.targetMode() {
        case .dev:
            return "dev"
        case .sit:
            return "sit"
        case .uat:
            return "uat"
        case .mock:
            return "mock"
        case .prd:
            return "prd"
        case .prd_hk:
            return "prd_hk"
        default:
            return "Unkown"
        }
    }

    /**
     设备UUID
     已通过keychain确保UUID的唯一性

     @return 设备UUID
     */
    @objc public static var deviceUUID: String = {
        let service = YXKeyChainUtil.serviceName(serviceType: .Device, bizType: .DeviceUUID)
        let account = YXKeyChainUtil.accountName(serviceType: .Device)
        if
            let uniqueKeyItem = SAMKeychain.password(forService: service, account: account),
            uniqueKeyItem.count > 0
        {
            return uniqueKeyItem
        } else {
            // 生成设备唯一id 系统不保存 自己做保存
            if let idfa = UIDevice.current.identifierForVendor {
                let md5UUID = idfa.uuidString.md5()
                SAMKeychain.setPassword(md5UUID, forService: service, account: account)
                return md5UUID
            }

            return ""
        }
    }()

    /// 返回雪花算法计算的随机数
    ///
    /// - Returns: 计算出的随机数
    @objc public static func flakeId() -> Int64 {
        return Thread.current.nextFlakeID() ^ Int64(YXUserHelper.currentUUID())
    }
    
    /// 返回雪花算法与xorNumber进行异或后，计算出的随机数
    ///
    /// - Parameter xorNumber: 用于异或的数字
    /// - Returns: 计算出的随机数
    @objc public static func flakeId(withXorNumber xorNumber: Int64) -> Int64 {
        return Thread.current.nextFlakeID() ^ xorNumber
    }

    @objc public static func deviceInfo() -> String {
        return "\(UIDevice.modelName)-iOS-\(UIDevice.current.systemVersion)"
    }

}

extension UIDevice {

    @objc public static var modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { (identifier, elementin) -> String in
            guard let value = elementin.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        switch identifier {
        case"iPhone3,1","iPhone3,2","iPhone3,3":     return "iPhone 4"
        case"iPhone4,1":                             return "iPhone 4S"
        case"iPhone5,1","iPhone5,2":                 return "iPhone 5"
        case"iPhone5,3","iPhone5,4":                 return "iPhone 5c"
        case"iPhone6,1","iPhone6,2":                 return "iPhone 5s"
        case"iPhone7,2":                             return "iPhone 6"
        case"iPhone7,1":                             return "iPhone 6 Plus"
        case"iPhone8,1":                             return "iPhone 6s"
        case"iPhone8,2":                             return "iPhone 6s Plus"
        case"iPhone8,3","iPhone8,4":                 return "iPhone SE"
        case"iPhone9,1","iPhone9,3":                 return "iPhone 7"
        case"iPhone9,2","iPhone9,4":                 return "iPhone 7 Plus"
        case"iPhone10,1","iPhone10,4":               return "iPhone 8"
        case"iPhone10,2","iPhone10,5":               return "iPhone 8 Plus"
        case"iPhone10,3","iPhone10,6":               return "iPhone X"
        case"iPhone11,2":                            return "iPhone XS"
        case"iPhone11,4","iPhone11,6":               return "iPhone XS MAX"
        case"iPhone11,8":                            return "iPhone XR"
        case"iPhone12,1":                            return "iPhone 11"
        case"iPhone12,3":                            return "iPhone 11 Pro"
        case"iPhone12,5":                            return "iPhone 11 Pro Max"

        case"iPod1,1":                               return "iPod Touch 1G"
        case"iPod2,1":                               return "iPod Touch 2G"
        case"iPod3,1":                               return "iPod Touch 3G"
        case"iPod4,1":                               return "iPod Touch 4G"
        case"iPod5,1":                               return "iPod Touch (5 Gen)"
        case"iPod7,1":                               return "iPod Touch 6"
        case"iPod9,1":                               return "iPod Touch 7"
            
        case"iPad1,1":                               return "iPad"
        case"iPad1,2":                               return "iPad 3G"
        case"iPad2,1":                               return "iPad 2 (WiFi)"
        case"iPad2,2","iPad2,4":                     return "iPad 2"
        case"iPad2,3":                               return "iPad 2 (CDMA)"
        case"iPad2,5":                               return "iPad Mini (WiFi)"
        case"iPad2,6":                               return "iPad Mini"
        case"iPad2,7":                               return "iPad Mini (GSM+CDMA)"
        case"iPad3,1":                               return "iPad 3 (WiFi)"
        case"iPad3,2":                               return "iPad 3 (GSM+CDMA)"
        case"iPad3,3":                               return "iPad 3"
        case"iPad3,4":                               return "iPad 4 (WiFi)"
        case"iPad3,5":                               return "iPad 4"
        case"iPad3,6":                               return "iPad 4 (GSM+CDMA)"
        case"iPad4,1":                               return "iPad Air (WiFi)"
        case"iPad4,2":                               return "iPad Air (Cellular)"
        case"iPad4,4":                               return "iPad Mini 2 (WiFi)"
        case"iPad4,5":                               return "iPad Mini 2 (Cellular)"
        case"iPad4,6":                               return "iPad Mini 2"
        case"iPad4,7","iPad4,8","iPad4,9":           return "iPad Mini 3"
        case"iPad5,1":                               return "iPad Mini 4 (WiFi)"
        case"iPad5,2":                               return "iPad Mini 4 (LTE)"
        case"iPad5,3","iPad5,4":                     return "iPad Air 2"
        case"iPad6,3","iPad6,4":                     return "iPad Pro 9.7"
        case"iPad6,7","iPad6,8":                     return "iPad Pro 12.9"
        case"iPad6,11":                              return "iPad 5 (WiFi)"
        case"iPad6,12":                              return "iPad 5 (Cellular)"
        case"iPad7,1":                               return "iPad Pro 12.9 inch 2nd gen (WiFi)"
        case"iPad7,2":                               return "iPad Pro 12.9 inch 2nd gen (Cellular)"
        case"iPad7,3":                               return "iPad Pro 10.5 inch (WiFi)"
        case"iPad7,4":                               return "iPad Pro 10.5 inch (Cellular)"
        case"iPad7,5":                               return "iPad 6th Gen (WiFi)"
        case"iPad7,6":                               return "iPad 6th Gen (WiFi+Cellular)"
        case"iPad7,11":                              return "iPad 7th Gen 10.2-inch (WiFi)"
        case"iPad7,12":                              return "iPad 7th Gen 10.2-inch (WiFi+Cellular)"
        case"iPad8,1":                               return "iPad Pro 3rd Gen (11 inch, WiFi)"
        case"iPad8,2":                               return "iPad Pro 3rd Gen (11 inch, 1TB, WiFi)"
        case"iPad8,3":                               return "iPad Pro 3rd Gen (11 inch, WiFi+Cellular)"
        case"iPad8,4":                               return "iPad Pro 3rd Gen (11 inch, 1TB, WiFi+Cellular)"
        case"iPad8,5":                               return "iPad Pro 3rd Gen (12.9 inch, WiFi)"
        case"iPad8,6":                               return "iPad Pro 3rd Gen (12.9 inch, 1TB, WiFi)"
        case"iPad8,7":                               return "iPad Pro 3rd Gen (12.9 inch, WiFi+Cellular)"
        case"iPad8,8":                               return "iPad Pro 3rd Gen (12.9 inch, 1TB, WiFi+Cellular)"
        case"iPad11,1":                              return "iPad mini 5th Gen (WiFi)"
        case"iPad11,2":                              return "iPad mini 5th Gen"
        case"iPad11,3":                              return "iPad Air 3rd Gen (WiFi)"
        case"iPad11,4":                              return "iPad Air 3rd Gen"

        case"AppleTV2,1":                            return "Apple TV 2"
        case"AppleTV3,1":                            return "Apple TV 3"
        case"AppleTV3,2":                            return "Apple TV 3"
        case"AppleTV5,3":                            return "Apple TV 4"

        case"i386","x86_64":                         return "Simulator"
        default:                                     return identifier
        }
    }()
}

