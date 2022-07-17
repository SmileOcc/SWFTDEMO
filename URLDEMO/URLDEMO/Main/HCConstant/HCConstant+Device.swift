//
//  HCConstant.swift
//  URLDEMO
//
//  Created by odd on 7/3/22.
//

import Foundation
import MMKV
import SAMKeychain
import CryptoSwift

private var SELECTED_MODE_PROPERTY = 0


extension HCConstant {

    @objc public static let screenWidth = UIScreen.main.bounds.size.width
    /**
     屏幕高度
     */
    @objc public static let screenHeight = UIScreen.main.bounds.size.height
    
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
            let array = HCConstant.systemVersion.components(separatedBy: ".")
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
        let value = MMKV.default()!.uint32(forKey: HCConstant.envModeMMKVKey, defaultValue: UInt32.max)
        HCConstant.selectedMode = value
        return value
    }
    
    /// 读取当前存储的目标模式
    ///
    /// - Returns: 目标模式
    @objc public class func envMode() -> HCTargetMode {
        return HCTargetMode(rawValue: Int(MMKV.default()!.uint32(forKey: HCConstant.envModeMMKVKey, defaultValue: UInt32(HCConstant.targetMode().rawValue)))) ?? HCTargetMode.sit
    }
    
    /// 储存当前的目标模式
    ///
    /// - Parameter targeMode: 目标模式
    @objc public class func saveEnvMode(targeMode: HCTargetMode) {
        HCConstant.selectedMode = UInt32(targeMode.rawValue)
        MMKV.default()?.set(UInt32(targeMode.rawValue), forKey: HCConstant.envModeMMKVKey)
    }
    
    /// 是否自动填充短信验证码
    ///
    /// - Returns: 是否填充短信验证码
    @objc public class func isAutoFillCaptcha() -> Bool {
        if HCConstant.targetMode() == .prd {
            return MMKV.default()!.bool(forKey: HCConstant.autoFillCaptchaMMKVKey, defaultValue: false)
        } else {
            return MMKV.default()!.bool(forKey: HCConstant.autoFillCaptchaMMKVKey, defaultValue: true)
        }
    }
    
    /// 设置是否自动填充短信验证码
    ///
    /// - Parameter fillCaptcha: 是否自动填充短信验证码
    @objc public class func saveAutoFillCaptcha(fillCaptcha: Bool) {
        MMKV.default()!.set(fillCaptcha, forKey: HCConstant.autoFillCaptchaMMKVKey)
    }
    
    /**
     当前目标模式
     分为DEV、SIT、UAT、MOCK、PRD和PRD_HK模式
     根据XCConfig中不同的配置进行确定，请先确认Build Configuration是使用了哪个XCCONFIG

     @return 当前目标模式
     */
    @objc public static func targetMode() -> HCTargetMode {
    #if PRD
        return .prd
    #else
        if HCConstant.selectedMode == UInt32.max {
        #if DEV
            return .dev
        #elseif SIT
            return .sit
        #elseif UAT
            return .uat
        #else
            return .sit
        #endif
        } else {
            if let targetMode = HCTargetMode(rawValue: Int(HCConstant.selectedMode)) {
                switch targetMode{
                case .dev, .sit, .uat:
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
        switch HCConstant.targetMode() {
        case .dev:
            return "dev"
        case .sit:
            return "sit"
        case .uat:
            return "uat"
        case .prd:
            return "prd"
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
        let service = HCKeyChainUtil.serviceName(serviceType: .Device, bizType: .DeviceUUID)
        let account = HCKeyChainUtil.accountName(serviceType: .Device)
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

}
