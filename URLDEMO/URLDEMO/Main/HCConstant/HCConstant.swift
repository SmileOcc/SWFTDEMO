//
//  HCConstant.swift
//  URLDEMO
//
//  Created by odd on 7/3/22.
//

import UIKit

@objc public enum HCTargetMode : Int {
    case dev    // 开发环境
    case sit    // 系统内部集成测试环境
    case uat    // 用户验收测试环境
    case prd    // 生产环境
}

public class HCConstant: NSObject {
    @objc public static let sharedAppDelegate = UIApplication.shared.delegate
    
    /// App类型
    @objc public enum HCAppType: Int {
        case CN         = 0x01        // 大陆版
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
    @objc public static let appStoreUrl = "https://itunes.apple.com/cn/app/id\(HCConstant.appId)?mt=8"

    /**
     当前应用的Review Url

     @return Review Url
     */
    @objc public static let appStoreReviewUrl = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(HCConstant.appId)&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"
    
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
        return HCConstant.launchChannel == "1313"
    }
    
    /// App版本号 64位
    @objc public static var appVersionValue: UInt64 {
        get {
            guard let array = HCConstant.appVersion?.components(separatedBy: ".") else { return 0 }
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
        if HCConstant.appTypeValue == .CN {
            return "1111111"
        }else {
            return "1111111"
        }
    }
    
    /// 获取当前AppType, String类型
    @objc public static var appType: String {
        if HCConstant.bundleId?.starts(with: "com.yxzq") ?? true {
            return "\(HCAppType.CN.rawValue)"
        } else {
            return "\(HCAppType.CN.rawValue)"
        }
    }
    
    /// 获取当前AppType, YXAppType类型
    @objc public static var appTypeValue: HCAppType {
        if HCConstant.bundleId?.starts(with: "com.yxzq") ?? true {
            return HCAppType.CN
        } else {
            return HCAppType.CN
        }
    }
    
    
    @objc public static var logPubKey: String {
        if HCConstant.appTypeValue == .CN  {
            return "e56a7bcb1ddcd59d08c6b20c732277150b609df3eaa14f9c7aa6fbc8515a1d57fadc55f379714b1d54c36029b5115ff44b2797a1f450599ba552c772f9f8f64d"
        } else {
            return "546fbb483422c123246593d99df9aa653c3035c53e78de29dcf26c1271f0abf55d6fc46f06b9032b1c639534cf8986a3c36329b74d0a3ae827c3cbd6ae9be1ea"
        }
    }
    
    @objc public static let logPath = "/uHCDemo_Logs"
    
    @objc public static let firstLaunchKeyForHotStock = "firstLaunch_key_for_hotstock"
    
    @objc public static let berichRegionKey = "yx_berich_region_key"
}
