//
//  YXChangeEmailViewModel.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/12.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import URLNavigator

enum YXEmailChangeType {
    case bind
    case change
}

class YXChangeEmailViewModel: HUDServicesViewModel  {

    typealias Services = HasYXUserService & HasYXLoginService
    var navigator: NavigatorServicesType!
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    var title : String = ""
    var changeType : YXEmailChangeType = .change
    
  
    let lockedSubject = PublishSubject<String>()
    let freezeSubject = PublishSubject<String>()
    
    let changeSuccessSubject = PublishSubject<Bool>()
    var changeEmailResponse: YXResultResponse<JSONAny>?
    
  
    var emailRelay = BehaviorRelay<String>.init(value: "")
    var pwdRelay = BehaviorRelay<String>.init(value: "")
    var captchaRelay = BehaviorRelay<String>.init(value: "")
    var everythingValid : Observable<Bool>?
    var emailValid : Observable<Bool>?
    
    var sendCaptchaResponse: YXResultResponse<JSONAny>?
    let codeSubject = PublishSubject<String>()//token-send-phone-captcha/v1接口的成功处理
    var vc:UIViewController?
    var bindCallBack: (([String: Any])->Void)?
    

    
    
    var services: Services! {
        didSet {
            
            sendCaptchaResponse =  { [weak self] (response) in
                guard let strongSelf = self else { return }
                strongSelf.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?,
                         .authCodeRepeatSent?:
                        if let dic = result.data?.value as? Dictionary<AnyHashable, Any> {
                            if let captcha = dic["captcha"] as? String {
                                strongSelf.codeSubject.onNext(captcha)
                            } else {
                                strongSelf.codeSubject.onNext("")
                            }
                        } else {
                            strongSelf.codeSubject.onNext("")
                        }
                    default:
                        if let msg = result.msg {
                            strongSelf.hudSubject.onNext(.error(msg, false))
                        }
                    }
                case .failed(_):
                    strongSelf.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
            
            changeEmailResponse =  { [weak self] (response) in
                
                self?.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    
                    switch code {
                    case .success?:
                        YXUserManager.getUserInfo(complete: nil)
                       // self?.hudSubject.onNext(.success(YXLanguageUtility.kLang(key: "更换成功"), true))
                        
                        //发送通知
                        NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiUpdateUserInfo), object: nil)
                        self?.changeSuccessSubject.onNext(true)
                        //绑定回调
//                        if let bindCallBack = self?.bindCallBack {
//                            bindCallBack(YXUserManager.userInfo)
//                        }
                    case .accountLockout?:
                        if let msg = result.msg {
                            self?.lockedSubject.onNext(msg)
                        }
                    case .accountFreeze?:
                        if let msg = result.msg {
                            self?.freezeSubject.onNext(msg)
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
            
        }
    }
    
    func bindView(){
        emailValid = emailRelay.asObservable().map{ $0.isValidEmail() }.share(replay: 1)
        let captchaValid = captchaRelay.asObservable().map { $0.count > 0 }.share(replay: 1)
        let pwdValid = pwdRelay.asObservable().map { $0.count > 0 }.share(replay: 1)
        everythingValid = Observable.combineLatest(emailValid!, captchaValid, pwdValid).map{ $0 && $1 && $2}.share(replay: 1)
    }
    
    init(_ type:YXEmailChangeType,sourceVC:UIViewController?,callBack: (([String: Any])->Void)?) {
        self.changeType = type
        self.vc = sourceVC
        self.bindCallBack = callBack
        if type == .bind {
            self.title = YXLanguageUtility.kLang(key: "mine_bind_email")
        }else {
            self.title = YXLanguageUtility.kLang(key: "mine_change_email")
        }
        bindView()
    }
}
