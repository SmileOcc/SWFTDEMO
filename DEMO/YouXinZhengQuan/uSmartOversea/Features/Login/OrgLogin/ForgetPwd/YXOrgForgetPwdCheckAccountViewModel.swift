//
//  YXOrgForgetPwdCheckAccountViewModel.swift
//  uSmartOversea
//
//  Created by 欧冬冬 on 2022/4/14.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator

class YXOrgForgetPwdCheckAccountViewModel: HUDServicesViewModel {
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    typealias Services = HasYXLoginService
    
    var navigator: NavigatorServicesType!

    
    //验证手机号是否注册  check-phone/v1
    var checkPhoneResponse: YXResultResponse<YXOrgCheckAccountModel>?
    let activationSubject = PublishSubject<YXOrgActivateModel>() //激活
    
    let checkAccountSubject = PublishSubject<Bool>() //已校验

    var services: Services! {
        didSet {
            //验证手机号是否注册  check-phone/v1
            
            checkPhoneResponse = { [weak self] (response) in
                guard let `self` = self else {return}
                self.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    let codeValue = result.code
                    if code == .success {
                        self.checkAccountSubject.onNext(true)
//                        if self.isClear {
//                            //有清除
//                            let context = YXNavigatable(viewModel: YXOrgForgetPwdCodeViewModel(withCode: self.areaCode.value, phone: self.mobile.value, isSecure: false, callBack: self.callBack!, sourceVC: self.fromVC))
//                            self.navigator.push(YXModulePaths.orgForgetPwdCode.url, context: context)
//                        }else {
//                            //没有清除
//                            let context = YXNavigatable(viewModel: YXOrgForgetPwdCodeViewModel(withCode: self.areaCode.value, phone: YXUserManager.shared().curLoginUser?.phoneNumber ?? "", isSecure: true, callBack: self.callBack!, sourceVC: self.fromVC))
//                            self.navigator.push(YXModulePaths.orgForgetPwdCode.url, context: context)
//                        }
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
        }
    }
    
//    var phone = BehaviorRelay<String>(value: "")
//    var code = YXUserManager.shared().defCode
    var callBack: (([String]) -> Void)?
    var isLogin = true
    var loginCallBack: (([String: Any])->Void)?
    var sourceVC: UIViewController? //sourceVC
    var fromVC: UIViewController?
    var isClear = false  //带入的手机号，是否被清除了。默认为false
    
    var accoutType = BehaviorRelay<YXMemberAccountType>(value: .email)
    var areaCode = BehaviorRelay<String>(value: YXUserManager.shared().defCode)
    var mobile = BehaviorRelay<String>(value: "")
    var email = BehaviorRelay<String>(value: "")
    
    var mobileHidden = PublishSubject<Bool>()
    var emailHidden = PublishSubject<Bool>()
    var mUsernameValid : Observable<Bool>?
    var eUsernameValid : Observable<Bool>?
    
    let disposebag = DisposeBag()

    
    init(with accoutType:YXMemberAccountType=YXMemberAccountType.mobile, code:String, phone:String, email:String, isLogin: Bool, callBack: (([String])->Void)?, loginCallBack: (([String: Any])->Void)?, fromVC: UIViewController?, sourceVC:UIViewController?) {
        
        self.callBack = callBack
        self.isLogin = isLogin
        self.loginCallBack = loginCallBack
        self.sourceVC = sourceVC
        self.fromVC = fromVC
        
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
        //                    .map { ($0.isValidEmail() || $0.isValidDolphID()) && $0.count > 0}
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
