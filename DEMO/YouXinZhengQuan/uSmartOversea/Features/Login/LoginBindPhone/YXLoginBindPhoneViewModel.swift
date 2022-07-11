//
//  YXLoginBindPhoneViewModel.swift
//  uSmartOversea
//
//  Created by rrd on 2019/5/13.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import URLNavigator

class YXLoginBindPhoneViewModel: HUDServicesViewModel {
    typealias Services = HasYXUserService & HasYXLoginService & HasYXAggregationService
    var navigator: NavigatorServicesType!
    
    /*获取验证码
     type 验证码类型 101注册 102重置密码 103更换手机号 104绑定手机号 105新设备登录校验 106短信登录 10001-邮箱注册
     /send-email-captcha/v1
     /send-email-captcha/v1
     */
    var sendUserInputCaptchaResponse: YXResultResponse<YXCommonCodeModel>?
    let eCodeSubject = PublishSubject<(Bool,String)>()
    let mCodeSubject = PublishSubject<(Bool,String)>()
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    /*验证手机号是否注册
     check-phone/v1 */
    var checkPhoneResponse: YXResultResponse<CheckPhoneV1Result>?//第一次绑定手机号
    let checkPhoneSuccessSubject = PublishSubject<Bool>()//绑定成功的回调   Bool:是否绑定过，
   
    /* 三方登录绑定手机号码聚合接口
     three-login-tel-aggregation/v1 */
    var threeTelAggResponse: YXResultResponse<YXLoginUser>? // 响应
    let threeTelAggSucSubject = PublishSubject<Bool>()//成功的处理
    let thirdPhoneBindedSubject = PublishSubject<(Bool, String)>() //三方登录：该手机号码已经被绑定了。
    let thirdEmailBindedSubject = PublishSubject<(Bool, String)>()  //三方登录：该手机号码已经通过ipad注册了。
    
    
    var services: Services! {
        didSet {
            /*验证手机号是否注册
             check-phone/v1 */
            //第一次绑定手机号
            checkPhoneResponse = {[weak self](response) in
                self?.hudSubject.onNext(.hide)
                switch response {
                case .success(let result, let code):
                    if code == .inputCorrectPhone, let msg = result.msg {
                        self?.hudSubject.onNext(.error(msg, false))
                    } else {
                        self?.checkPhoneSuccessSubject.onNext(false)
                    }
                case .failed(_):
                    YXProgressHUD.showError(YXLanguageUtility.kLang(key: "common_net_error"))
                   // self?.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
            /*MARK: 获取手机验证码(用户输入手机号)
             type 验证码类型 101注册 102重置密码 103更换手机号 104绑定手机号 105新设备登录校验 106短信登录
             send-phone-captcha/v1 */
            sendUserInputCaptchaResponse  = { [weak self] (response) in
                
                self?.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    if code == .success || code == .authCodeRepeatSent {
                        if let captcha = result.data?.captcha {
                            if self?.accoutType.value == .email{
                                self?.eCodeSubject.onNext((true,captcha))
                            }else{
                                self?.mCodeSubject.onNext((true,captcha))
                            }
                        } else if let msg = result.msg {
                            if self?.accoutType.value == .email {
                                self?.eCodeSubject.onNext((false,msg))
                            }else {
                                self?.mCodeSubject.onNext((false,msg))
                            }
                        }
                    }else if let msg = result.msg {
                        YXProgressHUD.showError(msg)
//                        self?.hudSubject.onNext(.error(msg, false))
                    }
                case .failed(_):
                    YXProgressHUD.showError(YXLanguageUtility.kLang(key: "common_net_error"))
                   // self?.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
            
            /* 三方登录绑定手机号码聚合接口
             three-login-tel-aggregation/v1 */
            threeTelAggResponse = {[weak self](response) in
                guard let `self` = self else {return}
                
                self.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code ):
                    switch code {
                    case .success?:
                        YXUserManager.setLoginInfo(user: result.data)
                        YXUserManager.shared().defCode = self.areaCode.value
                        let mmkv = MMKV.default()
                        mmkv.set(self.areaCode.value, forKey: YXUserManager.YXDefCode)
                        //通知 更新用户信息
                        NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiUpdateUserInfo), object: nil)
  
                        self.threeTelAggSucSubject.onNext(true)
                        if let loginCallBack = self.loginCallBack {
                            loginCallBack(YXUserManager.userInfo)
                        }
                    case .thirdLoginPhoneBinded?, .thirdLoginAlertOne?://该手机号码已经被绑定了。
                        if let msg = result.msg {
                            if self.accoutType.value == .mobile{
                                self.thirdPhoneBindedSubject.onNext((true, msg))
                            }else{
                                self.thirdEmailBindedSubject.onNext((true, msg))
                            }
                        }
                    default:
                        if let msg = result.msg {
                            //self.hudSubject.onNext(.error(msg, false))
                            YXProgressHUD.showError(msg)
                        }
                    }
                default:
                    YXProgressHUD.showError(YXLanguageUtility.kLang(key: "common_net_error"))
                   // self.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
        }
    }
    
//    var code = YXUserManager.shared().defCode //地区码
//    var phone = Variable<String>("")
    var vc: UIViewController?
    var loginCallBack: (([String: Any])->Void)?
    var sendCaptchaType : YXSendCaptchaType = .type106 //记录 【获取手机验证码(用户输入手机号)】 接口的 type
    
    
    // ---- 第三方登录的参数
    var accessToken = ""
    var openId = ""
    var appleUserId = ""
    var lineUserId = ""
    var appleParams: [String: Any] = [:]
    var thirdLoginType:YXThirdLoginType = .weChat
    var fillPhone: (([String]) -> Void)!
    
    var mobileHidden = PublishSubject<Bool>()
    var emailHidden = PublishSubject<Bool>()
    var mUsernameValid : Observable<Bool>?
    var mVerCodeValid : Observable<Bool>?
    var mPassWordValid : Observable<Bool>?
    var mEverythingValid : Observable<Bool>?
    var eUsernameValid : Observable<Bool>?
    var eVerCodeValid : Observable<Bool>?
    var eEverythingValid : Observable<Bool>?
    var ePassWordValid : Observable<Bool>?
    
    var accoutType = BehaviorRelay<YXMemberAccountType>(value: .email)
    var mobile = BehaviorRelay<String>(value: "")
    var email = BehaviorRelay<String>(value: "")
    
    var mPwd = BehaviorRelay<String>(value: "")
    var ePwd = BehaviorRelay<String>(value: "")
    var areaCode = BehaviorRelay<String>(value: YXUserManager.shared().defCode)
    
    var eCaptcha = BehaviorRelay<String>(value: "")//email验证码
    var mCaptcha = BehaviorRelay<String>(value: "")//mobeil 验证码
    let disposebag = DisposeBag()
    
    init(_ appleUserId:String,_ accessToken:String, _ openId:String, _ appleParmas: [String: Any], _ thirdLoginType:YXThirdLoginType, _ code: String,_ lineUserId:String,_ vc: UIViewController?,_ loginCallBack:(([String: Any])->Void)?,accoutType:YXMemberAccountType=YXMemberAccountType.mobile){
        self.accessToken = accessToken
        self.openId = openId
        self.appleParams = appleParmas
        self.thirdLoginType = thirdLoginType
        self.appleUserId = appleUserId
        self.lineUserId = lineUserId
        self.vc = vc
        self.loginCallBack = loginCallBack
        self.accoutType.subscribe(onNext:{ [weak self]type in
            if type == .email {
                self?.mobileHidden.onNext(true)
                self?.emailHidden.onNext(false)
            }else {
                self?.mobileHidden.onNext(false)
                self?.emailHidden.onNext(true)
            }
        }).disposed(by: disposebag)

        self.accoutType.accept(accoutType)
        self.handleMobInput()
        self.handleEmailInput()
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
            .map { $0.count >= 0}
            .share(replay: 1)
        let passTmp =  mPwd.asObservable()
            .map { $0.count > 0 }
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
            .map { $0.count > 0 }
            .share(replay: 1)
        
        self.eEverythingValid = Observable.combineLatest(eUsernameValid!, eVerCodeValid!,passTmp) { $0 && $1 && $2 }
                    .share(replay: 1)
    }
    
    func handelAccountChanage(title:String)  {
        if title == YXLanguageUtility.kLang(key: "mobile_acount") {
            accoutType.accept(.mobile)
        }else{
            accoutType.accept(.email)
        }
    }
    
    func bindMobileRequest(){
        hudSubject?.onNext(.loading(nil, false))
        let request: YXAggregationAPI = .thirdLoginTelAggreV1(YXUserManager.safeDecrypt(string: mPwd.value),areaCode.value, mCaptcha.value, YXUserManager.safeDecrypt(string: mobile.value), thirdLoginType.rawValue, accessToken, openId, appleUserId, lineUserId, "",false, false, false, false)
        services.aggregationService.request(request, response:threeTelAggResponse).disposed(by:disposebag)
    }
    func bindEmailRequest(){
        hudSubject?.onNext(.loading(nil, false))
        let request:YXAggregationAPI = .thirdLoginEmailBind(YXUserManager.safeDecrypt(string: ePwd.value), eCaptcha.value, email.value, thirdLoginType.rawValue, accessToken, openId, appleUserId,lineId: lineUserId)
        services.aggregationService.request(request, response: threeTelAggResponse).disposed(by: disposebag)
    }
    
    func sendMobileCodeRequest()  {
        hudSubject?.onNext(.loading(nil, false))
        let phoneNumber = YXUserManager.safeDecrypt(string:mobile.value)
        services.loginService.request(.sendUserInputCaptcha(areaCode.value, phoneNumber, .type104), response: sendUserInputCaptchaResponse).disposed(by: disposebag)
    }
    
    func sendEmailCodeRequest(){
        hudSubject?.onNext(.loading(nil, false))
        services.loginService.request(.sendEmailInputCaptcha(email.value, .type10004), response: sendUserInputCaptchaResponse).disposed(by: disposebag)
    }
    
    func gotoLogin() {
        let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: loginCallBack, cancelCallBack: nil, vc: nil, mobile: mobile.value, email: email.value, accoutType: accoutType.value,areacode:areaCode.value))
        navigator.push(YXModulePaths.defaultLogin.url, context: context)
    }
}
