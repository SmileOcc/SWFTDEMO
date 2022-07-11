//
//  YXGoToNativeCommand.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2018/11/20.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import UIKit
import Foundation

class YXGoToNativeManager: NSObject, YXGotoNativeProtocol {
    
    @objc static let shared = YXGoToNativeManager()
    
    private override init() {
        
    }
    
    override func copy() -> Any {
        self
    }
    
    override func mutableCopy() -> Any {
        self
    }
    
    // Optional
    func reset() -> Void {
        // Reset all properties to default value
    }
    
    lazy var tradeCommonLogic: YXGotoTradeCommonLogic = {
        return YXGotoTradeCommonLogic()
    }()
    
    @objc func schemeHasPrefix(string : String) -> Bool {
        return string.hasPrefix(YXNativeRouterConstant.YXZQ_SCHEME) || string.hasPrefix(YXNativeRouterConstant.YXZQ_SCHEME_V1)
    }
    
    /// 依据内部协议，跳转到指定页面
    /// 内部协议参考网站：http://szwiki.youxin.com/pages/viewpage.action?pageId=1116777
    /// - Parameter urlString: urlString: 需要跳转的Url String
    /// - Returns: 是否成功跳转
    @discardableResult
    @objc func gotoNativeViewController(withUrlString urlString : String) -> Bool {
        
        if urlString.isEmpty {
            return false
        }
        
        let result = urlString.replacingOccurrences(of: YXNativeRouterConstant.YXZQ_SCHEME_V1, with: YXNativeRouterConstant.YXZQ_SCHEME)
        let parser = YXNativeUrlParser(result)
        
        if let root = UIApplication.shared.delegate as? YXAppDelegate {
            
            let navigator = root.navigator
            
            func checkLogin(currentVC: UIViewController? = UIViewController.current(), needCheckOpenAccount: Bool = false, excuteBlock: @escaping (() -> Void)) {
                if YXUserManager.isLogin() {
                    if needCheckOpenAccount {
                        if YXUserManager.canTrade() {
                            excuteBlock()
                        }else {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: ["index" : YXTabIndex.holding])
                        }
                    }else {
                        excuteBlock()
                    }
                    
                } else {
                    let callback: (([String: Any])->Void)? = { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
                            if needCheckOpenAccount {
                                if YXUserManager.canTrade() {
                                    excuteBlock()
                                }else {
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: ["index" : YXTabIndex.holding])
                                }
                            }else {
                                excuteBlock()
                            }
                           
                        })
                    }
                    
                    let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: callback, vc: currentVC))
                    navigator.push(YXModulePaths.defaultLogin.url, context: context)
                }
            }
            
            switch parser.baseUrl {
            case YXNativeRouterConstant.GOTO_STOCK_QUOTE:
                if let market = parser.getParam(withKey: "market"),
                    let code = parser.getParam(withKey: "code") {
                    
                    let name = parser.getParam(withKey: "name")

                    let input = YXStockInputModel()
                    input.market = market
                    input.symbol = code
                    input.name = name ?? ""
                    navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : [input], "selectIndex" : 0])
                } else {
                    log(.warning, tag: kOther, content: "个股详情页error -> market or code is empty")
                }
            case YXNativeRouterConstant.GOTO_STOCK_QUOTE_DISCUSSION:
                if let market = parser.getParam(withKey: "market"),
                    let code = parser.getParam(withKey: "code") {
                    
                    let name = parser.getParam(withKey: "name")

                    let input = YXStockInputModel()
                    input.market = market
                    input.symbol = code
                    input.name = name ?? ""
                    navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : [input],"selectIndex" : 0, "selectTab" : StockDetailViewTabType.discussions])
                } else {
                    log(.warning, tag: kOther, content: "个股详情页error -> market or code is empty")
                }
            case YXNativeRouterConstant.GOTO_DEPOSIT:
                let dic: [String: Any] = [
                    YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_DEPOSIT_URL(market: parser.getParam(withKey: "market"))
                ]
                navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
               
            case YXNativeRouterConstant.GOTO_WITHDRAWAL:
                let dic: [String: Any] = [
                    YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_WITHDRAWAL_URL(market: parser.getParam(withKey: "market"))
                ]
                navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                
            case YXNativeRouterConstant.GOTO_USER_LOGIN:
                let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: nil, vc: nil))
                navigator.push(YXModulePaths.defaultLogin.url, context: context)
            case YXNativeRouterConstant.GOTO_TRADE_LOGIN:
                log(.info, tag: kOther, content: "交易登录")
            case YXNativeRouterConstant.GOTO_MAIN_OPTSTOCKS:
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: ["index" : YXTabIndex.market])
            case YXNativeRouterConstant.GOTO_MAIN_HKMARKET://自选--市场--港股
                let userInfo: [String : Any] = [
                    "index" : YXTabIndex.market,
                    "moduleTag" : 0,
                    "subModuleTag": 1
                ]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: userInfo)
            case YXNativeRouterConstant.GOTO_MAIN_USMARKET://自选--市场--美股
                let userInfo: [String : Any] = [
                    "index" : YXTabIndex.market,
                    "moduleTag" : 0,
                    "subModuleTag": 0
                ]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: userInfo)
            case YXNativeRouterConstant.GOTO_MAIN_HSMARKET://自选--市场--A股
                let userInfo: [String : Any] = [
                    "index" : YXTabIndex.market,
                    "moduleTag" : 0,
                    "subModuleTag": 2
                ]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: userInfo)
            case YXNativeRouterConstant.GOTO_MAIN_INFO: //自选--资讯
                let userInfo: [String : Any] = [
                    "index" : YXTabIndex.find,
                    "moduleTag" : 0,  //下标2--> 资讯
                ]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: userInfo)
                
            case YXNativeRouterConstant.GOTO_MAIN_INFO_MY_COURSE, YXNativeRouterConstant.GOTO_INFO_VIDEO://资讯-视频
                let userInfo: [String : Any] = [
                    "index" : YXTabIndex.find,      // 发现
                    "moduleTag" : 1,                //下标1--> 视频
                ]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: userInfo)
            case YXNativeRouterConstant.GOTO_INFO_LIVE://资讯--直播
                let userInfo: [String : Any] = [
                    "index" : YXTabIndex.find,      // 发现
                    "moduleTag" : 1,                //下标1
                ]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: userInfo)
            case YXNativeRouterConstant.GOTO_PUSH_LIVE://直播页面
                let liveId = parser.getParam(withKey: "pushId") ?? ""
                let viewModel = YXPreLiveViewModel(services: navigator, params: ["liveId": liveId])
                navigator.push(viewModel, animated: true)
            case YXNativeRouterConstant.GOTO_MAIN_TRADE:
                checkLogin(excuteBlock: {
                    let market = parser.getParam(withKey: "market") ?? YXMarketType.HK.rawValue
                    var userInfo: [String : Any] = [
                        "index" : YXTabIndex.holding
                    ]
                    if market.caseInsensitiveCompare(YXMarketType.US.rawValue) == .orderedSame {
                        userInfo["moduleTag"] = 1
                    } else if [YXMarketType.ChinaSH.rawValue, YXMarketType.ChinaSZ.rawValue, YXMarketType.ChinaHS.rawValue]
                        .contains(where: {$0.caseInsensitiveCompare(market) == .orderedSame})  {
                        userInfo["moduleTag"] = 2
                    } else {
                        userInfo["moduleTag"] = 0
                    }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: userInfo)
                })
                
            case YXNativeRouterConstant.GOTO_MAIN_PERSONAL:
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: ["index" : YXTabIndex.userCenter])
                navigator.push(YXModulePaths.userCenter.url)
            case YXNativeRouterConstant.GOTO_MAIN_FUND:
                let userInfo: [String : Any] = [
                    "index" : YXTabIndex.market,
                    "moduleTag" : 1,
                    "subModuleTag": 0
                ]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: userInfo)
            case YXNativeRouterConstant.GOTO_OPEN_ACCOUNT:
                let context = YXNavigatable(viewModel: YXOpenAccountWebViewModel(dictionary: [:]))
                navigator.push(YXModulePaths.openAccount.url, context: context)
            case YXNativeRouterConstant.GOTO_MESSAGE_CENTER:
                if YXUserManager.isLogin() {
                    let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_MSG_CENTER_URL()]
                    navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                } else {
                    let callback: (([String: Any])->Void)? = { _ in
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                            let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_MSG_CENTER_URL()]
                            navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                        })
                    }
                    
                    let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: callback, vc: nil))
                    navigator.push(YXModulePaths.defaultLogin.url, context: context)
                }
            case YXNativeRouterConstant.GOTO_MESSAGE_DETAIL:
                log(.info, tag: kOther, content: "消息中心- 消息详情")
            case YXNativeRouterConstant.GOTO_STOCK_TRADE:
                checkLogin(needCheckOpenAccount: true, excuteBlock: { [weak self] in
                    // 对应大陆版文件：YXGoToNativeManager.swift  搜索YXNativeRouterConstant.GOTO_STOCK_TRADE
                    // 跳转交易下单页面
                    let market = parser.getParam(withKey: "market")
                    let code = parser.getParam(withKey: "code")
                    // type : 0-普通交易、1-日内融交易、2-期权交易，3-智能订单
                    let type = parser.getParam(withKey: "type")
                    // clearStatus 日内交易需要
                    let clearStatus = parser.getParam(withKey: "clearStatus")
                    
                    let entrustType = Int(parser.getParam(withKey: "entrustType") ?? "") ?? 0
                    // 允许market 和 code 为空“
                    let tradeModel = TradeModel()
                    tradeModel.market = market ?? kYXMarketHK
                    tradeModel.symbol = code ?? ""
                    tradeModel.direction = entrustType == 0 ? .buy : .sell
                    
                    if type == "1" {
                        // 2022.4.21 日内融交易还没有
                    }else if type == "2" && !YXUserManager.isOpenUsOption() { //引导去期权开户
                        YXWebViewModel.pushToWebVC(YXH5Urls.OpenUsOptionURL())
                    }else if type == "3" {
                        self?.tradeCommonLogic.gotoSmartTrade(model: tradeModel)
                    }else if type == "4" {
                        YXToolUtility.handleCanTradeFractional {
                            tradeModel.market = kYXMarketUS
                            YXTradeManager.getOrderType(market: tradeModel.market) { (tradeOrderType) in
                                tradeModel.tradeType = .fractional
                                tradeModel.tradeOrderType = tradeOrderType
                                let viewModel = YXTradeViewModel(services: navigator, params: [
                                    "tradeModel" : tradeModel])
                                navigator.push(viewModel, animated: true)
                            }
                        }
                    }else {
                        self?.tradeCommonLogic.gotoTrade(model: tradeModel)
                    }
                })

            case YXNativeRouterConstant.GOTO_WEBVIEW:
                if let url = parser.getParam(withKey: "url") {
                    var titleBarVisible: Bool
                    
                    if let visible = parser.getParam(withKey:"titleBarVisible") {
                        if visible.lowercased() == "false" {
                            titleBarVisible = false
                        } else {
                            titleBarVisible = true
                        }
                    } else {
                        titleBarVisible = true
                    }
                    
                    var dic: [String: Any] = [
                        YXWebViewModel.kWebViewModelUrl: url,
                        YXWebViewModel.kWebViewModelTitleBarVisible : titleBarVisible
                    ]
                    
                    if let title = parser.getParam(withKey: "title") {
                        dic[YXWebViewModel.kWebViewModelTitle] = title
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                    }
                } else {
                    log(.warning, tag: kOther, content: "Native Webview页面 error -> url is empty")
                }
            case YXNativeRouterConstant.GOTO_INFO_DETAIL:
                if let type = parser.getParam(withKey: "type"),
                    let newsId = parser.getParam(withKey: "newsid") {
                    if Int(type) == YXInfomationType.Normal.rawValue || Int(type) == YXInfomationType.Recommend.rawValue {
                        var dictionary: Dictionary<String, Any> = [
                            "newsId" : newsId,
                        ]
                        
                        if Int(type) == YXInfomationType.Normal.rawValue {
                            dictionary["type"] = YXInfomationType.Normal
                        } else if Int(type) == YXInfomationType.Recommend.rawValue {
                            dictionary["type"] = YXInfomationType.Recommend
                        }
                        
                        if let title = parser.getParam(withKey: "title") {
                            dictionary["title"] = title
                            dictionary["newsTitle"] = title
                        }
                        
                        let context = YXNavigatable(viewModel: YXInfoDetailViewModel(dictionary: dictionary))
                        
                        navigator.push(YXModulePaths.infoDetail.url, context: context)
                    }
                } else {
                    log(.warning, tag: kOther, content: "资讯详情页面 error -> type or newsid is empty")
                }
            case YXNativeRouterConstant.GOTO_FUND_HISTORY_RECORD:
                log(.info, tag: kOther, content: "历史记录")
                checkLogin(needCheckOpenAccount: true, excuteBlock: {
                    var bizType: YXHistoryBizType = .All
                    if let type = parser.getParam(withKey: "type") {
                        if Int(type) == 1 {
                            bizType = .Deposit
                        } else if Int(type) == 2 {
                            bizType = .Withdraw
                        } else if Int(type) == 3 {
                            bizType = .Exchange
                        } else {
                            bizType = .All
                        }
                    }
                    let context = YXNavigatable(viewModel: YXHistoryViewModel(bizType: bizType))
                    navigator.push(YXModulePaths.history.url, context: context)
                })
                
            case YXNativeRouterConstant.GOTO_FEEDBACK:
                navigator.push(YXModulePaths.userCenterFeedback.url)
            case YXNativeRouterConstant.GOTO_TEL:
                if let phoneNumber = parser.getParam(withKey: "phoneNumber"),
                    let url = URL(string: "tel:" + phoneNumber) {
                    UIApplication.shared.open(url, completionHandler: nil)
                }
            case YXNativeRouterConstant.GOTO_CUSTOMER_SERVICE:
                let context = YXNavigatable(viewModel: YXOnlineServiceViewModel(dictionary: [:]))
                navigator.push(YXModulePaths.onlineService.url, context: context)
            case YXNativeRouterConstant.GOTO_SMART_MONITOR:
                let vc = UIViewController.current()
                if vc.isKind(of: YXStareHomeVC.self) {
                    break
                }
                
                if YXUserManager.isLogin() {
                    let params: [AnyHashable : Any] = [ "market" : YXMarketType.HK.rawValue]
                    let detailViewModel = YXStareHomeViewModel.init(services: navigator, params: params)
                    navigator.push(detailViewModel, animated: true)
                } else {
                    let callback: (([String: Any])->Void)? = { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
                            let params: [AnyHashable : Any] = [ "market" : YXMarketType.HK.rawValue]
                            let detailViewModel = YXStareHomeViewModel.init(services: navigator, params: params)
                            navigator.push(detailViewModel, animated: true)
                        })
                    }

                    let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: callback, vc: vc))
                    navigator.push(YXModulePaths.defaultLogin.url, context: context)
                }
                break
            case YXNativeRouterConstant.GOTO_ORDER_RECORD:
                checkLogin(needCheckOpenAccount: true, excuteBlock: {
                    var exchangeType: YXExchangeType = .hk
                    
                    if let market = parser.getParam(withKey: "market") {
                        let marketType = YXMarketType.init(rawValue: market.lowercased())
                        exchangeType = YXToolUtility.getExchangeType(with: marketType ?? YXMarketType.HK)
                    }
                    let context = YXNavigatable(viewModel: YXOrderListViewModel.init(exchangeType: exchangeType))
                    navigator.push(YXModulePaths.allOrderList.url, context: context)
                })
                
                
            case YXNativeRouterConstant.GOTO_IPO_CENTER:
                
                let type = Int(parser.getParam(withKey: "type") ?? "0") ?? 0
                var market = YXMarketType.HK.rawValue
                if type == 2 {
                    market = YXMarketType.US.rawValue
                }
                let context: [String : Any] = [
                    "market" : market
                ]
                // 新股中心
                navigator.push(YXModulePaths.newStockCenter.url, context: context)
            case YXNativeRouterConstant.GOTO_IPO_DETAIL:
                // 新股详情页
                if let market = parser.getParam(withKey: "market"),
                    let code = parser.getParam(withKey: "code") {
                    let ipoId: Int64? = Int64(parser.getParam(withKey: "ipoId") ?? "0")
                    
                    let marketType = YXMarketType.init(rawValue: market.lowercased())
                    let exchangeType = YXToolUtility.getExchangeType(with: marketType ?? YXMarketType.HK).rawValue
                    
                    let context: [String : Any] = [
                        "exchangeType" : exchangeType,
                        "ipoId" : ipoId ?? 0,
                        "stockCode" : code
                    ]
                    navigator.push(YXModulePaths.newStockDetail.url, context: context)
                    
                } else {
                    log(.warning, tag: kOther, content: "新股详情页error -> market or code is empty")
                }
                
            case YXNativeRouterConstant.GOTO_IPO_PURCHASE_ORDER:
                // 新股iPO认购页
                if parser.getParam(withKey: "ipoId") != nil ||
                    (parser.getParam(withKey: "exchangeType") != nil && parser.getParam(withKey: "stockCode") != nil) {
                    
                    
                    let exchangeType = Int(parser.getParam(withKey: "exchangeType") ?? "0") ?? 0
                    let ipoId = parser.getParam(withKey: "ipoId") ?? "0"
                    let stockCode = parser.getParam(withKey: "stockCode") ?? ""
                    let modify = Int(parser.getParam(withKey: "reconfirm") ?? "0") ?? 0
                    //未认购 ---> 立即认购（剩余X天）
                    let source = YXPurchaseDetailParams.init(exchangeType: exchangeType, ipoId: ipoId, stockCode: stockCode, isModify: modify, moneyType: YXExchangeType.currentType(exchangeType).moneyType)
                    if exchangeType == YXExchangeType.hk.rawValue {
                        navigator.push(YXModulePaths.newStockIPOPurchase.url, context: source)
                    } else {
                        navigator.push(YXModulePaths.newStockUSConfirm.url, context: source)
                    }
                    
                } else {
                    log(.warning, tag: kOther, content: "新股详情下单页error -> ipoId or stockCode is empty")
                }
            case YXNativeRouterConstant.GOTO_MAIN_STOCKKING:
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: ["index" : YXTabIndex.stockST])
                break
            case YXNativeRouterConstant.GOTO_HOLD_POSITION:
                let market = parser.getParam(withKey: "market") ?? YXMarketType.HK.rawValue
                
                let marketType = YXMarketType.init(rawValue: market.lowercased())
                let exchangeType = YXToolUtility.getExchangeType(with: marketType ?? YXMarketType.HK)
                
                if YXUserManager.isGray(with: .fund) {
                    //灰度为true 显示 基金
                    let context = YXNavigatable(viewModel: YXMixHoldListViewModel(exchangeType: exchangeType))
                    navigator.push(YXModulePaths.mixHoldList.url, context: context)
                } else {
                    let context = YXNavigatable(viewModel: YXHoldListViewModel(exchangeType: exchangeType))
                    navigator.push(YXModulePaths.holdList.url, context: context)
                }
            case YXNativeRouterConstant.GOTO_CONVERSION_RECORD:
                var exchangeType: YXExchangeType = .hk
                
                if let market = parser.getParam(withKey: "market") {
                    let marketType = YXMarketType.init(rawValue: market.lowercased())
                    exchangeType = YXToolUtility.getExchangeType(with: marketType ?? YXMarketType.HK)
                }
                
                let context = YXNavigatable(viewModel: YXShiftInStockHistoryViewModel(dictionary: [
                    "exchangeType" : exchangeType
                ]))
                navigator.push(YXModulePaths.shiftInHistory.url, context: context)
            case YXNativeRouterConstant.GOTO_TEL:
                if let phoneNumber = parser.getParam(withKey: "phoneNumber") {
                    let str = "tel:\(phoneNumber)"
                    let application = UIApplication.shared
                    let URL = NSURL(string: str)
                    
                    if let URL = URL {
                        application.open(URL as URL, options: [:], completionHandler: { success in
                        })
                    }
                } else {
                    log(.warning, tag: kOther, content: "拨打电话error -> phoneNumber is empty")
                }
            case YXNativeRouterConstant.GOTO_CURRENCY_EXCHANGE:
                checkLogin(needCheckOpenAccount: true, excuteBlock: {
                    var exchangeType: YXExchangeType = .hk
                    
                    if let market = parser.getParam(withKey: "market") {
                        let marketType = YXMarketType.init(rawValue: market.lowercased())
                        exchangeType = YXToolUtility.getExchangeType(with: marketType ?? YXMarketType.HK)
                    }
                    
                    let context = YXNavigatable(viewModel: YXCurrencyExchangeViewModel(market: exchangeType.market))
                    navigator.push(YXModulePaths.exchange.url, context: context)
                })
                
            case YXNativeRouterConstant.GOTO_NEWSTOCK_PURCHASE_DETAIL:
                // 新股认购明细页
                if parser.getParam(withKey: "applyId") != nil {

                    let applyId = parser.getParam(withKey: "applyId") ?? "0"
                    let context: [String : Any] = [
                        "applyID" : applyId,
                        "exchangeType" : YXExchangeType.us,
                        "applyType" : YXNewStockSubsType.internalSubs
                    ]
                    navigator.push(YXModulePaths.newStockECMListDetail.url, context: context)

                } else {
                    log(.warning, tag: kOther, content: "新股认购明细页error -> applyId is empty")
                }
            case YXNativeRouterConstant.GOTO_ABOUT_DETAIL:
                // 关于
                navigator.push(YXModulePaths.userCenterAbout.url, context: nil)
                
            case YXNativeRouterConstant.GOTO_MINE_COLLECT:

                //是否登录
                if YXUserManager.isLogin() {
                    navigator.push(YXModulePaths.userCenterCollect.url)
                } else {
                    let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: nil, vc: nil))
                    navigator.push(YXModulePaths.defaultLogin.url, context: context)
                }
            case YXNativeRouterConstant.GOTO_SEARCH:
                navigator.present(YXModulePaths.search.url, animated: false)
            case YXNativeRouterConstant.GOTO_IPO_PREMARKET:
                let context: [String : Any] = ["defaultTab" : YXNewStockCenterTab.preMarket]
                navigator.push(YXModulePaths.newStockCenter.url, context: context)
            case YXNativeRouterConstant.GOTO_LIVE_AUDIENCE://直播页面
                let liveId = parser.getParam(withKey: "pushId") ?? ""
                let viewModel = YXWatchLiveViewModel(services: navigator, params: ["liveId": liveId])
                navigator.push(viewModel, animated: true)
            case YXNativeRouterConstant.GOTO_BANK_TREASURER:
                checkLogin(needCheckOpenAccount: true, excuteBlock: {
//                    let market = parser.getParam(withKey: "market") ?? YXMarketType.HK.rawValue
//                    let viewModel = YXBankTreasurerViewModel(services: navigator, params: ["market": market])
//                    navigator.push(viewModel, animated: true)
                })
                
            case YXNativeRouterConstant.GOTO_MARKET_RANK:
                let market = parser.getParam(withKey: "market") ?? "hk"
                let rankType = parser.getParam(withKey: "rankType") ?? ""
                let rankCode = parser.getParam(withKey: "rankCode") ?? ""
                
                if rankType == "commonRank"  {
                    var title: String = ""
                    switch rankCode {
                    case "HK_ALL":
                        title = YXMarketSectionType.allHKStock.sectionName
                    case "MAIN_ALL":
                        title = YXMarketSectionType.mainboard.sectionName
                    case "GEM_ALL":
                        title = YXMarketSectionType.gem.sectionName
                    case "INDUSTRY_ALL":
                        title = YXMarketSectionType.industry.sectionName
                    case "US_ALL":
                        title = YXMarketSectionType.upsaAndDowns.sectionName
                    case "STAR_ALL":
                        title = YXMarketSectionType.star.sectionName
                    case "CONCEPT_ALL":
                        if market == "us" {
                            title = YXMarketSectionType.chinaConceptStock.sectionName
                        }else {
                            title = YXMarketSectionType.concept.sectionName
                        }
                        
                    case "CONNECT_ALL":
                        title = YXMarketSectionType.AStockFund.sectionName
                    case "DAILYFUNDING_ALL":
                        title = YXMarketSectionType.dailyFunding.sectionName
                    case "HS_ALL":
                        title = YXMarketSectionType.allHSStock.sectionName
                    default:
                        break
                    }
                    
                    let context: [String : Any] = ["title": title, "market": market, "code": rankCode]
                    navigator.push(YXModulePaths.stockIndustry.url, context: context)
                }else if rankType == "hotIndustry" {
                    let context: [String : Any] = ["title": YXMarketSectionType.industry.sectionName, "market": market, "rankCode": YXMarketSectionType.industry.rankCode]
                    navigator.push(YXModulePaths.hotIndustryList.url, context: context)
                }else if rankType == "dayMarginList" {
                    let dic: [String: Any] = ["market": YXMarketType.init(rawValue: market) ?? .HK, "rankType": YXRankType.dailyFunding]
                    navigator.push(YXModulePaths.financingList.url, context: dic)
                }else if rankType == "marginableList" {
                    let dic: [String: Any] = ["market": YXMarketType.init(rawValue: market) ?? .HK]
                    navigator.push(YXModulePaths.financingList.url, context: dic)
                }else if rankType == "concept" {
                    let context: [String : Any] = ["title": YXMarketSectionType.concept.sectionName, "market": market, "rankCode": YXMarketSectionType.concept.rankCode]
                    navigator.push(YXModulePaths.hotIndustryList.url, context: context)
                }
                
            case YXNativeRouterConstant.GOTO_STOCK_SCREENER:
                let market = parser.getParam(withKey: "market") ?? "hk"
                let vm = YXStockFilterTabViewModel.init(services: navigator, params: ["market": market])
                navigator.push(vm, animated: true)
            case YXNativeRouterConstant.GOTO_MARKET_WARRANTS:
                let userInfo: [String : Any] = [
                    "index" : YXTabIndex.market,
                    "moduleTag" : 0,
                    "subModuleTag": 2
                ]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: userInfo)
            case YXNativeRouterConstant.GOTO_MESSAGE_NOTICE_SETTINGS:
                let context = YXNavigatable(viewModel: YXNotiViewModel())
                navigator.push(YXModulePaths.noti.url, context: context)
            case YXNativeRouterConstant.GOTO_APP_SETTINGS:
                navigator.push(YXModulePaths.userCenterSet.url)
            case YXNativeRouterConstant.GOTO_GREY_MARKET_LIST:
                if YXUserManager.isLogin() {
                    if YXUserManager.canTrade() {
                        let viewModel = YXTodayGreyStockViewModel(services: navigator, params: nil)
                        navigator.push(viewModel, animated: true)
                    } else {
                        let context = YXNavigatable(viewModel: YXOpenAccountWebViewModel(dictionary: [:]))
                        navigator.push(YXModulePaths.openAccount.url, context: context)
                    }
                } else {
                    let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: { [weak self] (dic) in
                        self?.gotoNativeViewController(withUrlString: YXNativeRouterConstant.GOTO_GREY_MARKET_LIST)
                    }, vc: nil))
                    navigator.push(YXModulePaths.defaultLogin.url, context: context)
                }
            case YXNativeRouterConstant.GOTO_SMART_BIND_EMAIL:
               navigator.push(YXModulePaths.bindEmail.url, context:nil)
            case YXNativeRouterConstant.GOTO_NBB_HOME:
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: ["index" : YXTabIndex.learning, "moduleTag": 0])
            case YXNativeRouterConstant.GOTO_NBB_COURSE:
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: ["index" : YXTabIndex.learning, "moduleTag": 0])
            case YXNativeRouterConstant.GOTO_NBB_MINE:
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: ["index" : YXTabIndex.mine, "moduleTag": 0])
            case YXNativeRouterConstant.GOTO_NBB_KOL_PERSONAL:
                var kolId: String?
                if let id = parser.getParam(withKey: "kolId") {
                    kolId = id
                }
                navigator.pushPath(YXModulePaths.kolHome,
                                   context: ["kolId":kolId],
                                   animated: true)
            case YXNativeRouterConstant.GOTO_NBB_COURSE_DETAIL:
                var courseId: String?
                var lessonId: String?
                if let id = parser.getParam(withKey: "courseId") {
                    courseId = id
                }
                if let id = parser.getParam(withKey: "courseId") {
                    lessonId = id
                }
                ///isUserPayed H5跳入时暂时全部为false
                navigator.pushPath(YXModulePaths.courseDetail,
                                   context: ["courseId":courseId,
                                             "lessonId":lessonId,
                                             "isUserPayed": false],
                                   animated: true)
            case YXNativeRouterConstant.GOTO_NBB_BROWSE:
                if let url = parser.getParam(withKey: "url"), let URL = URL(string: url) {
                    let app = UIApplication.shared
                    if app.canOpenURL(URL) {
                        //是被是否可以打开
                        app.open(URL, options: [:], completionHandler: { success in
                        })
                    }
                }
            //讨论详情
        case YXNativeRouterConstant.GOTO_UGC_CONTENT_DETAIL:
            if let type = parser.getParam(withKey: "type"),
               let cid = parser.getParam(withKey: "id"),
               let intType = Int(type),
               let flowType =  YXInformationFlowType(rawValue: intType) {
                YXUGCCommentManager.jumpToSeedVC(params: ["cid": cid], flowType:flowType)
            }
            default:
                log(.error, tag: kOther, content: "no one base url matched")
                return false
            }
        }
        
        return true
    }
}
