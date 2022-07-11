//
//  YXOrgRegisterNumberVertifyViewModel.swift
//  uSmartOversea
//
//  Created by 欧冬冬 on 2022/4/21.
//  Copyright © 2022 RenRenDai. All rights reserved.
//
import UIKit
import RxSwift
import RxCocoa
import URLNavigator

class YXOrgRegisterNumberVertifyViewModel: HUDServicesViewModel {
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    typealias Services = HasYXLoginService
    var navigator: NavigatorServicesType!

    var checkResultResponse: YXResultResponse<JSONAny>?
    let checkAccountSubject = PublishSubject<Bool>() //已校验

    var services: Services! {
        didSet {
            //发送验证码 响应
            checkResultResponse  = { [weak self] (response) in
                guard let strongSelf = self else {return}
                
                strongSelf.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    if code == .success {
                        strongSelf.checkAccountSubject.onNext(true)
                    }  else if let msg = result.msg  {
                        strongSelf.hudSubject.onNext(.error(msg, false))
                    }
                case .failed(_):
                    strongSelf.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
            
        }
    }
    
    var idCode = BehaviorRelay<String>(value: "")
    var idCodeValid : Observable<Bool>?

    var sourceVC: UIViewController?
    init(vc: UIViewController?) {
        self.sourceVC = vc
        self.idCodeValid = self.idCode.asObservable()
                    .map { $0.count > 0 }
                    .share(replay: 1)
    }
}
