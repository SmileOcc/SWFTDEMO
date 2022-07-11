//
//  YXGlobalConfigManager.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2019/5/18.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import MMKV
import NSObject_Rx

@objc public enum YXGlobalConfigURLType : Int {
    case hzCenter, jyCenter, mCenter, imgCenter, zxCenter, wjCenter
}

@objc public enum YXGlobalConfigParameterType : Int {
    case optStocksMaxNum            //自选股展示个数
    case rankFreq                   //排行榜轮询时间（多久轮询一次）
    case quotesResendFreq           //行情订阅请求重发时间（多久重发一次请求)
    case holdingFreq                //持仓轮询频率 (多久轮询一次
    case stockKingFreq              //股王轮询频率 (多久轮询一次
    case marketRankFreq             //市场排行榜【市场页面和排行榜列表页面】(多久更新一次)
    case delayQuoteRealtimeFreq     //延时行情轮询频率
    case delayTimesharingFreq       //延时行情分时图轮询频率
    case delayKlineFreq             //延时K线轮询频率
    case timesharingFreq            //分时轮询频率
    case klineFreq                  //k线轮询频率
    case marketStatusFreq           //个股市场状态轮询频率
    case trendFreq                  //蚯蚓图轮询频率
    case currencyFreq               //换汇轮询频率
    case selfStockFreq              //智能盯盘自选股轮询频率
    case newStockNewsVisible        //新股新闻是否可见
    case stockRealquoteRefreshFreq  //个股详情页实时行情数据刷新频率, 时间是毫秒, 用时除以1000
    case lowAdrTradeEnable          //低级adr是否支持交易
    case stockValueVisible          //价值掘金模块是否展示 0: 不展示 （默认） 1：展示
    case iOSDNSEnable               // 0：不使用URLProtocol进行DNS拦截并解析, 1：使用URLProtocol进行DNS拦截并解析
    case httpDNSEnable              // 是否使用HttpDns， 1-- 使用， 2--不适用， 默认值 0
    case discussTabVisible          //是否展示个股讨论Tab 0-不展示， 1-展示 默认值 0
    case mainPageTabDefault         //默认主tab 0，1，2，3，4, 5
    case accountFreq                //账户页轮询频率
    case supportGreyTradeFutu       //是否支持富途暗盘交易
    /*
     case serviceTelphTime           //客服电话服务时间
     case serviceOnlineTime          //客服在线服务时间
     case ipoEndTime                 //IPO认购截止日
     case mrTipMessage               //MR测试app提示message
     */
}


@objc public class YXGlobalConfigManager: NSObject {
    
    @objc public static let shareInstance = YXGlobalConfigManager()
    
    public var customerModel: YXCustomerStatusSelect?
    
    @objc public var countryAreaModel: YXCountryAreaModel?
    
    @objc public let kYXFilterModuleNotification = "YXFilterModuleNotification"
    @objc public let kYXCountryAreaNotification = "YXCountryAreaNotification"
    
    private var globalConfigModel: YXGlobalURLConfigModel?
    private var lastConfigKey: String = ""
    
    @objc public func requestGlobalConfig() {
        
        var version: Int = 0
        if let data = MMKV.default().object(of: NSData.self, forKey: YXGlobalConfigManager.getGlobalUrlConfigKey()) as? Data,
            let model = try? JSONDecoder().decode(YXGlobalURLConfigModel.self, from: data),
            let localVersion = model.version {
            version = localVersion
        }
        
        YXGlobalConfigProvider.rx.request(.parameters(version: version))
            .map(YXResult<YXGlobalURLConfigModel>.self)
            .subscribe(onSuccess: { (response) in
                
                if response.code == YXResponseCode.success.rawValue, let model = response.data {
                    if let data = try? JSONEncoder().encode(model) {
                        MMKV.default().set(data, forKey: YXGlobalConfigManager.getGlobalUrlConfigKey())
                        YXGlobalConfigManager.shareInstance.globalConfigModel = nil
                        DispatchQueue.global().async {
                            if let hzGlobalConfigURLString = YXGlobalConfigManager.bizUrl(type: .hzCenter),
                               let hzGlobalUrl = URL(string: hzGlobalConfigURLString),
                               let host = hzGlobalUrl.host {
                                YXDNSResolver.shareInstance().resolveHost(host, resolverType: .hzGlobalConfig)
                            }
                            
                            if let jyGlobalConfigURLString = YXGlobalConfigManager.bizUrl(type: .jyCenter),
                               let jyGlobalUrl = URL(string: jyGlobalConfigURLString),
                               let host = jyGlobalUrl.host {
                                YXDNSResolver.shareInstance().resolveHost(host, resolverType: .jyGlobalConfig)
                            }
                        }
                        //通知
                        NotificationCenter.default.post(name:  NSNotification.Name(rawValue: YXGlobalConfigManager.getGlobalUrlConfigKey()), object: nil, userInfo: ["isDynamicShow": model.parameter?.isDynamicShow ?? "0"])
                    }
                }
            }, onError: { (error) in
                log(.error, tag: kNetwork, content: "\(error)")
            }).disposed(by: rx.disposeBag)
        
        if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG{
            //获取IP地区过滤的模块
            self.requestFilterModule()
        }
        
        if YXConstant.appTypeValue != .OVERSEA && YXConstant.appTypeValue != .EDUCATION  && YXConstant.appTypeValue != .OVERSEA_SG{
            // 客服状态配置
            self.requestCustomer()
        }
        
        //十六国地区
        self.requestCountryArea()
    }
    
    //MARK: - 客服状态配置
    public func requestCustomer() {
        if let data = MMKV.default().object(of: NSData.self, forKey: YXGlobalConfigManager.getCustomerModelKey()) as? Data,
            let model = try? JSONDecoder().decode(YXCustomerStatusSelect.self, from: data) {
            self.customerModel = model
        }
        
        YXGlobalConfigProvider.rx.request(.service)
            .map(YXResult<YXCustomerStatusSelect>.self)//TODO: model类型确认
            .subscribe(onSuccess: { [weak self] (response) in
                guard let strongSelf = self else { return }
                if response.code == YXResponseCode.success.rawValue, let model = response.data  {
                    strongSelf.customerModel = model
                    if let data = try? JSONEncoder().encode(model) {
                        MMKV.default().set(data, forKey: YXGlobalConfigManager.getCustomerModelKey())
                    }
                }
                } , onError: { (error) in
                    log(.error, tag: kNetwork, content: "\(error)")
            }).disposed(by: rx.disposeBag)
    }
    
    public func requestCountryArea() {
        var version: Int = 0
        if let data = MMKV.default().object(of: NSData.self, forKey: YXGlobalConfigManager.getCountryAreaModelKey()) as? Data,
            let model = try? JSONDecoder().decode(YXCountryAreaModel.self, from: data),
            let localVersion = model.version {
            version = Int(localVersion.value)
            self.countryAreaModel = model
        } else {
            if let path = Bundle.main.path(forResource: "countries", ofType: "plist") {
                if let countries = NSDictionary.init(contentsOfFile: path) {
                    if let data = try? JSONSerialization.data(withJSONObject: countries , options: .prettyPrinted) {
                        let model = try? JSONDecoder().decode(YXCountryAreaModel.self, from: data)
                        self.countryAreaModel = model
                    }
                }
            }
        }
        
        var needRequest = false
        if let date = MMKV.default().object(of: NSDate.self, forKey: YXGlobalConfigManager.getCountryAreaRequestKey()) as? NSDate {
            let gap = abs(Date().timeIntervalSince(date as Date))
            if gap >= TimeInterval(24 * 60 * 60) {
                // 上次请求时间跟现在时间相比，超过了1天则允许再次请求
                needRequest = true
            }
        } else {
            needRequest = true
        }
        
        if !needRequest, YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: self.kYXCountryAreaNotification), object: nil)
        }
        
        /* http://admin-dev.yxzq.com/config-manager/doc/doc.html -->
        国家区号 --> 获取国家区号
        /config-manager/api/get-country-area/v1 */
        if needRequest {
            YXGlobalConfigProvider.rx.request(.countryArea(version))
                .map(YXResult<YXCountryAreaModel>.self)
                .subscribe(onSuccess: { [weak self] (response) in
                    guard let strongSelf = self else { return }
                    if response.code == YXResponseCode.success.rawValue, let model = response.data {
                        let commonCountry = model.commonCountry
                        let othersCountry = model.othersCountry
                        if commonCountry?.count ?? 0 > 0 || othersCountry?.count ?? 0 > 0 {
                            strongSelf.countryAreaModel = model
                            if let data = try? JSONEncoder().encode(model) {
                                MMKV.default().set(data, forKey: YXGlobalConfigManager.getCountryAreaModelKey())
                            }
                        }
                    }
                    if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: strongSelf.kYXCountryAreaNotification), object: nil)
                    }
                    MMKV.default().set(Date(), forKey: YXGlobalConfigManager.getCountryAreaRequestKey())
                } , onError: { (error) in
                    log(.error, tag: kNetwork, content: "\(error)")
                }).disposed(by: rx.disposeBag)
        }
    }
    
    //获取IP地区过滤的模块
    public func requestFilterModule() {
        YXGlobalConfigProvider.rx.request(.getFilterModule)
            .map(YXResult<YXFilterModuleModel>.self)
            .subscribe(onSuccess: { [weak self] (response) in
                guard let strongSelf = self else { return }
                if response.code == YXResponseCode.success.rawValue, let model = response.data {
                    if let data = try? JSONEncoder().encode(model) {
                        MMKV.default().set(data, forKey: YXGlobalConfigManager.getFilterModuleKey())
                    }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: strongSelf.kYXFilterModuleNotification), object: nil)
                }
                
            } , onError: { (error) in
                log(.error, tag: kNetwork, content: "\(error)")
            }).disposed(by: rx.disposeBag)
    }
}

extension YXGlobalConfigManager {
    
    @objc public class func configURL(type: YXGlobalConfigURLType) -> String? {

        YXGlobalConfigManager.shareInstance.decodeGlobalConfigModel()
        if let model = YXGlobalConfigManager.shareInstance.globalConfigModel {
            switch type {
            case .hzCenter:
                if let url = model.serverUrls?.quoteInfoCenter?.url, url.hasPrefix(YXUrlRouterConstant.SCHEME) {
                    if YXConstant.isBackupEnv() {
                        return nil
                    } else {
                        return url
                    }
                }
            case .jyCenter:
                if let url = model.serverUrls?.jyCenter?.url, url.hasPrefix(YXUrlRouterConstant.SCHEME) { return url }
            case .mCenter:
                if let url = model.serverUrls?.staticPage?.url {
                    return url
                }
            case .imgCenter:
                if let url = model.serverUrls?.img?.url {
                    return url
                }
            case .zxCenter:
                if let url = model.serverUrls?.zxCenter?.url, url.hasPrefix(YXUrlRouterConstant.SCHEME) { return url }
            case .wjCenter:
                if let url = model.serverUrls?.wjCenter?.url, url.hasPrefix(YXUrlRouterConstant.SCHEME) { return url }
            }
        }
        
        return nil
    }
    
    private func decodeGlobalConfigModel() {

        let canConfig = YXConstant.isGlobalConfig()
        if canConfig || YXConstant.targetMode() == .prd || YXConstant.targetMode() == .prd_hk {
            let configKey = YXGlobalConfigManager.getGlobalUrlConfigKey()
            if YXGlobalConfigManager.shareInstance.globalConfigModel == nil ||  YXGlobalConfigManager.shareInstance.lastConfigKey != configKey {
                if let data = MMKV.default().object(of: NSData.self, forKey: configKey) as? Data,
                    let model = try? JSONDecoder().decode(YXGlobalURLConfigModel.self, from: data) {
                    YXGlobalConfigManager.shareInstance.lastConfigKey = configKey
                    YXGlobalConfigManager.shareInstance.globalConfigModel = model
                }
            }
        } else {
            YXGlobalConfigManager.shareInstance.globalConfigModel == nil
        }
    }

    /// 跟投晒单是否显示 1开，0关
    @objc public class func isDynamicShow() -> Bool {
        YXGlobalConfigManager.shareInstance.decodeGlobalConfigModel()
        if let model = YXGlobalConfigManager.shareInstance.globalConfigModel{
            if model.parameter?.isDynamicShow == "0" {
                return false
            } else if model.parameter?.isDynamicShow == "1" {
                return true
            }
        }
        return false
    }
    
    /// 离线包开关 1开，0关
    @objc public class func isH5PreLoadOn() -> Bool {
        YXGlobalConfigManager.shareInstance.decodeGlobalConfigModel()
        if let model = YXGlobalConfigManager.shareInstance.globalConfigModel{
            return model.parameter?.h5CacheOn == 1
        }
        return true
    }
    
    /// 证书双向校验开关 1开，0关
    @objc public class func isCertificateCheckOn() -> Bool {
        YXGlobalConfigManager.shareInstance.decodeGlobalConfigModel()
        if let value = YXGlobalConfigManager.shareInstance.globalConfigModel?.parameter?.certificateCheck {
            return value == 1
        }
        return true
    }

    @objc public class func showESOP() -> Bool {
        YXGlobalConfigManager.shareInstance.decodeGlobalConfigModel()
        if let value = YXGlobalConfigManager.shareInstance.globalConfigModel?.parameter?.configEsopValue {
            return value == 1
        }
        return true
    }
    
    @objc public class func showOpenSGAccount() -> Bool {
        YXGlobalConfigManager.shareInstance.decodeGlobalConfigModel()
        if let value = YXGlobalConfigManager.shareInstance.globalConfigModel?.parameter?.configSgOpenValue {
            return value == 1
        }
        return false
    }

    @objc public class func configFrequency(_ type: YXGlobalConfigParameterType) -> Int {
        
        var frequency : Int? = nil
        YXGlobalConfigManager.shareInstance.decodeGlobalConfigModel()
        if let model = YXGlobalConfigManager.shareInstance.globalConfigModel {
            switch type {
            case .optStocksMaxNum:
                if let optStocksMaxNum = model.parameter?.optStocksMaxNum, optStocksMaxNum > 0 {
                    frequency = optStocksMaxNum
                }
            case .rankFreq:
                if let rankFreq = model.parameter?.rankFreq, rankFreq > 0 {
                    frequency = rankFreq
                }
            case .quotesResendFreq:
                if let quotesResendFreq = model.parameter?.quotesResendFreq, quotesResendFreq > 0 {
                    frequency = quotesResendFreq
                }
            case .holdingFreq:
                if let holdingFreq = model.parameter?.holdingFreq, holdingFreq > 0 {
                    frequency = holdingFreq
                }
            case .marketRankFreq:
                if let marketRankFreq = model.parameter?.marketRankFreq, marketRankFreq > 0 {
                    frequency = marketRankFreq
                }
            case .stockKingFreq:
                if let marketStockKingFreq = model.parameter?.marketStockKingFreq, marketStockKingFreq > 0 {
                    frequency = marketStockKingFreq
                }
            case .delayQuoteRealtimeFreq:
                if let delayQuoteRealtimeFreq = model.parameter?.delayQuoteRealtimeFreq, delayQuoteRealtimeFreq > 0 {
                    frequency = delayQuoteRealtimeFreq
                }
            case .delayTimesharingFreq:
                if let delayTimesharingFreq = model.parameter?.delayTimesharingFreq, delayTimesharingFreq > 0 {
                    frequency = delayTimesharingFreq
                }
            case .delayKlineFreq:
                if let delayKlineFreq = model.parameter?.delayKlineFreq, delayKlineFreq > 0 {
                    frequency = delayKlineFreq
                }
            case .timesharingFreq:
                if let timesharingFreq = model.parameter?.timesharingFreq, timesharingFreq > 0 {
                    frequency = timesharingFreq
                }
            case .klineFreq:
                if let klineFreq = model.parameter?.klineFreq, klineFreq > 0 {
                    frequency = klineFreq
                }
            case .marketStatusFreq:
                if let marketStatusFreq = model.parameter?.marketStatusFreq, marketStatusFreq > 0 {
                    frequency = marketStatusFreq
                }
            case .trendFreq:
                if let trendFreq = model.parameter?.trendFreq, trendFreq > 0 {
                    frequency = trendFreq
                }
            case .currencyFreq:
                if let currencyFreq = model.parameter?.currencyFreq, currencyFreq > 0 {
                    frequency = currencyFreq
                    }
            case .selfStockFreq:
                if let selfstockFreq = model.parameter?.selfstockFreq, selfstockFreq > 0 {
                    frequency = selfstockFreq
                }
            case .newStockNewsVisible:
                if let ipoNewsVisible = model.parameter?.ipoNewsVisible {
                    frequency = ipoNewsVisible
                }
            case .stockRealquoteRefreshFreq:
                if let stockRealquoteRefreshFreq = model.parameter?.stockRealquoteRefreshFreq, stockRealquoteRefreshFreq > 0 {
                    frequency = stockRealquoteRefreshFreq
                }
            case .lowAdrTradeEnable:
                if let lowAdrTradeEnable = model.parameter?.lowAdrTradeEnable {
                    frequency = lowAdrTradeEnable
                }
            case .stockValueVisible:
                if let stockValueVisible = model.parameter?.stockValueVisible {
                    frequency = stockValueVisible
                }
            case .iOSDNSEnable:
                if let iOSDNSEnable = model.parameter?.iOSDNSEnable {
                    frequency = iOSDNSEnable
                }
            case .httpDNSEnable:
                if let httpDNSEnable = model.parameter?.httpDNSEnable {
                    frequency = httpDNSEnable
                }
            case .discussTabVisible:
                if let discussTabVisible = model.parameter?.discussTabVisible {
                    frequency = discussTabVisible
                }
            case .mainPageTabDefault:
                if let tabName = model.parameter?.mainPageTabDefault {
                    
                    switch tabName {
                    case "market":
                        frequency = 1
                    case "whatlist":
                        frequency = 0
                    case "fund":
                        frequency = 2
                    case "ustrategy":
                        frequency = 3
                    case "trade":
                        frequency = 4
                        if YXConstant.appTypeValue == .HK {
                            frequency = 5
                        }
                    case "ufinance":
                        frequency = 5
                        if YXConstant.appTypeValue == .HK {
                            frequency = 4
                        }
                    default:
                        frequency = 0
                        break
                    }
                    
                }
            case .accountFreq:
                if let accountFreq = model.parameter?.accountFreq, accountFreq > 0 {
                    frequency = accountFreq
                }
            case .supportGreyTradeFutu:
                if let greyTradeFutu = model.parameter?.greyTradeFutu {
                    frequency = greyTradeFutu
                }
            }
        }
        
        if frequency == nil {
            switch type {
            case .optStocksMaxNum:
                frequency = 200
            case .rankFreq:
                frequency = 30
            case .quotesResendFreq:
                frequency = 120
            case .holdingFreq:
                frequency = 3
            case .marketRankFreq:
                frequency = 30
            case .stockKingFreq:
                frequency = 10
            case .delayQuoteRealtimeFreq:
                frequency = 3
            case .delayTimesharingFreq:
                frequency = 5
            case .delayKlineFreq:
                frequency = 60
            case .timesharingFreq:
                frequency = 5
            case .klineFreq:
                frequency = 60
            case .marketStatusFreq:
                frequency = 3
            case .trendFreq:
                frequency = 60
            case .currencyFreq:
                frequency = 3
            case .selfStockFreq:
                frequency = 30
            case .newStockNewsVisible:
                frequency = 1
            case .stockRealquoteRefreshFreq:
                frequency = 300
            case .lowAdrTradeEnable:
                frequency = 0
            case .stockValueVisible:
                frequency = 0
            case .iOSDNSEnable:
                frequency = 0
            case .httpDNSEnable:
                frequency = 1
            case .discussTabVisible:
                frequency = 0
            case .mainPageTabDefault:
                frequency = 0
            case .accountFreq:
                frequency = 30
            case .supportGreyTradeFutu:
                frequency = 0
            }
        }
        
        return frequency!
    }
    
    @objc public class func tcpIpUrl() -> String? {
        var tryIp: String? = nil
        YXGlobalConfigManager.shareInstance.decodeGlobalConfigModel()
        if let model = YXGlobalConfigManager.shareInstance.globalConfigModel {

            if let tcpIps = model.tcpConnectIPS, tcpIps.count > 0 {
                let index = Int(arc4random_uniform(UInt32(tcpIps.count)))
                if index < tcpIps.count, let tempIp = tcpIps[index].ip {
                    tryIp = tempIp
                }
            }
        }
        
        /*
         if tryIp.count <= 0 {
         let tcpIps = YXUrlRouterConstant.socketBaseUrl()
         if tcpIps.count > 0 {
         let index = Int(arc4random_uniform(UInt32(tcpIps.count)))
         tryIp = tcpIps[index]
         }
         }
         */
        return tryIp
    }
    
    @objc public class func requestIP() -> String? {
        var url: String? = nil
        YXGlobalConfigManager.shareInstance.decodeGlobalConfigModel()
        if let model = YXGlobalConfigManager.shareInstance.globalConfigModel {

            if let tcpIps = model.serverUrls?.quoteInfoCenter?.ips, tcpIps.count > 0 {
                let index = Int(arc4random_uniform(UInt32(tcpIps.count)))
                if index < tcpIps.count, let tempIp = tcpIps[index].ip {
                    if tempIp.contains("http") {
                        url = tempIp
                    } else  {
                        url = "http://" + tempIp
                    }
                }
            }
        }
        return url
    }
    
    /// 获取指定类型的请求HOST
    /// - Parameter type: 指定的业务类型
    /// - Returns: 返回带有scheme的url
    @objc public class func bizUrl(type: YXGlobalConfigURLType) -> String? {
        YXGlobalConfigManager.shareInstance.decodeGlobalConfigModel()
        if let model = YXGlobalConfigManager.shareInstance.globalConfigModel {
            switch type {
            case .hzCenter:
                return model.serverUrls?.quoteInfoCenter?.url
            case .jyCenter:
                return model.serverUrls?.jyCenter?.url
            case .zxCenter:
                return model.serverUrls?.zxCenter?.url
            case .wjCenter:
                return model.serverUrls?.wjCenter?.url
            default:
                return nil
            }
        }
        return nil
    }
    
    /// 获取指定类型的IP
    /// - Parameter type: 指定的业务类型
    /// - Returns: 返回不带scheme的url【使用时需要注意，在PRD环境下SCHEME默认为HTTPS，SIT/UAT等环境默认为HTTP；或者与YXUrlRouterConstant中的SCHEME保持一致也可以】
    @objc public class func bizIPs(type: YXGlobalConfigURLType) -> [String] {
        var ips : [String] = []
        YXGlobalConfigManager.shareInstance.decodeGlobalConfigModel()
        if let model = YXGlobalConfigManager.shareInstance.globalConfigModel {
            switch type {
            case .hzCenter:
                if let ipModels = model.serverUrls?.quoteInfoCenter?.ips {
                    for ipModel in ipModels {
                        if let ip = ipModel.ip {
                            ips.append(ip)
                        }
                    }
                }
                return ips
            case .jyCenter:
                if let ipModels = model.serverUrls?.jyCenter?.ips {
                    for ipModel in ipModels {
                        if let ip = ipModel.ip {
                            ips.append(ip)
                        }
                    }
                }
                return ips
            case .zxCenter:
                if let ipModels = model.serverUrls?.zxCenter?.ips {
                    for ipModel in ipModels {
                        if let ip = ipModel.ip {
                            ips.append(ip)
                        }
                    }
                }
                return ips
            case .wjCenter:
                if let ipModels = model.serverUrls?.wjCenter?.ips {
                    for ipModel in ipModels {
                        if let ip = ipModel.ip {
                            ips.append(ip)
                        }
                    }
                }
                return ips
            default:
                return ips
            }
        }
        return ips
    }
    
    /// 比财分享域名
    @objc public class func beerichShareDomain() -> String? {
        YXGlobalConfigManager.shareInstance.decodeGlobalConfigModel()
        if let model = YXGlobalConfigManager.shareInstance.globalConfigModel ,let domain = model.parameter?.beerichShareDomain as? String, domain.count > 0 {
            return domain
        }
        return nil
    }
    
}


public extension YXGlobalConfigManager {
    
    @objc class func getGlobalUrlConfigKey() -> String {
        // 每个环境都单独保存自己环境的配置
        return "YXGlobalUrlConfigKey-".appending(YXConstant.targetModeName()!)
    }
    
    @objc class func getCountryAreaModelKey() -> String {
       // 每个环境都单独保存自己环境的配置
       // model有变化，之前的不能再使用,添加【-V1】启用新的key，
       return "YXCountryAreaModelKey-V1-".appending(YXConstant.targetModeName()!)
    }
    
    @objc class func getCountryAreaRequestKey() -> String {
        return "getCountryAreaRequestKey-".appending(YXConstant.targetModeName()!)
    }
    
    @objc class func getCustomerModelKey() -> String {
        // 每个环境都单独保存自己环境的配置
        return "YXCustomerModelKey-".appending(YXConstant.targetModeName()!)
    }
    
    @objc public class func getFilterModuleKey() -> String {
        // 每个环境都单独保存自己环境的配置
        return "YXFilterModuleKey-".appending(YXConstant.targetModeName()!)
    }
}
