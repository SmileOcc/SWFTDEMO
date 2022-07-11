//
//  YXNewStockECMListDetailViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/10/22.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator

class YXNewStockECMListDetailViewModel: HUDServicesViewModel {
    typealias Services = YXNewStockService
    
    var navigator: NavigatorServicesType!
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    let alertSubject = PublishSubject<Bool>()
    var exchangeType: YXExchangeType = .hk
    //更新状态
    var isRefeshing: Bool = false
    
    var services: Services! = YXNewStockService()
    var model: YXNewStockPurchaseDetailModel?
    //响应回调
    var resultResponse: YXResultResponse<YXNewStockPurchaseDetailModel>?
    var cancelResponse: YXResultResponse<YXNewStockPurchaseCancellModel>?
    var compensateResponse: YXResultResponse<YXNewStockECMCompensateModel>?
    
    //Rx代理回调
    typealias resultType = (isSuccess: Bool, msg: String?)
    let resultSubject = PublishSubject<resultType>()
    let cancelSubject = PublishSubject<(Int?, String?)>()
    let compensateSubject = PublishSubject<YXNewStockECMCompensateModel?>()
    init() {
        resultResponse = {
            [weak self] (response) in
            guard let strongSelf = self else { return }
            strongSelf.hudSubject.onNext(.hide)
            switch response {
            case .success(let result, let code):
                if code == .success, let model = result.data {
                    strongSelf.model = model
                    strongSelf.resultSubject.onNext((true, nil))
                } else if let msg = result.msg {
                    strongSelf.resultSubject.onNext((false, msg))
                }
                
            case .failed(let error):
                log(.error, tag: kNetwork, content: "\(error)")
                strongSelf.resultSubject.onNext((false, YXLanguageUtility.kLang(key: "common_net_error")))
            }
        }
        
        cancelResponse = {
            [weak self] (response) in
            guard let strongSelf = self else { return }
            strongSelf.hudSubject.onNext(.hide)
            switch response {
            case .success(let result, let code):
                if code == .success {
                    strongSelf.cancelSubject.onNext((1, YXLanguageUtility.kLang(key: "newStock_cancel_success")))
                } else if code == .tradePwdInvalid {
                    strongSelf.cancelSubject.onNext((0, nil))
                } else if let msg = result.msg {
                    strongSelf.cancelSubject.onNext((nil, msg))
                }
            case .failed(let error):
                log(.error, tag: kNetwork, content: "\(error)")
                strongSelf.cancelSubject.onNext((nil, YXLanguageUtility.kLang(key: "newStock_cancel_fail")))
            }
        }
        
        compensateResponse = {
            [weak self] (response) in
            guard let strongSelf = self else { return }
            strongSelf.hudSubject.onNext(.hide)
            switch response {
            case .success(let result, let code):
                if code == .success, let model = result.data {
                    strongSelf.compensateSubject.onNext(model)
                } else if let _ = result.msg {
                    strongSelf.compensateSubject.onNext(nil)
                }
                
            case .failed(_):
                strongSelf.compensateSubject.onNext(nil)
            }
        }
    }
}
