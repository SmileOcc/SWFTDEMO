//
//  YXForgetSetViewModel.swift
//  uSmartOversea
//
//  Created by mac on 2019/3/27.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator

class YXForgetPwdSetViewModel: HUDServicesViewModel  {

    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    typealias Services = HasYXLoginService
    
    var navigator: NavigatorServicesType!

    
    let resetSuccessSubject = PublishSubject<Bool>()
    
    let codeSubject = PublishSubject<Bool>()
    
    var forgetPwdResponse: YXResultResponse<JSONAny>?
    
    var services: Services! {
        didSet {
           
            forgetPwdResponse = { [weak self] (response) in
                
                self?.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    if code == .success {
                        self?.resetSuccessSubject.onNext(true)
                    } else if code == .codeTimeout {
                        
                        if let msg = result.msg {
                            //self?.hudSubject?.onNext(.error(msg, true))
                            YXProgressHUD.showSuccess(msg)
                        }
                        self?.codeSubject.onNext(true)
                        
                   }  else if let msg = result.msg  {
                       // self?.hudSubject.onNext(.error(msg, false))
                        YXProgressHUD.showSuccess(msg)
                    }
                case .failed(_):
                    YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "common_net_error"))
                   // self?.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
        }
    }
    
    var pwd = Variable<String>("")
    var code = ""
    var phone = ""
    var captcha = ""
    var sendCode: (() -> Void)?
    var callBack: (([String]) -> Void)?
    var sourceVC: UIViewController?
    var passWordValid : Observable<Bool>?
    var equePassWordValid : Observable<Bool>?
    var everythingValid : Observable<Bool>?
    
    init(withCode code:String, phone:String, captcha:String, codeCallBack: @escaping () -> Void, callBack: @escaping ([String])->Void,sourceVC:UIViewController?) {
        self.code = code
        self.phone = phone
        self.captcha = captcha
        self.sendCode = codeCallBack
        self.callBack = callBack
        self.sourceVC = sourceVC
    }
    
    func handleInput(passWord: Observable<String>,subPassword: Observable<String>){
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
        
        self.everythingValid = Observable.combineLatest(passTmp, equeTmp) { $0 && $1 }
                    .share(replay: 1)
        
    }
}
