//
//  YXStockDetailViewController.swift
//  uSmartOversea
//
//  Created by Kelvin on 2019/4/10.
//  Copyright © 2019年 RenRenDai. All rights reserved.
//

import YXKit
import SwiftyJSON
import RxSwift
import RxCocoa
import JXPagingView
import JXSegmentedView
import CoreGraphics
import UIKit

extension JXPagingListContainerView: JXSegmentedViewListContainer {}

var stockDetailShowTip: Bool = true
class YXStockDetailViewController: YXHKViewController, HUDViewModelBased {

    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    typealias ViewModelType = YXStockDetailViewModel
    var viewModel: ViewModelType!

    //MARK: 请求相关变量
    var quoteRequest: YXQuoteRequest?

    //MARK: 视图展示相关变量
    var topTitleView: YXStockDetailTopTitleView?

    var bottomToolView: StockDetailBottomView?

    var noticeHeight: CGFloat = 0

    //MARK: 行情 及 状态记录 相关变量
    //行情
    var quoteTimer = "YXStockDetailQuoteTimer"
    // 是否是第一次加载详情
    var isFirstLoad = true
    //是否可以切换股票
    var canChangeStock = false

    //登录态是否发生变化
    var loginStateChange: Bool = false

    var quoteLevelChange = false
    //记录是否请求过融资标签等数据
    var margin: NumberInt32? // 融资标签,之前是由行情返回，现在由交易接口获取，交易获取到了，则不再请求交易接口
    var marginRatio: NumberDouble? // 抵押比率
    
    lazy var pagingView: JXPagingView = preferredPagingView()
    lazy var quoteHeaderView: StockDetaiBaseHeaderView = preferredTableHeaderView()
    let segDataSource: JXSegmentedDotDataSource = JXSegmentedDotDataSource()
    lazy var segmentedView: JXSegmentedView = JXSegmentedView(frame: CGRect(x: 0, y: 8, width: UIScreen.main.bounds.size.width, height: 40))
    var tableHeaderViewHeight: Int = 98
    var headerInSectionHeight: Int = 48
    
    lazy var sectionView: UIView = {
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: CGFloat(headerInSectionHeight)))
        view.addSubview(segmentedView)
        view.backgroundColor = QMUITheme().backgroundColor()
        
        let lineView = UIView.line()
        lineView.frame = CGRect.init(x: 0, y: view.mj_h - 0.5, width: view.mj_w, height: 0.5)
        view.addSubview(lineView)
        return view
    }()
    
    let bottomHeight: CGFloat = 58 + YXConstant.tabBarPadding()
    
    lazy var bottomBgView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().foregroundColor()
        
        let lineView = UIView()
        lineView.backgroundColor = QMUITheme().separatorLineColor()
        view.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        return view
    }()
    
    //长按分时视图
    lazy var timeLineLongPressView: YXTimeLineLongPressView = {
        let view = YXTimeLineLongPressView(frame: CGRect.init(x: 0, y: 0, width: YXConstant.screenWidth, height: 165), andType: .portrait)
        view.isHidden = true
        return view
    }()
    
    //长按k线视图
    lazy var klineLongPressView: YXKlineLongPressView = {
        let view = YXKlineLongPressView.init(frame: CGRect.init(x: 0, y: 0, width: YXConstant.screenWidth, height: 165), andType: .portrait)
        view.isHidden = true
        return view
    }()
            
    override var pageName: String {
        if self.viewModel.market == YXMarketType.USOption.rawValue {
            return "options_detail"
        }
        return "stock_detail"
    }
    
    override var pageProperties: [String : String] {
        let market = self.viewModel.market
        let symbol = self.viewModel.symbol
        let name = self.viewModel.quoteModel?.name ?? (self.viewModel.name ?? "")
        return ["stock_code": market + symbol,
                "stock_name": name]
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = [.top, .left, .right]

        self.bindHUD()

        YXCYQUtility.saveCYQState(false)

        initUI()

        bindViewModel()

        self.networkingHUD.showLoading("", in: self.view)

        _ = NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: YXUserManager.notiUpdateUserInfo))
            .takeUntil(self.rx.deallocated) //页面销毁自动移除通知监听
            .subscribe(onNext: { [weak self] noti in
                guard let `self` = self else { return }

                self.loginStateChange = true
                if YXUserManager.canTrade() {
                    if !YXUserManager.isOpenUsOption() && self.viewModel.stockType == .stUsStockOpt {//期权未开户
                        self.bottomToolView?.refreshTradeButtonOpenAccountStatus(with: false)
                    }else {
                        self.bottomToolView?.refreshTradeButtonOpenAccountStatus(with: true)
                    }
                }else {
                    self.bottomToolView?.refreshTradeButtonOpenAccountStatus(with: false)
                }

            }).disposed(by: rx.disposeBag)

        _ = NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: YXUserManager.notiQuoteKick))
            .takeUntil(self.rx.deallocated) //页面销毁自动移除通知监听
            .subscribe(onNext: { [weak self] noti in
                guard let `self` = self else { return }

                self.handleQuoteKick()

            }).disposed(by: rx.disposeBag)
        
        
        configSegementView()

    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
 
        DispatchQueue.main.async {

            if (self.quoteLevelChange) {
                self.quoteLevelChange = false;
                self.handleQuoteKick()
            } else {
                self.loadServerData()

                if self.loginStateChange {
                    // 更新快捷交易
                    self.loginStateChange = false

                    self.viewModel.quoteVC?.updateUIByLoginState()

                }
                //加载股价提醒的数据
                if !self.isFirstLoad {
                    self.loadReminderData()
                }
            }

        }

        YXSensorAnalyticsTrack.trackTimerStart(withEvent: .ViewScreen)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
  
        quoteRequest?.cancel()
        quoteRequest = nil
        self.quoteHeaderView.hidePop()

    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        YXTimer.shared.cancleTimer(WithTimerName: quoteTimer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.pagingView.frame = CGRect.init(x: 0, y: YXConstant.navBarHeight(), width: self.view.mj_w, height: self.view.mj_h - bottomHeight - YXConstant.navBarHeight())
        self.bottomBgView.frame = CGRect.init(x: 0, y: self.pagingView.frame.maxY, width: self.view.mj_w, height: bottomHeight)
    }
    
    func configSegementView() {
        segDataSource.titles = self.viewModel.tabTypes.map({$0.title})
        segDataSource.dotStates = Array.init(repeating: false, count: segDataSource.titles.count)
        segDataSource.titleSelectedColor = QMUITheme().themeTextColor()
        segDataSource.titleNormalColor = QMUITheme().textColorLevel3()
        segDataSource.titleSelectedColor = QMUITheme().textColorLevel1()
        segDataSource.titleNormalFont = UIFont.systemFont(ofSize: 16, weight: .regular)
        segDataSource.titleSelectedFont = UIFont.systemFont(ofSize: 18, weight: .medium)
        segDataSource.isTitleColorGradientEnabled = true
        segDataSource.dotSize = CGSize(width: 8, height: 8)
        segDataSource.isItemSpacingAverageEnabled = false
        
        segmentedView.backgroundColor = QMUITheme().foregroundColor()
        segmentedView.delegate = self
        segmentedView.isContentScrollViewClickTransitionAnimationEnabled = false
        segmentedView.dataSource = segDataSource
        segmentedView.contentEdgeInsetLeft = 16
        
        let lineView = JXSegmentedIndicatorLineView()
        lineView.indicatorColor = QMUITheme().themeTextColor()
        lineView.indicatorWidth = 16
        lineView.indicatorHeight = 4
        lineView.indicatorCornerRadius = 2
        lineView.verticalOffset = 1
        segmentedView.indicators = [lineView]
        

        pagingView.mainTableView.gestureDelegate = self
        segmentedView.listContainer = pagingView.listContainerView
        
        //扣边返回处理，下面的代码要加上
        pagingView.listContainerView.scrollView.panGestureRecognizer.require(toFail: self.navigationController!.interactivePopGestureRecognizer!)
        pagingView.mainTableView.panGestureRecognizer.require(toFail: self.navigationController!.interactivePopGestureRecognizer!)
    }
    

    //跳转横屏放在外层来做，因为要记录股票位置（不做多股票切换时，可以放到YXStockDetailQuoteVC)
    func pushToLandscapeVC(with tsType: YXTimeShareLineType?) {
        let selectIndexBlock: (Int)->() = { [weak self] (index) in
            guard let `self` = self else { return }

            if index != self.viewModel.selectIndex {
                self.viewModel.selectIndex = index
                if self.viewModel.selectIndex >= self.viewModel.dataSource.count {
                    self.viewModel.selectIndex = self.viewModel.dataSource.count - 1
                }
                self.setCurrentStock()
            }
        }
        var paraM = ["dataSource" : self.viewModel.dataSource, "selectIndex" : self.viewModel.selectIndex, "selectIndexBlock": selectIndexBlock, "fromDetail": true] as [String : Any]
        if let type = tsType {
            paraM["tsType"] = type
        }
        self.viewModel.navigator.push(YXModulePaths.landStockDetail.url, context: paraM, animated: false)
    }

    //布局界面
    func initUI() {

        self.view.backgroundColor = QMUITheme().foregroundColor()

        do { //处理小黄条回调
            self.strongNoticeView.bmpCloseCallBack = {
//                [weak self] in
//                guard let `self` = self else { return }
                stockDetailShowTip = false
            }

            self.strongNoticeView.tempCodeCloseCallBack = {
                [weak self] in
                guard let `self` = self else { return }

                MMKV.default().set(Date().timeIntervalSince1970, forKey: "YXStockDetailTempCodeKey-" + self.viewModel.symbol)
            }

            self.strongNoticeView.quoteLevelChangeBlock = {
                [weak self] in
                guard let `self` = self else { return }

                self.networkingHUD.showLoading("")
                YXQuoteKickTool.shared.getUserQuoteLevelRequest(activateToken: true, resultBock: {
                    [weak self] success in
                    guard let `self` = self else { return }

                    self.networkingHUD.hide(animated: true)
                    //请求后有通知， 逻辑在YXUserManager.notiQuoteKick通知中处理
                })
            }

            self.strongNoticeView.tempCodeJumpCallBack = {
                [weak self] in
                guard let `self` = self else { return }

                let input = YXStockInputModel()
                input.market = YXMarketType.HK.rawValue
                input.symbol = self.viewModel.tempCode

                self.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : [input], "selectIndex" : 0])
            }

            self.strongNoticeView.rx.observe(Bool.self, "hidden").subscribe(onNext: {
                [weak self] hidden in
                guard let `self` = self, let isHidden = hidden else { return }

                if isHidden {
                    if self.noticeHeight == 0 {
                        return
                    }
                    self.noticeHeight = 0
                } else {
                    if self.noticeHeight == self.strongNoticeViewHeight {
                        return
                    }
                    self.noticeHeight = self.strongNoticeViewHeight
                }
            }).disposed(by: rx.disposeBag)
        }

        //初始化导航条
        initNavibar()

        //顶部常驻栏
        self.view.addSubview(self.pagingView)
        self.view.addSubview(self.bottomBgView)
        self.view.addSubview(self.klineLongPressView)
        self.view.addSubview(self.timeLineLongPressView)
        
        self.pagingView.mainTableView.mj_header = YXRefreshHeader { [weak self] in
            guard let `self` = self else { return }
            self.loadServerData()
            let type = self.viewModel.tabTypes[self.segmentedView.selectedIndex]
            if type == .optionChain {
                self.pagingView.mainTableView.mj_header.endRefreshing()
            } else {
                if let vc = self.pagingView.currentScrollingListView?.viewController() {
                    vc.jx_refreshData()
                }
            }
        }
    }

    //初始化导航栏
    func initNavibar() {

        let searchItem = UIBarButtonItem.qmui_item(with: UIImage(named: "stock_search")?.withRenderingMode(.alwaysOriginal) ?? UIImage(), target: self, action: #selector(seachClick(_:)))
        topTitleView = YXStockDetailTopTitleView.init(frame: CGRect.init(x: 0, y: 0, width: 300, height: 44))

        self.navigationItem.rightBarButtonItems = [searchItem]

        self.navigationItem.titleView = topTitleView!

        topTitleView?.setDefaultStockInfo(self.viewModel.name, market: self.viewModel.market, symbol: self.viewModel.symbol)

        if self.viewModel.dataSource.count > 1 {
            self.topTitleView?.addChangeStockPanGesture()
        }

        topTitleView?.nameTapBlock = {
            [weak self] (name) in
            guard let `self` = self else { return }
            self.networkingHUD.showMessage(name, in: self.view, hideAfter: 2.0)
        }

        topTitleView?.changeStockClosure = {
            [weak self] isPre in
            guard let `self` = self else { return }
            //上一只股票加载完成后，在加载另一只股票
            if self.canChangeStock {
                self.canChangeStock = false
                self.confirmNextDataSource(isPre)
            }
        }
        
    }

    func scrollNavTitleView(isTop: Bool) {
        self.topTitleView?.scrollToTop(isTop)
    }

    lazy var quoteTcpFilter: YXStockDetailTcpFilter<YXV2Quote> = {
        let interval = TimeInterval(YXGlobalConfigManager.configFrequency(.stockRealquoteRefreshFreq)) / 1000.0
        let filter = YXStockDetailTcpFilter<YXV2Quote>(interval: interval) { [weak self] quote in
            guard let `self` = self else { return }
            self.updateQuoteInfo(quoteModel: quote, scheme: .tcp)
        }
        
        return filter
    }()


    deinit {
        YXCYQRequestTool.shared.removeAllCache()
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK:- **** 行情Detail ****
//MARK: 行情Quote 请求及接口回调处理
extension YXStockDetailViewController {

    //加载数据
    func loadServerData() {

        if !YXTimer.shared.isExistTimer(WithTimerName: self.quoteTimer) {
            YXTimer.shared.isBackgroud = false
            YXTimer.shared.scheduledDispatchTimer(WithTimerName: self.quoteTimer, timeInterval: TimeInterval(YXGlobalConfigManager.configFrequency(.quotesResendFreq)), queue: .main, repeats: true) { [weak self] in
                guard let `self` = self else { return }
                //实时行情&买卖档
                self.loadQuoteData()
            }
        } else {
            //实时行情&买卖档
            self.loadQuoteData()
        }
    }

    // 行情Detail
    func loadQuoteData(_ needShowHud: Bool = false) {

        quoteRequest?.cancel()
        quoteRequest = YXQuoteManager.sharedInstance.subRtFullQuote(secu: Secu(market: self.viewModel.market, symbol: self.viewModel.symbol, extra: self.viewModel.extra), level: self.viewModel.level, handler: ({ [weak self] (quotes, scheme) in
            guard let `self` = self else { return }
            self.networkingHUD.hide(animated: true)
            if scheme == .http {
                self.canChangeStock = true
                self.pagingView.mainTableView.mj_header.endRefreshing()
            }
            guard quotes.count > 0, let quoteModel = quotes.first, let market = quoteModel.market, let symbol = quoteModel.symbol, market == self.viewModel.market, symbol == self.viewModel.symbol else {

                //多只股票切换时，避免接收的是上次的推送，需要比对market 和 symbol
                return
            }

            if scheme == .tcp {
                //推送销毁需要时间，同一只股票再次进入个股可能会立马收到推送，要过滤掉这种情况
                guard self.viewModel.quoteModel != nil else { return }
                //行情请求回来的融资比例不再生效，由交易接口返回的marginRatio来控制
                self.resetconfigMortagaRate(quoteModel)

                self.quoteTcpFilter.onNext(quoteModel)
                return
            } else {

                if self.viewModel.type1 == nil {
                    self.viewModel.type1 = quoteModel.type1?.value ?? 0
                    self.viewModel.type2 = quoteModel.type2?.value ?? 0
                    self.viewModel.type3 = quoteModel.type3?.value ?? 0
                    //暗盘 和 低阶adr有重置行情权限的操作，这里重新请求行情
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                        //ah 和 adr的轮询请求是在 subRtFullQuote 方法回调之后执行的
                        //延迟0.2s执行确保 ah和adr的请求已经发出，否则取消请求时ah 和 adr的轮询请求会取消不掉
                        self.loadQuoteData()
                    })
                }
                //行情请求回来的融资比例不再生效，由交易接口返回的marginRatio来控制
                self.resetconfigMortagaRate(quoteModel)

                self.updateQuoteInfo(quoteModel: quoteModel, scheme: .http)
            }


        }) ,failed: { [weak self] in
            guard let `self` = self else { return }

            self.networkingHUD.hide(animated: true)
            self.pagingView.mainTableView.mj_header.endRefreshing()
            self.canChangeStock = true
            if needShowHud {
                self.viewModel.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
            }
        })
    }

    func resetconfigMortagaRate(_ quote: YXV2Quote) {
        quote.marginRatio = NumberDouble.init(0)
        quote.margin = NumberInt32.init(0)
        
        if YXConstant.appTypeValue == .OVERSEA {
            if YXUserManager.shared().curBroker.brokerNo() != "" {
                if (self.marginRatio == nil) { //请求过有这个值了就不再请求了
                    self.requestConfigMortgageRate()
                } else {
                    quote.marginRatio = self.marginRatio
                    quote.margin = self.margin
                }
            }
        } else if YXConstant.appTypeValue == .OVERSEA_SG{
            if (self.marginRatio == nil) { //请求过有这个值了就不再请求了
                self.requestConfigMortgageRate()
            } else {
                quote.marginRatio = self.marginRatio
                quote.margin = self.margin
            }
        }
    }
    //查询configMortgageRate信息，202111月，之前是行情接口返回是否支持融资和日内融之类的中台配置，现在行情不支持了，交易提供了这个新接口去访问
    func requestConfigMortgageRate() {
        let requestModel = YXCconfigMortgageRateQueryReqModel()
        requestModel.stockCode = self.viewModel.symbol
        requestModel.exchangeType = self.viewModel.exchangeType.market.uppercased()
        
        let request = YXRequest(request: requestModel)
        request.startWithBlock(success: { [weak self] (responseModel)  in
            if (responseModel.code == .success) {
                if let res = YXCconfigMortgageRateQueryResModel.yy_model(withJSON: responseModel.data){
                    self?.margin = NumberInt32.init(res.margin)
                    self?.marginRatio = NumberDouble.init(res.mortgageRatio)
                    self?.viewModel.quoteModel?.marginRatio = NumberDouble.init(res.mortgageRatio)
                    self?.viewModel.quoteModel?.margin = NumberInt32.init(res.margin)
                    self?.updateQuoteInfo(quoteModel: self?.viewModel.quoteModel ?? YXV2Quote(), scheme: .http)
                }
            } else {
                self?.viewModel.quoteModel?.marginRatio = NumberDouble.init(0)
                self?.viewModel.quoteModel?.margin = NumberInt32.init(0)
//                self?.updateQuoteInfo(quoteModel: (self?.viewModel.quoteModel)!, scheme: .http)
            }
        }) { (request) in
            
        }
    }

    func updateQuoteInfo(quoteModel: YXV2Quote, scheme: Scheme) {

        if scheme == .tcp {
            if let underlingSEC = quoteModel.underlingSEC, underlingSEC.symbol == nil {
                quoteModel.underlingSEC?.symbol = self.viewModel.quoteModel?.underlingSEC?.symbol
                quoteModel.underlingSEC?.market = self.viewModel.quoteModel?.underlingSEC?.market
            }
        }
        
        self.viewModel.quoteModel = quoteModel
        if scheme == .http {            
            self.viewModel.stockType = quoteModel.stockType
        }

        if let name = self.viewModel.name, !name.isEmpty {

        } else {
            self.viewModel.name = quoteModel.name
        }

        self.topTitleView?.market = self.viewModel.market
        self.topTitleView?.quoteModel = quoteModel
        
        quoteHeaderView.quoteModel = quoteModel

        //优先判断是否是暗盘
        if let value = quoteModel.greyFlag?.value, value != 0 {
            self.viewModel.greyFlag = true;
        }

        //if内的方法，每次切换股票只需要执行一次
        if self.isFirstLoad {
            self.isFirstLoad = false

            if let type2 = OBJECT_SECUSecuType2(rawValue: Int32(quoteModel.type2?.value ?? 0)),
               (type2 == .stHighAdr || type2 == .stLowAdr) {
                self.viewModel.isADR = true
                if type2 == .stLowAdr {
                    self.viewModel.isLowADR = true
                }
            }

            self.updatePageView(quoteModel)

            self.initbottomView(quoteModel)
            
            self.configLongPressView()

            //消息小黄条一只股票之请求一次
            self.loadNoticeData()
            self.loadOtherData()
            self.loadNewDiscussData()
            self.loadReminderData()
            //融资信息
            self.loadMarginData()
            self.quoteHeaderView.parameterView.setTitles(self.viewModel.detailParameters)
        }
        self.viewModel.quoteVC?.updateQuoteInfo(quoteModel, scheme: scheme)
    }

    func updatePageView(_ quoteModel: YXV2Quote) {
                
        let index = self.viewModel.tabTypes.firstIndex(of: self.viewModel.selectTabType) ?? 0
        self.viewModel.updateTitlesAndControllers()
        self.segDataSource.titles = self.viewModel.tabTypes.map({$0.title})
        segDataSource.dotStates = Array.init(repeating: false, count: segDataSource.titles.count)
        if index > 0 {
            self.segmentedView.defaultSelectedIndex = index
            self.viewModel.selectTabType = StockDetailViewTabType.init(rawValue: 0) ?? .news
        }
        self.segmentedView.reloadData()
        self.pagingView.reloadData()
    }

}


//MARK: 新股，月供， 债券， 期权请求相关
extension YXStockDetailViewController  {

//
//    func headerRefreshing() {
//        loadQuoteData(true)
//        loadOtherData()
//    }

    func loadOtherData() {
        if !self.isFirstLoad {

            //期权链数量
            loadOptionAggravateData()

            loadShortSellData()
        }
    }

    //加载期权张数（是否有期权）
    func loadOptionAggravateData() {
        //目前只有美股正股有期权
        if self.viewModel.market == YXMarketType.US.rawValue, !self.viewModel.hasOptionChain {
            self.viewModel.services.quotesDataService.request(.optionAggravate(market: self.viewModel.market, code: self.viewModel.symbol), response: self.viewModel.optionAggravateResponse).disposed(by: rx.disposeBag)
        }
    }

    //卖空
    func loadShortSellData() {
//        if self.viewModel.quoteModel?.shortSellFlag?.value ?? false, self.viewModel.market == kYXMarketUS {
//            var userLevel = 1
//            if let userRoleType = YXUserManager.shared().curLoginUser?.userRoleType?.rawValue {
//                userLevel = userRoleType
//            }
//            self.viewModel.services.quotesDataService.request(.shortSell(self.viewModel.symbol, accountLevel: userLevel), response: self.viewModel.shortSellResponse).disposed(by: self.disposeBag)
//        }
    }
    
    func loadNewDiscussData() {

        self.viewModel.requestNewDiscuss().subscribe(onSuccess: {
            [weak self] show in
            guard let `self` = self else { return }
            if show {
                let index = self.segDataSource.titles.firstIndex(of: StockDetailViewTabType.discussions.title)
                if let index = index {
                    self.segDataSource.dotStates[index] = true
                    self.segmentedView.reloadItem(at: index)
                }
            }

            
        }).disposed(by: rx.disposeBag)
    }
    
    
    func loadReminderData() {
        if self.viewModel.market != kYXMarketUsOption {
            let requestModel = YXRemindSettingRequestModel.init()
            requestModel.stockMarket = self.viewModel.market
            requestModel.stockCode = self.viewModel.symbol
            let request = YXRequest.init(request: requestModel)
            request.startWithBlock { response in
                if let data = response.data, response.code == .success {
                    let model = YXReminderListModel.yy_model(withJSON: data)
                    var isHasSetRemind = false
                    if let stockNtfs = model?.stockNtfs {
                        for item in stockNtfs {
                            if item.status == 1 {
                                isHasSetRemind = true
                                break
                            }
                        }
                    }
                    if let stockNtfs = model?.stockForms {
                        for item in stockNtfs {
                            if item.status == 1 {
                                isHasSetRemind = true
                                break
                            }
                        }
                    }
                    
                    self.bottomToolView?.refreshRemindButtonSelectStatus(with: isHasSetRemind)
                }
            } failure: { _ in
                
            }
        }
    }

    func loadMarginData() {
        YXMarginManager.shared.requsetStockCanMargin(stockCode: self.viewModel.symbol, market: self.viewModel.market) { [weak self] res in
            guard let `self` = self else  { return }
            if let res = res {
                self.viewModel.quoteModel?.margin = NumberInt32.init(res.margin)
                self.viewModel.quoteModel?.marginRatio = NumberDouble.init(res.mortgageRatio)
            }
            self.quoteHeaderView.statusView.lablesView.quote = self.viewModel.quoteModel
        }
    }
}


//MARK: 小黄条数据相关
extension YXStockDetailViewController {

    func loadNoticeData() {

        showQuoteNoticeView()
        //暗盘不展示bmp小黄条， 放在行情之后请求
        self.requestNoticeData(urlStr: YXNativeRouterConstant.GOTO_STOCK_QUOTE) { [weak self] datas in
            guard let `self`  = self else { return }
            if datas.count > 0 {
                self.strongNoticeView.dataSource = datas
            }
        } failed: { [weak self] errorMsg in
            guard let `self`  = self else { return }
            let models: [YXNoticeModel] = self.addBmpNoticeIfNoExist()
            if models.count > 0 {
                self.strongNoticeView.dataSource = models
            }
        }
        self.requestTempCodeNotice()
    }

    /// 请求临时代码数据
    func requestTempCodeNotice() {
        if self.viewModel.market == YXMarketType.HK.rawValue {
            let oldTime = MMKV.default().double(forKey: "YXStockDetailTempCodeKey-" + self.viewModel.symbol, defaultValue: 0)
            let nowTime = Date().timeIntervalSince1970
            if nowTime - oldTime > 24 * 60 * 60 {

                self.viewModel.tempCodeRequestSignal.subscribe(onSuccess: {
                    [weak self] tempText in
                    guard let `self` = self else { return }
                    if let text = tempText, !text.isEmpty {

                        let dic = ["clickClose": "1"] as NSDictionary
                        let str = dic.yy_modelToJSONString()
                        let tempCodeModel = YXNoticeModel.init(msgId: 0, title: "", content: text, pushType: .none, pushPloy: str ?? "", msgType: 0, contentType: 0, startTime: 0.0, endTime: 0.0, createTime: 0.0, newFlag: 0)
                        tempCodeModel.isTempCode = true

                        var models: [YXNoticeModel] = self.addBmpNoticeIfNoExist()
                        models.append(tempCodeModel)
                        self.strongNoticeView.dataSource = models
                    }
                }).disposed(by: rx.disposeBag)
            }
        }
    }


    // 获取bmp小黄条数据
    func addBmpNoticeIfNoExist() -> [YXNoticeModel] {

        var models: [YXNoticeModel] = []
        if self.strongNoticeView.dataSource.count > 0 {
            models = self.strongNoticeView.dataSource
        }

        if stockDetailShowTip && self.viewModel.level == .bmp {

            var hasBmp = false
            if self.strongNoticeView.dataSource.count > 0 {
                for model in self.strongNoticeView.dataSource {
                    if model.isBmp {
                        hasBmp = true
                        break
                    }
                }
            }

            if (!hasBmp) {
                let dic = ["clickClose": "1"] as NSDictionary
                let str = dic.yy_modelToJSONString()
                let bmpTip = YXNoticeModel.init(msgId: 0, title: "", content: YXLanguageUtility.kLang(key: "stock_detail_bmpTip"), pushType: .none, pushPloy: str ?? "", msgType: 0, contentType: 0, startTime: 0.0, endTime: 0.0, createTime: 0.0, newFlag: 0)
                bmpTip.isBmp = true

                models.append(bmpTip)
            }

        }
        return models
    }

    func showQuoteNoticeView() {

        let status = Int(self.viewModel.quoteModel?.trdStatus?.value ?? OBJECT_QUOTETradingStatus.tsNormal.rawValue)
        if status == OBJECT_QUOTETradingStatus.tsUnlisted.rawValue || self.viewModel.greyFlag {
            return
        }

        if self.viewModel.market == kYXMarketHK || self.viewModel.market == kYXMarketUS {

            if YXQuoteKickTool.shared.isQuoteLevelKickToDelay(self.viewModel.market) {

                var isShow = false
                for model in self.strongNoticeView.dataSource {
                    if model.isQuoteKicks {
                        isShow = true
                        break
                    }
                }

                if isShow {
                    return
                }

                let content = YXLanguageUtility.kLang(key: "quote_kick_message")
                let str = YXLanguageUtility.kLang(key: "quote_kick_regot")

                let dic = ["clickClose": "0"] as NSDictionary
                let noticeModel = YXNoticeModel.init(msgId: 0, title: "", content: content, pushType: .none, pushPloy: dic.yy_modelToJSONString() ?? "", msgType: 0, contentType: 0, startTime: 0.0, endTime: 0.0, createTime: 0.0, newFlag: 0)
                noticeModel.isQuoteKicks = true

                let attrM = NSMutableAttributedString.init(string: content, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1()])

                attrM.addAttributes([NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue], range: (content as NSString).range(of: str))

                noticeModel.attributeContent = attrM

                if self.strongNoticeView.dataSource.count > 0 {
                    var models: [YXNoticeModel] = self.strongNoticeView.dataSource
                    models.append(noticeModel)
                    self.strongNoticeView.dataSource = models
                } else {

                    self.strongNoticeView.dataSource = [noticeModel]
                }
            }
        }
    }

    func hiddenQuoteNoticeView() {

        if YXQuoteKickTool.shared.currentQuoteLevleIsReal(self.viewModel.market) || !YXUserManager.isLogin() {
            if self.qmui_isViewLoadedAndVisible() {
                var array = self.strongNoticeView.dataSource

                for (index, model) in self.strongNoticeView.dataSource.enumerated() {
                    if model.isQuoteKicks {
                        array.remove(at: index)
                        break;
                    }
                }
                self.strongNoticeView.dataSource = array

                self.setCurrentStock()
            } else {
                self.quoteLevelChange = true
            }
        }
    }

    func handleQuoteKick() {

        let status = Int(self.viewModel.quoteModel?.trdStatus?.value ?? OBJECT_QUOTETradingStatus.tsNormal.rawValue)
        if status == OBJECT_QUOTETradingStatus.tsUnlisted.rawValue || self.viewModel.greyFlag {
            return
        }

        if self.viewModel.market == kYXMarketHK || self.viewModel.market == kYXMarketUS {

            var isShow = false
            for model in self.strongNoticeView.dataSource {
                if model.isQuoteKicks {
                    isShow = true
                    break
                }
            }

            if isShow {
                if YXQuoteKickTool.shared.currentQuoteLevleIsReal(self.viewModel.market) || !YXUserManager.isLogin() {
                    self.hiddenQuoteNoticeView()
                }
            } else {
            
                if YXQuoteKickTool.shared.isQuoteLevelKickToDelay(self.viewModel.market) {
                    if self.qmui_isViewLoadedAndVisible() {
                        self.showQuoteNoticeView()
                        self.setCurrentStock()
                    } else {
                        self.quoteLevelChange = true
                    }
                }
            }
        }
    }
}

//MARK: 股票左右切换逻辑
extension YXStockDetailViewController: UIScrollViewDelegate {


    func confirmNextDataSource(_ isPre: Bool) {

        //确认当前数据源
        if isPre { //上一⻚

            self.viewModel.selectIndex -= 1

            if self.viewModel.selectIndex < 0 {

                self.viewModel.selectIndex = self.viewModel.dataSource.count - 1
            }

        } else { //下一⻚


            self.viewModel.selectIndex += 1

            if self.viewModel.selectIndex >= self.viewModel.dataSource.count {

                self.viewModel.selectIndex = 0
            }
        }

        setCurrentStock()
    }

    func setCurrentStock() {

//        self.viewModel.quoteVC?.cancelRequest()
        self.cancelAllOperations()

        let input: YXStockInputModel = self.viewModel.dataSource[self.viewModel.selectIndex]
        self.viewModel.setCurrentDataSource(input)

        self.resetNavBar()

        // 是否是第一次加载详情
        isFirstLoad = true

        //每次切换股票，重置初始报价界面
        if self.viewModel.quoteModel == nil {
            self.viewModel.tabTypes = [.quote]
            self.segDataSource.titles = self.viewModel.tabTypes.map({$0.title})
            self.segmentedView.reloadData()
            self.pagingView.reloadData()
        }

        loadQuoteData()

        self.networkingHUD.showLoading("", in: self.view)
        if (self.viewModel.dataSource.count > 1 && self.viewModel.selectIndex == self.viewModel.dataSource.count - 1) {
            YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "change_to_last"), in: self.view)
        }
    }


    func cancelAllOperations() {

        YXTimer.shared.cancleTimer(WithTimerName: quoteTimer)
        quoteRequest?.cancel()
        quoteRequest = nil

        if self.strongNoticeView.isHidden == false {
            self.strongNoticeView.isHidden = true
            self.strongNoticeView.dataSource = []
            self.strongNoticeView.snp.updateConstraints { (make) in
                make.height.equalTo(0)
            }
        }
    }

    func resetNavBar() {
        topTitleView?.setDefaultStockInfo(self.viewModel.name, market: self.viewModel.market, symbol: self.viewModel.symbol)
    }
}

// MARK: - BindViewModel
extension YXStockDetailViewController {
    
    func bindViewModel() {

        //期权张数
        self.viewModel.optionAggravateSubject.subscribe(onNext: { [weak self] optionCount in
            guard let `self` = self else { return }
            if optionCount > 0 {
                self.bottomToolView?.resetOptionChainStatus(with: true)
                if !self.viewModel.tabTypes.contains(.optionChain) {
                    self.viewModel.tabTypes.insert(.optionChain, at: 1)
                    
                    var list = Array.init(self.segDataSource.dotStates)
                    list.insert(false, at: 1)
                    self.segDataSource.dotStates = list
                    self.segDataSource.titles = self.viewModel.tabTypes.map({$0.title})
                    self.segmentedView.reloadData()
                    self.pagingView.reloadData()
                }
            }
        }).disposed(by: rx.disposeBag)


        // 月供
        self.viewModel.stockYgExitDataSubject.subscribe(onNext: { [weak self]  _ in
            self?.bottomToolView?.resetMonthlyStatus(with: true)
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        //债券
        self.viewModel.stockBondSubject.subscribe(onNext: { [weak self] showBond in
            guard let `self` = self else { return }
            self.bottomToolView?.resetBondStatus(with: true)
        }).disposed(by: rx.disposeBag)


    }
}

//MARK: NavigationBarItem 点击事件
extension YXStockDetailViewController {
    
    @objc func seachClick(_ sender: UIButton) {

        self.trackViewClickEvent(name: "search_icon")
        self.viewModel.navigator.push(YXModulePaths.pushAggregatedSearch.url, animated: false)
        
    }

    @objc func shareClick() {
        let longUrl = YXQRCodeHelper.appQRString(shareId: "stock_dt", bizid: self.viewModel.marketSymbol)
       // let longUrl = YXH5Urls.introduction()
        self.viewModel.hudSubject.onNext(.loading(nil, false))
        YXShortUrlRequestModel.startRequest(longUrl: longUrl) { qrcodeUrlString in
            self.viewModel.hudSubject.onNext(.hide)

            let image = UIImage.qmui_image(with: CGSize(width: YXConstant.screenWidth, height: YXConstant.screenHeight - YXConstant.tabBarPadding() - 62), opaque: false, scale: 0) { (contextRef) in
                UIApplication.shared.keyWindow?.layer.render(in: contextRef)
            }

            if let imageWidth = image?.cgImage?.width, let imageHeight = image?.cgImage?.height, let scale = image?.scale,
               let qrImage = YXQRCodeHelper.qrCodeImage(with: qrcodeUrlString) {
                let width = CGFloat(imageWidth) / scale;
                let height = CGFloat(imageHeight) / scale

                let shotView = YXStockDetailSnapShotView(qrImage)
                shotView.frame = CGRect(x: 0, y: 0, width: width, height: height + 70)
                shotView.image = image
                self.view.addSubview(shotView)
                
                DispatchQueue.main.async {
                    let shotImage = UIImage.qmui_image(with: shotView)
//                    let shareView = YXShareCommonView(frame: UIScreen.main.bounds)
                    let shareView = YXShareCommonView(frame: UIScreen.main.bounds,sharetype: .image, isShowCommunity:true)
                    shareView.shareImage = shotImage
                    shareView.showShareView()
                    shotView.removeFromSuperview()
                }
            }
        }
    }
}

//MARK: bottomToolView?显示及点击逻辑处理
extension YXStockDetailViewController {

    // 每次执行，都会创建一个新的底部常驻栏，此方法同一只股票只需要执行一次
    func initbottomView(_ quoteModel: YXV2Quote) {
                        
        self.bottomToolView?.removeFromSuperview()
        self.bottomToolView?.isHidden = true
        self.bottomToolView = nil;

        let bottomToolView = StockDetailBottomView()
        self.bottomToolView = bottomToolView
        bottomToolView.isHidden = false
        bottomToolView.setUpSubviews(quoteModel: quoteModel)
        
        self.bottomBgView.addSubview(bottomToolView)
        bottomToolView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(1)
            make.bottom.equalToSuperview().offset(-YXConstant.tabBarPadding())
        }

        self.handlebottomViewClosure()

        YXKlineCalculateTool.shareInstance().isHKIndex = false
        if self.viewModel.stockType == .stIndex, self.viewModel.market == "hk" {
            YXKlineCalculateTool.shareInstance().isHKIndex = true
        }
    }
    
    func configOptionBottomView() {
                
        if let filterView = self.viewModel.optionChainVC?.filterView {
            filterView.removeFromSuperview()
            filterView.isHidden = false
            filterView.backgroundColor = QMUITheme().foregroundColor()
            self.bottomBgView.addSubview(filterView)
            filterView.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview()
                make.top.equalToSuperview().offset(1)
                make.bottom.equalToSuperview().offset(-YXConstant.tabBarPadding())
            }
        }
    }
    
    func handlebottomViewClosure() {
        //交易
        bottomToolView?.normalTradeClosure = { [weak self] _  in
            guard let `self` = self else { return }
            self.pushTradeOrSmart(.normalTrade)
        }

        // 月供
        bottomToolView?.monthlyClosure = { [weak self] _  in
            guard let `self` = self else { return }
            let dic: [String: Any] = [
                YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_MONTHLY_EDIT_URL(symbol: self.viewModel.symbol, exchangeType: self.viewModel.exchangeType.rawValue)
            ]
            self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))

        }
        //bond
        bottomToolView?.bondClosure = { [weak self] _ in
            guard let `self` = self else { return }
            let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.BOND_HOME_PAGE()]
            self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        }

        //提醒
        bottomToolView?.remindClosure = { [weak self] _ in
            guard let `self` = self else { return }
            if !YXUserManager.isLogin() {
                // 未登錄
                let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: nil, vc: self))
                self.viewModel.navigator.push(YXModulePaths.defaultLogin.url, context: context)
            } else {
                var dic: [String : Any] = [:]
                dic["code"] = self.viewModel.symbol
                dic["market"] = self.viewModel.market
                let viewModel = YXStockReminderHomeViewModel.init(services: self.viewModel.navigator, params: dic)
                self.viewModel.navigator.push(viewModel, animated: true)
            }

        }

        //轮证
        bottomToolView?.warrantClosure = { [weak self] _ in
            guard let `self` = self else { return }
            self.trackViewClickEvent(name: "Warrants_Tab")
            var dic: [String : Any] = [:]
            let quoteDate: YXV2Quote? = self.viewModel.quoteModel
            if let type3 = quoteDate?.type3?.value, (type3 == OBJECT_SECUSecuType3.stWarrant.rawValue || type3 == OBJECT_SECUSecuType3.stCbbc.rawValue) {

                if let symbol = quoteDate?.underlingSEC?.symbol, let market = quoteDate?.underlingSEC?.market  {
                    dic["name"] = quoteDate?.underlingSEC?.name ?? ""
                    dic["symbol"] = symbol
                    dic["market"] = market
                    dic["change"] = quoteDate?.underlingSEC?.netchng?.value ?? 0
                    dic["roc"] = quoteDate?.underlingSEC?.pctchng?.value ?? 0
                    dic["now"] = quoteDate?.underlingSEC?.latestPrice?.value ?? 0
                    dic["priceBase"] = quoteDate?.underlingSEC?.priceBase?.value ?? 0
                    dic["warrantType"] = YXStockWarrantsType.bullBear
                }
            } else {
                dic["name"] = self.viewModel.name ?? (quoteDate?.name ?? "")
                dic["symbol"] = self.viewModel.symbol
                dic["market"] = self.viewModel.market
                dic["change"] = quoteDate?.netchng?.value ?? 0
                dic["roc"] = quoteDate?.pctchng?.value ?? 0
                dic["now"] = quoteDate?.latestPrice?.value ?? 0
                dic["priceBase"] = quoteDate?.priceBase?.value ?? 0
                dic["warrantType"] = YXStockWarrantsType.bullBear
            }
            self.viewModel.navigator.push(YXModulePaths.warrantsAndStreet.url, context: dic)
        }

        bottomToolView?.tipClosure = {
            [weak self] tipString in
            guard let `self` = self else { return }
            if !YXUserManager.isLogin() {

                let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: nil, vc: self))
                self.viewModel.navigator.push(YXModulePaths.defaultLogin.url, context: context)
            } else {
                let alertView = YXAlertView.alertView(message: tipString)
                alertView.messageLabel.font = .systemFont(ofSize: 16)
                alertView.messageLabel.textAlignment = .left
                alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_iknow"), style: .default, handler: { (action) in

                }))
                alertView.showInWindow()
            }
        }

        bottomToolView?.selfSelectClosure = { [weak self] sender in
            guard let `self` = self else { return }
            guard let sender = sender else { return }
            
            self.trackViewClickEvent(name: "Watchlists_Tab")
            let item = YXStockDetailItem.init()
            item.market = self.viewModel.market
            item.symbol = self.viewModel.symbol
            if YXSecuGroupManager.shareInstance().containsSecu(item) {
                YXSecuGroupManager.shareInstance().remove(item)
                sender.isSelected = !sender.isSelected
                if let window = UIApplication.shared.delegate?.window, window != nil {
                    YXProgressHUD.showMessage(message: YXLanguageUtility.kLang(key: "search_remove_from_favorite"), inView: window!, buttonTitle: "", delay: 2, clickCallback: nil)
                }
            } else {
                let secu = YXOptionalSecu()
                secu.name = self.viewModel.name ?? ""
                secu.market = self.viewModel.market
                secu.symbol = self.viewModel.symbol
                if let type1 = self.viewModel.type1 {
                    secu.type1 = type1
                }
                if let type2 = self.viewModel.type2 {
                    secu.type2 = type2
                }
                if let type3 = self.viewModel.type3 {
                    secu.type3 = type3
                }

                YXToolUtility.addSelfStockToGroup(secu: secu) { (addResult) in
                    if addResult {
                        sender.isSelected = true
                    } else {
                        sender.isSelected = false
                    }
                }
            }
        }

        bottomToolView?.smartTradeClosure = { [weak self] _ in
            self?.pushTradeOrSmart(.smart)
        }
        bottomToolView?.shareClosure = {
            [weak self] _ in
            guard let `self` = self else { return }
            self.shareClick()
            self.trackViewClickEvent(name: "Share_Tab")
        }

        bottomToolView?.optionChainClosure = {
            [weak self] _ in
            guard let `self` = self else { return }

            self.pushToOptionChainVC()
        }
        
        bottomToolView?.fractionalTradeClosure = {
            [weak self] _ in
            guard let `self` = self else { return }

            ///碎股交易
            self.pushTradeOrSmart(.fractional)
        }
    }
    
    func pushToOptionChainVC() {
        YXToolUtility.handleBusinessWithOptionLevel(excute: {
            [weak self] in
            guard let `self` = self else { return }
            //跳转到期权链页面
            var market: String = self.viewModel.market
            var symbol: String = self.viewModel.symbol
            if self.viewModel.stockType == .stUsStockOpt {
                market = self.viewModel.quoteModel?.underlingSEC?.market ?? ""
                symbol = self.viewModel.quoteModel?.underlingSEC?.symbol ?? ""
            }

            let vm = YXShareOptionsViewModel.init(services: self.viewModel.navigator, params: ["market": market, "code": symbol])
            vm.style = .inMarket
            self.viewModel.navigator.push(vm, animated: true)
        })
    }

    func goToMarginTrade() {
        if YXUserManager.isFinancing(market: self.viewModel.market), YXUserManager.isIntraday(self.viewModel.market) {
            //保证金账户 & 日内融账户
            handleDailyMarginTrade()
        } else {

            let alert = YXStockDetailDailyAuthorityView.init(frame: self.view.bounds, market: self.viewModel.market, superview: self.view)
            var market = YXLanguageUtility.kLang(key: "hold_hk_account")
            if self.viewModel.market == kYXMarketHK {
                market = YXLanguageUtility.kLang(key: "hold_hk_account")
            } else if self.viewModel.market == kYXMarketUS {
                market = YXLanguageUtility.kLang(key: "hold_us_account")
            } else {
                market = YXLanguageUtility.kLang(key: "account_tab_cn")
            }

            alert.contentView.stepOneLabel.text = String(format: YXLanguageUtility.kLang(key: "daily_margin_trade_upgrade1"), market)

            alert.contentView.stepTwoLabel.text = String(format: YXLanguageUtility.kLang(key: "daily_margin_trade_upgrade2"), market)

            alert.contentView.upgradeMarginClosure = {
                [weak self] in
                guard let `self` = self else { return }
                let dic: [String: Any] = [

                    YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_TRADE_ACCOUNT_UPDATE_TO_MARGIN_URL(exchangeType: self.viewModel.exchangeType.rawValue)
                ]
                self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            }

            alert.contentView.openMarginClosure = {
                [weak self] in
                guard let `self` = self else { return }

                let dic: [String: Any] = [

                    YXWebViewModel.kWebViewModelUrl: YXH5Urls.OPEN_DAILY_MARGIN_URL(self.viewModel.exchangeType.rawValue)
                ]
                self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))

            }

            alert.contentView.aboutClosure = {
                [weak self] in
                guard let `self` = self else { return }
                let dic: [String: Any] = [

                    YXWebViewModel.kWebViewModelUrl: YXH5Urls.DAILY_MARGIN_EXPLAIN_URL()
                ]
                self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            }

            alert.showAlertView()


        }
    }

    func handleDailyMarginTrade() {
        // 日内融
    }
    

    func pushTradeOrSmart(_ type: BottomTradeExpandType) {
        if YXUserManager.isLogin() {
            if let quoteData = self.viewModel.quoteModel {
                let market = quoteData.market ?? "none"
                self.checkUserInfo(marketType: YXMarketType(rawValue:market)!, quote: quoteData, type: type)
            }
        } else {
            let loginCallBack: (([String: Any])->Void)? = { [weak self] (userInfo) in
                guard let `self` = self else { return }

                self.viewModel.hudSubject.onNext(.loading(nil, false))
                YXUserManager.getUserInfo(complete: { [weak self] in
                    guard let `self` = self else { return }

                    self.viewModel.hudSubject.onNext(.hide)

                    if let quoteData = self.viewModel.quoteModel {
                        let market = quoteData.market ?? "none"

                        self.checkUserInfo(marketType: YXMarketType(rawValue:market)!, quote: quoteData, type: type)
                    }
                })
            }

            let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: loginCallBack, vc: self))
            self.viewModel.navigator.push(YXModulePaths.defaultLogin.url, context: context)
        }
    }


    func checkUserInfo(marketType: YXMarketType, quote: YXV2Quote, type: BottomTradeExpandType) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // 判断用户当前状态，然后再决定跳转页面
            var canTrade: Bool = false

            if self.viewModel.isAStockMarket {
                if YXUserManager.isOpenHSTrade(with: .hs) {
                    canTrade = true
                }
            } else if YXUserManager.canTrade() {

                canTrade = true
            }
            if canTrade {
                // 满足以下条件之一即可去交易页面
                // 1.已经完成入金
                // 2.已经开户且是非大陆用户

                if type == .dayMargin {
                    self.goToMarginTrade()
                } else if self.viewModel.market == kYXMarketUsOption && !YXUserManager.isOpenUsOption() {//引导去期权开户
                    YXWebViewModel.pushToWebVC(YXH5Urls.OpenUsOptionURL())
                } else {
                    if self.viewModel.quoteModel != nil {
                        if type == .smart {
                            self.trackViewClickEvent(name: "Stock Smart Order_Tab")
                        } else {
                            self.trackViewClickEvent(name: "Trade")
                        }
                        self.viewModel.pushToTrade(type)
                    }
                }

            } else {
                //去开户引导页
                if !YXUserManager.canTrade() {
                    self.trackViewClickEvent(name: "Open Account")
                    let dic: [String: Any] = [

                        YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_OPEN_ACCOUNT_APPLY_URL()
                    ]
                    self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                } else {

                    let alertView = YXAlertView.init(title: YXLanguageUtility.kLang(key: "common_tips"), message: YXLanguageUtility.kLang(key: "trade_china_not_opened"), messageAlignment: .left)
                    alertView.messageLabel.font = .systemFont(ofSize: 16)
                    alertView.messageLabel.textAlignment = .left
                    alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: { (action) in

                    }))

                    alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_open_now"), style: .default, handler: { (action) in

                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: ["index" : YXTabIndex.holding, "moduleTag": 2])
                    }))
                    alertView.showInWindow()

                }

            }
        }
    }


}

// MARK: - 长按k线
extension YXStockDetailViewController {
    
    func configLongPressView() {
        self.klineLongPressView.market = self.viewModel.quoteModel?.market ?? ""
        self.klineLongPressView.setUpUI()
        
        self.timeLineLongPressView.market = self.viewModel.quoteModel?.market ?? ""
        
        if self.viewModel.stockType == .stIndex {
            if self.viewModel.market == YXMarketType.US.rawValue {
                self.klineLongPressView.hiddenAmount()
                self.timeLineLongPressView.hiddenAmount()
            } else if self.viewModel.market == YXMarketType.HK.rawValue {
                self.klineLongPressView.hiddenVolume()
                self.timeLineLongPressView.hiddenVolume()
            }
        }
    }
}

// MARK: - pageView
extension YXStockDetailViewController {
    
    func preferredPagingView() -> JXPagingView {
        return JXPagingView(delegate: self, listContainerType: .scrollView)
    }
    
    func preferredTableHeaderView() -> StockDetaiBaseHeaderView {
        let view = StockDetaiBaseHeaderView.init(frame: CGRect.init(x: 0, y: 0, width: YXConstant.screenWidth, height: CGFloat(tableHeaderViewHeight)))
        
        view.heightChangeCallBack = { [weak self] animate, height in

            guard let `self` = self else { return }
            let finalHeight = Int(height)
            if finalHeight != self.tableHeaderViewHeight {
                
                self.tableHeaderViewHeight = finalHeight
                self.pagingView.resizeTableHeaderViewHeight(animatable: true)
            }
        }
        return view
    }
}

extension YXStockDetailViewController: JXSegmentedViewDelegate {
    
    func pagingView(_ pagingView: JXPagingView, initListAtIndex index: Int) -> JXPagingViewListViewDelegate {
        let type = self.viewModel.tabTypes[index]
        let vc = self.viewModel.getSubViewController(with: type)
        if vc is JXPagingViewListViewDelegate {
            let finalVC = vc as! (UIViewController & JXPagingViewListViewDelegate)
            finalVC.endRefreshCallBack = { [weak self] in
                self?.pagingView.mainTableView.mj_header.endRefreshing()
            }            
            if type == .optionChain {
                configOptionBottomView()
            }
            
            // 为报价页设置父控制器
            if type == .quote {
                if let quoteVC = finalVC as? YXStockDetailQuoteVC {
                    quoteVC.parentVC = self
                    
                    /// 设置回调
                    quoteVC.klineLongPressCallBack = { [weak self] chartView, isShow, kline in
                        guard let `self` = self else { return }
                        if isShow {
                            let point = self.view.convert(CGPoint.init(x: 0, y: 39), from: chartView)
                            self.klineLongPressView.mj_y = point.y - self.klineLongPressView.mj_h
                            self.klineLongPressView.isHidden = false
                            if let lineModel = kline {
                                self.klineLongPressView.kLineSingleModel = lineModel
                            }
                        } else {
                            self.klineLongPressView.isHidden = true
                        }
                    }
                      
                    quoteVC.timeLineLongPressCallBack = { [weak self] chartView, isShow, timeLine in
                        guard let `self` = self else { return }
                        if isShow {
                            let point = self.view.convert(CGPoint.init(x: 0, y: 39), from: chartView)
                            self.timeLineLongPressView.mj_y = point.y - self.timeLineLongPressView.mj_h
                            self.timeLineLongPressView.isHidden = false
                            if let lineModel = timeLine {
                                self.timeLineLongPressView.timeSignalModel = lineModel
                            }
                        } else {
                            self.timeLineLongPressView.isHidden = true
                        }
                    }
                    
                }
            }
            
            return finalVC
        }
        
        return self.viewModel.getSubViewController(with: .quote) as! JXPagingViewListViewDelegate
    }
    
    func pagingView(_ pagingView: JXPagingView, mainTableViewDidScroll scrollView: UIScrollView) {
        
        self.topTitleView?.scrollToTop(scrollView.contentOffset.y > 65)
        
    }

    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {

        let state = self.segDataSource.dotStates[index]
        if state {
            self.segDataSource.dotStates[index] = false
            self.segmentedView.reloadItem(at: index)
        }
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = (index == 0)
        
        if index < self.viewModel.tabTypes.count {
                                    
            let type = self.viewModel.tabTypes[index]
            if type == .financials {
                // 财务
                self.trackViewClickEvent(name: "Financials_Tab", other: [:])
            } else if type == .discussions {
                // 讨论
                self.trackViewClickEvent(name: "Discussions_Tab", other: [:])
            } else if type == .news {
                // 新闻
            } else if type == .announcements {
                // 公告
                self.trackViewClickEvent(name: "Annoucement_Tab", other: [:])
            } else if type == .profile {
                // 简况
                self.trackViewClickEvent(name: "Profile_TAB", other: [:])
            }
                        
            // 处理底部view逻辑
            if type == .optionChain {
                self.bottomToolView?.isHidden = true
                self.viewModel.optionChainVC?.filterView.isHidden = false
            } else {
                self.bottomToolView?.isHidden = false
                self.viewModel.optionChainVC?.filterView.isHidden = true
            }
        }
    }
}

extension YXStockDetailViewController: JXPagingViewDelegate {

    func tableHeaderViewHeight(in pagingView: JXPagingView) -> Int {
        return tableHeaderViewHeight
    }

    func tableHeaderView(in pagingView: JXPagingView) -> UIView {
        return quoteHeaderView
    }

    func heightForPinSectionHeader(in pagingView: JXPagingView) -> Int {
        return headerInSectionHeight
    }

    func viewForPinSectionHeader(in pagingView: JXPagingView) -> UIView {
        return sectionView
    }

    func numberOfLists(in pagingView: JXPagingView) -> Int {
        return self.viewModel.tabTypes.count
    }
}

extension YXStockDetailViewController: JXPagingMainTableViewGestureDelegate {
    func mainTableViewGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        //禁止segmentedView左右滑动的时候，上下和左右都可以滚动
        if otherGestureRecognizer == segmentedView.collectionView.panGestureRecognizer {
            return false
        }
        return gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self)
    }
}


