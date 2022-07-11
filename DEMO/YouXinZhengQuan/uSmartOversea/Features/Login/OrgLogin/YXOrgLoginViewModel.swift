//
//  YXOrgLoginViewModel.swift
//  uSmartOversea
//
//  Created by 欧冬冬 on 2022/4/14.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import URLNavigator

class YXOrgLoginViewModel: HUDServicesViewModel {
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    typealias Services = HasYXLoginService & HasYXAggregationService & HasYXNewsService
    var navigator: NavigatorServicesType!

    var loginResponse: YXResultResponse<YXLoginUser>?
    
    let loginSuccessSubject = PublishSubject<Bool>()//登录成功回调
    let fillPhoneSubject = PublishSubject<[String]>()//填充手机号
    
    let checkAccountSubject = PublishSubject<Bool>() //已校验
        
    let jumpPersonAccontSubject = PublishSubject<String>() //调整个人用户
    let alertMsgSubject = PublishSubject<String>() //调整个人用户
    let activationSubject = PublishSubject<YXOrgActivateModel>() //激活
    let pwdErrorSubject =  PublishSubject<String>() //密码错误 4次
    var isCheckPreference: Bool = false //是否检查了喜好设置
    
    /*获取手机验证码(用户输入手机号)
     type 验证码类型 101注册 102重置密码 103更换手机号 104绑定手机号 105新设备登录校验 106短信登录
     send-phone-captcha/v1 */
    var sendUserInputCaptchaResponse: YXResultResponse<YXCommonCodeModel>?
    
    var checkAccountResponse: YXResultResponse<YXOrgCheckAccountModel>?
    
//    var checkAccountActivityResponse: YXResultResponse<YXOrgCheckAccountModel>?

    //登录注册广告
    var adResponse: YXResultResponse<YXUserBanner>?
    let adListRelay = BehaviorRelay<[BannerList]>(value: [])


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
                        if !self.isCheckPreference {
                            YXUserManager.checkPreferenceSet(user:result.data , clickSet: {[weak self] (isSame) in
                                guard let `self` = self else {return}
                                self.isCheckPreference = true
                                if isSame {
                                    self.loginResponse!(response)
                                }
                            })
                            return
                        }
                        
                        YXUserManager.setLoginInfo(user: result.data)
                        YXUserManager.shared().defCode = self.areaCode.value
                        let mmkv = MMKV.default()
                        mmkv.set(self.areaCode.value, forKey: YXUserManager.YXDefCode)
                        //通知 更新用户信息
                        NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiUpdateUserInfo), object: nil)

                        self.loginSuccessSubject.onNext(true)
                        if let loginCallBack = self.loginCallBack {
                            loginCallBack(YXUserManager.userInfo)
                        }
                        
                    case .accountDoubleCheak?, .accountEmailDoubleCheak?://在新设备登录，需要双重认证
                        let areaCode = self.areaCode.value
                        let phone = self.mobile.value
                        let context = YXNavigatable(viewModel: YXDoubleCheckViewModel(withCode: areaCode, phone: phone, email: self.email.value, isOrg: true))
                        self.navigator.push(YXModulePaths.doubleCheck.url, context: context)
                    default:
                        if let msg = result.msg {
                            self.hudSubject.onNext(.error(msg, false))
                        }
                    }
                case .failed(_):
                    self.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
            
            
            /*MARK: - 获取手机验证码(用户输入手机号)
             type 验证码类型 101注册 102重置密码 103更换手机号 104绑定手机号 105新设备登录校验 106短信登录
             send-phone-captcha/v1 */
            sendUserInputCaptchaResponse = { [weak self] (response) in
                guard let `self` = self else {return}
                self.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    if code == .success || code == .authCodeRepeatSent {
                        var tempCaptcha: String = ""
                        if YXConstant.isAutoFillCaptcha() {
                            if let captcha = result.data?.captcha {
                                tempCaptcha = captcha
                                //strongSelf.hudSubject.onNext(.message(captcha, true))
                            }
                        }
                        if code == .authCodeRepeatSent, let msg = result.msg {
                            self.hudSubject.onNext(.message(msg, true))
                        }
                        //跳去 注册code
                        let registerModel = YXRegisterCodeViewModel(withCode: self.areaCode.value, phone: self.mobile.value, sendCaptchaType: self.sendCaptchaType, vc: self.vc, loginCallBack: self.loginCallBack)
                        let userInfo = ["fromDefaultLogin": true,
                                        "tempCaptcha" : tempCaptcha] as [String : Any]
                        let context = YXNavigatable(viewModel: registerModel, userInfo: userInfo)
                        registerModel.isOrg = true
                        self.navigator.push(YXModulePaths.registerCode.url, context: context)
                    } else if let msg = result.msg {
                        self.hudSubject.onNext(.error(msg, false))
                    }
                case .failed(_):
                    self.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
            
            checkAccountResponse = { [weak self] (response) in
                guard let `self` = self else {return}
                self.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    let codeValue = result.code
                    if code == .success {
                        self.checkAccountSubject.onNext(true)
                    } else if codeValue == 304002 {
                        // 贵公司资料尚未审核成功，审核通过后可通过APP登陆
                        self.alertMsgSubject.onNext(result.msg ?? "")
                    } else if codeValue == 304016 {
                        // 您未注册机构账户，若需登陆请点击登陆个人账户
                        self.jumpPersonAccontSubject.onNext(result.msg ?? "")
                    } else if codeValue == 304005 {
                        // 机构户未激活
                        let model = YXOrgActivateModel.init(existPassword: result.data?.existPassword ?? false, msg: result.msg ?? "")
                        self.activationSubject.onNext(model)
                    } else if codeValue == 301003 {
                        self.pwdErrorSubject.onNext(result.msg ?? "")
                    } else if let msg = result.msg {
                        self.hudSubject.onNext(.error(msg, false))
                    }
                case .failed(_):
                    self.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
            
//            //点击激活按钮 校验
//            checkAccountActivityResponse = { [weak self] (response) in
//                guard let `self` = self else {return}
//                self.hudSubject.onNext(.hide)
//
//                switch response {
//                case .success(let result, let code):
//                    let codeValue = result.code
//                    if code == .success {
//                        self.checkAccountSubject.onNext(true)
//                    } else if codeValue == 304002 {
//                        // 贵公司资料尚未审核成功，审核通过后可通过APP登陆
//                        self.alertMsgSubject.onNext(result.msg ?? "")
//                    } else if codeValue == 304016 {
//                        // 您未注册机构账户，若需登陆请点击登陆个人账户
//                        self.jumpPersonAccontSubject.onNext(result.msg ?? "")
//                    } else if codeValue == 304005 {
//                        // 机构户未激活
//                        let model = YXOrgActivateModel.init(existPassword: result.data?.existPassword ?? false, msg: result.msg ?? "")
//                        self.activationSubject.onNext(model)
//                    } else if let msg = result.msg {
//                        self.hudSubject.onNext(.error(msg, false))
//                    }
//                case .failed(_):
//                    self.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
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
        
    //公共
//    var phone = Variable<String>("")//手机号
//    var pwd = Variable<String>("")//密码
    var mobile = BehaviorRelay<String>(value: "")
    var email = BehaviorRelay<String>(value: "")
    
    var mPwd = BehaviorRelay<String>(value: "")
    var ePwd = BehaviorRelay<String>(value: "")
    
//    var phone = BehaviorRelay<String>(value: "")//手机号
//    var pwd = BehaviorRelay<String>(value: "")//密码
    //var code = YXUserManager.shared().defCode //区号
    var sendCaptchaType: YXSendCaptchaType = .type106 //发送验证码的type
    
    var accoutType = BehaviorRelay<YXMemberAccountType>(value: .email)
    var areaCode = BehaviorRelay<String>(value: YXUserManager.shared().defCode)
    
    
    var mobileHidden = PublishSubject<Bool>()
    var emailHidden = PublishSubject<Bool>()
    var mUsernameValid : Observable<Bool>?
    var mPasswordValid : Observable<Bool>?
    var mEverythingValid : Observable<Bool>?
    var eUsernameValid : Observable<Bool>?
    var ePasswordValid : Observable<Bool>?
    var eEverythingValid : Observable<Bool>?
    
    var fillPhone: (([String]) -> Void)!
    let disposebag = DisposeBag()

    var loginCallBack: (([String: Any])->Void)?
    var cancelCallBack: (() -> Void)?
    weak var vc: UIViewController?
        
//    init(callBack: (([String: Any])->Void)?, cancelCallBack: (() -> Void)? = nil, vc: UIViewController?) {
//        self.loginCallBack = callBack
//        self.cancelCallBack = cancelCallBack
//        self.vc = vc
//    }
    
    init(callBack: (([String: Any])->Void)?, cancelCallBack: (() -> Void)? = nil, vc: UIViewController?,mobile:String="",email:String="",accoutType:YXMemberAccountType=YXMemberAccountType.email,areacode:String=YXUserManager.shared().defCode) {
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
        if title == YXLanguageUtility.kLang(key: "org_mobile_acount") {
            accoutType.accept(.mobile)
        }else{
            accoutType.accept(.email)
        }
    }
    
    func requestAdData() {
        services.newsService.request(.userBannerV2(id: .advRegisterLogin), response: adResponse).disposed(by: disposebag)
    }
    
//    func findPassWord(currentVC:UIViewController?,type:YXMemberAccountType) {
//        if type == .mobile {
//            let context = YXNavigatable(viewModel: YXForgetPwdPhoneViewModel(with: areaCode.value, phone:mobile.value , isLogin: false, callBack: fillPhone, loginCallBack: loginCallBack, fromVC: currentVC,sourceVC:vc,email: email.value,accoutType: accoutType.value))
//            self.mPwd.accept("")
//            self.ePwd.accept("")
//            navigator.push(YXModulePaths.forgetPwdInputPhone.url, context: context)
//            
//        } else {
//            
//        }
//    }
    
//    func accountLogin()  {
//      hudSubject?.onNext(.loading(nil, false))
//      services.aggregationService.request(.login("",email.value, YXUserManager.safeDecrypt(string: ePwd.value)), response:loginResponse).disposed(by: disposebag)
//    }
//    
//    func mobileLogin()  {
//        hudSubject?.onNext(.loading(nil, false))
//        services.aggregationService.request(.login(areaCode.value, YXUserManager.safeDecrypt(string: mobile.value),YXUserManager.safeDecrypt(string: mPwd.value)), response: loginResponse).disposed(by: disposebag)
//    }
}
