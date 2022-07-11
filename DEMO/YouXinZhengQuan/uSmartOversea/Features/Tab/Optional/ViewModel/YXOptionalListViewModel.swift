//
//  YXOptionalListViewModel.swift
//  uSmartOversea
//
//  Created by ellison on 2019/4/26.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Differentiator
import NSObject_Rx
import YXKit
import URLNavigator

extension YXV2Quote
: IdentifiableType {
    public typealias Identity = String
    
    public var identity: String {
        (market ?? "") + (symbol ?? "") + "\(latestTime?.value ?? 0)"
    }
}


class YXOptionalListViewModel: NSObject, RefreshViewModel, HasDisposeBag {
        
    typealias IdentifiableModel = YXV2Quote
    typealias Services = HasYXV2QuoteService
    
    var navigator: NavigatorServicesType!
    
    var endHeaderRefreshStatus: Driver<EndRefreshStatus>?
    var endFooterRefreshStatus: Driver<EndRefreshStatus>?
    
    var page: Int = 1
    var offset: Int = 0 
    var perPage: Int = 30
    var total: Int?
    
    let dataSource: BehaviorRelay<[IdentifiableModel]> = BehaviorRelay<[IdentifiableModel]>(value:[])
    let timeLineDataSource: BehaviorRelay<[String: YXTimeLineModel]> = BehaviorRelay<[String: YXTimeLineModel]>(value:[: ])
    
    var dataSourceSingle: Single<[IdentifiableModel]> {
        Single<[IdentifiableModel]>.create(subscribe: { [weak self] (single) -> Disposable in
            guard let strongSelf = self else { return Disposables.create() }
            guard let secuGroup = strongSelf.secuGroup.value else { return Disposables.create() }
            
            strongSelf.services.v2QuoteService.unSubOptional(with: strongSelf.quoteRequests)
            
            let secus = secuGroup.list.map({ (secuId) -> Secu in
                Secu(market: secuId.market, symbol: secuId.symbol)
            })
            let hkSecus = YXSecuGroupManager.shareInstance().hkSecuGroup.list.map { (secuId) -> Secu in
                Secu(market: secuId.market, symbol: secuId.symbol)
            }
            strongSelf.quoteRequests = strongSelf.services.v2QuoteService.subOptional(with: secus, quoteSubject: strongSelf.quoteSubject, timeLineSubject: strongSelf.timeLineSubject, allHKSecus: hkSecus)
            
            let optionalSecus = strongSelf.dataSource.value.map { (quote) -> YXOptionalSecu in
                let secu = YXOptionalSecu()
                secu.name = quote.name ?? ""
                secu.market = quote.market ?? ""
                secu.symbol = quote.symbol ?? ""
                if let type1 = quote.type1?.value {
                    secu.type1 = type1
                }
                if let type2 = quote.type2?.value {
                    secu.type2 = type2
                }
                if let type3 = quote.type3?.value {
                    secu.type3 = type3
                }
                return secu
            }
            
            YXOptionalDBManager.shareInstance().insertOrReplaceDatas(optionalSecus)
            
            single(.success(strongSelf.dataSource.value))
            return Disposables.create()
        })
    }
    
    let quoteSubject = PublishSubject<([IdentifiableModel],Scheme)>()
    let timeLineSubject = PublishSubject<[YXBatchTimeLine]>()
    
    
    var quoteRequests: [YXQuoteRequest]?
    var pollTimeLineRequests: [YXQuoteRequest]?

    var quoteType = BehaviorRelay<YXStockRankSortType>(value: .now)
    var sortState = BehaviorRelay<YXSortState>(value: .normal)
    
    var originList: [IdentifiableModel] = [IdentifiableModel]()
    
    var secuGroup = BehaviorRelay<YXSecuGroup?>(value: nil)
    
    var services: Services! {
        didSet {
            secuGroup.asDriver().drive(onNext: { [weak self] (secuGroup) in
                guard let strongSelf = self else { return }
                
                let secuIdList = secuGroup?.list ?? []
                let dataSourceValue = strongSelf.dataSource.value
                let secus = YXOptionalDBManager.shareInstance().getDataWithSecus(secuIdList)
                let array = secuIdList.map({ (secuId) -> YXV2Quote in
                    for item in dataSourceValue {
                        if secuId.symbol == item.symbol && secuId.market == item.market {
                            return item
                        }
                    }
                    for obj in secus {
                        if obj.market == secuId.market && obj.symbol == secuId.symbol {
                            return YXV2Quote(market: secuId.market, name: obj.name, symbol: secuId.symbol)
                        }
                    }
                    
                    return YXV2Quote(market: secuId.market, symbol: secuId.symbol)
                })
                strongSelf.originList = array
                self?.dataSource.accept(strongSelf.reloadedList())
            }).disposed(by: disposeBag)
            
            timeLineDataSource.asDriver().drive(onNext: { [weak self] (_) in
                guard let strongSelf = self else { return }
                
                strongSelf.dataSource.accept(strongSelf.dataSource.value)
            }).disposed(by: disposeBag)
        }
    }
    
    func reloadedList() -> [IdentifiableModel] {
        let type = quoteType.value
        let state = sortState.value

        if state != .normal {
            let array = originList.sorted { (obj1, obj2) -> Bool in
                let obj1PriceBase = Double(obj1.priceBase?.value ?? 0)
                let obj2PriceBase = Double(obj2.priceBase?.value ?? 0)
                
                var value1: Double = 0
                var value2: Double = 0
                switch type {
                case .roc:
                    value1 = Double(obj1.pctchng?.value ?? 0)
                    value2 = Double(obj2.pctchng?.value ?? 0)
                case .change:
                    value1 = Double(obj1.netchng?.value ?? 0)/pow(10.0, obj1PriceBase)
                    value2 = Double(obj2.netchng?.value ?? 0)/pow(10.0, obj2PriceBase)
                case .now:
                    value1 = Double(obj1.latestPrice?.value ?? 0)/pow(10.0, obj1PriceBase)
                    value2 = Double(obj2.latestPrice?.value ?? 0)/pow(10.0, obj2PriceBase)
                default:
                    break
                }
                
                if obj1.market != obj2.market, YXSecuGroupManager.shareInstance().sortflag == 1 {
                    if (obj1.market != "sz" && obj1.market != "sh") || (obj2.market != "sz" && obj2.market != "sh") {
                       return false
                    }
                    
                }
                
                let obj1TradingStatus = obj1.trdStatus?.value ?? OBJECT_QUOTETradingStatus.tsNormal.rawValue
                let obj2TradingStatus = obj2.trdStatus?.value ?? OBJECT_QUOTETradingStatus.tsNormal.rawValue
                
                if state == .ascending {
                    if obj1TradingStatus == OBJECT_QUOTETradingStatus.tsSuspended.rawValue
                        || obj1TradingStatus == OBJECT_QUOTETradingStatus.tsDelisting.rawValue
                        || obj1TradingStatus == OBJECT_QUOTETradingStatus.tsUnlisted.rawValue
                        || obj1TradingStatus == OBJECT_QUOTETradingStatus.tsZanting.rawValue {
                        return false
                    } else if obj2TradingStatus == OBJECT_QUOTETradingStatus.tsSuspended.rawValue
                        || obj2TradingStatus == OBJECT_QUOTETradingStatus.tsDelisting.rawValue
                        || obj2TradingStatus == OBJECT_QUOTETradingStatus.tsUnlisted.rawValue
                        || obj2TradingStatus == OBJECT_QUOTETradingStatus.tsZanting.rawValue {
                        return true
                    }
                    
                    return value1 < value2
                } else {
                    if obj1TradingStatus == OBJECT_QUOTETradingStatus.tsSuspended.rawValue
                        || obj1TradingStatus == OBJECT_QUOTETradingStatus.tsDelisting.rawValue
                        || obj1TradingStatus == OBJECT_QUOTETradingStatus.tsUnlisted.rawValue
                        || obj1TradingStatus == OBJECT_QUOTETradingStatus.tsZanting.rawValue {
                        return false
                    } else if obj2TradingStatus == OBJECT_QUOTETradingStatus.tsSuspended.rawValue
                        || obj2TradingStatus == OBJECT_QUOTETradingStatus.tsDelisting.rawValue
                        || obj2TradingStatus == OBJECT_QUOTETradingStatus.tsUnlisted.rawValue
                        || obj2TradingStatus == OBJECT_QUOTETradingStatus.tsZanting.rawValue {
                        return true
                    }
                    
                    return value1 > value2
                }
            }
            return array
        } else {
            return originList
        }
    }
    
    func updateOriginList(list: [YXV2Quote]) {
        let array = originList.map({ (quote) -> YXV2Quote in
            for item in list {
                if quote.symbol == item.symbol && quote.market == item.market {
                    return item
                }
            }
            
            return quote
        })
        originList = array
    }
}


extension YXOptionalListViewModel {
    
    var rx_quoteType: ControlProperty<YXStockRankSortType> {
        let source: Observable<YXStockRankSortType> = quoteType.asObservable()
        let setter: (YXOptionalListViewModel, YXStockRankSortType) -> Void = {
            if ($0.quoteType.value != $1) {
                $0.quoteType.accept($1)
            }
        }
        let binder = Binder(self, binding: setter)
        return ControlProperty<YXStockRankSortType>(values: source, valueSink: binder)
    }
}

extension YXOptionalListViewModel {
    
    func pollingTimeLineData()  {
        
        guard let secuGroup = self.secuGroup.value else { return }
        
        self.services.v2QuoteService.unSubOptional(with: self.pollTimeLineRequests)

        let secus = secuGroup.list.map({ (secuId) -> Secu in
            Secu(market: secuId.market, symbol: secuId.symbol)
        })
        var requests = [YXQuoteRequest]()
        let levelSecus = LevelSecus(secus: secus)

        for i in 0..<6 {
            var array = [Secu]()
            var level = QuoteLevel.delay
            
            switch i {
            case 0:
                array = levelSecus.delay
                level = .delay
            case 1:
                array = levelSecus.bmp
                level = .bmp
            case 2:
                array = levelSecus.level1
                level = .level1
            case 3:
                array = levelSecus.level2
                level = .level2
            case 4:
                array = levelSecus.none
                level = .none
            case 5:
                array = levelSecus.usNation
                level = .usNational
            default:
                break
            }
            
            if array.count > 0 {
                let timeLineRequest = YXQuoteManager.sharedInstance.subBatchTimeLine(secus: array, level: level, handler: { (list) in
                    self.timeLineSubject.onNext(list)
                })
                requests.append(timeLineRequest)
            }
        }
        
        //期权当初请求
        var options = [Secu]() // 期权
        for secu in secus {
            if secu.market == "usoption" {
                options.append(secu)
            }
        }
        
        if options.count > 0, YXUserHelper.currentUSOptionLevel() == .usLevel1 {

            let timeLineRequest = YXQuoteManager.sharedInstance.subBatchTimeLine(secus: options, level: .level1, handler: { (list) in
                self.timeLineSubject.onNext(list)
            })
            requests.append(timeLineRequest)
        }
        
        
        self.pollTimeLineRequests = requests
    }

}
