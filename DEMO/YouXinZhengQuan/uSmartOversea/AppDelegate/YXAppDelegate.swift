//
//  YXAppDelegate.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2018/10/22.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import UIKit
import PluggableApplicationDelegate
import RxSwift
import RxCocoa
import UserNotifications
import URLNavigator
import AVKit
import TXLiteAVSDK_Professional
import AppTrackingTransparency
import SDWebImageWebPCoder
import WidgetKit

@_exported import YXKit
@_exported import QMUIKit
@_exported import TYAlertController

let usmartWidgetSG = "usmartWidgetSG"
var widgetGroupId: String {
    if YXConstant.targetMode() == .prd || YXConstant.targetMode() == .prd_hk {
        return "group.com.usmart.global.sg.stock"
    } else {
        return "group.com.usmart.global.enterprise.stock"
    }
}

@UIApplicationMain
class YXAppDelegate: PluggableApplicationDelegate {
    var backgroundTask = UIBackgroundTaskIdentifier.invalid
    @objc let top_icon_forscreenshot = UIImageView(image: UIImage(named: "top_icon"))
    let disposeBag = DisposeBag()
    
    var tab : YXTabBarController?
 
    lazy var appServices = {
        AppServices(preferencesService: YXPreferencesService(),
                           userService: YXUserService(), 
                           loginService: YXLoginService(), 
                           newsService: YXNewsService(), 
                           quotesDataService: YXQuotesDataService(), 
                           aggregationService: YXAggregationService(),
                           stockSTService: YXStockSTService(),
                           webService: YXWebService(),
                           optionalService: YXOptionalService(),
                           stockOrderService: YXStockOrderService(),
                           tradeService: YXTradeService(),
                           globalConfigService: YXGlobalConfigService(),
                           messageCenterService: YXMessageCenterService.shared,
                           v2QuoteService: YXV2QuoteService(),
                           stockAnalyzeService: YXStockAnalyzeService(),
                           infomationService: YXInformationService(),
                           searchService: YXSearchService(),
                           marketService: YXMarketService(),
                           learningService: YXLearningService())
    }()

    // 使用SOA（Service-Oriented Architecture）面向服务的体系架构来实现AppDelegate，降低耦合减少代码
    override var services: [ApplicationService] {
        [
            YXSocketSingletonService(), // 行情Socket配置服务
            YXConfigNetworkService(),   // 网络配置服务
            YXIQKeyboardService(),      // 键盘配置服务
            YXShareSDKService(),        // 分享SDK配置服务
            YXQCloudService(),          // 腾讯云存储配置服务
            YXUrlOpenService(),         // uSmart自身的Url拦截服务
            YXSensorsAnalyticsService(),// 神策数据分析服务
            YXUpdateService(),           // 检查更新服务
            YXSecuGroupService(),        //自选股管理服务
            YXCommonService.shared,     // 通用事務服務
            YXBrokerService(),          // 经纪商
            YXAppsFlyerService.shared,        // AppsFlyer服务
            YXLittleRedDotService(),      // 小红点服务
            YXPushService()             // 自建推送服务
        ]
    }
    
    @objc var rotateScreen = false
    var launchedUrl: URL?
    var widgetLaunchedUrl: URL?
    @objc public let navigator = NavigatorServices.shareInstance
    
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        
        YXNavigationMap.initialize(navigator: navigator, services: appServices)
        
//        self.launchedUrl = launchOptions?[UIApplication.LaunchOptionsKey.url] as? URL
        
        let url = launchOptions?[UIApplication.LaunchOptionsKey.url] as? URL
        if let url = url {
            if url.scheme == usmartWidgetSG {
                self.widgetLaunchedUrl = url
            } else {
                self.launchedUrl = url
            }
        }
        

        YXUrlOpenService.setPublicQueryParams(url: self.launchedUrl)
        
        // DNS解析
        YXDNSResolver.shareInstance().resolveAllHost()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        if #available(iOS 13.0, *) {
            self.window?.overrideUserInterfaceStyle = YXThemeTool.style()
            QMUIModalPresentationViewController.appearance().overrideUserInterfaceStyle = YXThemeTool.style()
        } else {
            
        }
        self.window?.backgroundColor = QMUITheme().foregroundColor()
        // 刘海屏在顶部加个小icon
        if QMUIHelper.isNotchedScreen {
            window?.addSubview(top_icon_forscreenshot)
            top_icon_forscreenshot.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(10)
            }
        }
        guard self.window != nil else { return false }
        
        YXAppDelegateVersionTool.configTableView()
        
        // 初始化日志记录器
        initXlogs()

        // 初始化Https配置
        configHttps()
        
        // H5资源预加载
        YXH5Cache.shareInstance.startPreload()
        
        // 初始化QMUI相关操作
        initQMUI()
        
        // 初始化推送配置
        initPushConfig(application)
        
        // MMKV LogLevel
        MMKV.setLogLevel(MMKVLogError)
        
        // 更新本地token
        YXUserManager.shared().refreshToken()
        
        // 多语言读取文件
        YXLanguageUtility.initUserLanguage()
        
        initNotifications()
        
        //添加白名单
        addMLeakFinderWhitelist()
        
        // 初始化window
        showGuideOrRootView(navigator: navigator)
        //initRootViewController(navigator: navigator)
        
        // 启动腾讯云
        initTXLite()
        
        // 监听网络状态
        YXNetworkUtil.sharedInstance().startReachabilityNotifier()
        
        // 苹果不允许在截屏上做额外的操作，所以不用此代码
//        YXScreenShotManager.shared.observerSystemScreenShotNotificatin()
        
//        _ = YXSpreadTableManager.shared
        
        YXUserManager.checkJailBreak()
        
        // 初始化SDWebImage配置
        initSDWebImage()
        
        YXSpreadTableManager.shared.updateHkSpeadTable()
        
        YXIAPManager.shared().start()

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        rotateScreen ? .landscape : .portrait
    }

    func endBackgroundTask() {
        if self.backgroundTask != UIBackgroundTaskIdentifier.invalid {
            UIApplication.shared.endBackgroundTask(self.backgroundTask);
            self.backgroundTask = UIBackgroundTaskIdentifier.invalid
        }
    }
    
    override func applicationWillEnterForeground(_ application: UIApplication) {
        endBackgroundTask()
        super.applicationWillEnterForeground(application)
    }
    
    override func applicationDidBecomeActive(_ application: UIApplication) {
        if self.launchedUrl != nil {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: YX_Noti_OpenUrl), object: self.launchedUrl)
            self.launchedUrl = nil
        } else if self.widgetLaunchedUrl != nil {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: YX_Noti_OpenUrl), object: self.widgetLaunchedUrl)
            self.widgetLaunchedUrl = nil
        }
        
        YXRealLogger.shareInstance.postRealLogs()
        super.applicationDidBecomeActive(application)
        
    }
    
    override func applicationWillResignActive(_ application: UIApplication) {
        backgroundTask = UIApplication.shared.beginBackgroundTask(expirationHandler: { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.endBackgroundTask()
        })
        YXRealLogger.shareInstance.postRealLogs()
        //更新小组件数据
        let arr = YXToolUtility.getWidgetGroupData()
        let shareDefine = UserDefaults(suiteName: widgetGroupId)
        shareDefine?.setValue(arr, forKey: "appWidget")
        // 保存header
        let request = YXRequest.init()
        let dic = request.requestHeaderFieldValueDictionary()
        shareDefine?.setValue(dic, forKey: "widget_header")
        
        // 红涨绿跌
        let color = YXUserManager.curColor(judgeIsLogin: true)
        
        if color == .gRaiseRFall {
            shareDefine?.setValue(true, forKey: "widget_color")
        } else {
            shareDefine?.setValue(false, forKey: "widget_color")
        }
        
        //指数权限
        shareDefine?.setValue(YXUserManager.isOpenAccount(broker: YXBrokersBitType.sg), forKey: "widget_index_Authority")
        
        
        shareDefine?.synchronize()
        
        if #available(iOS 14.0, *) {
            #if arch(arm64) || arch(i386) || arch(x86_64)
            WidgetCenter.shared.getCurrentConfigurations { result in
                if case .success(let data) = result {
                    for item in data {
                        WidgetCenter.shared.reloadTimelines(ofKind: item.kind)
                    }
                }
            }
            #endif
        } else {
            // Fallback on earlier versions
        }
        super.applicationWillResignActive(application)
        
    }
    
    override func applicationWillTerminate(_ application: UIApplication) {
        super.applicationWillTerminate(application)
        
        deinitXlogger()
    }
}


extension YXAppDelegate {
    
    fileprivate func showGuideOrRootView(navigator: NavigatorServicesType) {
        let isInstallKey = "YXIsInstallCacheKey"
        
        //读取本地地登录弹窗标识
        YXUserManager.getLocalShowLoginRegister()
        
        //保存过appVersion
        let cacheAppVersion: String = MMKV.default().string(forKey: "YXShortVersion") ?? ""
        if cacheAppVersion.isEmpty == false {
            //当版本不一致时，设置为 新版本app
            let curAppVersion = YXConstant.appVersion
            if curAppVersion != cacheAppVersion  {
                MMKV.default().set(true, forKey: isInstallKey)
            }else {
                MMKV.default().set(false, forKey: isInstallKey)
            }
        } else {
            MMKV.default().set(true, forKey: isInstallKey)
        }
        
        //获取是否是 新版本app
        let isInstall = MMKV.default().bool(forKey: isInstallKey, defaultValue: true) //默认为true
        if isInstall {
            //展示引导页
            let guide = YXLaunchGuideViewController(navigator: navigator, andServices: appServices)
            guide.dismissClosure = {[weak self] in
                guard let `self` = self else { return }


                self.initRootViewController(navigator: navigator)
            }
            self.window?.rootViewController = YXNavigationController(rootViewController: guide)
            self.window?.makeKeyAndVisible()
        } else {
            if YXUserManager.isShowLoginRegister() {
                let loginVC = YXDefaultLoginViewController.instantiate(withViewModel: YXLoginViewModel(callBack: nil, vc: nil), andServices: appServices, andNavigator: navigator)

                self.window?.rootViewController = YXNavigationController(rootViewController: loginVC)
                self.window?.makeKeyAndVisible()
                return
            }
            initRootViewController(navigator: navigator)
        }
        
    }
    
    /// 初始化根视图控制器
    func initRootViewController(navigator: NavigatorServicesType) {
        
        YXUserManager.endShowLoginRegister()
        YXLaunchGuideManager.setGuideToLogin(withFlag: false)
        
        //清空注册时持有的邀请码
        YXConstant.registerICode = ""
        
        self.tab = YXTabBarController(navigator: navigator)
        let market = YXMarketViewController.instantiate(withViewModel: YXMarketViewModel(), andServices: self.appServices, andNavigator: navigator)
        let marketNC = YXNavigationController(rootViewController: market)
        //发现
        let discover = YXDiscoverViewController.instantiate(withViewModel: YXDiscoverViewModel(), andServices: self.appServices, andNavigator: navigator)
        let discoverNC = YXNavigationController(rootViewController: discover)
        
        //个人中心
        let mineVC = YXUserCenterViewController.instantiate(withViewModel: YXUserCenterViewModel(), andServices: self.appServices, andNavigator: navigator)
        let mineNC = YXNavigationController(rootViewController: mineVC)
        
        //学习模块
        let learningVC = YXLearningMainViewController.instantiate(withViewModel: YXLearningMainViewModel(), andServices: self.appServices, andNavigator: navigator)
        let learningNC = YXNavigationController(rootViewController: learningVC)
                
        let tradeVC: UIViewController?
        if YXUserManager.canTrade() {
            // 已开户已入金, 则是：允许交易
            let vc = YXAccountAssetViewController()
            vc.viewModel.navigator = navigator
            tradeVC = vc
        } else {
            // 未开户，则是：等待开户
            tradeVC = YXOpenAccountGuideViewController.instantiate(withViewModel: YXOpenAccountGuideViewModel(dictionary: [:]), andServices: self.appServices, andNavigator: navigator)
        }
        if let tab = self.tab {
            tab.tabBarItemsAttributes = tab.tabBarItemsAttributesForController(with: .waitOpenAccount)
        }
        
        let tradeNC = YXNavigationController(rootViewController: tradeVC!)
        

        self.tab?.viewControllers =  [marketNC, discoverNC, tradeNC, learningNC, mineNC]
        self.window?.rootViewController = self.tab
        self.window?.makeKeyAndVisible()
        
        /// 启动如果因viewControllers为空，还没有check过home的pop的话，就在执行一次，
        self.tab?.homeCheckPopAlertView() //C
        
        //每次缓存一次最新的 是否弹出登录注册skip标识
        YXUserManager.shared().fetchGrayStatusBit(nil)
        
        MMKV.default().set(false, forKey: "YXIsInstallCacheKey") //设置：不是 新版本app
        //保存当前的 appVersion
        MMKV.default().set(YXConstant.appVersion ?? "", forKey: "YXShortVersion")
    }
}

private extension YXAppDelegate {
    func initPushConfig(_ application: UIApplication) {
        // 初始化推送配置
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .notDetermined {
                MMKV.default().set(true, forKey: YXPopManager.kNotificationName)
                center.requestAuthorization(options: [.sound, .badge, .alert], completionHandler: { (granted, error) in
                    log(.debug, tag: kXGPush, content: "UNUserNotificationCenter: granted:\(granted)")
                    DispatchQueue.main.async {
                        if granted {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                      
                        //首页广告待通知授权完成后才弹
                        YXPopManager.shared.didInstalled()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXPopManager.kNotificationName), object: nil, userInfo:nil)
                        
                        if #available(iOS 14.0, *) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                                ATTrackingManager.requestTrackingAuthorization { status in
                                    log(.warning, tag: kOther, content: "requestTrackingAuthorization : \(status.rawValue)")
                                }
                            })
                        }
                    }
                })
            } else {
                if #available(iOS 14.0, *) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                        ATTrackingManager.requestTrackingAuthorization { status in
                            log(.warning, tag: kOther, content: "requestTrackingAuthorization : \(status.rawValue)")
                        }
                    })
                }
            }
        }
        
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func initXlogs() {
        initXlogger(.debug, releaseLevel: .warning, prefix: "logs")
    }
    
    func configHttps() -> Void {
        if YXConstant.targetMode() == .prd || YXConstant.targetMode() == .prd_hk {
            var certData : Data? = nil
            
            if YXUpdateManager.shared.certificateCached(), let url = YXUpdateManager.shared.certificateFile() {
                // 先检查本地有没有缓存证书
                certData = try? Data.init(contentsOf: url)
            } else if let url = Bundle.main.url(forResource: "certificate", withExtension: "cer") {
                // 如果没有本地证书, 则读取内置证书
                certData = try? Data.init(contentsOf: url)
            }
            
            if let certData =  certData {
                let config = YTKNetworkConfig.shared()
                let securityPolicy = AFSecurityPolicy.init(pinningMode: .publicKey)
                securityPolicy.allowInvalidCertificates = true
                securityPolicy.validatesDomainName = true
                securityPolicy.pinnedCertificates = [certData]
                config.securityPolicy = securityPolicy
            }
        }
    }
    
    private func initQMUI() -> Void {                        
        QDCommonUI.renderGlobalAppearances()
    }
    
    func initSDWebImage() -> Void {
        let WebPCoder = SDImageWebPCoder.shared
        SDImageCodersManager.shared.addCoder(WebPCoder)
        SDWebImageDownloader.shared.setValue("image/webp,image/*,*/*;q=0.8", forHTTPHeaderField:"Accept")
        SDWebImageDownloader.shared.setValue("www.yxzq.com", forHTTPHeaderField: "Referer")
        SDImageCache.shared.config.maxMemoryCost = 20 * 4 * 1024 * 1024
    }
    
    func initTXLite() -> Void {
        TXLiveBase.setLicenceURL("http://license.vod2.myqcloud.com/license/v1/5593ffa259671117aa535e6cf07e3a7b/TXLiveSDK.licence", key: "96a346d172b9a8dae5dae3b1d4da6bb5")
        TXLiveBase.setConsoleEnabled(true)
    }
    
    //MARK: resetRootView、tab跳转方法
    func initNotifications() {
        _ = NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: YXUserManager.notiUpdateResetRootView))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (notification) in
                guard let `self` = self else { return }
                
                
                // 这里使用重新初始化的原因是在于，如果是切换语言时，需要让页面重新初始化，才会成功的切换语言
                self.initRootViewController(navigator: self.navigator)
            
                
                if let userInfo = notification.userInfo {
                    self.resetRootView(with: userInfo)
                }
                
                
                
                if let object = notification.object as? Dictionary<String, Any> {
                    if let tip = object["preferenceSet"] as? String, tip.isEmpty == false {
                        QMUITips.showSucceed(tip)
                    }
                }
                
                // 快捷导航是单例，切换语言后需要重新设置语言才生效
//                YXShortCutsManager.shareInstance.shortCutsVC.reSetLanguage()
            })
        
        _ = NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: YXUserManager.notiLogin))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (ntf) in
                guard let `self` = self else { return }

                self.updateTabBar()
            })

        _ = NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: YXUserManager.notiLoginOut))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (ntf) in
                guard let `self` = self else { return }

                self.updateTabBar()
            })
        
        _ = NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: YXUserManager.notiUpdateUserInfo))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (ntf) in
                guard let `self` = self else { return }

                self.updateTabBar()
            })
        
        _ = NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: YXUserManager.notiLogoutbroker))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (ntf) in
                guard let `self` = self else { return }

                self.updateTabBar()
            })
        
        _ = NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: YXUserManager.notiLoginbroker))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (ntf) in
                guard let `self` = self else { return }

                self.updateTabBar()
            })
        
//        _ = NotificationCenter.default.rx
//            .notification(NSNotification.Name.init(YXGlobalConfigManager.shareInstance.kYXFilterModuleNotification))
//            .takeUntil(self.rx.deallocated)
//            .subscribe(onNext: {[weak self] ntf in
//                guard let `self` = self else { return }
//                if let tabBar = self.tab {
//                    let show = tabBar.canShowSmartTab()
//                    if show != tabBar.showSmartTab {
//                        self.tab?.showSmartTab = show
//                        self.initRootViewController(navigator: self.navigator)
//                    }
//                }
//            })
        
        // 解決在iOS 12以上的版本中，出現從H5頁面中播放視頻后，返回原生頁面沒有狀態欄的問題
//        if #available(iOS 12.0, *) {
//            _ = NotificationCenter.default.rx
//                .notification(UIWindow.didBecomeHiddenNotification)
//                .takeUntil(self.rx.deallocated)
//                .subscribe(onNext: { (ntf) in
//                    if let win = ntf.object as? UIWindow {
//                        if let rootVC = win.rootViewController {
//                            let vcs = rootVC.children
//                            if (vcs.first is AVPlayerViewController) {
//                                UIApplication.shared.setStatusBarHidden(false, with: .none)
//                            }
//                        }
//                    }
//                })
//        }
    }
    
    private func resetRootView(with userInfo: [AnyHashable : Any]) {
        
        // 特别说明：此处延时0.01秒，是为了解决APPINCN-1360问题
        // 真实原因暂未找到，不知道为何直接设置selectedIndex会导致tabbar消失
        guard let tab = self.tab else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {
            if let index = userInfo["index"] as? YXTabIndex {
                tab.selectedIndex = index.rawValue //切换tabbar
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {
                    tab.selectedIndex = index.rawValue
                })
            } else {
                tab.selectedIndex = 0
            }
        })
    }
    
    func updateTabBar() {
        let tabbarViewController = self.tab

        let tradeIndex = YXTabIndex.holding.rawValue //3
        
        if let viewControllers = tabbarViewController?.viewControllers,
            viewControllers.count > YXTabIndex.holding.rawValue {
            if let tradeNC = viewControllers[tradeIndex] as? UINavigationController {
                let tradeRootVC = tradeNC.viewControllers[0]
                if YXUserManager.canTrade() {
                    // 已开户已入金, 则是：允许交易
                    if tradeRootVC is YXAccountAssetViewController{
                    } else {
                        let vc = YXAccountAssetViewController()
                        vc.viewModel.navigator = navigator
                        tradeNC.setViewControllers([vc], animated: false)
                    }
                } else {
                    // 未开户，则是：等待开户
                    if !(tradeRootVC is YXOpenAccountGuideViewController) {
                        let vc = YXOpenAccountGuideViewController.instantiate(withViewModel: YXOpenAccountGuideViewModel(dictionary: [:]), andServices: self.appServices, andNavigator: navigator)
                        tradeNC.setViewControllers([vc], animated: false)
                    }
                }
                tabbarViewController?.updateTabarTitle()
                let tabbarSelectIndex = tabbarViewController?.selectedIndex
                tabbarViewController?.selectedIndex = tabbarSelectIndex ?? 0
            }
        }
    }
    //添加白名单
    func addMLeakFinderWhitelist() {
        // TODO: YXReportViewController 发布成功后 pop 会弹 memory leak alert ，影响 presen 盲盒抽奖测试流程，暂时屏蔽
        NSObject.addClassNames(toWhitelist: [NSStringFromClass(UITextField.self), "YXReportViewController"])
    }
}

struct AppServices:HasYXPreferencesService, HasYXQuotesDataService, HasYXUserService, HasYXLoginService, HasYXAggregationService, HasYXStockSTService, HasYXNewsService, HasYXWebService, HasYXOptionalService, HasYXStockOrderService, HasYXTradeService, HasYXGlobalConfigService, HasYXMessageCenterService, HasYXV2QuoteService, HasYXStockAnalyzeService, HasYXInformationService, HasYXSearchService,HasYXMarketService,HasYXLearningService {
    let preferencesService: YXPreferencesService
    let userService: YXUserService
    let loginService: YXLoginService
    let newsService: YXNewsService
    let quotesDataService: YXQuotesDataService
    let aggregationService: YXAggregationService
    let stockSTService: YXStockSTService
    let webService: YXWebService
    let optionalService: YXOptionalService
    let stockOrderService: YXStockOrderService
    let tradeService: YXTradeService
    let globalConfigService: YXGlobalConfigService
    let messageCenterService: YXMessageCenterService
    let v2QuoteService: YXV2QuoteService
    let stockAnalyzeService: YXStockAnalyzeService
    let infomationService: YXInformationService
    let searchService: YXSearchService
    let marketService: YXMarketService
    let learningService: YXLearningService

}
