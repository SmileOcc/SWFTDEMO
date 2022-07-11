//
//  YXPopManager.swift
//  uSmartOversea
//
//  Created by ellison on 2019/3/19.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import YXKit

//弹窗的状态
enum YXPopAlertStatus {
    case notShow            //还没展示
    case showed             //已经展示
    case requestFailed      //请求失败
}

@objc enum YXAppLaunchPopType: Int {
    case ipoNewStock = 1 //新股弹窗
    case giveScore = 2  //app评分
    case proChange =  3 //pro等级
}

//sg的popmanger
class YXPopManager: NSObject {
    public static let YXAdvertiseDidShowCache =  "YXAdvertiseDidShowCache"// 闪屏广告是否展示
    @objc static  let kNotificationName = "YXPopDidShowHighPopNotification"
    public static let kYXFristInstallCache =  "kYXFristInstallCache"// 是否第一次
    public static let kYXPopDayCache =  "kYXPopDayCache"// 缓存展示时日期
    
    var appLaunchTypes: [YXAppLaunchPopType] = []
    var appHttpNextType: YXAppLaunchPopType = .ipoNewStock

    @objc static let shared = YXPopManager()
    
    let messageCenterService = YXMessageCenterService.shared
    
    static let recodeIdentify = "yxpop"
    //show_page：1自选,2策略,3账户 4、个人中心
    static let showPageMarket = 1
    static let showPageStategy = 2
    static let showPageAccount = 3
    static let showPageUserCenter = 4
    
    static let showPageFund = 999
    static let showPageOptional = 999

    var optionalAlertStatus: YXPopAlertStatus = .notShow
    var userCenterAlertStatus: YXPopAlertStatus = .notShow
    var fundAlertStatus: YXPopAlertStatus = .notShow
    var marketAlertStatus: YXPopAlertStatus = .notShow
    var stategyAlertStatus: YXPopAlertStatus = .notShow
    var accountAlertStatus: YXPopAlertStatus = .notShow

    var optionalCacheModel: YXCommonAdModel?      //暂时缓存
    var userCenterCacheModel: YXCommonAdModel?    //暂时缓存
    var fundCacheModel: YXCommonAdModel?          //暂时缓存
    var marketCacheModel: YXCommonAdModel?    //暂时缓存
    var stategyCacheModel: YXCommonAdModel?          //暂时缓存
    var accountCacheModel: YXCommonAdModel?          //暂时缓存

    var ipoNewStockHandle:YXNewStockIPOAlertManager = YXNewStockIPOAlertManager()  //新股弹窗的处理
    @objc var giveScoreHandle: YXGiveScoreAlertManager = YXGiveScoreAlertManager()
    var proLevelUpHandle: YXProLevelUpPopHandel = YXProLevelUpPopHandel()
    var newsPopHandle: YXNewsPopHandle = YXNewsPopHandle()
    var newsList: [YXNoticeStruct] = []
    
    var selectStockPopHandle = YXSeleceStockPopHandle()
    
    var currentVC:UIViewController?
    var subVcIndex:Int = 0
    
    let disposeBag = DisposeBag()
    
    private override init() {
        super.init()
        
        subscribLaunchPop()
        
    }
    
    override func copy() -> Any {
        self
    }
    
    override func mutableCopy() -> Any {
        self
    }
    
    func isFristInstall() -> Bool {
       let statu = MMKV.default().bool(forKey: YXPopManager.kYXFristInstallCache)
       return statu
        
    }
    
    func didInstalled() {
        MMKV.default().set(false, forKey: YXPopManager.kYXFristInstallCache)
    }
    
    func saveShowedAd(_ showPage:Int ,_ adId:Int)  {
        let keepKey =  YXPopManager.recodeIdentify + "_\(showPage)" + "\(YXUserManager.userUUID())"
        if let recodeArray:NSMutableArray = MMKV.default().object(of: NSMutableArray.self, forKey: keepKey) as? NSMutableArray {
            recodeArray.add(adId as Any)
            MMKV.default().set(recodeArray, forKey:keepKey)
        }else {
            let recodeArray = NSMutableArray.init(capacity: 1)
            recodeArray.add(adId as Any)
            MMKV.default().set(recodeArray, forKey:keepKey)
        }
    }
    
    func filterShowModel(_ showPage:Int ,_ popModel:[YXCommonAdModel]?) -> YXCommonAdModel? {

        if popModel?.count == 0 {
            return nil
        }
        
        let keepKey =  YXPopManager.recodeIdentify + "_\(showPage)" + "\(YXUserManager.userUUID())"
        let dateFormatter = DateFormatter.en_US_POSIX()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let now = Date()

        let lastDateString = MMKV.default().string(forKey: YXPopManager.kYXPopDayCache + String(showPage))
        let nowDateString = dateFormatter.string(from: now)

        //一天只展示一次
        if lastDateString == nowDateString {

            if let recodeArray:NSMutableArray = MMKV.default().object(of: NSMutableArray.self, forKey: keepKey) as? NSMutableArray {
                var showMode:YXCommonAdModel?
                
                let popList = popModel?.sorted { m1, m2 in
                    m1.priority! < m2.priority!
                }
                
                for itm in popList ?? [] {
                    if recodeArray.contains(NSNumber.init(value: itm.bannerID ?? 0)) == false {
                        showMode = itm
                        break
                    }
                }
                return showMode
            }else {
                let popList = popModel?.sorted { m1, m2 in
                    m1.priority! < m2.priority!
                }
                return popList?.first
            }
        }else {
            MMKV.default().set(nowDateString, forKey: YXPopManager.kYXPopDayCache + String(showPage)) 
            let emptyArr = NSMutableArray()
            MMKV.default().set(emptyArr, forKey:keepKey)
            let popList = popModel?.sorted { m1, m2 in
                m1.priority! < m2.priority!
            }
            if  let showModel = popList?.first {
                return showModel
            }
            return nil
        }
    }
    
     func showPop(noticeModel: YXCommonAdModel, vc: UIViewController,showPage:Int) {
        let showSplash = MMKV.default().bool(forKey: YXPopManager.YXAdvertiseDidShowCache)
        let fristInstall = isFristInstall()
        
        if showSplash == true ||  fristInstall == true || YXUpdateManager.shared.finishedUpdatePop == false {
                return
        }
        //展示过，也要展示，直到全部点过
        if showPage == YXPopManager.showPageOptional {
            optionalAlertStatus = .showed
            optionalCacheModel = nil
        } else if showPage == YXPopManager.showPageUserCenter {
            userCenterAlertStatus = .showed
            userCenterCacheModel = nil
        } else if showPage == YXPopManager.showPageFund {
            fundAlertStatus = .showed
            fundCacheModel = nil
        } else if showPage == YXPopManager.showPageMarket{
            marketAlertStatus = .showed
            marketCacheModel = nil
        }else if showPage == YXPopManager.showPageStategy{
            stategyAlertStatus = .showed
            stategyCacheModel = nil
        }else if showPage == YXPopManager.showPageAccount{
            accountAlertStatus = .showed
            accountCacheModel = nil
        }
        //保存展示过的弹框
        if let imgUrl = noticeModel.pictureURL, imgUrl.count > 0 {
            self.saveShowedAd(showPage, noticeModel.bannerID ?? 0)
                //背景
                let bgView = UIView()
                bgView.backgroundColor = .clear
                //图片
                let popView = YXPopImageView(frame: .zero)
                let transformer = SDImageResizingTransformer(size: CGSize(width: popView.frame.size.width * UIScreen.main.scale, height: popView.frame.size.height * UIScreen.main.scale), scaleMode: .aspectFill)
                
                popView.sd_setImage(with: URL.init(string: imgUrl), placeholderImage: UIImage(named: "pop_placeholder"), options: [], context: [SDWebImageContextOption.imageTransformer: transformer])
                bgView.addSubview(popView)
                popView.snp.makeConstraints { (make) in
                    make.left.top.right.equalToSuperview()
                }
                popView.layer.cornerRadius = 8
                popView.clipsToBounds = true
                
                //关闭按钮
                let button = UIButton(type: .custom)
                button.setImage(UIImage(named: "pop_close"), for: .normal)
                bgView.addSubview(button)
                
                button.snp.makeConstraints { (make) in
                    make.width.height.equalTo(28)
                    make.top.equalTo(popView.snp.bottom).offset(32)
                    make.centerX.equalToSuperview()
                    make.bottom.equalToSuperview()
                }
                
                bgView.frame = CGRect(x: 0, y: 0, width: popView.frame.size.width, height: popView.frame.size.height + 32 + 28)
                
                //使用showInWindow()，不再使用show(in: vc)，为解决点击「立即认购」时，没有跳转的问题；
                //bgView.show(in: vc)
                UIView.hideOldShowAlertView()
                bgView.showInWindow()
                
                //点击跳转响应
                let tap = UITapGestureRecognizer()
                tap.rx.event.asObservable().subscribe(onNext: {[weak bgView] (recognizer) in
                 //   MMKV.default().double(forKey: YXPopManager.recodeIdentify + "_\(showPage)", defaultValue: 0)
                    if let isJumpPage = Int(noticeModel.jumpType ?? "0"), isJumpPage == 1 {
                        if let jumpPageUrl = noticeModel.jumpURL, jumpPageUrl.count > 0 {
                            bgView?.hide()
                            YXGoToNativeManager.shared.gotoNativeViewController(withUrlString: jumpPageUrl)
                        }
                    }else if let isJumpPage = Int(noticeModel.jumpType ?? "0"), isJumpPage == 2{
                        if let jumpPageUrl = noticeModel.jumpURL, jumpPageUrl.count > 0 {
                            bgView?.hide()
                            YXWebViewModel.pushToWebVC(jumpPageUrl)
                        }
                    }
                }).disposed(by: disposeBag)
                popView.addGestureRecognizer(tap)
                //关闭响应
                button.rx.tap.asObservable().subscribe(onNext: {[weak bgView] (_) in
                    bgView?.hide()
                   
                }).disposed(by: self.disposeBag)
            }
    }
    
    func showSeleceStockPop(noticeModel: YXCommonAdModel, vc: UIViewController,showPage:Int) {
       let showSplash = MMKV.default().bool(forKey: YXPopManager.YXAdvertiseDidShowCache)
       let fristInstall = isFristInstall()
       
       if showSplash == true ||  fristInstall == true || YXUpdateManager.shared.finishedUpdatePop == false {
               return
       }
       if showPage == YXPopManager.showPageOptional {
            optionalAlertStatus = .showed
           optionalCacheModel = nil
       } else if showPage == YXPopManager.showPageUserCenter {
        userCenterAlertStatus = .showed
           userCenterCacheModel = nil
       } else if showPage == YXPopManager.showPageFund {
            fundAlertStatus = .showed
           fundCacheModel = nil
       } else if showPage == YXPopManager.showPageMarket{
            marketAlertStatus = .showed
           marketCacheModel = nil
       }else if showPage == YXPopManager.showPageStategy{
            stategyAlertStatus = .showed
           stategyCacheModel = nil
       }else if showPage == YXPopManager.showPageAccount{
        accountAlertStatus = .showed
        accountCacheModel = nil
       }
        
        var modelList: [RecommendStockModel]? = noticeModel.recommendMsg

        if modelList?.count == 0 {
            return
        }
        //保存展示过的弹框
        self.saveShowedAd(showPage, noticeModel.bannerID ?? 0)
//        var showList: [RecommendStockModel] = []
//        modelList?.forEach { (recommendStockModel) in
//            if !YXSecuGroupManager.shareInstance().allSecuGroup.list.contains(where: { ($0.market + $0.symbol) == recommendStockModel.symbol }) {
//                showList.append(recommendStockModel)
//            }
//        }
        
        //背景
        let bgView = UIView()
        bgView.backgroundColor = .clear
        
        let alertView = YXSeleceStockPopAlertView(frame: .zero, modelList: modelList ?? [])
        alertView.addLikeClosure = { [weak bgView] (showhub)  in
            let str = String(format: YXLanguageUtility.kLang(key: "tips_add_stock_success"), "ALL")
            if showhub {
                YXProgressHUD.showMessage(str)
            }
            bgView?.hide()
        }
        
        bgView.addSubview(alertView)
        
        alertView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(uniHorLength(285))
            $0.height.equalTo(412)
        }
        
//        let logoImageView = UIImageView(image: UIImage(named: "selectStockLogo"))
//        bgView.addSubview(logoImageView)
//        logoImageView.snp.makeConstraints {
//            $0.trailing.equalTo(alertView).offset(-21)
//            $0.top.equalTo(alertView.snp.top).offset(-22)
//        }
        
        //关闭按钮
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "pop_close"), for: .normal)
        bgView.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.width.height.equalTo(30)
            make.top.equalTo(alertView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        bgView.frame = UIScreen.main.bounds
        UIView.hideOldShowAlertView()
        bgView.showInWindow()
        
        //关闭响应
        button.rx.tap.asObservable().subscribe(onNext: { [weak bgView] (_) in
            bgView?.hide()
        }).disposed(by: self.rx.disposeBag)
        
   }

    
    
    @objc func checkPop(with showPage: Int, vc: UIViewController) {
        var adtype = YXNewsAdType.selfStock
        if showPage == YXPopManager.showPageOptional {
            // 只执行一次，防止resetRootView时，出现再次提示
            adtype = YXNewsAdType.selfStock
            if optionalAlertStatus == .showed {
                return
            }
        } else if showPage == YXPopManager.showPageUserCenter {
            //只执行一次，防止resetRootView时，出现再次提示
            adtype = YXNewsAdType.personalCenterHome
            if userCenterAlertStatus == .showed {
                return
            }
        } else if showPage == YXPopManager.showPageFund {
            //只执行一次，防止resetRootView时，出现再次提示
            if fundAlertStatus == .showed {
                return
            }
        }else if showPage == YXPopManager.showPageMarket {
            //只执行一次，防止resetRootView时，出现再次提示
            adtype = YXNewsAdType.maket
            if marketAlertStatus == .showed {
                return
            }
        }else if showPage == YXPopManager.showPageStategy {
            //只执行一次，防止resetRootView时，出现再次提示
            adtype = YXNewsAdType.stockStrategy
            if stategyAlertStatus == .showed {
                return
            }
        }else if showPage == YXPopManager.showPageAccount{
            adtype = YXNewsAdType.account
            if accountAlertStatus == .showed {
                return
            }
        }
        if let appDelegate = YXConstant.sharedAppDelegate as? YXAppDelegate {
            /*news-configserver -- 弹窗广告
             post请求
            */
            appDelegate.appServices.newsService.request(.getflowwindow(hasRead: [], pageId: showPage), response:{[weak self]  (response) in
                guard let `self` = self else { return }
                var hasPopData: Bool = false

                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        if let model = result.data {
                            if let model = self.filterShowModel(showPage, model.dataList) {
                                hasPopData = true
                                if showPage == YXPopManager.showPageOptional {
                                    if UIViewController.current().isKind(of: YXOptionalViewController.self) || UIViewController.current().isKind(of: YXMarketViewController.self) {
                                        if model.adType == 1{
                                            self.showPop(noticeModel: model,vc:vc,showPage:showPage)
                                        }  else if model.adType == 2 {
                                            self.showSeleceStockPop(noticeModel: model, vc: vc, showPage: showPage)
                                        }
                                    } else {
                                        self.optionalCacheModel = model
                                    }
                                } else if showPage == YXPopManager.showPageUserCenter {
                                    if UIViewController.current().isKind(of: YXUserCenterViewController.self) {
                                        if model.adType == 1{
                                            self.showPop(noticeModel: model,vc:vc,showPage:showPage)
                                        } else if model.adType == 2 {
                                            self.showSeleceStockPop(noticeModel: model, vc: vc, showPage: showPage)

                                        }
                                    } else {
                                        self.userCenterCacheModel = model
                                    }
                                } else if showPage == YXPopManager.showPageFund {
                                    if UIViewController.current().isKind(of: YXFundWebViewController.self) {
                                        if model.adType == 1{
                                            self.showPop(noticeModel: model,vc:vc,showPage:showPage)
                                        }  else if model.adType == 2 {
                                            self.showSeleceStockPop(noticeModel: model, vc: vc, showPage: showPage)
                                        }
                                    } else {
                                        self.fundCacheModel = model
                                    }
                                }else if showPage == YXPopManager.showPageMarket {
                                    if UIViewController.current().isKind(of: YXMarketViewController.self) {
                                        if model.adType == 1{
                                            self.showPop(noticeModel: model,vc:vc,showPage:showPage)
                                        }  else if model.adType == 2 {
                                            self.showSeleceStockPop(noticeModel: model, vc: vc, showPage: showPage)
                                        }
                                    } else {
                                        self.marketCacheModel = model
                                    }
                                }else if showPage == YXPopManager.showPageStategy {
                                    if UIViewController.current().isKind(of: YXDiscoverViewController.self) {
                                        if model.adType == 1{
                                            self.showPop(noticeModel: model,vc:vc,showPage:showPage)
                                        }  else if model.adType == 2 {
                                            self.showSeleceStockPop(noticeModel: model, vc: vc, showPage: showPage)
                                        }
//                                        self.showSeleceStockPop(noticeModel: model, vc: vc, showPage: showPage)


                                    } else {
                                        self.stategyCacheModel = model
                                    }
                                }else if showPage == YXPopManager.showPageAccount {
                                    if UIViewController.current().isKind(of: YXAccountAssetViewController.self) ||
                                        UIViewController.current().isKind(of: YXOpenAccountGuideViewController.self){
                                        if model.adType == 1{
                                            self.showPop(noticeModel: model,vc:vc,showPage:showPage)
                                        }  else if model.adType == 2 {
                                            self.showSeleceStockPop(noticeModel: model, vc: vc, showPage: showPage)
                                        }
                                    } else {
                                        self.stategyCacheModel = model
                                    }
                                }
                            }
                        }
                    default:
                        log(.debug, tag: kNetwork, content: "get pop msg not success")
                    }
                case .failed(_):
                    YXProgressHUD.showError(YXLanguageUtility.kLang(key: "common_net_error"))
                }
                
                if showPage == YXPopManager.showPageMarket {
                    if hasPopData == false { //当没有弹窗广告和自选推荐广告时，才触发新股、评分、权限改变等弹窗，目前sg只有评分弹窗，没有新股推荐和pro权限弹窗
                        self.marketAlertStatus = .requestFailed
                        self.checkSystemIPOAlert(with: vc)
                    }
                }
                
                }as YXResultResponse<YXPopAdModel>).disposed(by: YXUserManager.shared().disposeBag)
        }
        
        //历史遗留的逻辑，注释提供参考
        //        if let appDelegate = YXConstant.sharedAppDelegate as? YXAppDelegate {
        //            /*news-configserver -- 广告
        //             get请求
        //            */
        //            appDelegate.appServices.newsService.request(.flowAd(id: adtype), response: { [weak self] (response) in
        //                guard let `self` = self else { return }
        //
        //                var hasPopData: Bool = false
        //
        //                switch response {
        //                case .success(let result, let code):
        //                    switch code {
        //                    case .success?:
        //                        if let model = result.data {
        //
        //                            if let model = self.filterShowModel(showPage, model) {
        //
        //                                hasPopData = true
        //                                if showPage == YXPopManager.showPageOptional {
        //                                    if UIViewController.current().isKind(of: YXOptionalViewController.self){
        //                                        self.showPop(noticeModel: model,vc:vc,showPage:showPage)
        //                                        self.optionalCacheModel = model
        //                                    } else {
        //                                        self.optionalCacheModel = model
        //                                    }
        //                                } else if showPage == YXPopManager.showPageUserCenter {
        //                                    if UIViewController.current().isKind(of: YXUserCenterViewController.self) {
        //                                        self.showPop(noticeModel: model,vc:vc,showPage:showPage)
        //                                    } else {
        //                                        self.userCenterCacheModel = model
        //                                    }
        //                                } else if showPage == YXPopManager.showPageFund {
        //                                    if UIViewController.current().isKind(of: YXFundWebViewController.self) {
        //                                        self.showPop(noticeModel: model, vc:vc, showPage:showPage)
        //                                    } else {
        //                                        self.fundCacheModel = model
        //                                    }
        //                                }else if showPage == YXPopManager.showPageMarket {
        //                                    if UIViewController.current().isKind(of: YXMarketViewController.self) {
        //                                        self.showPop(noticeModel: model, vc:vc, showPage:showPage)
        //                                    } else {
        //                                        self.marketCacheModel = model
        //                                    }
        //                                }else if showPage == YXPopManager.showPageStategy {
        //                                    if UIViewController.current().isKind(of: YXStockSTWebviewController.self) {
        //                                        self.showPop(noticeModel: model, vc:vc, showPage:showPage)
        //                                    } else {
        //                                        self.stategyCacheModel = model
        //                                    }
        //                                }else if showPage == YXPopManager.showPageAccount {
        //                                    if UIViewController.current().isKind(of: YXAccountAssetViewController.self) || vc is YXOpenAccountGuideViewController {
        //                                        self.showPop(noticeModel: model, vc:vc, showPage:showPage)
        //                                    } else {
        //                                        self.stategyCacheModel = model
        //                                    }
        //                                }
        //                            }
        //                        }
        //                    default:
        //                        log(.debug, tag: kNetwork, content: "get pop msg not success")
        //                    }
        //                case .failed(_):
        //                    log(.debug, tag: kNetwork, content: "get pop msg failed")
        //                }
        //
        //                if showPage == YXPopManager.showPageOptional {
        //                    if hasPopData == false {
        //                        self.optionalAlertStatus = .requestFailed
        //                        self.checkSystemIPOAlert(with: vc)
        //                    }
        //                }
        //
        //            } as YXResultResponse<YXPopAdModel>).disposed(by: self.disposeBag)
        //        }
                
    }
    
    
    @objc func checkSystemIPOAlert(with vc: UIViewController) {
        //先不检测 不调用checkIPOAlert函数，因为sg没有ipo新股弹窗，直接onNext到评分弹窗
//        YXNewStockIPOAlertManager.shared.checkIPOAlert(with: vc)
        
        ipoNewStockHandle.ipoNewStockSubject.onNext(true)
    }
    
    //检查Pop的弹窗状态
    @objc func checkPopShowStatus(with showPage:Int,vc:UIViewController) {
        let showSplash = MMKV.default().bool(forKey: YXPopManager.YXAdvertiseDidShowCache)
        let fristInstall = isFristInstall()
        if showSplash == true || fristInstall == true || YXUpdateManager.shared.finishedUpdatePop == false {
            return
        }
        //弹窗还没有展示出来
        if showPage == YXPopManager.showPageOptional {
            if UIViewController.current().isKind(of: YXOptionalViewController.self) {
                switch self.optionalAlertStatus {
                case .notShow:
                    if let cache = self.optionalCacheModel {
                        if cache.adType == 1{
                            self.showPop(noticeModel: cache, vc: vc, showPage:showPage)
                        }  else if cache.adType == 2 {
                            self.showSeleceStockPop(noticeModel: cache, vc: vc, showPage: showPage)
                        }
                    }
                    break
                case .requestFailed:
                    break
                default:
                    break
                }
            }
        } else if showPage == YXPopManager.showPageUserCenter {
            if UIViewController.current().isKind(of: YXUserCenterViewController.self) {
                switch self.userCenterAlertStatus {
                case .notShow:
                    if let cache = self.userCenterCacheModel {
                        if cache.adType == 1{
                            self.showPop(noticeModel: cache, vc: vc, showPage:showPage)
                        }  else if cache.adType == 2 {
                            self.showSeleceStockPop(noticeModel: cache, vc: vc, showPage: showPage)
                        }
                    }
                    break
                case .requestFailed:
                    break
                default:
                    break
                }
            }
        } else if showPage == YXPopManager.showPageFund {
            if UIViewController.current().isKind(of: YXFundWebViewController.self) {
                switch self.fundAlertStatus {
                case .notShow:
                    if let cache = self.fundCacheModel {
                        if cache.adType == 1{
                            self.showPop(noticeModel: cache, vc: vc, showPage:showPage)
                        }  else if cache.adType == 2 {
                            self.showSeleceStockPop(noticeModel: cache, vc: vc, showPage: showPage)
                        }
                    }
                    break
                case .requestFailed:
                    break
                default:
                    break
                }
            }
        } else if showPage == YXPopManager.showPageMarket{
            if UIViewController.current().isKind(of: YXMarketViewController.self) {
                self.currentVC = vc
                switch self.marketAlertStatus {
                case .notShow:
                    if let cache = self.marketCacheModel {
                        if cache.adType == 1{
                            self.showPop(noticeModel: cache, vc: vc, showPage:showPage)
                        }  else if cache.adType == 2 {
                            self.showSeleceStockPop(noticeModel: cache, vc: vc, showPage: showPage)
                        }
                    }
                    break
                case .requestFailed:
                    showLaunchPopView()
                    break
                default:
                    break
                }
            }
        }else if showPage == YXPopManager.showPageStategy{
            if UIViewController.current().isKind(of: YXDiscoverViewController.self) {
                switch self.stategyAlertStatus {
                case .notShow:
                    if let cache = self.stategyCacheModel {
                        if cache.adType == 1{
                            self.showPop(noticeModel: cache, vc: vc, showPage:showPage)
                        }  else if cache.adType == 2 {
                            self.showSeleceStockPop(noticeModel: cache, vc: vc, showPage: showPage)
                        }
                    }
                    break
                case .requestFailed:
                    break
                default:
                    break
                }
            }
        }
    }
    
    //MARK:显示启动需要弹的pop //sg只有引导评分弹窗，没有新股和pro权限弹窗
    func showLaunchPopView() {
        guard let vc = self.currentVC else {
            return
        }
        if self.appLaunchTypes.count > 0 {
            let firstType: YXAppLaunchPopType = self.appLaunchTypes.first ?? .ipoNewStock
            switch firstType {
            case .ipoNewStock:
                if ipoNewStockHandle.ipoShowed == false {
//                    self.showIPONewStockPop(vc: vc)
                }
            case .giveScore:
                if giveScoreHandle.popShowed == false {
                    giveScoreHandle.showAlter(vc: vc, selectedIndex: self.subVcIndex)
                }
            case .proChange:
                if proLevelUpHandle.popShowed == false {
//                    proLevelUpHandle.showProLevelUpPop()
                }
            default:
                break
            }
        }
    }
    
    //MARK:荐股弹窗
    @objc func showSelectStockPop(vc: UIViewController) {
        if vc is YXStockSTWebviewController {
            selectStockPopHandle.showSeleceStockPop(by: .stockKing)
        } else if vc is YXAccountAssetViewController {
            selectStockPopHandle.showSeleceStockPop(by: .fund)
        } else if vc is YXUserCenterViewController {
            selectStockPopHandle.showSeleceStockPop(by: .userCenter)
        }
    }
    
    //MARK:快讯/资讯弹窗
    @objc func showNewSPop(vc: UIViewController) {
        
        guard newsPopHandle.popType == .notShow  else {
            return
        }

        let timeStamp = Int(Date().timeIntervalSince1970)
        if let model = newsList.popLast(), let startTime = model.startTime, timeStamp - Int(startTime) < 30 * 60 {
            newsPopHandle.showNewsAlertView(with: model, vc: vc)
        }
    }
    
    //MARK:新股弹窗
    func showIPONewStockPop(vc: UIViewController) {
        ipoNewStockHandle.showIPOAlertView(with: [], vc: vc)
    }
    
    //MARK:首页检查持仓分享弹窗
    func checkShowShareScorePop(vc: UIViewController) {
        if self.giveScoreHandle.onlyCheckShareScoreCodition() {
            giveScoreHandle.showAlter(vc: vc, selectedIndex: 0)
        }
    }
    
    func subscribLaunchPop() {
        ipoNewStockHandle.ipoNewStockSubject.subscribe { (isResponsed) in
            self.showLaunchPopView()
            self.nextPopRequestStep()

        }.disposed(by: disposeBag)
        
        giveScoreHandle.giveScoreSubject.subscribe { (isResponsed) in
//            self.showLaunchPopView()
            self.nextPopRequestStep()
        }.disposed(by: disposeBag)
        
        proLevelUpHandle.proLevelUpSubject.subscribe { [weak self] (isResponsed) in
            guard let `self` = self else { return }
            
            let (sameDay, _) =  YXUserManager.isTheSameDay(with: YXProLevelUpPopHandel.proLevelUpSaveKey(), cacheNow: false)
            
            if let data = self.proLevelUpHandle.data, data.popUpPicUrl.count > 0, sameDay == false {
                self.addLaunchPopType(type: .proChange)
            }
            self.showLaunchPopView()
            self.nextPopRequestStep()

        }.disposed(by: disposeBag)
        
//        selectStockPopHandle.getSeleceStockList()
    }
    
//    @objc func checkSystemIPOAlert(vc:UIViewController, selectecIndex:Int) {
//        self.subVcIndex = selectecIndex
//        self.currentVC = vc
//
//        ipoNewStockHandle.checkIPOAlert(with:vc)
//        return
//    }
    
    //MARK:评分弹窗
    func giveScoreReadyData() {
       
        giveScoreHandle.isConditionReady()
    }
    
    //MARK:Pro等级升级弹窗
    func proChangeReadyData() {
       
        proLevelUpHandle.reqProLevelUpData()
    }
    
    //添加类型
    func addLaunchPopType(type: YXAppLaunchPopType) {
        if self.appLaunchTypes.contains(type) == false {
            YXPopManager.shared.appLaunchTypes.append(type)
        }
    }
    
    //清除类型
    func removeTypeInPops(type: YXAppLaunchPopType, needShowNextPop:Bool = false) {
        let array = self.appLaunchTypes
        for (index, item) in array.enumerated() {
            if item == type {
                self.appLaunchTypes.remove(at: index)
                clearCacheData(type: type)
                if needShowNextPop {
                    showLaunchPopView()
                }
            }
        }
    }
    
    //清除相应的缓存
    func clearCacheData(type: YXAppLaunchPopType) {
        if type == .ipoNewStock {
            ipoNewStockHandle.ipoShowed = true
            ipoNewStockHandle.ipoCacheList = nil
        }else if type == .giveScore {
            giveScoreHandle.popShowed = true
        }else if type ==  .proChange {
            proLevelUpHandle.popShowed = true
            proLevelUpHandle.data = nil
        }
    }
    
    //下步要弹的数据准备
    func nextPopRequestStep() {
        let nextType:Int = self.appHttpNextType.rawValue + 1
        self.appHttpNextType = YXAppLaunchPopType.init(rawValue: nextType) ?? .ipoNewStock
        if nextType == YXAppLaunchPopType.giveScore.rawValue {
            giveScoreReadyData()
        }else if nextType == YXAppLaunchPopType.proChange.rawValue {
//            proChangeReadyData()
        }
       
    }
    
}

/* dolphin的pop管理逻辑
 class YXPopManager: NSObject {
     public static let YXAdvertiseDidShowCache =  "YXAdvertiseDidShowCache"// 闪屏广告是否展示
     @objc static  let kNotificationName = "YXPopDidShowHighPopNotification"
     public static let kYXFristInstallCache =  "kYXFristInstallCache"// 是否第一次
     public static let kYXPopDayCache =  "kYXPopDayCache"// 缓存展示时日期
     
     @objc static let shared = YXPopManager()
     
     let messageCenterService = YXMessageCenterService.shared
     
     static let recodeIdentify = "yxpop"
     //show_page：1自选,2个人中心,3基金 4。市场 5.智投
     static let showPageOptional = 1
     static let showPageUserCenter = 2
     static let showPageFund = 3
     static let showPageMarket = 4
     static let showPageStategy = 5
     
     var optionalAlertStatus: YXPopAlertStatus = .notShow
     var userCenterAlertStatus: YXPopAlertStatus = .notShow
     var fundAlertStatus: YXPopAlertStatus = .notShow
     var marketAlertStatus: YXPopAlertStatus = .notShow
     var stategyAlertStatus: YXPopAlertStatus = .notShow
     
     var optionalCacheModel: YXCommonAdModel?      //暂时缓存
     var userCenterCacheModel: YXCommonAdModel?    //暂时缓存
     var fundCacheModel: YXCommonAdModel?          //暂时缓存
     var marketCacheModel: YXCommonAdModel?    //暂时缓存
     var stategyCacheModel: YXCommonAdModel?          //暂时缓存
     
     let disposeBag = DisposeBag()
     
     private override init() {}
     
     override func copy() -> Any {
         self
     }
     
     override func mutableCopy() -> Any {
         self
     }
     
     func isFristInstall() -> Bool {
        let statu = MMKV.default().bool(forKey: YXPopManager.kYXFristInstallCache)
        return statu
         
     }
     
     func didInstalled() {
         MMKV.default().set(false, forKey: YXPopManager.kYXFristInstallCache)
     }
     
     func saveShowedAd(_ showPage:Int ,_ adId:Int)  {
         let keepKey =  YXPopManager.recodeIdentify + "_\(showPage)" + "\(YXUserManager.userUUID())"
         if let recodeArray:NSMutableArray = MMKV.default().object(of: NSMutableArray.self, forKey: keepKey) as? NSMutableArray {
             recodeArray.add(adId as Any)
             MMKV.default().set(recodeArray, forKey:keepKey)
         }else {
             let recodeArray = NSMutableArray.init(capacity: 1)
             recodeArray.add(adId as Any)
             MMKV.default().set(recodeArray, forKey:keepKey)
         }
     }
     
     func filterShowModel(_ showPage:Int ,_ popModel:YXPopAdModel) -> YXCommonAdModel? {

         if popModel.popList.count == 0 {
             return nil
         }
         
         let keepKey =  YXPopManager.recodeIdentify + "_\(showPage)" + "\(YXUserManager.userUUID())"
         let dateFormatter = DateFormatter.init()
         dateFormatter.dateFormat = "yyyy-MM-dd"
         let now = Date()

         let lastDateString = MMKV.default().string(forKey: YXPopManager.kYXPopDayCache)
         let nowDateString = dateFormatter.string(from: now)

         //一天只展示一次
         if lastDateString == nowDateString {

             if let recodeArray:NSMutableArray = MMKV.default().object(of: NSMutableArray.self, forKey: keepKey) as? NSMutableArray {
                 var showMode:YXCommonAdModel?
                 
                 let popList = popModel.popList.sorted { m1, m2 in
                     m1.priority! > m2.priority!
                 }
                 
                 for itm in popList {
                     if recodeArray.contains(NSNumber.init(value: itm.bannerID ?? 0)) == false {
                         showMode = itm
                         break
                     }
                 }
                 return showMode
             }else {
                 let popList = popModel.popList.sorted { m1, m2 in
                     m1.priority! > m2.priority!
                 }
                 return popList.first
             }
         }else {
             MMKV.default().set(nowDateString, forKey: YXPopManager.kYXPopDayCache)
             let emptyArr = NSMutableArray()
             MMKV.default().set(emptyArr, forKey:keepKey)
             let popList = popModel.popList.sorted { m1, m2 in
                 m1.priority! > m2.priority!
             }
             if  let showModel = popList.first {
                 return showModel
             }
             return nil
         }
     }
     
      func showPop(noticeModel: YXCommonAdModel, vc: UIViewController,showPage:Int) {
         let showSplash = MMKV.default().bool(forKey: YXPopManager.YXAdvertiseDidShowCache)
         let fristInstall = isFristInstall()
         
         if showSplash == true ||  fristInstall == true || YXUpdateManager.shared.finishedUpdatePop == false {
                 return
             }
             //展示过，就不再展示了
             if showPage == YXPopManager.showPageOptional {
                 optionalAlertStatus = .showed
                 optionalCacheModel = nil
             } else if showPage == YXPopManager.showPageUserCenter {
                 userCenterAlertStatus = .showed
                 userCenterCacheModel = nil
             } else if showPage == YXPopManager.showPageFund {
                 fundAlertStatus = .showed
                 fundCacheModel = nil
             } else if showPage == YXPopManager.showPageMarket{
                 marketAlertStatus = .showed
                 marketCacheModel = nil
             }else if showPage == YXPopManager.showPageStategy{
                 stategyAlertStatus = .showed
                 stategyCacheModel = nil
             }
         //保存展示过的弹框
         self.saveShowedAd(showPage, noticeModel.bannerID ?? 0)
         if let imgUrl = noticeModel.pictureURL, imgUrl.count > 0, let url = URL(string: imgUrl) {
                 //背景
                 let bgView = UIView()
                 bgView.backgroundColor = .clear
                 //图片
                 let popView = YXPopImageView(frame: .zero)
                 let transformer = SDImageResizingTransformer(size: CGSize(width: popView.frame.size.width * UIScreen.main.scale, height: popView.frame.size.height * UIScreen.main.scale), scaleMode: .aspectFill)
                 
                 popView.sd_setImage(with: url, placeholderImage: UIImage(named: "popViewPlaceholder"), options: [], context: [SDWebImageContextOption.imageTransformer: transformer])
                 bgView.addSubview(popView)
                 popView.snp.makeConstraints { (make) in
                     make.left.top.right.equalToSuperview()
                 }
                 popView.layer.cornerRadius = 8
                 popView.clipsToBounds = true
                 
                 //关闭按钮
                 let button = UIButton(type: .custom)
                 button.setImage(UIImage(named: "pop_close"), for: .normal)
                 bgView.addSubview(button)
                 
                 button.snp.makeConstraints { (make) in
                     make.width.height.equalTo(28)
                     make.top.equalTo(popView.snp.bottom).offset(32)
                     make.centerX.equalToSuperview()
                     make.bottom.equalToSuperview()
                 }
                 
                 bgView.frame = CGRect(x: 0, y: 0, width: popView.frame.size.width, height: popView.frame.size.height + 32 + 28)
                 
                 //使用showInWindow()，不再使用show(in: vc)，为解决点击「立即认购」时，没有跳转的问题；
                 //bgView.show(in: vc)
                 bgView.showInWindow()
                 
                 //点击跳转响应
                 let tap = UITapGestureRecognizer()
                 tap.rx.event.asObservable().subscribe(onNext: {[weak bgView] (recognizer) in
                  //   MMKV.default().double(forKey: YXPopManager.recodeIdentify + "_\(showPage)", defaultValue: 0)
                     if let isJumpPage = Int(noticeModel.jumpType ?? "0"), isJumpPage == 1 {
                         if let jumpPageUrl = noticeModel.jumpURL, jumpPageUrl.count > 0 {
                             bgView?.hide()
                             YXGoToNativeManager.shared.gotoNativeViewController(withUrlString: jumpPageUrl)
                         }
                     }else if let isJumpPage = Int(noticeModel.jumpType ?? "0"), isJumpPage == 2{
                         if let jumpPageUrl = noticeModel.jumpURL, jumpPageUrl.count > 0 {
                             bgView?.hide()
                             YXWebViewModel.pushToWebVC(jumpPageUrl)
                         }
                     }
                 }).disposed(by: disposeBag)
                 popView.addGestureRecognizer(tap)
                 //关闭响应
                 button.rx.tap.asObservable().subscribe(onNext: {[weak bgView] (_) in
                     bgView?.hide()
                    
                 }).disposed(by: self.disposeBag)
             }
     }
     
     @objc func checkPop(with showPage: Int, vc: UIViewController) {
         var adtype = YXNewsAdType.selfStock
         if showPage == YXPopManager.showPageOptional {
             // 只执行一次，防止resetRootView时，出现再次提示
             adtype = YXNewsAdType.selfStock
             if optionalAlertStatus == .showed {
                 return
             }
         } else if showPage == YXPopManager.showPageUserCenter {
             //只执行一次，防止resetRootView时，出现再次提示
             adtype = YXNewsAdType.personalCenterHome
             if userCenterAlertStatus == .showed {
                 return
             }
         } else if showPage == YXPopManager.showPageFund {
             //只执行一次，防止resetRootView时，出现再次提示
             if fundAlertStatus == .showed {
                 return
             }
         }else if showPage == YXPopManager.showPageMarket {
             //只执行一次，防止resetRootView时，出现再次提示
             adtype = YXNewsAdType.maket
             if marketAlertStatus == .showed {
                 return
             }
         }else if showPage == YXPopManager.showPageStategy {
             //只执行一次，防止resetRootView时，出现再次提示
             adtype = YXNewsAdType.stockStrategy
             if stategyAlertStatus == .showed {
                 return
             }
         }
         
         if let appDelegate = YXConstant.sharedAppDelegate as? YXAppDelegate {
             /*news-configserver -- 广告
              get请求
             */
             appDelegate.appServices.newsService.request(.flowAd(id: adtype), response: { [weak self] (response) in
                 guard let `self` = self else { return }
                 
                 var hasPopData: Bool = false
                 
                 switch response {
                 case .success(let result, let code):
                     switch code {
                     case .success?:
                         if let model = result.data {
                             
                             if let model = self.filterShowModel(showPage, model) {
                                 
                                 hasPopData = true
                                 if showPage == YXPopManager.showPageOptional {
                                     if UIViewController.current().isKind(of: YXOptionalViewController.self){
                                         self.showPop(noticeModel: model,vc:vc,showPage:showPage)
                                         self.optionalCacheModel = model
                                     } else {
                                         self.optionalCacheModel = model
                                     }
                                 } else if showPage == YXPopManager.showPageUserCenter {
                                     if UIViewController.current().isKind(of: YXUserCenterViewController.self) {
                                         self.showPop(noticeModel: model,vc:vc,showPage:showPage)
                                     } else {
                                         self.userCenterCacheModel = model
                                     }
                                 } else if showPage == YXPopManager.showPageFund {
                                     if UIViewController.current().isKind(of: YXFundWebViewController.self) {
                                         self.showPop(noticeModel: model, vc:vc, showPage:showPage)
                                     } else {
                                         self.fundCacheModel = model
                                     }
                                 }else if showPage == YXPopManager.showPageMarket {
                                     if UIViewController.current().isKind(of: YXMarketViewController.self) {
                                         self.showPop(noticeModel: model, vc:vc, showPage:showPage)
                                     } else {
                                         self.marketCacheModel = model
                                     }
                                 }else if showPage == YXPopManager.showPageStategy {
                                     if UIViewController.current().isKind(of: YXStockSTWebviewController.self) {
                                         self.showPop(noticeModel: model, vc:vc, showPage:showPage)
                                     } else {
                                         self.stategyCacheModel = model
                                     }
                                 }
                             }
                         }
                     default:
                         log(.debug, tag: kNetwork, content: "get pop msg not success")
                     }
                 case .failed(_):
                     log(.debug, tag: kNetwork, content: "get pop msg failed")
                 }
                 
                 if showPage == YXPopManager.showPageOptional {
                     if hasPopData == false {
                         self.optionalAlertStatus = .requestFailed
                         self.checkSystemIPOAlert(with: vc)
                     }
                 }
                 
             } as YXResultResponse<YXPopAdModel>).disposed(by: self.disposeBag)
         }
         
         
         
     }
     
     
     @objc func checkSystemIPOAlert(with vc: UIViewController) {
         YXNewStockIPOAlertManager.shared.checkIPOAlert(with: vc)
     }
     
     //检查Pop的弹窗状态
     @objc func checkPopShowStatus(with showPage:Int,vc:UIViewController) {
         let showSplash = MMKV.default().bool(forKey: YXPopManager.YXAdvertiseDidShowCache)
         let fristInstall = isFristInstall()
         if showSplash == true || fristInstall == true || YXUpdateManager.shared.finishedUpdatePop == false {
             return
         }
         //弹窗还没有展示出来
         if showPage == YXPopManager.showPageOptional {
             if UIViewController.current().isKind(of: YXOptionalViewController.self) {
                 switch self.optionalAlertStatus {
                 case .notShow:
                     if let cache = self.optionalCacheModel {
                         self.showPop(noticeModel: cache, vc: vc, showPage:showPage)
                     }
                     break
                 case .requestFailed:
                     //系统弹窗
                     let ipoSingle = YXNewStockIPOAlertManager.shared
                     if ipoSingle.ipoShowed == false {
                         if let list = ipoSingle.ipoCacheList {
                             ipoSingle.showIPOAlertView(with: list, vc: vc)
                         }
                     }
                     break
                 default:
                     break
                 }
             }
         } else if showPage == YXPopManager.showPageUserCenter {
             if UIViewController.current().isKind(of: YXUserCenterViewController.self) {
                 switch self.userCenterAlertStatus {
                 case .notShow:
                     if let cache = self.userCenterCacheModel {
                         self.showPop(noticeModel: cache, vc: vc, showPage:showPage)
                     }
                     break
                 case .requestFailed:
                     break
                 default:
                     break
                 }
             }
         } else if showPage == YXPopManager.showPageFund {
             if UIViewController.current().isKind(of: YXFundWebViewController.self) {
                 switch self.fundAlertStatus {
                 case .notShow:
                     if let cache = self.fundCacheModel {
                         self.showPop(noticeModel: cache, vc: vc, showPage:showPage)
                     }
                     break
                 case .requestFailed:
                     break
                 default:
                     break
                 }
             }
         } else if showPage == YXPopManager.showPageMarket{
             if UIViewController.current().isKind(of: YXMarketViewController.self) {
                 switch self.marketAlertStatus {
                 case .notShow:
                     if let cache = self.marketCacheModel {
                         self.showPop(noticeModel: cache, vc: vc, showPage:showPage)
                     }
                     break
                 case .requestFailed:
                     break
                 default:
                     break
                 }
             }
         }else if showPage == YXPopManager.showPageStategy{
             if UIViewController.current().isKind(of: YXStockSTWebviewController.self) {
                 switch self.stategyAlertStatus {
                 case .notShow:
                     if let cache = self.stategyCacheModel {
                         self.showPop(noticeModel: cache, vc: vc, showPage:showPage)
                     }
                     break
                 case .requestFailed:
                     break
                 default:
                     break
                 }
             }
         }
     }
 }
 */
