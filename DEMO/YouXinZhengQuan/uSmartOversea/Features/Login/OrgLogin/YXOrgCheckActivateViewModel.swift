//
//  YXOrgCheckActivateViewModel.swift
//  uSmartOversea
//
//  Created by 欧冬冬 on 2022/4/18.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import URLNavigator

class YXOrgCheckActivateViewModel: HUDServicesViewModel {
    
    typealias Services = HasYXAggregationService & HasYXLoginService
    
    var navigator: NavigatorServicesType!
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    let loginSuccessSubject = PublishSubject<Bool>()
    
//    var captcha = Variable<String>("")
//    var registCode = Variable<String>("")
//    var password = Variable<String>("")
    
    var captcha = BehaviorRelay<String>(value: "")
    var registCode = BehaviorRelay<String>(value: "")
    var password = BehaviorRelay<String>(value: "")
    
    var checkActiviteResponse: YXResultResponse<YXOrgCheckAccountModel>?
    
    let codeSubject = PublishSubject<(Bool,String)>()
    
    let checkAccountSubject = PublishSubject<Bool>() //已校验
    let jumpPersonAccontSubject = PublishSubject<String>() //调整个人用户
    let alertMsgSubject = PublishSubject<String>() //调整个人用户
    let activationSubject = PublishSubject<YXOrgActivateModel>() //激活

    var sendUserInputCaptchaResponse: YXResultResponse<YXCommonCodeModel>?
    

    var services: Services! {
        didSet {
            
            self.checkActiviteResponse = { [weak self] (response) in
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
                    } else if let msg = result.msg {
                        self.hudSubject.onNext(.error(msg, false))
                    }
                case .failed(_):
                    self.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
            
            sendUserInputCaptchaResponse  = { [weak self] (response) in
                
                self?.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    if code == .success {
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
        
        }
    }
    

    var loginCallBack: (([String: Any])->Void)?
    weak var vc: UIViewController?
    var sendCaptchaType:YXSendCaptchaType = .type106
    
    var isEmail = false
    
    var isExitPwd = false
    
    var accoutType = BehaviorRelay<YXMemberAccountType>(value: .email)
    var areaCode = BehaviorRelay<String>(value: YXUserManager.shared().defCode) //区号
    var mobile = BehaviorRelay<String>(value: "") //手机号
    var email = BehaviorRelay<String>(value: "") //邮箱
    
    var mobileHidden = PublishSubject<Bool>()
    var emailHidden = PublishSubject<Bool>()
    var mUsernameValid : Observable<Bool>?
    var eUsernameValid : Observable<Bool>?
    
    let disposebag = DisposeBag()
    

    init(with accoutType:YXMemberAccountType=YXMemberAccountType.email, code:String, phone: String, email: String, fromVC: UIViewController?, loginCallBack: (([String: Any])->Void)?) {
        self.vc = fromVC
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
        
        self.areaCode = BehaviorRelay<String>(value: code)
        self.mobile = BehaviorRelay<String>(value: phone)
        self.email = BehaviorRelay<String>(value: email)
        self.accoutType.accept(accoutType)
        self.handleEmailInput()
        self.handleMobInput()
        
    }
    
    func handleMobInput(){
        self.mUsernameValid = mobile.asObservable()
                    .map { $0.count > 0 }
                    .share(replay: 1)
    }
    
    func handleEmailInput() {
        self.eUsernameValid = email.asObservable()
                    .map { ($0.isValidEmail()) && $0.count > 0}
                    .share(replay: 1)
    }
    
    func handelAccountChanage(title:String)  {
        if title == YXLanguageUtility.kLang(key: "org_mobile_acount") {
            accoutType.accept(.mobile)
        }else{
            accoutType.accept(.email)
        }
    }
}
