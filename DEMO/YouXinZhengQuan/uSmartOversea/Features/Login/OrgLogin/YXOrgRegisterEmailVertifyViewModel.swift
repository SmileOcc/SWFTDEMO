//
//  YXOrgRegisterEmailVertifyViewModel.swift
//  uSmartOversea
//
//  Created by 欧冬冬 on 2022/4/21.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator

class YXOrgRegisterEmailVertifyViewModel: HUDServicesViewModel {
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    typealias Services = HasYXUserService
    var navigator: NavigatorServicesType!

    let codeSubject = PublishSubject<String>()

    var sendCode: (() -> Void)? //block 发送验证码
    var callBack: (([String]) -> Void)? //没有实现
    var isSecure = false
    
    var captcha = BehaviorRelay<String>(value: "")
    var captchaValid : Observable<Bool>?

    /*校验手机验证码是否正确（用户输入手机号）
     type 业务类型（101用户注册102重置密码）
     check-captcha-with-phone/v1 */
    var checkUserInputCaptchaResponse: YXResultResponse<JSONAny>?
    var sendUserInputCaptchaResponse: YXResultResponse<JSONAny>?//发送验证码 响应
    let checkAccountSubject = PublishSubject<Bool>() //已校验

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
            
            //发送验证码 响应
            checkUserInputCaptchaResponse  = { [weak self] (response) in
                guard let strongSelf = self else {return}
                strongSelf.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    if code == .success {
                        strongSelf.checkAccountSubject.onNext(true)
                    }  else if let msg = result.msg  {
                        strongSelf.hudSubject.onNext(.error(msg, false))
                    }
                case .failed(_):
                    strongSelf.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
        }
    }
    
    
    var sourceVC: UIViewController?
    init(vc: UIViewController?) {
        self.sourceVC = vc
        self.captchaValid = self.captcha.asObservable()
                    .map { $0.count > 0 }
                    .share(replay: 1)
    }
}
