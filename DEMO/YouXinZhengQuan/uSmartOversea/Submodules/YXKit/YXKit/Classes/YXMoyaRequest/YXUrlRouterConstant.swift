//
//  YXConstant+E.swift
//  YouXinZhengQuan
//
//  Created by mac on 2019/4/2.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

@objcMembers public class YXUrlRouterConstant: NSObject {
    #if PRD || PRD_HK
    static public let SCHEME = "https://"
    #else
    static public let SCHEME = "http://"
    #endif
    
    static public var ipAddressStatus : [String : Bool] = [:]
    
    // 域名规划由公司业务统一开展，具体可参见：http://szwiki.youxin.com/pages/viewpage.action?pageId=1119817
    // 其中
    // hz.yxzq.com，hz是行情资讯（hqzx）的简写
    // jy.yxzq.com，jy是交易开发（jykf）的简写

    
    // 校验证书时用
    class public func appHttpsEvaluatorsKey() -> String {
        switch YXConstant.appTypeValue {
        case .OVERSEA_SG, .OVERSEA:
            return "*.usmartsg.com"
        case .EDUCATION:
            return "*.niubibi.com"
        default:
            return "*.yxzq.com"
        }
    }
    
    /// 设置IP的状态，如果出现过超时，则标记为不可访问
    /// - Parameters:
    ///   - IP: 指定IP
    ///   - status: 状态
    class public func setStatus(IP: String, status: Bool) {
        YXUrlRouterConstant.ipAddressStatus[IP] = status
    }
    
    /// 判断给定的IP是否被可用
    /// - Parameter ipAddress: 给定的IP
    /// - Returns: 是否曾经被标记过访问不同，如果被标记过返回false，未被标记过返回true
    class public func ipAddressHitTest(ipAddress: String) -> Bool {
        if YXUrlRouterConstant.ipAddressStatus.keys.contains(ipAddress) {
            return YXUrlRouterConstant.ipAddressStatus[ipAddress] ?? true
        }
        return true
    }
    
    /// 从给定的IP池中返回可用的IP
    /// - Parameter ipPools: 指定的IP池
    /// - Returns: 可用的IP
    class func decideIPAddress(ipPools: [String]) -> String? {
        var result: String?
        
        for ip in ipPools {
            if ipAddressHitTest(ipAddress: ip) {
                result = ip
                break
            }
        }
        return result
    }
    
    /// 移动端静态资源BaseUrl
    ///
    /// - Returns: 移动端静态资源BaseUrl
    class public func staticResourceBaseUrlForShare() -> String {
        if let url = YXGlobalConfigManager.configURL(type: .imgCenter) { return url }
        switch YXConstant.targetMode() {
        case .dev:
            if YXConstant.appTypeValue == .ZTMASTER {
                return SCHEME + "m-dev.usmart8.com"
            } else if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG {
                return SCHEME + "m-dev.usmartsg.com"
            } else if YXConstant.appTypeValue == .EDUCATION {
                return SCHEME + "m-dev.usmart8.com"
            } else {
                return SCHEME + "m-dev.usmart8.com"
            }
        case .sit:
            if YXConstant.appTypeValue == .ZTMASTER {
                return SCHEME + "m1-sit.usmart8.com"
            } else if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG {
                return SCHEME + "m-sit.usmartsg.com"
            } else if YXConstant.appTypeValue == .EDUCATION {
                return SCHEME + "m1-sit.usmart8.com"
            } else {
                return SCHEME + "m1-sit.usmart8.com"
            }
        case .uat:
            if YXConstant.appTypeValue == .ZTMASTER {
                return SCHEME + "m1-uat.usmart8.com"
            } else if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG {
                return SCHEME + "m-uat.usmartsg.com"
            } else if YXConstant.appTypeValue == .EDUCATION {
                return SCHEME + "m1-uat.usmart8.com"
            } else {
                return SCHEME + "m1-uat.usmart8.com"
            }
        case .mock:
            return SCHEME + "10.210.110.93:9898/mockstatic"
        case .prd, .prd_hk:
            if YXConstant.appTypeValue == .ZTMASTER {
                return SCHEME + "m.usmart8.com"
            } else if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG {
                return SCHEME + "m.usmartsg.com"
            } else if YXConstant.appTypeValue == .EDUCATION {
                return SCHEME + "m.usmart8.com"
            } else {
                return SCHEME + "m.usmart8.com"
            }
//        case .prd_hk:
//            if YXConstant.appTypeValue == .ZTMASTER {
//                return SCHEME + "m.usmart8.com"
//            } else if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG {
//                return SCHEME + "m.usmartsg.com"
//            } else if YXConstant.appTypeValue == .EDUCATION {
//                return SCHEME + "m.usmart8.com"
//            } else {
//                return SCHEME + "m.usmart8.com"
//            }
        }
    }

    /// sg跳转到pc静态资源BaseUrl
    ///
    /// - Returns: 静态资源BaseUrl
    
    class public func pcStaticResourceBaseUrl() -> String {
        var baseUrl = ""
        switch YXConstant.targetMode() {
        case .sit:
            baseUrl = SCHEME + "www-sit.usmartsg.com"
        case .uat:
            baseUrl = SCHEME + "www-uat.usmartsg.com"
        default:
            baseUrl = SCHEME + "www.usmartsg.com"
            break
        }
        return baseUrl
    }
    
    /// 移动端静态资源BaseUrl
    ///
    /// - Returns: 移动端静态资源BaseUrl
    class public func staticResourceBaseUrl() -> String {
        if let url = YXGlobalConfigManager.configURL(type: .mCenter) { return url }
        switch YXConstant.targetMode() {
        case .dev:
            if YXConstant.appTypeValue == .ZTMASTER {
                return SCHEME + "m1-uat.limitupmaster.com"
            } else if YXConstant.appTypeValue == .OVERSEA  || YXConstant.appTypeValue == .OVERSEA_SG{
                return SCHEME + "m-uat.usmartsg.com"
            } else if YXConstant.appTypeValue == .EDUCATION {
                return SCHEME + "global-uat.beerichinvest.com"
            } else {
                return SCHEME + "m-dev.yxzq.com"
            }
        case .sit:
            if YXConstant.appTypeValue == .ZTMASTER {
                return SCHEME + "m1-uat.limitupmaster.com"
            } else if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG {
                return SCHEME + "m-sit.usmartsg.com"
            }else if YXConstant.appTypeValue == .EDUCATION {
                return SCHEME + "global-uat.beerichinvest.com"
            } else {
                return SCHEME + "m1-sit.yxzq.com"
            }
        case .uat:
            if YXConstant.appTypeValue == .ZTMASTER {
                return SCHEME + "m1-uat.limitupmaster.com"
            } else if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG {
                return SCHEME + "m-uat.usmartsg.com"
            }else if YXConstant.appTypeValue == .EDUCATION {
                return SCHEME + "global-uat.beerichinvest.com"
            } else {
                return SCHEME + "m1-uat.yxzq.com"
            }
        case .mock:
            return SCHEME + "10.210.110.93:9898/mockstatic"
        case .prd, .prd_hk:
            if YXConstant.appTypeValue == .ZTMASTER {
                return SCHEME + "m.zhangtingmaster.com"
            } else if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG {
                return SCHEME + "m.usmartsg.com"
            } else if YXConstant.appTypeValue == .EDUCATION {
                return SCHEME + "global.beerichinvest.com"
            } else {
                return SCHEME + "m.yxzq.com"
            }
//        case .prd_hk:
//            if YXConstant.appTypeValue == .ZTMASTER {
//                return SCHEME + "m.zhangtingmaster.com"
//            } else if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG{
//                return SCHEME + "m.usmartsg.com"
//            } else if YXConstant.appTypeValue == .EDUCATION {
//                return SCHEME + "global.beerichinvest.com"
//            } else {
//                return SCHEME + "m-hk.yxzq.com"
//            }
        }
    }
    
    /// 判断给定的Host是否是行情资讯的Host
    /// - Parameter Host: 给定的Host
    /// - Returns: 是否是行情资讯的Host
    class public func isEqualHZBaseURLHost(Host: String) -> Bool {
        if Host.count <= 0 {
            return false
        }
        
        if let url = YXGlobalConfigManager.configURL(type: .hzCenter), url.contains(Host) {
            return true
        }
        
        for ip in YXGlobalConfigManager.bizIPs(type: .hzCenter) {
            if ip.contains(Host) {
                return true
            }
        }
        
        if hzBuildInBaseUrl().contains(Host) {
            return true
        }
        
        for ip in hzIPUrl() {
            if ip.contains(Host) {
                return true
            }
        }
        
        return false
    }
    
    /// 判断给定的Host是否是交易的Host
    /// - Parameter Host: 给定的Host
    /// - Returns: 是否是交易的Host
    class public func isEqualJYBaseURLHost(Host: String) -> Bool {
        if Host.count <= 0 {
            return false
        }
        
        if let url = YXGlobalConfigManager.configURL(type: .jyCenter), url.contains(Host) {
            return true
        }
        
        for ip in YXGlobalConfigManager.bizIPs(type: .jyCenter) {
            if ip.contains(Host) {
                return true
            }
        }
        
        if jyBuildInBaseUrl().contains(Host) {
            return true
        }
        
        for ip in jyIPUrl() {
            if ip.contains(Host) {
                return true
            }
        }
        
        return false
    }
    
    class public func hzBaseUrl() -> String {
        // 1. 首先看是否打开了备份机房开关，如果打开了则使用备份机房域名
        // 2. 先看腾讯云httpdns是否解析出了IP，如果解析出来了则使用腾讯云的ip
        // 3. 全局配置Url是否能够解析成功，则使用全局配置Url
        // 4. 如果全局配置解析失败，则使用全局配置的IP地址请求
        // 5. 如果全局配置没有配置IP地址，则使用内置域名
        // 6. 如果内置域名解析失败，则使用内置IP
        
        if YXConstant.appTypeValue == .EDUCATION {
            return hzBuildInBaseUrl()
        }else if YXConstant.isBackupEnv() {
            return hzBuildInBaseUrl();
        } else if let ip = YXDNSResolver.shareInstance().httpDNSIp(with: .hzGlobalConfig) {
            if ip.lowercased().hasPrefix("http") {
                return ip
            } else {
                return SCHEME + ip
            }
        } else if let url = YXGlobalConfigManager.configURL(type: .hzCenter),
            YXDNSResolver.shareInstance().hostStatus(with: .hzGlobalConfig) {
            return url
        } else if let ip = decideIPAddress(ipPools: YXGlobalConfigManager.bizIPs(type: .hzCenter)) {
            if ip.lowercased().hasPrefix("http") {
                return ip
            } else {
                return SCHEME + ip
            }
        } else if YXDNSResolver.shareInstance().hostStatus(with: .hzBuildIn) {
            return hzBuildInBaseUrl()
        } else if let ip = decideIPAddress(ipPools: hzIPUrl()) {
            return ip
        }
        return hzBuildInBaseUrl()
    }
    
    class public func hzBuildInBaseUrl() -> String {
        return SCHEME + hzBaseUrlWithoutScheme()
    }
    
    /// 行情资讯BaseUrl
    /// 测试环境IP：139.199.251.160
    /// 开发环境IP：139.199.45.69
    /// - Returns: 行情资讯BaseUrl
    class public func hzBaseUrlWithoutScheme() -> String {
        switch YXConstant.targetMode() {
        case .dev:
            if YXConstant.appTypeValue == .ZTMASTER {
                return "zt-uat.limitupmaster.com"
            } else if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG{
                return "hz-uat.usmartsg.com"
            } else if YXConstant.appTypeValue == .EDUCATION {
                return "edu-uat.niubibi.com"
            } else {
                return "hz-dev.yxzq.com"
            }
        case .sit:
            if YXConstant.appTypeValue == .ZTMASTER {
                return "zt-uat.limitupmaster.com"
            } else if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG {
                return "hz-sit.usmartsg.com"
            } else if YXConstant.appTypeValue == .EDUCATION {
                return "edu-uat.niubibi.com"
            } else {
                return "hz1-sit.yxzq.com"
            }
        case .uat:
            if YXConstant.appTypeValue == .ZTMASTER {
                return "zt-uat.limitupmaster.com"
            } else if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG {
                return "hz-uat.usmartsg.com"
            } else if YXConstant.appTypeValue == .EDUCATION {
                return "edu-uat.niubibi.com"
            } else {
                return "hz1-uat.yxzq.com"
            }
        case .mock:
            return "10.210.110.93:9898/mockhqzx"
        case .prd, .prd_hk:
            if YXConstant.appTypeValue == .ZTMASTER {
                return "zt.zhangtingmaster.com"
            } else if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG {
                return "hz.usmartsg.com"
            } else if YXConstant.isBackupEnv() {
                return "hz-hkst.yxzq.com"
            } else if YXConstant.appTypeValue == .EDUCATION {
                return "edu.niubibi.com"
            } else {
                return "hz.yxzq.com"
            }
//        case .prd_hk:
//            if YXConstant.appTypeValue == .ZTMASTER {
//                return "zt-hk.zhangtingmaster.com"
//            } else if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG {
//                return "hz-hk.usmartsg.com"
//            } else if YXConstant.appTypeValue == .EDUCATION {
//                return "edu.niubibi.com"
//            } else {
//                return "hz-hk.yxzq.com"
//            }
        }
    }
    
    class public func wjBaseUrl() -> String {
        // 1. 首先看是否打开了备份机房开关，如果打开了则使用备份机房域名
        // 2. 先看腾讯云httpdns是否解析出了IP，如果解析出来了则使用腾讯云的ip
        // 3. 全局配置Url是否能够解析成功，则使用全局配置Url
        // 4. 如果全局配置解析失败，则使用全局配置的IP地址请求
        // 5. 如果全局配置没有配置IP地址，则使用内置域名
        // 6. 如果内置域名解析失败，则使用内置IP
        if YXConstant.appTypeValue == .EDUCATION {
            return wjBuildInBaseUrl()
        } else if YXConstant.isBackupEnv() {
            return wjBuildInBaseUrl();
        } else if let ip = YXDNSResolver.shareInstance().httpDNSIp(with: .wjGlobalConfig) {
            if ip.lowercased().hasPrefix("http") {
                return ip
            } else {
                return SCHEME + ip
            }
        } else if let url = YXGlobalConfigManager.configURL(type: .wjCenter),
           YXDNSResolver.shareInstance().hostStatus(with: .wjGlobalConfig) {
            return url
        } else if let ip = decideIPAddress(ipPools: YXGlobalConfigManager.bizIPs(type: .wjCenter)) {
            if ip.lowercased().hasPrefix("http") {
                return ip
            } else {
                return SCHEME + ip
            }
        } else if YXDNSResolver.shareInstance().hostStatus(with: .wjBuildIn) {
            return wjBuildInBaseUrl()
        } else if let ip = decideIPAddress(ipPools: wjIPUrl()) {
            return ip
        }

        return wjBuildInBaseUrl()
    }
    
    class public func wjBuildInBaseUrl() -> String {
        return SCHEME + wjBaseUrlWithoutScheme()
    }
    
    /// 文件BaseUrl
    /// 测试环境IP：139.199.251.160
    /// 开发环境IP：139.199.45.69
    /// - Returns: 文件BaseUrl
    class public func wjBaseUrlWithoutScheme() -> String {
        switch YXConstant.targetMode() {
        case .dev:
            if YXConstant.appTypeValue == .ZTMASTER {
                return "zt-uat.limitupmaster.com"
            } else if YXConstant.appTypeValue == .EDUCATION {
                return "edu-uat.niubibi.com"
            } else {
                return "wj-dev.yxzq.com"
            }
        case .sit:
            if YXConstant.appTypeValue == .ZTMASTER {
                return "zt-uat.limitupmaster.com"
            } else if YXConstant.appTypeValue == .EDUCATION {
                return "edu-uat.niubibi.com"
            } else {
                return "wj-sit.yxzq.com"
            }
        case .uat:
            if YXConstant.appTypeValue == .ZTMASTER {
                return "zt-uat.limitupmaster.com"
            } else if YXConstant.appTypeValue == .EDUCATION {
                return "edu-uat.niubibi.com"
            } else {
                return "wj-uat.yxzq.com"
            }
        case .mock:
            return "10.210.110.93:9898/mockhqzx"
        case .prd, .prd_hk:
            if YXConstant.appTypeValue == .ZTMASTER {
                return "zt.zhangtingmaster.com"
            } else if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG {
                return "wj.usmartsg.com"
            } else if YXConstant.appTypeValue == .EDUCATION {
                return "edu.niubibi.com"
            } else {
                return "wj.yxzq.com"
            }
//        case .prd_hk:
//            if YXConstant.appTypeValue == .ZTMASTER {
//                return "zt-hk.zhangtingmaster.com"
//            } else if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG {
//                return "wj-hk.usmartsg.com"
//            } else if YXConstant.appTypeValue == .EDUCATION {
//                return "edu.niubibi.com"
//            } else {
//                return "wj-hk.yxzq.com"
//            }
        }
    }
    
    class public func zxBaseUrl() -> String {
        // 1. 首先看是否打开了备份机房开关，如果打开了则使用备份机房域名
        // 2. 先看腾讯云httpdns是否解析出了IP，如果解析出来了则使用腾讯云的ip
        // 3. 全局配置Url是否能够解析成功，则使用全局配置Url
        // 4. 如果全局配置解析失败，则使用全局配置的IP地址请求
        // 5. 如果全局配置没有配置IP地址，则使用内置域名
        // 6. 如果内置域名解析失败，则使用内置IP
        if YXConstant.appTypeValue == .EDUCATION {
            return zxBuildInBaseUrl()
        } else if YXConstant.isBackupEnv() {
            return zxBuildInBaseUrl();
        } else if let ip = YXDNSResolver.shareInstance().httpDNSIp(with: .zxGlobalConfig) {
            if ip.lowercased().hasPrefix("http") {
                return ip
            } else {
                return SCHEME + ip
            }
        } else if let url = YXGlobalConfigManager.configURL(type: .zxCenter),
           YXDNSResolver.shareInstance().hostStatus(with: .zxGlobalConfig) {
            return url
        } else if let ip = decideIPAddress(ipPools: YXGlobalConfigManager.bizIPs(type: .zxCenter)) {
            if ip.lowercased().hasPrefix("http") {
                return ip
            } else {
                return SCHEME + ip
            }
        } else if YXDNSResolver.shareInstance().hostStatus(with: .zxBuildIn) {
            return zxBuildInBaseUrl()
        } else if let ip = decideIPAddress(ipPools: zxIPUrl()) {
            return ip
        }

        return zxBuildInBaseUrl()
    }
    
    class public func zxBuildInBaseUrl() -> String {
        return SCHEME + zxBaseUrlWithoutScheme()
    }
    
    /// 资讯BaseUrl
    /// 测试环境IP：139.199.251.160
    /// 开发环境IP：139.199.45.69
    /// - Returns: 资讯BaseUrl
    class public func zxBaseUrlWithoutScheme() -> String {
        switch YXConstant.targetMode() {
        case .dev:
            if YXConstant.appTypeValue == .ZTMASTER {
                return "zt-uat.limitupmaster.com"
            } else if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG{
                return "zx-uat.usmartsg.com"
            } else if YXConstant.appTypeValue == .EDUCATION {
                return "edu-uat.niubibi.com"
            } else {
                return "zx-dev.yxzq.com"
            }
        case .sit:
            if YXConstant.appTypeValue == .ZTMASTER {
                return "zt-uat.limitupmaster.com"
            } else if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG {
                return "zx-sit.usmartsg.com"
            } else if YXConstant.appTypeValue == .EDUCATION {
                return "edu-uat.niubibi.com"
            } else {
                return "zx-sit.yxzq.com"
            }
        case .uat:
            if YXConstant.appTypeValue == .ZTMASTER {
                return "zt-uat.limitupmaster.com"
            } else if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG {
                return "zx-uat.usmartsg.com"
            } else if YXConstant.appTypeValue == .EDUCATION {
                return "edu-uat.niubibi.com"
            } else {
                return "zx-uat.yxzq.com"
            }
        case .mock:
            return "10.210.110.93:9898/mockhqzx"
        case .prd, .prd_hk:
            if YXConstant.appTypeValue == .ZTMASTER {
                return "zt.zhangtingmaster.com"
            } else if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG {
                return "zx.usmartsg.com"
            } else if YXConstant.isBackupEnv() {
                return "zx-hkst.yxzq.com"
            } else if YXConstant.appTypeValue == .EDUCATION {
                return "edu.niubibi.com"
            } else {
                return "zx.yxzq.com"
            }
//        case .prd_hk:
//            if YXConstant.appTypeValue == .ZTMASTER {
//                return "zt-hk.zhangtingmaster.com"
//            } else if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG {
//                return "zx-hk.usmartsg.com"
//            } else if YXConstant.appTypeValue == .EDUCATION {
//                return "edu.niubibi.com"
//            } else {
//                return "zx-hk.yxzq.com"
//            }
        }
    }
    
    /// 交易开发BaseUrl
    ///
    /// - Returns: 交易开发BaseUrl
    class public func jyBaseUrl() -> String {
        // 1. 先看腾讯云httpdns是否解析出了IP，如果解析出来了则使用腾讯云的ip(用全局URL或者是内置)
        // 2. 全局配置Url是否能够解析成功，则使用全局配置Url
        // 3. 如果全局配置解析失败，则使用全局配置的IP地址请求
        // 4. 如果全局配置没有配置IP地址，则使用内置域名
        // 5. 如果内置域名解析失败，则使用内置IP
        if YXConstant.appTypeValue == .EDUCATION {
            return jyBuildInBaseUrl()
        } else if let ip = YXDNSResolver.shareInstance().httpDNSIp(with: .jyGlobalConfig) {
            if ip.lowercased().hasPrefix("http") {
                return ip
            } else {
                return SCHEME + ip
            }
        } else if let url = YXGlobalConfigManager.configURL(type: .jyCenter),
           YXDNSResolver.shareInstance().hostStatus(with: .jyGlobalConfig) {
            return url
        } else if let ip = decideIPAddress(ipPools: YXGlobalConfigManager.bizIPs(type: .jyCenter)) {
            if ip.lowercased().hasPrefix("http") {
                return ip
            } else {
                return SCHEME + ip
            }
        } else if YXDNSResolver.shareInstance().hostStatus(with: .jyBuildIn) {
            return jyBuildInBaseUrl()
        } else if let ip = decideIPAddress(ipPools: jyIPUrl()) {
            return ip
        }
        
        return jyBuildInBaseUrl()
    }
    
    class public func jyBuildInBaseUrl() -> String {
        return SCHEME + jyBaseUrlWithoutScheme()
    }
    
    /// 交易开发BaseUrl
    /// - Returns: 交易开发BaseUrl【不带SCHEME】
    class public func jyBaseUrlWithoutScheme() -> String {
        switch YXConstant.targetMode() {
        case .dev:
            if YXConstant.appTypeValue == .ZTMASTER {
                return "zt-uat.limitupmaster.com"
            } else if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG{
                return "jy-uat.usmartsg.com"
            } else if YXConstant.appTypeValue == .EDUCATION {
                return "edu-uat.niubibi.com"
            } else {
                return "jy-dev.yxzq.com"
            }
        case .sit:
            if YXConstant.appTypeValue == .ZTMASTER {
                return "zt-uat.limitupmaster.com"
            } else if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG {
                return "jy-sit.usmartsg.com"
            } else if YXConstant.appTypeValue == .EDUCATION {
                return "edu-uat.niubibi.com"
            } else {
                return "jy1-sit.yxzq.com"
            }
        case .uat:
            if YXConstant.appTypeValue == .ZTMASTER {
                return "zt-uat.limitupmaster.com"
            } else if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG {
                return "jy-uat.usmartsg.com"
            } else if YXConstant.appTypeValue == .EDUCATION {
                return "edu-uat.niubibi.com"
            } else {
                return "jy1-uat.yxzq.com"
            }
        case .mock:
            return "10.210.110.93:9898/mocktrade"
        case .prd, .prd_hk:
            if YXConstant.appTypeValue == .ZTMASTER {
                return "zt.zhangtingmaster.com"
            } else if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG {
                return "jy.usmartsg.com"
            } else if YXConstant.appTypeValue == .EDUCATION {
                return "edu.niubibi.com"
            } else {
                return "jy.yxzq.com"
            }
//        case .prd_hk:
//            if YXConstant.appTypeValue == .ZTMASTER {
//                return "zt-hk.zhangtingmaster.com"
//            } else if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG {
//                return "jy-hk.usmartsg.com"
//            } else if YXConstant.appTypeValue == .EDUCATION {
//                return "edu.niubibi.com"
//            } else {
//                return "jy-hk.yxzq.com"
//            }
        }
    }
    
    /*使用的地方：
     意见反馈*/
    class public func suggestionBucket() -> String {
        if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG {
            switch YXConstant.targetMode() {
            case .dev, .sit, .uat, .mock:
                return "jy-user-server-sg-uat-1257884527"
            case .prd,
                 .prd_hk:
                return "jy-user-server-sg-prd-singapore-1257884527"
            }
        } else if YXConstant.appTypeValue == .EDUCATION {
            switch YXConstant.targetMode() {
            case .dev, .sit, .uat, .mock:
                return "jy-user-server-rich-uat-1305919280"
            case .prd,
                 .prd_hk:
                return "jy-user-server-rich-prd-hongkong-1305919280"
            }
        } else {
            switch YXConstant.targetMode() {
            case .dev:
                return "jy-user-server-dev-1257884527"
            case .sit:
                return "jy-user-server-sit-1257884527"
            case .uat:
                return "jy-user-server-uat-1257884527"
            case .mock:
                return "jy-user-server-sit-1257884527"
            case .prd,
                 .prd_hk:
                return "jy-user-server-prd-1257884527"
            }
        }
    }
    
    /// 评论使用的桶
    /// - Returns: 桶
    class public func frontEndTopicBucket() -> String {
        if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG {
            switch YXConstant.targetMode() {
            case .dev, .sit, .uat, .mock:
                return "frontend-topic-sg-uat-1257884527"
            case .prd,
                 .prd_hk:
                return "frontend-topic-sg-prd-singapore-1257884527"
            }
        }else {
            switch YXConstant.targetMode() {
            case .dev, .sit, .uat, .mock:
                return "frontend-topic-dev-hk-1257884527"
            case .prd,
                 .prd_hk:
                return "frontend-topic-prod-hk-1257884527"
            }
        }
    }
    
    /*使用的地方：
     上传图片*/
    class public func headerImageBucket() -> String {
        if YXConstant.appTypeValue == .OVERSEA  || YXConstant.appTypeValue == .OVERSEA_SG{
            switch YXConstant.targetMode() {
            case .dev, .sit, .uat, .mock:
                return "jy-common-sg-uat-1257884527"
            case .prd,
                 .prd_hk:
                return "jy-common-sg-prd-singapore-1257884527"
            }
        } else if YXConstant.appTypeValue == .EDUCATION {
            switch YXConstant.targetMode() {
            case .dev, .sit, .uat, .mock:
                return "jy-common-rich-uat-1305919280"
            case .prd,
                 .prd_hk:
                return "jy-common-rich-prd-hongkong-1305919280"
            }
        }else {
            switch YXConstant.targetMode() {
            case .dev:
                return "jy-common-dev-1257884527"
            case .sit:
                return "jy-common-sit-1257884527"
            case .uat:
                return "jy-common-uat-1257884527"
            case .mock:
                return "jy-common-sit-1257884527"
            case .prd,
                 .prd_hk:
                return "jy-common-prd-1257884527"
            }
        }
    }
    
    /// 图片资源BaseUrl
    ///
    /// - Returns: 图片资源BaseUrl
    class public func imgResourceBaseUrl() -> String {
        if let url = YXGlobalConfigManager.configURL(type: .imgCenter) { return url }
        switch YXConstant.targetMode() {
        case .dev:
            return SCHEME + "img-dev.yxzq.com"
        case .sit:
            return SCHEME + "img-sit.yxzq.com"
        case .uat:
            return SCHEME + "img1-uat.yxzq.com"
        case .mock:
            return SCHEME + "10.210.110.93:9898/mockimage"
        case .prd, .prd_hk:
            return SCHEME + "img.yxzq.com"
//        case .prd_hk:
//            return SCHEME + "img-hk.yxzq.com"
        }
    }
    
    
    /// 长连接推送的IP地址
    ///
    /// - Returns: 长连接推送的IP地址
    class public func socketBaseUrl() -> [URL] {
        switch YXConstant.targetMode() {
        case .dev:
            return [URL(string: "http://10.210.110.95:26000")!,
                    URL(string: "http://10.210.110.95:21000")!]
        case .sit, .mock:
            return [URL(string: "http://10.210.110.74:26000")!,
                    URL(string: "http://10.210.110.74:21000")!]
        case .uat:
            return [URL(string: "http://10.55.4.128:20000")!,
                    URL(string: "http://10.55.4.128:21000")!,
                    URL(string: "http://10.55.4.70:20000")!,
                    URL(string: "http://10.55.4.70:21000")!]
        case .prd,
             .prd_hk:
            return [URL(string: "http://139.199.45.170:21000")!,
                    URL(string: "http://139.199.45.170:26000")!,
                    URL(string: "http://139.199.251.82:21000")!,
                    URL(string: "http://139.199.251.82:26000")!,
                    URL(string: "http://150.109.70.120:26000")!,
                    URL(string: "http://150.109.77.142:26000")!]
        }
    }
    
    /// 内置的行情IP地址，用于在域名请求或DNS解析失败时的备用
    /// - Returns: 所有备用的IP地址【带SCHEME】
    class public func hzIPUrl() -> [String] {
        let IPUrls = hzIPUrlWithoutScheme().map { (url) -> String in
            return SCHEME + url
        }
        
        return IPUrls
    }
    
    /// 内置的行情IP地址，用于在域名请求或DNS解析失败时的备用
    /// - Returns: 所有备用的IP地址【不带SCHEME】
    class public func hzIPUrlWithoutScheme() -> [String] {
        switch YXConstant.targetMode() {
        case .dev:
            return ["10.55.4.13"]
        case .sit:
            return ["10.55.4.33"]
        case .uat:
            return ["10.55.4.128", "10.55.4.70"]
        case .mock:
            return ["10.55.4.33"]
        case .prd,
             .prd_hk:
            if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG{
                return ["47.242.182.40", "3.33.131.232"]
            }else if YXConstant.appTypeValue == .EDUCATION {
                return ["101.32.16.9"]
            } else {
                return ["139.199.43.245",
                        "120.77.150.199",
                        "47.240.105.222",
                        "120.77.252.10",
                        "124.156.123.52"]
            }
        }
    }
    
    /// 内置的文件IP地址，用于在域名请求或DNS解析失败时的备用
    /// - Returns: 所有备用的IP地址【带SCHEME】
    class public func wjIPUrl() -> [String] {
        let IPUrls = wjIPUrlWithoutScheme().map { (url) -> String in
            return SCHEME + url
        }
        
        return IPUrls
    }
    
    /// 内置的文件IP地址，用于在域名请求或DNS解析失败时的备用
    /// - Returns: 所有备用的IP地址【不带SCHEME】
    class public func wjIPUrlWithoutScheme() -> [String] {
        switch YXConstant.targetMode() {
        case .dev:
            return ["10.60.6.76"]
        case .sit:
            return ["10.60.6.76"]
        case .uat:
            return ["10.60.6.41"]
        case .mock:
            return ["10.60.6.76"]
        case .prd,
             .prd_hk:
            if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG{
                return ["47.242.182.40"]
            } else {
                return ["139.199.139.235",
                        "124.156.123.104"]
            }
        }
    }
    
    /// 内置的资讯IP地址，用于在域名请求或DNS解析失败时的备用
    /// - Returns: 所有备用的IP地址【带SCHEME】
    class public func zxIPUrl() -> [String] {
        let IPUrls = zxIPUrlWithoutScheme().map { (url) -> String in
            return SCHEME + url
        }
        
        return IPUrls
    }
    
    /// 内置的资讯IP地址，用于在域名请求或DNS解析失败时的备用
    /// - Returns: 所有备用的IP地址【不带SCHEME】
    class public func zxIPUrlWithoutScheme() -> [String] {
        switch YXConstant.targetMode() {
        case .dev:
            return ["10.60.6.78"]
        case .sit:
            return ["10.60.6.78"]
        case .uat:
            return ["10.55.4.128", "10.55.4.70"]
        case .mock:
            return ["10.60.6.78"]
        case .prd,
             .prd_hk:
            if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG {
                return ["47.242.182.40"]
            } else {
                return ["139.199.139.236",
                        "124.156.123.105"]
            }
        }
    }
    
    /// 内置的交易IP地址，用于在域名请求或DNS解析失败时的备用
    /// - Returns: 所有备用的IP地址【带SCHEME】
    class public func jyIPUrl() -> [String] {
        let IPUrls = jyIPUrlWithoutScheme().map { (url) -> String in
            return SCHEME + url
        }
        
        return IPUrls
    }
    
    /// 内置的交易IP地址，用于在域名请求或DNS解析失败时的备用
    /// - Returns: 所有备用的IP地址【不带SCHEME】
    class public func jyIPUrlWithoutScheme() -> [String] {
        switch YXConstant.targetMode() {
        case .dev:
            return ["10.55.4.13"]
        case .sit:
            return ["10.55.4.33"]
        case .uat:
            return ["10.55.4.128", "10.55.4.70"]
        case .mock:
            return ["10.55.4.33"]
        case .prd,
             .prd_hk:
            if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG{
                return ["47.242.140.27", "3.33.140.225"]
            } else {
                return ["139.199.139.211",
                        "124.156.123.52"]
            }
        }
    }
    
    class public func staticResourceUrlForBeerichShare() -> String {
        if let url = YXGlobalConfigManager.beerichShareDomain() { return url }
        switch YXConstant.targetMode() {
        case .dev,.sit,.mock,.uat:
            return SCHEME + "global-uat.beerichinvest.com"
        case .prd, .prd_hk:
            return SCHEME + "global.beerichinvest.com"
        }
    }
    
}
