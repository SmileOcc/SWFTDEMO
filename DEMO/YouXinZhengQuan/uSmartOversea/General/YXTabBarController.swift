//
//  YXTabBarController.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/4/15.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import CYLTabBarController
import RxSwift
import RxCocoa
import URLNavigator
import GoogleSignIn



@objc public enum YXTabIndex: Int {
  //  case optional   = 0         // 自选股--(CN:行情，SN:報價)
    case market     = 0         // 市场
    case stockST    = 1        // 智能选股
    case holding    = 2         // 持仓或开户
    case learning   = 3         // 学习模块
    case mine       = 4         // 个人中心
    case find       = 6         // 发现
    
    var title: String {
        switch self {
//        case .optional:
//            return YXLanguageUtility.kLang(key: "tab_optional")
        case .market:
            return YXLanguageUtility.kLang(key: "tab_quote_title")
        case .stockST:
            return YXLanguageUtility.kLang(key: "tab_discover_title")
        case .holding:
            if YXUserManager.canTrade() {
                return YXLanguageUtility.kLang(key: "common_trade")
            }else {
                return YXLanguageUtility.kLang(key: "tab_open_account")
            }
        case .mine:
            return YXLanguageUtility.kLang(key: "tab_user_center")
        case .find:
            return YXLanguageUtility.kLang(key: "tab_market")
        case .learning:
            return YXLanguageUtility.kLang(key: "tab_learning")
        }
    }
}

class YXTabBarController: CYLTabBarController {
    // 是否已经展示过了广告页或引导页
    static var adFlag = false
    
    private var navigator: NavigatorServicesType?
    
    let disposeBag = DisposeBag()
    var timeCount = 3
    let timerMark = "registerCode"
    
    enum YXAccountStateType {
        // 待开户状态
        case waitOpenAccount
        
        // 待入金状态
        case waitFinishAmount
        
        // 允许交易状态
        case allowTrade
    }
    
    var titles: [String] = []
    
    var animations: [String] = []
    
    var showSmartTab = true
            
    //首页的pop是否check过
    var homePopCheckFlag: Int = 0

    init(navigator: NavigatorServicesType) {
        self.navigator = navigator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func customizeTabbarAppearance() {
                 
        self.tabBar.tintColor = UIColor.themeColor(withNormalHex: "#414FFF", andDarkColor: "#D3D4E6")
        self.tabBar.unselectedItemTintColor = QMUITheme().textColorLevel2()
        self.tabBar.backgroundColor = QMUITheme().foregroundColor()
        self.tabBar.backgroundImage = UIImage.qmui_image(with: QMUITheme().foregroundColor())
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
                        
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                
                guard UIApplication.shared.applicationState != .background else {
                    return
                }
                self.tabBar.backgroundImage = UIImage.qmui_image(with: QMUITheme().foregroundColor())
                updateTabarAnimations()
                self.selectedIndex = self.selectedIndex
                QDCommonUI.renderGlobalAppearances()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customizeTabbarAppearance()
        if !YXTabBarController.adFlag {
            self.showGuideOrAdvertiseView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //在这里处理deeplink跳转
        YXAppsFlyerService.shared.jumpDeepLink()
    }
    
    /// 更新文字和动画图(已经初始化后)
//    public func updateTabBarItems() {
//        setTitleAndImages(YXUserManager.canTrade() ? .allowTrade : .waitOpenAccount)
//        for i in 0..<titles.count {
//            let str = animations[i].themeSuffix
//            let animationView = LOTAnimationView.init(name: str)
//            animationView.frame = CGRect.init(x: 0, y: 0, width: 24, height: 24)
//            let image = UIImage.qmui_image(with: animationView)!
//
//            let path = Bundle.main.path(forResource: str, ofType: "json") ?? ""
//            let url = URL.init(fileURLWithPath: path)
//
//            self.tabBar.items?[i].title = titles[i]
//            self.tabBar.items?[i].image = image.withRenderingMode(.alwaysOriginal)
//            self.tabBar.items?[i].selectedImage = image.withRenderingMode(.alwaysOriginal)
//            self.tabBar.items?[i].cyl_tabButton.cyl_addLottieImage(withLottieURL: url, size: CGSize.init(width: 24, height: 24))
//        }
//        self.selectedIndex = self.selectedIndex
//    }
    
    func updateTabarTitle() {
        setTitleAndImages(YXUserManager.canTrade() ? .allowTrade : .waitOpenAccount)
        for i in 0..<titles.count {
            self.tabBar.items?[i].title = titles[i]

        }
    }
    
    func updateTabarAnimations() {
        setTitleAndImages(YXUserManager.canTrade() ? .allowTrade : .waitOpenAccount)
        
//        var tabBarItemsAttributes = [Dictionary<String, Any>]()
        
        for i in 0..<animations.count {
            let str = animations[i].themeSuffix
            let animationView = LOTAnimationView.init(name: str)
            animationView.frame = CGRect.init(x: 0, y: 0, width: 24, height: 24)
            let image = UIImage.qmui_image(with: animationView)!
                        
            let path = Bundle.main.path(forResource: str, ofType: "json") ?? ""
            let url = URL.init(fileURLWithPath: path)
            
            self.tabBar.items?[i].image = image.withRenderingMode(.alwaysOriginal)
            self.tabBar.items?[i].selectedImage = image.withRenderingMode(.alwaysOriginal)
            
            print("cyl_lottieAnimationView___updateTabarAnimations:  " + str)
            self.tabBar.items?[i].cyl_tabButton.cyl_addLottieImage(withLottieURL: url, size: CGSize.init(width: 24, height: 24))
            
//            let tabBarItemAttributes: Dictionary<String, Any> = [
//                CYLTabBarLottieURL: url,
//                CYLTabBarItemTitle: titles[i],
//                CYLTabBarLottieSize: NSValue.init(cgSize: CGSize.init(width: 24, height: 24)),
//                CYLTabBarItemImage: image.withRenderingMode(.alwaysOriginal),
//                CYLTabBarItemSelectedImage: image.withRenderingMode(.alwaysOriginal)
//                ] as [String : Any]
//            tabBarItemsAttributes.append(tabBarItemAttributes)

        }
//        self.tabBarItemsAttributes = tabBarItemsAttributes
    }
    
    fileprivate func setTitleAndImages(_ type: YXTabBarController.YXAccountStateType) {
        titles = [
            YXTabIndex.market.title,
            YXTabIndex.holding.title,
            YXTabIndex.learning.title,
            YXTabIndex.mine.title,
        ]
        animations = ["tab_market_animate",
                      "tab_trade_animate",
                      "tab_learning_animate",
                      "tab_mine_animate"]
        if showSmartTab {
            titles.insert(YXTabIndex.stockST.title, at: YXTabIndex.stockST.rawValue)
            animations.insert("tab_robo_animate", at: YXTabIndex.stockST.rawValue)
        }
        
        for i in 0..<titles.count {
            self.tabBar.items?[i].title = titles[i]
        }
    }
    
    ///初始化调用的方法
    func tabBarItemsAttributesForController(with type: YXAccountStateType) -> [Dictionary<String, Any>] {
        
        setTitleAndImages(type)
        
        var tabBarItemsAttributes = [Dictionary<String, Any>]()

        for i in 0..<titles.count {
            let str = animations[i].themeSuffix
            let animationView = LOTAnimationView.init(name: str)
            animationView.frame = CGRect.init(x: 0, y: 0, width: 24, height: 24)
            let image = UIImage.qmui_image(with: animationView)!
                        
            let path = Bundle.main.path(forResource: str, ofType: "json") ?? ""
            let url = URL.init(fileURLWithPath: path)
            
            let tabBarItemAttributes: Dictionary<String, Any> = [
                CYLTabBarLottieURL: url,
                CYLTabBarItemTitle: titles[i],
                CYLTabBarLottieSize: NSValue.init(cgSize: CGSize.init(width: 24, height: 24)),
                CYLTabBarItemImage: image.withRenderingMode(.alwaysOriginal),
                CYLTabBarItemSelectedImage: image.withRenderingMode(.alwaysOriginal)
                ] as [String : Any]
            tabBarItemsAttributes.append(tabBarItemAttributes)
        }
        return tabBarItemsAttributes
    }
}

//MARK: - 广告 和引导页
extension YXTabBarController {
    fileprivate func showGuideOrAdvertiseView() {
        //如果不是同一天，则清空用于存储闪屏的数组
        let (sameDay,_) = YXUserManager.isTheSameDay(with: YXUserManager.YXAdvertiseDateCache)
        if sameDay == false {
            let recodeArray = NSMutableArray.init(capacity: 0)
            MMKV.default().set(recodeArray, forKey:YXUserManager.YXSplashScreenImageHasReadCodes)
            MMKV.default().removeValue(forKey: YXUserManager.YXSplashScreenImage)
            MMKV.default().removeValue(forKey: YXUserManager.YXSplashScreenAdvertisement)
            MMKV.default().removeValue(forKey: YXUserManager.YXAdvertiseDateCache) //去掉记录的日期，重新判断是否是新的一天
        }
        
        //获取是否是 新版本app
        let isInstall = MMKV.default().bool(forKey: "YXIsInstallCacheKey", defaultValue: true) //默认为true
        if !isInstall {
            //展示广告页
//            self.showAdvertiseView()
            self.sg_showAdvertiseView()
        }
//

        // 设置已经展示过引导页或广告页
        YXTabBarController.adFlag = true

//        DispatchQueue.main.async(execute: {
//            YXUserManager.getSplashscreenAdvertisement { }
//        })
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            if let splashScreenImageHasReadCodes:NSMutableArray = MMKV.default().object(of: NSMutableArray.self, forKey: YXUserManager.YXSplashScreenImageHasReadCodes) as? NSMutableArray {

                YXUserManager.sg_getSplashscreenAdvertisement(hasRead: splashScreenImageHasReadCodes as! [String], pageId: 1) {
                        
                }
                
            } else {
                let recodeArray = NSMutableArray.init(capacity: 0)
                MMKV.default().set(recodeArray, forKey:YXUserManager.YXSplashScreenImageHasReadCodes)
                let splashScreenImageHasReadCodes:NSMutableArray? = MMKV.default().object(of: NSMutableArray.self, forKey: YXUserManager.YXSplashScreenImageHasReadCodes) as? NSMutableArray
                YXUserManager.sg_getSplashscreenAdvertisement(hasRead: splashScreenImageHasReadCodes as! [String], pageId: 1) {
                }
            }
        }
    }
    
    //sg显示 闪屏广告 逻辑
    fileprivate func sg_showAdvertiseView() {
        
        var isShowAdviertise = false //是否展示广告，默认false
        
        //一天只展示最多三次
        let (sameDay,_) = YXUserManager.isTheSameDay(with: YXUserManager.YXAdvertiseDateCache)
        if sameDay == false {
          
            //获取闪屏数组
            let advertisData = MMKV.default().data(forKey: YXUserManager.YXSplashScreenAdvertisement)
            do {
                let splash = try JSONDecoder().decode(YXSplashScreenList.self, from: advertisData ?? Data())
                let splashItem = splash.dataList?.min { //取出优先级最靠前的广告
                    $0.adPos ?? 0 < $1.adPos ?? 0
                }
                if splashItem == nil {
                    MMKV.default().removeValue(forKey: YXUserManager.YXSplashScreenImage)
                    MMKV.default().removeValue(forKey: YXUserManager.YXAdvertiseDateCache)
                    MMKV.default().removeValue(forKey: YXUserManager.YXSplashScreenAdvertisementShowing)
                    self.hqAuthority()
                    self.homeCheckPopAlertView()
                    return
                } else {
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    do {
                        let data = try encoder.encode(splashItem)
                        let mmkv = MMKV.default()
                        mmkv.set(data, forKey: YXUserManager.YXSplashScreenAdvertisementShowing)
                    } catch {
                        
                    }
                }
                let mmkv = MMKV.default()
                //取出上一次请求中保存下来的优先级最高的一张闪屏，用来展示
                let data = mmkv.data(forKey:YXUserManager.YXSplashScreenImage)
                YXPopManager.shared.didInstalled()
                
                if let advertiseImg = UIImage(data: data ?? Data()) {
                    //保存展示了闪屏
                     MMKV.default().set(true, forKey: YXPopManager.YXAdvertiseDidShowCache)
                    //展示过的闪屏要把id存起来

                    if let splashScreenImageHasReadCodes:NSMutableArray = MMKV.default().object(of: NSMutableArray.self, forKey: YXUserManager.YXSplashScreenImageHasReadCodes) as? NSMutableArray {
                        splashScreenImageHasReadCodes.add(String(splashItem?.bannerID ?? 0) as Any)
                        MMKV.default().set(splashScreenImageHasReadCodes, forKey:YXUserManager.YXSplashScreenImageHasReadCodes)
                    } else {
                        let recodeArray = NSMutableArray.init(capacity: 1)
                        if !recodeArray.contains(String(splashItem?.bannerID ?? 0)) {
                            recodeArray.add(String(splashItem?.bannerID ?? 0) as Any)
                            MMKV.default().set(recodeArray, forKey:YXUserManager.YXSplashScreenImageHasReadCodes)
                        }
                    }
                    
                    
                    isShowAdviertise = true
                    
                    let bgView = YXAdvertiseBaseView(frame: UIScreen.main.bounds, image: advertiseImg, navigator: self.navigator!)
                    self.view.addSubview(bgView)
                    
                    bgView.callBack = { [weak bgView,self] in
                        bgView?.isHidden = true
                        bgView?.removeFromSuperview()
                        MMKV.default().set(false, forKey: YXPopManager.YXAdvertiseDidShowCache)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXPopManager.kNotificationName), object: nil, userInfo:nil)
                        bgView = nil
                        self.hqAuthority()
                        self.homeCheckPopAlertView()
                    }
                }
            } catch {
                //YXAdvertiseDidShowCache 闪屏里没有要展示的数据了，表示三张闪屏都已经展示过了
                
            }
        }else {
            MMKV.default().set(false, forKey: YXPopManager.YXAdvertiseDidShowCache)
            
              //获取闪屏数组
              let advertisData = MMKV.default().data(forKey: YXUserManager.YXSplashScreenAdvertisement)
              do {
                  let splash = try JSONDecoder().decode(YXSplashScreenList.self, from: advertisData ?? Data())
                let splashItem = splash.dataList?.min { //取出优先级最靠前的广告
                    $0.adPos ?? 0 < $1.adPos ?? 0
                  }
                if splashItem == nil {
                    MMKV.default().removeValue(forKey: YXUserManager.YXSplashScreenImage)
                    MMKV.default().removeValue(forKey: YXUserManager.YXSplashScreenAdvertisementShowing)
                    self.hqAuthority()
                    self.homeCheckPopAlertView()
                    return
                } else {
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    do {
                        let data = try encoder.encode(splashItem)
                        let mmkv = MMKV.default()
                        mmkv.set(data, forKey: YXUserManager.YXSplashScreenAdvertisementShowing)
                    } catch {
                        
                    }
                }
                  let mmkv = MMKV.default()
                  //取出上一次请求中保存下来的优先级最高的一张闪屏，用来展示
                  let data = mmkv.data(forKey:YXUserManager.YXSplashScreenImage)
                  YXPopManager.shared.didInstalled()
                  
                  if let advertiseImg = UIImage(data: data ?? Data()) {
                    //保存展示了闪屏
                     MMKV.default().set(true, forKey: YXPopManager.YXAdvertiseDidShowCache)
                    
                      //展示过的闪屏要把id存起来，是同一天则不删掉
                    if let splashScreenImageHasReadCodes:NSMutableArray = MMKV.default().object(of: NSMutableArray.self, forKey: YXUserManager.YXSplashScreenImageHasReadCodes) as? NSMutableArray {
                        splashScreenImageHasReadCodes.add(String(splashItem?.bannerID ?? 0) as Any)
                        MMKV.default().set(splashScreenImageHasReadCodes, forKey:YXUserManager.YXSplashScreenImageHasReadCodes)
                    } else {
                        let recodeArray = NSMutableArray.init(capacity: 1)
                        if !recodeArray.contains(String(splashItem?.bannerID ?? 0)) {
                            recodeArray.add(String(splashItem?.bannerID ?? 0) as Any)
                            MMKV.default().set(recodeArray, forKey:YXUserManager.YXSplashScreenImageHasReadCodes)
                        }
                    }
                      
                      isShowAdviertise = true
                      
                      let bgView = YXAdvertiseBaseView(frame: UIScreen.main.bounds, image: advertiseImg, navigator: self.navigator!)
                      self.view.addSubview(bgView)
                      
                      bgView.callBack = { [weak bgView,self] in
                          bgView?.isHidden = true
                          bgView?.removeFromSuperview()
                          MMKV.default().set(false, forKey: YXPopManager.YXAdvertiseDidShowCache)
                          NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXPopManager.kNotificationName), object: nil, userInfo:nil)
                          bgView = nil
                          self.hqAuthority()
                          self.homeCheckPopAlertView()
                      }
                  }
              } catch {

              }
        }
        
        if isShowAdviertise ==  false {
            self.hqAuthority()
            self.homeCheckPopAlertView()
        }
    }

}

//MARK: - 行情权限判断
extension YXTabBarController {
    //行情权限判断
    func hqAuthority() {

    }
    /// 行情页，请求pop弹窗。需求：闪屏页后，真正在「行情」页后，才展示pop弹窗
    func homeCheckPopAlertView() {
        self.homePopCheckFlag += 1
        
        if self.viewControllers.count > 0, self.homePopCheckFlag >= 2{
            
            let NC = self.viewControllers[0]
            if let homeNC = NC as? UINavigationController {
                let homeRootVC = homeNC.viewControllers[0]
                if let home = homeRootVC as? YXMarketViewController {
                    home.checkPopAlertView()
                }
            }
        }
    }
}

extension YXTabBarController {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        var pageBtn = ""
        var appsflyerBtn = ""


        if item.title == YXLanguageUtility.kLang(key: "tab_quote_title") {
            pageBtn = "Quote_Tab"
            appsflyerBtn = "usmartsg_quotes"
        } else if item.title == YXLanguageUtility.kLang(key: "tab_discover_title") {
            pageBtn = "Discover_Tab"
            appsflyerBtn = "usmartsg_discover"
        } else if item.title == YXLanguageUtility.kLang(key: "common_trade") {
            pageBtn = "Trade_Tab"
            appsflyerBtn = "usmartsg_trade"
        } else if item.title == YXLanguageUtility.kLang(key: "tab_open_account") {
            pageBtn = "Open Account_Tab"
            appsflyerBtn = "Open Account_Tab"
        } else if item.title == YXLanguageUtility.kLang(key: "tab_user_center") {
            pageBtn = "me_tab"
            appsflyerBtn = "usmartsg_me"
        } else if item.title == YXLanguageUtility.kLang(key: "tab_learning") {
            pageBtn = "Learning_Tab"
            appsflyerBtn = "usmartsg_learning"
        }
        
        let dict = [YXSensorAnalyticsPropsConstant.PROP_VIEW_PAGE:"Main",
                    YXSensorAnalyticsPropsConstant.PROP_PAGE_MEDIA:"app",
                    YXSensorAnalyticsPropsConstant.PROP_VIEW_ACTION:"click",
                    YXSensorAnalyticsPropsConstant.PROP_PAGE_BTN:pageBtn]
        YXSensorAnalyticsTrack.track(withEvent: .viewEvent, properties: dict)

        YXAppsFlyerTracker.shared.trackEvent(name: appsflyerBtn)
    }


}
