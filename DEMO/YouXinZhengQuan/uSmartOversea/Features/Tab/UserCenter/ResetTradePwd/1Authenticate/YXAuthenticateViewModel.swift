//
//  YXAuthenticateViewModel.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/12.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import URLNavigator

class YXAuthenticateViewModel: HUDServicesViewModel  {

    typealias Services = HasYXUserService
    
    var navigator: NavigatorServicesType!
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    /* 校验身份证
     verify-identify-id/v1 */
    var checkIdResponse: YXResultResponse<JSONAny>?
    var checkSuccessSubject = PublishSubject<Bool>()
    
    var type = 2 //1.大陆身份证;2.香港身份证;3.护照;4.香港永久居民身份证
    
    var vc: UIViewController?
    
    var services: Services! {
        didSet {
            /* 校验身份证
             verify-identify-id/v1 */
            checkIdResponse = {[weak self] (response) in
                
                self?.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    if code == .success {
                        self?.checkSuccessSubject.onNext(true)                        
                    } else if let msg = result.msg  {
                        self?.hudSubject.onNext(.error(msg, false))
                    }
                case .failed(_):
                    self?.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
        }
    }
    
    init(type: Int, vc: UIViewController?) {
        self.type = type
        self.vc = vc
    }
}
