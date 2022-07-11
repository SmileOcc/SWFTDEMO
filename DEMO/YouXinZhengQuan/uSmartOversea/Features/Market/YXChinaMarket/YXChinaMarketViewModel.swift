//
//  YXChinaMarketViewModel.swift
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

class YXChinaMarketViewModel: ServicesViewModel, HasDisposeBag {
    typealias Services = YXMarketService
    
    var navigator: NavigatorServicesType!
    
    var services: YXMarketService! = YXMarketService()
    
    var rankServices = YXNewStockService()
    
    let market = YXMarketType.ChinaHS.rawValue

    var stareModel: YXStareSignalModel?
    
    // collectionView数据源
    var dataSource: [[String: Any]]! = [[String: Any]]()
    // 股票分时数据池子
    var timeLinePool: [String: YXBatchTimeLine]! = [String: YXBatchTimeLine]()
    // 总览
    var allHSRank: YXMarketRankCodeList?
    // 热门行业
    var industryRank: YXMarketRankCodeList?
    // 沪深股通
    var AstockRank: YXMarketRankCodeList?
    // 概念板块
    var conceptRank: YXMarketRankCodeList?
    // 沪股通、深股通额度
    var AStockFund: YXMarketHSSCMResponseModel?
    
    let industryRankCode = YXMarketSectionType.industry.rankCode
    let AstockRankCode = YXMarketSectionType.AStock.rankCode
    let conceptRankCode = YXMarketSectionType.concept.rankCode
    let allHSRankCode = YXMarketSectionType.marketOverview.rankCode
    
    var hsRankSortDirection: Int = 1
    var hsRankSortType: YXStockRankSortType = .roc
    
    var timeLineRequest: YXQuoteRequest?
    var indexTimeLineRequest: YXQuoteRequest?
    var indexRequest: YXQuoteRequest?
    // 排行榜股票分时信号
    let timeLineSubject = PublishSubject<[String: YXBatchTimeLine]>()
    // 指数分时信号
    let indexTimeLineSubject = ReplaySubject<YXTimeLineData?>.create(bufferSize: 1)
    // 指数行情信号
    let indexSubject = BehaviorSubject<[YXV2Quote]>(value: [YXV2Quote(), YXV2Quote(), YXV2Quote()])
    // 指数行情数据源
    var indexDataSource = [YXV2Quote(), YXV2Quote(), YXV2Quote()]
    
    var selectedIndex = 0
    
    lazy var chinaIndexs: [Secu] = {
        // 上证指数
        let HSSSE = Secu.init(market: YXMarketType.ChinaSH.rawValue, symbol: YXMarketIndex.HSSSE.rawValue)
        // 深证指数
        let HSSZSE = Secu.init(market: YXMarketType.ChinaSZ.rawValue, symbol: YXMarketIndex.HSSZSE.rawValue)
        // 创业板指
        let HSGEM = Secu.init(market: YXMarketType.ChinaSZ.rawValue, symbol: YXMarketIndex.HSGEM.rawValue)
        
        return [HSSSE, HSSZSE, HSGEM]
    }()
    
    func requestIndexData() {
        let level = YXUserManager.shared().getLevel(with: market)
        indexRequest?.cancel()
        indexRequest = YXQuoteManager.sharedInstance.subRtSimpleQuote(secus: chinaIndexs, level: level, handler: { [weak self](list, scheme) in
            guard let `self` = self else { return }
            var indexDataSource = self.indexDataSource
            if scheme == .http {
                for item in list {
                    if item.market == YXMarketType.ChinaSH.rawValue, item.symbol == YXMarketIndex.HSSSE.rawValue {
                        indexDataSource[0] = item
                    }else if item.market == YXMarketType.ChinaSZ.rawValue, item.symbol == YXMarketIndex.HSSZSE.rawValue {
                        indexDataSource[1] = item
                    }else if item.market == YXMarketType.ChinaSZ.rawValue, item.symbol == YXMarketIndex.HSGEM.rawValue {
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
        
        requestIndexTimeLineData(index: selectedIndex)
    }
    
    func requestIndexTimeLineData(index: Int) {
        selectedIndex = index
        let secu = chinaIndexs[index]
        let level = YXUserManager.shared().getLevel(with: market)
        self.indexTimeLineRequest?.cancel()
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
                                if item.data?.rankCode == strongSelf.AstockRankCode {
                                    strongSelf.AstockRank = item.data
                                    strongSelf.AstockRank?.level = item.level
                                }else if item.data?.rankCode == strongSelf.conceptRankCode {
                                    strongSelf.conceptRank = item.data
                                }else if item.data?.rankCode == strongSelf.industryRankCode {
                                    strongSelf.industryRank = item.data
                                }else if item.data?.rankCode == strongSelf.allHSRankCode {
                                    strongSelf.allHSRank = item.data
                                }
                            }
                        }
                        
                        // 请求得到股票数据后，再去请求股票的分时行情数据
                        var secus = [Secu]()
                        
                        for item in strongSelf.allStocks() {
                            if let market = item.trdMarket, let secuCode = item.secuCode {
                                let secu = Secu.init(market: market, symbol: secuCode)
                                secus.append(secu)
                            }
                        }
                        
                        let level = YXUserManager.shared().getLevel(with: self?.market ?? "")
                        strongSelf.timeLineRequest?.cancel()
                        strongSelf.timeLineRequest = YXQuoteManager.sharedInstance.subBatchTimeLine(secus: secus, level: level, handler: { (timeLineList) in
                            strongSelf.timeLineRequest?.cancel()
                            for item in strongSelf.allStocks() {
                                for timeLineModel in timeLineList {
                                    if item.trdMarket == timeLineModel.market, item.secuCode == timeLineModel.symbol,
                                        let market = item.trdMarket, let secuCode = item.secuCode {
                                        strongSelf.timeLinePool[market + secuCode] = timeLineModel
                                        
                                    }
                                }
                            }
                            
                        })
                        
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
    
    var fundDataSingle: Single<[[String: Any]]> {
        Single<[[String: Any]]>.create(subscribe: { [weak self] (single) -> Disposable in
            guard let strongSelf = self else { return Disposables.create() }
            
            return strongSelf.services.request(.hsFund, response: { (response: YXResponseType<YXMarketHSSCMResponseModel>) in
                //                strongSelf.hudSubject.onNext(.hide)
                switch response {
                case .success(let result, let code):
                    if code == .success {
                        // 调整顺序
                        strongSelf.AStockFund = result.data
                        strongSelf.dataSource = strongSelf.creatDataSource()
                        single(.success(strongSelf.dataSource ?? []))
                    } else {
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
            return strongSelf.rankServices.request(.signalList(type: 2, subType: 0, count: 1, seqNum: 0, unixTime: unixTime), response: { [weak self] (response: YXResponseType<JSONAny>) in
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
    
    func marketItems() -> [[String: Any]] {
        let level = YXUserManager.shared().getLevel(with: market)
        
        let allHSItem: [String : Any] = ["from": 0,
                                            "count": 5,
                                            "code": allHSRankCode,
                                            "market": market,
                                            "level": level.rawValue,
                                            "sorttype": self.hsRankSortType.rawValue,
                                            "sortdirection": self.hsRankSortDirection,
                                            "pagedirection": 0]
        
        let industryItem: [String : Any] = ["from": 0,
                                            "count": 6,
                                            "code": industryRankCode,
                                            "market": market,
                                            "level": level.rawValue,
                                            "sorttype": 1,
                                            "sortdirection": 1,
                                            "pagedirection": 0]
        
        let AstockItem: [String : Any] = ["from": 0,
                                      "count": 5,
                                      "code": AstockRankCode,
                                      "market": market,
                                      "level": level.rawValue,
                                      "sorttype": 1,
                                      "sortdirection": 1,
                                      "pagedirection": 0]
        
        let conceptItem: [String : Any] = ["from": 0,
                                        "count": 6,
                                        "code": conceptRankCode,
                                        "market": market,
                                        "level": level.rawValue,
                                        "sorttype": 1,
                                        "sortdirection": 1,
                                        "pagedirection": 0]
        
        
        return [allHSItem, industryItem, AstockItem, conceptItem]
    }
    
    func creatDataSource() -> [[String: Any]] {
        // 放三个占位
        let first = YXMarketHSSCMItem()
        first.code = "HKSCSH"
        let second = YXMarketHSSCMItem()
        second.code = "HKSCSZ"
        var AStockFundList: [Any] = [first, second, AStockFund ?? YXMarketHSSCMResponseModel()]
        // 请求到数据再替换
        if let list = AStockFund?.list {
            for item in list {
                if item.code == "HKSCSH" {
                    AStockFundList[0] = item
                }else if item.code == "HKSCSZ" {
                    AStockFundList[1] = item
                }
            }
        }
        
        let entrances = [
                         ["title": YXLanguageUtility.kLang(key: "interval_title"), "iconName": "range_roc_entrance"],
                         ["title": YXLanguageUtility.kLang(key: "stock_scanner"), "iconName": "stock_filter_entrance"]
                        ]
        
        let dataSource = [["sectionType": YXMarketSectionType.index, "list": [""]],
                          ["sectionType": YXMarketSectionType.entrance, "list": entrances],
                          ["sectionType": YXMarketSectionType.marketOverview, "list": [""]],
                          ["sectionType": YXMarketSectionType.stare, "list": self.stareModel == nil ? [] : [""]],
                          ["sectionType": YXMarketSectionType.AStockFund, "list": AStockFundList],
                          ["sectionType": YXMarketSectionType.AStock, "list": AstockRank?.list ?? []],
                          ["sectionType": YXMarketSectionType.concept, "list": conceptRank?.list ?? []],
                          ["sectionType": YXMarketSectionType.industry, "list": industryRank?.list ?? []],
                          ["sectionType": YXMarketSectionType.allHSStock, "list": allHSRank?.list ?? []]]
        
        return dataSource
    }
    
    func allStocks() -> [YXMarketRankCodeListInfo] {
        if let rankList = self.AstockRank?.list {
            return rankList
        }
        return []
    }
    
    init() {
        dataSource = creatDataSource()
        let HSSSE = YXV2Quote()
        HSSSE.symbol = YXMarketIndex.HSSSE.rawValue
        let HSSZSE = YXV2Quote()
        HSSZSE.symbol = YXMarketIndex.HSSZSE.rawValue
        let HSGEM = YXV2Quote()
        HSGEM.symbol = YXMarketIndex.HSGEM.rawValue
        indexDataSource = [HSSSE, HSSZSE, HSGEM]
    }
    
}
