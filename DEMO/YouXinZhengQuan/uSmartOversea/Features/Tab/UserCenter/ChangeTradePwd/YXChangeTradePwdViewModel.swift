//
//  YXChangeTradePwdViewModel.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/12.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import URLNavigator

class YXChangeTradePwdViewModel: HUDServicesViewModel  {

    typealias Services = HasYXUserService
    var navigator: NavigatorServicesType!
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    /*校验交易密码
     check-trade-password/v1 */
    var checkPwdResponse: YXResultResponse<JSONAny>?
    var checkSuccessSubject = PublishSubject<Bool>()
    var pwdErrorSubject = PublishSubject<String>()
    var pwdLockSubject = PublishSubject<String>()
    
    /*获取客户开户证件类型
     1.大陆身份证;2.香港身份证;3.护照;4.香港永久居民身份证
     get-customer-identify-type/v1 */
    var idTypeResponse: YXResultResponse<YXIdType>?
    var idTypeSuccessSubject = PublishSubject<NSInteger>()
    /*修改交易密码
     update-trade-password/v1 */
    var changePwdResponse: YXResultResponse<JSONAny>?
    
    /*重置交易密码
     reset-trade-password/v1 */
    var resetPwdResponse: YXResultResponse<JSONAny>?
   
    
    var changeSuccessSubject = PublishSubject<Bool>()
    var digitalErrorSubject = PublishSubject<String>()
    
    var services: Services! {
        didSet {
            /*校验交易密码
             check-trade-password/v1 */
            checkPwdResponse = {[weak self] (response) in
                
                guard let strongSelf = self else { return }
                strongSelf.hudSubject.onNext(.hide)
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        
                        strongSelf.checkSuccessSubject.onNext(true)
                    case .tradePwdError?:
                        if let msg = result.msg {
                            strongSelf.pwdErrorSubject.onNext(msg)
                        }
                    case .tradePwdLockError?:
                        if let msg = result.msg {
                            strongSelf.pwdLockSubject.onNext(msg)
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
            /*获取客户开户证件类型
             1.大陆身份证;2.香港身份证;3.护照;4.香港永久居民身份证
             get-customer-identify-type/v1 */
            idTypeResponse = {[weak self] (response) in
                
                self?.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    if code == .success {
                        self?.idTypeSuccessSubject.onNext(result.data?.identifyType ?? 2)
                    } else if let msg = result.msg  {
                        self?.hudSubject.onNext(.error(msg, false))
                    }
                case .failed(_):
                    self?.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
            /*修改交易密码
             update-trade-password/v1 */
            changePwdResponse = {[weak self] (response) in
                
                self?.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        self?.hudSubject.onNext(.success(YXLanguageUtility.kLang(key: "mine_change_succeed"), true))
                        self?.changeSuccessSubject.onNext(true)
                        break
                    case .tradePwdDigitalError?:
                        if let msg = result.msg {
                            self?.digitalErrorSubject.onNext(msg)
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
            /*重置交易密码
             reset-trade-password/v1 */
            resetPwdResponse = {[weak self] (response) in
                
                self?.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        self?.hudSubject.onNext(.success(YXLanguageUtility.kLang(key: "mine_reset_tradePwd_succeed"), true))
                        self?.changeSuccessSubject.onNext(true)
                        break
                    case .tradePwdDigitalError?:
                        if let msg = result.msg {
                            self?.digitalErrorSubject.onNext(msg)
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
        }
    }
    
    var type: YXChangeTradePwdType?
    var funType: YXTradePwdFunType = .change
    var pwd = ""
    var oldPwd = ""
    var captcha = ""
    var vc: UIViewController!
    var pwdRelay = BehaviorRelay<String>.init(value: "")
    
    init(type: YXChangeTradePwdType, funType: YXTradePwdFunType, oldPwd: String, pwd: String, captcha: String, vc: UIViewController) {
        self.type = type
        self.pwd = pwd
        self.oldPwd = oldPwd
        self.funType = funType
        self.captcha = captcha
        self.vc = vc
    }
    
    
}
