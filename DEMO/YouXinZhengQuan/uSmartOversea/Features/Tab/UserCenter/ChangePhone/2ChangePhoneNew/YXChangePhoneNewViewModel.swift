//
//  YXChangePhoneNewViewModel.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/12.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import URLNavigator

class YXChangePhoneNewViewModel: HUDServicesViewModel  {

    typealias Services = HasYXUserService & HasYXLoginService
    var navigator: NavigatorServicesType!
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    var phone = Variable<String>("")
    var code = YXUserManager.shared().defCode
    
    let codeSubject = PublishSubject<String>()
    
    
    let serviceSubject = PublishSubject<Bool>()
    let timeoutSubject = PublishSubject<Bool>()
    
    var sendCaptchaResponse: YXResultResponse<JSONAny>?
    /*更换手机号
     replace-phone/v1 */
    var changePhoneResponse: YXResultResponse<JSONAny>?
    let changeSuccessSubject = PublishSubject<Bool>()
    
    var services: Services! {
        didSet {
            
            sendCaptchaResponse =  { [weak self] (response) in
                
                self?.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    
                    switch code {
                    case .success?,
                         .authCodeRepeatSent?:
                        if let dic = result.data?.value as? Dictionary<AnyHashable, Any> {
                            if let captcha = dic["captcha"] as? String {
                                self?.codeSubject.onNext(captcha)
                            } else {
                                self?.codeSubject.onNext("")
                            }
                        } else {
                            self?.codeSubject.onNext("")
                        }
                    default:
                        if let msg = result.msg {
                            self?.hudSubject.onNext(.error(msg, false))
                        }
                    }
                case .failed(_):
                    self?.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
            /*更换手机号
             replace-phone/v1 */
            changePhoneResponse =  { [weak self] (response) in
                
                self?.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    
                    switch code {
                    case .success?:
                        
                        self?.hudSubject.onNext(.message(YXLanguageUtility.kLang(key: "mine_change_success"), true))
                        YXUserManager.getUserInfo(complete: nil)
                        self?.changeSuccessSubject.onNext(true)
                                                
//                    case .changePhoneAccountExisting?:
//                        self?.serviceSubject.onNext(true)
//                    case .accountCheakTimeout?:
//                        self?.timeoutSubject.onNext(true)
                    default:
                        if let msg = result.msg {
                            self?.hudSubject.onNext(.error(msg, false))
                        }
                    }
                case .failed(_):
                    self?.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
            
        }
    }
    
    var areaCodeRelay  = BehaviorRelay<String>.init(value: YXUserManager.shared().defCode)
    var phoneRelay = BehaviorRelay<String>.init(value: "")
    var captchaRelay = BehaviorRelay<String>.init(value: "")
    var everythingValid : Observable<Bool>?
    var phoneValid : Observable<Bool>?
    
    
    func bindView(){
        phoneValid = phoneRelay.asObservable().map{ $0.count > 0 }.share(replay: 1)
        let captchaValid = captchaRelay.asObservable().map { $0.count > 0 }.share(replay: 1)
        everythingValid = Observable.combineLatest(phoneValid!, captchaValid).map{ $0 && $1 }.share(replay: 1)
    }
    
    var sendCode: (() -> Void)!
    
    init(callBack: @escaping () -> Void) {
        self.sendCode = callBack
        bindView()
    }
    
}
