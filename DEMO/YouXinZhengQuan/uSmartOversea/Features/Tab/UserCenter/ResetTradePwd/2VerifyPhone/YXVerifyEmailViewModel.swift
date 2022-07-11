//
//  YXVerifyPhoneViewModel.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/12.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import URLNavigator


class YXVerifyEmailViewModel: HUDServicesViewModel  {
   
    typealias Services = HasYXUserService
    var navigator: NavigatorServicesType!
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    var sendCaptchaResponse: YXResultResponse<JSONAny>?
    let codeSubject = PublishSubject<String>()
    /* 校验手机验证码是否正确
     type: 业务类型（201重置交易密码短信验证202更换手机号短信验证）
     check-phone-captcha/v1 */
    var checkCaptchaResponse: YXResultResponse<JSONAny>?
    let checkSubject = PublishSubject<Bool>()
    
    var captcha = BehaviorRelay<String>.init(value: "")
    var vc: UIViewController?
    
    var services: Services! {
        didSet {
            
            sendCaptchaResponse = {[weak self] (response) in
                
                self?.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        if let dic = result.data?.value as? Dictionary<AnyHashable, Any> {
                            if let captcha = dic["captcha"] as? String {
                                self?.codeSubject.onNext(captcha)
                            } else {
                                self?.codeSubject.onNext("")
                            }
                        } else {
                            self?.codeSubject.onNext("")
                        }
                        break
                    default:
                        if let msg = result.msg {
                            self?.hudSubject.onNext(.error(msg, false))
                        }
                    }
                case .failed(_):
                    self?.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
            /* 校验手机验证码是否正确
             type: 业务类型（201重置交易密码短信验证202更换手机号短信验证）
             check-phone-captcha/v1 */
            checkCaptchaResponse = {[weak self] (response) in
                
                self?.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        self?.checkSubject.onNext(true)                       
                        break
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

    init(vc: UIViewController?) {
        self.vc = vc
    }
}
