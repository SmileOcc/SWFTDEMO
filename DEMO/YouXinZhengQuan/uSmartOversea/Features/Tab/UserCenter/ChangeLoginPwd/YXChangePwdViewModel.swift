//
//  YXChangePwdViewModel.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/10.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import URLNavigator

class YXChangePwdViewModel: HUDServicesViewModel  {

    typealias Services = HasYXUserService
    
    var navigator: NavigatorServicesType!
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    let resetSuccessSubject = PublishSubject<Bool>()
    
    var oldPassword = BehaviorRelay<String>(value: "")
    var password = BehaviorRelay<String>(value: "")
    var oldPassWordValid : Observable<Bool>?
    var passWordValid : Observable<Bool>?
    var equePassWordValid : Observable<Bool>?
    var everythingValid : Observable<Bool>?
    var disposeBag = DisposeBag()
    
    var changePwdResponse: YXResultResponse<JSONAny>?
    
    var services: Services! {
        didSet {
            
            self.changePwdResponse = { [weak self] (response) in
                
                self?.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    if code == .success {
                        self?.resetSuccessSubject.onNext(true)
                        YXUserManager.loginOut(request: false)
                    } else if let msg = result.msg  {
                        self?.hudSubject.onNext(.error(msg, false))
                    }
                case .failed(_):
                    self?.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
        
        }
    }
    
    init() {
        
        
    }
    
    func handleInput(oldPassword:Observable<String>,passWord: Observable<String>,subPassword: Observable<String>){
        
        self.oldPassWordValid = oldPassword.map{ $0.count > 0 }.share(replay: 1)
        
//        self.passWordValid = passWord
//            .map { $0.isValidPwd() && $0.count >= 8 && $0.count <= 20 || $0.count == 0}
//                    .share(replay: 1)
        self.passWordValid = passWord
            .map { $0.count >= 0}
                    .share(replay: 1)
        
        self.equePassWordValid = Observable.combineLatest(passWord, subPassword) { $0 == $1 && $0.count > 0 || $1.count == 0}
            .share(replay: 1)
        
//        let passTmp =  passWord
//            .map { $0.isValidPwd() && $0.count >= 8 && $0.count <= 20 }
//            .share(replay: 1)
        let passTmp =  passWord
            .map { $0.count > 0 }
            .share(replay: 1)
        
        let equeTmp = Observable.combineLatest(passWord, subPassword) { $0 == $1 && $0.count > 0}
            .share(replay: 1)
        
        self.everythingValid = Observable.combineLatest(passTmp, equeTmp,oldPassWordValid!) { $0 && $1 && $2 }
                    .share(replay: 1)
        
    }
    
    
    func resetPwdRequest(){
        hudSubject?.onNext(.loading(nil, false))
        let oldPassword = YXUserManager.safeDecrypt(string:self.oldPassword.value)
        let password = YXUserManager.safeDecrypt(string:self.password.value)
        services.userService.request(.changePwd(oldPassword, password: password), response:changePwdResponse).disposed(by: disposeBag)
    }
    
    func gotoFogetPwd(){
        if let phone = YXUserManager.shared().curLoginUser?.phoneNumber,let areacode = YXUserManager.shared().curLoginUser?.areaCode {
            let context = YXNavigatable(viewModel: YXForgetPwdPhoneViewModel(with: areacode, phone: phone, isLogin: true, callBack: {_ in }, loginCallBack: nil, fromVC:nil,sourceVC:nil,email:YXUserManager.shared().curLoginUser?.email ?? "",accoutType: .mobile))
            navigator.push(YXModulePaths.forgetPwdInputPhone.url, context: context)
        }else if let emali = YXUserManager.shared().curLoginUser?.email {
            let context = YXNavigatable(viewModel: YXForgetPwdPhoneViewModel(with: "", phone: "", isLogin: true, callBack: {_ in }, loginCallBack: nil, fromVC:nil,sourceVC:nil,email: emali,accoutType: .email))
            navigator.push(YXModulePaths.forgetPwdInputPhone.url, context: context)
        }else {
            let context = YXNavigatable(viewModel: YXForgetPwdPhoneViewModel(with: "", phone: "", isLogin: true, callBack: {_ in }, loginCallBack: nil, fromVC:nil,sourceVC:nil,email: "",accoutType: .email))
            navigator.push(YXModulePaths.forgetPwdInputPhone.url, context: context)
        }
    }
}
