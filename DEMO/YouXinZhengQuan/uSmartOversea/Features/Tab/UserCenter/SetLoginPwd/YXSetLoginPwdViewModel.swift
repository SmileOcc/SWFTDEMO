//
//  YXSetLoginPwdViewModel.swift
//  uSmartOversea
//
//  Created by rrd on 2019/5/13.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import URLNavigator

class YXSetLoginPwdViewModel: HUDServicesViewModel {

    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    typealias Services = HasYXUserService
    var navigator: NavigatorServicesType!
    
    var sendCaptcha: (() -> Void)!
    /*获取手机验证码(默认用户手机号)
     type:业务类型（201 重置交易密码短信 202 更换手机号 203 设置登录密码）
     token-send-phone-captcha/v1  */
    var sendCaptchaResponse: YXResultResponse<JSONAny>?
    let codeSubject = PublishSubject<String>()//token-send-phone-captcha/v1接口的成功处理
    
    /* 设置登陆密码 post
     set-login-password/v1  */
    var setLoginPwdResponse: YXResultResponse<JSONAny>?
    let lockedSubject = PublishSubject<String>()
    let freezeSubject = PublishSubject<String>()
    let setLoginPwdSuccessSubject = PublishSubject<Bool>()
    
    var pwd = Variable<String>("")
    var captcha = Variable<String>("")
    
    var services: Services! {
        didSet {
            /*获取手机验证码(默认用户手机号)
             type:业务类型（201 重置交易密码短信 202 更换手机号 203 设置登录密码）
             token-send-phone-captcha/v1  */
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
            /* 设置登陆密码 post
             set-login-password/v1  */
            setLoginPwdResponse = { [weak self] (response) in
                
                guard let strongSelf = self else { return }
                strongSelf.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    
                    switch code {
                    case .success?:
                        strongSelf.setLoginPwdSuccessSubject.onNext(true)
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
    
    init() {
        
    }
}
