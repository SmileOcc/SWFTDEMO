//
//  YXSignUpViewModel.swift
//  uSmartOversea
//
//  Created by usmart on 2021/4/1.
//  Copyright © 2021 RenRenDai. All rights reserved.
//
import UIKit
import RxSwift
import RxCocoa
import YXKit
import URLNavigator

class YXSignUpViewModel: HUDServicesViewModel  {

    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    typealias Services = HasYXLoginService & HasYXAggregationService & HasYXUserService & HasYXNewsService
    var navigator: NavigatorServicesType!
    
    /*获取验证码
     type 验证码类型 101注册 102重置密码 103更换手机号 104绑定手机号 105新设备登录校验 106短信登录 10001-邮箱注册
     /send-email-captcha/v1
     /send-email-captcha/v1
     */
    var sendUserInputCaptchaResponse: YXResultResponse<YXCommonCodeModel>?
    let eCodeSubject = PublishSubject<(Bool,String)>()
    let mCodeSubject = PublishSubject<(Bool,String)>()
    
    /*短信验证码注册聚合接口
     email-captcha-password-register-aggregation/v1
     phone-captcha-password-register-aggregation/v1
     */
    var captchaRegisterAggResponse: YXResultResponse<YXLoginUser>?
//    let lockedSubject = PublishSubject<String>()//锁住
//    let freezeSubject = PublishSubject<String>()//冻结
    let loginSuccessSubject = PublishSubject<Bool>()//登录成功的回调
    let hasActivateSubject = PublishSubject<String>() //已激活
    let hasRegisterSubject = PublishSubject<String>()//已注册
    
    //登录注册广告
    var adResponse: YXResultResponse<YXUserBanner>?
    let adListRelay = BehaviorRelay<[BannerList]>(value: [])
    
    var services: Services! {
        didSet {
            /*MARK: 获取手机验证码(用户输入手机号)
             type 验证码类型 101注册 102重置密码 103更换手机号 104绑定手机号 105新设备登录校验 106短信登录
             send-phone-captcha/v1 */
            sendUserInputCaptchaResponse  = { [weak self] (response) in
                guard let `self` = self else { return }

                self.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    if code == .success || code == .authCodeRepeatSent {
                        
                        let captcha = result.data?.captcha ?? ""

                        if self.accoutType.value == .email{
                            let signUpRegisterModel = YXSignUpRegisterCodeViewModel(withCode: self.areaCode.value, captcha:captcha, phone: "", email: self.email.value, invite: self.inviteCode.value, sendCaptchaType: .type10001, vc: self.vc, loginCallBack: self.loginCallBack)
                            let userInfo = ["tempCaptcha" : captcha,"recommendCode": self.inviteCode.value] as [String : Any]

                            let context = YXNavigatable(viewModel: signUpRegisterModel, userInfo: userInfo)
                            self.navigator.push(YXModulePaths.normalRegisterCode.url, context: context)
                        } else {
                            
                            let signUpRegisterModel = YXSignUpRegisterCodeViewModel(withCode: self.areaCode.value, captcha:captcha, phone: self.mobile.value, email: "", invite: self.inviteCode.value, sendCaptchaType: .type101, vc: self.vc, loginCallBack: self.loginCallBack)
                            let userInfo = ["tempCaptcha" : captcha,"recommendCode": self.inviteCode.value] as [String : Any]
                            
                            let context = YXNavigatable(viewModel: signUpRegisterModel, userInfo: userInfo)
                            self.navigator.push(YXModulePaths.normalRegisterCode.url, context: context)
                        }
                        
                        if code == .authCodeRepeatSent, let msg = result.msg {
                            self.hudSubject.onNext(.message(msg, true))
                        }
                        
                    }
                    else if code == .userPhoneHasRegistered || code == .userEmialHasRegistered {
                        if let msg = result.msg {
                            self.hasRegisterSubject.onNext(msg)
                        }
                        
                    } else if let msg = result.msg {
                        YXProgressHUD.showSuccess(msg)
                    }
                case .failed(_):
                    YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "common_net_error"))
                }
            }
//            /*MARK: 短信验证码注册登陆聚合接口
//             captcha-register-aggregation/v1   */
//            captchaRegisterAggResponse = { [weak self] (response) in
//                guard let `self` = self else { return }
//                self.hudSubject.onNext(.hide)
//                
//                //清空邀请码
//                YXConstant.registerICode = ""
//                
//                switch response {
//                case .success(let result, let code):
//                    switch code {
//                    case .success?:
//                        YXUserManager.setLoginInfo(user: result.data)
//                        YXUserManager.shared().defCode = self.areaCode.value
//                        let mmkv = MMKV.default()
//                        mmkv.set(self.areaCode.value, forKey: YXUserManager.YXDefCode)
//                        mmkv.set(self.accoutType.value.rawValue,forKey: YXUserManager.YXLoginType)
//                        //通知 更新用户信息
//                        NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiUpdateUserInfo), object: nil)
//                        
//                        //是否有绑定美股行情权限 判断 v2.4去掉
////                        let extendStatusBit = YXUserManager.shared().curLoginUser?.extendStatusBit ?? 2
////                        let hqAuthority = (extendStatusBit & YXExtendStatusBitType.hqAuthority.rawValue) == YXExtendStatusBitType.hqAuthority.rawValue
////                        if hqAuthority == false {
////
////                            let model = YXUSAuthStateWebViewModel(dictionary: [:], loginCallBack: self.loginCallBack, sourceVC: self.vc,hideSkip: false)
////                            model.isFromeRegister = true
////                            let context = YXNavigatable(viewModel: model)
////                            self.navigator.push(YXModulePaths.USAuthState.url, context: context)
////                        }
//                        
//                        if YXUserManager.isNeedGuideAccount() {//进入开户页
//                            let context = YXNavigatable(viewModel: YXOpenAccountGuideViewModel(dictionary: [:]))
//                            self.navigator.push(YXModulePaths.loginOpenAccountGuide.url, context: context)
//                            
//                        } else {
//                            self.loginSuccessSubject.onNext(true)
//                            //loginCallBack的回调
//                            if let loginCallBack = self.loginCallBack {
//                                loginCallBack(YXUserManager.userInfo)
//                            }
//                        }
//                    case .aggregationError?,
//                         .aggregationHalfError?,
//                         .aggregationUserError?,
//                         .aggregationStockError?,
//                         .aggregationProductError?,
//                         .aggregationInfoError?,
//                         .aggregationLoginError?,
//                         .aggregationRegistError?,
//                         .aggregationMoneyError?,
//                         .aggregationPermissionsError?,
//                         .aggregationWechatError?,
//                         .aggregationWeiboError?:
//                        self.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
//                        break
//                    case .mobileHasRegisted?,
//                         .emailHasRegisted?:
//                        if let msg = result.msg {
//                            self.hasRegisterSubject.onNext(msg)
//                        }
//                    default:
//                        if let msg = result.msg {
//                           // self.hudSubject.onNext(.error(msg, false))
//                            YXProgressHUD.showSuccess(msg)
//                        }
//                    }
//                case .failed(_):
//                    YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "common_net_error"))
//                    //self.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
//                }
//            }
            
            adResponse = { [weak self] (response) in
                guard let `self` = self else { return }
                
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        if let adList = result.data?.dataList, adList.count > 0 {
                            self.adListRelay.accept(adList)
                        } else {
                            self.adListRelay.accept([])
                        }
                    default:
                        self.adListRelay.accept([])
                        break
                    }
                case .failed(_):
                    self.adListRelay.accept([])
                    break
                }
            }
        }
    }
    
    var loginCallBack: (([String: Any])->Void)?
    var vc: UIViewController?
    var sendCaptchaType:YXSendCaptchaType = .type106
    
    var mobileHidden = PublishSubject<Bool>()
    var emailHidden = PublishSubject<Bool>()
    var mUsernameValid : Observable<Bool>?
    var mVerCodeValid : Observable<Bool>?
    var mPassWordValid : Observable<Bool>?
    var mEverythingValid : Observable<Bool>?
    var eUsernameValid : Observable<Bool>?
    var eVerCodeValid : Observable<Bool>?
    var ePassWordValid : Observable<Bool>?
    var eEverythingValid : Observable<Bool>?
    
    var accoutType = BehaviorRelay<YXMemberAccountType>(value: .email)
    var mobile = BehaviorRelay<String>(value: "")
    var email = BehaviorRelay<String>(value: "")
    var inviteCode = BehaviorRelay<String>(value: "")

    var mPwd = BehaviorRelay<String>(value: "")
    var ePwd = BehaviorRelay<String>(value: "")
    var areaCode = BehaviorRelay<String>(value: YXUserManager.shared().defCode)
    
    var eCaptcha = BehaviorRelay<String>(value: "")//email验证码
    var mCaptcha = BehaviorRelay<String>(value: "")//mobeil 验证码
    let disposebag = DisposeBag()
    
    init(withCode code:String, phone: String, sendCaptchaType:YXSendCaptchaType, vc: UIViewController?, loginCallBack: (([String: Any])->Void)?,email:String="",accoutType:YXMemberAccountType=YXMemberAccountType.mobile) {
        self.sendCaptchaType = sendCaptchaType
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

        self.mobile.accept(phone)
        self.email.accept(email)
        self.accoutType.accept(accoutType)
        self.areaCode.accept(code)
        self.handleMobInput()
        self.handleEmailInput()
    }
    
    
    func handleMobInput(){
        self.mUsernameValid = mobile.asObservable()
                    .map { $0.count > 0 }
                    .share(replay: 1)
//        self.mVerCodeValid = mCaptcha.asObservable()
//                    .map { $0.count > 0 }
//                    .share(replay: 1)
//        self.mPassWordValid = mPwd.asObservable()
//            .map { $0.isValidPwd() && $0.count >= 8 && $0.count <= 20 || $0.count == 0}
//            .share(replay: 1)
//        let passTmp =  mPwd.asObservable()
//            .map { $0.isValidPwd() && $0.count >= 8 && $0.count <= 20 }
//            .share(replay: 1)
        
//        self.mPassWordValid = mPwd.asObservable()
//            .map { $0.count >= 0}
//            .share(replay: 1)
//        let passTmp =  mPwd.asObservable()
//            .map { $0.count > 0 }
//            .share(replay: 1)
        
//        self.mEverythingValid = Observable.combineLatest(mUsernameValid!, mVerCodeValid!,passTmp) { $0 && $1 && $2 }
//                    .share(replay: 1)
    }
    
    func handleEmailInput() {
        self.eUsernameValid = email.asObservable()
                    .map { $0.isValidEmail() }
                    .share(replay: 1)
//        self.eVerCodeValid = eCaptcha.asObservable()
//                    .map { $0.count > 0 }
//                    .share(replay: 1)
//        self.ePassWordValid = ePwd.asObservable()
//                    .map { $0.isValidPwd() && $0.count >= 8 && $0.count <= 20 || $0.count == 0}
//                    .share(replay: 1)
//        let passTmp =  ePwd.asObservable()
//            .map { $0.isValidPwd() && $0.count >= 8 && $0.count <= 20 }
//            .share(replay: 1)
        
//        self.ePassWordValid = ePwd.asObservable()
//                    .map { $0.count >= 0}
//                    .share(replay: 1)
//        let passTmp =  ePwd.asObservable()
//            .map { $0.count > 0 }
//            .share(replay: 1)
//
//        self.eEverythingValid = Observable.combineLatest(eUsernameValid!, eVerCodeValid!,passTmp) { $0 && $1 && $2 }
//                    .share(replay: 1)
    }
    
    func handelAccountChanage(title:String)  {
        if title == YXLanguageUtility.kLang(key: "mobile_acount") {
            accoutType.accept(.mobile)
        }else{
            accoutType.accept(.email)
        }
    }
    
//    func sendMobileCodeRequest()  {
//        hudSubject?.onNext(.loading(nil, false))
//        let phoneNumber = YXUserManager.safeDecrypt(string:mobile.value)
//        services.loginService.request(.sendUserInputCaptcha(areaCode.value, phoneNumber, .type101), response: sendUserInputCaptchaResponse).disposed(by: disposebag)
//    }
//    
//    func sendEmailCodeRequest(){
//        hudSubject?.onNext(.loading(nil, false))
//        services.loginService.request(.sendEmailInputCaptcha(email.value, .type10001), response: sendUserInputCaptchaResponse).disposed(by: disposebag)
//    }
    
    func checkAccount() {
        hudSubject?.onNext(.loading(nil, false))
        if accoutType.value == .mobile {
            services.loginService.request(.checkAccountRegistNumber(YXUserManager.safeDecrypt(string: mobile.value), areaCode.value), response: sendUserInputCaptchaResponse).disposed(by: disposebag)

        } else {
            services.loginService.request(.checkAccountRegistNumber(YXUserManager.safeDecrypt(string: email.value), ""), response: sendUserInputCaptchaResponse).disposed(by: disposebag)
        }
  
    }
    
//    func mobileSignupRequest()  {
//        hudSubject?.onNext(.loading(nil, false))
//
//        //持有邀请码
//        YXConstant.registerICode = inviteCode.value.removeBlankSpace()
//        services.aggregationService.request(.mobileRegister(areaCode.value, YXUserManager.safeDecrypt(string:mobile.value), mCaptcha.value, YXUserManager.safeDecrypt(string:mPwd.value), inviteCode.value.removeBlankSpace()), response: captchaRegisterAggResponse).disposed(by: disposebag)
//    }
//
//    func emailSignupRequest(){
//        hudSubject?.onNext(.loading(nil, false))
//        //持有邀请码
//        YXConstant.registerICode = inviteCode.value.removeBlankSpace()
//        services.aggregationService.request(.emailRegister(eCaptcha.value, email.value, YXUserManager.safeDecrypt(string:ePwd.value), inviteCode.value.removeBlankSpace()), response: captchaRegisterAggResponse).disposed(by: disposebag)
//    }
    
    func gotoLogin() {
        let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: loginCallBack, cancelCallBack: nil, vc: self.vc, mobile: mobile.value, email: email.value, accoutType: accoutType.value,areacode:areaCode.value))
        navigator.push(YXModulePaths.defaultLogin.url, context: context)
    }
    
    func requestAdData() {
        services.newsService.request(.userBannerV2(id: .advRegisterLogin), response: adResponse).disposed(by: disposebag)
    }
}

