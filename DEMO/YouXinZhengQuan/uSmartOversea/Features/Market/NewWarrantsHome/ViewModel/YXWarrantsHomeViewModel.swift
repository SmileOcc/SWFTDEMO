//
//  YXWarrantsHomeViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/9/22.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

enum YXNewWarrantsSectionType {
    case deal
    case entrance
    case street
    case fundFlow
    
    var title: String {
        switch self {
        case .street:
            //return "HSI" + YXLanguageUtility.kLang(key: "bullbear_CBBC_outstanding")
            return YXLanguageUtility.kLang(key: "warrants_cbbc_distribtion")
        case .fundFlow:
            return YXLanguageUtility.kLang(key: "warrant_capital_flows")
        case .entrance:
            return YXMarketSectionType.entrance.sectionName
        default:
            return ""
        }
    }
}

@objc enum YXWarrantType: Int {
    case buy = 1
    case sell
    case bull
    case bear
    
    var text: String {
        switch self {
        case .buy:
            return "认购证"
        case .sell:
            return "认沽证"
        case .bull:
            return "牛证"
        case .bear:
            return "熊证"
        }
    }
}

class YXWarrantsHomeViewModel: YXViewModel {
    var sections: [YXNewWarrantsSectionType] = [.deal, .entrance, .street, .fundFlow]
    var dealModel: YXWarrantsDealResModel?
    var streetTopModel: YXWarrantsStreetTopResModel?
    var fundFlowModel: YXWarrantCBBCFundFlowResModel?
    
    // 大市成交
    func getDeal() -> Single<Any?> {
        
        let single = Single<Any?>.create { single in
            let requestModel = YXWarrantsDealReqModel()
            requestModel.market = kYXMarketHK
        
            let request = YXRequest.init(request: requestModel)
            
            request.startWithBlock(success: { [weak self](response) in
                
                if response.code == YXResponseStatusCode.success {
                    self?.dealModel = YXWarrantsDealResModel.yy_model(withJSON: response.data ?? [:])
                }
                
                single(.success(self?.dealModel))
                
            }, failure: { (request) in
                single(.error(request.error ?? NSError.init(domain: "", code: -1, userInfo: nil)))
            })
            return Disposables.create()
        }
        
        return single
    }
    
    // 牛熊街货精选
    func getCBBCTop() -> Single<Any?> {

        let single = Single<Any?>.create { single in
            let requestModel = YXBullBearContractStreetReqModel()
            requestModel.market = kYXMarketHK

            let request = YXRequest.init(request: requestModel)

            request.startWithBlock(success: { [weak self](response) in

                if response.code == YXResponseStatusCode.success {
                    self?.streetTopModel = YXWarrantsStreetTopResModel.yy_model(withJSON: response.data ?? [:])
                }

                single(.success(self?.streetTopModel))

            }, failure: { (request) in
                single(.error(request.error ?? NSError.init(domain: "", code: -1, userInfo: nil)))
            })
            return Disposables.create()
        }

        return single
    }
    
    // 资金流向
    func getFundFlow() -> Single<Any?> {
        
        let single = Single<Any?>.create { single in
            let requestModel = YXWarrantCBBCFundFlowReqModel()
            requestModel.market = kYXMarketHK
        
            let request = YXRequest.init(request: requestModel)
            
            request.startWithBlock(success: { [weak self](response) in
                
                if response.code == YXResponseStatusCode.success {
                    self?.fundFlowModel = YXWarrantCBBCFundFlowResModel.yy_model(withJSON: response.data ?? [:])
                }
                
                single(.success(self?.fundFlowModel))
                
            }, failure: { (request) in
                single(.error(request.error ?? NSError.init(domain: "", code: -1, userInfo: nil)))
            })
            return Disposables.create()
        }
        
        return single
    }
    
    // 跳转街货分布
    func gotoCBBC(market: String, symbol: String, name: String) {
        let dic: [String: Any] = ["symbol": symbol, "name": name, "market": market, "warrantType": YXStockWarrantsType.bullBear, "tabIndex": 1]
        YXNavigationMap.navigator.push(YXModulePaths.warrantsAndStreet.url, context: dic)
    }
}
