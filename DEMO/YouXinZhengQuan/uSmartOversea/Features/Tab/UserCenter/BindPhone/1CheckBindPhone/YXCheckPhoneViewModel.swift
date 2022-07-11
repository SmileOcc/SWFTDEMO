//
//  YXCheckPhoneViewModel.swift
//  uSmartOversea
//
//  Created by rrd on 2019/5/14.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import URLNavigator

class YXCheckPhoneViewModel: HUDServicesViewModel {
    
    typealias Services = HasYXUserService & HasYXLoginService
    
    var navigator: NavigatorServicesType!
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    /*验证手机号是否注册
     check-phone/v1 的响应 */
    var checkPhoneResponse: YXResultResponse<CheckPhoneV1Result>?
    let registeredSubject = PublishSubject<Bool>() //已注册的回调
    
    
    var services: Services! {
        didSet {
            /*验证手机号是否注册
             check-phone/v1  的响应*/
            checkPhoneResponse = { [weak self] (response) in
                guard let strongSelf = self else {return}
                strongSelf.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    
                    switch code {
                    case .success?:
                        if let registered = result.data?.registered {
                            if registered {
                                strongSelf.registeredSubject.onNext(true)
                            }else {
                                //绑定手机号
                                let context = YXNavigatable(viewModel: YXFirstBindPhoneViewModel(withCode:strongSelf.code, phone: strongSelf.phone.value, sourceVC: strongSelf.sourceVC, callback: strongSelf.bindCallBack))
                                strongSelf.navigator.push(YXModulePaths.bindPhone.url, context: context)
                            }
                        }
                    case .codeCheckActivation?: //已激活-预注册
                        if let msg = result.msg {
                            strongSelf.hudSubject.onNext(.error(msg, false))
                        }
                        default:
                            if let msg = result.msg {
                                strongSelf.hudSubject.onNext(.error(msg, false))
                        }
                    }
                case .failed(_):
                    self?.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
        }
    }
    
    var code = YXUserManager.shared().defCode
    var phone = Variable<String>("")
    var bindCallBack: (([String: Any])->Void)?
    weak var sourceVC:UIViewController?
    
    init(sourceVC: UIViewController?, callback: (([String: Any])->Void)?) {
        self.sourceVC = sourceVC
        self.bindCallBack = callback
    }
}
