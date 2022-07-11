//
//  YXPromotionMsgViewModel.swift
//  uSmartOversea
//
//  Created by Mac on 2019/8/22.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import URLNavigator

class YXPromotionMsgViewModel: ServicesViewModel, HUDServicesViewModel {
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    typealias Services = HasYXUserService
    
    var navigator: NavigatorServicesType!
    
    var promotValue = YXPromotionValue()
    
    var curUserResponse: YXResultResponse<YXLoginUser2>?
    let resultSubject = PublishSubject<Bool>()
    
    var modifyResponse: YXResultResponse<JSONAny>?
    let modifySubject = PublishSubject<(Bool, String)>()
    
    var curModifyType: YXPromotionMsgType = .phone
    
    var services: Services! {
        didSet {
            
            curUserResponse =  { [weak self] (response) in
                guard let strongSelf = self else { return }
                strongSelf.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        let userModel = result.data
                        if userModel?.phoneSet == 0 {
                            strongSelf.promotValue.phone = false
                        }
                        if userModel?.smsSet == 0 {
                            strongSelf.promotValue.sms = false
                        }
                        if userModel?.emailSet == 0 {
                            strongSelf.promotValue.email = false
                        }
                        if userModel?.mailSet == 0 {
                            strongSelf.promotValue.mail = false
                        }
                        
                        strongSelf.resultSubject.onNext(true)
                    default:
                        if let msg = result.msg {
                            strongSelf.hudSubject.onNext(.error(msg, false))
                        }
                    }
                case .failed(_):
                    strongSelf.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
            
            
            
            modifyResponse =  { [weak self] (response) in
                guard let strongSelf = self else { return }
                strongSelf.hudSubject.onNext(.hide)
                
                switch response {
                case .success(_, let code):
                    
                    switch code {
                    case .success?:
                        strongSelf.modifySubject.onNext((true, YXLanguageUtility.kLang(key: "user_saveSucceed")))
                    default:
                        strongSelf.modifySubject.onNext((false, YXLanguageUtility.kLang(key: "common_save_failed")))
                    }
                case .failed(_):
                    strongSelf.modifySubject.onNext((false, YXLanguageUtility.kLang(key: "common_net_error")))
                }
            }
            
        }
    }
    
}
