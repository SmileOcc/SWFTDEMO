//
//  YXConstant.swift
//  YouXinZhengQuan
//
//  Created by ellison on 2019/3/26.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

@objc public enum YXTargetMode : Int {
    case dev    // 开发环境
    case sit    // 系统内部集成测试环境
    case uat    // 用户验收测试环境
    case mock   // 测试Mock环境
    case prd    // 生产环境
    case prd_hk // 生产环境（HK）
}
// 网络环境配置Key值
#if YXZQ_ENV_MODE_SET
let ENV_MODE_MMKV_KEY = "yx_env_mode"
#endif

// 自动填充短信验证码
#if YXZQ_AUTOFILL_CAPTCHA
let AUTOFILL_CAPTCHA_MMKV_KEY = "yx_autofill_captcha"
#endif


public class YXConstant: NSObject {
    @objc public static let sharedAppDelegate = UIApplication.shared.delegate
    
    /// App类型
    @objc public enum YXAppType: Int {
        case CN         = 0x01        // 大陆版
        case HK         = 0x02        // 香港版
        case ZTMASTER   = 0x04        // 涨停大师
        case PRO        = 0x05        // PRO版
        case OVERSEA    = 0x09        // 海外版
        case EDUCATION  = 0x0B        // 教育版
        case OVERSEA_SG = 0x0c        //海外版SG
    }
    
    /**
     获取当前应用的BundleIdentifier

     @return BundleIdentifier
     */
    @objc public static let bundleId = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String

    /**
     获取当前应用的名称

     @return 应用的名称
     */
    @objc public static let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String

    /**
     获取当前应用的Build number

     @return Build number
     */
    @objc public static let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String

    /**
     获取当前应用版本号

     @return 获应用版本号
     */
    @objc public static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

    /**
     当前应用的appStore Url

     @return appStore Url
     */
    @objc public static let appStoreUrl = "https://itunes.apple.com/cn/app/id\(YXConstant.appId)?mt=8"

    /**
     当前应用的Review Url

     @return Review Url
     */
    @objc public static let appStoreReviewUrl = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(YXConstant.appId)&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"
    
    /**
     启动渠道
     e.g. @"友信渠道", @"1313"

     @return 启动渠道
     */
    @objc public static var launchChannel: String?
    
    /**
     注册邀请码
        默认“”

     @return 注册邀请码
     */
    @objc public static var registerICode: String? = ""
    
    /**
     来源于AAStock的哪个页面
     e.g. @"00001", @"00002"

     @return AAStock的来源页
     */
    @objc public static var AAStockPageName: String?
    
    
    /**
     来源于AAStock，是否完成过下单交易
      默认为true。如果从AAStock跳转过来，则会设置为false。

     @return 是否完成过下单交易
     */
    @objc public static var finishTradeAAStock: Bool = true
    
    /// 是否是由AAStock启动
    @objc public class func isLaunchedByAAStock() -> Bool {
        return YXConstant.launchChannel == "1313"
    }
    
    /// App版本号 64位
    @objc public static var appVersionValue: UInt64 {
        get {
            guard let array = YXConstant.appVersion?.components(separatedBy: ".") else { return 0 }
            assert(array.count <= 3, "version字符串格式不对")
            var valueString = ""
            (array as NSArray).enumerateObjects({ obj, idx, stop in
                if let str = obj as? String {
                    if str.count < 3 {
                        valueString += String(format: "%03d", Int(str) ?? 0)
                    } else {
                        valueString += str
                    }
                }

            })
            
            return UInt64(valueString) ?? 0

        }
    }
    
    /**
     获取当前appId

     @return appId
     */
    @objc public static var appId: String {
        if YXConstant.appTypeValue == .CN {
            return "1450893002"
        } else if YXConstant.appTypeValue == .HK {
            return "1329603560"
        } else if YXConstant.appTypeValue == .PRO {
            return "1547908492"
        } else if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG{
            return "1600023952"
        } else if YXConstant.appTypeValue == .EDUCATION {
            return "1590293090"
        } else {
            return "1519167898"
        }
    }
    
    /// 获取当前AppType, String类型
    @objc public static var appType: String {
        if YXConstant.bundleId?.starts(with: "com.yxzq") ?? true {
            return "\(YXAppType.CN.rawValue)"
        } else if YXConstant.bundleId?.contains("berich") ?? true {
            return "\(YXAppType.EDUCATION.rawValue)"
        }else if YXConstant.bundleId?.starts(with: "com.usmart.pro") ?? true {
            return "\(YXAppType.PRO.rawValue)"
        }  else if YXConstant.bundleId?.starts(with: "com.usmart.global") ?? true{
            return "\(YXAppType.OVERSEA_SG.rawValue)"
        } else if YXConstant.bundleId?.starts(with: "com.usmart") ?? true {
            return "\(YXAppType.HK.rawValue)"
        } else {
            return "\(YXAppType.ZTMASTER.rawValue)"
        }
    }
    
    /// 获取当前AppType, YXAppType类型
    @objc public static var appTypeValue: YXAppType {
        if YXConstant.bundleId?.starts(with: "com.yxzq") ?? true {
            return YXAppType.CN
        } else if YXConstant.bundleId?.contains("berich") ?? true {
            return YXAppType.EDUCATION
        } else if YXConstant.bundleId?.starts(with: "com.usmart.pro") ?? true {
            return YXAppType.PRO
        } else if YXConstant.bundleId?.starts(with: "com.usmart.global") ?? true{
            return YXAppType.OVERSEA_SG
        } else if YXConstant.bundleId?.starts(with: "com.usmart") ?? true  {
            return YXAppType.HK
        } else {
            return YXAppType.ZTMASTER
        }
    }
    
    
    @objc public static var logPubKey: String {
        if YXConstant.appTypeValue == .CN || YXConstant.appTypeValue == .ZTMASTER || YXConstant.appTypeValue == .PRO {
            return "e56a7bcb1ddcd59d08c6b20c732277150b609df3eaa14f9c7aa6fbc8515a1d57fadc55f379714b1d54c36029b5115ff44b2797a1f450599ba552c772f9f8f64d"
        } else {
            return "546fbb483422c123246593d99df9aa653c3035c53e78de29dcf26c1271f0abf55d6fc46f06b9032b1c639534cf8986a3c36329b74d0a3ae827c3cbd6ae9be1ea"
        }
    }
    
    @objc public static let logPath = "/uSMART_Logs"
    
    @objc public static let firstLaunchKeyForHotStock = "firstLaunch_key_for_hotstock"
    
    @objc public static let berichRegionKey = "yx_berich_region_key"
}
