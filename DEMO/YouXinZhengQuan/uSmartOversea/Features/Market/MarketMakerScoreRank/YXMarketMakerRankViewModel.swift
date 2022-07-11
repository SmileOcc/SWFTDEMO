//
//  YXMarketMakerRankViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2021/1/6.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXMarketMakerRankViewModel: YXStockListViewModel {
    override var shouldPullToRefresh: Bool {
        get {
            return true
        }
        set {
            
        }
    }
    
    override var didClickSortCommand: RACCommand<AnyObject, AnyObject> {
        get {
            let command = RACCommand<AnyObject, AnyObject>.init { (arr) -> RACSignal<AnyObject> in
                
                if let list = arr as? Array<Any> {
                    let state = YXSortState.init(rawValue: UInt())
                    if let sortState = list.first as? YXSortState, let type = list.last as? YXMobileBrief1Type {
                        
                        
                        if let array = self.dataSource.first as? [YXMarketMakerRankItem] {
                            let sortedArray = array.sorted { (obj1, obj2) -> Bool in
                                switch type {
                                case .yxScore:
                                    return sortState == .descending ? obj1.score > obj2.score : obj1.score < obj2.score
                                case .avgSpread:
                                    return sortState == .descending ? obj1.avgSpread > obj2.avgSpread : obj1.avgSpread < obj2.avgSpread
                                case .openOnTime:
                                    return sortState == .descending ? obj1.openOnTime > obj2.openOnTime : obj1.openOnTime < obj2.openOnTime
                                case .liquidity:
                                    return sortState == .descending ? obj1.liquidity > obj2.liquidity : obj1.liquidity < obj2.liquidity
                                case .oneTickSpreadProducts:
                                    return sortState == .descending ? obj1.oneTickSpreadProducts > obj2.oneTickSpreadProducts : obj1.oneTickSpreadProducts < obj2.oneTickSpreadProducts
                                case .oneTickSpreadDuration:
                                    return sortState == .descending ? obj1.oneTickSpreadDuration > obj2.oneTickSpreadDuration : obj1.oneTickSpreadDuration < obj2.oneTickSpreadDuration
                                case .amount:
                                    return sortState == .descending ? obj1.avgAmount > obj2.avgAmount : obj1.avgAmount < obj2.avgAmount
                                case .volume:
                                    return sortState == .descending ? obj1.avgVolume > obj2.avgVolume : obj1.avgVolume < obj2.avgVolume
                                
                                default:
                                    return false
                                }
                                
                            }
                            
                            self.dataSource = [sortedArray]
                        }
                    }
                }
                
                return RACSignal.empty()
            }
            return command
        }
        set {
            
        }
    }
    
    override func request(withOffset offset: Int) -> RACSignal<AnyObject>! {
        let signal = RACSignal<AnyObject>.createSignal { (subscriber) -> RACDisposable? in
            let requestModel = YXMarketMakerRankReqModel()
            
            let request = YXRequest.init(request: requestModel)
            
            request.startWithBlock(success: { [weak self](response) in
                
                if response.code == YXResponseStatusCode.success {
                    let model  = YXMarketMakerRankResModel.yy_model(withJSON: response.data ?? [:])
                    if let array = model?.list {
                        self?.dataSource = [array]
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
