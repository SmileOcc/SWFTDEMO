//
//  YXOrgActivateViewModel.swift
//  uSmartOversea
//
//  Created by 欧冬冬 on 2022/4/14.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import URLNavigator

class YXOrgActivateViewModel: HUDServicesViewModel {
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
    
    var activiteResponse: YXResultResponse<YXLoginUser>?
    
    let codeSubject = PublishSubject<(Bool,String)>()
    
    var sendUserInputCaptchaResponse: YXResultResponse<YXCommonCodeModel>?
    
    var services: Services! {
        didSet {
            
            self.activiteResponse = { [weak self] (response) in
                
                self?.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    if code == .success {
                        guard let `self` = self else {return}
                        
                        YXUserManager.setLoginInfo(user: result.data)
                        YXUserManager.shared().defCode = self.areaCode
                        let mmkv = MMKV.default()
                        mmkv.set(self.areaCode, forKey: YXUserManager.YXDefCode)
                        //通知 更新用户信息
                        NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiUpdateUserInfo), object: nil)
                        self.loginSuccessSubject.onNext(true)
                        if let loginCallBack = self.loginCallBack {
                            loginCallBack(YXUserManager.userInfo)
                        }
                        
                    } else if let msg = result.msg  {
                        self?.hudSubject.onNext(.error(msg, false))
                    }
                case .failed(_):
                    self?.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
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
    
    var phone = ""//手机号
    var areaCode = ""//区号
    var email = ""//邮箱
//    var captcha = ""//Variable<String>("") //验证码
    //var recommendCode: String?
    var loginCallBack: (([String: Any])->Void)?
    weak var vc: UIViewController?
    var sendCaptchaType:YXSendCaptchaType = .type106
    
    var isEmail = false
    
    var isExitPwd = false
    

    init(withCode code:String, phone: String, email: String, isEmail: Bool, isExitPwd: Bool, vc: UIViewController?, loginCallBack: (([String: Any])->Void)?) {
        self.phone = phone
        self.areaCode = code
        self.email = email
        self.isEmail = isEmail
        self.isExitPwd = isExitPwd
        self.vc = vc
        
        self.loginCallBack = loginCallBack
    }
}
