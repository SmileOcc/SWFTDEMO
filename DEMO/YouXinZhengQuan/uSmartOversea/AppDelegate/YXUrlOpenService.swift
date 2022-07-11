//
//  YXUrlOpenService.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2018/11/23.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import UIKit
import PluggableApplicationDelegate
import URLNavigator
import TYAlertController
import YXKit

let YX_Noti_OpenUrl = "YX_Noti_OpenUrl"

class YXUrlOpenService: NSObject, ApplicationService {
    static let scheme_V1 = "usmart-global"

    static let host_V1 = "stock.app"
    
    static let scheme = "usmart-global"

    static let host = "stock.app"
    
    enum Path: String {
        // 资讯详情页
        case infoDetail = "/info_detail"
        // 内部H5页面
        case h5Page = "/h5_page"
        // 股票详情页
        case stockDetail = "/stock_detail"
        // 主页面
        case main = "/main"
        // 交易下单
        case stockTrade = "/stock_trade"
        // 新股中心
        case ipoCenter = "/ipo_center"
        // 交易订单查询
        case orderRecord = "/order_record"
        // 持仓查询
        case holdingRecord = "/holding_record"
    }
    
    enum mainTag: String {
        case optstocks = "optstocks"  //自选股
//        case info = "info"
        case trade = "trade"        //开户/交易
//        case stockking = "stockking"
//        case personal = "personal"
        case hkmarket = "hkmarket"
        case usmarket = "usmarket"
        case hkwarrants = "hkwarrants_market"
        case crypto = "crypto_market"
        case ustrategy = "ustrategy"
        case mine = "mine"
//        1、 optstocks 自选股
//        2、hkmarket 港股市场
//        3、usmarket 美股市场
//        4、hkwarrants_market 港股窝论牛熊
//        5、crypto_market 数字货币
//        6、ustrategy 智投策略
//        7、trade 交易账户/ 开户
//        8、mine 个人中心
    }

    override init() {
        super.init()
        _ = NotificationCenter.default.rx.notification(Notification.Name(rawValue: YX_Noti_OpenUrl))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (notification) in
                if let object = notification.object as? URL {
                    _ = self?.urlDispatcher(url: object)
                }
            })
    }
    
    @available(iOS, introduced: 2.0, deprecated: 9.0, message: "Please use application:openURL:options:")
    open func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        urlDispatcher(url: url)
    }
    
    @available(iOS, introduced: 4.2, deprecated: 9.0, message: "Please use application:openURL:options:")
    open func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        urlDispatcher(url: url)
    }
    
    @available(iOS 9.0, *)
    open func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        urlDispatcher(url: url)
    }
    
    /// 清除本次启动的参数
    public class func clearPublicQueryParams() {
        YXConstant.launchChannel = nil
        YXConstant.AAStockPageName = nil
    }
    
    /// 设置启动公共属性
    /// - Parameter url: 启动链接
    public class func setPublicQueryParams(url: URL?) {
        YXUrlOpenService.clearPublicQueryParams()
        
        if let launchChannel = url?.queryDictionary?["channel"] {
            YXConstant.launchChannel = launchChannel
        }
        
        if let AAStockPageName = url?.queryDictionary?["AAStockPageName"], YXConstant.isLaunchedByAAStock() {
            YXConstant.AAStockPageName = AAStockPageName
        }
    }
    
    fileprivate func urlDispatcher(url: URL) -> Bool {
       
        if url.scheme == usmartWidgetSG {
            let str = url.absoluteString.replacingOccurrences(of: usmartWidgetSG, with: "yxzq_goto")
            YXGoToNativeManager.shared.gotoNativeViewController(withUrlString: str)
            return true
        }
        
        var comp = URLComponents(url: url, resolvingAgainstBaseURL: true)
        if comp != nil {
            if comp?.scheme == YXUrlOpenService.scheme_V1 {
                comp?.scheme = YXUrlOpenService.scheme
            }
            
            if comp?.host == YXUrlOpenService.host_V1 {
                comp?.host = YXUrlOpenService.host
            }
        }
        
        if let root = UIApplication.shared.delegate as? YXAppDelegate, let url = try? comp?.asURL() {
            let navigator = root.navigator
            
            if url.scheme == YXUrlOpenService.scheme &&
                url.host == YXUrlOpenService.host {
                
                YXUrlOpenService.setPublicQueryParams(url: url)
                
                switch url.path {
                case Path.infoDetail.rawValue:
                    // 1.资讯详情页，判断是否传入了参数
                    guard let queryDictionary = url.queryDictionary else {
                        return false;
                    }
                    
                    // 2.判断是否传入的参数中是否存在newsId参数和type
                    guard let newsId = queryDictionary["newsid"], let type = queryDictionary["type"] else {
                        return false
                    }
                    
                    // 3.判断传入的type值是否是YXNewsTypeNormal和YXNewsTypeRecommend
                    var newsType: YXInfomationType
                    switch type {
                    case "1":
                        newsType = .Normal;
                    case "2":
                        newsType = .Recommend
                    default:
                        return false
                    }
                    
                    var params : Dictionary<String, Any> = ["newsId" : newsId, "type" : newsType.rawValue]
                    if let title = queryDictionary["title"] {
                        params[YXWebViewModel.kWebViewModelTitle] = title
                        params["newsTitle"] = title
                    }
                    
                    let context = YXNavigatable(viewModel: YXInfoDetailViewModel(dictionary: params))
                    navigator.push(YXModulePaths.infoDetail.url, context: context)
                    return true
                case Path.h5Page.rawValue:
                    // 1.内部H5页面，判断是否传入了参数
                    guard let queryDictionary = url.queryDictionary else {
                        return false;
                    }
                    
                    // 2.判断是否传入的参数中是否存在url参数
                    guard let destUrlString = queryDictionary["url"] else {
                        return false
                    }
                    
                    // 3.判断url参数是否是一个合法的URL
                    guard let urlString = destUrlString.removingPercentEncoding,
                        let destUrl = URL.init(string: urlString) else {
                            return false
                    }
                    
                    // 4.判断该URL是否遵从HTTPS协议
                    #if PRD || PRD_HK
                    guard destUrl.scheme == "https" else {
                        return false
                    }
                    #else
                    guard destUrl.scheme == "https" || destUrl.scheme == "http" else {
                        return false
                    }
                    #endif
                    
                    var titleBarVisible = false
                    if let visible = queryDictionary["titleBarVisible"] {
                        if visible.lowercased() == "false" {
                            titleBarVisible = false
                        } else {
                            titleBarVisible = true
                        }
                    } else {
                        titleBarVisible = true
                    }
                    
                    if url.path == Path.h5Page.rawValue {
                        // 常规Web页面
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            // FIXME: 延时0.1秒主要是因为在App冷启动时，会导致直接tabBarViewController没有加入到rootViewController上
                            if destUrlString.count > 0 {
                                var dic: [String: Any] = [
                                    YXWebViewModel.kWebViewModelUrl: destUrlString,
                                    YXWebViewModel.kWebViewModelTitleBarVisible : titleBarVisible
                                ]
                                if let title = queryDictionary["title"] {
                                    dic[YXWebViewModel.kWebViewModelTitle] = title
                                }
                                
                                navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                            }
                        }
                    }
                    return true
                case Path.stockDetail.rawValue:
                    // market=hk&code=00700    market和code都必须有，否则无法跳转到个股详情页面
                    // 1.判断是否传入了参数
                    guard let queryDictionary = url.queryDictionary else {
                        return false;
                    }
                    
                    // 2.判断是否传入的参数中是否存在market参数
                    guard let market = queryDictionary["market"] else {
                        return false
                    }
                    
                    // 3.判断是否传入的参数中是否存在code参数
                    guard let code = queryDictionary["code"] else {
                        return false
                    }
                    

                    let input = YXStockInputModel()
                    input.market = market
                    input.symbol = code

                    navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : [input], "selectIndex" : 0])
                    return true
                case Path.main.rawValue:
                    // 1.判断是否传入了参数
                    guard let queryDictionary = url.queryDictionary else {
                        return false;
                    }
                    
                    // 2.判断是否传入的参数中是否存在tag参数
                    guard let tag = queryDictionary["tag"] else {
                        return false
                    }
                    
                    self.pushToMain(navigator, tag: tag)
                    return true
                case Path.stockTrade.rawValue:
                    // market=hk&code=00700    market必须有，否则无法跳转到交易下单页面;
                    // 1.判断是否传入了参数
                    guard let queryDictionary = url.queryDictionary else {
                        return false;
                    }
                    
                    // 2.判断是否传入的参数中是否存在market参数
                    var market = queryDictionary["market"] ?? YXMarketType.HK.rawValue
                    
                    if !YXToolUtility.oneOfSupporttedMarket(market) {
                        // 判断传入的market是否合法,如果不合法,则默认使用港股
                        market = YXMarketType.HK.rawValue
                    }
                    
                    // 3.尝试提取参数中的code字段
                    let code = queryDictionary["code"]
                    
                    // 4.尝试提取参数中的name字段
                    let name = queryDictionary["name"]
                    
                    // 5.买入或是卖出，
                    let entrustType = queryDictionary["entrust_type"]
                    
                    var direction: TradeDirection = .buy
                    
                    if entrustType?.caseInsensitiveCompare("1") == .orderedSame {
                        direction = .sell
                    }
                    
                    self.pushToTradeOrder(navigator, market: market, code: code, name: name, direction: direction)
                    return true
                case Path.ipoCenter.rawValue:
                    //新股认购
                    self.pushToIPOCenter(navigator)
                    return true
                case Path.orderRecord.rawValue:
                    // 1.判断是否传入的参数中是否存在market参数
                    var exchangeType: YXExchangeType = .hk
                    if let market = url.queryDictionary?["market"] {
                        let marketType = YXMarketType.init(rawValue: market.lowercased())
                        exchangeType = YXToolUtility.getExchangeType(with: marketType ?? YXMarketType.HK)
                    }
                    self.pushToOrderRecord(navigator, exchangeType: exchangeType)
                    return true
                case Path.holdingRecord.rawValue:
                    // 1.判断是否传入的参数中是否存在market参数
                    var exchangeType: YXExchangeType = .hk
                    if let market = url.queryDictionary?["market"] {
                        let marketType = YXMarketType.init(rawValue: market.lowercased())
                        exchangeType = YXToolUtility.getExchangeType(with: marketType ?? YXMarketType.HK)
                    }
                    self.pushToHoldingRecord(navigator, exchangeType: exchangeType)
                    return true
                default:
                    return false
                }
            }
        }
        return false
    }
    
    fileprivate func dismissLoginViewControllerIfNeed() {
        if let navigationController = UIViewController.current().navigationController,
            navigationController.viewControllers.count > 0 {
            
            let vcs = navigationController.viewControllers
            
            let defaultLoginIndex = vcs.firstIndex { (vc) -> Bool in
                vc is YXDefaultLoginViewController
            }
            
            if let defaultLoginIndex = defaultLoginIndex {
                if defaultLoginIndex == 0 {
                    log(.warning, tag: kOther, content: "defaultLogin is first vc")
                } else {
                    let destinationViewController = navigationController.viewControllers[defaultLoginIndex - 1]
                    navigationController.popToViewController(destinationViewController, animated: false)
                }
            }
        }
    }
    
    /// 跳转去下单页面
    /// 待完善：如果在第三方授权登录时，则会导致无法跳转
    /// - Parameters:
    ///   - navigator: 跳转器
    ///   - market: 市场
    ///   - code: 股票代码
    ///   - name: 股票名称
    ///   - tradingType: 买入或卖出，不传默认为买入
    func pushToTradeOrder(_ navigator: NavigatorServicesType, market: String, code: String?, name: String?, direction: TradeDirection = .buy) {
        let completeBlock = {
            if YXUserManager.isLogin() {
                // 1.已登录
                if YXUserManager.canTrade() {
                    // 对应大陆版文件：YXUrlOpenService.swift  搜索pushToTradeOrder
                    // 2.可交易 -> 去交易
                    let model = TradeModel()
                    model.market = market
                    
                    if let code = code {
                        model.symbol = code
                    }
                    
                    if let name = name {
                        model.name = name
                    }
                    model.direction = direction
                    
                    YXConstant.finishTradeAAStock = false
                    YXTradeManager.getOrderType(market: model.market) { (tradeOrderType) in
                        model.tradeOrderType = tradeOrderType
                        let viewModel = YXTradeViewModel(services: navigator, params: ["tradeModel": model])
                        navigator.push(viewModel, animated: true)
                    }
                } else {
                    // 3.不可交易 -> 去开户
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: ["index" : YXTabIndex.holding])
                }
            } else {
                // 4.去登录 -> 登录后再判断是否可交易
                self.dismissLoginViewControllerIfNeed()
                
                let loginCallBack: (([String: Any])->Void)? = { [weak self] (userInfo) in
                    guard let `self` = self else { return }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
                        guard let `self` = self else { return }
                        
                        // 登陆成功后，再尝试去获取用户信息，看看是否已开户成功
                        YXUserManager.getUserInfo(complete: { [weak self] in
                            guard let `self` = self else { return }
                            
                            self.pushToTradeOrder(navigator, market: market, code: code, name: name)
                        })
                    })
                }
                
                let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: loginCallBack, vc: UIViewController.current()))
                navigator.push(YXModulePaths.defaultLogin.url, context: context)
            }
        }
        
        if UIViewController.current().isKind(of: TYAlertController.self) {
            let alert = UIViewController.current() as? TYAlertController
            alert?.dismissViewController(animated: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                completeBlock()
            }
        } else {
            completeBlock()
        }
    }
    
    /// 跳转去IPO 新股中心
    /// 待完善：如果在第三方授权登录时，则会导致无法跳转
    /// - Parameter navigator: 跳转器
    func pushToIPOCenter(_ navigator: NavigatorServicesType) {
        let completeBlock = {
            if YXUserManager.isLogin() {
                // 1.已登录
                if YXUserManager.canTrade() {
                    // 2.已开户 -> 去新股中心
                    navigator.push(YXModulePaths.newStockCenter.url)
                } else {
                    // 3.未开户 -> 去开户
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: ["index" : YXTabIndex.holding])
                }
            } else {
                // 4.去登录 -> 登录后再判断是否用户状态
                self.dismissLoginViewControllerIfNeed()
                
                let loginCallBack: (([String: Any])->Void)? = { [weak self] (userInfo) in
                    guard let `self` = self else { return }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
                        guard let `self` = self else { return }
                        
                        self.pushToIPOCenter(navigator)
                    })
                }
                
                let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: loginCallBack, vc: UIViewController.current()))
                navigator.push(YXModulePaths.defaultLogin.url, context: context)
            }
        }
        
        if UIViewController.current().isKind(of: TYAlertController.self) {
            let alert = UIViewController.current() as? TYAlertController
            alert?.dismissViewController(animated: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                completeBlock()
            }
        } else {
            completeBlock()
        }
    }
    
    /// 跳转去主页
    /// - Parameter navigator: 跳转器
    /// - Parameter tag: 指定的tab页面
    func pushToMain(_ navigator: NavigatorServicesType, tag: String) {
        let completeBlock = { [weak self] in
            guard let `self` = self else { return }
            if tag == mainTag.ustrategy.rawValue {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: ["index" : YXTabIndex.stockST])
            } else if tag == mainTag.mine.rawValue {
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: ["index" : YXTabIndex.userCenter])
//                navigator.push(YXModulePaths.userCenter.url, context: YXNavigatable(viewModel: YXUserCenterViewModel()))
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: ["index" : YXTabIndex.mine])
            }else if tag == mainTag.optstocks.rawValue{
                self.selectMareket(index: 0)
            }else if tag == mainTag.usmarket.rawValue{
                self.selectMareket(index: 2)
            }else if tag == mainTag.hkmarket.rawValue{
                self.selectMareket(index: 3)
            }else if tag == mainTag.hkwarrants.rawValue {
                self.selectMareket(index: 4)
            }else if tag == mainTag.crypto.rawValue{
                self.selectMareket(index: 5)
            } else {
                if YXUserManager.isLogin() {
                    // 1.已登录
                    if YXUserManager.canTrade() {
                        // 2.已开户 -> 跳转主页
                        switch tag {
                        case mainTag.optstocks.rawValue:
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: ["index" : YXTabIndex.market])
//                        case mainTag.info.rawValue:
//                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: ["index" : YXTabIndex.news])
                            let context = YXNavigatable(viewModel: YXInformationHomeViewModel())
                            navigator.push(YXModulePaths.infomations.url, context: context)
                        case mainTag.trade.rawValue:
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: ["index" : YXTabIndex.holding])
                        default:
                            return
                        }
                    } else {
                        // 3.未开户 -> 去开户
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: ["index" : YXTabIndex.holding])
                    }
                } else {
                    // 4.去登录 -> 登录后再判断是否用户状态
                    self.dismissLoginViewControllerIfNeed()
                    
                    let loginCallBack: (([String: Any])->Void)? = { [weak self] (userInfo) in
                        guard let `self` = self else { return }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
                            guard let `self` = self else { return }
                            
                            self.pushToMain(navigator, tag: tag)
                        })
                    }
                    
                    let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: loginCallBack, vc: UIViewController.current()))
                    navigator.push(YXModulePaths.defaultLogin.url, context: context)
                }
            }
        }
        
        if UIViewController.current().isKind(of: TYAlertController.self) {
            let alert = UIViewController.current() as? TYAlertController
            alert?.dismissViewController(animated: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                completeBlock()
            }
        } else {
            completeBlock()
        }
    }
    
    
    func selectMareket(index:Int) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: ["index" : YXTabIndex.market])
        if let marketNC = getRootViewContorller()?.selectedViewController as? UINavigationController, let marketRootVC = marketNC.viewControllers[0] as? YXMarketViewController, let marketVM = marketRootVC.viewModel {
            marketVM.selectIndex.accept(index)
        }
    }
    func getRootViewContorller() -> YXTabBarController? {
        if let root = UIApplication.shared.delegate as? YXAppDelegate {
            return root.tab
        }else {
            return nil
        }
    }
    
    /// 跳转去交易订单页面
    /// - Parameter navigator: 跳转器
    /// - Parameter exchangeType: 交易所类型
    func pushToOrderRecord(_ navigator: NavigatorServicesType, exchangeType: YXExchangeType = .hk) {
        let completeBlock = {
            if YXUserManager.isLogin() {
                // 1.已登录
                if YXUserManager.canTrade() {
                    // 2.已开户 -> 交易订单页面
                    let context = YXNavigatable(viewModel: YXOrderListViewModel(exchangeType: exchangeType), userInfo: ["isFromAAStock": true])
                    navigator.push(YXModulePaths.allOrderList.url, context: context)
                } else {
                    // 3.未开户 -> 去开户
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: ["index" : YXTabIndex.holding])
                }
            } else {
                // 4.去登录 -> 登录后再判断是否用户状态
                self.dismissLoginViewControllerIfNeed()
                
                let loginCallBack: (([String: Any])->Void)? = { [weak self] (userInfo) in
                    guard let `self` = self else { return }
                    //为解决：在引导页，aastock跳进来，登录成功后，需要跳到对应页面。
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75, execute: { [weak self] in
                        guard let `self` = self else { return }
                        
                        self.pushToOrderRecord(navigator, exchangeType: exchangeType)
                    })
                }
                
                let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: loginCallBack, vc: UIViewController.current()))
                navigator.push(YXModulePaths.defaultLogin.url, context: context)
            }
        }
        
        if UIViewController.current().isKind(of: TYAlertController.self) {
            let alert = UIViewController.current() as? TYAlertController
            alert?.dismissViewController(animated: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                completeBlock()
            }
        } else {
            completeBlock()
        }
    }
    
    /// 跳转去持仓页面
    /// - Parameter navigator: 跳转器
    /// - Parameter exchangeType: 交易所类型
    func pushToHoldingRecord(_ navigator: NavigatorServicesType, exchangeType: YXExchangeType = .hk) {
        let completeBlock = {
            if YXUserManager.isLogin() {
                // 1.已登录
                if YXUserManager.canTrade() {
                    // 2.已开户 -> 跳转去持仓页面
                    if YXUserManager.isGray(with: .fund) {
                        //灰度为true 显示 基金
                        let context = YXNavigatable(viewModel: YXMixHoldListViewModel(exchangeType: exchangeType))
                        navigator.push(YXModulePaths.mixHoldList.url, context: context)
                    } else {
                        let context = YXNavigatable(viewModel: YXHoldListViewModel(exchangeType: exchangeType))
                        navigator.push(YXModulePaths.holdList.url, context: context)
                    }
                } else {
                    // 3.未开户 -> 去开户
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: ["index" : YXTabIndex.holding])
                }
            } else {
                // 4.去登录 -> 登录后再判断是否用户状态
                self.dismissLoginViewControllerIfNeed()
                
                let loginCallBack: (([String: Any])->Void)? = { [weak self] (userInfo) in
                    guard let `self` = self else { return }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75, execute: { [weak self] in
                        guard let `self` = self else { return }
                        
                        self.pushToHoldingRecord(navigator, exchangeType: exchangeType)
                    })
                }
                
                let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: loginCallBack, vc: UIViewController.current()))
                navigator.push(YXModulePaths.defaultLogin.url, context: context)
            }
        }
        
        if UIViewController.current().isKind(of: TYAlertController.self) {
            let alert = UIViewController.current() as? TYAlertController
            alert?.dismissViewController(animated: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                completeBlock()
            }
        } else {
            completeBlock()
        }
    }
}
