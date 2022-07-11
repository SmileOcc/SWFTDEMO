//
//  YXFirstSetTradePwdViewModel.swift
//  uSmartOversea
//
//  Created by ysx on 2021/7/5.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator

enum YXSetTradePwdType {
    case reSet
    case update
    case set
    
    func title() -> String {
        switch self {
        case
            .set,
            .reSet:
            return YXLanguageUtility.kLang(key: "mine_set_tpwd")
        case .update:
            return YXLanguageUtility.kLang(key: "mine_set_tpwd")
        }
    }
}

class YXSetTradePwdViewModel: HUDServicesViewModel {
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    typealias Services = HasYXUserService & HasYXLoginService
    var navigator: NavigatorServicesType!
    var type : YXSetTradePwdType = .update
    //首次设置
    var setTradePwdResponse: YXResultResponse<JSONAny>?
    var pwdSuccessSubject = PublishSubject<Bool>()
    
    /*修改交易密码
     update-trade-password/v1 */
    var changePwdResponse: YXResultResponse<JSONAny>?
    
    /*重置交易密码
     reset-trade-password/v1 */
    var resetPwdResponse: YXResultResponse<JSONAny>?
    
    
    var successBlock :((_ pwd:String) -> ())?
    
    
    var services: Services! {
        didSet{
            
            setTradePwdResponse = {[weak self] (response) in
                self?.hudSubject.onNext(.hide)
                guard let strongSelf = self else { return }
                strongSelf.hudSubject.onNext(.hide)
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        strongSelf.hudSubject.onNext(.success(YXLanguageUtility.kLang(key: "mine_set_success"), true))
//                        strongSelf.hud.showSuccess(YXLanguageUtility.kLang(key: "mine_set_success"))
                        YXUserManager.shared().curLoginUser?.tradePassword = true
                        YXUserManager.saveCurLoginUser()
//                        YXUserManager.getUserInfo(complete: nil)
                        strongSelf.pwdSuccessSubject.onNext(true)
                    case .tradePwdSetted:
                        if let msg = result.msg {
                            strongSelf.hudSubject.onNext(.error(msg, true))
                        }
                        YXUserManager.shared().curLoginUser?.tradePassword = true
                        YXUserManager.saveCurLoginUser()
                        strongSelf.pwdSuccessSubject.onNext(true)
                    default:
                        if let msg = result.msg {
                            strongSelf.hudSubject.onNext(.error(msg, true))
                        }
                    }
                case .failed(_):
//                    let err = error as NSError
                    strongSelf.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), true))
//                    self?.hud.showError(YXLanguageUtility.kLang(key: "common_net_error"), in: self?.viewController?.view)
//                    if strongSelf.isToastFailedMessage == nil || (strongSelf.isToastFailedMessage != nil && strongSelf.isToastFailedMessage!() == true){
//                        self?.hud.showError(YXLanguageUtility.kLang(key: "common_net_error"), in: self?.viewController?.view)
//                    }
                }
            }
            
            changePwdResponse = {[weak self] (response) in
                
                self?.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                       // self?.hudSubject.onNext(.success("Trade password has been changed successfully.", true))
                        YXProgressHUD.showError(YXLanguageUtility.kLang(key: "trade_password_changed_successfully"), in: UIViewController.current().view, hideAfterDelay: 1.0)
//                        self?.hudSubject.onNext(.success(YXLanguageUtility.kLang(key: "mine_change_succeed"), true))
                        self?.pwdSuccessSubject.onNext(true)
                    default:
                        if let msg = result.msg {
                            self?.hudSubject.onNext(.error(msg, false))
                        }
                    }
                case .failed(_):
                    self?.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
            /*重置交易密码
             reset-trade-password/v1 */
            resetPwdResponse = {[weak self] (response) in
                
                self?.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        YXProgressHUD.showError(YXLanguageUtility.kLang(key: "trade_password_changed_successfully"), in: UIViewController.current().view, hideAfterDelay: 1.0)
                       // self?.hudSubject.onNext(.success(YXLanguageUtility.kLang(key: "mine_reset_tradePwd_succeed"), true))
                        self?.pwdSuccessSubject.onNext(true)
                    default:
                        if let msg = result.msg {
                            self?.hudSubject.onNext(.error(msg, false))
                        }
                    }
                case .failed(_):
                    self?.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
        }
    }
    
    var passwordRelay = BehaviorRelay<String>(value: "")
    var rePasswordRelay = BehaviorRelay<String>(value: "")
    var equePassWordValid : Observable<Bool>?
    var everythingValid : Observable<Bool>?
    var disposeBag = DisposeBag()
    var oldPwd = ""
    var captcha = ""
    var brokerNo: String?
    var sourceVC : UIViewController?
    
    
    
    init(_ type:YXSetTradePwdType,oldPwd:String,captcha:String,sourceVC:UIViewController?,successBlock:((_ pwd:String)->())?) {
        self.type = type
        self.handViewBind()
        self.oldPwd = oldPwd
        self.captcha = captcha
        self.sourceVC = sourceVC
        self.successBlock = successBlock
    }
    
    func handViewBind(){
        
//        self.equePassWordValid = Observable.combineLatest(passwordRelay, rePasswordRelay) { $0 == $1 && $0.count > 0 || $1.count == 0}
//            .share(replay: 1)
        
        self.everythingValid = Observable.combineLatest(passwordRelay, rePasswordRelay) {  $1.count == 6  && $0.count == 6 }
            .share(replay: 1)
        
    }
}
