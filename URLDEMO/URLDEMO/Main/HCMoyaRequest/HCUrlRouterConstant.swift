//
//  HCUrlRouterConstant.swift
//  URLDEMO
//
//  Created by odd on 7/3/22.
//

import UIKit

@objcMembers public class HCUrlRouterConstant {
    
    #if PRD || PRD_HK
    static public let SCHEME = "https://"
    #else
    static public let SCHEME = "http://"
    #endif
    
    static public var ipAddressStatus : [String : Bool] = [:]

    
    // 校验证书时用
    class public func appHttpsEvaluatorsKey() -> String {
        return "*.cs.com"
    }
    
    /// 资讯BaseUrl
    /// 测试环境IP：139.199.251.160
    /// 开发环境IP：139.199.45.69
    /// - Returns: 资讯BaseUrl
    class public func zxBaseUrlWithoutScheme() -> String {
        switch HCConstant.targetMode() {
        case .dev:
            return "zx-dev.yxzq.com"

        case .sit:
            return "zx-dev.yxzq.com"

        case .uat, .prd:
            return "zx-dev.yxzq.com"

        }
    }
    
    class public func zxBaseUrl() -> String {
        // 1. 先看腾讯云httpdns是否解析出了IP，如果解析出来了则使用腾讯云的ip(用全局URL或者是内置)
        // 2. 全局配置Url是否能够解析成功，则使用全局配置Url
        // 3. 如果全局配置解析失败，则使用全局配置的IP地址请求
        // 4. 如果全局配置没有配置IP地址，则使用内置域名
        // 5. 如果内置域名解析失败，则使用内置IP
        
        return zxBuildInBaseUrl()
    }
    
    class public func zxBuildInBaseUrl() -> String {
        return SCHEME + zxBaseUrlWithoutScheme()
    }

}
