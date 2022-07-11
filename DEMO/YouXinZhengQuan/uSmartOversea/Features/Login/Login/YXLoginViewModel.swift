//
//  YXLoginViewModel.swift
//  uSmartOversea
//
//  Created by mac on 2019/3/22.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import URLNavigator

public enum YXRegisterType {
    case normal
    case third
}

public enum YXMemberAccountType:String{
    case email = "email"
    case mobile = "mobile"
}

class YXLoginViewModel: HUDServicesViewModel  {
   
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    typealias Services = HasYXLoginService & HasYXAggregationService & HasYXNewsService
    var navigator: NavigatorServicesType!

    //登录注册广告
    var adResponse: YXResultResponse<YXUserBanner>?
    let adListRelay = BehaviorRelay<[BannerList]>(value: [])
    
    var loginResponse: YXResultResponse<YXLoginUser>?
    
    let loginSuccessSubject = PublishSubject<Bool>()//登录成功回调
    let unRegisteredSubject = PublishSubject<String>()//没有注册回调
    let fillPhoneSubject = PublishSubject<[String]>()//填充手机号
    let lockedSubject = PublishSubject<String>()//锁住 //密码错误次数过多账号已锁定，请%d分钟后重新登录或找回密码
    let freezeSubject = PublishSubject<String>()//冻结 //手机账户被冻结
    let unsetLoginPwdSubject = PublishSubject<String>()//未设置登录密码
    let hasActivateSubject = PublishSubject<String>() //已激活--预注册
    let thirdLoginUnbindPhoneSubject = PublishSubject<String>() //第三方登录没有绑定手机号
    
    var isCheckPreference: Bool = false //是否检查了喜好设置
    var unenablePopGestion: Bool = false //是否禁止侧滑返回手势
    
    var isGuideLoginRegister: Bool = false  //来自引导页登录注册
    
    var services: Services! {
        didSet {
            //登录响应
            loginResponse = { [weak self] (response) in
                guard let `self` = self else {return}
                self.hudSubject.onNext(.hide)
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        let userInfo = result.data
                        func setUserInfo(){
                            YXUserManager.setLoginInfo(user: userInfo)
                            YXUserManager.shared().defCode = self.areaCode.value
                            let mmkv = MMKV.default()
                            mmkv.set(self.areaCode.value, forKey: YXUserManager.YXDefCode)
                            mmkv.set(self.accoutType.value.rawValue,forKey: YXUserManager.YXLoginType)
                            //通知 更新用户信息
                            NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiUpdateUserInfo), object: nil)
                            
                            if YXUserManager.isNeedGuideAccount() {//进入开户页
                                let context = YXNavigatable(viewModel: YXOpenAccountGuideViewModel(dictionary: [:]))
                                self.navigator.push(YXModulePaths.loginOpenAccountGuide.url, context: context)
                                
                            } else {
                                self.loginSuccessSubject.onNext(true)
                                if let loginCallBack = self.loginCallBack {
                                    loginCallBack(YXUserManager.userInfo)
                                }
                            }
                        }
                        
                        let extendStatusBit = userInfo?.extendStatusBit ?? 2
                        let isOpen2fa = (extendStatusBit & YXExtendStatusBitType.auth2login.rawValue) == YXExtendStatusBitType.auth2login.rawValue
                        if isOpen2fa == false {
                            setUserInfo()
                        }else {
                            self.mPwd.accept("")
                            self.ePwd.accept("")
                            let context = YXNavigatable(viewModel: YXDoubleAuthLoginViewModel(user: userInfo, loginType:self.accoutType.value,callBack: { 
                                setUserInfo()
                            }))
                            self.navigator.push(YXModulePaths.doubelAuthLogin.url, context: context)
                        }
                        
                    case .accountUnregistered?,//帐号未注册
                         .accountUnSignup?:
                        if let msg = result.msg {
                            self.unRegisteredSubject.onNext(msg)
                        }
                    case .thirdLoginUnbindPhone?: //第三方登录没有绑定手机号
                        if let msg = result.msg {
                            self.thirdLoginUnbindPhoneSubject.onNext(msg)
                        }
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
                         .aggregationWeiboError?,
                         .aggregationFacebookError?,
                         .aggregationGoogleError?,
                         .aggregationOverseaUnservice?,
                         .aggregationHKWechatError?:
                        //self.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                        YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "common_net_error"))
                        break
                    case .accountLockout?://密码错误次数过多账号已锁定，请%d分钟后重新登录或找回密码
                        if let msg = result.msg {
                            self.freezeSubject.onNext(msg)
                        }
                    case .passwordWrong?:  //密码错误
                        if let msg = result.msg {
                            self.lockedSubject.onNext(msg)
                        }
                    default:
                        if let msg = result.msg {
                            //self.hudSubject.onNext(.error(msg, false))
                            YXProgressHUD.showSuccess(msg)
                        }
                    }
                case .failed(_):
                    YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "common_net_error"))
                   // self.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
            
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
    
    //第三方登录
    var accessToken = "" //三方token，微信、微博、谷歌、facebook同一个
    var openId = "" //微信openId
    var thirdLoginType = YXThirdLoginType.weChat //1:微信、2:微博、3:谷歌、4:facebook 6.apple
    var appleParams: [String: Any] = [:]
    var appleUserId = ""
    var lineUserId = ""
    var sendCaptchaType: YXSendCaptchaType = .type106 //发送验证码的type
    
    var mobileHidden = PublishSubject<Bool>()
    var emailHidden = PublishSubject<Bool>()
    var mUsernameValid : Observable<Bool>?
    var mPasswordValid : Observable<Bool>?
    var mEverythingValid : Observable<Bool>?
    var eUsernameValid : Observable<Bool>?
    var ePasswordValid : Observable<Bool>?
    var eEverythingValid : Observable<Bool>?
    
    var accoutType = BehaviorRelay<YXMemberAccountType>(value: .email)
    var mobile = BehaviorRelay<String>(value: "")
    var email = BehaviorRelay<String>(value: "")
    
    var mPwd = BehaviorRelay<String>(value: "")
    var ePwd = BehaviorRelay<String>(value: "")
    var areaCode = BehaviorRelay<String>(value: YXUserManager.shared().defCode)
    

    
    var loginCallBack: (([String: Any])->Void)?
    var cancelCallBack: (() -> Void)?
    weak var vc: UIViewController?
    
    var isThirdLogin:Bool = false
    var fillPhone: (([String]) -> Void)!
    let disposebag = DisposeBag()
    
    init(callBack: (([String: Any])->Void)?, cancelCallBack: (() -> Void)? = nil, vc: UIViewController?,mobile:String="",email:String="",accoutType:YXMemberAccountType=YXMemberAccountType.mobile,areacode:String=YXUserManager.shared().defCode) {
        self.loginCallBack = callBack
        self.cancelCallBack = cancelCallBack
        self.vc = vc
       
        self.accoutType.subscribe(onNext:{ [weak self]type in
            if type == .email {
                self?.mobileHidden.onNext(true)
                self?.emailHidden.onNext(false)
            }else {
                self?.mobileHidden.onNext(false)
                self?.emailHidden.onNext(true)
            }
        }).disposed(by: disposebag)
        
        self.mobile.accept(mobile)
        self.email.accept(email)
        self.accoutType.accept(accoutType)
        self.areaCode.accept(areacode)
        self.handleEmailInput()
        self.handleMobInput()
    }
    
    func handleMobInput(){
        self.mUsernameValid = mobile.asObservable()
                    .map { $0.count > 0 }
                    .share(replay: 1)
        self.mPasswordValid = mPwd.asObservable()
                    .map { $0.count > 0 }
                    .share(replay: 1)
        self.mEverythingValid = Observable.combineLatest(mUsernameValid!, mPasswordValid!) { $0 && $1 }
                    .share(replay: 1)
    }
    
    func handleEmailInput() {
        self.eUsernameValid = email.asObservable()
                    .map { ($0.isValidEmail() || $0.isValidDolphID()) && $0.count > 0}
                    .share(replay: 1)
        self.ePasswordValid = ePwd.asObservable()
                    .map { $0.count > 0 }
                    .share(replay: 1)
        self.eEverythingValid = Observable.combineLatest(eUsernameValid!, ePasswordValid!) { $0 && $1 }
                    .share(replay: 1)
    }
    
    func handelAccountChanage(title:String)  {
        if title == YXLanguageUtility.kLang(key: "mobile_acount") {
            accoutType.accept(.mobile)
        }else{
            accoutType.accept(.email)
        }
    }
    
    func gotoRegist(autoSendCaptcha:Bool) {
        let phone = mobile.value
        let viewModel = YXSignUpViewModel(withCode: areaCode.value, phone: phone, sendCaptchaType: .type101, vc: vc, loginCallBack: loginCallBack,email:email.value, accoutType: accoutType.value)

        let context = YXNavigatable(viewModel: viewModel)
        navigator.push(YXModulePaths.signUp.url, context: context)
    }
    
    func findPassWord(currentVC:UIViewController?) {
        let context = YXNavigatable(viewModel: YXForgetPwdPhoneViewModel(with: areaCode.value, phone:mobile.value , isLogin: false, callBack: fillPhone, loginCallBack: loginCallBack, fromVC: currentVC,sourceVC:vc,email: email.value,accoutType: accoutType.value))
        self.mPwd.accept("")
        self.ePwd.accept("")
        navigator.push(YXModulePaths.forgetPwdInputPhone.url, context: context)
    }
    
    func bindAccount()  {
        let bindPhoneModel = YXLoginBindPhoneViewModel(appleUserId,accessToken, openId, appleParams, thirdLoginType, areaCode.value, lineUserId,self.vc, loginCallBack)
        let context = YXNavigatable(viewModel: bindPhoneModel)
        navigator.push(YXModulePaths.loginBindPhone.url, context: context)
    }
    
    func accountLogin()  {
      hudSubject?.onNext(.loading(nil, false))
      services.aggregationService.request(.login("",email.value, YXUserManager.safeDecrypt(string: ePwd.value)), response:loginResponse).disposed(by: disposebag)
    }
    
    func mobileLogin()  {
        hudSubject?.onNext(.loading(nil, false))
        services.aggregationService.request(.login(areaCode.value, YXUserManager.safeDecrypt(string: mobile.value),YXUserManager.safeDecrypt(string: mPwd.value)), response: loginResponse).disposed(by: disposebag)
    }
    
    func requestAdData() {
        services.newsService.request(.userBannerV2(id: .advRegisterLogin), response: adResponse).disposed(by: disposebag)
    }
}
