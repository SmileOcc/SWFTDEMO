//
//  YXOptionalListLandViewModel.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2020/1/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//
import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Differentiator
import NSObject_Rx
import YXKit
import URLNavigator

class YXOptionalListLandViewModel: NSObject, RefreshViewModel, HasDisposeBag {
    typealias IdentifiableModel = YXV2Quote
    typealias Services = HasYXV2QuoteService
    
    var navigator: NavigatorServicesType!
    
    var endHeaderRefreshStatus: Driver<EndRefreshStatus>?
    var endFooterRefreshStatus: Driver<EndRefreshStatus>?
    
    var page: Int = 1
    var offset: Int = 0
    var perPage: Int = 30
    var total: Int?
    
    let contentOffsetRelay = BehaviorRelay<CGPoint>(value: CGPoint.zero)
    
    let dataSource: BehaviorRelay<[YXV2Quote]> = BehaviorRelay<[YXV2Quote]>(value:[])
    let timeLineDataSource: BehaviorRelay<[String: YXTimeLineModel]> = BehaviorRelay<[String: YXTimeLineModel]>(value:[: ])
    
    var dataSourceSingle: Single<[IdentifiableModel]> {
        Single<[IdentifiableModel]>.create(subscribe: { [weak self] (single) -> Disposable in
            guard let strongSelf = self else { return Disposables.create() }
            guard let secuGroup = strongSelf.secuGroup.value else { return Disposables.create() }
            
            strongSelf.services.v2QuoteService.unSubOptional(with: strongSelf.quoteRequests)
            
            let secus = secuGroup.list.map({ (secuId) -> Secu in
                Secu(market: secuId.market, symbol: secuId.symbol)
            })
            strongSelf.quoteRequests = strongSelf.services.v2QuoteService.subOptional(with: secus, quoteSubject: strongSelf.quoteSubject, timeLineSubject: strongSelf.timeLineSubject)
            
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
                case .turnoverRate:
                    value1 = Double(obj1.turnoverRate?.value ?? 0)
                    value2 = Double(obj2.turnoverRate?.value ?? 0)
                case .volume:
                    value1 = Double(obj1.volume?.value ?? 0)
                    value2 = Double(obj2.volume?.value ?? 0)
                case .amount:
                    value1 = Double(obj1.amount?.value ?? 0)/pow(10.0, obj1PriceBase)
                    value2 = Double(obj2.amount?.value ?? 0)/pow(10.0, obj1PriceBase)
                case .amp:
                    value1 = Double(obj1.amp?.value ?? 0)
                    value2 = Double(obj2.amp?.value ?? 0)
                case .volumeRatio:
                    value1 = Double(obj1.volumeRatio?.value ?? 0)
                    value2 = Double(obj2.volumeRatio?.value ?? 0)
                case .marketValue:
                    value1 = Double(obj1.mktCap?.value ?? 0)/pow(10.0, obj1PriceBase)
                    value2 = Double(obj2.mktCap?.value ?? 0)/pow(10.0, obj1PriceBase)
                case .pe:
                    value1 = Double(obj1.pe?.value ?? 0)
                    value2 = Double(obj2.pe?.value ?? 0)
                case .pb:
                    value1 = Double(obj1.pb?.value ?? 0)
                    value2 = Double(obj2.pb?.value ?? 0)
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


