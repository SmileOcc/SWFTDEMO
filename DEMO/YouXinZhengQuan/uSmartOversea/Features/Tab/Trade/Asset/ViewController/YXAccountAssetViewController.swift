//
//  YXAccountAssetViewController.swift
//  uSmartOversea
//
//  Created by 覃明明 on 2021/7/6.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

@objc enum TradeRefreshType: Int {
    case allAsset = 1        //全部业务资产数据
    case singleAsset = 2     //查询客户资产首页基础数据
    case todayOrder = 3      //今日订单
    case conditonOrder = 4   //条件单（type=0）
    case smartOrder = 5      //智能订单（type=1）
}

class YXAccountAssetViewController: YXHKViewController {

    let viewModel = YXAccountAssetViewModel()

    let entranceViewHeight: CGFloat = 150
    let tabViewHeight: CGFloat = 40
    var tagTimerFlag: YXTimerFlag = 0
    var positionCount = 0
    var todayOrderCount = 0
    
    var holdViewCotnroller:YXHomeHoldViewController?
    var todayOrderViewCotnroller:YXTodayOrderViewController?

    var headerViewHeight: CGFloat = 0
    
    var tabViewTitles: [String] {
        var pTitle: String
        var tTitle: String
        if positionCount == 0 {
            pTitle = YXLanguageUtility.kLang(key: "hold_holds")
        }else {
            pTitle = YXLanguageUtility.kLang(key: "hold_holds") + " " + "(\(positionCount))"
        }
        
        if todayOrderCount == 0 {
            tTitle = YXLanguageUtility.kLang(key: "trading_today_order")
        }else {
            tTitle = YXLanguageUtility.kLang(key: "trading_today_order") + " " + "(\(todayOrderCount))"
        }
        
        return [pTitle, tTitle]
    }

    lazy var headerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: headerViewHeight))
        view.backgroundColor = QMUITheme().foregroundColor()

        view.addSubview(assetView_sg)
        view.addSubview(entranceView)

        assetView_sg.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(4)
        }
        
        entranceView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(assetView_sg.snp.bottom).offset(8)
            make.height.equalTo(entranceViewHeight)
        }

        let line = UIView()
        line.backgroundColor = UIColor.themeColor(withNormalHex: "#F8F9FC", andDarkColor: "#000000")
        view.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(8)
        }

        return view
    }()

    lazy var assetView_sg: YXAccountAssetView = {
        let view = YXAccountAssetView()

        view.tapAssetAction = { [weak self] in
            guard let `self` = self else { return }

            let vm = YXMyAssetsDetailViewModel.init(self.viewModel.moneyType)
            let context = YXNavigatable(viewModel: vm)
            self.viewModel.navigator.push(YXModulePaths.myAssetsDetail.url, context: context)
        }
        
        view.heightDidChange = { [weak self] height in
            guard let `self` = self else { return }
            self.headerViewHeight = 4 + height + 8 + self.entranceViewHeight + 8
            self.headerView.frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: self.headerViewHeight)
            self.tabPageView.reloadData()
        }
        
        view.didChoose = { [weak self] moneyType in
            self?.viewModel.moneyType = moneyType
            self?.requestData()
        }

        return view
    }()

    lazy var entranceView: YXMarketEntranceScrollCell = {
        let view = YXMarketEntranceScrollCell(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: entranceViewHeight))
        view.backgroundColor = .clear
        view.titleColor = QMUITheme().textColorLevel1()
        view.items = [
            ["title": YXLanguageUtility.kLang(key: "account_trade"), "iconName": "entrance_trade"],
            ["title": YXLanguageUtility.kLang(key: "account_all_orders"), "iconName": "entrance_transactions"],
            ["title": YXLanguageUtility.kLang(key: "hold_trade_smart_order"), "iconName": "entrance_smartorder"],
            ["title": YXLanguageUtility.kLang(key: "fractional_trading"), "iconName": "entrance_fractional_trade"],
            ["title": YXLanguageUtility.kLang(key: "account_deposit"), "iconName": "entrance_deposit"],
            ["title": YXLanguageUtility.kLang(key: "account_exchange"), "iconName": "entrance_cx"],
            ["title": YXLanguageUtility.kLang(key: "account_stock_deposit"), "iconName": "entrance_stock_deposit"],
            ["title": YXLanguageUtility.kLang(key: "share_info_more"), "iconName": "entrance_more"]
        ]
        let events = [
            "Trade_Tab",
            "All Orders_Tab",
            "Smart Order_Tab",
            "Fractional Trading_Tab",
            "Deposit_Tab",
            "Exchange_Tab",
            "Stock Deposit_Tab",
            "More_Tab"
        ]
        view.tapItemAction = { [weak self] index in
            guard let `self` = self else { return }
            if index == 0 {
                let tradeModel = TradeModel()
                tradeModel.market =  ""
                tradeModel.symbol =  ""
                tradeModel.tradeType = .normal
                tradeModel.market = self.viewModel.exchangeType.market
                let viewModel = YXTradeViewModel(services: self.viewModel
                                                            .navigator, params: ["tradeModel": tradeModel])
                self.viewModel.navigator.push(viewModel, animated: true)
            } else if index == 1 {
                let orderListViewModel = YXAggregatedOrderListViewModel.init(defaultTab: nil, exchangeType: nil)
                let context = YXNavigatable(viewModel: orderListViewModel)
                self.viewModel.navigator.push(YXModulePaths.allOrderList.url, context: context)
            } else if index == 2 {
                let viewModel = YXSmartTradeGuideViewModel(services:self.viewModel
                                                            .navigator, params:nil)
                let vc = YXSmartTradeGuideViewController(viewModel: viewModel)
                self.bottomSheet.titleLabel.text = YXLanguageUtility.kLang(key: "account_stock_order_title")
                self.bottomSheet.showViewController(vc: vc)
            } else if index == 3 {
                YXToolUtility.handleCanTradeFractional { [weak self] in
                    guard let `self` = self else { return }
                    let tradeModel = TradeModel()
                    tradeModel.market =  ""
                    tradeModel.symbol =  ""
                    tradeModel.tradeType = .fractional
                    tradeModel.market = self.viewModel.exchangeType.market
                    let viewModel = YXTradeViewModel(services: self.viewModel
                                                                .navigator, params: ["tradeModel": tradeModel])
                    self.viewModel.navigator.push(viewModel, animated: true)
                }
            } else if index == 4 {
                var url = YXH5Urls.DEPOSIT_GUIDELINE_SG_URL()
                if YXUserManager.shared().curBroker == .sg {
                    url = YXH5Urls.DEPOSIT_GUIDELINE_SG_URL()
                }
                let dic: [String: Any] = [
                    YXWebViewModel.kWebViewModelUrl: url
                ]
                self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            } else if index == 5 {
                let context = YXNavigatable(viewModel: YXCurrencyExchangeViewModel(market: self.viewModel.exchangeType.market))
                self.viewModel.navigator.push(YXModulePaths.exchange.url, context: context)
            } else if index == 6 {
                let url = YXH5Urls.stockDepositURL()
                let dic: [String: Any] = [
                    YXWebViewModel.kWebViewModelUrl: url
                ]
                self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            } else if index == 7 {
                let moduleMoreVM = YXModuleMoreViewModel.init(market: self.viewModel.exchangeType.market)
                let context = YXNavigatable(viewModel: moduleMoreVM)
                self.viewModel.navigator.push(YXModulePaths.moduleMore.url, context: context)
            }

            if index < 8 {
                self.trackViewClickEvent(name: events[index])
            }
        }
        return view
    }()
    
    lazy var bottomSheet: YXBottomSheetViewTool = {
        let sheet = YXBottomSheetViewTool()
        sheet.rightBtnOnlyImage(iamge: UIImage.init(named: "nav_info"))
        sheet.rightButtonAction = {
            if let vc = UIViewController.current() as? QMUIModalPresentationViewController {
                vc.hideWith(animated: true) { (finish) in
                    YXWebViewModel.pushToWebVC(YXH5Urls.smartHelpUrl())
                }
            }
        }
        return sheet
    }()

    lazy var tabView: YXTabView = {
        let tabLayout = YXTabLayout.default()
        tabLayout.lineColor = QMUITheme().themeTextColor()
        tabLayout.linePadding = QMUIHelper.pixelOne
        tabLayout.lineCornerRadius = 2
        tabLayout.lineWidth = 16
        tabLayout.lineHeight = 4
        tabLayout.titleColor = QMUITheme().textColorLevel3()
        tabLayout.titleSelectedColor = QMUITheme().themeTextColor()
        tabLayout.titleFont = .systemFont(ofSize: 16)
        tabLayout.titleSelectedFont = .systemFont(ofSize: 16, weight: .medium)

        let tabView = YXTabView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: tabViewHeight), with: tabLayout)
        tabView.backgroundColor = QMUITheme().foregroundColor();
        tabView.delegate = self
        
        tabView.titles = tabViewTitles

        let line = UIView()
        line.backgroundColor = QMUITheme().separatorLineColor()
        tabView.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(QMUIHelper.pixelOne)
        }

        return tabView
    }()
    
    lazy var pageView: YXPageView = {
        let pageView = YXPageView()
        pageView.parentViewController = self
        pageView.contentView.isScrollEnabled = false
        
        holdViewCotnroller = YXHomeHoldViewController(viewModel: viewModel.holdViewModel)
        
        todayOrderViewCotnroller = YXTodayOrderViewController(viewModel: viewModel.todayOrderViewModel)
        
        pageView.viewControllers = [
            self.holdViewCotnroller!,
            self.todayOrderViewCotnroller!,
        ]
        
        return pageView
    }()
    
    lazy var tabPageView: YXTabPageView = {
        let tabPageView = YXTabPageView(delegate: self)
        let view = UIView(frame: CGRect(x: 0, y: -300, width: YXConstant.screenWidth, height: 300))
        view.backgroundColor = QMUITheme().foregroundColor()
        
        tabPageView.mainTableView.insertSubview(view, at: 0)

        return tabPageView
    }()
    
    lazy var quoteTool: YXSubscribeQuotesManager = {
        return YXSubscribeQuotesManager()
    }()

    lazy var assetRequestTimer: YXStockDetailTcpTimer = {
        let timer = YXStockDetailTcpTimer(interval: 3, excute: {
            [weak self] (tempArr, scheme) in
            guard let `self` = self else { return }
            self.requestData()
        })

        return timer
    }()

    lazy var todayOrderRequestTimer: YXStockDetailTcpTimer = {
        let timer = YXStockDetailTcpTimer(interval: 3, excute: {
            [weak self] (tempArr, scheme) in
            guard let `self` = self else { return }
            self.viewModel.requestTodayViewModel()
        })

        return timer
    }()

    deinit {
        stopTimer()
    }


    lazy var checkAccountUpgrade: YXCheckTradeAccountUpgradeTool = {
        return YXCheckTradeAccountUpgradeTool()
    }()
    
    override func didInitialize() {
        super.didInitialize()
        hidesBottomBarWhenPushed = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.headerViewHeight = 4 + self.assetView_sg.assetViewHeight + 8 + self.entranceViewHeight + 8

        self.view.addSubview(self.tabPageView)
        self.tabPageView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.view)
            make.bottom.equalTo(-YXConstant.tabBarHeight())
            make.top.equalTo(self.strongNoticeView.snp.bottom)
        }
        
        let header = YXRefreshHeader { [weak self] in
            guard let `self` = self else { return }
            self.requestData()
            self.tabPageView.mainTableView.mj_header.endRefreshing()
        }
        
        tabPageView.mainTableView.mj_header = header
        tabPageView.mainTableView.bringSubviewToFront(header!)

        _ = NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: kYXSocketTradeAccountChangeNotification))
            .takeUntil(self.rx.deallocated) //页面销毁自动移除通知监听
            .subscribe(onNext: { [weak self] noti in
                guard let `self` = self else { return }

                if self.qmui_isViewLoadedAndVisible(), let arr = noti.object as? [NSNumber] {

                    let numberArr = arr.map { $0.intValue }
                    if numberArr.contains(TradeRefreshType.allAsset.rawValue) {
                        self.assetRequestTimer.onNext(NSNumber(value: TradeRefreshType.allAsset.rawValue))
                    } else if numberArr.contains(TradeRefreshType.singleAsset.rawValue) {
                        self.assetRequestTimer.onNext(NSNumber(value: TradeRefreshType.singleAsset.rawValue))
                    } else if numberArr.contains(TradeRefreshType.todayOrder.rawValue) {
                        self.todayOrderRequestTimer.onNext(NSNumber(value: TradeRefreshType.todayOrder.rawValue))
                    }
                }

            }).disposed(by: self.rx.disposeBag)

        _ = NotificationCenter.default.rx
            .notification(UIApplication.willEnterForegroundNotification)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] noti in
                guard let `self` = self else { return }
                self.requestData()
            }).disposed(by: self.rx.disposeBag)

        _ = NotificationCenter.default.rx
            .notification(NSNotification.Name(rawValue: "YXBrokerAccountTypeDidChangeNotification"))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] noti in
                guard let `self` = self else { return }
                self.assetView_sg.reloadAccountType()
                self.requestData()
            }).disposed(by: self.rx.disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setTabbarVisibleIfNeed()
        YXPopManager.shared.checkPop(with: YXPopManager.showPageAccount, vc:self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startTimer()
        YXPopManager.shared.checkPopShowStatus(with: YXPopManager.showPageAccount, vc: self)
        
        checkAccountUpgrade.checkIsNeedPrompt()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopTimer()
    }

    override func setupNavigationItems() {
        super.setupNavigationItems()

        let logoImageView = UIImageView.init(image: UIImage(named: "uSmartSG"))
        navigationItem.leftBarButtonItems = [buildSpaceItem(12), UIBarButtonItem(customView: logoImageView)]

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

        let searchBtn = QMUIButton()
        searchBtn.setImage(UIImage(named: "market_search"), for: .normal)
        searchBtn.qmui_tapBlock = { [weak self] _ in
            guard let `self` = self else { return }
            self.viewModel.navigator.present(YXModulePaths.aggregatedSearch.url, animated: false)
            self.trackViewClickEvent(name: "Search_Tab")
        }
        searchBtn.widthAnchor.constraint(equalToConstant: 22).isActive = true
        let searchBarButtonItem = UIBarButtonItem(customView: searchBtn)

        navigationItem.rightBarButtonItems = [buildSpaceItem(12), UIBarButtonItem(customView: messageBtn), buildSpaceItem(16), searchBarButtonItem]
    }

    override var pageName: String {
        "Trade"
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.updateNavigationBarAppearance()
    }

    private func buildSpaceItem(_ width: CGFloat) -> UIBarButtonItem {
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spaceItem.width = width
        return spaceItem
    }

}

extension YXAccountAssetViewController {

    private func startTimer() {
        self.stopTimer()

        if YXUserManager.shared().curBroker == .nz {
            self.tagTimerFlag = YXTimerSingleton.shareInstance().transactOperation({ [weak self] (flag) in
                guard let `self` = self else { return }
                self.requestData()
                }, timeInterval: TimeInterval(YXGlobalConfigManager.configFrequency(.holdingFreq)), repeatTimes: Int.max, atOnce: true)
        } else if YXUserManager.shared().curBroker == .sg {
            self.requestData()
        }
    }

    private func stopTimer() {
        if self.tagTimerFlag > 0 {
            YXTimerSingleton.shareInstance().invalidOperation(withFlag: self.tagTimerFlag)
            self.tagTimerFlag = 0
        }
        self.quoteTool.invalidate()
    }

    private func requestData() {
        self.quoteTool.invalidate()

        viewModel.getData().flatMap { assetModel -> Single<[YXExchangeRateModel]?> in
            self.refreshUI(model: assetModel)
            self.subAllMarketsQuote(assetModel: assetModel)
            return self.viewModel.getExchangeRateList()
        }.subscribe(onSuccess: { [weak self] exchangeRateList in
            self?.viewModel.accountAssetModel?.exchangeRateList = exchangeRateList
            self?.assetView_sg.exchangeRateList = exchangeRateList?.map({ model in
                let cellVM = YXMoneyTypeSelectionCellViewModel(model: model)
                return cellVM
            })
        }).disposed(by: rx.disposeBag)

        viewModel.todayOrderViewModel.requestRemoteDataCommand.execute(NSNumber(value: 1)).subscribeNext { [weak self]obj in
            guard let `self` = self else { return }
            self.todayOrderCount = self.viewModel.todayOrderViewModel.orderCount
            self.tabView.titles = self.tabViewTitles
            self.tabView.reloadData()
        }
    }

    private func subAllMarketsQuote(assetModel: YXAccountAssetResModel?) {
        if assetModel?.totalData != nil {
            quoteTool.subAllMarketQuotes(assetModel) { [weak self] model in
                self?.refreshUI(model: model)
            }
        }
    }

    private func refreshUI(model: YXAccountAssetResModel?) {
        self.assetView_sg.model = model

        positionCount = self.viewModel.holdViewModel.holdSecurityCount()
        tabView.titles = tabViewTitles
        tabView.reloadData()

        if let model = model {
            self.viewModel.holdViewModel.assetModel = model
            self.viewModel.holdViewModel.reloadDataSource()
        }
    }

}

extension YXAccountAssetViewController: YXTabPageViewDelegate {

    func heightForTabViewInTabPage() -> CGFloat {
        tabViewHeight
    }
    
    func heightForPageViewInTabPage() -> CGFloat {
        return YXConstant.screenHeight - YXConstant.navBarHeight() - YXConstant.tabBarHeight() - tabViewHeight
    }
    
    func headerViewInTabPage() -> UIView {
        headerView
    }
    
    func heightForHeaderViewInTabPage() -> CGFloat {
        return headerViewHeight
    }
    
    func tabViewInTabPage() -> YXTabView {
        tabView
    }
    
    func pageViewInTabPage() -> YXPageView {
        pageView
    }

}

extension YXAccountAssetViewController: YXTabViewDelegate{

    func tabView(_ tabView: YXTabView, didSelectedItemAt index: UInt, withScrolling scrolling: Bool) {
        var event = "Positions_Tab"
        if index == 1 {
            event = "Today's Orders_Tab"
        }
        trackViewClickEvent(name: event)
    }

}
