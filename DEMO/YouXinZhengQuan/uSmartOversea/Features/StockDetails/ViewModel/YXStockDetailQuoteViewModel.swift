//
//  YXStockDetailQuoteViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/12/21.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import YYModel
import URLNavigator
import YXKit

extension YXV2Quote {
    
    var stockType: YXStockDetailStockType {
        
        guard let market = market else { return .hkStock }
        let type1 = OBJECT_SECUSecuType1(rawValue: Int32(self.type1?.value ?? 0))
        let type3 = OBJECT_SECUSecuType3(rawValue: Int32(self.type3?.value ?? 0))
        if market == YXMarketType.Cryptos.rawValue {
            return .cryptos
        } else if type1 == .stStock { //stock
            if market.elementsEqual(YXMarketType.HK.rawValue) {
                return .hkStock
            } else if market.elementsEqual(YXMarketType.US.rawValue) {
                return .usStock
            } else if market.elementsEqual(YXMarketType.SG.rawValue) {
                return .sgStock
            }else {
                return .shStock
            }
        } else if type1 == .stIndex { //index
            return .stIndex
        } else if type1 == .stFund { //fund
            if type3 == .stTrustFundReit{
                return .stTrustFundReit
            }
            return .fund
        } else if type1 == .stBond { //fund
            return .bond
        } else if type1 == .stSector {
            return .stSector
        } else if type3 == .stWarrant { //warrant
            return .stWarrant
        } else if type3 == .stCbbc { //cbbc
            return .stCbbc
        } else if type3 == .stInlineWarrant {
            return .stInlineWarrant
        } else if type3 == .stUsWarrant {
            return .stUsWarrant
        } else if type3 == .stSgDlc {
            return .stSgDlc
        } else if type3 == .stSgWarrant {
            return .stSgWarrant
        } else if self.market == kYXMarketUsOption {
            return .stUsStockOpt
        }
        return .hkStock
    }
}

class YXStockDetailQuoteViewModel: HUDServicesViewModel  {

    // hud的信号
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    //step/service
    typealias Services = HasYXQuotesDataService & HasYXMessageCenterService & HasYXStockAnalyzeService
    var navigator: NavigatorServicesType!

    var analyzeService: YXStockAnalyzeService! = YXStockAnalyzeService()

    //MARK: tabTiles and PageControllers
    var pageControllers: [UIViewController] = []
    var tabTitles: [String] = []

    //MARK:- Quote数据变量 及 股票数据变量
    var quoteModel: YXV2Quote?
    var dataSource: [YXStockInputModel] = []
    var selectIndex: Int = 0 //当前数据源在 dataSource 中的位置

    //market/symbol/name
    var market = ""
    var exchangeType: YXExchangeType = .hk
    var symbol = ""
    var name: String?
    var type1: Int32?
    var type2: Int32?
    var type3: Int32?
    var marketSymbol = ""

    var isTecBoard = false //是否是科创板
    var industryHeight: CGFloat = 0


    var greyFlag: Bool = false
    var isADR: Bool = false
    var isLowADR: Bool = false

    //MARK:- k线、分时、Tick相关变量
    var timeLineType: String = "0"
    var klineType: String = "0"

    // 类型
    var highLineType: String = "1"
    var kLineData: YXKLineData?

    //MARK:- 接口响应 及 处理相关变量（Response & Subject）

    var addFocusResponse: YXResultResponse<JSONAny>?

    var stockValueResponse: YXResultResponse<YXStockValueModel>?
    var stockValueSubject = PublishSubject<YXStockValueModel>()

    var technicalInsightResponse: YXResultResponse<YXStockTechnicalModel>?
    var technicalInsightSubject = PublishSubject<YXStockTechnicalModel>()

    var eventReminderResponse: YXResultResponse<YXStockEventReminderModel>?
    var eventReminderSubject = PublishSubject<YXStockEventReminderModel>()

    var importantNewsResponse: YXResultResponse<YXStockImportantNewsModel>?
    var importantNewsSubject = PublishSubject<YXStockImportantNewsModel>()

    var capitalSubject = PublishSubject<YXStockAnalyzeCapitalModel?>()
    var capitalResponse: YXResultResponse<YXStockAnalyzeCapitalModel>?

    var cashFlowSubject = PublishSubject<YXStockAnalyzeCashFlowListModel>()
    var cashFlowResponse: YXResultResponse<YXStockAnalyzeCashFlowListModel>?

    var pageHeightSubject = PublishSubject<Bool>()

    var holdAssetSubject = PublishSubject<Double>()
    var klineOrderSubject = PublishSubject<YXKLineOrderModel>()
    var timeLineOrderSubject = PublishSubject<YXKLineOrderModel>()
    
    // 趋势长盈数据
    var isRequestSignal = false
    var signalList: [YXUsmartSignalModel]?
    var lastKlineData: YXKLine?
    var lastTimelineData: YXTimeLine?
    //MARK: 用户权限
    var level: QuoteLevel {

        if self.greyFlag {
            if YXUserManager.isLogin() {
                return .level2
            } else {
                return .delay
            }
        }

        if self.stockType == .cryptos {
            return .level1
        }

        if let quote = self.quoteModel,
           let type2 = OBJECT_SECUSecuType2(rawValue: Int32(quote.type2?.value ?? 0)), type2 == .stLowAdr {
            return .delay
        }

        return YXUserManager.shared().getLevel(with: self.market)
    }
    
    var extra: YXSocketExtraQuote {
        if self.level == .usNational {
            return .usNation
        } else {
            return .none
        }
    }

    // 高级k线
    var direction: OBJECT_QUOTEKLineDirection {
        let type = YXKLineConfigManager.shareInstance().adjustType
        if type == .notAdjust {
            return .kdNone
        } else if type == .preAdjust {
            return .kdForward
        } else {
            return .kdBackward
        }
    }

    //是否是A股市场
    var isAStockMarket: Bool {
        (self.market == YXMarketType.ChinaHS.rawValue ||
            self.market == YXMarketType.ChinaSZ.rawValue ||
            self.market == YXMarketType.ChinaSH.rawValue)
    }




    var secuType3: OBJECT_SECUSecuType3 {

        OBJECT_SECUSecuType3(rawValue: Int32(self.type3 ?? 0)) ?? .st3None
    }


    //MARK: 买卖档是否可以展示(包括提示)
    func canShowAskBid() -> Bool {
        if self.greyFlag, YXUserManager.isLogin() {
            return true
        }

        if self.stockType == .stIndex || self.isLowADR || self.stockType == .stSector {
            return false
        }

        return true
    }

    //是否是港股指数
    var isHKIndexStock: Bool {
        (self.stockType == .stIndex && self.market == YXMarketType.HK.rawValue)
    }

    //MARK: 股票类型
    var stockType: YXStockDetailStockType {
        return self.quoteModel?.stockType ?? .hkStock
    }

    var services: Services! {
        didSet {
            bindRequestResponse()
        }
    }

    init(dataSource: [YXStockInputModel], selectIndex: Int) {
        self.dataSource = dataSource
        self.selectIndex = selectIndex

        if self.selectIndex >= self.dataSource.count {
            self.selectIndex = self.dataSource.count - 1
        }
        let input = self.dataSource[self.selectIndex]

        setCurrentDataSource(input)
    }


    func pushToLoginVC() {
        let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: nil, vc: UIViewController.current()))
        self.navigator.push(YXModulePaths.defaultLogin.url, context: context)
    }
    
    
    //请求轮证多空信号
    func requestWarrantCbbcData(market: String, symbol: String) -> Single<YXBullBearPbSignalItem?>  {

        return Single<YXBullBearPbSignalItem?>.create { (single) -> Disposable in
          
            let requestModel = YXBullBearPbSignalReqModel()
            requestModel.type = "warrantcbbc"
            requestModel.size = 1
            requestModel.idString = market + symbol

            let request = YXRequest.init(request: requestModel)
            request.startWithBlock(success: { (responseModel) in
                if responseModel.code == .success, let data = responseModel.data {
                    let model = YXBullBearPbSignalResModel.yy_model(with: data)
                    single(.success(model?.list.first))
                } else {
                    single(.success(nil))
                }
            }, failure: { (request) in
                single(.error(NSError.init(domain: "", code: -1, userInfo: nil)))
            })

            return Disposables.create()
        }
    }
}

//MARK:- 股票切换时重置股票信息 及 变量状态重置
extension YXStockDetailQuoteViewModel {
    //股票信息 及 状态重置
    func setCurrentDataSource(_ input: YXStockInputModel) {

        self.market = input.market
        self.symbol = input.symbol
        self.name = input.name
        self.marketSymbol = String(format: "%@%@", self.market, self.symbol)

        self.type1 = input.type1

        self.type2 = input.type2

        self.type3 = input.type3

        if market == YXMarketType.HK.rawValue {
            self.exchangeType = .hk
        } else if market == YXMarketType.US.rawValue {
            self.exchangeType = .us
        } else if market == YXMarketType.ChinaHS.rawValue {
            self.exchangeType = .hs
        } else if market == YXMarketType.ChinaSZ.rawValue {
            self.exchangeType = .sz
        } else if market == YXMarketType.ChinaSH.rawValue {
            self.exchangeType = .sh
        } else if market == YXMarketType.USOption.rawValue {
            self.exchangeType = .usop
        }


        greyFlag = false
        isADR = false
        isLowADR = false

        timeLineType = "0"
        klineType = "0"

        highLineType = "1"
        kLineData = nil

        self.quoteModel = nil

        isTecBoard = false //是否是科创板
        industryHeight = 0

        lastKlineData = nil
        lastTimelineData = nil
    }
}



//MARK:- 处理接口响应Response
extension YXStockDetailQuoteViewModel {

    func bindRequestResponse() {

        //股票浏览（关注度）统计
        addFocusResponse = {
            (response) in
            switch response {
                case .success(let result, let code):
                    if code == .success {

                    } else if let _ = result.msg {

                    }
                case .failed(let error):
                    log(.error, tag: kNetwork, content: "\(error)")

            }
        }

        // 获取股票价值掘金信息
        stockValueResponse = {[weak self] (response) in
            switch response {
                case .success(let result, let code):
                    if code == .success, let data = result.data, let info = data.info {
                        if let notShowFlag = data.notShowFlag, notShowFlag == true {

                        } else {
                            if let valueStatus = info.valueStatus, let rate = valueStatus.rateOfReturnEstimate, rate > 0 {
                                self?.stockValueSubject.onNext(data)
                            }
                        }

                    }
                case .failed(_):
                    break
            }
        }

        // 获取技术洞察信息
        technicalInsightResponse = {[weak self] (response) in
            switch response {
                case .success(let result, let code):
                    if code == .success, let data = result.data {
                        if let notShowFlag = data.notShowFlag, notShowFlag == true {

                        } else if let list = data.signRankList, list.count > 0 {
                            self?.technicalInsightSubject.onNext(data)
                        }
                    }
                case .failed(_):
                    break
            }
        }

        // 获取大事提醒信息
        eventReminderResponse = {[weak self] (response) in
            guard let `self` = self else { return }
            switch response {
                case .success(let result, let code):
                    if code == .success, let data = result.data, let noteList = data.noteList, noteList.count > 0 {
                        self.eventReminderSubject.onNext(data)
                    }
                case .failed(_):
                    break
            }
        }

        // 获取资讯提醒信息
        importantNewsResponse = {[weak self] (response) in
            guard let `self` = self else { return }
            switch response {
                case .success(let result, let code):
                    if code == .success, let data = result.data, let list = data.list, list.count > 0 {
                        self.importantNewsSubject.onNext(data)
                    }
                case .failed(_):
                    break
            }
        }

        // 成交分布
        capitalResponse = {[weak self] (response) in
            switch response {
                case .success(let result, let code):
                    if code == .success, let data = result.data {
                        self?.capitalSubject.onNext(data)
                    } else {
                        self?.capitalSubject.onNext(nil)
                    }
                    break
                case .failed(_):
                    self?.capitalSubject.onNext(nil)
                    break
            }
        }

        // 趋势
        cashFlowResponse = {[weak self] (response) in
            switch response {
                case .success(let result, let code):
                    if code == .success, let data = result.data {
                        self?.cashFlowSubject.onNext(data)
                    }
                    break
                case .failed(_):

                    break
            }
        }

        //
    }
}


//MARK: - K线分时买卖点相关
extension YXStockDetailQuoteViewModel {

    //请求对应股票的持仓成本价
    func loadHoldAssetData() {
        let requestModel = YXStockSingleAssetRequestModel()
        requestModel.stockCode = self.symbol

        if self.market == YXMarketType.HK.rawValue {
            requestModel.exchangeType = 0
        } else if self.market == YXMarketType.US.rawValue {
            requestModel.exchangeType = 5
        } else {
            requestModel.exchangeType = 67
        }

        let request = YXRequest.init(request: requestModel)
        request.startWithBlock(success: { [weak self] (responseModel) in
            guard let `self` = self else { return }
            if responseModel.code == YXResponseStatusCode.success, let data = responseModel.data {
                let model = YXJYHoldStockModel.yy_model(withJSON: data)

                if let holdModel = model, let costPrice = Double(holdModel.costPrice ?? "0") {
                    self.holdAssetSubject.onNext(costPrice)
                }
            }
        }, failure: { (request) in

        })

    }
    //请求对应期权股票的持仓成本价
//    func loadOptionHoldAssetData() {
//        let requestModel = YXOptionHoldInfoRequestModel()
//        requestModel.code = self.symbol
//        requestModel.exchangeType = 51
//        requestModel.multiplier = self.quoteModel?.contractSize?.value ?? 0
//
//        let request = YXRequest.init(request: requestModel)
//        request.startWithBlock(success: { [weak self] (responseModel) in
//            guard let `self` = self else { return }
//            if responseModel.code == YXResponseStatusCode.success, let data = responseModel.data {
//                if let costPrice = data["costPrice"] as? NSNumber {
//                    self.holdAssetSubject.onNext(costPrice.doubleValue)
//                }
//            }
//        }, failure: { (request) in
//
//        })
//    }


    func loadKLineOrderData(_ klineData: YXKLineData) {
        return
        /* 加载K线订单条件
         * 1.用户在设置中打开显示买卖点
         * 2.在当前为日K模式下
         * 3.该只股票可以交易 且 用户可以交易该只股票
         * 4.K线会缓存之前请求的数据，只需要在viewWillAppear, 下拉刷新，加载更多时 请求接口
         */
        guard YXKLineConfigManager.shareInstance().lineType == .dayKline, (YXKLineConfigManager.shareInstance().showBuySellPoint || YXKLineConfigManager.shareInstance().showCompanyActionPoint) else {
            return
        }

        guard let list = klineData.list, list.count > 0 else {
            return
        }

        self.requestLineOrder(beginDate: Int64(klineData.list?.first?.latestTime?.value ?? 0), endDate: Int64(klineData.list?.last?.latestTime?.value ?? 0), type: "kline1Day") { [weak self] (model) in
            guard let `self` = self else { return }
            
            YXStockDetailTool.mergeOrderDataToKLine(orderModel: model, klineData: self.kLineData)
            self.lastKlineData = self.kLineData?.list?.last
            self.klineOrderSubject.onNext(model)
        }
    }

    func loadTimeLineOrderData(_ timelineData: YXTimeLineData) {
        return
        /* 加载K线订单条件
         * 1.用户在设置中打开显示买卖点
         * 2.在当前为1日分时模式下
         * 3.该只股票可以交易 且 用户可以交易该只股票
         *  分时每次http请求都会覆盖之前的数据，买卖点都需要重新请求
         */
        guard let quoteModel = self.quoteModel, YXKLineConfigManager.shareInstance().lineType == .dayTimeLine, YXKLineConfigManager.shareInstance().showBuySellPoint, (YXStockDetailTool.canShowShortcut(quoteModel) || YXStockDetailTool.canOptionTrade(quoteModel)) else {
            return
        }

        guard let list = timelineData.list, list.count > 0 else {
            return
        }

        self.requestLineOrder(beginDate: Int64(timelineData.list?.first?.latestTime?.value ?? 0), endDate: Int64(timelineData.list?.last?.latestTime?.value ?? 0), type: "timeline1Day") { [weak self] (model) in
            guard let `self` = self else { return }

            self.timeLineOrderSubject.onNext(model)
        }
    }
    //请求打点信息
    func requestLineOrder(beginDate: Int64, endDate: Int64, type: String, completion: @escaping ((_ model: YXKLineOrderModel) -> Void)) {
        let requestModel = YXKLineOrderRequestModel()
        requestModel.market = self.market
        requestModel.symbol = self.symbol
        requestModel.type = type
        requestModel.beginDate = beginDate
        requestModel.endDate = endDate

        let request = YXRequest.init(request: requestModel)
        request.startWithBlock(success: { (responseModel) in
            if responseModel.code == YXResponseStatusCode.success, let data = responseModel.data {
                let model = YXKLineOrderModel.yy_model(withJSON: data)
                if let holdModel = model, let list = holdModel.list, list.count > 0 {
                    completion(holdModel)
                }
            }
        }, failure: { (request) in

        })
    }

}

//MARK: - 历史分时
extension YXStockDetailQuoteViewModel {

    /* 请求对应时间的历史分时
     * param: date 对应的显示日期 20200921000000000, 格式和K线对应柱子的时间一致
     */
    func loadHistoryTimeLineData(date: Int64) -> Single<YXTimeLineData?>  {

        return Single<YXTimeLineData?>.create { [weak self] (single) -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            let secu = Secu(market: self.market, symbol: self.symbol)
            YXQuoteManager.sharedInstance.onceHistoryTimeLineQuote(secu: secu, days: "1", level: self.level, type: .intraDay, date: date, handler: { (timeLineData, scheme) in

                single(.success(timeLineData))
            }, failed: {
                single(.error(NSError.init(domain: "", code: -1, userInfo: nil)))
            })

            return Disposables.create()
        }
    }
}
