//
//  HCHomeViewModel.swift
//  URLDEMO
//
//  Created by odd on 7/4/22.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import URLNavigator

class HCHomeViewModel: ServicesViewModel, HasDisposeBag {
    
    typealias Services = AppServices
    
    var navigator: NavigatorServicesType!
    
//    var loginResponse: HCResultResponse<JSONAny>?
    var loginResponse: HCResultResponse<HCHomeModel>?

    let disposebag = DisposeBag()

    var services: Services! {
        didSet {
            loginResponse = {[weak self] (response) in
                guard let `self` = self else {return}
                switch response {
                    case .success(let result, let code):
                    switch code {
                    case .success?:
                        
                        let userInfo = result.result

                        func setUserInfo(){
                            if let ccc = userInfo {
                                print("name: \(ccc.banner)")
                            }
                            print("=================")

                            print("=================")
                        }
                        
                        setUserInfo()
                        
                    default:
                        if let msg = result.message {
                            //self.hudSubject.onNext(.error(msg, false))
                            
                        }
                    }
                case .failed(_):
                    print("error")
                    //YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "common_net_error"))
                   // self.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            
                
            }
        }
    }
    
    func testRequest() {
        
//        self.services.loginService.requesttttt(.testRequest("1"), response: loginResponse)

        self.services.loginService.request(.testRequest("1"), response: loginResponse).disposed(by: disposebag)
    }
}
