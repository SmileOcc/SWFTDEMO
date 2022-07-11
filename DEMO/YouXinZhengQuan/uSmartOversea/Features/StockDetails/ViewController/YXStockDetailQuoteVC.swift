//
//  YXStockDetailQuoteVC.swift
//  uSmartOversea
//
//  Created by youxin on 2020/12/21.
//  Copyright © 2020 RenRenDai. All rights reserved.
//
import YXKit
import SwiftyJSON
import RxSwift
import RxCocoa
import UIKit
import JXPagingView

extension YXTimeShareLineType {
    
    var quoteType: QuoteType {
        
        switch self {
        case .all:
            return .sQuoteAll
        case .pre:
            return .pre
        case .after:
            return .after
        default:
            return .intraDay
        }
    }
}

class YXStockDetailQuoteVC: YXHKViewController, HUDViewModelBased {

    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    typealias ViewModelType = YXStockDetailQuoteViewModel
    var viewModel: ViewModelType!

    //MARK: 请求相关变量
    var tickRequest: YXQuoteRequest?
    var statisticalRequest: YXQuoteRequest?
    var hightTimelineRequest: YXQuoteRequest?
    var highKlineRequest: YXQuoteRequest?
    var underlineQuoteRequest: YXQuoteRequest?
    var depthOrderRequest: YXQuoteRequest?
    var depthChartRequest: YXQuoteRequest?
    
    var posBrokerRequest: YXQuoteRequest?
    //MARK: 视图展示相关变量

    weak var parentVC: YXStockDetailViewController?

    var historyTimelineView: YXTimeLineHistoryView?
    var historyTimeLineInterval: TimeInterval = 0
    var historyRequestTime: Int64 = 0
    
    //MARK: 行情 及 状态记录 相关变量

    // 市場狀態timer
    let httpTimer = "YXStockDetailAnalyzeVCTimer"

    // 是否是第一次加载详情
    var isFirstLoad = true

    //是否K线加载更多
    var isKlineLoadingMore = false

    //登录态是否发生变化
    var loginStateChange: Bool = false

    var needLoadHoldAsset = false //是否需要加载用户持仓成本信息字段

    var hasRemoveKlineOrderCache = false //是否需要移除K线缓存

    var orientationBag: DisposeBag?
    
    var analyzeVC: YXStockDetailBrokerAnalyzeVC?
    
    var klineLongPressCallBack:((YXStockDetailLineView, _ isShow: Bool, _ kline: YXKLine?) -> ())?
    
    var timeLineLongPressCallBack:((YXStockDetailLineView, _ isShow: Bool, _ timeLine: YXTimeLine?) -> ())?
    
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
        // 重置权限
        YXKLineConfigManager.shareInstance().hasUsmartLimit = true
        self.edgesForExtendedLayout = [.top, .left, .right]

        self.bindHUD()

        initUI()

        bindViewModel()

        //监听K线设置界面更改
        _ = NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: "KLineSettingChanged"))
            .takeUntil(self.rx.deallocated) //页面销毁自动移除通知监听
            .subscribe(onNext: { [weak self] noti in
                guard let `self` = self else { return }

                self.headerView.chartView.accessoryView.setUpUI()
            }).disposed(by: rx.disposeBag)

        _ = NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: YXQuoteTipHelper.kNotificationName))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] notic in
                guard let `self` = self else{ return }
                self.updateUIByLoginState()
            }).disposed(by: rx.disposeBag)
        
        _ = NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: YXUserManager.notiUpdateUserInfo))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] notic in
                guard let `self` = self else{ return }
                self.updateUIByLoginState()
            }).disposed(by: rx.disposeBag)
        

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        resetAppearStatus()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //旋转横屏，目前只在报价页面生效
//        observerDeviceRotate()
        if YXStockDetailTool.isShowAskBid(self.viewModel.quoteModel) && self.viewModel.market == kYXMarketUS {
            self.posStatisticsView.askBidView.usPosButton.resetPosQuote()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        cancelRequest()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.orientationBag = nil
        
        hidePopView()
    }
    
    func hidePopView() {
        if self.historyTimelineView != nil {
            hiddenHistoryTimeLineView()
        }
    }

    //登录状态变化更新UI
    func updateUIByLoginState() {
        if let quoteModel = self.viewModel.quoteModel {
            //更新tickview
            self.headerView.chartView.updateTickView(self.viewModel.quoteModel)
            self.updateUIHidden()
            self.posStatisticsView.quote = quoteModel
        }

        self.chipView.level = YXUserManager.shared().getLevel(with: self.viewModel.market)

        if self.viewModel.market == kYXMarketCryptos {
            self.btDealView.isHidden = false
            self.btDealView.snp.updateConstraints { (make) in
                make.height.equalTo(434)
            }
        }
    }

    //重置变量
    func resetAppearStatus() {

        //線的數據
        let type = YXKLineConfigManager.shareInstance().lineType
        if type != self.headerView.chartView.lineType {
            //同步横屏图表类型
            self.headerView.chartView.reloadSelectTable()
        }
        //横竖屏切换时（横屏可能停留很久），竖屏时需要重新加载分时，K线数据
        loadHttpData()
        self.needLoadHoldAsset = true
        YXStockDetailTool.removeFirstKLineOrderCache(self.headerView.chartView.kLineView.klineModel)

        if !self.isFirstLoad {
            self.headerView.chartView.accessoryView.resetMainAndSubStatus()
            self.headerView.chartView.setCurrentLineTypeHeight()
        }
    }

    //用于弹窗设置 K线类型，复权类型，买卖点，持仓线，现价线改变 更新K线
    func refreshKLine() {
//        self.headerView.chartView.loadingView.isHidden = false
        self.headerView.chartView.isHkIndex = self.viewModel.isHKIndexStock

        self.needLoadHoldAsset = true
        YXStockDetailTool.removeFirstKLineOrderCache(self.headerView.chartView.kLineView.klineModel)
        // 高级k线
        self.loadHighLineData()

        loadChipData()
    }

    //转屏只在报价页面生效，切换到其他页面不自动转屏
    func observerDeviceRotate() {

        self.orientationBag = nil
        self.orientationBag = DisposeBag()
        if let dispoaseBag = self.orientationBag {
            NotificationCenter.default.rx.notification(UIDevice.orientationDidChangeNotification).subscribe(onNext: {
                [weak self] noti in
                guard let `self` = self else { return }
                let orientation = UIDevice.current.orientation
                if orientation == .landscapeLeft || orientation == .landscapeRight {
                    self.parentVC?.pushToLandscapeVC(with: self.getDayTimeLineType())
                }

            }).disposed(by: dispoaseBag)
        }
    }


    func cancelRequest() {

        tickRequest?.cancel()
        tickRequest = nil
        statisticalRequest?.cancel()
        statisticalRequest = nil

        hightTimelineRequest?.cancel()
        hightTimelineRequest = nil
        highKlineRequest?.cancel()
        highKlineRequest = nil


        underlineQuoteRequest?.cancel()
        underlineQuoteRequest = nil
        
        depthOrderRequest?.cancel()
        depthOrderRequest = nil
        
        depthChartRequest?.cancel()
        depthChartRequest = nil
        
        posBrokerRequest?.cancel()
        posBrokerRequest = nil

        closeTimer()
        
        hidePopView()
    }

    func initUI() {

        self.view.backgroundColor = QMUITheme().foregroundColor()

        self.view.addSubview(self.contentScrollView)
        self.contentScrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.contentScrollView.addSubview(self.stackView)
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(YXConstant.screenWidth)
        }
        
        self.stackView.addArrangedSubview(self.headerView)
        self.headerView.snp.makeConstraints { make in
            make.height.equalTo(self.headerView.totalHeight)
        }
        
        self.stackView.addArrangedSubview(self.posStatisticsView)
        self.posStatisticsView.snp.makeConstraints { make in
            make.height.equalTo(self.posStatisticsView.height)
        }
        
        self.stackView.addArrangedSubview(self.chipView)
        self.chipView.snp.makeConstraints { make in
            make.height.equalTo(194)
        }
        
        self.stackView.addArrangedSubview(self.cashFlowView)
        self.stackView.addArrangedSubview(self.tradingView)
        self.cashFlowView.snp.makeConstraints { make in
            make.height.equalTo(246)
        }
        self.tradingView.snp.makeConstraints { make in
            make.height.equalTo(472)
        }
        
        self.headerView.chartView.isCryptos = (self.viewModel.market == kYXMarketCryptos)

//        self.contentScrollView.rx.contentOffset.subscribe(onNext: {
//            [weak self] contentOffset in
//            guard let `self` = self else { return }
//            self.parentVC?.scrollNavTitleView(isTop: contentOffset.y > 65)
//        }).disposed(by: self.rx.disposeBag)

    }
    
    override func jx_refreshData() {
        if self.headerView.chartView.holdPrice <= 0 {
            self.needLoadHoldAsset = true
        }
        self.loadServerData()
    }
        

    //加载数据
    func loadServerData() {
        self.loadHttpData()
    }
    
    //加载tick、分时、k线数据 (横屏切换回到竖屏时（在横屏停留了很久），需重新加载分时K线数据，保持最新）
    func loadChartLineData() {

        if !self.isFirstLoad {
            self.headerView.chartView.loadingView.isHidden = false
            self.headerView.chartView.isHkIndex = self.viewModel.isHKIndexStock
            // 高级k线
            self.loadHighLineData()
            self.loadTickData()
            self.loadPosBrokerData()
            self.loadStatisticalData()

            self.loadDepthTradeData()
            self.loadDepthChartData()
        }
    }

    func loadHttpData() {
        if !self.isFirstLoad {
            //加载tick、分时、k线数据
            loadChartLineData()
            //多空信号
            loadWarrantCbbcData()
            //成交分布
            loadCapitalData()
            //资金流水
            loadCashFlowData()
            //筹码分布
            loadChipData()
            self.openTimer()
        }
    }

//    func endRefresh() {
//        self.endRefreshCallBack?()
//    }

    //MARK:- **** 更新行情Detail ****
    func updateQuoteInfo(_ quoteModel: YXV2Quote, scheme: Scheme) {

//        if scheme == .http {
//            endRefresh()
//        }

        self.viewModel.quoteModel = quoteModel
        if self.viewModel.type1 == nil {
            self.viewModel.type1 = quoteModel.type1?.value ?? 0
            self.viewModel.type2 = quoteModel.type2?.value ?? 0
            self.viewModel.type3 = quoteModel.type3?.value ?? 0
        }

        if let name = self.viewModel.name, !name.isEmpty {

        } else {
            self.viewModel.name = quoteModel.name
        }

        //优先判断是否是暗盘
        if let value = quoteModel.greyFlag?.value, value != 0 {
            self.viewModel.greyFlag = true;
        }

        if self.isFirstLoad {
            self.isFirstLoad = false
            
            YXKLineConfigManager.shareInstance().timeShareType = YXStockDetailUtility.getTimeShareType(with: quoteModel)
            if self.viewModel.market == kYXMarketUsOption {
                YXKLineConfigManager.shareInstance().lineType = YXStockDetailUtility.resetOptionKline(YXKLineConfigManager.shareInstance().lineType)
            }
            // 是否有盘前盘后分时
            if !YXStockDetailUtility.canSupportTimelineExpand(quoteModel) {
                self.headerView.chartView.klineTabView.hasTsExpand = false
            } else {
                self.headerView.chartView.klineTabView.hasTsExpand = true
                self.headerView.chartView.klineTabView.subTsType = YXKLineConfigManager.shareInstance().timeShareType
            }

            // 股票确认的时候, 选择usmart的话,重置MA
            var needResetMa = false
            if YXKLineConfigManager.shareInstance().mainAccessory == .usmart {
                needResetMa = true
                if needResetMa {
                    YXKLineConfigManager.shareInstance().mainAccessory = .MA
                }
            }
            self.headerView.quoteModel = quoteModel
            
            if self.viewModel.greyFlag {
                self.headerView.chartView.kLineView.hideHistoryTimeLine = true
            }

            if let type2 = OBJECT_SECUSecuType2(rawValue: Int32(quoteModel.type2?.value ?? 0)),
               (type2 == .stHighAdr || type2 == .stLowAdr) {
                self.viewModel.isADR = true
                if type2 == .stLowAdr {
                    self.viewModel.isLowADR = true
                }
            }

            //放在加载分时K线之前执行，有重置图表类型的操作
            if self.viewModel.stockType == .stUsStockOpt {
                self.headerView.chartView.tickStatisticalView.isOptionStock = true
                self.headerView.chartView.isOptionStock = true
                self.headerView.chartView.kLineView.hideHistoryTimeLine = true
            }

            if YXStockDetailTool.isGemStock(quoteModel) {
                self.viewModel.isTecBoard = true
                self.headerView.chartView.timeLineView.isGem = true
            }
            
            self.showAnalyzeView()
            
            //确认盘口字段
            self.updateUIHidden()
            self.posStatisticsView.quote = quoteModel
            self.headerView.chartView.updateTickView(quoteModel)
            self.loadHttpData()


        } else {
            self.headerView.quoteModel = quoteModel
        }
        if scheme == .http {
            // 简况
            if self.viewModel.stockType == .stCbbc || self.viewModel.stockType == .stWarrant || self.viewModel.stockType == .stInlineWarrant || self.viewModel.stockType == .stSgWarrant {
                self.handleRelateStock(quoteModel)
            } else if (quoteModel.related != nil) {
                self.handleRelateStock(quoteModel)
            } else if (self.viewModel.stockType == .stUsStockOpt) {
                self.handleRelateStock(quoteModel)
            }
        }

    }

    //处理轮证，界内证，期权等关联正股行情
    func handleRelateStock(_ quoteModel: YXV2Quote) {
        if let underlineQuote = quoteModel.underlingSEC {

            if self.underlineQuoteRequest == nil {
                // 请求关联正股信息
                self.loadUnderlisngQuoteData(underlineQuote)
            }
        } else if let related = quoteModel.related {
            if self.underlineQuoteRequest == nil {
                // 请求相关资产的信息
                self.loadRelatedQuoteData(market: related.market ?? "", symbol: related.symbol ?? "")
            }
        }
    }

    //行情
    func loadUnderlisngQuoteData(_ quoteModel: UnderlingSEC) {

        if let market = quoteModel.market, !market.isEmpty,
           let symbol = quoteModel.symbol, !symbol.isEmpty {
            underlineQuoteRequest?.cancel()
            underlineQuoteRequest = YXQuoteManager.sharedInstance.subRtSimpleQuote(secus: [Secu(market: market, symbol: symbol)], level: YXUserManager.shared().getLevel(with: market), handler: ({ [weak self] (quotes, scheme) in
                guard let `self` = self else { return }
                if let quote = quotes.first {
                    self.viewModel.quoteModel?.underlingSEC?.pctchng = quote.pctchng
                    self.viewModel.quoteModel?.underlingSEC?.netchng = quote.netchng
                    self.viewModel.quoteModel?.underlingSEC?.latestPrice = quote.latestPrice
                    self.viewModel.quoteModel?.underlingSEC?.priceBase = quote.priceBase
                    self.headerView.extraQuoteView.underlingSec = self.viewModel.quoteModel?.underlingSEC
                }
            }))
        }

    }


    //行情
    func loadRelatedQuoteData(market: String, symbol: String) {

        if !market.isEmpty, !symbol.isEmpty {
            underlineQuoteRequest?.cancel()
            underlineQuoteRequest = YXQuoteManager.sharedInstance.subRtSimpleQuote(secus: [Secu(market: market, symbol: symbol)], level: YXUserManager.shared().getLevel(with: market), handler: ({ [weak self] (quotes, scheme) in
                guard let `self` = self else { return }
                if let quote = quotes.first {
                    self.headerView.extraQuoteView.relatedQuote = quote
                }
            }))
        }

    }

    // 加载高级画图数据
    func loadHighLineData() {
        let type = YXKLineConfigManager.shareInstance().lineType
        self.viewModel.highLineType = YXStockDetailTool.lineTypeString(type)
        if type == .dayTimeLine || type == .fiveDaysTimeLine {
            self.loadHighTimeLineData()
        } else {
            self.loadHighKLineData()
        }

    }

    // 高级分時
    func loadHighTimeLineData() {

        highKlineRequest?.cancel()
        hightTimelineRequest?.cancel()
        hightTimelineRequest = nil
                
        if self.viewModel.market == kYXMarketCryptos {
            loadBTTimeLineData()
            return
        }

        var userLevel = self.viewModel.level
        if self.viewModel.greyFlag {
            userLevel = .delay
        }
                
        
        var timeLineType: YXTimeShareLineType = .intra
        if self.headerView.chartView.klineTabView.rtLineType == .dayTimeLine {
            timeLineType = self.getDayTimeLineType()
        } else {
            if let quoteModel = self.viewModel.quoteModel {
                timeLineType = YXStockDetailUtility.getFiveDayTimeShareType(with: quoteModel)
            }
        }
        
        let quoteType: QuoteType = self.getDayTimeLineType().quoteType
        
        if quoteType == .sQuoteAll {
            hightTimelineRequest = YXQuoteManager.sharedInstance.subFullTimeLineQuote(secu: Secu(market: self.viewModel.market, symbol: self.viewModel.symbol, extra: self.viewModel.extra), days: self.viewModel.highLineType, level: userLevel, type: quoteType, handler: ({ (timelineModel, scheme) in

                if scheme == .tcp {
                    self.timeLineTcpFilter.onNext(timelineModel)
                    return
                }
                self.updateTimelineData(timelineModel, scheme: scheme)

            }) ,failed: ( { [weak self] in
                guard let `self` = self else { return }
                self.headerView.chartView.loadingView.isHidden = true
                self.headerView.chartView.refreshTimeLineView(nil)
            }))
        } else {
            hightTimelineRequest = YXQuoteManager.sharedInstance.subTimeLineQuote(secu: Secu(market: self.viewModel.market, symbol: self.viewModel.symbol, extra: self.viewModel.extra), days: self.viewModel.highLineType, level: userLevel, type: quoteType, handler: ({ (timelineModel, scheme) in

                if scheme == .tcp {
                    self.timeLineTcpFilter.onNext(timelineModel)
                    return
                }

                self.updateTimelineData(timelineModel, scheme: scheme)
            }) ,failed: ( { [weak self] in
                guard let `self` = self else { return }
                self.headerView.chartView.loadingView.isHidden = true
                self.headerView.chartView.refreshTimeLineView(nil)
            }))
        }
    }
    
    func updateTimelineData(_ timelineModel: YXTimeLineData, scheme: Scheme) {
        // 赋值
        if YXKLineConfigManager.shareInstance().timeShareType == .intra || YXKLineConfigManager.shareInstance().timeShareType == .none {
            if let quote = self.viewModel.quoteModel, let priceBase = quote.priceBase?.value,
               let high = quote.high?.value, let low = quote.low?.value {

                let priceBasic: Double = pow(10.0, Double(priceBase) * 1.0)
                self.headerView.chartView.timeLineView.high = Double(high) / priceBasic
                self.headerView.chartView.timeLineView.low = Double(low) / priceBasic
            }
        } else {
            self.headerView.chartView.timeLineView.high = 0
            self.headerView.chartView.timeLineView.low = 0
        }
        
        var change = 0
        if let pctchng = self.viewModel.quoteModel?.pctchng?.value {
            if pctchng > 0 {
                change = 1
            } else if pctchng < 0 {
                change = -1
            }
         }
        self.headerView.chartView.timeLineView.change = change
        
        self.headerView.chartView.isHkIndex = self.viewModel.isHKIndexStock
        self.headerView.chartView.refreshTimeLineView(timelineModel)
        self.headerView.chartView.loadingView.isHidden = true

        if YXKLineConfigManager.shareInstance().lineType == .dayTimeLine, let lineData = timelineModel.list?.last, let time1 = lineData.latestTime?.value, let time2 = self.viewModel.lastTimelineData?.latestTime?.value, time1 == time2 {
            lineData.klineEvents = self.viewModel.lastTimelineData?.klineEvents
        }
        if scheme == .http {
            self.viewModel.loadTimeLineOrderData(timelineModel)
        }
    }

    func loadBTTimeLineData() {
        hightTimelineRequest?.cancel()
        highKlineRequest?.cancel()
        highKlineRequest = nil
 
        var type = YXKLineConfigManager.shareInstance().lineType
        if type == .dayTimeLine {
            type = .oneMinKline
        } else if type == .fiveDaysTimeLine {
            type = .fiveMinKline
        }
        self.viewModel.highLineType = YXStockDetailTool.lineTypeString(type)

        highKlineRequest = YXQuoteManager.sharedInstance.subKLineQuote(secu: Secu(market: self.viewModel.market, symbol: self.viewModel.symbol, extra: self.viewModel.extra), type: OBJECT_QUOTEKLineType.init(rawValue: Int32(self.viewModel.highLineType) ?? 1) ?? .ktMin1, direction: self.viewModel.direction, level: self.viewModel.level, count: 1440, handler: ({ [weak self](klineData, scehme) in
            guard let `self` = self else { return }

            if scehme == .tcp {
                self.btTimeLineTcpFilter.onNext(klineData)
                return
            }
           
            self.updateBTTimeLineData(klineData)

        }), failed: ({ [weak self] in
            guard let `self` = self else { return }
            self.headerView.chartView.loadingView.isHidden = true
            self.headerView.chartView.refreshBTTimeLineView(nil)
        }))
    }
    
    func updateBTTimeLineData(_ klineData: YXKLineData) {
        // 赋值
        if let quote = self.viewModel.quoteModel,
           let highStr = quote.btRealTime?.high, let high = Double(highStr),
           let lowStr = quote.btRealTime?.low, let low = Double(lowStr) {

            self.headerView.chartView.btTimeLineView.decimalCount = YXToolUtility.btDecimalPoint(quote.btRealTime?.now)
            self.headerView.chartView.btTimeLineView.high = high
            self.headerView.chartView.btTimeLineView.low = low
        }
        var change = 0
        if let pctchngStr = self.viewModel.quoteModel?.btRealTime?.pctchng, let pctchng = Double(pctchngStr) {
            if pctchng > 0 {
                change = 1
            } else if pctchng < 0 {
                change = -1
            }
         }
        self.headerView.chartView.btTimeLineView.change = change
        
        self.headerView.chartView.isHkIndex = self.viewModel.isHKIndexStock
        self.headerView.chartView.refreshBTTimeLineView(klineData)
        self.headerView.chartView.loadingView.isHidden = true
    }


    // 高级k线
    func loadHighKLineData() {

        hightTimelineRequest?.cancel()
        highKlineRequest?.cancel()
        highKlineRequest = nil
        var userLevel = self.viewModel.level
        if self.viewModel.greyFlag {
            userLevel = .delay
        }
        highKlineRequest = YXQuoteManager.sharedInstance.subKLineQuote(secu: Secu(market: self.viewModel.market, symbol: self.viewModel.symbol, extra: self.viewModel.extra), type: OBJECT_QUOTEKLineType.init(rawValue: Int32(self.viewModel.highLineType) ?? 7) ?? .ktDay, direction: self.viewModel.direction, level: userLevel, handler: ({ [weak self](klineData, scehme) in
            guard let `self` = self else { return }

            self.viewModel.kLineData = klineData
            if self.viewModel.market == kYXMarketCryptos {
                self.headerView.chartView.kLineView.decimalCount = YXToolUtility.btDecimalPoint(self.viewModel.quoteModel?.btRealTime?.now)
            }
            if self.isKlineLoadingMore { //加载更多时，缓存tcp数据，等加载更多数据回来一起刷新
                self.viewModel.kLineData = klineData
                return
            }

            if !self.hasRemoveKlineOrderCache, YXKLineConfigManager.shareInstance().lineType == .dayKline { //第一次数据加载时移除订单信息，防止测试切换不同环境，还显示上一个环境的数据
                self.hasRemoveKlineOrderCache = true
                YXStockDetailTool.removeAllKLineOrderCache(klineData)
            }
            //tcp 推送时最新一条数据会被替换掉，需要更新其订单信息
            if YXKLineConfigManager.shareInstance().lineType == .dayKline,
               let lineData = klineData.list?.last,
               let time1 = lineData.latestTime?.value,
               let time2 = self.viewModel.lastKlineData?.latestTime?.value,
               time1 == time2 {

                lineData.klineEvents = self.viewModel.lastKlineData?.klineEvents
            }
            if scehme == .http {
                self.viewModel.loadKLineOrderData(klineData)
            }
            
            YXKlineCalculateTool.shareInstance().calAccessoryValue(klineData)
            self.headerView.chartView.refreshKLineView(klineData)
            self.headerView.chartView.loadingView.isHidden = true
            
        }), failed: ({ [weak self] in
            guard let `self` = self else { return }
            if self.isKlineLoadingMore {
                return
            }
            self.headerView.chartView.loadingView.isHidden = true
            self.headerView.chartView.refreshKLineView(nil)
        }))

    }

    func loadCapitalData() {
        if isShowCashFlow() {
            self.viewModel.analyzeService.request(.capital(self.viewModel.market + self.viewModel.symbol), response: self.viewModel.capitalResponse).disposed(by: self.disposeBag)
        }
    }

    func loadCashFlowData() {
        if isShowCashFlow() {
            self.viewModel.analyzeService.request(.cashFlow(self.viewModel.market + self.viewModel.symbol), response: self.viewModel.cashFlowResponse).disposed(by: self.disposeBag)
        }
    }

    func loadChipData() {
    
        if YXUserManager.isLogin(), self.viewModel.level.rawValue >= QuoteLevel.bmp.rawValue,  YXStockDetailTool.isShowCYQ(self.viewModel.quoteModel) {
            YXCYQRequestTool.shared.requestCYQData(self.viewModel.market + self.viewModel.symbol, timeInterval: 0, rights: YXKLineConfigManager.shareInstance().adjustType.rawValue, completion: {
                [weak self] (model, time) in
                guard let `self` = self else { return }
                if let count = model?.list?.count, count > 0 {
                    self.chipView.model = model
                }
            })
        }
    }

    // tick
    func loadTickData() {
        guard YXStockDetailTool.isShowTick(self.viewModel.quoteModel) else { return }
        tickRequest?.cancel()
                
        let quoteType = self.getDayTimeLineType().quoteType
        
        
        if quoteType == .sQuoteAll {
            tickRequest = YXQuoteManager.sharedInstance.subFullTickQuote(secu: Secu(market: self.viewModel.market, symbol: self.viewModel.symbol, extra: self.viewModel.extra), level: self.viewModel.level, type: quoteType, handler: ({ [weak self] (tickModel, scheme) in
                guard let `self` = self else { return }

                if scheme == .tcp {
                    self.tickTcpFilter.onNext(tickModel)
                    return
                }
                self.updateTickData(tickModel)
                
            }))
        } else {
            tickRequest = YXQuoteManager.sharedInstance.subTickQuote(secu: Secu(market: self.viewModel.market, symbol: self.viewModel.symbol, extra: self.viewModel.extra), level: self.viewModel.level, type: quoteType, handler: ({ [weak self] (tickModel, scheme) in
                guard let `self` = self else { return }

                if scheme == .tcp {
                    self.tickTcpFilter.onNext(tickModel)
                    return
                }
                
                self.updateTickData(tickModel)
            }))
        }
    }
    
    func loadPosBrokerData() {
        guard YXStockDetailTool.isShowAskBid(self.viewModel.quoteModel) else { return }
        posBrokerRequest?.cancel()
        
        var level = self.viewModel.level
        var extra = self.viewModel.extra
        let type = YXStockDetailUtility.getUsAskBidSelect()
        if self.viewModel.extra == .usNation && type == .nsdq {
            // 在全美行情下, 选择了纳斯达克, 就设置为none
            extra = .none
            level = .level1
        }
        
        posBrokerRequest = YXQuoteManager.sharedInstance.subPosAndBroker(secu: Secu(market: self.viewModel.market, symbol: self.viewModel.symbol, extra: extra), level: level, handler: { posBroker, scheme in
            
            //买卖档经纪商名称匹配
            func configBroker(_ posBroker: PosBroker?) {
                if let posBroker = posBroker {
                    if let list = posBroker.brokerData?.askBroker {
                        for model in list {
                            if let code = model.Id, code.count > 0 {
                                model.Name = self.brokerDic[code]
                            }
                        }
                    }

                    if let list = posBroker.brokerData?.bidBroker {
                        for model in list {
                            if let code = model.Id, code.count > 0 {
                                model.Name = self.brokerDic[code]
                            }
                        }
                    }
                }
            }
            if scheme == .tcp {
                configBroker(posBroker)
                self.posBrokerFilter.onNext(posBroker)
            } else {
                configBroker(posBroker)
                self.updatePosBrokerData(posBroker)
            }
        })
    }
    
    func updateTickData(_ tickModel: YXTickData) {
        if self.viewModel.market == kYXMarketCryptos {
            self.btDealView.pclose = Double(self.viewModel.quoteModel?.preClose?.value ?? 0)
            self.btDealView.priceBase = UInt32(self.viewModel.quoteModel?.priceBase?.value ?? 0)
            self.btDealView.decimalCount = YXToolUtility.btDecimalPoint(self.viewModel.quoteModel?.btRealTime?.now)
            self.btDealView.tickModel = tickModel
        } else {
            self.headerView.chartView.tickStatisticalView.dealView.pclose = Double(self.viewModel.quoteModel?.preClose?.value ?? 0)
            self.headerView.chartView.tickStatisticalView.dealView.lastPrice = UInt32(self.viewModel.quoteModel?.latestPrice?.value ?? 0)
            self.headerView.chartView.tickStatisticalView.dealView.priceBase = UInt32(self.viewModel.quoteModel?.priceBase?.value ?? 0)
            self.headerView.chartView.tickStatisticalView.dealView.tickModel = tickModel
        }

    }
    
    func updatePosBrokerData(_ posBroker: PosBroker) {
        if posBroker.pos != nil {
//            self.headerView.parameterView.updateCittenValue(posBroker)
        }
        self.posStatisticsView.posBroker = posBroker
    }
        
    // 成交统计
    func loadStatisticalData() {
        
        guard YXStockDetailTool.isShowTick(self.viewModel.quoteModel) else { return }
        
        guard viewModel.market != kYXMarketUsOption else { return }
            
        
        statisticalRequest?.cancel()
        // 市场时段：0：盘中时段，1：开盘竞价(美股盘前)时段，2：收盘竞价(美股盘后)时段 ，3：全部时段
        var marketType: Int = 0
        if self.viewModel.market == kYXMarketUS {
            if YXKLineConfigManager.shareInstance().timeShareType == .all {
                marketType = 3
            } else if YXKLineConfigManager.shareInstance().timeShareType == .pre {
                marketType = 1
            } else if YXKLineConfigManager.shareInstance().timeShareType == .after {
                marketType = 2
            }
        }
        // type: 类型：0：最近20条，1：最近50条，2：全部
        statisticalRequest = YXQuoteManager.sharedInstance.subStatisticQuote(secu: Secu(market: self.viewModel.market, symbol: self.viewModel.symbol), type: 0, nextPageRef: 10, marketType: marketType, handler: { [weak self] (sData, scheme) in
            guard let `self` = self else { return }
            self.headerView.chartView.tickStatisticalView.statisticalView.preClose = UInt32(self.viewModel.quoteModel?.preClose?.value ?? 0)
            self.headerView.chartView.tickStatisticalView.statisticalView.statisData = sData
        })
    }
    
    //多空信号
    func loadWarrantCbbcData() {
        if self.viewModel.market == kYXMarketHK, (self.viewModel.stockType == .stWarrant || self.viewModel.stockType == .stCbbc) {
            if let symbol = self.viewModel.quoteModel?.underlingSEC?.symbol, !symbol.isEmpty,
               let market = self.viewModel.quoteModel?.underlingSEC?.market, !market.isEmpty {
                
                self.viewModel.requestWarrantCbbcData(market: market, symbol: symbol).subscribe(onSuccess: {
                    [weak self] model in
                    guard let `self` = self else { return }
                    self.headerView.extraQuoteView.bearSignalItem = model
                }).disposed(by: self.rx.disposeBag)
            }
        }
    }
    
    func loadDepthTradeData() {
        if YXStockDetailTool.showDepthOrder(self.viewModel.quoteModel) {
        
            depthOrderRequest?.cancel()
            
            let type: Int = self.viewModel.market == kYXMarketSG ? 10 : 1
            depthOrderRequest = YXQuoteManager.sharedInstance.subDepthOrder(secu: Secu(market: self.viewModel.market, symbol: self.viewModel.symbol), type: type, depthType: (YXStockDetailUtility.showDepthTradeCombineSamePrice() ? .merge : .none)) { [weak self] model, scheme in
                guard let `self` = self else { return }
                self.depthOrderTcpFilter.onNext(model)
            }
        }
    }
    
    func loadDepthChartData() {
        if YXStockDetailTool.showDepthOrder(self.viewModel.quoteModel), YXStockDetailUtility.showDepthTradePriceDistribution() {
        
            depthChartRequest?.cancel()
            let type: Int = self.viewModel.market == kYXMarketSG ? 10 : 1
            depthChartRequest = YXQuoteManager.sharedInstance.subDepthOrder(secu: Secu(market: self.viewModel.market, symbol: self.viewModel.symbol), type: type, depthType: .chart) { [weak self] model, scheme in
                guard let `self` = self else { return }
                
                self.depthChartTcpFilter.onNext(model)
             
            }
        }
    }
    



    //MARK: Lazy Loading 懒加载
    lazy var headerView: YXStockDetailHeaderView = {
        let view = YXStockDetailHeaderView(frame: .zero, market: self.viewModel.market)
        view.frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: view.totalHeight)
//        view.parameterView.setTitles(self.viewModel.detailParameters)
        return view
    }()


    lazy var contentScrollView: UIScrollView = {

        let scrollView = UIScrollView()
        scrollView.backgroundColor = QMUITheme().foregroundColor()
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delaysContentTouches = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView.init()
        stackView.axis = .vertical
        return stackView
    }()
    
    // 盘口/经纪商/深度摆盘
    lazy var posStatisticsView: YXPosStatisticsView = {
        let view = YXPosStatisticsView.init()
        view.backgroundColor = QMUITheme().foregroundColor()
        
        view.heightDidChange = { [weak self] in
            guard let `self` = self else { return }
            self.posStatisticsView.snp.updateConstraints { (make) in
                make.height.equalTo(self.posStatisticsView.height)
            }
        }
        
        view.depthOrderView.settingChangeBlock = {
            [weak self] type in
            guard let `self` = self else { return }

            if type == .combineSamePrice {
                self.loadDepthTradeData()
            } else if type == .priceDistribution {
                
                if YXStockDetailUtility.showDepthTradePriceDistribution() {
                    self.loadDepthChartData()
                } else {
                    self.depthChartRequest?.cancel()
                    self.depthChartRequest = nil
                }
                
//                if self.depthOrderView.contentHeight != self.depthOrderView.totalHeight {
//                    self.updateDepthOrderView(self.viewModel.quoteModel)
//                }
            }
        }
        
        view.clickItemBlock = { [weak self] type in
            self?.loadPosBrokerData()
        }
        
        return view
    }()

    lazy var tradingView: YXCapitalTradingView = {
        let view = YXCapitalTradingView.init(frame: CGRect.init(x: 0, y: 0, width: YXConstant.screenWidth, height: 472))
        view.backgroundColor = QMUITheme().foregroundColor()
        view.market = self.viewModel.market
        view.isHidden = true
        return view
    }()

    lazy var cashFlowView: YXStockAnalyzeCashFlowView = {
        let view = YXStockAnalyzeCashFlowView.init(frame: CGRect.init(x: 0, y: 0, width: YXConstant.screenWidth, height: 246))
        view.backgroundColor = QMUITheme().foregroundColor()
        view.market = self.viewModel.market
        view.isHidden = true
        return view
    }()

    lazy var chipView: YXStockAnalyzeChipView = {
        let view = YXStockAnalyzeChipView()
        view.isHidden = true
        view.backgroundColor = QMUITheme().foregroundColor()
        view.level = YXUserManager.shared().getLevel(with: self.viewModel.market)
        view.chipDetailBlock = {
            [weak self] in
            guard let `self` = self else { return }
            self.trackViewClickEvent(name: "Position Cost Distribution", other: [:])
            let viewModel = YXStockChipDetailViewModel(market: self.viewModel.market, symbol: self.viewModel.symbol, name: self.viewModel.name)
            self.viewModel.navigator.push(YXModulePaths.chipDetail.url, context:viewModel)
        }

        view.chipExplainBlock = { [weak self] in
            guard let `self` = self else { return }
            YXWebViewModel.pushToWebVC(YXH5Urls.analyzeChipExplainUrl())
        }

        view.loginClosure = { [weak self] in
            guard let `self` = self else { return }

            self.viewModel.pushToLoginVC()
        }

        view.upgradeClosure = { [weak self] in
            guard let `self` = self else { return }
            if self.viewModel.market == kYXMarketHK {
                YXWebViewModel.pushToWebVC(YXH5Urls.YX_MY_QUOTES_URL(tab: 2))
            } else if self.viewModel.market == kYXMarketSG {
                YXWebViewModel.pushToWebVC(YXH5Urls.YX_MY_QUOTES_URL(tab: 0))
            } else {
                YXWebViewModel.pushToWebVC(YXH5Urls.YX_MY_QUOTES_URL(tab: 1))
            }
            self.trackViewClickEvent(name: "Upgrade_Tab")

        }
        return view
    }()

    lazy var settingView: YXStockDetailSettingView = {
        let view = YXStockDetailSettingView()
        view.market = self.viewModel.market
        view.tapButtonAction = { [weak self] tapType in
            guard let `self` = self else { return }
            switch tapType {
            case .landScape:
                self.parentVC?.pushToLandscapeVC(with: self.getDayTimeLineType())
            case .chip:
                YXKLineConfigManager.shareInstance().lineType = .dayKline
                YXCYQUtility.saveCYQState(true)
                self.parentVC?.pushToLandscapeVC(with: self.getDayTimeLineType())   // 筹码分布
            case .chartCompare:
                var dic: [String : Any] = [:]
                dic["name"] = self.viewModel.name ?? ""
                dic["symbol"] = self.viewModel.symbol
                dic["market"] = self.viewModel.market
                dic["isFromStockDetail"] = true
                dic["type1"] = self.viewModel.quoteModel?.type1?.value
                self.viewModel.navigator.push(YXModulePaths.klineVS.url, context: dic, animated: false)
            case .indexSetting:
                self.viewModel.navigator.push(YXModulePaths.stockDetailChartSetting.url, context: nil)

            default:
                break
            }
        }
        
        view.selectedAction = { [weak self] (type, isSelected) in
            switch type {
            case .noRehabilitation:
                YXKLineConfigManager.shareInstance().adjustType = .notAdjust
            case .complexbeforeright:
                YXKLineConfigManager.shareInstance().adjustType = .preAdjust
            case .complexbackright:
                YXKLineConfigManager.shareInstance().adjustType = .afterAdjust
            case .solid:
                YXKLineConfigManager.shareInstance().styleType = .solid
            case .hollow:
                YXKLineConfigManager.shareInstance().styleType = .hollow
            case .usa:
                YXKLineConfigManager.shareInstance().styleType = .OHLC
            case .price:
                YXKLineConfigManager.shareInstance().showNowPrice = isSelected
            case .cost:
                YXKLineConfigManager.shareInstance().showHoldPrice = isSelected
            case .tradPoint:
                YXKLineConfigManager.shareInstance().showBuySellPoint = isSelected
            case .fiveDayIntra:
                YXKLineConfigManager.shareInstance().fiveDaysTimelineIntra = isSelected
            default:
                break
            }
            
            self?.refreshKLine()
        }
        
        view.setDefaultAction = { [weak self] in
            YXKLineConfigManager.shareInstance().adjustType = .preAdjust
            YXKLineConfigManager.shareInstance().styleType = .solid
            YXKLineConfigManager.shareInstance().showNowPrice = true
            YXKLineConfigManager.shareInstance().showHoldPrice = true
            YXKLineConfigManager.shareInstance().showBuySellPoint = true
            YXKLineConfigManager.shareInstance().fiveDaysTimelineIntra = false
            
            self?.refreshKLine()
        }
        
        view.rotateAction = { [weak self] in
            self?.parentVC?.pushToLandscapeVC(with: self?.getDayTimeLineType())
        }
        return view
    }()


    lazy var btDealView: YXStockDetailBTDealView = {
        let view = YXStockDetailBTDealView()
        view.isHidden = true

        return view
    }()
    
    
    lazy var timeLineTcpFilter: YXStockDetailTcpFilter<YXTimeLineData> = {
    
        let filter = YXStockDetailTcpFilter<YXTimeLineData>(interval: 0.3) { [weak self] timelineModel in
            guard let `self` = self else { return }
            
            self.updateTimelineData(timelineModel, scheme: .tcp)
        }
        
        return filter
    }()
    
    lazy var btTimeLineTcpFilter: YXStockDetailTcpFilter<YXKLineData> = {
    
        let filter = YXStockDetailTcpFilter<YXKLineData>(interval: 0.3) { [weak self] klineData in
            guard let `self` = self else { return }
            
            self.updateBTTimeLineData(klineData)
        }
        
        return filter
    }()
    
    
    lazy var tickTcpFilter: YXStockDetailTcpFilter<YXTickData> = {

        let filter = YXStockDetailTcpFilter<YXTickData>(interval: 0.3) { [weak self] tickModel in
            guard let `self` = self else { return }
           
            self.updateTickData(tickModel)
        }
        
        return filter
    }()
    
    lazy var posBrokerFilter: YXStockDetailTcpFilter<PosBroker> = {

        let filter = YXStockDetailTcpFilter<PosBroker>(interval: 0.3) { [weak self] posBroker in
            guard let `self` = self else { return }
            self.updatePosBrokerData(posBroker)
        }
    
        return filter
    }()
    
    
    lazy var depthOrderTcpFilter: YXStockDetailTcpFilter<YXDepthOrderData> = {

        let filter = YXStockDetailTcpFilter<YXDepthOrderData>(interval: 0.3) { [weak self] tickModel in
            guard let `self` = self else { return }
            self.posStatisticsView.depthOrderView.model = tickModel
        }
        
        return filter
    }()
    
    lazy var depthChartTcpFilter: YXStockDetailTcpFilter<YXDepthOrderData> = {

        let filter = YXStockDetailTcpFilter<YXDepthOrderData>(interval: 0.3) { [weak self] tickModel in
            guard let `self` = self else { return }
            self.posStatisticsView.depthOrderView.chartModel = tickModel
        }
        return filter
    }()
    
    lazy var brokerDic: [String: String] = {
        var dic = [String: String]()
        let data = MMKV.default().data(forKey: brokerListPath)
        if let data = data, let json = try? JSON(data: data) {
            if let arr = json["broker_list"].arrayObject {
                for model in arr {
                    let subJson = JSON.init(model)
                    var loacalId = subJson["broker_code"].stringValue
                    let ids = loacalId.components(separatedBy: ",")
                    var name = ""
                    //泰语、马来语先用英文
                    if YXUserManager.isENMode() {
                        name = subJson["english_abb_name"].stringValue
                    } else if YXUserManager.curLanguage() == .CN {
                        name = subJson["simplified_abb_name"].stringValue
                    } else {
                        name = subJson["traditional_abb_name"].stringValue
                    }
                    
                    for str in ids {
                        let tempId = str.replacingOccurrences(of: " ", with: "")
                        if str.count > 0 {
                            dic[tempId] = name
                        }
                    }
                }
            }
        }
        return dic
    }()

}

// MARK: - BindViewModel
extension YXStockDetailQuoteVC {

    func bindViewModel() {

        handleHeaderViewBlock()
                
        self.viewModel.capitalSubject.subscribe(onNext: { [weak self] (model) in
            guard let `self` = self else { return }
            self.tradingView.model = model
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        self.viewModel.cashFlowSubject.subscribe(onNext: { [weak self] (model) in
            guard let `self` = self else { return }
            let priceBase = model.price_base ?? 0
            let base = pow(10.0, Double.init(priceBase))
            if let list = model.list {
                let arr = list.map{ NSNumber.init(value: Double.init($0.netin ?? 0) / base) }
                self.cashFlowView.currentList = arr
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        self.viewModel.pageHeightSubject.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.updateContentViewLayout()
        }).disposed(by: rx.disposeBag)

        self.viewModel.holdAssetSubject.subscribe(onNext: { [weak self] holdPrice in
            guard let `self` = self else { return }
            if holdPrice > 0 {
                self.headerView.chartView.holdPrice = holdPrice
            }

        }).disposed(by: rx.disposeBag)

        self.viewModel.klineOrderSubject.subscribe(onNext: { [weak self] model in
            guard let `self` = self else { return }

            if YXKLineConfigManager.shareInstance().lineType == .dayKline && YXKLineConfigManager.shareInstance().showBuySellPoint {
                self.headerView.chartView.kLineView.reload()
            }
        }).disposed(by: rx.disposeBag)

        self.viewModel.timeLineOrderSubject.subscribe(onNext: { [weak self] model in
            guard let `self` = self else { return }

            if YXKLineConfigManager.shareInstance().lineType == .dayTimeLine && YXKLineConfigManager.shareInstance().showBuySellPoint {
                YXStockDetailTool.mergeOrderDataToTimeline(orderModel: model, timelineData: self.headerView.chartView.timeLineView.timeLineModel)
                self.viewModel.lastTimelineData = self.headerView.chartView.timeLineView.timeLineModel.list?.last
                self.headerView.chartView.timeLineView.hasOrder = true
                self.headerView.chartView.timeLineView.reload()
            }
        }).disposed(by: rx.disposeBag)
    }

    //更新布局
    func updateContentViewLayout() {
        self.headerView.snp.updateConstraints { make in
            make.height.equalTo(self.headerView.totalHeight)
        }
    }

    func handleHeaderViewBlock() {
        headerView.updateHeightBlock = {
            [weak self] height in
            guard let `self` = self else { return }
            self.updateContentViewLayout()
        }

        headerView.tapBlock = {
            [weak self] (market, symbol) in
            guard let `self` = self else { return }

            let input = YXStockInputModel()
            input.market = market
            input.symbol = symbol

            self.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : [input], "selectIndex" : 0])
        }

        headerView.chartView.chartSettingCallBack = {
            [weak self] in
            guard let `self` = self else { return }
            let rect = self.view.convert(self.view.frame, from: self.headerView.chartView)
            let oriPoint = self.contentScrollView.contentOffset
            var point = self.contentScrollView.contentOffset
            point.y = point.y + rect.origin.y
            self.contentScrollView.setContentOffset(point, animated: true)
            
            self.settingView.shoulShowChip = YXStockDetailTool.isShowCYQ(self.viewModel.quoteModel)
            self.settingView.showSetting(hideBlock: { [weak self] in
                guard let `self` = self else { return }
                self.contentScrollView.setContentOffset(oriPoint, animated: true)
            })
            
            self.trackViewClickEvent(name: "Setting_Tab")
        }

        headerView.chartView.pushToLandscapeBlock = {
            [weak self] in
            guard let `self` = self else { return }

            self.parentVC?.pushToLandscapeVC(with: self.getDayTimeLineType())
        }

        headerView.chartView.klineLoadMoreBlock = {
            [weak self] in
            guard let `self` = self, let request = self.highKlineRequest else { return }
            self.isKlineLoadingMore = true
            request.nextKLine(succeed: ({ [weak self] (success) in
                guard let `self` = self else { return }
                self.isKlineLoadingMore = false
                if let klineData = self.headerView.chartView.kLineView.klineModel {
                    // 趋势长盈的指标
                    let type = OBJECT_QUOTEKLineType.init(rawValue: Int32(self.viewModel.highLineType) ?? 7) ?? .ktDay
                    if YXKLineConfigManager.shareInstance().mainAccessory == .usmart && type == .ktDay {
                        self.handleSignalData()
                    }
                    self.viewModel.loadKLineOrderData(klineData)
//                    self.viewModel.loadKLineOrderData(klineData)
                    YXKlineCalculateTool.shareInstance().calAccessoryValue(klineData)
                    self.headerView.chartView.refreshKLineView(klineData)
                }
                self.viewModel.kLineData = nil
                self.headerView.chartView.loadingView.isHidden = true

            }), failed: { [weak self] in
                guard let `self` = self else { return }
                self.isKlineLoadingMore = false
                if let klineData = self.viewModel.kLineData {
                    YXKlineCalculateTool.shareInstance().calAccessoryValue(klineData)
                    self.headerView.chartView.refreshKLineView(klineData)
                }
                self.viewModel.kLineData = nil
            })
        }
        
        headerView.chartView.kLineView.usmartLineCallBack =  { [weak self] type in
            guard let `self` = self else { return }
            if type == 0 {
                // 登录
                // 未登錄
                self.viewModel.pushToLoginVC()
            } else if type == 1 {
                // 升级
                let dic: [String: Any] = [
                    YXWebViewModel.kWebViewModelUrl: YXH5Urls.goUsmartAccessoryUnlockUrl()
                ]
                self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            } else if type == 2 {
                // 详情
                let dic: [String: Any] = [
                    YXWebViewModel.kWebViewModelUrl: YXH5Urls.goUsmartAccessoryDetailUrl(with: self.viewModel.market + self.viewModel.symbol)
                ]
                self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            }
        }


        headerView.chartView.selectTpyeCallBack = { [weak self] type in
            guard let `self` = self else { return }
            self.headerView.chartView.kLineView.klineModel = nil
            if self.viewModel.market == kYXMarketCryptos {
                self.headerView.chartView.btTimeLineView.klineModel = nil
            } else {
                self.headerView.chartView.timeLineView.timeLineModel = nil
            }

            self.viewModel.highLineType = YXStockDetailTool.lineTypeString(type)
            self.headerView.chartView.loadingView.isHidden = false
            self.loadHighLineData()

            self.trackKlineType(type)
            
            if self.headerView.chartView.klineTabView.hasTsExpand {
                if self.headerView.chartView.klineTabView.subTsType != YXKLineConfigManager.shareInstance().timeShareType {
                    // 是否选了全部
                    MMKV.default().set((self.headerView.chartView.klineTabView.subTsType == .all), forKey: "kSelectTimeShareingAllTabKey")
                    YXKLineConfigManager.shareInstance().timeShareType = self.headerView.chartView.klineTabView.subTsType
                    self.loadTickData()
                    self.loadStatisticalData()
                }
            }
        }

        headerView.chartView.tickStatisticalView.dealView.loadMoreCallBack = {
            [weak self] (_, _) in
            guard let `self` = self else { return }
            self.tickRequest?.nextTick(succeed: { [weak self] (success) in
                guard let `self` = self else { return }
                self.headerView.chartView.tickStatisticalView.dealView.reload(withMoreLoad: success)

            }, failed: {
                self.headerView.chartView.tickStatisticalView.dealView.reload(withMoreLoad: false)
            })

        }

        btDealView.loadMoreCallBack = {
            [weak self] (_, _) in
            guard let `self` = self else { return }
            self.tickRequest?.nextTick(succeed: { [weak self] (success) in
                guard let `self` = self else { return }
                self.btDealView.reload(withMoreLoad: success)

            }, failed: {
                self.btDealView.reload(withMoreLoad: false)
            })

        }

        let onlyTick = self.viewModel.market == kYXMarketUsOption || self.viewModel.market == kYXMarketCryptos
        headerView.chartView.tickStatisticalView.dealView.tickClickCallBack = {
            [weak self] in
            guard let `self` = self else { return }
            let params: [AnyHashable : Any] = [
                "name": self.viewModel.name ?? "",
                "symbol": self.viewModel.symbol,
                "market" : self.viewModel.market,
                "pClose": String(self.viewModel.quoteModel?.preClose?.value ?? 0),
                "Index" : 0,
                "onlyTick": onlyTick,
                "timeShareType": YXKLineConfigManager.shareInstance().timeShareType.rawValue,
            ]

            let detailViewModel = YXStockDetailTradeStaticVModel.init(services: self.viewModel.navigator, params: params)
            self.viewModel.navigator.push(detailViewModel, animated: true)
        }


        headerView.chartView.tickStatisticalView.statisticalView.loadStactisticDataBlock = {
            [weak self]  in
            guard let `self` = self else { return }
            self.loadStatisticalData()
        }

        headerView.chartView.tickStatisticalView.statisticalView.clickCallBack = {
            [weak self] in
            guard let `self` = self else { return }
            let params: [AnyHashable : Any] = [
                "name": self.viewModel.name ?? "",
                "symbol": self.viewModel.symbol,
                "market" : self.viewModel.market,
                "pClose": String(self.viewModel.quoteModel?.preClose?.value ?? 0),
                "Index" : 1,
                "onlyTick": onlyTick,
                "timeShareType": YXKLineConfigManager.shareInstance().timeShareType.rawValue,
            ]

            let detailViewModel = YXStockDetailTradeStaticVModel.init(services: self.viewModel.navigator, params: params)
            self.viewModel.navigator.push(detailViewModel, animated: true)
        }
//        
//        headerView.klineLongPressView.orderDetailView.clickToDetailBlock = {
//            [weak self] (date, orderType) in
//            guard let `self` = self else { return }
//            self.pushToOrderList(date, orderType: orderType)
//        }
//
//        headerView.timeLineLongPressView.orderDetailView.clickToDetailBlock = {
//            [weak self] (date, orderType) in
//            guard let `self` = self else { return }
//            self.pushToOrderList(date, orderType: orderType)
//        }

        headerView.extraQuoteView.preQuotaView.usQuotesStatementBlock = {
            [weak self] in
            guard let `self` = self else { return }
            let dic: [String: Any] = [
                YXWebViewModel.kWebViewModelUrl: YXH5Urls.US_QUOTES_STATEMENT_URL()
            ]
            self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        }

        headerView.chartView.kLineView.queryQuoteCallBack = {
            [weak self] (klineData, model, index) in
            guard let `self` = self else { return }
            if self.historyTimelineView == nil {
                self.showHistoryTimeLineView()
            }

            if self.historyTimelineView?.queryIndex != index {
                self.historyTimelineView?.klineData = klineData
                self.historyTimelineView?.singleKLine = model
                self.historyTimelineView?.queryIndex = index

                self.loadHistoryTimeLineData(date: Int64(model?.latestTime?.value ?? 0))
            }
        }

        headerView.chartView.kLineView.cancelQueryQuoteCallBack = {
            [weak self] in
            guard let `self` = self else { return }

            self.hiddenHistoryTimeLineView()
        }
        
        headerView.chartView.selectUsmartAccessCallBack = { [weak self] in
            guard let `self` = self else { return }
            self.handleSignalData()
        }
        
        headerView.chartView.kLineView.klineLongPressStartCallBack = {
            [weak self] kline in
            guard let `self` = self else { return }
            self.klineLongPressCallBack?(self.headerView.chartView, true, kline)
            
            if let lineModel = kline {
                if self.headerView.chartView.cyqView.isHidden == false {
                    self.headerView.cyqRequestBlock?(lineModel.latestTime?.value ?? 0)
                }
            }
        }
        
        headerView.chartView.kLineView.klineLongPressEndCallBack = {
            [weak self] in
            guard let `self` = self else { return }
            self.klineLongPressCallBack?(self.headerView.chartView, false, nil)
        }
        
        headerView.chartView.timeLineView.timeLineLongPressStartCallBack = {
            [weak self] timeLine in
            guard let `self` = self else { return }
            
            self.timeLineLongPressCallBack?(self.headerView.chartView, true, timeLine)
        }
        
        headerView.chartView.timeLineView.timeLineLongPressEndCallBack = {
            [weak self] in
            guard let `self` = self else { return }
            self.timeLineLongPressCallBack?(self.headerView.chartView, false, nil)
        }
    }

    func pushToOrderList(_ date: String, orderType: Int32) {
        var exchangeType: YXExchangeType = .hk
        if self.viewModel.market == YXMarketType.HK.rawValue {
            exchangeType = YXExchangeType.hk
        } else if self.viewModel.market == YXMarketType.US.rawValue {
            exchangeType = YXExchangeType.us
        } else if self.viewModel.market == YXMarketType.USOption.rawValue {
            exchangeType = YXExchangeType.usop
        } else {
            exchangeType = YXExchangeType.hs
        }

        if self.viewModel.market == YXMarketType.USOption.rawValue {
//            let params = [ "name" : self.viewModel.quoteModel?.underlingSEC?.name ?? "",
//                           "symbol" : self.viewModel.quoteModel?.underlingSEC?.symbol ?? "",
//                           "beginDate" : date,
//                           "endDate" : date ]
//            let viewModel = YXOptionOrderViewModel(services: self.viewModel.navigator, params: params)
//            self.viewModel.navigator.push(viewModel, animated: true)
        } else {
            var viewModel: YXOrderListViewModel

            if orderType == 1 {
                viewModel = YXOrderListViewModel.init(exchangeType: exchangeType, allOrderType: YXAllOrderType.dayMargin)
            } else {
                viewModel = YXOrderListViewModel.init(exchangeType: exchangeType)
            }

            viewModel.externParams = ["exchangeType" : exchangeType,
                                      "name" : self.viewModel.name ?? "",
                                      "symbol" : self.viewModel.symbol,
                                      "beginDate" : date,
                                      "endDate" : date ]

            let context = YXNavigatable(viewModel: viewModel)
            self.viewModel.navigator.push(YXModulePaths.allOrderList.url, context: context)
        }

    }

    func trackKlineType(_ type: YXRtLineType) {
        switch type {
            case .dayTimeLine:
                self.trackViewClickEvent(name: "1D_Tab")
            case .fiveDaysTimeLine:
                self.trackViewClickEvent(name: "5D_Tab")
            case .dayKline:
                self.trackViewClickEvent(name: "D_Tab")
            case .weekKline:
                self.trackViewClickEvent(name: "W_Tab")
            case .monthKline:
                self.trackViewClickEvent(name: "M_Tab")
            case .seasonKline:
                self.trackViewClickEvent(name: "Q_Tab")
            case .yearKline:
                self.trackViewClickEvent(name: "Y_Tab")
            default:
                self.trackViewClickEvent(name: "Mins_Tab")
        }

    }
    
    func getDayTimeLineType() -> YXTimeShareLineType {
        
        var timeLineType: YXTimeShareLineType = .intra
        if self.headerView.chartView.klineTabView.rtLineType == .dayTimeLine {
            if self.headerView.chartView.klineTabView.hasTsExpand {
                timeLineType = self.headerView.chartView.klineTabView.subTsType
            }
        }
        
        return timeLineType
    }
}

//MARK: 买卖档相关
extension YXStockDetailQuoteVC {

    fileprivate func updateUIHidden() {
        //买卖档，资金趋势，成交分布
        self.chipView.isHidden = !YXStockDetailTool.isShowCYQ(self.viewModel.quoteModel)
        //暗盘 和 美股期权不展示 资金趋势 和 资金成交分布
        if isShowCashFlow() {
            self.cashFlowView.isHidden = false
            self.tradingView.isHidden = false
        } else {
            self.cashFlowView.isHidden = true
            self.tradingView.isHidden = true
        }
        
        self.headerView.updateUsQuoteTipView()
    }

    func isShowCashFlow() -> Bool {
        if !self.viewModel.greyFlag && self.viewModel.market != kYXMarketUsOption && self.viewModel.market != kYXMarketCryptos && self.viewModel.stockType != .stIndex && self.viewModel.stockType != .stSector {
            return true
        }
        return false
    }
}


//MARK: - 资金趋势 和 成交分布
extension YXStockDetailQuoteVC {

    func openTimer() {
        //暗盘 和 美股期权不展示 资金趋势 和 资金成交分布
        closeTimer()
        if self.viewModel.quoteModel != nil,
           !self.viewModel.greyFlag,
           self.viewModel.market != kYXMarketUsOption,
           !YXTimer.shared.isExistTimer(WithTimerName: self.httpTimer)  {

            YXTimer.shared.scheduledDispatchTimer(WithTimerName: self.httpTimer, timeInterval: Double(YXGlobalConfigManager.configFrequency(.delayTimesharingFreq)), queue: .main, repeats: true) { [weak self] in
                self?.loadCapitalData()
                self?.loadCashFlowData()
            }
        }
    }

    //
    func closeTimer() {
        YXTimer.shared.cancleTimer(WithTimerName: httpTimer)
    }
}

//MARK: - 历史分时相关
extension YXStockDetailQuoteVC {

    func showHistoryTimeLineView() {
        let viewHeight: CGFloat = 233 + YXConstant.tabBarPadding()

        let timelineView = YXTimeLineHistoryView.init(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: viewHeight))
        self.historyTimelineView = timelineView
        timelineView.quote = self.viewModel.quoteModel

        let superView: UIView = self.parentVC?.view ?? self.view
        superView.addSubview(timelineView)
        timelineView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(viewHeight)
            make.height.equalTo(viewHeight)
        }

        timelineView.closeClosure = {
            [weak self] in
            guard let `self` = self else { return }

            self.hiddenHistoryTimeLineView()
        }

        timelineView.queryTimeLineDataBlock = {
            [weak self] (model, isLeftDirection) in
            guard let `self` = self else { return }
            //每次回调实时刷新时间
            self.historyTimeLineInterval = CFAbsoluteTimeGetCurrent()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                //间隔0.3s及以上请求数据，0.3s内不请求，
                //重新获取时间，和self.historyTimeLineInterval比较，时差是否大于0.3s
                //连续请求时外面的self.historyTimeLineInterval会连续变化，0.3s进入block后 time - self.historyTimeLineInterval的值是不确定的
                let time = CFAbsoluteTimeGetCurrent()
                if (time - self.historyTimeLineInterval >= 0.3) {
                    self.loadHistoryTimeLineData(date: Int64(model.latestTime?.value ?? 0))
                }
            })

            self.headerView.chartView.kLineView.moveCrossLineLayer(isLeftDirection)
        }

        //长按状态回调
        timelineView.longPressStateBlock = {
            [weak self] isEnd in
            guard let `self` = self else { return }
            if isEnd {
                self.historyTimelineView?.snp.updateConstraints({ (make) in
                    make.height.equalTo(viewHeight)
                })
            } else {
                self.historyTimelineView?.snp.updateConstraints({ (make) in
                    make.height.equalTo(viewHeight + 55)
                })
            }
        }

        UIView.animate(withDuration: 0.25, animations: {
            timelineView.snp.updateConstraints({ (make) in
                make.bottom.equalToSuperview()
            })
            timelineView.alpha = 1.0
            self.view.setNeedsLayout()
        })
    }

    func hiddenHistoryTimeLineView() {

        self.headerView.chartView.kLineView.resetLongPressState()
        let superView: UIView = self.parentVC?.view ?? self.view
        UIView.animate(withDuration: 0.25, animations: {
            self.historyTimelineView?.snp.makeConstraints({ (make) in
                make.bottom.equalTo(superView).offset(self.historyTimelineView?.frame.height ?? 0)
            })
            self.historyTimelineView?.alpha = 0.0
            self.view.setNeedsLayout()
        }, completion: {
            flag in
            self.historyTimelineView?.removeFromSuperview()
            self.historyTimelineView = nil
        })
    }

    func loadHistoryTimeLineData(date: Int64) {
        self.historyRequestTime = date
        self.viewModel.loadHistoryTimeLineData(date: date).subscribe(onSuccess: {
            [weak self] timeLineData in
            guard let `self` = self else { return }
            //防止 已经切换到一个日期了，上一个日期的股票请求才返回
            if self.historyRequestTime == date {
                self.historyTimelineView?.timeLineData = timeLineData
            }
        }).disposed(by: rx.disposeBag)
    }

}

// MARK: - 分析界面
extension YXStockDetailQuoteVC {
    
    func showAnalyzeView() {
        guard let quote = self.viewModel.quoteModel else { return }
        self.removeAnalyzeView()
        
        guard YXStockDetailTool.isShowAnalyze(quote) else {
            return
        }
        var isHKVolumn = false
        if let scmType = self.viewModel.quoteModel?.scmType?.value, ((scmType & 0x8) > 0 || (scmType & 0x4) > 0) {
            isHKVolumn = true
        }
        var isStock = false
        if self.viewModel.stockType == .hkStock || self.viewModel.stockType == .usStock || self.viewModel.stockType == .sgStock {
            if !self.viewModel.isLowADR {
                isStock = true
            }
        }
        var isWarrantCbbc = false
        if self.viewModel.stockType == .stCbbc || self.viewModel.stockType == .stWarrant {
            isWarrantCbbc = true
        }
        let params: [String: Any] = ["market" : self.viewModel.market,
                                     "symbol" : self.viewModel.symbol,
                                     "name" : self.viewModel.name ?? "",
                                     "isHKVolumn" : NSNumber.init(booleanLiteral: isHKVolumn),
                                     "greyFlag" : NSNumber.init(booleanLiteral: self.viewModel.greyFlag),
                                     "preClose" : self.viewModel.quoteModel?.preClose?.value ?? 0,
                                     "isStock" : NSNumber.init(booleanLiteral: isStock),
                                     "isWarrantCbbc" : NSNumber.init(booleanLiteral: isWarrantCbbc),
        ]
//        if self.viewModel.market == kYXMarketUsOption {
//            params["contractSize"] = quote.contractSize?.value ?? 0
//            params["callPutType"] = quote.callPutFlag?.value ?? 1
//        }
        let model = YXStockDetailAnalyzeViewModel.init(services: self.viewModel.navigator, params: params)
        let vc = YXStockDetailBrokerAnalyzeVC.init(viewModel: model)
        self.analyzeVC = vc
        
        self.stackView.subviews.forEach { view in
            if view == self.analyzeVC?.view {
                view.removeFromSuperview()
            }
        }

        self.addChild(vc)
        self.stackView.addArrangedSubview(vc.view)
        vc.view.snp.makeConstraints { make in
            make.height.equalTo(self.analyzeVC?.contentHieght ?? 0)
        }
        vc.contentHeightDidChange = { [weak self] height in
            guard let `self` = self else { return }

            self.analyzeVC?.view.snp.updateConstraints({ make in
                make.height.equalTo(height)
            })
        }
    }
    
    func removeAnalyzeView() {
        self.stackView.subviews.forEach { view in
            if view == self.analyzeVC?.view {
                view.removeFromSuperview()
            }
        }
        self.analyzeVC = nil
    }
}

//MARK: - 趋势长盈

extension YXStockDetailQuoteVC {
    
    func handleSignalData() {
        if !self.viewModel.isRequestSignal {
            // 先判断登录
            if !YXUserManager.isLogin() {
                return
            }
            // 再判断是否是pro账户
            if YXUserManager.getProLevel() == .level1 || YXUserManager.getProLevel() == .level2 {
                YXKLineConfigManager.shareInstance().hasUsmartLimit = true
                self.requestLineSignal(with: 0, 1000)
            } else {
                let requestModel = YXKLineGetUsmartSignalCountRequestModel.init()
                requestModel.stock_id = self.viewModel.market + self.viewModel.symbol
                let request = YXRequest.init(request: requestModel)
                request.startWithBlock(success: { (responseModel) in
                    if responseModel.code == .success {
                        if let data = responseModel.data, let right = data["has_right"] as? Bool {
                            YXKLineConfigManager.shareInstance().hasUsmartLimit = right
                            
                            if right {
                                self.requestLineSignal(with: 0, 1000)
                            } else {
                                if let kLineData =  self.headerView.chartView.kLineView.klineModel{
                                    self.headerView.chartView.refreshKLineView(kLineData)
                                }
                            }
                        }
                    } else {
                        YXKLineConfigManager.shareInstance().hasUsmartLimit = false
                    }
                    
                }, failure: { (request) in
                    YXKLineConfigManager.shareInstance().hasUsmartLimit = false
                })
            }
        } else {
            if let list = self.viewModel.signalList, list.count > 0, let kLineData =  self.viewModel.kLineData {
                YXStockDetailUtility.mergeUsmartSingalData(list, toTime: kLineData)
                self.headerView.chartView.refreshKLineView(kLineData)
            }
        }
    }
    
    func requestLineSignal(with offset: Int64, _ limit: Int64) {
        let requestModel = YXKLineUsmartSignalRequestModel.init()
        requestModel.stock_id = self.viewModel.market + self.viewModel.symbol
        requestModel.offset = offset
        requestModel.limit = limit
        
        let request = YXRequest.init(request: requestModel)
        request.startWithBlock(success: { (responseModel) in
            if responseModel.code == .success {
                if let data = responseModel.data, let list = data["list"] {
                    self.viewModel.isRequestSignal = true
                    let a = NSArray.yy_modelArray(with: YXUsmartSignalModel.self, json: list) as? [YXUsmartSignalModel]
                    
                    if let a = a, a.count > 0 , let kLineData =  self.headerView.chartView.kLineView.klineModel {
                        self.viewModel.signalList = a
                        YXStockDetailUtility.mergeUsmartSingalData(a, toTime: kLineData)
                        self.viewModel.lastKlineData = self.viewModel.kLineData?.list?.last
                        self.headerView.chartView.refreshKLineView(kLineData)
                    }
                }
            }
        }, failure: { (request) in
            
        })
    }
}

extension YXStockDetailQuoteVC: JXPagingViewListViewDelegate, UIScrollViewDelegate {
    
    func listScrollView() -> UIScrollView { self.contentScrollView }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        listViewDidScrollCallback?(scrollView)
    }
    
    
}
