//
//  YXNewStockCenterViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/4/28.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator

class YXNewStockCenterViewModel: HUDServicesViewModel {

    typealias Services = YXNewStockService
    var navigator: NavigatorServicesType!
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    let alertSubject = PublishSubject<Bool>()
    
//    var financingAccountDiff = false
    var financingAccountDiff = true
    
    var exchangeType: YXExchangeType = .hk
    var purchaseLabels: [String] = []
    var purchaseList: [YXNewStockCenterPreMarketStockModel] = []
    var purchaseNormalModel: YXNewStockCenterPreMarketModel?
    var deliverModel: YXNewStockDeliveredListModel?
    var premarketList: [YXNewStockCenterPreMarketStockModel] = []
    //更新状态
    var isRefeshing: Bool = false
    var isPulling: Bool = false
    // 是否自动滑动到待上市
    var isToPreMarket: Bool = false
    //响应回调
    var purchaseNormalResponse: YXResultResponse<YXNewStockCenterPreMarketModel>?
    var premarketResponse: YXResultResponse<YXNewStockCenterPreMarketModel>?
    var deliverResponse: YXResultResponse<YXNewStockDeliveredListModel>?
    //Rx代理回调
    typealias resultType = (isSuccess: Bool, msg: String?)
    let purchaseNormalSubject = PublishSubject<resultType>()
    let premarketSubject = PublishSubject<resultType>()
    let deliverSubject = PublishSubject<resultType>()
    
    lazy var quoteObservable: Observable<[resultType]> = { [unowned self] in
        if self.exchangeType == .us {
            return  Observable.zip([self.purchaseNormalSubject, self.premarketSubject])
        } else {
            return  Observable.zip([self.purchaseNormalSubject, self.premarketSubject, self.deliverSubject])
        }
    }()
    //请求service
    let newsService = YXNewsService()
    var services: Services! = YXNewStockService()
    
    init() {
        
        deliverResponse = {
            [weak self] (response) in
            guard let strongSelf = self else { return }
            switch response {
            case .success(let result, let code):
                if code == .success, let model = result.data {
                    
                    strongSelf.deliverModel = model
                    strongSelf.deliverSubject.onNext((true, nil))
                } else if let msg = result.msg {
                    strongSelf.deliverSubject.onNext((false, msg))
                } else {
                    strongSelf.deliverSubject.onNext((false, nil))
                }
                
            case .failed(let error):
                log(.error, tag: kNetwork, content: "\(error)")
                strongSelf.deliverSubject.onNext((false, YXLanguageUtility.kLang(key: "common_net_error")))
            }
        }
        
        purchaseNormalResponse = {
            [weak self] (response) in
            guard let strongSelf = self else { return }
            switch response {
            case .success(let result, let code):
                if code == .success, let model = result.data {
                    
                    for m in model.list ?? [] {
                        if m.financingAccountDiff ?? 0 > 1 {
                            strongSelf.financingAccountDiff = true
                        }
                    }
                    strongSelf.purchaseNormalModel = model
                    strongSelf.purchaseNormalSubject.onNext((true, nil))
                } else if let msg = result.msg {
                    strongSelf.purchaseNormalSubject.onNext((false, msg))
                } else {
                    strongSelf.purchaseNormalSubject.onNext((false, nil))
                }
            case .failed(let error):
                log(.error, tag: kNetwork, content: "\(error)")
                strongSelf.purchaseNormalSubject.onNext((false, YXLanguageUtility.kLang(key: "common_net_error")))
            }
        }
        
        premarketResponse = {
            [weak self] (response) in
            guard let strongSelf = self else { return }
            switch response {
            case .success(let result, let code):
                if code == .success, let model = result.data {
                    if let list = model.list, list.count > 0 {
                        strongSelf.premarketList = list
                    }
                    strongSelf.premarketSubject.onNext((true, nil))
                } else if let msg = result.msg {
                    strongSelf.premarketSubject.onNext((false, msg))
                } else {
                    strongSelf.premarketSubject.onNext((false, nil))
                }
                
            case .failed(let error):
                log(.error, tag: kNetwork, content: "\(error)")
                strongSelf.premarketSubject.onNext((false, YXLanguageUtility.kLang(key: "common_net_error")))
            }
        }
    }
}
