//
//  YXShareOptionsListViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/11/23.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift



enum YXShareOptinosItem {
    
    //行权价
    case strikePrice
    //最新价
    case latestPrice
    //涨跌幅
    case pctchng
    //买一价
    case bidPrice
    //卖一价
    case askPrice
    //涨跌额
    case netchng
    //成交量
    case volume
    //成交额
    case amount
    //未平仓数合约数
    case openInt
    //溢价
    case premium
    //引申波幅
    case impliedVolatility
    //对冲值//Delta
    case delta
    //Gamma
    case gamma
    //Vega
    case vega
    //Theta
    case theta
    //Rho
    case rho
    
    var title: String {
        switch self {
        case .strikePrice:
            return YXLanguageUtility.kLang(key: "stock_detail_strike")
        case .latestPrice:
            return YXLanguageUtility.kLang(key: "warrants_latest_price")
        case .pctchng:
            return YXLanguageUtility.kLang(key: "market_roc")
        case .bidPrice:
            return YXLanguageUtility.kLang(key: "first_bid")
        case .askPrice:
            return YXLanguageUtility.kLang(key: "first_ask")
        case .netchng:
            return YXLanguageUtility.kLang(key: "market_change")
        case .volume:
            return YXLanguageUtility.kLang(key: "market_volume")
        case .amount:
            return YXLanguageUtility.kLang(key: "market_amount")
        case .openInt:
            return YXLanguageUtility.kLang(key: "options_non_closedContract")
        case .premium:
            return "溢价"
        case .impliedVolatility:
            return YXLanguageUtility.kLang(key: "options_implied_volatility")
        case .delta:
            return "Delta"
        case .gamma:
            return "Gamma"
        case .vega:
            return "Vega"
        case .theta:
            return "Theta"
        case .rho:
            return "Rho"
        }
    }
    
}

enum YXShareOptinosCount: Int {
    case ten   = 10
    case twenty  = 20
    case thirty  = 30
    case forty  = 40
    case all    = 0
    
    var title: String {
        switch self {
        case .ten:
            return "10"
        case .twenty:
            return "20"
        case .thirty:
            return "30"
        case .forty:
            return "40"
        case .all:
            return YXLanguageUtility.kLang(key: "common_all")
        }
    }
}

class YXShareOptionsListViewModel: YXTableViewModel {
    var contentOffset = BehaviorSubject.init(value: CGPoint.zero)
    var contentOffset2 = BehaviorSubject.init(value: CGPoint.zero)
    var optionsType: YXShareOptionsType = .call
    var maturityDate: String = ""
    var market: String = ""
    var symbol: String = ""
    var nextPageBegin: Double = 0.0
    let dataSoureSubject = PublishSubject<[[Any]]>()
    var showLoading = false
    
    var quote: YXV2Quote? {
        didSet {
            // 股票价格改变，需要从新计算股票现价cell的位置
            let array = self.dataSource?.first ?? []
            if let price = quote?.latestPrice?.value, price > 0, array.count > 1 {
                var tempArray = [Any]()
                for item in array {
                    if let model = item as? [String: YXShareOptionsChainItem] {
                        tempArray.append(model)
                    }
                }
                self.stockPriceIndex = self.findStockPriceIndex(array: tempArray)
                tempArray.insert("stockPrice", at: self.stockPriceIndex)
                self.dataSource = [tempArray]
            }
        }
    }
    
    var isLandscape = false
    var stockPriceIndex = 0
    
    override var perPage: UInt {
        get {
            50
        }
        set {
            
        }
    }
    
    var tapCellAction: ((_ market: String, _ code: String) -> Void)?
    
    var currentOptinosCount: YXShareOptinosCount = .ten
    
    // 方向，0：行权价正序，1：行权价逆序，2：按行权价上下取
    var direction: Int {
        if currentOptinosCount == .all {
            return 0
        }else {
            return 2
        }
    }
    
    var count: Int {
        return currentOptinosCount.rawValue
    }
    
    var stockPrice: Double {
        if let latestPrice = quote?.latestPrice?.value, let priceBase = quote?.priceBase?.value {
            return Double(latestPrice) / pow(10.0, Double(priceBase))
        }else {
            return 0.0
        }
    }
    
    var stockChange: Double {
        if let change = quote?.netchng?.value, let priceBase = quote?.priceBase?.value {
            return Double(change) / pow(10.0, Double(priceBase))
        }else {
            return 0.0
        }
    }
    
    var stockRoc: Double {
        if let roc = quote?.pctchng?.value {
            return Double(roc) / 100.0
        }else {
            return 0.0
        }
    }
    
    override func request(withOffset offset: Int) -> RACSignal<AnyObject>! {
        
        guard self.maturityDate.count > 0, stockPrice > 0 else { return RACSignal.empty() }
        
        let signal = RACSignal<AnyObject>.createSignal { (subscriber) -> RACDisposable? in
            
            let requestModel = YXShareOptionsChainReqModel()
            requestModel.market = self.market//"us"
            requestModel.code = self.symbol//"AAPL"
            requestModel.maturityDate = self.maturityDate
            requestModel.count = self.count
            requestModel.direction = self.direction
            
            if offset == 0 { // 从新开始
                if self.currentOptinosCount == .all {
                    requestModel.nextPageBegin = 0
                }else {
                    requestModel.nextPageBegin = self.stockPrice
                }
                
            }else { // 加载更多
                requestModel.nextPageBegin = self.nextPageBegin
            }
            
            let request = YXRequest.init(request: requestModel)
            var loadingHud: YXProgressHUD?
            if self.showLoading {
                loadingHud = YXProgressHUD.showLoading("")
            }else {
                if self.dataSource == nil {
                    loadingHud = YXProgressHUD.showLoading("")
                }
            }
            
            request.startWithBlock(success: { [weak self](response) in
                loadingHud?.hide(animated: true)
                guard let `self` = self else { return }
                if response.code == YXResponseStatusCode.success {
                    let model = YXShareOptionsChainResModel.yy_model(withJSON: response.data ?? [:])
                    if let nextPageBegin = model?.nextPageBegin {
                        self.nextPageBegin = nextPageBegin
                    }
            
                    if let callList = model?.callGroup, let putList = model?.putGroup, callList.count == putList.count  {
                        var array = self.dataSource?.first ?? []
                        if offset == 0 {
                            array = []
                        }
                        
                        for index in 0..<callList.count {
                            array.append([YXShareOptionsType.call.key: callList[index], YXShareOptionsType.put.key: putList[index]])
                        }
                        
                        self.stockPriceIndex = self.findStockPriceIndex(array: array)
                        
                        if array.count > 1,self.stockPrice > 0 {
                            array.insert("stockPrice", at: self.stockPriceIndex)
                        }
                        
                        self.dataSource = [array]
                        
                        if let hasMore = model?.hasMore  {
                            self.loadNoMore = !hasMore
                        }
                        
                    }else {
                        if offset == 0 {
                            self.dataSource = [[]]
                        }
                    }
                }
                if let dataSource = self.dataSource {
                    self.dataSoureSubject.onNext(dataSource)
                }
                
                subscriber.sendNext(nil)
                subscriber.sendCompleted()
                
            }, failure: { (request) in
                loadingHud?.hide(animated: true)
                subscriber.sendError(request.error)
            })
            
            return nil
        }
        return signal
    }
    
    func findStockPriceIndex(array: [Any]) -> Int {
        for (index, item) in array.enumerated() {
            if let model = item as? [String: YXShareOptionsChainItem], let value = model[YXShareOptionsType.call.key] {
                let strikePrice = value.strikePrice / pow(10.0, value.priceBase)
                if self.stockPrice < strikePrice {
                    return index
                }
            }
        }
        return 0
    }
    
    override init(services: YXViewModelServices, params: [AnyHashable : Any]?) {
        
        super.init(services: services, params: params)
        
        if let market = params?["market"] as? String {
            self.market = market
        }
        
        if let symbol = params?["code"] as? String {
            self.symbol = symbol
        }
        
    }
}
