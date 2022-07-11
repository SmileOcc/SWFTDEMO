//
//  YXForgetPwdPhoneViewModel.swift
//  uSmartOversea
//
//  Created by mac on 2019/3/27.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator

class YXForgetPwdPhoneViewModel: HUDServicesViewModel  {
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    typealias Services = HasYXLoginService
    
    var navigator: NavigatorServicesType!

    
    /*获取验证码
     type 验证码类型 101注册 102重置密码 103更换手机号 104绑定手机号 105新设备登录校验 106短信登录 10001-邮箱注册
     /send-email-captcha/v1
     /send-email-captcha/v1
     */
    var sendUserInputCaptchaResponse: YXResultResponse<YXCommonCodeModel>?
    
    var resetPwdResponse: YXResultResponse<JSONAny>?
    
    let unRegiestSubject = PublishSubject<String>() //手机号码没有注册过 的响应
    let eCodeSubject = PublishSubject<(Bool,String)>()
    let mCodeSubject = PublishSubject<(Bool,String)>()
    let resetSuccessSubject = PublishSubject<Bool>()
    var isLogin:Bool = true
    
    var services: Services! {
        didSet {
            sendUserInputCaptchaResponse  = { [weak self] (response) in
                self?.hudSubject.onNext(.hide)
                switch response {
                case .success(let result, let code):
                    if code == .success {
                        if let captcha = result.data?.captcha {
                            if self?.accoutType.value == .email{
                                self?.mCodeSubject.onNext((true,captcha))
                            }else{
                                self?.eCodeSubject.onNext((true,captcha))
                            }
                        } else if let msg = result.msg {
                            if self?.accoutType.value == .email {
                                self?.mCodeSubject.onNext((false,msg))
                            }else {
                                self?.eCodeSubject.onNext((false,msg))
                            }
                        }
                    }else if code == .emaliNoRegist || code == .mobileNoRegist {
                        if let msg = result.msg {
                            self?.unRegiestSubject.onNext(msg)
                        }
                    }else if let msg = result.msg {
                       // self?.hudSubject.onNext(.error(msg, false))
                        YXProgressHUD.showSuccess(msg)
                    }
                case .failed(_):
                    YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "common_net_error"))
                   // self?.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
            resetPwdResponse = { [weak self] (response) in
                self?.hudSubject.onNext(.hide)
                switch response {
                case .success(let result, let code):
                    if code == .success {
                        self?.resetSuccessSubject.onNext(true)
                    }else if code == .accountUnregistered || code == .accountUnSignup ,let msg = result.msg{//帐号未注册
                        self?.unRegiestSubject.onNext(msg)
                    }else if let msg = result.msg  {
                        YXProgressHUD.showSuccess(msg)
                        //self?.hudSubject.onNext(.error(msg, false))
                    }
                case .failed(_):
                    YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "common_net_error"))
                   // self?.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }

        }
    }
    
   
    var callBack: (([String]) -> Void)?
    var loginCallBack: (([String: Any])->Void)?
    var sourceVC: UIViewController? //sourceVC
    var fromVC: UIViewController?
    var isClear = false  //带入的手机号，是否被清除了。默认为false
    
    var mobileHidden = PublishSubject<Bool>()
    var emailHidden = PublishSubject<Bool>()
    var mUsernameValid : Observable<Bool>?
    var mVerCodeValid : Observable<Bool>?
    var mEverythingValid : Observable<Bool>?
    var eUsernameValid : Observable<Bool>?
    var eVerCodeValid : Observable<Bool>?
    var eEverythingValid : Observable<Bool>?
    var mPassWordValid : Observable<Bool>?
    var ePassWordValid : Observable<Bool>?
    
    var accoutType = BehaviorRelay<YXMemberAccountType>(value: .email)
    var mobile = BehaviorRelay<String>(value: "")
    var email = BehaviorRelay<String>(value: "")
    
    var eCaptcha = BehaviorRelay<String>(value: "")//email验证码
    var mCaptcha = BehaviorRelay<String>(value: "")//mobeil 验证码
    var areaCode = BehaviorRelay<String>(value: YXUserManager.shared().defCode)
    var mPwd = BehaviorRelay<String>(value: "")
    var ePwd = BehaviorRelay<String>(value: "")
    let disposebag = DisposeBag()
    
    init(with code:String, phone:String, isLogin: Bool,
         callBack: (([String])->Void)?,
         loginCallBack: (([String: Any])->Void)?,
         fromVC: UIViewController?,
         sourceVC:UIViewController?,
         email:String="",
         accoutType:YXMemberAccountType=YXMemberAccountType.mobile) {
        self.callBack = callBack
        self.loginCallBack = loginCallBack
        self.sourceVC = sourceVC
        self.fromVC = fromVC
        self.isLogin = isLogin
        
        self.accoutType.subscribe(onNext:{ [weak self]type in
            if type == .email {
                self?.mobileHidden.onNext(false)
                self?.emailHidden.onNext(true)
            }else {
                self?.mobileHidden.onNext(true)
                self?.emailHidden.onNext(false)
            }
        }).disposed(by: disposebag)
        
        if accoutType == .email {
            self.accoutType.accept(.mobile)
        }else{
            self.accoutType.accept(.email)
        }
        
        self.mobile.accept(phone)
        self.email.accept(email)
        self.areaCode.accept(code)
        self.handleEmailInput()
        self.handleMobInput()
    }
    
    func handleMobInput(){
        self.mUsernameValid = mobile.asObservable()
                    .map { $0.count > 0 }
                    .share(replay: 1)
        self.mVerCodeValid = mCaptcha.asObservable()
                    .map { $0.count > 0 }
                    .share(replay: 1)
//        self.mPassWordValid = mPwd.asObservable()
//            .map { $0.isValidPwd() && $0.count >= 8 && $0.count <= 20 || $0.count == 0}
//            .share(replay: 1)
//        let passTmp =  mPwd.asObservable()
//            .map { $0.isValidPwd() && $0.count >= 8 && $0.count <= 20 }
//            .share(replay: 1)
        
        self.mPassWordValid = mPwd.asObservable()
            .map {  $0.count >= 0}
            .share(replay: 1)
        let passTmp =  mPwd.asObservable()
            .map {  $0.count > 0 }
            .share(replay: 1)
        
        self.mEverythingValid = Observable.combineLatest(mUsernameValid!, mVerCodeValid!,passTmp) { $0 && $1 && $2 }
                    .share(replay: 1)
    }
    
    func handleEmailInput() {
        self.eUsernameValid = email.asObservable()
                    .map { $0.isValidEmail() }
                    .share(replay: 1)
        self.eVerCodeValid = eCaptcha.asObservable()
                    .map { $0.count > 0 }
                    .share(replay: 1)
//        self.ePassWordValid = ePwd.asObservable()
//                    .map { $0.isValidPwd() && $0.count >= 8 && $0.count <= 20 || $0.count == 0}
//                    .share(replay: 1)
//        let passTmp =  ePwd.asObservable()
//            .map { $0.isValidPwd() && $0.count >= 8 && $0.count <= 20 }
//            .share(replay: 1)
        
        self.ePassWordValid = ePwd.asObservable()
                    .map { $0.count >= 0}
                    .share(replay: 1)
        let passTmp =  ePwd.asObservable()
            .map {  $0.count > 0 }
            .share(replay: 1)
        
        self.eEverythingValid = Observable.combineLatest(eUsernameValid!, eVerCodeValid!,passTmp) { $0 && $1 && $2 }
                    .share(replay: 1)
    }
    
    func handelAccountChanage(title:String)  {
        if title == YXLanguageUtility.kLang(key: "verify_mobile") {
            accoutType.accept(.mobile)
        }else{
            accoutType.accept(.email)
        }
    }
    
    func sendMobileCodeRequest()  {
        hudSubject?.onNext(.loading(nil, false))
        let phoneNumber = YXUserManager.safeDecrypt(string:mobile.value)
        services.loginService.request(.sendUserInputCaptcha(areaCode.value, phoneNumber, .type102), response: sendUserInputCaptchaResponse).disposed(by: disposebag)
    }
    
    func sendEmailCodeRequest(){
        hudSubject?.onNext(.loading(nil, false))
        services.loginService.request(.sendEmailInputCaptcha(email.value, .type2), response: sendUserInputCaptchaResponse).disposed(by: disposebag)
    }
    
    func mobileVerifyRequest()  {
        hudSubject?.onNext(.loading(nil, false))
        services.loginService.request(.resetPwd(areaCode.value, YXUserManager.safeDecrypt(string:mobile.value), mCaptcha.value,YXUserManager.safeDecrypt(string: mPwd.value)),response: resetPwdResponse).disposed(by: disposebag)
    }
    
    func emailVerifyRequest(){
        hudSubject?.onNext(.loading(nil, false))
        services.loginService.request(.emailResetPwd(YXUserManager.safeDecrypt(string:email.value), eCaptcha.value, YXUserManager.safeDecrypt(string:ePwd.value)),response: resetPwdResponse).disposed(by: disposebag)
    }
    
    func gotoRegister() {
        let type = accoutType.value == .email ? YXMemberAccountType.mobile : YXMemberAccountType.email
        let phone = mobile.value
        let context = YXNavigatable(viewModel: YXSignUpViewModel(withCode: areaCode.value, phone: phone, sendCaptchaType: .type101, vc: self.sourceVC, loginCallBack: loginCallBack,email:email.value, accoutType: type))
        navigator.push(YXModulePaths.signUp.url, context: context)
    }
    
    func canChangeType()-> Bool{
        if self.isLogin{
            if let _ = YXUserManager.shared().curLoginUser?.areaCode,let _ = YXUserManager.shared().curLoginUser?.email {
                return true
            }
            return false
        }
        return true
    }
    
}
