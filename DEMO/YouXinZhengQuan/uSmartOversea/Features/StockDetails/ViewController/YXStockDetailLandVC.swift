//
//  YXStockDetailLandVC.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/8/5.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YXKit

class YXStockDetailLandVC: YXHKViewController {
    
    typealias ViewModelType = YXStockDetailLandViewModel
    var viewModel: YXStockDetailLandViewModel!
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    
    let closeBtn = YXExpandAreaButton.init(frame: .zero)
    
    var quoteRequest: YXQuoteRequest?
    var tickRequest: YXQuoteRequest?
    var hightTimelineRequest: YXQuoteRequest?
    var highKlineRequest: YXQuoteRequest?
    var posBrokerRequest: YXQuoteRequest?
  
    var loadMoreBlock: ((YXKLineData?) -> Void)?
    var isKlineLoadingMore = false

    var cyqRequestTime: UInt64 = 0
    var needLoadHoldAsset = false

    var hasRemoveKlineOrderCache = false
    
    private var task: DispatchQueue.Task?
    var tickTimeLine: YXTimeShareLineType = .intra
    
    var cycViewHeight: CGFloat {
        return YXConstant.screenWidth - 57 - 5
    }

    var dealPadding: CGFloat {
        if self.viewModel.market == kYXMarketCryptos {
            return 200
        } else {
            return 140
        }
    }

    var headerViewHeight: CGFloat {
        if self.viewModel.market == kYXMarketCryptos {
            return 39
        } else {
            return 57
        }
    }
    
    lazy var lineView: YXStockDetailLineView = {
        let lineView = YXStockDetailLineView.init(frame: .zero, market: self.viewModel.market, isLand: true)
        return lineView
    }() 
    
    lazy var headerView: YXStockDetailLandHeaderView = {
        let view = YXStockDetailLandHeaderView.init()
        view.market = self.viewModel.market
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()
    
    lazy var dealView: YXStockLandDealAndAskBidView = {
        let view = YXStockLandDealAndAskBidView.init(frame: .zero, market: self.viewModel.market)
        view.isHidden = true
        return view
    }()

    lazy var cyqView: YXCYQView = {
        let view = YXCYQView(frame: CGRect.init(x: self.view.frame.width - 140, y: 57, width: 140, height: cycViewHeight))
        view.isLand = true
        view.isHidden = true
        view.market = self.viewModel.market
        view.isFullChart = YXKLineConfigManager.shareInstance().subAccessoryArray.count == 0
        return view
    }()

    var isConfirmType = false
    
    var accessoryView: YXKlineAccessoryView!

    lazy var timeLineLongPressView: YXTimeLineLongPressView = {
        let view = YXTimeLineLongPressView.init(frame: CGRect.init(x: 0, y: 0, width: YXConstant.screenHeight, height: 98), andType: .right)
        view.market = self.viewModel.market
        view.backgroundColor = QMUITheme().foregroundColor()
        view.isHidden = true
        return view
    }()
    
    lazy var klineLongPressView: YXKlineLongPressView = {
        let view = YXKlineLongPressView.init(frame: CGRect.init(x: 0, y: 0, width: YXConstant.screenHeight, height: 98), andType: .right)
        view.market = self.viewModel.market
        view.oritentType = .right
        view.backgroundColor = QMUITheme().foregroundColor()
        view.isHidden = true
        return view
    }()
    
    //毛玻璃
    lazy var stockIndexShadeView: YXStockIndexAccessoryShadeView = {
        let view = YXStockIndexAccessoryShadeView()
        view.isHidden = true
        view.setLandscape(true)
        view.setButtonType(.OPENACCOUNTBUTTON)
        return view
    }()
    
    lazy var quoteStatementShadeView: YXStockIndexAccessoryShadeView = {
        let view = YXStockIndexAccessoryShadeView()
        view.isHidden = true
        view.setButtonType(.QUOTESTATEMENTBUTTON)
        view.setLandscape(false)
        return view
    }()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // 重置权限
        YXKLineConfigManager.shareInstance().hasUsmartLimit = true
        self.accessoryView = YXKlineAccessoryView(frame: .zero, isLand: true)
        self.accessoryView.backgroundColor = QMUITheme().foregroundColor()
        initUI()
        bindViewModel()
    }
    
    override func didInitialize() {
        super.didInitialize()
        self.forceToLandscapeRight = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetAppearRequest()
    }
    
    override func preferredNavigationBarHidden() -> Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    func resetAppearRequest() {
        self.needLoadHoldAsset = true
        self.cyqRequestTime = 0
        DispatchQueue.main.async {
            self.loadQuoteData()
        }
        if isConfirmType {
            self.selectLineType(with: YXKLineConfigManager.shareInstance().lineType)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancelAllRequest()

        self.viewModel.selectIndexBlock?(self.viewModel.selectIndex)
    }

    func cancelAllRequest() {
        quoteRequest?.cancel()
        quoteRequest = nil
        tickRequest?.cancel()
        tickRequest = nil
        hightTimelineRequest?.cancel()
        hightTimelineRequest = nil
        highKlineRequest?.cancel()
        highKlineRequest = nil
        
        posBrokerRequest?.cancel()
        posBrokerRequest = nil

        self.dealView.tickView.invalidateTimer()
    }
    
    func initUI() {

        self.view.backgroundColor = QMUITheme().foregroundColor()

        self.accessoryView.isHidden = true
        closeBtn.setImage(UIImage(named: "quit_close"), for: .normal)
        closeBtn.addTarget(self, action: #selector(closeDidClick), for: .touchUpInside)
        self.view.addSubview(self.headerView)
        self.view.addSubview(self.closeBtn)
        self.view.addSubview(self.lineView)
        self.view.addSubview(self.accessoryView)
        self.view.addSubview(self.dealView)
        self.view.addSubview(self.cyqView)

        self.headerView.frame = CGRect(x: YXConstant.navBarPadding(), y: 0, width: max(YXConstant.screenWidth, YXConstant.screenHeight) - YXConstant.navBarPadding() - 60, height: self.headerViewHeight)
//        self.headerView.snp.makeConstraints { (make) in
//            make.top.equalToSuperview()
//            make.trailing.equalToSuperview().offset(-60)
//            make.height.equalTo(50)
//            make.leading.equalToSuperview().offset(YXConstant.navBarPadding())
//        }
        
        self.dealView.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview()
            make.top.equalTo(self.headerView.snp.bottom)
            make.bottom.equalToSuperview()
            make.width.equalTo(self.dealPadding)
        }
        
        self.closeBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            if YXConstant.deviceScaleEqualToXStyle() {
                make.trailing.equalToSuperview().offset(-YXConstant.tabBarPadding())
            } else {
                make.trailing.equalToSuperview().offset(-20)
            }
            make.width.height.equalTo(20)
        }
        
        self.lineView.snp.makeConstraints { (make) in
            make.leading.equalTo(headerView)
            make.trailing.equalToSuperview()
            make.top.equalTo(self.headerView.snp.bottom)
            make.bottom.equalToSuperview()
        }
        
        self.accessoryView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.top.equalTo(self.headerView.snp.bottom)
            make.trailing.equalToSuperview()
            make.width.equalTo(64)
        }

        self.cyqView.snp.makeConstraints { (make) in
            make.right.equalTo(self.accessoryView.snp.left)
            make.top.equalTo(self.headerView.snp.bottom)
            make.height.equalTo(cycViewHeight)
            make.width.equalTo(140)
        }
        
        //添加横屏毛玻璃
        self.view.addSubview(self.stockIndexShadeView)
        stockIndexShadeView.snp.makeConstraints { (make) in
            make.top.equalTo(self.lineView).offset(0)
            make.leading.trailing.bottom.equalTo(lineView)
        }

        self.view.addSubview(self.quoteStatementShadeView)
        quoteStatementShadeView.snp.makeConstraints { (make) in
            make.top.equalTo(self.lineView).offset(0)
            make.leading.trailing.bottom.equalTo(lineView)
        }

        if self.viewModel.dataSource.count > 1 {
            self.view.addSubview(preButton)
            preButton.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(YXConstant.navBarPadding() + 100)
                make.bottom.equalToSuperview().offset(-37)
                make.width.height.equalTo(20)
            }

            self.view.addSubview(nextButton)
            nextButton.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(YXConstant.navBarPadding() + 152)
                make.bottom.equalToSuperview().offset(-37)
                make.width.height.equalTo(20)
            }
        }

        let topLineView = UIView()
        topLineView.backgroundColor = QMUITheme().separatorLineColor()
        self.view.addSubview(topLineView)
        topLineView.snp.makeConstraints { (make) in
            make.left.equalTo(headerView)
            make.right.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
            make.height.equalTo(0.5)
        }

        let leftLineView = UIView()
        leftLineView.backgroundColor = QMUITheme().separatorLineColor()
        self.view.addSubview(leftLineView)
        leftLineView.snp.makeConstraints { (make) in
            make.left.equalTo(headerView)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(0.5)
        }

    }

    lazy var preButton: QMUIButton = {

        let preButton = YXExpandAreaButton()
        preButton.expandX = 10
        preButton.expandY = 10
        preButton.setImage(UIImage(named: "pre_stock"), for: .normal)
        self.view.addSubview(preButton)
        preButton.addTarget(self, action: #selector(preAction), for: .touchUpInside)
        return preButton
    }()

    lazy var nextButton: QMUIButton = {

        let nextButton = YXExpandAreaButton()
        nextButton.expandX = 10
        nextButton.expandY = 10
        nextButton.setImage(UIImage(named: "next_stock"), for: .normal)
        self.view.addSubview(nextButton)
        nextButton.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        return nextButton
    }()

    @objc func preAction() {
        self.viewModel.selectIndex -= 1

        if self.viewModel.selectIndex < 0 {

            self.viewModel.selectIndex = self.viewModel.dataSource.count - 1
        }

        handleNextStock()
    }

    @objc func nextAction() {
        self.viewModel.selectIndex += 1

        if self.viewModel.selectIndex >= self.viewModel.dataSource.count {

            self.viewModel.selectIndex = 0
        }

        handleNextStock()
    }

    func handleNextStock() {

        nextButton.isEnabled = false
        preButton.isEnabled = false
        self.cancelAllOperations()

        let input: YXStockInputModel = self.viewModel.dataSource[self.viewModel.selectIndex]
        self.viewModel.setCurrentDataSource(input)

        self.restartAllOperations()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.nextButton.isEnabled = true
            self.preButton.isEnabled = true
        }

        if (self.viewModel.selectIndex == self.viewModel.dataSource.count - 1) {
            self.networkingHUD.showMessage(YXLanguageUtility.kLang(key: "change_to_last"), in: self.view, hideAfter: 2.5)
        }
    }

    func cancelAllOperations() {
        cancelAllRequest()
    }

    func restartAllOperations() {

        cyqRequestTime = 0

        hasRemoveKlineOrderCache = false

        // 是否确定类型
        isConfirmType = false
        self.viewModel.isRequestSignal = false

        isKlineLoadingMore = false

        resetAppearRequest()

        self.lineView.isCryptos = false

        self.lineView.kLineView.isIndexStock = false
        self.lineView.kLineView.resetSetting()
        self.lineView.kLineView.holdPrice = 0

        self.lineView.timeLineView.isIndexStock = false
        self.lineView.timeLineView.isGem = false
        self.lineView.timeLineView.holdPrice = 0

        self.lineView.btTimeLineView.holdPrice = 0

        if (self.lineView.isOptionStock) {
            self.lineView.isOptionStock = false
        }

        do { //逐笔买卖档重置
            self.dealView.removeFromSuperview()
            self.dealView = YXStockLandDealAndAskBidView.init(frame: .zero, market: self.viewModel.market)
            self.dealView.isHidden = true
            self.view.addSubview(self.dealView)
            self.dealView.snp.makeConstraints { (make) in
                make.trailing.equalToSuperview()
                make.top.equalTo(self.headerView.snp.bottom).offset(40)
                make.bottom.equalToSuperview().offset(4)
                make.width.equalTo(self.dealPadding)
            }
            handleDealBlock()
        }

        self.headerView.frame = CGRect(x: YXConstant.navBarPadding(), y: 0, width: max(YXConstant.screenWidth, YXConstant.screenHeight) - YXConstant.navBarPadding() - 60, height: self.headerViewHeight)
        self.headerView.market = self.viewModel.market
        self.headerView.hkIndex = false

        do {
            //长按视图重置
            self.timeLineLongPressView.removeFromSuperview()
            self.timeLineLongPressView = YXTimeLineLongPressView.init(frame: CGRect.init(x: 0, y: 0, width: YXConstant.screenHeight, height: 98), andType: .right)
            self.timeLineLongPressView.market = self.viewModel.market
            self.timeLineLongPressView.backgroundColor = QMUITheme().foregroundColor()
            self.timeLineLongPressView.isHidden = true

            self.klineLongPressView.removeFromSuperview()
            self.klineLongPressView = YXKlineLongPressView.init(frame: CGRect.init(x: 0, y: 0, width: YXConstant.screenHeight, height: 98), andType: .right)
            self.klineLongPressView.market = self.viewModel.market
            self.klineLongPressView.oritentType = .right
            self.klineLongPressView.backgroundColor = QMUITheme().foregroundColor()
            self.klineLongPressView.isHidden = true

            handleLongPressViewBlock()
        }
    }
    
    override func shouldPopViewController(byBackButtonOrPopGesture byPopGesture: Bool) -> Bool {
        return false
    }
    
    @objc func closeDidClick() {
        if !self.viewModel.isFromLandVC {
            YXToolUtility.forceToPortraitOrientation()
            self.navigationController?.popViewController(animated: false)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func loadLineData(type: YXRtLineType) {
        if type == .dayTimeLine || type == .fiveDaysTimeLine {
            loadHighTimeLineData()
        } else {
            loadHighKLineData()
        }
    }
    
    //MARK: ***** 行情 *****
    func loadQuoteData() {

        quoteRequest?.cancel()
        quoteRequest = YXQuoteManager.sharedInstance.subRtFullQuote(secu: Secu(market: self.viewModel.market, symbol: self.viewModel.symbol), level: self.viewModel.level, handler: ({ [weak self](quotes, scheme) in
            guard let `self` = self else { return }

            guard quotes.count > 0, let quoteModel = quotes.first, let market = quoteModel.market, let symbol = quoteModel.symbol, market == self.viewModel.market, symbol == self.viewModel.symbol else {

                //多只股票切换时，避免接收的是上次的推送，需要比对market 和 symbol
                return
            }

            if scheme == .tcp {

                if self.viewModel.quoteModel != nil {
                    self.quoteTcpFilter.onNext(quoteModel)
                    return
                }
            }
            
            //美股指数隐藏提示
            if quoteModel.type1?.value == OBJECT_SECUSecuType1.stIndex.rawValue, quoteModel.market == kYXMarketUS {
                if YXToolUtility.needFinishQuoteNotify() {
                    self.quoteStatementShadeView.isHidden = false
                } else if !YXUserManager.isOpenAccount(broker: YXBrokersBitType.sg) {
                    self.stockIndexShadeView.isHidden = false
                } else {
                    self.stockIndexShadeView.isHidden = true
                }
                
            } else {
                self.stockIndexShadeView.isHidden = true
            }
            
            self.updateQuoteData(quoteModel)
        }))
        
    }
    
    func updateQuoteData(_ quoteModel: YXV2Quote) {
        self.viewModel.quoteModel = quoteModel
        if self.viewModel.type1 == nil {
            self.viewModel.type1 = quoteModel.type1?.value ?? 0
            self.viewModel.type2 = quoteModel.type2?.value ?? 0
            self.viewModel.type3 = quoteModel.type3?.value ?? 0
        }

        let status = Int(quoteModel.trdStatus?.value ?? OBJECT_QUOTETradingStatus.tsNormal.rawValue)
        var str: String?
        if status == OBJECT_QUOTETradingStatus.tsSuspended.rawValue {
            str = YXLanguageUtility.kLang(key: "stock_detail_suspenden")

        } else if status == OBJECT_QUOTETradingStatus.tsDelisting.rawValue  {
            str = YXLanguageUtility.kLang(key: "stock_detail_delisted")
        }  else if status == OBJECT_QUOTETradingStatus.tsUnlisted.rawValue {
            str = YXLanguageUtility.kLang(key: "stock_detail_beforList")
        } else if status == OBJECT_QUOTETradingStatus.tsZanting.rawValue {
            str = YXLanguageUtility.kLang(key: "zanting")
        } else {

        }
        if let text = str {
            self.headerView.statusMarketString = text
        }

        self.headerView.quoteModel = quoteModel
//        self.dealView.quoteModel = quoteModel
        self.lineView.quoteModel = quoteModel

        if !self.isConfirmType {
            
            self.isConfirmType = true
            // 股票确认的时候, 选择usmart的话,重置MA
            var needResetMa = false
            if YXKLineConfigManager.shareInstance().mainAccessory == .usmart {
                if self.viewModel.isFromStockDetailVC {
                    self.viewModel.isFromStockDetailVC = false
                    needResetMa = false
                } else {
                    needResetMa = true
                }
                if needResetMa {
                    YXKLineConfigManager.shareInstance().mainAccessory = .MA
                }
            }
            
            // 是否有盘前盘后分时
            if !YXStockDetailUtility.canSupportTimelineExpand(quoteModel) {
                self.lineView.klineTabView.hasTsExpand = false
            } else {
                self.lineView.klineTabView.hasTsExpand = true
                if let tsType = self.viewModel.selectTsType {
                    self.lineView.klineTabView.subTsType = tsType
                    ///设置完后,重置为nil
                    self.viewModel.selectTsType = nil
                } else {
                    let type = YXStockDetailUtility.getTimeShareType(with: quoteModel)
                    self.lineView.klineTabView.subTsType = type
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.selectLineType(with: YXKLineConfigManager.shareInstance().lineType)
            }
            
            //优先判断暗盘
            if let greyFlag = quoteModel.greyFlag?.value, greyFlag != 0 {

                self.viewModel.greyFlag = true
                if YXUserManager.isLogin() {
                    self.dealView.isGreyFlag = true
                }
            }

            if self.viewModel.stockType == .stIndex && self.viewModel.market == "hk" {
                self.headerView.hkIndex = true
                self.lineView.isHkIndex = true
                YXKlineCalculateTool.shareInstance().isHKIndex = true
            } else {
                
                if self.viewModel.stockType == .stIndex && self.viewModel.market == "us" {
                    self.headerView.usIndex = true
                }
                YXKlineCalculateTool.shareInstance().isHKIndex = false
            }
        
            

            self.handleShowAskBidView()
            self.handleShowCYQView()

            if YXStockDetailTool.isGemStock(quoteModel) {
                self.lineView.timeLineView.isGem = true
            }
            self.accessoryView.quoteModel = quoteModel

            if let market = quoteModel.market, market == kYXMarketUsOption {
                self.lineView.isOptionStock = true
            }

            if self.viewModel.market == kYXMarketSG, self.viewModel.level == .delay {
                self.dealView.isOnlyTick = true
            }
        }

        if self.needLoadHoldAsset && YXKLineConfigManager.shareInstance().showHoldPrice  && (YXStockDetailTool.canShowShortcut(quoteModel) || YXStockDetailTool.canOptionTrade(quoteModel)) {
            self.needLoadHoldAsset = false
            if self.viewModel.market == kYXMarketUsOption {
//                self.viewModel.loadOptionHoldAssetData()
            } else {
                self.viewModel.loadHoldAssetData()
            }
        }

        if self.tickRequest == nil, YXStockDetailTool.isShowTick(quoteModel) {
            self.loadTickData()
        }
        if self.posBrokerRequest == nil, YXStockDetailTool.isShowAskBid(quoteModel) {
            self.loadPosBrokerData()
        }
    }
    
    // 高级k线
    func loadHighKLineData() {
        
        highKlineRequest?.cancel()
        hightTimelineRequest?.cancel()
        var userLevel = self.viewModel.level
        if self.viewModel.greyFlag {
            userLevel = .delay
        }
        highKlineRequest = YXQuoteManager.sharedInstance.subKLineQuote(secu: Secu(market: self.viewModel.market, symbol: self.viewModel.symbol), type: OBJECT_QUOTEKLineType.init(rawValue: Int32(self.viewModel.timeLineType) ?? 7) ?? .ktDay, direction: self.viewModel.direction, level: userLevel, handler: ({ [weak self](klineData, scehme) in
            guard let `self` = self else { return }

            self.viewModel.kLineData = klineData
            
            if self.viewModel.market == kYXMarketCryptos {
                self.lineView.kLineView.decimalCount = YXToolUtility.btDecimalPoint(self.viewModel.quoteModel?.btRealTime?.now)
            }
            if self.isKlineLoadingMore {
                return
            }
            if !self.hasRemoveKlineOrderCache, YXKLineConfigManager.shareInstance().lineType == .dayKline {
                self.hasRemoveKlineOrderCache = true
                YXStockDetailTool.removeAllKLineOrderCache(klineData)
            }

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
            self.lineView.refreshKLineView(klineData)
            self.lineView.loadingView.isHidden = true
            
        }), failed: ({ [weak self] in
            guard let `self` = self else { return }

            if self.isKlineLoadingMore {
                return
            }
            self.lineView.loadingView.isHidden = true
            self.lineView.refreshKLineView(nil)

        }))

        if YXKLineConfigManager.shareInstance().lineType == .dayKline, YXStockDetailTool.isShowCYQ(self.viewModel.quoteModel) {
            self.requestCYQData(self.cyqRequestTime)
            self.cyqView.market = self.viewModel.market
            self.cyqView.level = self.viewModel.level
        }
    }
    
    // 高级分時
    func loadHighTimeLineData() {
        
        hightTimelineRequest?.cancel()
        highKlineRequest?.cancel()
        if self.viewModel.market == kYXMarketCryptos {
            loadBTTimeLineData()
            return
        }
        var userLevel = self.viewModel.level
        if self.viewModel.greyFlag {
            userLevel = .delay
        }
        
        var timeLineType: YXTimeShareLineType = .intra
        if self.lineView.klineTabView.rtLineType == .dayTimeLine {
            if self.lineView.klineTabView.hasTsExpand {
                timeLineType = self.lineView.klineTabView.subTsType
            }
        } else {
            if let quoteModel = self.viewModel.quoteModel {
                timeLineType = YXStockDetailUtility.getFiveDayTimeShareType(with: quoteModel)
            }
        }
        let quoteType = timeLineType.quoteType
        let extra: YXSocketExtraQuote = userLevel == .usNational ? .usNation : .none
        let secu = Secu(market: self.viewModel.market, symbol: self.viewModel.symbol, extra: extra)
        if quoteType == .sQuoteAll {
            hightTimelineRequest = YXQuoteManager.sharedInstance.subFullTimeLineQuote(secu: secu, days: self.viewModel.timeLineType, level: userLevel, type: quoteType, handler: ({ (timelineModel, scheme) in
                if scheme == .tcp {
                    self.timeLineTcpFilter.onNext(timelineModel)
                    return
                }
                self.updateTimelineData(timelineModel, scheme: scheme)
            }) ,failed: ( { [weak self] in
                guard let `self` = self else { return }
                self.lineView.loadingView.isHidden = true
                self.lineView.refreshTimeLineView(nil)
            }))
        } else {

            hightTimelineRequest = YXQuoteManager.sharedInstance.subTimeLineQuote(secu: secu, days: self.viewModel.timeLineType, level: userLevel, type: quoteType, handler: ({ (timelineModel, scheme) in
                if scheme == .tcp {
                    self.timeLineTcpFilter.onNext(timelineModel)
                    return
                }
                self.updateTimelineData(timelineModel, scheme: scheme)
                
            }) ,failed: ( { [weak self] in
                guard let `self` = self else { return }
                self.lineView.loadingView.isHidden = true
                self.lineView.refreshTimeLineView(nil)
            }))
        }
    }
    
    func updateTimelineData(_ timelineModel: YXTimeLineData, scheme: Scheme) {
        self.lineView.loadingView.isHidden = true
        if self.tickTimeLine == .intra || self.tickTimeLine == .none {
            if let quote = self.viewModel.quoteModel, let priceBase = quote.priceBase?.value,
                let high = quote.high?.value, let low = quote.low?.value {
                
                let priceBasic: Double = pow(10.0, Double(priceBase) * 1.0)
                self.lineView.timeLineView.high = Double(high) / priceBasic
                self.lineView.timeLineView.low = Double(low) / priceBasic
            }
        } else {
            self.lineView.timeLineView.high = 0
            self.lineView.timeLineView.low = 0
        }

        if YXKLineConfigManager.shareInstance().lineType == .dayTimeLine, let lineData = timelineModel.list?.last, let time1 = lineData.latestTime?.value, let time2 = self.viewModel.lastTimelineData?.latestTime?.value, time1 == time2 {
            lineData.klineEvents = self.viewModel.lastTimelineData?.klineEvents
        }
        
        var change = 0
        if let pctchng = self.viewModel.quoteModel?.pctchng?.value {
            if pctchng > 0 {
                change = 1
            } else if pctchng < 0 {
                change = -1
            }
         }
        self.lineView.timeLineView.change = change

        self.lineView.refreshTimeLineView(timelineModel)

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
        self.viewModel.timeLineType = YXStockDetailTool.lineTypeString(type)

        highKlineRequest = YXQuoteManager.sharedInstance.subKLineQuote(secu: Secu(market: self.viewModel.market, symbol: self.viewModel.symbol), type: OBJECT_QUOTEKLineType.init(rawValue: Int32(self.viewModel.timeLineType) ?? 1) ?? .ktMin1, direction: self.viewModel.direction, level: self.viewModel.level, count: 1440, handler: ({ [weak self](klineData, scehme) in
            guard let `self` = self else { return }

            if scehme == .tcp {
                self.btTimeLineTcpFilter.onNext(klineData)
                return
            }
            self.updateBTTimelineData(klineData)

        }), failed: ({ [weak self] in
            guard let `self` = self else { return }
            self.lineView.loadingView.isHidden = true
            self.lineView.refreshBTTimeLineView(nil)
        }))
    }
    
    func updateBTTimelineData(_ klineData: YXKLineData) {
        // 赋值
        if let quote = self.viewModel.quoteModel,
           let high = quote.btRealTime?.high,
           let low = quote.btRealTime?.low {

            self.lineView.btTimeLineView.decimalCount = YXToolUtility.btDecimalPoint(quote.btRealTime?.now)
            self.lineView.btTimeLineView.high = Double(high) ?? 0
            self.lineView.btTimeLineView.low = Double(low) ?? 0
        }
        
        
        var change = 0
        if let pctchngStr = self.viewModel.quoteModel?.btRealTime?.pctchng, let pctchng = Double(pctchngStr) {
            if pctchng > 0 {
                change = 1
            } else if pctchng < 0 {
                change = -1
            }
         }

        self.lineView.btTimeLineView.change = change
        self.lineView.refreshBTTimeLineView(klineData)
        self.lineView.loadingView.isHidden = true
    }
    
    func loadPosBrokerData() {
        guard YXStockDetailTool.isShowAskBid(self.viewModel.quoteModel) else { return }
        posBrokerRequest?.cancel()
        
//        var tempGreyMarketType = self.viewModel.greyMarkeType
//        if let value = self.viewModel.quoteModel?.greyFlag?.value, value > 0 {
//            let supportType = YXStockDetailTool.greyMarketSupportType(self.viewModel.quoteModel)
//            if supportType.contains(.phillip), !supportType.contains(.futu), self.viewModel.greyMarkeType == .futu {
//                tempGreyMarketType = .phillip
//            } else if !supportType.contains(.phillip), supportType.contains(.futu), self.viewModel.greyMarkeType == .phillip {
//                tempGreyMarketType = .futu
//            }
//        }
        
        posBrokerRequest = YXQuoteManager.sharedInstance.subPosAndBroker(secu: Secu(market: self.viewModel.market, symbol: self.viewModel.symbol), level: self.viewModel.level, handler: { posBroker, scheme in
            if scheme == .tcp {
                self.posBrokerFilter.onNext(posBroker)
            } else {
                self.updatePosBrokerData(posBroker)
            }
        })
    }
    
    // tick
    func loadTickData() {
                
        guard YXStockDetailTool.isShowTick(self.viewModel.quoteModel) else { return }
        tickRequest?.cancel()
        
        
        var timeLineType: YXTimeShareLineType = .intra
        if self.lineView.klineTabView.rtLineType == .dayTimeLine {
            if self.lineView.klineTabView.hasTsExpand {
                timeLineType = self.lineView.klineTabView.subTsType
            }
        } else {
            if let quoteModel = self.viewModel.quoteModel {
                timeLineType = YXStockDetailUtility.getFiveDayTimeShareType(with: quoteModel)
            }
        }
        let quoteType = timeLineType.quoteType
        let extra: YXSocketExtraQuote = self.viewModel.level == .usNational ? .usNation : .none
        let secu = Secu(market: self.viewModel.market, symbol: self.viewModel.symbol, extra: extra)
        
        tickTimeLine = timeLineType
        
        if quoteType == .sQuoteAll {
            tickRequest = YXQuoteManager.sharedInstance.subFullTickQuote(secu: secu, level: self.viewModel.level, type: quoteType, handler: ({ [weak self] (tickModel, scheme) in
                guard let `self` = self else { return }
                if scheme == .tcp {
                    self.tickTcpFilter.onNext(tickModel)
                    return
                }
                self.updateTickData(tickModel)
            }))
        } else {
            tickRequest = YXQuoteManager.sharedInstance.subTickQuote(secu: secu, level: self.viewModel.level, type: quoteType, handler: ({ [weak self] (tickModel, scheme) in
                guard let `self` = self else { return }
                if scheme == .tcp {
                    self.tickTcpFilter.onNext(tickModel)
                    return
                }
                self.updateTickData(tickModel)
            }))
        }
    }
    
    func updatePosBrokerData(_ posBroker: PosBroker) {
        if posBroker.pos != nil {
            self.dealView.posBroker = posBroker
        }
    }
    
    func updateTickData(_ tickModel: YXTickData) {
        if self.viewModel.quoteModel?.market == kYXMarketCryptos {
            self.dealView.tickView.decimalCount = YXToolUtility.btDecimalPoint(self.viewModel.quoteModel?.btRealTime?.now)
        }
        if let priceBase = tickModel.priceBase?.value, priceBase > 0 {
            self.dealView.tickView.priceBase = priceBase
        } else {
            self.dealView.tickView.priceBase = self.viewModel.quoteModel?.priceBase?.value ?? 0
        }
        
        self.dealView.tickView.pclose = Double(self.viewModel.quoteModel?.preClose?.value ?? 0)
        self.dealView.tickView.lastPrice = UInt32(self.viewModel.quoteModel?.latestPrice?.value ?? 0)
        self.dealView.tickView.tickModel = tickModel
    }
    
    
    lazy var quoteTcpFilter: YXStockDetailTcpFilter<YXV2Quote> = {
        let interval = TimeInterval(YXGlobalConfigManager.configFrequency(.stockRealquoteRefreshFreq)) / 1000.0
        let filter = YXStockDetailTcpFilter<YXV2Quote>(interval: interval) { [weak self] quoteModel in
            guard let `self` = self else { return }
            
            self.updateQuoteData(quoteModel)
        }
        
        return filter
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
            
            self.updateBTTimelineData(klineData)
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
}

extension YXStockDetailLandVC {
    
    func bindViewModel() {

        self.handleLineViewBlock()
        
        self.accessoryView.adjustTypeCallBack = { [weak self] tag in
            guard let `self` = self else { return }

            self.lineView.loadingView.isHidden = false
            YXKLineConfigManager.shareInstance().adjustType = tag
            self.loadHighKLineData()
        }
        
        self.accessoryView.mainParameterCallBack = { [weak self] tag in

            guard let `self` = self else { return }
            let type: YXStockMainAcessoryStatus = tag
            YXKLineConfigManager.shareInstance().mainAccessory = type
            if let klineData = self.lineView.kLineView.klineModel {
                YXKlineCalculateTool.shareInstance().calAccessoryValue(klineData)
                self.lineView.refreshKLineView(klineData)
            }
            if type == .usmart {
                self.handleSignalData()
            }
            if !self.cyqView.isHidden {
                self.cyqView.chartView.reSetChart(with: Int64(self.lineView.kLineView.getMaxPriceValue()), minValue: Int64(self.lineView.kLineView.getminPriceValue()))
            }
        }
        
        self.accessoryView.subParameterCallBack = { [weak self] tag in

            guard let `self` = self else { return }

            self.lineView.setCurrentLineTypeHeight()
            if YXKLineConfigManager.shareInstance().subAccessoryArray.count > 0, let klineData = self.lineView.kLineView.klineModel {
                YXKlineCalculateTool.shareInstance().calAccessoryValue(klineData)
                self.lineView.refreshKLineView(klineData)
            }
            if !self.cyqView.isHidden {
                self.cyqView.isFullChart = YXKLineConfigManager.shareInstance().subAccessoryArray.count == 0
            }
        }

        self.accessoryView.chipsCYQCallBack = {
            [weak self] isSelect in
            guard let `self` = self else { return }

            YXCYQUtility.saveCYQState(isSelect)
            self.handleShowCYQView()
            if isSelect {
                self.requestCYQData(0)
            }
            self.cyqView.isFullChart = YXKLineConfigManager.shareInstance().subAccessoryArray.count == 0
        }


        self.cyqView.loginClosure = {
            [weak self]  in
            guard let `self` = self else { return }
            // 未登錄
            let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: nil, vc: self))
            self.viewModel.navigator.push(YXModulePaths.defaultLogin.url, context: context)
        }

        self.cyqView.upgradeClosure = {

            if let url = URL(string: YXH5Urls.goBuyOnLineUrl()) {
                UIApplication.shared.open(url)
            }
        }

        self.cyqView.reloadDataClosure = {
            [weak self]  in
            guard let `self` = self else { return }
            self.requestCYQData(self.cyqRequestTime)
        }

        self.cyqView.doubleTapClosure = {
            [weak self] in
            guard let `self` = self else { return }
            self.closeDidClick()
        }

        self.viewModel.holdAssetSubject.subscribe(onNext: { [weak self] holdPrice in
            guard let `self` = self else { return }
            if holdPrice > 0 {
                self.lineView.holdPrice = holdPrice
            }

        }).disposed(by: rx.disposeBag)

        self.viewModel.klineOrderSubject.subscribe(onNext: { [weak self] model in
            guard let `self` = self else { return }

            if YXKLineConfigManager.shareInstance().lineType == .dayKline && (YXKLineConfigManager.shareInstance().showBuySellPoint || YXKLineConfigManager.shareInstance().showCompanyActionPoint) {
                self.lineView.kLineView.reload()
            }
        }).disposed(by: rx.disposeBag)

        self.viewModel.timeLineOrderSubject.subscribe(onNext: { [weak self] model in
            guard let `self` = self else { return }

            if YXKLineConfigManager.shareInstance().lineType == .dayTimeLine && YXKLineConfigManager.shareInstance().showBuySellPoint {
                YXStockDetailTool.mergeOrderDataToTimeline(orderModel: model, timelineData: self.lineView.timeLineView.timeLineModel)
                self.viewModel.lastTimelineData = self.lineView.timeLineView.timeLineModel.list?.last
                self.lineView.timeLineView.hasOrder = true
                self.lineView.timeLineView.reload()
            }
        }).disposed(by: rx.disposeBag)



        self.cyqView.clickDetailBlock = {
            [weak self] in
             guard let `self` = self else { return }

            let viewModel = YXStockChipDetailViewModel(market: self.viewModel.market, symbol: self.viewModel.symbol, name: self.viewModel.name ?? "")
            viewModel.isFromLand = true
            self.viewModel.navigator.push(YXModulePaths.chipDetail.url, context:viewModel)

        }

    }

    func handleLineViewBlock() {

        self.lineView.selectTpyeCallBack = { [weak self] type in
            guard let `self` = self else { return }
            self.lineView.timeLineView.timeLineModel = nil
            self.lineView.btTimeLineView.klineModel = nil
            self.lineView.kLineView.klineModel = nil
            YXStockDetailUtility.resetRtLineType(type)
            self.selectLineType(with: type)
            self.trackKlineType(type)
            if self.lineView.klineTabView.hasTsExpand {
                MMKV.default().set((self.lineView.klineTabView.subTsType == .all), forKey: "kSelectTimeShareingAllTabKey")
                if self.lineView.klineTabView.subTsType != self.tickTimeLine {
                    self.loadTickData()
                }
            }
        }

        handleDealBlock()

        self.lineView.klineLoadMoreBlock = {
            [weak self] in
            guard let `self` = self, let request = self.highKlineRequest else { return }
            self.isKlineLoadingMore = true
            request.nextKLine(succeed: ({ [weak self] (success) in
                guard let `self` = self else { return }
                self.isKlineLoadingMore = false
                if let klineData = self.viewModel.kLineData {
                    
                    self.viewModel.loadKLineOrderData(klineData)
                    YXKlineCalculateTool.shareInstance().calAccessoryValue(klineData)
                    self.lineView.refreshKLineView(klineData)
                }
                self.lineView.loadingView.isHidden = true

            }), failed: { [weak self] in
                guard let `self` = self else { return }
                self.isKlineLoadingMore = false
                if let klineData = self.viewModel.kLineData {
                    YXKlineCalculateTool.shareInstance().calAccessoryValue(klineData)
                    self.lineView.refreshKLineView(klineData)
                }
            })
        }
        
        
        self.lineView.kLineView.usmartLineCallBack =  { [weak self] type in
            guard let `self` = self else { return }
            if type == 0 {
                // 登录
                // 未登錄
                let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: nil, vc: self))
                self.viewModel.navigator.push(YXModulePaths.defaultLogin.url, context: context)
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


        self.lineView.kLineView.clickSubAccessoryView = {
            [weak self] in
            guard let `self` = self, let list = self.lineView.kLineView.klineModel.list, list.count > 0 else { return }

            if YXKLineConfigManager.shareInstance().subAccessoryArray.count == 1,
                let obj = YXKLineConfigManager.shareInstance().subAccessoryArray.firstObject as? NSNumber {
                YXKLineConfigManager.shareInstance().subAccessoryArray.removeAllObjects()
                let status = obj.intValue
                let count = YXKLineConfigManager.shareInstance().subArr.count
                for i in 0..<count {
                    let number = YXKLineConfigManager.shareInstance().subArr[i]
                    if let num = number as? NSNumber, num.intValue == status {
                        if i == count - 1 {
                            if let tempNum = YXKLineConfigManager.shareInstance().subArr.firstObject as? NSNumber, let _ = YXStockSubAccessoryStatus(rawValue: tempNum.intValue) {

                                YXKLineConfigManager.shareInstance().subAccessoryArray.append(tempNum)
                            }
                        } else {
                            if let tempNum = YXKLineConfigManager.shareInstance().subArr[i + 1] as? NSNumber, let _ = YXStockSubAccessoryStatus(rawValue: tempNum.intValue) {

                                YXKLineConfigManager.shareInstance().subAccessoryArray.append(tempNum)
                            }
                        }
                        break
                    }
                }

                self.accessoryView.resetSubStatus()

                if let klineData = self.lineView.kLineView.klineModel {
                    YXKlineCalculateTool.shareInstance().calAccessoryValue(klineData)
                    self.lineView.refreshKLineView(klineData)
                }

            }

        }

        self.lineView.timeLineView.timeLineLongPressStartCallBack = {
            [weak self] timeLine in
            guard let `self` = self else { return }

            if self.timeLineLongPressView.superview == nil {
                self.timeLineLongPressView.removeFromSuperview()
                self.view.addSubview(self.timeLineLongPressView)
                self.timeLineLongPressView.snp.makeConstraints { (make) in
                    make.top.equalToSuperview()
                    make.right.equalToSuperview()
                    make.left.equalToSuperview().offset(YXConstant.navBarPadding())
                    make.height.greaterThanOrEqualTo(98)
                }
                self.timeLineLongPressView.market = self.viewModel.quoteModel?.market ?? ""
                if let type1 = self.viewModel.quoteModel?.type1?.value, type1 == OBJECT_SECUSecuType1.stIndex.rawValue {
                    if self.timeLineLongPressView.market == YXMarketType.HK.rawValue {
                        self.timeLineLongPressView.hiddenVolume()
                    } else if self.timeLineLongPressView.market == YXMarketType.US.rawValue {
                        self.timeLineLongPressView.hiddenAmount()
                    }
                }
            }
            self.timeLineLongPressView.isHidden = false
            if let lineModel = timeLine {
                self.timeLineLongPressView.timeSignalModel = lineModel
            }
        }

        self.lineView.timeLineView.timeLineLongPressEndCallBack = {
            [weak self] in
            guard let `self` = self else { return }
            //self.timeLineLongPressView.removeFromSuperview()
            self.timeLineLongPressView.isHidden = true
        }

        self.lineView.kLineView.klineLongPressStartCallBack = {
            [weak self] kline in
            guard let `self` = self else { return }

            if self.klineLongPressView.superview == nil {
                self.klineLongPressView.removeFromSuperview()
                self.view.addSubview(self.klineLongPressView)
                let isGem = YXStockDetailTool.isGemStock(self.viewModel.quoteModel)
                self.klineLongPressView.snp.makeConstraints { (make) in
                    make.top.equalToSuperview()
                    make.right.equalToSuperview()
                    make.left.equalToSuperview().offset(YXConstant.navBarPadding())
                    make.height.greaterThanOrEqualTo(98)
                }
                self.klineLongPressView.market = self.viewModel.quoteModel?.market ?? ""
                self.klineLongPressView.isGem = isGem
                self.klineLongPressView.oritentType = .right
                self.klineLongPressView.setUpUI()
                if let type1 = self.viewModel.quoteModel?.type1?.value, type1 == OBJECT_SECUSecuType1.stIndex.rawValue {
                    if self.klineLongPressView.market == YXMarketType.HK.rawValue {
                        self.klineLongPressView.hiddenVolume()
                    } else if self.timeLineLongPressView.market == YXMarketType.US.rawValue {
                        self.klineLongPressView.hiddenAmount()
                    }
                }
            }

            if self.klineLongPressView.isHidden {
                self.klineLongPressView.isHidden = false
                if self.viewModel.market == kYXMarketCryptos {
                    self.klineLongPressView.decimalCount = YXToolUtility.btDecimalPoint(self.viewModel.quoteModel?.btRealTime?.now)
                }
                if let type = self.lineView.kLineView.klineModel.type?.value, type < 7 {
                    self.klineLongPressView.showFullTime = true
                } else {
                    self.klineLongPressView.showFullTime = false
                }
            }
            if let lineModel = kline {
                self.klineLongPressView.kLineSingleModel = lineModel
                if self.cyqView.isHidden == false {
                    self.requestCYQData(lineModel.latestTime?.value ?? 0)
                }
            }
        }

        self.lineView.kLineView.klineLongPressEndCallBack = {
            [weak self] in
            guard let `self` = self else { return }
            //self.klineLongPressView.removeFromSuperview()
            self.klineLongPressView.isHidden = true
        }

        self.lineView.kLineView.doubleTapCallBack = {
            [weak self] in
            guard let `self` = self else { return }
            self.closeDidClick()
        }

        self.lineView.timeLineView.doubleTapCallBack = {
            [weak self] in
            guard let `self` = self else { return }
            self.closeDidClick()
        }

        self.lineView.doubleTapClosure = {
            [weak self] in
            guard let `self` = self else { return }
            self.closeDidClick()
        }

        self.lineView.btTimeLineView.klineLongPressStartCallBack = {
            [weak self] kline in
            guard let `self` = self else { return }

            if self.klineLongPressView.superview == nil {
                self.klineLongPressView.removeFromSuperview()
                self.view.addSubview(self.klineLongPressView)
                let isGem = YXStockDetailTool.isGemStock(self.viewModel.quoteModel)
                self.klineLongPressView.snp.makeConstraints { (make) in
                    make.top.equalToSuperview()
                    make.right.equalToSuperview()
                    make.left.equalToSuperview().offset(YXConstant.navBarPadding())
                    make.height.greaterThanOrEqualTo(98)
                }
                self.klineLongPressView.market = self.viewModel.quoteModel?.market ?? ""
                self.klineLongPressView.isGem = isGem
                self.klineLongPressView.oritentType = .right
                self.klineLongPressView.setUpUI()
                if let type1 = self.viewModel.quoteModel?.type1?.value, type1 == OBJECT_SECUSecuType1.stIndex.rawValue {
                    if self.klineLongPressView.market == YXMarketType.HK.rawValue {
                        self.klineLongPressView.hiddenVolume()
                    } else if self.timeLineLongPressView.market == YXMarketType.US.rawValue {
                        self.klineLongPressView.hiddenAmount()
                    }
                }
            }

            if self.klineLongPressView.isHidden {
                self.klineLongPressView.isHidden = false
                self.klineLongPressView.showFullTime = true
                self.klineLongPressView.decimalCount = YXToolUtility.btDecimalPoint(self.viewModel.quoteModel?.btRealTime?.now)
            }
            if let lineModel = kline {
                self.klineLongPressView.kLineSingleModel = lineModel
                if self.cyqView.isHidden == false {
                    self.requestCYQData(lineModel.latestTime?.value ?? 0)
                }
            }
        }

        self.lineView.btTimeLineView.klineLongPressEndCallBack = {
            [weak self] in
            guard let `self` = self else { return }
            //self.klineLongPressView.removeFromSuperview()
            self.klineLongPressView.isHidden = true
        }

        self.lineView.btTimeLineView.doubleTapCallBack = {
            [weak self] in
            guard let `self` = self else { return }
            self.closeDidClick()
        }
        
        self.lineView.kLineView.lastDayChangeCallBack = { [weak self] time in
            guard let `self` = self else { return }
            self.requestCYQData(time)
        }

        handleLongPressViewBlock()
    }

    func handleLongPressViewBlock() {
        self.klineLongPressView.orderDetailView.clickToDetailBlock = {
            [weak self] (date, orderType) in
            guard let `self` = self else { return }

            self.pushToOrderList(date, orderType: orderType)
        }

        self.timeLineLongPressView.orderDetailView.clickToDetailBlock = {
            [weak self] (date, orderType) in
            guard let `self` = self else { return }

            self.pushToOrderList(date, orderType: orderType)
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

    func handleDealBlock() {
        //tick加载更多
        dealView.tickView.loadMoreCallBack = { [weak self] start, tradeTime in
            guard let `self` = self else { return }

            self.tickRequest?.nextTick(succeed: ({ (success) in
                self.dealView.tickView.reload(withMoreLoad: success)
            }), failed: nil)
        }
    }

    func trackKlineType(_ type: YXRtLineType) {
        var propViewName = ""
        var propViewId = ""
        switch type {
            case .dayTimeLine:
                propViewName = "分时"
                propViewId = "time_sharing_tab"
            case .fiveDaysTimeLine:
                propViewName = "5日"
                propViewId = "five_day_tab"
            case .dayKline:
                propViewName = "日K"
                propViewId = "k_day_tab"
            case .weekKline:
                propViewName = "周K"
                propViewId = "k_week_tab"
            case .monthKline:
                propViewName = "月K"
                propViewId = "k_month_tab"
            case .seasonKline:
                propViewName = "季K"
                propViewId = "k_season_tab"
            case .yearKline:
                propViewName = "年K"
                propViewId = "k_year_tab"
            /*
             case .oneMinKline:
             propViewName = "1分"
             propViewId = "k_one_min_tab"
             case .fiveMinKline:
             propViewName = "5分"
             propViewId = "k_five_min_tab"
             case .fifteenMinKline:
             propViewName = "15分"
             propViewId = "k_fifteen_min_tab"
             case .thirtyMinKline:
             propViewName = "30分"
             propViewId = "k_thirty_min_tab"
             case .sixtyMinKline:
             propViewName = "60分"
             propViewId = "k_sixty_min_tab"
             */
            default:
                break
        }

    }

    
    // MARK: - 选择类型.
    func selectLineType(with type: YXRtLineType) {

        self.viewModel.timeLineType = YXStockDetailTool.lineTypeString(type)

        if type == .dayTimeLine || type == .fiveDaysTimeLine {
            self.accessoryView.isHidden = true
        } else {
            self.accessoryView.isHidden = false
        }

        self.lineView.loadingView.isHidden = false
        self.loadLineData(type: type)
        self.handleShowAskBidView()
        self.handleShowCYQView()
    }

    func handleShowAskBidView() {
        self.lineView.isCryptos = (self.viewModel.market == kYXMarketCryptos)
        if YXStockDetailTool.isShowTick(self.viewModel.quoteModel) && self.lineView.lineType == .dayTimeLine {
            self.lineView.rPadding = self.dealPadding
            self.dealView.isHidden = false
        } else {
            self.lineView.rPadding = 0
            self.dealView.isHidden = true
        }
    }

    func handleShowCYQView() {
        if YXStockDetailTool.isShowCYQ(self.viewModel.quoteModel), self.lineView.lineType == .dayKline {
            if YXCYQUtility.isShowCYQ() {
                self.lineView.klinePadding = 140
                self.cyqView.isHidden = false
            } else {
                self.lineView.klinePadding = 0
                self.cyqView.isHidden = true
            }
            self.accessoryView.showCYQ = true
        } else {
            self.lineView.klinePadding = 0
            self.cyqView.isHidden = true
            self.accessoryView.showCYQ = false
        }
    }

    func requestCYQData(_ interval: UInt64) {
        if task != nil {
            DispatchQueue.cancel(task)
            task = DispatchQueue.delay(0.2, task: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delayRequestCyqData(interval)
                strongSelf.task = nil
            })
        } else {
            task = DispatchQueue.delay(0.2, task: {
                self.delayRequestCyqData(interval)
            })
        }
    }
    
    func delayRequestCyqData(_ interval: UInt64) {
        guard YXUserManager.isLogin(), self.viewModel.level.rawValue >= QuoteLevel.bmp.rawValue else {
            return
        }
        if self.cyqView.isHidden {
            return
        }
        if self.viewModel.level != .delay {
            let rights = Int(self.viewModel.direction.rawValue)
            if interval != 0, self.cyqRequestTime == interval, self.cyqView.model != nil, rights == YXCYQRequestTool.shared.rights {
                return
            }
            cyqRequestTime = interval
            YXCYQRequestTool.shared.requestCYQData(String(format: "%@%@", self.viewModel.market, self.viewModel.symbol), timeInterval: interval, rights: rights) { [weak self] (model, originInterval) in
                guard let `self` = self else { return }
                if self.cyqRequestTime == originInterval {
                    DispatchQueue.main.async {
                        self.cyqView.chartView.reSetChart(with: Int64(self.lineView.kLineView.getMaxPriceValue()), minValue: Int64(self.lineView.kLineView.getminPriceValue()))
                        self.cyqView.model = model
                    }
                }
            }
        }
    }
}

//MARK: - 趋势长盈

extension YXStockDetailLandVC {
    
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
                                if let kLineData =  self.lineView.kLineView.klineModel {
                                    self.lineView.refreshKLineView((kLineData))
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
                self.lineView.refreshKLineView((kLineData))
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
                    
                    if let a = a, a.count > 0 , let kLineData =  self.lineView.kLineView.klineModel {
                        self.viewModel.signalList = a
                        YXStockDetailUtility.mergeUsmartSingalData(a, toTime: kLineData)
                        self.viewModel.lastKlineData = self.viewModel.kLineData?.list?.last
                        self.lineView.refreshKLineView((kLineData))
                    }
                }
            }
        }, failure: { (request) in
            
        })
    }
}

