//
//  YXTradeMoreViewController.swift
//  uSmartOversea
//
//  Created by Apple on 2020/4/24.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXTradeMoreViewController: YXHKViewController, ViewModelBased {
    var viewModel: YXTradeMoreViewModel!
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = QMUITheme().backgroundColor()
        return scrollView
    }()

    var trackPageName = "户口-港股-更多"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = YXLanguageUtility.kLang(key: "trade_all_func")
        
        initUI()
        
        initItemsActions()

        if (self.viewModel.exchangeType == .us) {
            trackPageName = "户口-美股-更多"
        } else if (self.viewModel.exchangeType == .hs) {
            trackPageName = "户口-A股-更多"
        } else {
            trackPageName = "户口-港股-更多"
        }
        
        _ = NotificationCenter.default.rx.notification(Notification.Name(rawValue: YX_Noti_Ecm_Sub_Red_Point))
         .takeUntil(self.rx.deallocated)
         .subscribe(onNext: { [weak self] (notification) in
             self?.stockItems.hideEcmRedDot = YXLittleRedDotManager.shared.isHiddenEcmSubRedPoint()
         })
        
        _ = NotificationCenter.default.rx.notification(Notification.Name(rawValue: YX_Noti_Act_Center))
         .takeUntil(self.rx.deallocated)
         .subscribe(onNext: { [weak self] (notification) in
             self?.activityItems.hideActRedDot = YXLittleRedDotManager.shared.isHiddenActCenter()
         })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        stockItems.hideEcmRedDot = YXLittleRedDotManager.shared.isHiddenEcmSubRedPoint()
        activityItems.hideActRedDot = YXLittleRedDotManager.shared.isHiddenActCenter()
    }
    
    // 交易 模块
    lazy var tradeItems: YXTradeTradeItemsView = {
        let tradeItems = YXTradeTradeItemsView(frame: .zero, exchangeType: viewModel.exchangeType, showGrey: viewModel.showGrey)
        tradeItems.backgroundColor = QMUITheme().foregroundColor()
        addShadowLayer(view: tradeItems)
        return tradeItems
    }()
    // 资金 模块
    lazy var fundsItems: YXTradeFundsItemsView = {
        let fundsItems = YXTradeFundsItemsView(frame: .zero)
        fundsItems.backgroundColor = QMUITheme().foregroundColor()
        addShadowLayer(view: fundsItems)
        
        if YXUserManager.isIntraday(viewModel.exchangeType.market) == false {
            fundsItems.capitalBtn.isHidden = true
        }
        
        return fundsItems
    }()
    // 账户 模块
    lazy var accountItems: YXTradeAccountItemsView = {
        let accountItems = YXTradeAccountItemsView(frame: .zero, exchangeType: viewModel.exchangeType)
        accountItems.backgroundColor = QMUITheme().foregroundColor()
        addShadowLayer(view: accountItems)
        return accountItems
    }()
    
    // 权益管理 模块
    lazy var manageItems: YXTradeManageItemsView = {
        let manageItems = YXTradeManageItemsView(frame: .zero, exchangeType: viewModel.exchangeType)
        manageItems.backgroundColor = QMUITheme().foregroundColor()
        addShadowLayer(view: manageItems)
        return manageItems
    }()
    
    lazy var stockItems: YXTradeStockItemsView = {
        let stockItems = YXTradeStockItemsView(frame: .zero, exchangeType: viewModel.exchangeType)
        stockItems.backgroundColor = QMUITheme().foregroundColor()
        addShadowLayer(view: stockItems)
        return stockItems
    }()
    
    lazy var activityItems: YXTradeActivityView = {
        let activityItems = YXTradeActivityView(frame: .zero)
        activityItems.backgroundColor = QMUITheme().foregroundColor()
        addShadowLayer(view: activityItems)
        return activityItems
    }()
    
    //交易模块英文状态要额外增加的高度
    lazy var tradeItemExtroHeight:CGFloat = {
        if YXUserManager.isENMode() {
            return 20.0
        }
        return 0.0
    }()
    
    override func viewDidLayoutSubviews() {
        tradeItems.layer.shadowPath = UIBezierPath.init(rect: tradeItems.bounds.offsetBy(dx: 0, dy: 4)).cgPath
        fundsItems.layer.shadowPath = UIBezierPath.init(rect: fundsItems.bounds.offsetBy(dx: 0, dy: 4)).cgPath
        accountItems.layer.shadowPath = UIBezierPath.init(rect: accountItems.bounds.offsetBy(dx: 0, dy: 4)).cgPath
        stockItems.layer.shadowPath = UIBezierPath.init(rect: stockItems.bounds.offsetBy(dx: 0, dy: 4)).cgPath
        activityItems.layer.shadowPath = UIBezierPath.init(rect: activityItems.bounds.offsetBy(dx: 0, dy: 4)).cgPath
        
        if viewModel.exchangeType == .hk {
            manageItems.layer.shadowPath = UIBezierPath.init(rect: manageItems.bounds.offsetBy(dx: 0, dy: 4)).cgPath
        }
    }
    
    func addShadowLayer(view: UIView) {
        view.layer.backgroundColor = QMUITheme().foregroundColor().cgColor
        view.layer.cornerRadius = 10
        view.layer.borderColor = QMUITheme().separatorLineColor().cgColor
        view.layer.borderWidth = 1
        view.layer.shadowColor = QMUITheme().separatorLineColor().cgColor
        view.layer.shadowOpacity = 1.0
    }
    
    private func initUI() {
        self.view.addSubview(self.scrollView)
        
        if #available(iOS 11.0, *) {
            self.scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        
        self.scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        //容器
        let container = UIView()
        self.scrollView.addSubview(container)
        container.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(self.scrollView)
            make.left.right.equalTo(self.view)
        }
        
        
        container.addSubview(self.tradeItems)
        container.addSubview(self.fundsItems)
        container.addSubview(self.stockItems)
        if viewModel.exchangeType == .hk {
            container.addSubview(self.manageItems)
        }
        container.addSubview(self.accountItems)
        container.addSubview(self.activityItems)
        
        self.tradeItems.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
            make.top.equalTo(YXConstant.navBarHeight() + 8)
            make.height.equalTo(83 + tradeItems.defaultHeight + tradeItems.itemHeight)
        }
        
        // 资金 模块
        self.fundsItems.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
            make.top.equalTo(self.tradeItems.snp.bottom).offset(14)
            make.height.equalTo(183)
        }
        
        // 股票 模块
        self.stockItems.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
            make.top.equalTo(self.fundsItems.snp.bottom).offset(14)
            make.height.equalTo(113 + tradeItemExtroHeight)
        }
        if viewModel.exchangeType == .hk {
            // 权益管理 模块
            self.manageItems.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(18)
                make.right.equalToSuperview().offset(-18)
                make.top.equalTo(self.stockItems.snp.bottom).offset(14)
                make.height.equalTo(113 + tradeItemExtroHeight)
            }
            
            // 账户 模块
            self.accountItems.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(18)
                make.right.equalToSuperview().offset(-18)
                make.top.equalTo(self.manageItems.snp.bottom).offset(14)
                make.height.equalTo(113 + tradeItemExtroHeight)
            }
        } else {
            // 账户 模块
            self.accountItems.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(18)
                make.right.equalToSuperview().offset(-18)
                make.top.equalTo(self.stockItems.snp.bottom).offset(14)
                make.height.equalTo(113 + tradeItemExtroHeight)
            }
        }
        
       self.activityItems.snp.makeConstraints { (make) in
           make.left.equalToSuperview().offset(18)
           make.right.equalToSuperview().offset(-18)
           make.top.equalTo(self.accountItems.snp.bottom).offset(14)
           make.height.equalTo(113)
           make.bottom.equalToSuperview().offset(-14)
       }
        
        
        if let text = self.viewModel.ipoTagText, text.count > 0 {
            stockItems.newStockTagView.textLabel?.text = text
            stockItems.newStockTagView.isHidden = false
        }
    }
    
    private func initItemsActions() {
        self.tradeItems.onClickTrade = { [weak self] in
            guard let strongSelf = self else { return }
            
//            let model = YXTradeOrderModel()
//            model.market = strongSelf.viewModel.exchangeType.market
//
//            YXTradeViewModel.getOrderType(withMarket: model.market) { (type) in
//
//                let viewModel = YXTradeViewModel(services: strongSelf.viewModel.navigator,
//                                                      params:["tradeModel":model,
//                                                              "tradeType":YXTradeType.normal.rawValue,
//                                                              "defaultOrderType"  : NSNumber(integerLiteral: type)
//                                                      ])
//                strongSelf.viewModel.navigator.push(viewModel, animated: true)
//
//            }
//
//            YXSensorAnalyticsTrack.track(withEvent: .ViewClick, properties: [
//                YXSensorAnalyticsPropsConstants.propViewId() : "trade",
//                YXSensorAnalyticsPropsConstants.propViewName() : "交易",
//                YXSensorAnalyticsPropsConstants.propViewPage() :strongSelf.trackPageName])
            
        }
        
        // 月供股票
        self.tradeItems.onClickMonthly = { [weak self] in
            guard let `self` = self else { return }
            
            let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_MONTHLY_ALL_URL()]
            self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))

        }
        
        self.tradeItems.onClickBond = { [weak self] in
            guard let `self` = self else { return }
            let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.BOND_HOME_PAGE()]
            self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))

        }
        
        self.tradeItems.onClickGrey = { [weak self] in
            guard let `self` = self else { return }
            let viewModel = YXTodayGreyStockViewModel(services: self.viewModel.navigator, params:nil)
            self.viewModel.navigator.push(viewModel, animated: true)
        }
        
        self.tradeItems.onClickOrder = { [weak self] in
            guard let `self` = self else { return }
            let orderListViewModel = YXAggregatedOrderListViewModel.init(defaultTab: nil, exchangeType: nil)
            let context = YXNavigatable(viewModel: orderListViewModel)
            self.viewModel.navigator.push(YXModulePaths.allOrderList.url, context: context)

        }
        
        self.tradeItems.onClickSmartTrade = { [weak self] in
            guard let `self` = self else { return }
            
//            let orderModel = YXTradeOrderModel()
//            orderModel.market = self.viewModel.exchangeType.market;
//
//            let params = ["tradeModel": orderModel,
//                          "tradeType": NSNumber(value: YXTradeType.normal.rawValue),
//                          "defaultOrderType": NSNumber(value: YXOrderType.smart.rawValue)]
//
//            let viewModel = YXSmartTradeGuideViewModel(services: self.viewModel.navigator, params: params)
//            self.viewModel.navigator.push(viewModel, animated: true)
//
//            YXSensorAnalyticsTrack.track(withEvent: .ViewClick, properties: [
//                YXSensorAnalyticsPropsConstants.propViewId() : "smart_trade",
//                YXSensorAnalyticsPropsConstants.propViewName() : "智能下单",
//                YXSensorAnalyticsPropsConstants.propViewPage() :self.trackPageName])
        }
        
        self.tradeItems.onClickSmartOrder = { [weak self] in
            guard let `self` = self else { return }
            
//            let viewModel = YXSmartOrderListViewModel(services: self.viewModel.navigator, params: nil)
//            viewModel.exchangeType = self.viewModel.exchangeType.rawValue
//            self.viewModel.navigator.push(viewModel, animated: true)
//
//            YXSensorAnalyticsTrack.track(withEvent: .ViewClick, properties: [
//                                            YXSensorAnalyticsPropsConstants.propViewId() : "smart_order",
//                                            YXSensorAnalyticsPropsConstants.propViewName() : "智能订单",
//                                            YXSensorAnalyticsPropsConstants.propViewPage() :self.trackPageName])
        }
        
        self.tradeItems.onClickConditionOrder = { [weak self] in
            guard let `self` = self else { return }
            
        }
        
        self.tradeItems.onClickTradeFund = { [weak self] in
            guard let `self` = self else { return }
            
            let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_FUND_TRADE_URL(with: nil, market: YXMarketType.HK.rawValue)]
            self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))

        }
        

        //新股认购
        self.stockItems.onClickIPO = { [weak self] in
            guard let `self` = self else { return }

            let context: [String : Any] = [
                "market" : self.viewModel.exchangeType.market
            ]
            self.viewModel.navigator.push(YXModulePaths.newStockCenter.url, context: context)
        }
        
        //新股认购
        self.stockItems.onClickIpoSub = { [weak self] in
            guard let `self` = self else { return }
            
            YXLittleRedDotManager.shared.hiddenEcmSub()
            self.stockItems.hideEcmRedDot = true

            self.viewModel.navigator.push(YXModulePaths.newStockDelivered.url)

        }
        
        // 转入股票
        self.stockItems.onClickShiftIn = { [weak self] in
            guard let `self` = self else { return }

            let context = YXNavigatable(viewModel: YXShiftInStockViewModel(dictionary: ["exchangeType" : self.viewModel.exchangeType]))
            self.viewModel.navigator.push(YXModulePaths.shiftInStock.url, context: context)

        }
        
        //MARK: 资金：存入资金、货币兑换、提取资金、历史记录、资金流水
        self.fundsItems.onClickDespositFunds = { [weak self] in
            guard let `self` = self else { return }
            
            let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_DEPOSIT_URL(market: self.viewModel.exchangeType.market)]
            self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))

        }
        
        self.fundsItems.onClickExchangeCurrency = { [weak self] in
            guard let `self` = self else { return }
            
            let context = YXNavigatable(viewModel: YXCurrencyExchangeViewModel(market: self.viewModel.exchangeType.market))
            self.viewModel.navigator.push(YXModulePaths.exchange.url, context: context)

        }
        
        self.fundsItems.onClickWithdrawFunds = { [weak self] in
            guard let `self` = self else { return }
            
            let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_WITHDRAWAL_URL(market: self.viewModel.exchangeType.market)]
            self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))

        }
        
        self.fundsItems.onClickHistory = { [weak self] in
            guard let `self` = self else { return }
            
            let context = YXNavigatable(viewModel: YXHistoryViewModel(bizType: .All))
            self.viewModel.navigator.push(YXModulePaths.history.url, context: context)

        }
        
        self.fundsItems.onClickCapitalFlow = { [weak self] in
            guard let `self` = self else { return }
            
            let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_CAPITAL_FLOW_URL()]
            self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))

        }
        
        self.fundsItems.onClickCapital = { [weak self] in
            guard let `self` = self else { return }
            
//            let viewModel = YXBankTreasurerViewModel(services: self.viewModel.navigator,
//                                                     params:["market":self.viewModel.exchangeType.market])
//            self.viewModel.navigator.push(viewModel, animated: true)
        }
        
        self.accountItems.onClickProfessionalFlow = { [weak self] in
            guard let `self` = self else { return }
            
            let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_PROFESSIONAL_URL()]
            self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))

        }
        
        self.accountItems.onClickGoProFlow = { [weak self] in
            guard let `self` = self else { return }
            
            //高级账户介绍落地页
            let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_USERCENTER_PRO_INTRO("Account_HK")]
            self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            
        }
        
        if viewModel.exchangeType == .hk {
            self.manageItems.onClickStockOption = { [weak self] in
                guard let `self` = self else { return }
                
                let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.STOCK_OPTION_URL()]
                self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))

            }
            
            self.manageItems.onClickStockSelection = { [weak self] in
                guard let `self` = self else { return }
                
                let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.STOCK_SELECTION_URL()]
                self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))

            }
        }

        self.activityItems.onClickActivity = { [weak self] in
            guard let `self` = self else { return }
            
            YXLittleRedDotManager.shared.hiddenActCenter()
            self.activityItems.hideActRedDot = true
            
            let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_ACTIVITY_CENTER_URL()]
            self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            
        }
    }

}
