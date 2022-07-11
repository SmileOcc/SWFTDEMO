//
//  YXSGWarrantsViewModel.swift
//  uSmartOversea
//
//  Created by lennon on 2022/1/13.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator

class YXSGWarrantsViewModel: HUDServicesViewModel, RefreshViewModel {
    
    typealias IdentifiableModel = YXWarrantsDetailModel
    typealias Services = YXQuotesDataService
    var navigator: NavigatorServicesType!
    
//    let trackOffsetRelay = BehaviorRelay<CGPoint>(value: CGPoint.zero)
//    let dragOffsetRelay = BehaviorRelay<CGPoint>(value: CGPoint.zero)
    let contentOffsetRelay = BehaviorRelay<CGPoint>(value: CGPoint.zero)
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    var services: Services! = YXQuotesDataService()
    var quoteService: YXQuotesDataService = YXQuotesDataService()
    
    //响应回调
    var warrantsResultResponse: YXResultResponse<YXWarrantsModel>?
    
    var endHeaderRefreshStatus: Driver<EndRefreshStatus>?
    var endFooterRefreshStatus: Driver<EndRefreshStatus>?
    
    var name: String?
    var symbol: String = ""
    var market: String = "sg"
    var warrantType: YXStockWarrantsType = .inlineWarrants
    weak var pushVC: YXSGWarrantsViewController? = nil
    var needRefresh: Bool = false
    var isFromFundFlow = false
    
    @objc var roc: Int32 = 0 //涨跌幅
    @objc var change: Int64 = 0 //涨跌额
    @objc var now: Int64 = 0 //现价
    @objc var priceBase: UInt32 = 0
    
    @objc var type: YXBullAndBellType = .all    //类型
    @objc var expireDate: YXBullAndBellExpireDate = .all    //距到期日
    @objc var sortType: YXBullAndBellSortType = .roc     //排序指标
    @objc var direction: YXBullAndBellDirection = .descending  //筛选方向
    @objc var moneyness: YXBullAndBellMoneyness = .all  //价内/价外
    @objc var leverageRatio: YXBullAndBellLeverageRatio = .all  //杠杆比率
    @objc var premium: YXBullAndBellPremium = .all  //溢价
    @objc var outstandingRatio: YXBullAndBellOutstandingRatio = .all //街货比
    @objc var outstandingPctLow = ""  //行使价低
    @objc var outstandingPctHeight = "" //行使价高
    @objc var exchangeRatioLow = ""     //换股比率低
    @objc var exchangeRatioHeight = ""  //换股比率高
    @objc var recoveryPriceLow = ""  //回收价低
    @objc var recoveryPriceHeight = "" //回收价高
    @objc var extendedVolatilityLow = "" //引申波幅低
    @objc var extendedVolatilityHeight = "" //引申波幅高
    
    var page: Int = 1
    var offset: Int = 0
    var perPage: Int = 30
    var total: Int?
    
    lazy var userLevel: QuoteLevel = {

        let level = YXUserManager.shared().getLevel(with: YXMarketType.SG.rawValue)
        if level == .bmp {
            return .delay
        }else {
            return level
        }
    }()

    func updateLevel() {
        userLevel = YXUserManager.shared().getLevel(with: YXMarketType.SG.rawValue)
        if userLevel == .bmp {
            userLevel = .delay
        }
    }
    
    let dataSource: BehaviorRelay<[IdentifiableModel]> = BehaviorRelay<[IdentifiableModel]>(value:[])
    
    let refreshStockSubject = PublishSubject<Bool>()
    
    var dataSourceSingle: Single<[IdentifiableModel]> {
        Single<[YXWarrantsDetailModel]>.create(subscribe: { [weak self] (single) -> Disposable in
            guard let strongSelf = self else { return Disposables.create() }
            
            strongSelf.refreshStockSubject.onNext(true)
            
            var perPage = strongSelf.perPage
            var offset = strongSelf.offset
            if strongSelf.userLevel == .bmp {
                perPage = 20
                offset = 0
                if strongSelf.page > 1 {
                    single(.success([]))
                }
            }
            
            if self?.isFromFundFlow ?? false {
                self?.sortType = .score
            }
                        
            return strongSelf.services.request(.warrants(strongSelf.market, strongSelf.symbol, offset, perPage, strongSelf.sortType.rawValue, strongSelf.direction.rawValue, strongSelf.generateFilterDictionary(), 0), response: { (response: YXResponseType<YXWarrantsModel>) in
                
                strongSelf.hudSubject.onNext(.hide)
                switch response {
                case .success(let result, let code):
                    if code == .success, let list = result.data?.warrants {
                        strongSelf.total = result.data?.total
                        single(.success(list))
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
    
    init() {
        
        
        warrantsResultResponse = { [weak self] (response) in
            guard let strongSelf = self else { return }
            switch response {
            case .success(let result, let code):
                if code == .success, let list = result.data?.warrants {
                    
                    var totalList = strongSelf.dataSource.value
                    let totalCount = totalList.count
                    var replaceIndex = result.data?.from ?? 0
                    for model in list {
                        if replaceIndex < totalCount {
                            totalList[replaceIndex] = model
                        }
                        replaceIndex += 1
                    }
                    strongSelf.dataSource.accept(totalList)
                    
                }
            case .failed(_):
                log(.info, tag: kNetwork, content: " ")
            }
        }
    }
    
    func generateFilterDictionary() -> NSMutableDictionary {
        
        let dic = NSMutableDictionary()

        dic.setValue(NSNumber(value: type.rawValue), forKey: "type")
        dic.setValue(NSNumber(value: moneyness.rawValue), forKey: "moneyness")
        
        switch expireDate {
        case .lessThanThree:
            dic.setValue(["low": NSNumber(value: 0), "up": NSNumber(value: 3)], forKey: "to_expire_date")
            break
        case .threeToSix:
            dic.setValue(["low": NSNumber(value: 3), "up": NSNumber(value: 6)], forKey: "to_expire_date")
            break
        case .sixToNine:
            dic.setValue(["low": NSNumber(value: 6), "up": NSNumber(value: 12)], forKey: "to_expire_date")
            break
        case .moreThanTwelve:
            dic.setValue(["low": NSNumber(value: 12)], forKey: "to_expire_date")
            break
        default:
            break
        }
        
        switch outstandingRatio {
        case .lessThanThirty:
            dic.setValue(["low": NSNumber(value: 0), "up": NSNumber(value: 300000)], forKey: "outstanding_ratio")
            break
        case .thirtyToFifty:
            dic.setValue(["low": NSNumber(value: 300000), "up": NSNumber(value: 500000)], forKey: "outstanding_ratio")
            break
        case .fiftyToSeventy:
            dic.setValue(["low": NSNumber(value: 500000), "up": NSNumber(value: 700000)], forKey: "outstanding_ratio")
        case .moreThanSeventy:
            dic.setValue(["low": NSNumber(value: 700000), "up": NSNumber(value: 1000000)], forKey: "outstanding_ratio")
            break
        default:
            break
        }
        
        switch premium {
        case .zeroToThree:
            dic.setValue(["low": NSNumber(value: 0), "up": NSNumber(value: 300)], forKey: "premium")
            break
        case .threeToSix:
            dic.setValue(["low": NSNumber(value: 300), "up": NSNumber(value: 600)], forKey: "premium")
            break
        case .sixToNine:
            dic.setValue(["low": NSNumber(value: 600), "up": NSNumber(value: 900)], forKey: "premium")
            break
        case .moreThanNine:
            dic.setValue(["low": NSNumber(value: 900)], forKey: "premium")
            break
        default:
            break
        }
        
        switch leverageRatio {
        case .lessThanOne:
            dic.setValue(["up": NSNumber(value: 10000)], forKey: "leverage_ratio")
            break
        case .oneToFive:
            dic.setValue(["low": NSNumber(value: 10000), "up": NSNumber(value: 50000)], forKey: "leverage_ratio")
            break
        case .fiveToTen:
            dic.setValue(["low": NSNumber(value: 50000), "up": NSNumber(value: 100000)], forKey: "leverage_ratio")
            break
        case .moreThanTen:
            dic.setValue(["low": NSNumber(value: 100000)], forKey: "leverage_ratio")
            break
        default:
            break
        }
        
        if !outstandingPctLow.isEmpty || !outstandingPctHeight.isEmpty {
            let low = round((Double(outstandingPctLow) ?? 0)*10000)
            let up = round((Double(outstandingPctHeight) ?? 0)*10000)
            dic.setValue(["low": NSNumber(value: low), "up": NSNumber(value: up)], forKey: "strike_price")
        }
        
        if !exchangeRatioLow.isEmpty || !exchangeRatioHeight.isEmpty {
            let low = round((Double(exchangeRatioLow) ?? 0)*10000)
            let up = round((Double(exchangeRatioHeight) ?? 0)*10000)
            dic.setValue(["low": NSNumber(value: low), "up": NSNumber(value: up)], forKey: "exchange_ratio")
        }
        
        if !recoveryPriceLow.isEmpty || !recoveryPriceHeight.isEmpty {
            let low = round((Double(recoveryPriceLow) ?? 0)*10000)
            let up = round((Double(recoveryPriceHeight) ?? 0)*10000)
            dic.setValue(["low": NSNumber(value: low), "up": NSNumber(value: up)], forKey: "call_price")
        }
        
        if !extendedVolatilityLow.isEmpty || !extendedVolatilityHeight.isEmpty {
            let low = round((Double(extendedVolatilityLow) ?? 0)*10000)
            let up = round((Double(extendedVolatilityHeight) ?? 0)*10000)
            dic.setValue(["low": NSNumber(value: low), "up": NSNumber(value: up)], forKey: "implied_volatility")
        }
        
        return dic
    }
    
}


