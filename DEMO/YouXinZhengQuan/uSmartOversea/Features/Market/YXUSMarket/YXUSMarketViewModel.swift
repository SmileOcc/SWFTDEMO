//
//  YXUSMarketViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/12/12.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import YXKit
import NSObject_Rx
import URLNavigator

class YXUSMarketViewModel: ServicesViewModel {
    typealias Services = YXMarketService
    
    var navigator: NavigatorServicesType!
    
    var services: YXMarketService! = YXMarketService()
    
    var rankServices = YXNewStockService()
    
    let market = YXMarketType.US.rawValue

    var stareModel: YXStareSignalModel?

    // collectionView数据源
    var dataSource: [[String: Any]]! = [[String: Any]]()
    // 股票分时数据池子
    var timeLinePool: [String: YXBatchTimeLine]! = [String: YXBatchTimeLine]()
    // 热门行业
    var industryRank: YXMarketRankCodeList?
    // 涨跌榜
    var usRank: YXMarketRankCodeList?
    // 月供股
    var monthlyStockRank: YXMarketRankCodeList?
    // 明星股
    var starRank: YXMarketRankCodeList?
    // 热门ETF （跳转时用）
    var hotETF: YXMarketRankCodeList?
    // 热门ETF LIST(展示时用，展示三个)
    var hotETFList: [YXMarketRankCodeListInfo] = []
    // 构造一个字典，存储三个热门ETF与其领涨股的对应关系
    var etfLeadStock: [String: YXMarketRankCodeListInfo] = [:]
    let hotETFLeadStockSubject = PublishSubject<Any>.init()
    let EBK00101ETF = "EBK00101" // 标普ETF
    let EBK00102ETF = "EBK00102" // 道指ETF
    let EBK00103ETF = "EBK00103" // 纳指ETF
    let HOTETFSECONDCONS = "HOTETFSECONDCONS" // 具体指数的成分股前缀
    let HOTETFSECONDEBK001 = "HOTETFSECOND_EBK001" // 指数型
    
    // 猜涨跌
    var guessUpAndDownModel: YXGuessUpAndDownResModel?
    var guessUpDownIndex = 0
    var guessQuoteRequest: YXQuoteRequest?
    
    // 中概股
    var conceptRank: YXMarketRankCodeList?
    // 日内融
    var dailyFundingRank: YXMarketRankCodeList?
    // 每日复盘
    var dailyReplay: [String] = []
    
    let industryRankCode = YXMarketSectionType.industry.rankCode
    let usRankCode = YXMarketSectionType.upsaAndDowns.rankCode
    var usRankSortType: YXStockRankSortType = .roc
    let starRankCode = YXMarketSectionType.star.rankCode
    let hotETFCode = YXMarketSectionType.hotETF.rankCode
    var usRankSortDirection: Int = 1
    let conceptRankCode = YXMarketSectionType.concept.rankCode
    let dailyFundingRankCode = YXMarketSectionType.dailyFunding.rankCode
    let monthlyStockRankCode = YXMarketSectionType.monthlyPayment.rankCode
    
    var timeLineRequest: YXQuoteRequest?
    var indexTimeLineRequest: YXQuoteRequest?
    var indexRequest: YXQuoteRequest?
    var etfRequest: YXQuoteRequest?
    // 排行榜股票分时信号
    let timeLineSubject = PublishSubject<[String: YXBatchTimeLine]>()
    // 指数分时信号
    let indexTimeLineSubject = ReplaySubject<YXTimeLineData?>.create(bufferSize: 1)
    // 指数行情信号
    let indexSubject = BehaviorSubject<[YXV2Quote]>(value: [YXV2Quote(), YXV2Quote(), YXV2Quote()])
    // 指数行情数据源
    var indexDataSource = [YXV2Quote(), YXV2Quote(), YXV2Quote()]
    //ETF
    let etfSubject = BehaviorSubject<[YXV2Quote]>(value: [YXV2Quote(), YXV2Quote(), YXV2Quote()])
    // ETF行情数据源
    var etfDataSource = [YXV2Quote(), YXV2Quote(), YXV2Quote()]
    
    var selectedIndex = 0
    
    lazy var usETFs: [Secu] = {
        // 道琼斯指数
        let DIA = Secu.init(market: market, symbol: YXMarketIndex.DIA.rawValue)
        // 纳指100ETF
        let QQQ = Secu.init(market: market, symbol: YXMarketIndex.QQQ.rawValue)
        // 标普500指数
        let SPY = Secu.init(market: market, symbol: YXMarketIndex.SPY.rawValue)
        
        return [DIA, QQQ, SPY]
    }()
    
    lazy var usIndexs: [Secu] = {
        // 道琼斯指数
        let DJI = Secu.init(market: market, symbol: YXMarketIndex.DJI.rawValue)
        // 纳指100ETF
        let IXIC = Secu.init(market: market, symbol: YXMarketIndex.IXIC.rawValue)
        // 标普500指数
        let SPX = Secu.init(market: market, symbol: YXMarketIndex.SPX.rawValue)
        
        return [DJI, IXIC, SPX]
    }()
    
    func requestIndexData() {
        let level = YXUserManager.shared().getLevel(with: market)
        indexRequest?.cancel()
        indexRequest = YXQuoteManager.sharedInstance.subRtSimpleQuote(secus: usIndexs, level: level, handler: { [weak self](list, scheme) in
            guard let `self` = self else { return }
            var indexDataSource = self.indexDataSource
            if scheme == .http {
                for item in list {
                    if item.market == self.market, item.symbol == YXMarketIndex.DJI.rawValue {
                        item.name = YXLanguageUtility.kLang(key: "dow_jones")
                        indexDataSource[0] = item
                    }else if item.market == self.market, item.symbol == YXMarketIndex.IXIC.rawValue {
                        item.name = YXLanguageUtility.kLang(key: "nasdaq")
                        indexDataSource[1] = item
                    }else if item.market == self.market, item.symbol == YXMarketIndex.SPX.rawValue {
                        item.name = YXLanguageUtility.kLang(key: "s&p_500")
                        indexDataSource[2] = item
                    }
                }
                self.indexDataSource = indexDataSource
                self.indexSubject.onNext(self.indexDataSource)
                
            }else if scheme == .tcp {
                
                if let quote = list.first {
                    for (index, item) in indexDataSource.enumerated() {
                        if quote.symbol == item.symbol, quote.market == item.market {
                            indexDataSource[index] = quote
                            self.indexDataSource = indexDataSource
                            break
                        }
                    }
                    self.indexSubject.onNext(self.indexDataSource)
                }
            }
        })
    }
    
    func requestETFData() {
        let level = YXUserManager.shared().getLevel(with: market)
        etfRequest?.cancel()
        etfRequest = YXQuoteManager.sharedInstance.subRtSimpleQuote(secus: usETFs, level: level, handler: { [weak self](list, scheme) in
            guard let `self` = self else { return }
            var etfDataSource = self.etfDataSource
            if scheme == .http {
                for item in list {
                    if item.market == self.market, item.symbol == YXMarketIndex.DIA.rawValue {
                        etfDataSource[0] = item
                    }else if item.market == self.market, item.symbol == YXMarketIndex.QQQ.rawValue {
                        etfDataSource[1] = item
                    }else if item.market == self.market, item.symbol == YXMarketIndex.SPY.rawValue {
                        etfDataSource[2] = item
                    }
                }
                self.etfDataSource = etfDataSource
                self.etfSubject.onNext(self.etfDataSource)
                
            }else if scheme == .tcp {
                
                if let quote = list.first {
                    for (index, item) in etfDataSource.enumerated() {
                        if quote.symbol == item.symbol, quote.market == item.market {
                            etfDataSource[index] = quote
                            self.etfDataSource = etfDataSource
                            break
                        }
                    }
                    self.etfSubject.onNext(self.etfDataSource)
                }
            }
        })
        requestIndexTimeLineData(index: 0)
    }
    
    func requestIndexTimeLineData(index: Int) {
        selectedIndex = index
        let secu = usETFs[index]
        self.indexTimeLineRequest?.cancel()
        let level = YXUserManager.shared().getLevel(with: market)
        self.indexTimeLineRequest = YXQuoteManager.sharedInstance.subTimeLineQuote(secu: secu, days: "1", level: level, type: .intraDay, handler: { [weak self](timeLineData, scheme) in
            
            self?.indexTimeLineSubject.onNext(timeLineData)
        })
    }
    
    var marketDataSourceSingle: Single<[[String: Any]]> {
        Single<[[String: Any]]>.create(subscribe: { [weak self] (single) -> Disposable in
            guard let strongSelf = self else { return Disposables.create() }
            
            return strongSelf.rankServices.request(.multiQuotesRank(codelist: strongSelf.marketItems()), response: { (response: YXResponseType<YXMarketRankModel>) in
                //                strongSelf.hudSubject.onNext(.hide)
                switch response {
                case .success(let result, let code):
                    if code == .success, let list = result.data?.list {
                        
                        for item in list {
                            
                            if item.data?.rankMarket == self?.market {
                                if item.data?.rankCode == strongSelf.usRankCode {
                                    strongSelf.usRank = item.data
                                    strongSelf.usRank?.level = item.level
                                }else if item.data?.rankCode == strongSelf.conceptRankCode {
                                    strongSelf.conceptRank = item.data
                                    strongSelf.conceptRank?.level = item.level
                                }else if item.data?.rankCode == strongSelf.industryRankCode {
                                    strongSelf.industryRank = item.data
                                }else if item.data?.rankCode == strongSelf.starRankCode {
                                    strongSelf.starRank = item.data
                                    strongSelf.starRank?.level = item.level
                                }else if item.data?.rankCode == strongSelf.dailyFundingRankCode {
                                    strongSelf.dailyFundingRank = item.data
                                    strongSelf.dailyFundingRank?.level = item.level
                                }else if item.data?.rankCode == strongSelf.monthlyStockRankCode {
                                    strongSelf.monthlyStockRank = item.data
                                    strongSelf.monthlyStockRank?.level = item.level
                                }else if item.data?.rankCode == strongSelf.hotETFCode {
                                    if let list = item.data?.list {
                                        strongSelf.hotETF = item.data
                                        strongSelf.hotETFList = list
                                        var tempList = [YXMarketRankCodeListInfo]()
                                        for item in list {
                                            if let code = item.secuCode {
                                                if code == strongSelf.EBK00101ETF || code == strongSelf.EBK00102ETF || code == strongSelf.EBK00103ETF {
                                                    tempList.append(item)
                                                }
                                            }
                                        }
                                        
                                        if tempList.count > 0 {
                                            strongSelf.hotETF?.list = tempList
                                            strongSelf.getHotETFLeadStock(items: tempList)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // 请求得到股票数据后，再去请求股票的分时行情数据
//                        var secus = [Secu]()
//
//                        for item in strongSelf.allStocks() {
//                            if let market = item.trdMarket, let secuCode = item.secuCode {
//                                let secu = Secu.init(market: market, symbol: secuCode)
//                                secus.append(secu)
//                            }
//                        }
//
//                        let level = YXUserManager.shared().getLevel(with: self?.market ?? "")
//                        strongSelf.timeLineRequest?.cancel()
//                        strongSelf.timeLineRequest = YXQuoteManager.sharedInstance.subBatchTimeLine(secus: secus, level: level, handler: { (timeLineList) in
//                            strongSelf.timeLineRequest?.cancel()
//                            for item in strongSelf.allStocks() {
//                                for timeLineModel in timeLineList {
//                                    if item.trdMarket == timeLineModel.market, item.secuCode == timeLineModel.symbol, let market = item.trdMarket, let secuCode = item.secuCode {
//                                        strongSelf.timeLinePool[market + secuCode] = timeLineModel
//                                    }
//                                }
//                            }
//
//                        })
                        
                        strongSelf.dataSource = strongSelf.creatDataSource()
                        single(.success(strongSelf.dataSource))
                        
                    }
                case .failed(let error):
                    log(.error, tag: kNetwork, content: "\(error)")
                    single(.error(error))
                }
            })
            
        })
    }
    
    // 请求热门ETF三个指数型的领涨股
    func getHotETFLeadStock(items: [YXMarketRankCodeListInfo]) {
        let level = YXUserManager.shared().getLevel(with: market)
        var requestList: [[String: Any]] = []
        for item in items {
            if let code = item.secuCode {
                
                let requestItem: [String: Any] = ["from": 0,
                                                  "count": 1,
                                                  "code": String(format: "%@_%@", HOTETFSECONDCONS, code),
                                                  "market": market,
                                                  "level": level.rawValue,
                                                  "sorttype": 1,
                                                  "sortdirection": 1,
                                                  "pagedirection": 0]
                
                requestList.append(requestItem)
            }
        }
        
        _ = rankServices.request(.multiQuotesRank(codelist: requestList), response: { [weak self](response: YXResponseType<YXMarketRankModel>) in
            guard let `self` = self else { return }
            switch response {
            case .success(let result, let code):
                if code == .success, let list = result.data?.list {
                    for rankCodeModel in list {
                        for item in self.hotETF?.list ?? [] {
                            let code = String(format: "%@_%@", self.HOTETFSECONDCONS, item.secuCode ?? "")
                            if rankCodeModel.data?.rankCode == code {
                                if let key = item.secuCode, let value = rankCodeModel.data?.list?.first {
                                    self.etfLeadStock[key] = value
                                    break
                                }
                            }
                        }
                    }
                    
                    var etfIndex = -1
                    var starIndex = 0
                    for (index, dic) in self.dataSource.enumerated() {
                        let sectionType = dic["sectionType"] as! YXMarketSectionType
                        switch sectionType {
                        case .hotETF:
                            etfIndex = index
                        case .star:
                            starIndex = index
                        default:
                            break
                        }
                    }
                    
                    if self.hotETF?.list?.count ?? 0 > 0 { // 有则展示，无则隐藏
                        if etfIndex < 0 {
                            self.dataSource.insert(["sectionType": YXMarketSectionType.hotETF, "list": self.hotETF?.list ?? []], at: starIndex+1)
                        }
                    }else {
                        if etfIndex > 0 {
                            self.dataSource.remove(at: etfIndex)
                        }
                    }
                    
                    self.hotETFLeadStockSubject.onNext("")
                }
            case .failed(let err):
                log(.error, tag: kNetwork, content: "\(err)")
                
            }
        })
    }

    // 每日复盘
    var dailyReplayDataSingle: Single<[String]> {
        Single<[String]>.create(subscribe: { [weak self] (single) -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            
            return self.services.request(.dailyReplay(market: self.market), response: { (response: YXResponseType<JSONAny>) in
                
                switch response {
                case .success(let result, let code):
                    if code == .success, let dic = result.data?.value as? [String : Any] {
                        let contentText = dic["closeAbstract"]
                        if let text = contentText as? String {
                            self.dailyReplay = [text]
                            self.dataSource = self.creatDataSource()
                        }
                        single(.success(self.dailyReplay))
                    }else {
                        single(.success([]))
                    }
                case .failed(let error):
                    log(.error, tag: kNetwork, content: "\(error)")
                    single(.error(error))
                }
            })
            
        })
    }
    
    // 智能盯盘
    var stareDataSingle: Single<YXStareSignalModel?> {
        Single<YXStareSignalModel?>.create(subscribe: { [weak self] (single) -> Disposable in
            guard let strongSelf = self else { return Disposables.create() }
            let unixTime = Int64(Date().timeIntervalSince1970 * 1000.0)
            return strongSelf.rankServices.request(.signalList(type: 1, subType: 0, count: 1, seqNum: 0, unixTime: unixTime), response: { [weak self] (response: YXResponseType<JSONAny>) in
                //strongSelf.hudSubject.onNext(.hide)
                guard let `self` = self else { return single(.success(nil))}
                switch response {
                    case .success(let result, let code):
                        if code == .success, let data = result.data?.value as? [String : Any], let list = data["list"] as? [[String : Any]] {
                            if let model = NSArray.yy_modelArray(with: YXStareSignalModel.self, json: list)?.first as? YXStareSignalModel {
                                self.stareModel = model
                                self.dataSource = self.creatDataSource()
                                single(.success(model))
                            } else {
                                self.stareModel = nil
                                self.dataSource = self.creatDataSource()
                                single(.success(nil))
                            }
                        } else {
                            self.stareModel = nil
                            self.dataSource = self.creatDataSource()
                            single(.success(nil))
                    }
                    case .failed(let error):
                        self.stareModel = nil
                        self.dataSource = self.creatDataSource()
                        log(.error, tag: kNetwork, content: "\(error)")
                        single(.error(error))
                }
            })

        })
    }
    
    // 猜涨跌
    func guessUpAndDownSingle(isRefresh: Bool) -> Single<Any?> {
        Single<Any?>.create(subscribe: { [weak self] (single) -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            
            let requestModel = YXGuessUpAndDowReqModel()
            requestModel.market = "0"
            requestModel.extraStockCodes = [YXMarketIndex.HSI.rawValue]
            if isRefresh {
                self.guessUpDownIndex += 4
                if self.guessUpDownIndex >= (self.guessUpAndDownModel?.total ?? 0) {
                    self.guessUpDownIndex = 0
                }
            }
            requestModel.index = self.guessUpDownIndex
            
            let request = YXRequest.init(request: requestModel)
            
            request.startWithBlock(success: { (response) in
                
                if response.code == YXResponseStatusCode.success {
                    if let model = YXGuessUpAndDownResModel.yy_model(withJSON: response.data ?? [:]) {
                        var array: [Secu] = []
                        for item in model.stockInfos {
                            if let code = item.stockCode {
                                let secu = Secu.init(market: self.market, symbol: code)
                                array.append(secu)
                            }
                        }
                        
                        let level = YXUserManager.shared().getLevel(with: self.market)
                        self.guessQuoteRequest?.cancel()
                        self.guessQuoteRequest = YXQuoteManager.sharedInstance.subRtFullQuote(secus: array, level: level, handler: { (quotes, scheme) in
                            if scheme == .http {
                                for quote in quotes {
                                    for stock in model.stockInfos {
                                        if quote.symbol == stock.stockCode {
                                            stock.quote = quote
                                            break
                                        }
                                    }
                                }
                            }
                            self.guessQuoteRequest?.cancel()
                            self.guessUpAndDownModel = model
                            single(.success(nil))
                        }, failed: {
                            single(.success(nil))
                        })
                    }else {
                        single(.success(nil))
                    }
                    
                }else {
                    single(.success(nil))
                }
                
            }, failure: { (request) in
                single(.error(request.error ?? NSError.init(domain: "", code: -1, userInfo: nil)))
            })
            
            return Disposables.create()
            
        })
    }
    
    // 猜涨跌用户选择
    func guessUserSelectedSingle(code: String, value: String) -> Single<Any?> {
        Single<Any?>.create(subscribe: { (single) -> Disposable in
//            guard let `self` = self else { return Disposables.create() }
            
            let requestModel = YXGuessUpAndDownUserGuessReqModel()
            requestModel.market = "0"
            requestModel.guessChange = value
            requestModel.code = code
            
            let request = YXRequest.init(request: requestModel)
            
            request.startWithBlock(success: { (response) in
                
                single(.success(nil))
                
            }, failure: { (request) in
                single(.error(request.error ?? NSError.init(domain: "", code: -1, userInfo: nil)))
            })
            
            return Disposables.create()
        })
    }
    
    func marketItems() -> [[String: Any]] {
        let level = YXUserManager.shared().getLevel(with: market)
        
        let industryItem: [String : Any] = ["from": 0,
                                            "count": 6,
                                            "code": industryRankCode,
                                            "market": market,
                                            "level": level.rawValue,
                                            "sorttype": 1,
                                            "sortdirection": 1,
                                            "pagedirection": 0]
        
        let usItem: [String : Any] = ["from": 0,
                                      "count": 5,
                                      "code": usRankCode,
                                      "market": market,
                                      "level": level.rawValue,
                                      "sorttype": self.usRankSortType.rawValue,
                                      "sortdirection": self.usRankSortDirection,
                                      "pagedirection": 0]
        
        let starItem: [String : Any] = ["from": 0,
                                        "count": 5,
                                        "code": starRankCode,
                                        "market": market,
                                        "level": level.rawValue,
                                        "sorttype": 1,
                                        "sortdirection": 1,
                                        "pagedirection": 0]
        
        let conceptItem: [String : Any] = ["from": 0,
                                        "count": 5,
                                        "code": conceptRankCode,
                                        "market": market,
                                        "level": level.rawValue,
                                        "sorttype": 1,
                                        "sortdirection": 1,
                                        "pagedirection": 0]
        
        let hotETF: [String : Any] = ["from": 0,
                                      "count": 5,
                                      "code": HOTETFSECONDEBK001,
                                      "market": market,
                                      "level": level.rawValue,
                                      "sorttype": 1,
                                      "sortdirection": 1,
                                      "pagedirection": 0]
        
//        let monthlyStockItem: [String : Any] = ["from": 0,
//                                       "count": 5,
//                                       "code": monthlyStockRankCode,
//                                       "market": market,
//                                       "level": level.rawValue,
//                                       "sorttype": 75,
//                                       "sortdirection": 1,
//                                       "pagedirection": 0]
//
//        let dailyFundingItem: [String : Any] = ["from": 0,
//                                           "count": 5,
//                                           "code": dailyFundingRankCode,
//                                           "market": market,
//                                           "level": level.rawValue,
//                                           "sorttype": 1,
//                                           "sortdirection": 1,
//                                           "pagedirection": 0]
        
        
//        return [industryItem, usItem, starItem, conceptItem, hotETF, dailyFundingItem, monthlyStockItem]
        return [industryItem, usItem, conceptItem, starItem]
    }
    
    func creatDataSource() -> [[String: Any]] {
        
        let entrances = [["title": YXLanguageUtility.kLang(key: "options"), "iconName": "entrance_shareOptions"],
                         ["title": YXLanguageUtility.kLang(key: "premarket_after_ranking"), "iconName": "entrance_preafter"],
                         ["title": YXMarketSectionType.hotETF.sectionName, "iconName": "hk_etf"],
                         ["title": YXLanguageUtility.kLang(key: "market_entrance_dividens"), "iconName": "market_dividens"],
                         /*["title": YXLanguageUtility.kLang(key: "margin_trade"), "iconName": "financing_entrance"],
                         ["title": YXLanguageUtility.kLang(key: "interval_title"), "iconName": "range_roc_entrance"],
                         ["title": YXLanguageUtility.kLang(key: "stock_scanner"), "iconName": "stock_filter_entrance"]*/]
        
        var dataSource: [[String: Any]] = [["sectionType": YXMarketSectionType.index, "list":[""]],
                                           ["sectionType": YXMarketSectionType.industry, "list": industryRank?.list ?? []],
                                           ["sectionType": YXMarketSectionType.entrance, "list":entrances],
                                           ["sectionType": YXMarketSectionType.upsaAndDowns, "list": usRank?.list ?? []],
                                           ["sectionType": YXMarketSectionType.chinaConceptStock, "list": conceptRank?.list ?? []],
                                           ["sectionType": YXMarketSectionType.star, "list": starRank?.list ?? []],
                                           /*["sectionType": YXMarketSectionType.stare, "list": self.stareModel == nil ? [] : [""]],
                                           ["sectionType": YXMarketSectionType.dailyReplay, "list": dailyReplay],
                                           ["sectionType": YXMarketSectionType.monthlyPayment, "list": monthlyStockRank?.list ?? []],
                                           ["sectionType": YXMarketSectionType.star, "list": starRank?.list ?? []],
                                           ["sectionType": YXMarketSectionType.dailyFunding, "list": dailyFundingRank?.list ?? []]*/]
        
        if YXUserManager.shared().getUsaThreeLevel() != .level1 {
            dataSource.insert( ["sectionType": YXMarketSectionType.usETF, "list":[""]], at: 1)
        }
//        var finalDataSource: [[String: Any]] = []
//
//        for item in dataSource {
//            if let type = item["sectionType"] as? YXMarketSectionType, let list = item["list"] as? Array<Any> {
//                if type == .hotETF && list.count == 0 {
//                    continue
//                }
//            }
//
//            finalDataSource.append(item)
//        }
        
        return dataSource
        
    }
    
    func allStocks() -> [YXMarketRankCodeListInfo] {
        if let starRankList = self.starRank?.list, let conceptRankList = self.conceptRank?.list, let dailyFundingRankList = self.dailyFundingRank?.list {
            return starRankList + conceptRankList + dailyFundingRankList
        }
        return []
    }
    
    init() {
        dataSource = creatDataSource()
        let DIA = YXV2Quote()
        DIA.symbol = YXMarketIndex.DIA.rawValue
        let QQQ = YXV2Quote()
        QQQ.symbol = YXMarketIndex.QQQ.rawValue
        let SPY = YXV2Quote()
        SPY.symbol = YXMarketIndex.SPY.rawValue
        indexDataSource = [DIA, QQQ, SPY]
    }
}
