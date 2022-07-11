//
//  YXSGMarketViewModel.swift
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

class YXSGMarketViewModel: ServicesViewModel {
    
    typealias Services = YXMarketService
    
    var disposeBag = DisposeBag()
    
    var services: YXMarketService! = YXMarketService()
    
    var rankServices = YXNewStockService()
    
    var navigator: NavigatorServicesType!
    
    var market = YXMarketType.SG.rawValue

    var stareModel: YXStareSignalModel?
    // collectionView数据源
    var dataSource: [[String: Any]]! = [[String: Any]]()
    // 股票分时数据池子
    var timeLinePool: [String: YXBatchTimeLine]! = [String: YXBatchTimeLine]()
    // 热门行业
    var industryRank: YXMarketRankCodeList?
    // 全部港股
    var sgRank: YXMarketRankCodeList?
    // 主板
    var mainRank: YXMarketRankCodeList?
    // 创业板
    var cataRank: YXMarketRankCodeList?
    // 月供股
    var monthlyStockRank: YXMarketRankCodeList?
    // 日内融
    var dailyFundingRank: YXMarketRankCodeList?
    // 新股数量
    var ipoToday: YXMarketIPOTodayCountModel?
    // 每日复盘
    var dailyReplay: [String] = []
    // ipo认购中
    var ipoModel: YXNewStockCenterPreMarketModel2?
    // 猜涨跌
    var guessUpAndDownModel: YXGuessUpAndDownResModel?
    var guessUpDownIndex = 0
    var guessQuoteRequest: YXQuoteRequest?
    
    var level: Int?
    
    let industryRankCode = YXMarketSectionType.industry.rankCode
    let sgRankCode = YXMarketSectionType.allSGStock.rankCode
    var sgRankSortType: YXStockRankSortType = .roc
    var sgRankSortDirection: Int = 1
    let mainRankCode = YXMarketSectionType.mainboard.rankCode
    let cataRankCode = YXMarketSectionType.cata.rankCode
    let monthlyStockRankCode = YXMarketSectionType.monthlyPayment.rankCode
    let dailyFundingRankCode = YXMarketSectionType.dailyFunding.rankCode
    
    var timeLineRequest: YXQuoteRequest?
    var indexTimeLineRequest: YXQuoteRequest?
    var indexRequest: YXQuoteRequest?
    // 排行榜股票分时信号
    let timeLineSubject = PublishSubject<[String: YXBatchTimeLine]>()
    // ipo运营广告
    var ipoAdList: [YXMarketIPOAdItem]?
    
    var selectedIndex = 0
    

    // 全部港股、主板、创业板
    var marketDataSourceSingle: Single<[[String: Any]]> {
        Single<[[String: Any]]>.create(subscribe: { [weak self] (single) -> Disposable in
            guard let strongSelf = self else { return Disposables.create() }
            
            return strongSelf.rankServices.request(.multiQuotesRank(codelist: strongSelf.marketItems()), response: { (response: YXResponseType<YXMarketRankModel>) in
                switch response {
                case .success(let result, let code):
                    if code == .success, let list = result.data?.list {
                        
                        for item in list {
                            
                            if item.data?.rankMarket == strongSelf.market {
                                if item.data?.rankCode == strongSelf.sgRankCode {
                                    strongSelf.sgRank = item.data
                                    strongSelf.sgRank?.level = item.level
                                }else if item.data?.rankCode == strongSelf.mainRankCode {
                                    strongSelf.mainRank = item.data
                                    strongSelf.mainRank?.level = item.level
                                }else if item.data?.rankCode == strongSelf.cataRankCode {
                                    strongSelf.cataRank = item.data
                                    strongSelf.cataRank?.level = item.level
                                }else if item.data?.rankCode == strongSelf.dailyFundingRankCode {
                                    strongSelf.dailyFundingRank = item.data
                                    strongSelf.dailyFundingRank?.level = item.level
                                }else if item.data?.rankCode == strongSelf.monthlyStockRankCode {
                                    strongSelf.monthlyStockRank = item.data
                                    strongSelf.monthlyStockRank?.level = item.level
                                }else if item.data?.rankCode == strongSelf.industryRankCode {
                                    strongSelf.industryRank = item.data
                                }
                            }
                        }
                        
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
    
    // 热门行业
    var industryDataSourceSingle: Single<[[String: Any]]> {

        Single<[[String: Any]]>.create(subscribe: { [weak self] (single) -> Disposable in
            guard let strongSelf = self else { return Disposables.create() }
            
            return strongSelf.rankServices.request(.multiQuotesRank(codelist: strongSelf.industryItems()), response: { (response: YXResponseType<YXMarketRankModel>) in
                //strongSelf.hudSubject.onNext(.hide)
                switch response {
                case .success(let result, let code):
                    if code == .success, let list = result.data?.list {
                        
                        for item in list {
                            
                            if item.data?.rankMarket == strongSelf.market {
                                if item.data?.rankCode == strongSelf.industryRankCode {
                                    strongSelf.industryRank = item.data
                                }
                            }
                        }
                        strongSelf.dataSource = strongSelf.creatDataSource()
                        single(.success(strongSelf.creatDataSource()))
                    }
                case .failed(let error):
                    log(.error, tag: kNetwork, content: "\(error)")
                    single(.error(error))
                }
            })
            
        })
    }
    
    // ipo数据
    var ipoDataSourceSingle: Single<YXMarketIPOTodayCountModel?> {
        Single<YXMarketIPOTodayCountModel?>.create(subscribe: { [weak self] (single) -> Disposable in
            guard let strongSelf = self else { return Disposables.create() }
            
            return strongSelf.services.request(.ipoCount, response: { (response: YXResponseType<YXMarketIPOTodayCountModel>) in
                //strongSelf.hudSubject.onNext(.hide)
                switch response {
                case .success(let result, let code):
                    if code == .success, let ipoToday = result.data {
                        strongSelf.ipoToday = ipoToday
                        strongSelf.dataSource = strongSelf.creatDataSource()
                        single(.success(ipoToday))
                    }
                case .failed(let error):
                    log(.error, tag: kNetwork, content: "\(error)")
                    single(.error(error))
                }
            })
            
        })
    }
    
    // ipo广告
    var ipoADDataSingle: Single<[YXMarketIPOAdItem]?> {
        Single<[YXMarketIPOAdItem]?>.create(subscribe: { [weak self] (single) -> Disposable in
            guard let strongSelf = self else { return Disposables.create() }
            
            return strongSelf.services.request(.ipoAD, response: { (response: YXResponseType<YXMarketIPOAdModel>) in
                //strongSelf.hudSubject.onNext(.hide)
                switch response {
                case .success(let result, let code):
                    if code == .success, let list = result.data?.recommendList {
//                        guard let `self` = self else {
//                            return
//                        }
                        // 限制最多两条
                        let count = min(2, list.count)
                        var arr = [YXMarketIPOAdItem]()
                        for index in 0..<count {
                            arr.append(list[index])
                        }
                        single(.success(arr))
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
            return strongSelf.rankServices.request(.signalList(type: 0, subType: 0, count: 1, seqNum: 0, unixTime: unixTime), response: { [weak self] (response: YXResponseType<JSONAny>) in
                //strongSelf.hudSubject.onNext(.hide)
                guard let `self` = self else { return single(.success(nil)) }
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
    
    // 合并ipo广告请求和ipo认购中请求，如果广告没有配，则取认购中的股票来显示
    var ipoZipDataSingle: Single<[YXMarketIPOAdItem]?> {
        return Single<[YXMarketIPOAdItem]?>.create(subscribe: { [weak self] (single) -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            Observable.zip(self.ipoDataSingle.asObservable(), self.ipoADDataSingle.asObservable()).subscribe(onNext: { [weak self](ipoPurchasingArr, ipoAdArr) in
                if ipoAdArr?.count == 0 {
                    self?.ipoAdList = ipoPurchasingArr
                }else {
                    self?.ipoAdList = ipoAdArr
                }
                single(.success(self?.ipoAdList))
            }, onError: {error in
                single(.success(nil))
            }, onCompleted: {
                single(.success(nil))
            }).disposed(by: self.disposeBag)
            return Disposables.create()
        })
        
    }
    
    // IPO认购中股票
    var ipoDataSingle: Single<[YXMarketIPOAdItem]?> {
        Single<[YXMarketIPOAdItem]?>.create(subscribe: { (single) -> Disposable in
//            guard let `self` = self else { return Disposables.create() }
            
            let requestModel = YXNewStockPreMarketRequestModel()
            requestModel.status = 0
            requestModel.orderBy = "latest_endtime"
            requestModel.orderDirection = 1
            requestModel.pageNum = 1
            requestModel.pageSize = 2
            requestModel.pageSizeZero = false
            requestModel.exchangeType = 0
            
            let request = YXRequest.init(request: requestModel)
            
            request.startWithBlock(success: { (response) in
                
                if response.code == YXResponseStatusCode.success {
                    let ipoModel = YXNewStockCenterPreMarketModel2.yy_model(withJSON: response.data ?? [:])
                    var array = [YXMarketIPOAdItem]()
                    if let list = ipoModel?.list, list.count > 0 {
                        let count = min(2, list.count)
                        for index in 0..<count {
                            let stock = list[index]
                            let market = stock.exchangeType == 0 ? "hk" : "us"
                            let name = "\(stock.stockName)"
                            let adModel = YXMarketIPOAdItem.init(stockCode: "\(market)\(stock.stockCode)", companyName: name, pictureUrl: nil, secuCode: stock.stockCode, exchangeId: stock.exchangeType)
                            array.append(adModel)
                        }
                    }
                    single(.success(array))
                }else {
                    single(.success(nil))
                }

            }, failure: { (request) in
                single(.error(request.error ?? NSError.init(domain: "", code: -1, userInfo: nil)))
            })
            
            return Disposables.create()
            
        })
    }
    
    // 猜涨跌
    func guessUpAndDownSingle(isRefresh: Bool) -> Single<Any?> {
        Single<Any?>.create(subscribe: { [weak self] (single) -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            
            let requestModel = YXGuessUpAndDowReqModel()
            requestModel.market = "5"
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
            requestModel.market = "5"
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
        
        let sgItem: [String : Any] = ["from": 0,
                                      "count": 5,
                                      "code": sgRankCode,
                                      "market": market,
                                      "level": level.rawValue,
                                      "sorttype": self.sgRankSortType.rawValue,
                                      "sortdirection": self.sgRankSortDirection,
                                      "pagedirection": 0]
        
        let mainItem: [String : Any] = ["from": 0,
                                        "count": 5,
                                        "code": mainRankCode,
                                        "market": market,
                                        "level": level.rawValue,
                                        "sorttype": 1,
                                        "sortdirection": 1,
                                        "pagedirection": 0]
        
        let cataItem: [String : Any] = ["from": 0,
                                        "count": 5,
                                        "code": cataRankCode,
                                        "market": market,
                                        "level": level.rawValue,
                                        "sorttype": 1,
                                        "sortdirection": 1,
                                        "pagedirection": 0]
        
        
        let industryItem: [String : Any] = ["from": 0,
                                            "count": 6,
                                            "code": industryRankCode,
                                            "market": market,
                                            "level": level.rawValue,
                                            "sorttype": 1,
                                            "sortdirection": 1,
                                            "pagedirection": 0]
        
        return [sgItem, mainItem, cataItem, industryItem]
    }
    
    func industryItems() -> [[String: Any]] {
        let level = YXUserManager.shared().getLevel(with: market)
        
        let industryItem: [String : Any] = ["from": 0,
                                            "count": 6,
                                            "code": industryRankCode,
                                            "market": market,
                                            "level": level.rawValue,
                                            "sorttype": 1,
                                            "sortdirection": 1,
                                            "pagedirection": 0]
        
        return [industryItem]
    }
    
    func creatDataSource() -> [[String: Any]] {
        let entrances = [
                        ["title": YXLanguageUtility.kLang(key: "markets_news_reits"), "iconName": "market_reits_blue"],
                        ["title": YXLanguageUtility.kLang(key: "market_sg_etf"), "iconName": "hk_etf"],
                        ["title": YXLanguageUtility.kLang(key: "market_sg_warrants"), "iconName": "market_warrants_blue"],
                        ["title": YXLanguageUtility.kLang(key: "market_sg_dlcs"), "iconName": "sg_dlcs"],
                        ["title": YXLanguageUtility.kLang(key: "market_entrance_dividens"), "iconName": "market_dividens"],
                        ]

        
        let dataSource = [["sectionType": YXMarketSectionType.industry, "list": industryRank?.list ?? []],
                          ["sectionType": YXMarketSectionType.entrance, "list":entrances],
                          ["sectionType": YXMarketSectionType.allSGStock, "list": sgRank?.list ?? []],
                          ["sectionType": YXMarketSectionType.mainboard, "list": mainRank?.list ?? []],
                          ["sectionType": YXMarketSectionType.cata, "list": cataRank?.list ?? []]]
        
        return dataSource
    }
    
    func allStocks() -> [YXMarketRankCodeListInfo] {
        if let mainRankList = self.mainRank?.list, let cataRankList = self.cataRank?.list, let dailyFundingRankList = self.dailyFundingRank?.list {
            return mainRankList + cataRankList + dailyFundingRankList
        }
        return []
    }
    
    init() {
        dataSource = creatDataSource()
      
    }
}
