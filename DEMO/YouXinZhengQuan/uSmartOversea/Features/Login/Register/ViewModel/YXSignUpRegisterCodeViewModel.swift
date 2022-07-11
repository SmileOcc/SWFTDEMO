//
//  YXSignUpRegisterCodeViewModel.swift
//  uSmartOversea
//
//  Created by 欧冬冬 on 2022/6/2.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YXKit
import URLNavigator

class YXSignUpRegisterCodeViewModel: HUDServicesViewModel {
    var navigator: NavigatorServicesType!
    

    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    typealias Services = HasYXLoginService & HasYXAggregationService & HasYXUserService
    
    var mobile = BehaviorRelay<String>(value: "")//手机号
    var email = BehaviorRelay<String>(value: "")
    var areaCode = BehaviorRelay<String>(value: YXUserManager.shared().defCode)//区号
    var captcha = BehaviorRelay<String>(value: "")//验证码
    var inviteCode = BehaviorRelay<String>(value: "")
    
    var sendUserInputCaptchaResponse: YXResultResponse<YXCommonCodeModel>?
    var captchaRegisterAggResponse: YXResultResponse<YXLoginUser>?
    let codeSubject = PublishSubject<(Bool,String)>()
    let hasRegisterSubject = PublishSubject<String>()//已注册
    let registerSMSErrorSubject = PublishSubject<String>()//验证码错误
    
    let loginSuccessSubject = PublishSubject<Bool>()//登录成功的回调

    var accoutType = BehaviorRelay<YXMemberAccountType>(value: .email)

    var loginCallBack: (([String: Any])->Void)?
    var vc: UIViewController?
    var sendCaptchaType:YXSendCaptchaType = .type106
    let disposebag = DisposeBag()
    
    var services: Services! {
        didSet {
            /*MARK: 获取手机验证码(用户输入手机号)
             type 验证码类型 101注册 102重置密码 103更换手机号 104绑定手机号 105新设备登录校验 106短信登录
             send-phone-captcha/v1 */
            sendUserInputCaptchaResponse  = { [weak self] (response) in
                
                self?.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    if code == .success || code == .authCodeRepeatSent {
                        if let captcha = result.data?.captcha {
                            self?.codeSubject.onNext((true,captcha))
                        } else if let msg = result.msg {
                            self?.codeSubject.onNext((false,msg))
                        }
                    } else if let msg = result.msg {
                        self?.hudSubject.onNext(.error(msg, false))
                    }
                case .failed(_):
                    self?.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
            
            /*MARK: 验证码校验 */
            captchaRegisterAggResponse = { [weak self] (response) in
                guard let `self` = self else { return }
                self.hudSubject.onNext(.hide)
                
                
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                    
                        //校验成功去注册账号（本来是去设置密码的，😅）
                        let pwdSetModel = YXSignUpSetPwdViewModel(withCode: self.areaCode.value, captcha: self.captcha.value, phone: self.mobile.value, email: self.email.value, invite: self.inviteCode.value, vc: self.vc, loginCallBack: self.loginCallBack)
                        let context = YXNavigatable(viewModel: pwdSetModel)
                        self.navigator.push(YXModulePaths.normalRegisterSetPwd.url, context: context, animated: true)
                        
                    case .aggregationError?,
                         .aggregationHalfError?,
                         .aggregationUserError?,
                         .aggregationStockError?,
                         .aggregationProductError?,
                         .aggregationInfoError?,
                         .aggregationLoginError?,
                         .aggregationRegistError?,
                         .aggregationMoneyError?,
                         .aggregationPermissionsError?,
                         .aggregationWechatError?,
                         .aggregationWeiboError?:
                        self.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                        break
                    case .mobileHasRegisted?,
                         .emailHasRegisted?,
                         .userPhoneHasRegistered?,
                         .userEmialHasRegistered:
                        if let msg = result.msg {
                            self.hasRegisterSubject.onNext(msg)
                        }
                    case .registePhoneSMSError?,
                         .registeEmailCodeError?:
                        if let msg = result.msg {
                            self.registerSMSErrorSubject.onNext(msg)
                        }
                    default:
                        if let msg = result.msg {
                           // self.hudSubject.onNext(.error(msg, false))
                            YXProgressHUD.showSuccess(msg)
                        }
                    }
                case .failed(_):
                    YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "common_net_error"))
                    //self.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
            
        }
    }
    
    init(withCode code:String=YXUserManager.shared().defCode, captcha: String = "", phone: String = "", email: String = "", invite: String = "", sendCaptchaType:YXSendCaptchaType, vc: UIViewController?, loginCallBack: (([String: Any])->Void)?) {
        self.mobile.accept(phone)
        self.email.accept(email)
        self.areaCode.accept(code)
        self.captcha.accept(captcha)
        self.inviteCode.accept(invite)
        self.sendCaptchaType = sendCaptchaType
        self.vc = vc
        if !email.isEmpty {
            accoutType.accept(.email)
        } else {
            accoutType.accept(.mobile)
        }
        self.loginCallBack = loginCallBack
    }
    
    func sendCodeRequest() {
        hudSubject?.onNext(.loading(nil, false))
        if !self.email.value.isEmpty {
            services.loginService.request(.checkAccountRegistNumber(YXUserManager.safeDecrypt(string: email.value), ""), response: sendUserInputCaptchaResponse).disposed(by: disposebag)
        } else {
            services.loginService.request(.checkAccountRegistNumber(YXUserManager.safeDecrypt(string: mobile.value), areaCode.value), response: sendUserInputCaptchaResponse).disposed(by: disposebag)
        }
    }
    
    func signUpRequest() {
        
        hudSubject?.onNext(.loading(nil, false))
        if !self.email.value.isEmpty {
            services.userService.request(.registerCheckEmailCaptcha(captcha.value, type:.type10001, email: email.value), response: captchaRegisterAggResponse).disposed(by: disposebag)
        } else {
            services.loginService.request(.checkUserInputCaptcha(areaCode.value, YXUserManager.safeDecrypt(string:mobile.value), captcha.value, 101), response: captchaRegisterAggResponse).disposed(by: disposebag)
        }
    }
    
    func gotoLogin() {
        let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: loginCallBack, cancelCallBack: nil, vc: self.vc, mobile: mobile.value, email: email.value, accoutType: accoutType.value,areacode:areaCode.value))
        navigator.push(YXModulePaths.defaultLogin.url, context: context)
    }
}
