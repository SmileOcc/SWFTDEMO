//
//  YXWarrantsFundFlowDetailViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/9/25.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

enum YXWarrantsFundFlowRankType: Int {
    case longPos = 1
    case buy
    case bull
    case shortPos
    case sell
    case bear
}

class YXWarrantsFundFlowDetailViewModel: YXStockListViewModel {
    override var shouldPullToRefresh: Bool {
        get {
            return true
        }
        set {
            
        }
    }
    
    var kLinemodel: YXWarrantsFundFlowKLineResModel?
    
    var sortDirection = 1 // 0：升序；1：降序
    var sortRule: YXWarrantsFundFlowRankType = .longPos
    
    override var didClickSortCommand: RACCommand<AnyObject, AnyObject> {
        get {
            let command = RACCommand<AnyObject, AnyObject>.init { (arr) -> RACSignal<AnyObject> in
                
                if let list = arr as? Array<Any> {
                    if let sortState = list.first as? YXSortState {
                        self.sortDirection = sortState == YXSortState.descending ? 1 : 0
                    }
                    
                    if let type = list.last as? YXMobileBrief1Type {
                        switch type {
                        case .longPosition:
                            self.sortRule = .longPos
                        case .warrantBuy:
                            self.sortRule = .buy
                        case .warrantBull:
                            self.sortRule = .bull
                        case .shortPosition:
                            self.sortRule = .shortPos
                        case .warrantSell:
                            self.sortRule = .sell
                        case .warrantBear:
                            self.sortRule = .bear
                        default:
                            self.sortRule = .longPos
                        }
                    }
                }
                
                self.requestOffsetDataCommand.execute(NSNumber.init(value: 0))
                
                return RACSignal.empty()
            }
            return command
        }
        set {
            
        }
    }
    
    override var didSelectCommand: RACCommand<AnyObject, AnyObject>! {
        get {
            return RACCommand<AnyObject, AnyObject>.init { (indexPath) -> RACSignal<AnyObject> in
                if let indexPath = indexPath as? NSIndexPath {
                    let item = self.dataSource[indexPath.section][indexPath.row]
                    if let model = item as? YXWarrantsFundFlowRankItem {
                        if let realSymbol = model.asset?.secuCode, let realMarket = model.asset?.market {
                            
                            var inputs = [YXStockInputModel]()
                            var realIndex = 0
                            var index = 0
                            for item in self.dataSource[indexPath.section] {
                                if let model = item as? YXWarrantsFundFlowRankItem, let symbol = model.asset?.secuCode, let market = model.asset?.market {
                                    let input = YXStockInputModel()
                                    input.market = market
                                    input.symbol = symbol
                                    input.name = model.asset?.name ?? ""
                                    
                                    inputs.append(input)
                                    
                                    if realIndex == 0, symbol == realSymbol, market == realMarket {
                                        realIndex = index
                                    }
                                    index += 1
                                }
                            }
                            
                            if inputs.count > 0 {
                                self.services.pushPath(.stockDetail, context: ["dataSource": inputs, "selectIndex": realIndex], animated: true)
                            }
                            
                        }else {
                            return RACSignal.empty()
                        }
                    }
                }
                
                return RACSignal.empty()
            }
        }
        set {
            
        }
    }
    
    // 资金流向分时
    func getKLine() -> Single<YXWarrantsFundFlowKLineResModel?> {
        
        let single = Single<YXWarrantsFundFlowKLineResModel?>.create { single in
            let requestModel = YXWarrantsFundFlowKLineReqModel()
        
            let request = YXRequest.init(request: requestModel)
            
            request.startWithBlock(success: { [weak self](response) in
                
                if response.code == YXResponseStatusCode.success {
                    self?.kLinemodel = YXWarrantsFundFlowKLineResModel.yy_model(withJSON: response.data ?? [:])
                }
                
                single(.success(self?.kLinemodel))
                
            }, failure: { (request) in
                single(.error(request.error ?? NSError.init(domain: "", code: -1, userInfo: nil)))
            })
            return Disposables.create()
        }
        
        return single
    }
    
    override func request(withOffset offset: Int) -> RACSignal<AnyObject>! {
        let signal = RACSignal<AnyObject>.createSignal { (subscriber) -> RACDisposable? in
            let requestModel = YXWarrantFundFlowRankReqModel()
            requestModel.from = offset
            requestModel.count = 30
            requestModel.sortRule = self.sortRule.rawValue
            requestModel.sortDirection = self.sortDirection
            
            let request = YXRequest.init(request: requestModel)
            
            request.startWithBlock(success: { [weak self](response) in
                
                if response.code == YXResponseStatusCode.success {
                    let model  = YXWarrantsFundFlowRankResModel.yy_model(withJSON: response.data ?? [:])
                    if let totalCount = model?.total, let list = model?.data, list.count > 0 {
                        var array = self?.dataSource?.first ?? []
                        if offset == 0 {
                            array = []
                        }
                        if array.count == 0 {
                            array = Array.init(repeating: YXWarrantsFundFlowRankItem(), count: totalCount)
                        }
                        var index = offset
                        let level = YXUserManager.shared().getLevel(with: kYXMarketHK)//YXUserManager.shareInstance().getCurLevel(withMarket: kYXMarketHK)
                        for item in list {
                            if index < array.count {
                                item.level = level.rawValue
                                array[index] = item
                                index += 1
                            }
                        }
                        
                        self?.dataSource = [array]
                        
                    }else {
                        if offset == 0 {
                            self?.dataSource = [[]]
                        }
                    }
                }
                
                subscriber.sendNext(nil)
                subscriber.sendCompleted()
                
            }, failure: { (request) in
                subscriber.sendError(request.error)
            })
            
            return nil
        }
        return signal
    }
}
