//
//  YXDoubleCheckViewModel.swift
//  uSmartOversea
//
//  Created by mac on 2019/3/28.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator

class YXDoubleCheckViewModel: HUDServicesViewModel  {

    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    typealias Services = HasYXLoginService & HasYXAggregationService
    var navigator: NavigatorServicesType!

    
    
    
    var sendUserInputCaptchaResponse: YXResultResponse<JSONAny>?
    let codeSubject = PublishSubject<String>()
    
    var loginResponse: YXResultResponse<YXLoginUser>?
    let timeoutSubject = PublishSubject<Bool>()  //手机双重认证时间超时
    let freezeSubject = PublishSubject<String>()
    let loginSuccessSubject = PublishSubject<Bool>()
    
    var isCheckPreference: Bool = false //是否检查了喜好设置
    
    var services: Services! {
        didSet {
            
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
                        YXUserManager.shared().defCode = self.code
                        let mmkv = MMKV.default()
                        mmkv.set(self.code , forKey: YXUserManager.YXDefCode)
                        self.loginSuccessSubject.onNext(true)
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
                    case .accountFreeze?:
                        if let msg = result.msg {
                            self.freezeSubject.onNext(msg)
                        }
                    case .accountCheakTimeout?: //手机双重认证时间超时
                        self.timeoutSubject.onNext(true)
                    default:
                        if let msg = result.msg {
                            self.hudSubject.onNext(.error(msg, false))
                        }
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
                        if let dic = result.data?.value as? Dictionary<AnyHashable, Any> {
                            if let captcha = dic["captcha"] as? String {
                                self?.codeSubject.onNext(captcha)
                            } else {
                                self?.codeSubject.onNext("")
                            }
                        } else {
                            self?.codeSubject.onNext("")
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
    
    var code = ""
    var phone = ""
    var captcha = ""
    
    var isOrg = false
    var email = ""
    
    init(withCode code:String, phone:String, email: String = "", isOrg: Bool = false) {
        self.code = code
        self.phone = phone
        self.email = email
        self.isOrg = isOrg
    }
    
}
