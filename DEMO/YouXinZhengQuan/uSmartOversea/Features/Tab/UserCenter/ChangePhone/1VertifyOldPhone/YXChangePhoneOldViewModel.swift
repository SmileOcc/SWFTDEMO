//
//  YXChangePhoneOldViewModel.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/12.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator

class YXChangePhoneOldViewModel:  HUDServicesViewModel  {

    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    typealias Services = HasYXUserService
    var navigator: NavigatorServicesType!

    let codeSubject = PublishSubject<String>()
    
    var sendCaptcha: (() -> Void)!
    
    var sendCaptchaResponse: YXResultResponse<JSONAny>?
    /*校验更换手机号验证码
     verify-replace-phone/v1 */
    var verifyChangePhoneResponse: YXResultResponse<JSONAny>?
    
    let lockedSubject = PublishSubject<String>()
    let freezeSubject = PublishSubject<String>()
    
    
    var services: Services! {
        didSet {
            
            sendCaptchaResponse =  { [weak self] (response) in
                
                self?.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    var showMsg = false
                    switch code {
                    case .success?,
                         .authCodeRepeatSent?:
                        if let dic = result.data?.value as? Dictionary<AnyHashable, Any> {
                            if let captcha = dic["captcha"] as? String {
                                self?.codeSubject.onNext(captcha)
                            } else {
                                self?.codeSubject.onNext("")
                                showMsg = true
                            }
                        } else {
                            self?.codeSubject.onNext("")
                            showMsg = true
                        }
                    default:
                        showMsg = true
                    }
                    if showMsg {
                        if let msg = result.msg {
                            self?.hudSubject.onNext(.error(msg, true))
                        }
                    }
                case .failed(_):
                    self?.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
            /*校验更换手机号验证码
             verify-replace-phone/v1 */
            verifyChangePhoneResponse = { [weak self] (response) in
                
                guard let strongSelf = self else { return }
                strongSelf.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    
                    switch code {
                    case .success?:
                        if code == .success {
//                            let context : [AnyHashable : Any] = [
//                                "navigatable" : YXNavigatable(viewModel: YXChangePhoneNewViewModel(callBack: strongSelf.sendCaptcha))
//                            ]
                            let context = YXNavigatable(viewModel: YXChangePhoneNewViewModel(callBack: strongSelf.sendCaptcha))
                            strongSelf.navigator.push(YXModulePaths.changePhoneNew.url, context: context)
                        } else if let msg = result.msg {
                            strongSelf.hudSubject.onNext(.error(msg, false))
                        }
                    case .accountLockout?:
                        if let msg = result.msg {
                            strongSelf.lockedSubject.onNext(msg)
                        }
                    case .accountFreeze?:
                        if let msg = result.msg {
                            strongSelf.freezeSubject.onNext(msg)
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
        }
    }
    
    var pwdRelay = BehaviorRelay<String>.init(value: "")
    var captchaRelay = BehaviorRelay<String>.init(value: "")
    var everythingValid : Observable<Bool>?
    
    
    func bindView(){
        let captchaValid = captchaRelay.asObservable().map { $0.count > 0 }.share(replay: 1)
        let pwdValid = pwdRelay.asObservable().map { $0.count > 0 }.share(replay: 1)
        everythingValid = Observable.combineLatest(captchaValid, pwdValid).map{ $0 && $1}.share(replay: 1)
    }
    
    init() {
        bindView()
    }

}
