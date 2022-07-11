//
//  YXModifyNickNameViewModel.swift
//  uSmartOversea
//
//  Created by rrd on 2019/5/13.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import URLNavigator

class YXModifyNickNameViewModel: HUDServicesViewModel {
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    typealias Services = HasYXUserService
    
    var navigator: NavigatorServicesType!
    
    var nickName = BehaviorRelay<String>(value: "")
    
    var updateUserInfoResponse: YXResultResponse<YXCommonCodeModel>?
    let successSubject = PublishSubject<Bool>()
    let defaultSubject = PublishSubject<String>()
    
    var services: HasYXUserService! {
        didSet {
            updateUserInfoResponse = {[weak self](response) in
                guard let strongSelf = self else {return}
                
                strongSelf.hudSubject.onNext(.hide)
                switch response {
                case .success(let result , let code):
                    switch code {
                    case .success?:
                        strongSelf.hudSubject.onNext(.message(YXLanguageUtility.kLang(key: "user_saveSucceed"), true))
                        strongSelf.successSubject.onNext(true)
                    default:
                        if let msg = result.msg {
                            strongSelf.defaultSubject.onNext(msg)
                        }
                    }
                case .failed(_):
                    strongSelf.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                    
                }
            }
        }
    }
    
    init() {
        
    }
}
