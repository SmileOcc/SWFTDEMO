//
//  YXNewStockUSConfirmViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/11/14.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator

class YXNewStockUSConfirmViewModel: HUDServicesViewModel {
    typealias Services = YXNewStockService
    
    var navigator: NavigatorServicesType!
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    let alertSubject = PublishSubject<Bool>()
    
    var sourceParam: YXPurchaseDetailParams!
    //响应回调

    //Rx代理回调
    typealias resultType = (userName: String?, msg: String?)
    let resultSubject = PublishSubject<resultType>()
    var resultResponse: YXResultResponse<YXLoginUser2>?
    
    var signatureResponse: YXResultResponse<JSONAny>?
    var signatureSubject = PublishSubject<(Bool, String?)>()
    
    var services: Services! = YXNewStockService()
    var userService = YXUserService()

    init() {
   
        
        resultResponse =  { [weak self] (response) in
            guard let strongSelf = self else { return }
            strongSelf.hudSubject.onNext(.hide)
            
            switch response {
            case .success(let result, let code):
                if code == .success, let model = result.data, let name = model.userAutograph {
                    //认购股数/金额
                    strongSelf.resultSubject.onNext((name, nil))
                } else if let msg = result.msg {
                    strongSelf.resultSubject.onNext((nil, msg))
                }
            case .failed(let error):
                log(.error, tag: kNetwork, content: "\(error)")
                strongSelf.resultSubject.onNext((nil, YXLanguageUtility.kLang(key: "common_net_error")))
            }
        }
        
        signatureResponse =  { [weak self] (response) in
            guard let strongSelf = self else { return }
            strongSelf.hudSubject.onNext(.hide)
            
            switch response {
            case .success(let result, let code):
                if code == .success {
                    //认购股数/金额
                    strongSelf.signatureSubject.onNext((true, nil))
                } else if let msg = result.msg {
                    strongSelf.signatureSubject.onNext((false, msg))
                }
            case .failed(let error):
                log(.error, tag: kNetwork, content: "\(error)")
                strongSelf.signatureSubject.onNext((false, YXLanguageUtility.kLang(key: "common_net_error")))
            }
        }
        
    }

}
