//
//  YXMarketViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2019/12/11.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

enum YXMarketTabType {
    case none
    case watchlists
    case hk
    case us
    case cn
    case cnConnect
    case hkConnect
    case warrants
    case cryptos
    case sg
    
    var title: String {
        
        switch self {
        case .watchlists:
            return YXLanguageUtility.kLang(key: "news_watchlist")
        case .hk:
            return YXLanguageUtility.kLang(key: "community_hk_stock")
        case .sg:
            return YXLanguageUtility.kLang(key: "community_sg_stock")
        case .us:
            return YXLanguageUtility.kLang(key: "community_us_stock")
        case .cn:
            return YXLanguageUtility.kLang(key: "community_cn_stock")
        case .cnConnect:
            return YXLanguageUtility.kLang(key: "bubear_cn_connect")
        case .hkConnect:
            return YXLanguageUtility.kLang(key: "bubear_hk_connect")
        case .warrants:
            return YXLanguageUtility.kLang(key: "market_hk_warrants")
        case .cryptos:
            return YXLanguageUtility.kLang(key: "cryptos_market")
        case .none:
            return ""
        }
    }
    
    var url: String {
        switch self {
        case .watchlists:
            return YXNativeRouterConstant.GOTO_MAIN_OPTSTOCKS
        case .hk:
            return YXNativeRouterConstant.GOTO_MAIN_HKMARKET
        case .sg:
            return YXNativeRouterConstant.GOTO_MAIN_SGMARKET
        case .us:
            return YXNativeRouterConstant.GOTO_MAIN_USMARKET
        default:
            return ""
        }
    }
    
    
    var tabIndex: Int {
        switch self {
        case .watchlists:
            return 0
        case .us:
            return 1
        case .sg:
            return 2
        case .hk:
            return 3
        case .warrants:
            return 4
        case .cryptos:
            return 5
        case .cn:
            return 4
        case .cnConnect:
            return 4
        case .hkConnect:
            return 5
        case .none:
            return -1
 
        }
    }
    
    static func getType(index:Int) -> YXMarketTabType {
        
        switch index {
        case 0:
            return .watchlists
        case 1:
            return .us
        case 2:
            return .sg
        case 3:
            return .hk
        default:
            return .none
        }
    }
}

class YXMarketViewController: YXHKViewController, ViewModelBased {

    var viewModel: YXMarketViewModel!
    
    let marketCurrentTabIndexKey = "YXMarketCurrentTabIndexKey"
    
    var showCryptos = true
    //是否触发过请求
    var marketHasCheckPop = false
    lazy var tabView: YXTabView = {
        let tabLayout = YXTabLayout.default()
        tabLayout.lineHidden = false
        tabLayout.lrMargin = 4
        tabLayout.tabMargin = 0
        tabLayout.tabPadding = 8
        tabLayout.lineHeight = 4
        tabLayout.leftAlign = true
        tabLayout.lineCornerRadius = 2
        tabLayout.lineColor = QMUITheme().mainThemeColor()
        tabLayout.lineWidth = 16
        tabLayout.titleFont = .systemFont(ofSize: 16)
        tabLayout.titleSelectedFont = .systemFont(ofSize: 22, weight: .medium)
        tabLayout.titleColor = QMUITheme().textColorLevel2()
        tabLayout.titleSelectedColor = QMUITheme().textColorLevel1()
        tabLayout.isGradientTail = true
        tabLayout.gradientTailColor = QMUITheme().foregroundColor()
        let tabView = YXTabView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 44), with: tabLayout)
        tabView.delegate = self
        tabView.pageView = pageView;
        return tabView
    }()
    
    lazy var pageView: YXPageView = {
        let pageView = YXPageView(frame: view.bounds)
        pageView.useCache = true
        pageView.parentViewController = self
        return pageView
    }()
    
    lazy var hkMarketViewController: YXHKMarketViewController = {
        let vc = YXHKMarketViewController.instantiate(withViewModel: YXHKMarketViewModel(), andServices: self.viewModel.services.marketService, andNavigator: self.viewModel.navigator)
        return vc
    }()
    
    lazy var sgMarketViewController: YXSGMarketViewController = {
        let vc = YXSGMarketViewController.instantiate(withViewModel: YXSGMarketViewModel(), andServices: self.viewModel.services.marketService, andNavigator: self.viewModel.navigator)
        return vc
    }()
    
    lazy var usMarketViewController: YXUSMarketViewController = {
        let vc = YXUSMarketViewController.instantiate(withViewModel: YXUSMarketViewModel(), andServices: self.viewModel.services.marketService, andNavigator: self.viewModel.navigator)
        return vc
    }()
    
    lazy var chinaMarketViewController: YXChinaMarketViewController = {
        let vc = YXChinaMarketViewController.instantiate(withViewModel: YXChinaMarketViewModel(), andServices: self.viewModel.services.marketService, andNavigator: self.viewModel.navigator)
        return vc
    }()
    
    lazy var a_hkSouthViewController: YXA_HKMarketViewController = {
        let vm = YXA_HKMarketViewModel.init(services: viewModel.navigator, direction: .south)
        let vc = YXA_HKMarketViewController.init(viewModel: vm)
        
        return vc
    }()
    
    lazy var a_hkNorthViewController: YXA_HKMarketViewController = {
        let vm = YXA_HKMarketViewModel.init(services: viewModel.navigator, direction: .north)
        let vc = YXA_HKMarketViewController.init(viewModel: vm)
        return vc
    }()
    
    // 轮证证
//    lazy var warrantVC: YXBullBearContractViewController = {
//        let vm = YXBullBearContractViewModel.init(services: viewModel.navigator, type: .warrant)
//        let vc = YXBullBearContractViewController.init(viewModel: vm)
//        return vc
//    }()
    
    lazy var warrantVC: YXWarrantsHomeViewController = {
        let vm = YXWarrantsHomeViewModel.init(services: viewModel.navigator, params: [:])
        let vc = YXWarrantsHomeViewController.init(viewModel: vm)
        return vc
    }()
    
    lazy var cryptosVC: YXCryptosViewController = {
        let vc = YXCryptosViewController()
        return vc
    }()
    
    lazy var optionalViewController: YXOptionalViewController = {
        let optionalViewModel = YXOptionalViewModel()
        let optionalViewController = YXOptionalViewController.instantiate(withViewModel: optionalViewModel, andServices: viewModel.services, andNavigator: self.viewModel.navigator)
        return optionalViewController
    }()

    /// 请求pop弹窗
    func checkPopAlertView() {
        YXUpdateManager.shared.rx.observe(Bool.self, "finishedUpdatePop").subscribe(onNext: { [weak self] (finishedUpdatePop) in
            guard let `self` = self else { return }
            
            if finishedUpdatePop ?? false && self.marketHasCheckPop == false {
                self.marketHasCheckPop = true
                YXPopManager.shared.checkPop(with: YXPopManager.showPageMarket, vc:self)
            }
        }).disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        selectedTabWithTime()
        
        _ = NotificationCenter.default.rx
            .notification(NSNotification.Name.init(YXGlobalConfigManager.shareInstance.kYXFilterModuleNotification))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: {[weak self] ntf in
                guard let strongSelf = self else { return }
                
                let show = strongSelf.canShowCryptos()
                if show != strongSelf.showCryptos {
                    strongSelf.showCryptos = show
                    strongSelf.fetchViewControllers(true)
                }
            })
        
//        YXPopManager.shared.checkPop(with: YXPopManager.showPageMarket, vc: self)
        
        _ = NotificationCenter.default.rx.notification(Notification.Name.init(YXPopManager.kNotificationName))
            .takeUntil(self.rx.deallocated)
            .subscribe({ _ in
                //检查Pop的弹窗状态
                YXPopManager.shared.checkPopShowStatus(with: YXPopManager.showPageMarket, vc: self)
            }).disposed(by: rx.disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setTabbarVisibleIfNeed()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //检查弹框
        YXPopManager.shared.checkPopShowStatus(with: YXPopManager.showPageMarket, vc: self)
        
        YXPopManager.shared.checkShowShareScorePop(vc: self)
        //获取一级小黄条数据
        let type = YXMarketTabType.getType(index: Int(self.tabView.selectedIndex))
        self.requestNoticeData(urlStr: YXNativeRouterConstant.GOTO_QUOTES) {[weak self] datas in
            guard let `self` = self else { return }
            self.viewModel.quoteNoticeModels = nil
            if datas.count > 0 {
                self.viewModel.quoteNoticeModels = datas
            }
            self.generateStrongNoticeModels(with: type)
        } failed: {[weak self] errorMsg in
            guard let `self` = self else { return }
            self.generateStrongNoticeModels(with: type)
        }
        
    }
    
    func selectedTabWithTime() {
        tabView.reloadData()
        tabView.selectTab(at: UInt(YXMarketTabType.watchlists.tabIndex))
        
//        let date = Date()
//        var calendar = Calendar.init(identifier: .gregorian)
//        if let timeZone = TimeZone.init(identifier: "Asia/Shanghai") {
//            calendar.timeZone = timeZone
//            if let month = calendar.dateComponents(in: timeZone, from: date).month,
//               let hour = calendar.dateComponents(in: timeZone, from: date).hour {
//
//                if (month >= 3 && month <= 10 ) { // 美国夏令时 北京时间3月1号开始 21：30 - 4：00 冬令时 北京时间11月1号开始，22：30-5：00 往前五个半小时为盘前 往后4小时为盘后
//                    if (hour >= 16 || hour <= 8) {
//
//                    }else {
//                        tabView.reloadData()
//                        tabView.selectTab(at: YXMarketTabType.hk.tabIndex)
//                    }
//                } else {
//                    if (hour >= 17 || hour <= 9) {
//
//                    }else {
//                        tabView.reloadData()
//                        tabView.selectTab(at: YXMarketTabType.hk.tabIndex)
//                    }
//                }
//            }
//        }
    }
    
    func getLevel2note(with type:YXMarketTabType) {
        guard type == .watchlists || type == .hk || type == .us || type == .sg else {
            self.generateStrongNoticeModels(with: type)
            return
        }
        
        self.requestNoticeData(urlStr: type.url) { [weak self] datas in
            guard let `self` = self else { return }
            
                if type == .watchlists {
                    self.viewModel.watchlistsNoticeModels = nil
                    if datas.count > 0 {
                        self.viewModel.watchlistsNoticeModels = datas
                    }
                } else if type == .us {
                    self.viewModel.usNoticeModels = nil
                    if datas.count > 0 {
                        self.viewModel.usNoticeModels = datas
                    }
                } else if type == .hk {
                    self.viewModel.hkNoticeModels = nil
                    if datas.count > 0 {
                        self.viewModel.hkNoticeModels = datas
                    }
                } else if type == .sg {
                    self.viewModel.sgNoticeModels = nil
                    if datas.count > 0 {
                        self.viewModel.sgNoticeModels = datas
                    }
                }
            
            self.generateStrongNoticeModels(with: type)
        } failed: { errorMsg in
            self.generateStrongNoticeModels(with: type)
        }
    }
    
    func generateStrongNoticeModels(with type:YXMarketTabType)  {
        var datas:[YXNoticeModel] = []
        self.viewModel.quoteNoticeModels?.forEach{ datas.append($0) }
        switch type {
        case .watchlists:
            self.viewModel.watchlistsNoticeModels?.forEach{ datas.append($0) }
        case .us:
            self.viewModel.usNoticeModels?.forEach{ datas.append($0) }
        case .hk:
            self.viewModel.hkNoticeModels?.forEach{ datas.append($0) }
        case .sg:
            self.viewModel.sgNoticeModels?.forEach{ datas.append($0) }
        default:
            break
        }
        
        if datas.count > 0 {
            self.strongNoticeView.dataSource = datas
        } else {
            self.strongNoticeView.dataSource = []
        }
        
    }

    func bindViewModel()  {
        self.viewModel.selectIndex.subscribe {[weak self] index in
            guard let `self` = self,let tabIndex = index.element, tabIndex > (self.pageView.constraints.count - 1), tabIndex < 0 else{
                return
            }
            self.tabView.selectTab(at: UInt(tabIndex))
        }.disposed(by: disposeBag)
    }
    func setupUI() {
        
        self.showCryptos = canShowCryptos()
        fetchViewControllers()
        
        navigationItem.titleView = tabView

        let messageBtn = QMUIButton()
        messageBtn.setImage(UIImage(named: "message"), for: .normal)
        messageBtn.qmui_shouldShowUpdatesIndicator = !YXMessageButton.brokerRedIsHidden
        messageBtn.qmui_tapBlock = { [weak self] _ in
            self?.trackViewClickEvent(name: "Message_Tab")
            YXWebViewModel.pushToWebVC(YXH5Urls.YX_BROKERS_MSG_CENTER_URL())
        }
        messageBtn.rx.observeWeakly(YXMessageButton.self, "brokerRedIsHidden").subscribe {[weak messageBtn] _ in
            messageBtn?.qmui_shouldShowUpdatesIndicator = !YXMessageButton.brokerRedIsHidden
        }.disposed(by: disposeBag)
        messageBtn.widthAnchor.constraint(equalToConstant: 22).isActive = true

        let spaceItem = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spaceItem.width = 16
        
        let spaceItem12 = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spaceItem12.width = 12
        
        let searchBtn = QMUIButton()
        searchBtn.setImage(UIImage(named: "market_search"), for: .normal)
        searchBtn.qmui_tapBlock = { [weak self] _ in
            guard let `self` = self else { return }

            self.viewModel.navigator.present(YXModulePaths.aggregatedSearch.url, animated: false)
            self.trackViewClickEvent(name: "Search_Tab")
        }
        searchBtn.widthAnchor.constraint(equalToConstant: 22).isActive = true
        let searchBarButtonItem = UIBarButtonItem(customView: searchBtn)
        
        navigationItem.rightBarButtonItems = [spaceItem12, UIBarButtonItem(customView: messageBtn), spaceItem, searchBarButtonItem]

        view.addSubview(pageView)
        pageView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(self.strongNoticeView.snp.bottom);
            make.bottom.equalTo(view).offset(-YXConstant.tabBarHeight())
        }
        
    }
    
    
    func fetchViewControllers(_ needReload: Bool = false) {
        
        var titles = [YXMarketTabType.watchlists.title,
                      YXMarketTabType.us.title,
                      YXMarketTabType.sg.title,
                      YXMarketTabType.hk.title]
        
        var controllers:[UIViewController] = [optionalViewController,
                           usMarketViewController,
                           sgMarketViewController,
                           hkMarketViewController]
        
        if showCryptos {
            titles.append(YXMarketTabType.cryptos.title)
            controllers.append(cryptosVC)
        }
        
        tabView.titles = titles
        pageView.viewControllers = controllers
        
        if needReload {
            tabView.reloadData()
            pageView.reloadData()
        }
    }
    
    func canShowCryptos() -> Bool {
        if let data = MMKV.default().object(of: NSData.self, forKey: YXGlobalConfigManager.getFilterModuleKey()) as? Data,
           let model = try? JSONDecoder().decode(YXFilterModuleModel.self, from: data) {
            
            let FLAG = 0x01
            //let FLAG2 = 0x03
            if let bitValue = model.bitValue,
               bitValue & FLAG > 0 {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }
    
    override func didInitialize() {
        super.didInitialize()
        hidesBottomBarWhenPushed = false
    }
}

extension YXMarketViewController {
    @objc public override var pageName: String {
        return "Quote"
    }
}

extension YXMarketViewController: YXTabViewDelegate {
    func tabView(_ tabView: YXTabView, didSelectedItemAt index: UInt, withScrolling scrolling: Bool) {
        MMKV.default().set(UInt32(index), forKey: marketCurrentTabIndexKey)
        if index == YXMarketTabType.watchlists.tabIndex {
            self.trackViewClickEvent(name: "Watchlists_Tab")
            getLevel2note(with: YXMarketTabType.watchlists)
        } else if index == YXMarketTabType.us.tabIndex {
            self.trackViewClickEvent(name: "US_Tab")
            getLevel2note(with: YXMarketTabType.us)
        } else if index == YXMarketTabType.sg.tabIndex {
            self.trackViewClickEvent(name: "SG_Tab")
            getLevel2note(with: YXMarketTabType.sg)
        } else if index == YXMarketTabType.hk.tabIndex {
            self.trackViewClickEvent(name: "HK_Tab")
            getLevel2note(with: YXMarketTabType.hk)
        } else  if YXMarketTabType.warrants.tabIndex == index {
            trackViewClickEvent(name: "HK Warrants_Tab")
            getLevel2note(with: YXMarketTabType.none)
        } else  if YXMarketTabType.cryptos.tabIndex == index {
            trackViewClickEvent(name: "Cryptos_Tab")
            getLevel2note(with: YXMarketTabType.none)
        }
    }
}
