//
//  YXFeedbackViewModel.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/13.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import QCloudCOSXML
import URLNavigator

class YXFeedbackViewModel: HUDServicesViewModel  {

    typealias Services = HasYXUserService & HasYXGlobalConfigService
    var navigator: NavigatorServicesType!
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    var uploadPicSubject = PublishSubject<Bool>()
    var successSubject = PublishSubject<Bool>()
    
    var feedbackResponse: YXResultResponse<JSONAny>?
    
    let MaxCount = 500
    var imageUrlArr = [String]()
    var putRequestsArr = [QCloudCOSXMLUploadObjectRequest<AnyObject>]()
    var isUploadSuccess = true
    
    var services: Services! {
        didSet {
            
            feedbackResponse = {[weak self] (response) in
                
                self?.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    if code == .success {
                        self?.hudSubject.onNext(.success(YXLanguageUtility.kLang(key: "common_submit_success"), true))
                        self?.successSubject.onNext(true)
                    } else if let msg = result.msg  {
                        self?.hudSubject.onNext(.error(msg, false))
                        
                    }
                case .failed(_):
                    self?.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
            
        }
        
    }
    
    var code = YXUserManager.shared().defCode
}
