//
//  YXA-HKRankListViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/3/17.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXA_HKRankListViewModel: YXViewModel {
    var rankType: YXA_HKRankType
    var rankMarket: YXA_HKMarket
    var rankDataSource: [Any] = []
    var tradeDates: [String] = []
    var page = 0
    var day: Int64 = 0
    var rankSort: YXA_HKRankSortType!
    var canLoadMore = true
    
    init(services: YXViewModelServices, type: YXA_HKRankType, market: YXA_HKMarket) {
        rankType = type
        rankMarket = market
        
        super.init(services: services, params: [:])
        
        switch type {
        case .fundDirection:
            rankSort = YXA_HKRankSortType.fundAmount(sortType: .descending)
        case .roc:
            rankSort = YXA_HKRankSortType.roc(sortType: .descending)
        default:
            break
        }
    }
    
    // 交易日历
    func getTradeDate() -> Single<Any?> {
        let single = Single<Any?>.create { single in
            let requestModel = YXTradeDateRequestModel()
            if self.rankMarket == .hs {
                requestModel.market = YXA_HKMarket.sh.rawValue
            }else {
                requestModel.market = self.rankMarket.rawValue
            }
            
            if self.rankMarket.direction == .south, self.rankType == .fundDirection {
                requestModel.count = 32
                requestModel.type = 2
            }
            
            let request = YXRequest.init(request: requestModel)
            
            request.startWithBlock(success: { [weak self](response) in
                if response.code == YXResponseStatusCode.success {
                    var array = response.data?["tradeDataList"] as? [String] ?? []
                    if self?.rankMarket.direction == .south, self?.rankType == .fundDirection {
                        if array.count > 2 {
                            // t+2日 删除前两个
                            array.remove(at: 0)
                            array.remove(at: 0)
                            self?.tradeDates = array
                        }
                    }else {
                        self?.tradeDates = array
                    }
                }
                single(.success(response))
            }, failure: { (request) in
                single(.error(request.error ?? NSError.init(domain: "", code: -1, userInfo: nil)))
            })
            return Disposables.create()
        }
        
        return single
    }
    
    // 资金流向排行
    func getFundDirection() -> Single<Any?> {
        
        let single = Single<Any?>.create { single in
            let requestModel = YXA_HKFundDirectionRankRequestModel()
            requestModel.direction = self.rankMarket.direction.rawValue
            requestModel.market = self.rankMarket.rawValue
            requestModel.offset = self.page * requestModel.count
            requestModel.day = self.day
            requestModel.sortKey = self.rankSort.sortKey
            requestModel.sortType = self.rankSort.sortType
            let request = YXRequest.init(request: requestModel)
            
            request.startWithBlock(success: { [weak self](response) in
                if response.code == YXResponseStatusCode.success {
                    let fundDirectionRankModel = YXA_HKFundDirectionRankModel.yy_model(withJSON: response.data ?? [:])
                    if let model = fundDirectionRankModel {
                        for item in model.records {
                            item.priceBase = model.priceBase
                        }
                        
                        guard let `self` = self else { return }
                        if self.page == 0 {
                            self.rankDataSource = []
                        }
                        self.rankDataSource = self.handleDataSource(arr: model.records, countPerPage: requestModel.count)//model.records
                    }
                }
                single(.success(response))
                }, failure: { (request) in
                single(.error(request.error ?? NSError.init(domain: "", code: -1, userInfo: nil)))
            })
            return Disposables.create()
        }
        
        return single
    }
    
    
    // 成交量
    func getVolume() -> Single<Any?> {
        
        let single = Single<Any?>.create { single in
            let requestModel = YXTradeActiveRequestModel()
            requestModel.direction = self.rankMarket.direction.rawValue
            requestModel.market = self.rankMarket.rawValue
            requestModel.offset = self.page * requestModel.count
            requestModel.day = self.day
        
            let request = YXRequest.init(request: requestModel)
            
            request.startWithBlock(success: { [weak self](response) in
                if response.code == YXResponseStatusCode.success {
                    let tradeActiveModel = YXTradeActiveResponseModel.yy_model(withJSON: response.data ?? [:])
                    if let model = tradeActiveModel {
                        for item in model.records {
                            item.priceBase = model.priceBase
                        }
                        
                        guard let `self` = self else { return }
                        if self.page == 0 {
                            self.rankDataSource = []
                        }
                        self.rankDataSource = self.handleDataSource(arr: model.records, countPerPage: requestModel.count)//model.records
                    }
                }
                single(.success(response))
            }, failure: { (request) in
                single(.error(request.error ?? NSError.init(domain: "", code: -1, userInfo: nil)))
            })
            return Disposables.create()
        }
        
        return single
    }
    
    // 上限预警
    func getLimitWarning() -> Single<Any?> {
        
        let single = Single<Any?>.create { single in
            let requestModel = YXA_HKLimitWarningRequestModel()
            requestModel.offset = self.page * requestModel.count
            requestModel.market = self.rankMarket.rawValue
        
            let request = YXRequest.init(request: requestModel)
            
            request.startWithBlock(success: { [weak self](response) in
                if response.code == YXResponseStatusCode.success {
                    let warningModel = YXA_HKLimitWarningResModel.yy_model(withJSON: response.data ?? [:])
                    if let model = warningModel {
                        for item in model.records {
                            item.priceBase = model.priceBase
                        }
                        
                        guard let `self` = self else { return }
                        if self.page == 0 {
                            self.rankDataSource = []
                        }
                        self.rankDataSource = self.handleDataSource(arr: model.records, countPerPage: requestModel.count)//model.records
                    }
                }
                single(.success(response))
            }, failure: { (request) in
                single(.error(request.error ?? NSError.init(domain: "", code: -1, userInfo: nil)))
            })
            return Disposables.create()
        }
        
        return single
    }
    
    func handleDataSource(arr: [Any], countPerPage: Int) -> [Any] {
        let array = [Any]() + rankDataSource
        if arr.count < countPerPage {
            canLoadMore = false
        }else {
            canLoadMore = true
            page = page + 1
        }
        
         return array + arr
    }
    
    func goToStockDetail(_ selectIndex: Int) {

        var inputs: [YXStockInputModel] = []
        for model in self.rankDataSource {

            var market: String?
            var symbol: String?
            var name: String?
            if let item = model as? YXA_HKFundDirectionRankItem {
                market = item.market
                symbol = item.code
                name = item.name

            }else if let item = model as? YXTradeActiveItem {
                market = item.market
                symbol = item.code
                name = item.name
            }else if let item = model as? YXA_HKLimitWarningItem {
                market = item.market
                symbol = item.code
                name = item.name
            }

            if let tempMarket = market, let tempSymbol = symbol {
                let input = YXStockInputModel()
                input.market = tempMarket
                input.symbol = tempSymbol
                input.name = name ?? ""
                inputs.append(input)
            }

        }

        if inputs.count > 0 {
            self.services.pushPath(.stockDetail, context: ["dataSource": inputs, "selectIndex": selectIndex], animated: true)
        }
    }
    
}

