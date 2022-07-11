//
//  YXSignUpSetPwdViewModel.swift
//  uSmartOversea
//
//  Created by 欧冬冬 on 2022/6/6.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YXKit
import URLNavigator

class YXSignUpSetPwdViewModel: HUDServicesViewModel {
    
    var navigator: NavigatorServicesType!
    

    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    typealias Services = HasYXLoginService & HasYXAggregationService & HasYXUserService

    var registerResponse: YXResultResponse<YXLoginUser>?
    let loginSuccessSubject = PublishSubject<Bool>()
    let registerSMSTimeoutSubject = PublishSubject<String>()//验证码错误

    var passwordValid : Observable<Bool>?
    var password = BehaviorRelay<String>(value: "")
    var accoutType = BehaviorRelay<YXMemberAccountType>(value: .email)

    var needClearUserInfo:Bool=false

    var services: Services! {
        didSet {
            
            /* 注册账号  */
            registerResponse = { [weak self] (response) in
                guard let strongSelf = self else { return }
                strongSelf.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    
                    switch code {
                    case .success?:
    
                        YXConstant.registerICode = ""
                        YXUserManager.setLoginInfo(user: result.data)
                        YXUserManager.shared().defCode = strongSelf.code
                        let mmkv = MMKV.default()
                        mmkv.set(strongSelf.code, forKey: YXUserManager.YXDefCode)
                        mmkv.set(strongSelf.accoutType.value.rawValue,forKey: YXUserManager.YXLoginType)
                        
                        //通知 更新用户信息
                        NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiUpdateUserInfo), object: nil)
                        
                        if YXUserManager.isNeedGuideAccount() {//进入开户页
                            let context = YXNavigatable(viewModel: YXOpenAccountGuideViewModel(dictionary: [:]))
                            strongSelf.navigator.push(YXModulePaths.loginOpenAccountGuide.url, context: context)

                        } else {
                            
                            strongSelf.loginSuccessSubject.onNext(true)
                            //loginCallBack的回调
                            if let loginCallBack = strongSelf.loginCallBack {
                                loginCallBack(YXUserManager.userInfo)
                            }
                            
                        }

                    case .registePhoneSMSError?,
                         .registeEmailCodeError?,
                         .registeEmailCodeTimesOverMuch?,
                         .registeEmailCodeOverdue?,
                         .codeTimeout?,
                         .vertifyTooMuch?:
                        if let msg = result.msg {
                            strongSelf.registerSMSTimeoutSubject.onNext(msg)
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
        }
    }
    
    
    var code:String = ""
    var captcha:String = ""
    var phone:String = ""
    var email:String = ""
    var invite:String = ""
    var loginCallBack: (([String: Any])->Void)?
    var vc: UIViewController?
    
    let disposebag = DisposeBag()

    
    init(withCode code:String=YXUserManager.shared().defCode, captcha: String = "", phone: String = "", email: String = "", invite: String = "", vc: UIViewController?, loginCallBack: (([String: Any])->Void)?) {
        
        self.code = code
        self.captcha = captcha
        self.phone = phone
        self.email = email
        self.invite = invite
        
        self.vc = vc
        self.loginCallBack = loginCallBack
        
        self.passwordValid = password.asObservable()
                    .map { $0.count > 0 }
                    .share(replay: 1)
        
        if !email.isEmpty {
            accoutType.accept(.email)
        } else {
            accoutType.accept(.mobile)
        }
    }
    
    func signUpRequest(_ pwd: String) {
        
        hudSubject?.onNext(.loading(nil, false))

        //持有邀请码
        YXConstant.registerICode = self.invite.removeBlankSpace()
        if self.phone.isNotEmpty() {

            self.services.aggregationService.request(.mobileCodeRegister(self.code, YXUserManager.safeDecrypt(string:self.phone), pwd, self.captcha, self.invite.removeBlankSpace()), response: self.registerResponse).disposed(by: disposebag)

        } else {
            self.services.aggregationService.request(.emailRegister(self.captcha, self.email, pwd, self.invite.removeBlankSpace()), response: self.registerResponse).disposed(by: disposebag)
        }
    }
}
