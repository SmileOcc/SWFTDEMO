//
//  HCLoginViewModel.swift
//  URLDEMO
//
//  Created by odd on 7/4/22.
//

import UIKit
import URLNavigator
import RxSwift
import RxCocoa

class HCLoginViewModel: ServicesViewModel {

    var navigator: NavigatorServicesType!

    typealias Services = HasHCLoginService
    
    let loginSuccessSubject = PublishSubject<Bool>()//登录成功回调

    var loginResponse: HCResultResponse<HCLoginUser>?
    let disposebag = DisposeBag()

    var services: Services! {
        didSet {
            loginResponse = {[weak self] (response) in
                guard let `self` = self else {return}
                switch response {
                    case .success(let result, let code):
                    switch code {
                    case .success?:
                        func setUserInfo(){
                            self.loginSuccessSubject.onNext(true)
                        }
                    default:
//                        if let msg = result.msg {
//                            //self.hudSubject.onNext(.error(msg, false))
//
//                        }
                        print("")
                    }
                case .failed(_):
                    print("error")
                    //YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "common_net_error"))
                   // self.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            
                
            }
        }
    }
    
    func mobileLogin() {
        services.loginService.request(.checkPhone("86", "13122223333"), response: loginResponse).disposed(by: disposebag)
    }
}
