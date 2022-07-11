//
//  YXConstant.swift
//  YouXinZhengQuan
//
//  Created by ellison on 2019/3/26.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

#if PRD
let YX_RSAPublicKey = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCp1hORHq6Cx7/bNFObrs3i12UUKAiqVRTCQFJNnse/VurZZaxXQtgstjLSsDe3w0gVZmfEosSunhmTWAP5b2gFAcRYtaemT5JxZuf5E+aJWKvEuFP4ycjVaKcux9PNSia5CHd91HnRMg5MMZBWJ8R59oVpQwOJinvy0+j7VfzJMQIDAQAB"
#else
let YX_RSAPublicKey = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCajLOdwFMIBQ8k3W48/e4bIj2EFc3O/T54oiLOk+KQgAknvmUHJp/1arN8g9tjAaBKPSbznTe4ZYX3VXI7VTRF7Dhi1+vCkas1OwWkdwzZWg3LOqfUORF3tFmvNOiLLzJQ6H5oLsNNZjMOr2QZrm4srzc1aX3O0BRwQhPkP/XhYwIDAQAB"
#endif

enum YXTargetMode : Int {
    case dev // 开发环境
    case sit // 系统内部集成测试环境
    case uat // 用户验收测试环境
    case mock // 测试Mock环境
    case prd // 生产环境
}
// 网络环境配置Key值
#if YXZQ_ENV_MODE_SET
let ENV_MODE_MMKV_KEY = "yx_env_mode"
#endif

// 自动填充短信验证码
#if YXZQ_AUTOFILL_CAPTCHA
let AUTOFILL_CAPTCHA_MMKV_KEY = "yx_autofill_captcha"
#endif


class YXConstant: NSObject {
    static let sharedAppDelegate = UIApplication.shared.delegate as! YXAppDelegate


    /**
     获取当前应用的BundleIdentifier

     @return BundleIdentifier
     */
    static let bundleId = Bundle.main.infoDictionary?["CFBundleIdentifier"]

    /**
     获取当前应用的名称

     @return 应用的名称
     */
    static let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"]

    /**
     获取当前应用的Build number

     @return Build number
     */
    static let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"]

    /**
     获取当前应用版本号

     @return 获应用版本号
     */
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"]

    /**
     获取当前appId

     @return appId
     */
    static let appId = "1329603560"

    /**
     当前应用的appStore Url

     @return appStore Url
     */
    static let appStoreUrl = "https://itunes.apple.com/cn/app/id\(YXConstant.appId)?mt=8"

    /**
     当前应用的Review Url

     @return Review Url
     */
    static let appStoreReviewUrl = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(YXConstant.appId)&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"
    
    static let notiGoogleLogin = "YX_Noti_GoogleLogin"
    
}

