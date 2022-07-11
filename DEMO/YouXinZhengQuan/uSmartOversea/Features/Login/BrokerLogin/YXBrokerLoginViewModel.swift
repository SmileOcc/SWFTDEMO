//
//  YXBrokerLoginViewModel.swift
//  uSmartOversea
//
//  Created by ysx on 2021/11/10.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import URLNavigator

class YXBrokerLoginViewModel: HUDServicesViewModel {
    typealias Services = HasYXUserService
    var navigator: NavigatorServicesType!
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    var services: Services!
    
    var broker: YXBrokersBitType = .dolph
    var vc: UIViewController!
    
    var inputValid : Observable<Bool>?
    var pwdRelay = BehaviorRelay<String>(value: "")
    var clientIdRelay = BehaviorRelay<String>(value: "")
    
    var loginSucesSubject : PublishSubject<YXBrokerLoginResponseModel> = PublishSubject<YXBrokerLoginResponseModel>()
   
    var  isLoginSuccess  = false
    
    
    
    init(broker: YXBrokersBitType,vc:UIViewController?) {
        self.broker = broker
        self.vc = vc
        
        let clientIdValid = clientIdRelay.asObservable()
            .map{ $0.count > 0}
            .share(replay: 1)
        let pwdValid = pwdRelay.asObservable()
            .map{ $0.count > 0}
            .share(replay: 1)
        
        self.inputValid = Observable.combineLatest(clientIdValid, pwdValid) { $0 && $1 }
                    .share(replay: 1)
    }
    
    var loginSubject : Single<String> {
        Single<String>.create{ [weak self] (singel) -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            let requestModel = YXBrokerLoginRequestModel.init()
            requestModel.clientId = self.clientIdRelay.value
            requestModel.traderPassword =  YXUserManager.safeDecrypt(string: self.pwdRelay.value)
            requestModel.brokerNo = self.broker.brokerNo()
            let request = YXRequest.init(request: requestModel)
            request.requestHeaderFieldValueDictionary()
           
            request.startWithBlock { (response) in
                if response.code == .success , let res = response as? YXBrokerLoginResponseModel{
                    singel(.success(""))
                    self.loginSucesSubject.onNext(res)
                }else {
                    self.hudSubject.onNext(.hide)
                    YXProgressHUD.showError(response.msg)
                }
            } failure: { (req) in
                singel(.error(YXError.internalError(code: -1, message: YXLanguageUtility.kLang(key: "common_net_error"))))
            }
            return Disposables.create()
        }
    }
    
}
