//
//  YXIBAcountViewModel.swift
//  uSmartOversea
//
//  Created by ysx on 2021/7/16.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxCocoa
import URLNavigator
import RxSwift

class YXIBAcountViewModel: HUDServicesViewModel {
    typealias Services = HasYXUserService & HasYXLoginService
    var navigator: NavigatorServicesType!
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    var sendCaptchaResponse: YXResultResponse<JSONAny>?
    let codeSubject = PublishSubject<String>()
    let codeErrorSubject = PublishSubject<String>()

    var checkCaptchaResponse: YXResultResponse<JSONAny>?
    let checkSubject = PublishSubject<(String,String)>()
    
    var captcha = BehaviorRelay<String>.init(value: "")
    var vc: UIViewController?
    
    var services: Services! {
        didSet {
            sendCaptchaResponse = {[weak self] (response) in
                self?.hudSubject.onNext(.hide)
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        if let dic = result.data?.value as? Dictionary<AnyHashable, Any> {
                            if let captcha = dic["captcha"] as? String {
                                self?.codeSubject.onNext(captcha)
                            } else {
                                self?.codeSubject.onNext("")
                            }
                        } else {
                            self?.codeSubject.onNext("")
                        }
                        break
                    default:
                        if let msg = result.msg {
                            self?.codeErrorSubject.onNext(msg)
                        }
                    }
                case .failed(_):
                    self?.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
          
            checkCaptchaResponse = {[weak self] (response) in
                
                self?.hudSubject.onNext(.hide)
    
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        if let dic = result.data?.value as? Dictionary<AnyHashable, Any> {
                            if let originalPassword = dic["originalPassword"] as? String ,let userId = dic["userId"] as? String{
                                self?.checkSubject.onNext((originalPassword,userId))
                            } else {
                                self?.checkSubject.onNext(("",""))
                            }
                        } else {
                            
                        }
                        break
                    default:
                       
                        if let msg = result.msg {
//                            self?.hudSubject.onNext(.error(msg, false))
                            self?.codeErrorSubject.onNext(msg)
                        }
                    }
                case .failed(_):
                    self?.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
        }
    }
}
