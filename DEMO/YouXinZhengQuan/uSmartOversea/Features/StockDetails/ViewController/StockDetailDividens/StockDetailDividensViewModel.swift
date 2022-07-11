//
//  StockDetailDividensViewModel.swift
//  uSmartOversea
//
//  Created by lennon on 2022/5/19.
//  Copyright © 2022 RenRenDai. All rights reserved.
//
import UIKit

 class StockDetailDividensViewModel: YXTableViewModel {
    
     @objc dynamic var dataModel:StockDetailDividensResponse?;
        
    override func initialize() {
        super.initialize()
        shouldPullToRefresh = true
    }

    override func request(withOffset offset: Int) -> RACSignal<AnyObject>! {
        return RACSignal.createSignal { [weak self] subscriber -> RACDisposable? in

            let dividensRequestModel = StockDetailDividensRequestModel.init()
            
            if let market = self?.params?["market"] as? String,let symbol = self?.params?["symbol"] as? String {
//                dividensRequestModel.stock = "hk00700"
                dividensRequestModel.stock = market + symbol
            }
            
            
            let requestModel = YXRequest.init(request: dividensRequestModel)
            requestModel.startWithBlock { [weak self] responseModel in
                guard let `self` = self else { return }
                if responseModel.code == .success{
                    if let res = responseModel as? StockDetailDividensResponse, res.list.count > 0 {
                        self.dataModel = res
                        var tmpDataSource: [[Any]] = []
                        res.list.forEach{ tmpDataSource.append($0.day) }
                        self.dataSource = tmpDataSource
                        
//                        let teststr = """
// {"code": 0, "msg": "success", "data": {"date": "20220527", "list": [{"date": "2022", "div_amount": 1.6, "div_yield": 0.004788, "is_exp": 0, "month": [{"date": "202205", "div_amount": 1.6, "div_yield": 0.004788, "is_exp": 0}], "day": [{"date": "20220520", "div_amount": 1.6, "div_yield": 0.004788, "is_exp": 0}]}]}}
//"""
//                        let model = StockDetailDividensResponse.yy_model(withJSON: teststr)!
//                        self.dataModel = model
//                        var tmpDataSource: [[Any]] = []
//                        model.list.forEach{ tmpDataSource.append($0.day) }
//                        self.dataSource = tmpDataSource
                        
                        subscriber.sendNext(nil)
                        subscriber.sendCompleted()
                    } else {
                        self.dataSource = []
                        subscriber.sendNext(nil)
                        subscriber.sendCompleted()
                    }
                }
            } failure: { _ in
                self?.dataSource = nil

                subscriber.sendNext(nil)
                subscriber.sendCompleted()
            }
            
            return nil
        }
    }

}
