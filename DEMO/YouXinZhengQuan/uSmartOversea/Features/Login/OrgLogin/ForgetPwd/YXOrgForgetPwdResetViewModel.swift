//
//  YXOrgForgetPwdResetViewModel.swift
//  uSmartOversea
//
//  Created by 欧冬冬 on 2022/4/14.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator

class YXOrgForgetPwdResetViewModel: HUDServicesViewModel {
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    typealias Services = HasYXLoginService
    var navigator: NavigatorServicesType!

    let codeSubject = PublishSubject<String>()

    var sendCode: (() -> Void)? //block 发送验证码
    var callBack: (([String]) -> Void)? //没有实现
    var isSecure = false
    
    var isEmail = false
    var captcha = BehaviorRelay<String>(value: "")
    var password = BehaviorRelay<String>(value: "")

    /*校验手机验证码是否正确（用户输入手机号）
     type 业务类型（101用户注册102重置密码）
     check-captcha-with-phone/v1 */
    var checkUserInputCaptchaResponse: YXResultResponse<JSONAny>?
    var sendUserInputCaptchaResponse: YXResultResponse<JSONAny>?//发送验证码 响应

    let resetSuccessSubject = PublishSubject<Bool>()
        
    var forgetPwdResponse: YXResultResponse<JSONAny>?
    
    var services: Services! {
        didSet {
            //发送验证码 响应
            sendUserInputCaptchaResponse  = { [weak self] (response) in
                guard let strongSelf = self else {return}
                
                strongSelf.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    if code == .success || code == .authCodeRepeatSent {
                        if let dic = result.data?.value as? Dictionary<AnyHashable, Any> {
                            if let captcha = dic["captcha"] as? String {
                                strongSelf.codeSubject.onNext(captcha)
                            } else {
                                strongSelf.codeSubject.onNext(result.msg ?? "")
                            }
                        } else {
                            strongSelf.codeSubject.onNext(result.msg ?? "")
                        }
                    }  else if let msg = result.msg  {
                        strongSelf.hudSubject.onNext(.error(msg, false))
                    }
                case .failed(_):
                    strongSelf.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
            
            forgetPwdResponse = { [weak self] (response) in
                
                self?.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    if code == .success {
                        self?.resetSuccessSubject.onNext(true)
                    } else if code == .codeTimeout {
                        
                        if let msg = result.msg {
                            self?.hudSubject?.onNext(.error(msg, true))
                        }
                        
                   }  else if let msg = result.msg  {
                        self?.hudSubject.onNext(.error(msg, false))
                    }
                case .failed(_):
                    self?.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
        }
    }
    
    var phone = ""
    var code = ""
    var email = ""//邮箱
    
    var sourceVC: UIViewController?
    init(withCode code:String, phone: String, email: String,  isEmail: Bool, isSecure: Bool, callBack: @escaping ([String])->Void, sourceVC:UIViewController?) {
        self.phone = phone
        self.email = email
        self.code = code
        self.isEmail = isEmail
        self.callBack = callBack
        self.isSecure = isSecure
        self.sourceVC = sourceVC
    }
}
