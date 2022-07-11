//
//  YXStockWarrantsViewModel.swift
//  uSmartOversea
//
//  Created by 井超 on 2019/8/2.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator

class YXStockWarrantsViewModel: HUDServicesViewModel, RefreshViewModel {
    
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
    var market: String = "hk"
    var warrantType: YXStockWarrantsType = .inlineWarrants
    weak var pushVC: YXStockWarrantsViewController? = nil
    var needRefresh: Bool = false
    var isFromFundFlow = false
    
    @objc var roc: Int32 = 0 //涨跌幅
    @objc var change: Int64 = 0 //涨跌额
    @objc var now: Int64 = 0 //现价
    @objc var priceBase: UInt32 = 0
    
    @objc var issuer: NSNumber = 0
    @objc var issuerTitleArray = [YXLanguageUtility.kLang(key: "common_all")]
    @objc var issuerIDArray: [NSNumber] = [NSNumber(integerLiteral: 0)]
    @objc var issuerIndex = 0
    
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
        
        let level = YXUserManager.shared().getLevel(with: YXMarketType.HK.rawValue)
        if level == .bmp {
            return .delay
        }else {
            return level
        }
        
    }()

    func updateLevel() {
        userLevel = YXUserManager.shared().getLevel(with: YXMarketType.HK.rawValue)
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
        
        let request = YXRequest(request: YXWarrantIssuerRequestModel())
        request.startWithBlock(success: { [weak self] (responseModel) in
            guard let strongSelf = self else { return }
            
            let data = responseModel.data
            if let array = data?["list"] as? [[String: Any?]] {
                strongSelf.issuerTitleArray = [YXLanguageUtility.kLang(key: "common_all")]
                strongSelf.issuerIDArray = [NSNumber(integerLiteral: 0)]
                array.forEach { (obj) in
                    if let name = obj["name"] as? String, let id = obj["id"] as? NSNumber {
                        strongSelf.issuerTitleArray.append(name)
                        strongSelf.issuerIDArray.append(id)
                    }
                }
            }
        }, failure: { (_) in
            
        })
        
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

        if self.warrantType == .inlineWarrants {
            dic.setValue(NSNumber(value: YXBullAndBellType.inline.rawValue), forKey: "type")
            return dic
        }
        dic.setValue(NSNumber(value: type.rawValue), forKey: "type")
        dic.setValue(NSNumber(value: moneyness.rawValue), forKey: "moneyness")
        dic.setValue(self.issuer, forKey:"issuer")
        
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
@objc enum YXBullAndBellType: Int { //类型
    case all      = 0 //全部
    case buy      = 1 //认购
    case sell     = 2 //认沽
    case bull     = 3 //牛证
    case bear     = 4 //熊证
    case inline   = 6 //界内证
}

@objc enum YXBullAndBellExpireDate: Int { //距到期日
    case all             = 0 //全部
    case lessThanThree   = 1 //小于三个月
    case threeToSix      = 2 //3~6
    case sixToNine       = 3 //6~12
    case moreThanTwelve  = 4 //>12
}

@objc enum YXBullAndBellDirection: Int { //方向
    case ascending    = 0 //升序
    case descending   = 1 //降序
}

@objc enum YXBullAndBellMoneyness: Int { //价内/价外
    case all             = 0 //全部
    case priceIn         = 1 //价内
    case priceOut        = 2 //价外
}

@objc enum YXBullAndBellLeverageRatio: Int { //杠杆比率
    case all             = 0 //全部
    case lessThanOne     = 1 //小于1
    case oneToFive       = 2 //1～5
    case fiveToTen       = 3 //5～10
    case moreThanTen     = 4 //大于10
}

@objc enum YXBullAndBellPremium: Int { //溢价
    case all             = 0 //全部
    case zeroToThree     = 1 //0~3
    case threeToSix      = 2 //3~6
    case sixToNine       = 3 //6~9
    case moreThanNine    = 4 //大于9
}

@objc enum YXBullAndBellOutstandingRatio: Int { //街货比
    case all                = 0 //全部
    case lessThanThirty     = 1 //小于30
    case thirtyToFifty      = 2 //30～50
    case fiftyToSeventy     = 3 //50～70
    case moreThanSeventy    = 4 //大于70
}

@objc enum YXBullAndBellSortType: Int { //排序指标
    case price           = 0 //最新价
    case roc             = 1 //涨跌幅
    case change          = 2 //涨跌额
    case volume          = 3 //成交量
    case amount          = 4 //成交额
    case maturityDate    = 5 //到期日
    case premium         = 6 //溢价
    case outstandingPct  = 7 //街货比
    case gearing         = 8 //杠杆比率
    case conversionRatio = 9 //换股比率
    case strike          = 10//行使价
    case moneyness               = 11//价内价外
    case impliedVolatility       = 12//引申波幅
    case actualLeverage          = 13//实际杠杆
    case callPrice               = 14//回收价
    case toCallPrice             = 15//距回收价
    case upperStrike             = 16//上限价
    case lowerStrike             = 17//下限价
    case toUpperStrike           = 18//距上限
    case toLowerStrike           = 19//距下限
    case score                   = 21//评分
    case bidSize
    case askSize
    case delta
    case status
}
