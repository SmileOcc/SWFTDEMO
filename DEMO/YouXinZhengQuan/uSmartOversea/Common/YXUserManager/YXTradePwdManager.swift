//
//  YXTradePwdManager.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/19.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YXKit
import RxSwift

class YXTradePwdManager: NSObject {
    
    static let instance: YXTradePwdManager = YXTradePwdManager()
    
    lazy var onceCode: Void = {
        netConfig()
    }()
    
    class func shared() -> YXTradePwdManager {
        _ = instance.onceCode
        return instance
    }
    
    var successBlock: ((String?) -> Void)?
    var failureBlock: ((Int, String) -> Void)?
    var isToastFailedMessage: (() -> Bool)?
    weak var viewController: UIViewController!
    var autoLogin = false
    var needToken: Bool = false
    var pwdAlertController: YXPwdAlertController = {
        let alertView = YXPasswordSetAlertView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth-30, height: 192))
        alertView.backgroundColor = UIColor.white
        
        if let vc = YXPwdAlertController(alert: alertView, preferredStyle: .alert) {
            vc.viewWillShowHandler = {[weak alertView] (view) in
                alertView?.passwordResetView.textField.becomeFirstResponder()
            }
            return vc
        }
        
        return YXPwdAlertController()
    }()
    
    let disposeBag = DisposeBag()
    var setTradePwdResponse: YXResultResponse<JSONAny>?
    var hud = YXProgressHUD()
    var pwd = ""
    var setSuccessBlock: ((_ pwd:String) -> ())?
    //展示
    func showValidAlert(successBlock: ((String?) -> Void)?, failureBlock: ((Int, String) -> Void)?, isToastFailedMessage: (() -> Bool)?, viewController:UIViewController, autoLogin: Bool, needToken: Bool = false) -> YXPwdAlertController{
        
        self.successBlock = successBlock
        self.failureBlock = failureBlock
        self.isToastFailedMessage = isToastFailedMessage
        self.viewController = viewController
        self.autoLogin = autoLogin
        self.needToken = needToken
        if let alertView = pwdAlertController.alertView as? YXPasswordSetAlertView {
            alertView.delegate = self
            alertView.alertType = .valid
            alertView.passwordResetView.clearText()
            alertView.dismissBtn.rx.tap.subscribe(onNext: {[weak self] (_) in
                self?.failureBlock?(-1, "")
                self?.dismissPwdAlertController(animated: true)
            }).disposed(by: disposeBag)
        }
        self.pwdAlertController.dismissComplete = {}

        return self.pwdAlertController
    }
    
    func setTradePwd(successBlock: ((String?) -> Void)?, failureBlock: ((Int, String) -> Void)?, isToastFailedMessage: (() -> Bool)?, viewController:UIViewController, autoLogin: Bool, needToken: Bool = false) {
        
        self.successBlock = successBlock
        self.failureBlock = failureBlock
        self.isToastFailedMessage = isToastFailedMessage
        self.viewController = viewController
        self.autoLogin = autoLogin
        self.needToken = needToken

        if let appDelegate = YXConstant.sharedAppDelegate as? YXAppDelegate{
            self.setSuccessBlock = {[weak self] (pwd) in
                if self!.autoLogin {
                    //是否自动登录交易密码，是就调用交易密码登录，successBlock 在登录交易成功后调用，其他block正常调用
                    self?.passwordSetAlertViewDidValidPwd(pwd)
                }else {
                    if let successBlock = self?.successBlock {
                        successBlock(nil)
                    }
                }
            }
            let navigator = appDelegate.navigator
            let context = YXNavigatable(viewModel:YXSetTradePwdViewModel(.set, oldPwd: "", captcha:"", sourceVC: viewController,successBlock: setSuccessBlock))
            navigator.push(YXModulePaths.setTradePwd.url, context: context)
        }
    }
    
    func netConfig() {
        /*http://admin-dev.yxzq.com/user-server/doc/doc.html
        --> 1-APP -->交易业务 --> 第一次设置交易密码
        set-trade-password/v1 */
        setTradePwdResponse = {[weak self] (response) in
            
            guard let strongSelf = self else { return }
            strongSelf.hud.hideHud()
            strongSelf.setTextFieldEnable(enable: true)
            strongSelf.pwdAlertController.dismissComplete = { [weak self] in
                guard let strongSelf = self else { return }
                
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        strongSelf.hud.showSuccess(YXLanguageUtility.kLang(key: "mine_set_success"))
                        YXUserManager.shared().curLoginUser?.tradePassword = true
                        YXUserManager.saveCurLoginUser()
                        YXUserManager.getUserInfo(complete: nil)
                        if strongSelf.autoLogin {
                            //是否自动登录交易密码，是就调用交易密码登录，successBlock 在登录交易成功后调用，其他block正常调用
                            strongSelf.passwordSetAlertViewDidValidPwd(strongSelf.pwd)
                        }else {
                            if let successBlock = strongSelf.successBlock {
                                successBlock(nil)
                            }
                        }
                        break
                    default:
                        if let msg = result.msg {
                            strongSelf.failureBlock?(code?.rawValue ?? -1, msg)
                            if strongSelf.isToastFailedMessage == nil || (strongSelf.isToastFailedMessage != nil && strongSelf.isToastFailedMessage!() == true){
                                strongSelf.hud.showError(msg, in: self?.viewController?.view)
                            }
                        }
                    }
                case .failed(let error):
                    let err = error as NSError
                    strongSelf.failureBlock?(err.code, err.localizedDescription)
                    if strongSelf.isToastFailedMessage == nil || (strongSelf.isToastFailedMessage != nil && strongSelf.isToastFailedMessage!() == true){
                        self?.hud.showError(YXLanguageUtility.kLang(key: "common_net_error"), in: self?.viewController?.view)
                    }
                }
            }
            strongSelf.dismissPwdAlertController(animated: false)
        }
    }
    
    func setTextFieldEnable(enable: Bool) {
        if let alertView = self.pwdAlertController.alertView as? YXPasswordSetAlertView {
            alertView.passwordResetView.textFieldEnable = enable
        }
    }
    
    func dismissPwdAlertController(animated: Bool) {
        if let alertView = self.pwdAlertController.alertView as? YXPasswordSetAlertView {
            alertView.passwordResetView.clearText()
            pwdAlertController.dismissViewController(animated: animated)
        }
    }
    
    func showFrozenAlert(msg :String?) {
        //账户冻结需为强弹窗提示，不是toast
        let alertView = YXAlertView(message: msg)
        alertView.clickedAutoHide = false
        
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_confirm"), style: .default, handler: {[weak alertView] action in
            
            alertView?.hide()
        }))
        alertView.showInWindow()
    }
    
    func pwdAlert(withInfo info: String?, confirmTitle title: String?, isHide: Bool) {
        let alertView = YXAlertView(message: info)
        alertView.clickedAutoHide = false
        alertView.addAction(YXAlertAction(title: title ?? "", style: .cancel, handler: { [weak alertView, weak self] action in
            guard let `self` = self else { return }
            guard let `alertView` = alertView else { return }
            
            alertView.hide()
            
            if !isHide {
                let alertController: YXPwdAlertController? = self.showValidAlert(successBlock: self.successBlock, failureBlock: self.failureBlock, isToastFailedMessage: self.isToastFailedMessage, viewController: self.viewController, autoLogin: self.autoLogin)
                
                if let alertController = alertController {
                    self.viewController?.present(alertController, animated: true)
                }
            }
            
        }))
        
        
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "find_back"), style: .default, handler: { [weak alertView, weak self] action in
            guard let `alertView` = alertView else { return }
            guard let `self` = self else { return }
            
            self.failureBlock?(-1, YXLanguageUtility.kLang(key: "find_back"))
            
            if let appDelegate = YXConstant.sharedAppDelegate as? YXAppDelegate {
                alertView.hide()
                let navigator = appDelegate.navigator
                
                if YXUserManager.shared().curLoginUser?.orgEmailLoginFlag ?? false {
                    let context = YXNavigatable(viewModel: YXOrgRegisterNumberVertifyViewModel(vc: self.viewController))
                    navigator.push(YXModulePaths.orgCheckRegisterNumber.url, context: context)

                } else {
                    
                    let context = YXNavigatable(viewModel: YXAuthenticateViewModel(type:1, vc: self.viewController))
                    navigator.push(YXModulePaths.authenticate.url, context: context)
                }

                
//                appDelegate.appServices.userService.request(.idType, response: { [weak alertView, weak self] (response) in
//                    guard let `alertView` = alertView else { return }
//                    guard let `self` = self else { return }
//
//                    self.hud.hideHud()
//                    switch response {
//                    case .success(let result, let code):
//                        switch code {
//                        case .success?:
//                            // 如果沒有獲取成功，默認使用大陸身份證去找回交易密碼
//                            // 跳转到验证身份证页面
//                            let navigator = appDelegate.navigator
//
//                            let context = YXNavigatable(viewModel: YXAuthenticateViewModel(type: result.data?.identifyType ?? 1, vc: self.viewController))
//                            navigator.push(YXModulePaths.authenticate.url, context: context)
//
//                            alertView.hide()
//                            break
//                        default:
//                            self.hud.showError(result.msg, in: self.viewController.view)
//                        }
//                    case .failed(_):
//                        self.hud.showError(YXLanguageUtility.kLang(key: "common_net_error"), in: self.viewController?.view)
//                    }
//                    } as YXResultResponse<YXIdType>).disposed(by: YXUserManager.shared().disposeBag)
            }
        }))
        
        alertView.showInWindow()
    }
    
    func checkSetTradePwd( _ vc:UIViewController? , _ complit:@escaping (_ isSet:Bool)->())  {
        self.viewController = vc
        if let appDelegate = YXConstant.sharedAppDelegate as? YXAppDelegate {
//            self.hud.showLoading("")
            appDelegate.appServices.userService.request(.getIsSetTradePwd, response: { [weak self] (response) in
                guard let `self` = self else { return }
                
                self.hud.hideHud()
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success:                        
                        var isSet = false
                        if let dic = result.data?.value as? [String: Any], let set = dic["setTradePassword"] as? Bool {
                            isSet = set
                        }
                        YXUserManager.shared().curLoginUser?.tradePassword = isSet
                        YXUserManager.saveCurLoginUser()
                        complit(isSet)
                    default:
                        self.hud.showError(result.msg)
                    }
                case .failed(_):
                        self.hud.showError(YXLanguageUtility.kLang(key: "common_net_error"))
                }
            } as YXResultResponse<JSONAny>).disposed(by: YXUserManager.shared().disposeBag)
        }
    }
    
}

extension YXTradePwdManager: YXPasswordSetAlertViewDelegate {
    /// 輸入完交易密碼后，調用網絡請求接口設置交易密碼
    ///
    /// - Parameter pwd: 設置的密碼
    func passwordSetAlertViewDidSetPwd(_ pwd: String!) {
        self.pwd = pwd
        let pwd = YXUserManager.safeDecrypt(string: pwd)
        setTextFieldEnable(enable: false)
        
        if let appDelegate = YXConstant.sharedAppDelegate as? YXAppDelegate {
            /*http://admin-dev.yxzq.com/user-server/doc/doc.html
             --> 1-APP -->交易业务 --> 第一次设置交易密码
             set-trade-password/v1 */
            appDelegate.appServices.userService.request(.setTradePwd(pwd,YXUserManager.shared().curBroker.brokerNo()), response: YXTradePwdManager.shared().setTradePwdResponse).disposed(by: YXUserManager.shared().disposeBag)
        }
    }
    
    /// 輸入完交易密碼后，調用網絡請求接口驗證交易密碼
    ///
    /// - Parameter pwd: 輸入的密碼
    func passwordSetAlertViewDidValidPwd(_ pwd: String!) {
        self.pwd = pwd
        let pwd = YXUserManager.safeDecrypt(string: pwd)
        setTextFieldEnable(enable: false)
        self.hud.showLoading("")
        
        
        /* getTradePasswordToken
         http://admin-dev.yxzq.com/user-server/doc/doc.html
        --> 1-APP -->交易业务 --> 获取用户交易密码临时认证token
        get-trade-password-token/v1 */
        /* tradePwdLogin
         http://admin-dev.yxzq.com/user-server/doc/doc.html
         --> 1-APP -->交易业务 --> 交易登录
        trade-login/v1 */
        let api: YXUserAPI = self.needToken ? YXUserAPI.getTradePasswordToken(pwd) : YXUserAPI.tradePwdLogin(pwd)
        
        if let appDelegate = YXConstant.sharedAppDelegate as? YXAppDelegate {
            appDelegate.appServices.userService.request(api, response: { [weak self] (response) in
                guard let `self` = self else { return }
                
                self.hud.hideHud()
                self.setTextFieldEnable(enable: true)
                
                self.pwdAlertController.dismissComplete = { [weak self] in
                    guard let `self` = self else { return }
                    
                    switch response {
                    case .success(let result, let code):
                        switch code {
                        case .success?:
                            YXUserManager.shared().isTradeLogin = true
                            
                            //notiTradeChange: 交易密码状态改变
                            NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiTradeChange), object: nil)
                            
                            if (self.successBlock != nil) {
                                var token: String? = nil
                                if self.needToken {
                                    if let data = result.data?.value as? [AnyHashable: Any] {
                                        token = data["token"] as? String
                                    }
                                }
                                self.successBlock!(token)
                            }
                        case .tradePwdError?,
                             .tradePwdError2?:
                            self.pwdAlert(withInfo: result.msg, confirmTitle: YXLanguageUtility.kLang(key: "tpwd_reEnter"), isHide: false)
                        case .tradePwdLockError?,
                             .tradePwdLockError2?,
                             .tradeFrozenError:
                            self.showFrozenAlert(msg: result.msg)
                        default:
    //                        if code == .tradePwdLockError{
    //                            //self.pwdAlert(withInfo: result.msg, confirmTitle: YXLanguageUtility.kLang(key: "common_close"), isHide: true)
    //                            self.showFrozenAlert(msg: result.msg)
    //                        } else if code == .tradeFrozenError {
    //                            self.showFrozenAlert(msg: result.msg)
    //                        } else {
    //
    //                            if self.isToastFailedMessage == nil || (self.isToastFailedMessage != nil && self.isToastFailedMessage!() == true) {
    //                                self.hud.showError(result.msg, in: self.viewController.view)
    //                            }
    //                        }
    //
                            if self.isToastFailedMessage == nil || (self.isToastFailedMessage != nil && self.isToastFailedMessage!() == true) {
                                self.hud.showError(result.msg, in: self.viewController.view)
                            }
                            self.failureBlock?(result.code, result.msg ?? "")
                        }
                    case .failed(let error):
                        let err = error as NSError
                        self.failureBlock?(err.code, err.localizedDescription)
                        if self.isToastFailedMessage == nil || (self.isToastFailedMessage != nil && self.isToastFailedMessage!() == true) {
                            self.hud.showError(err.localizedDescription, in: self.viewController.view)
                        }
                    }
                }
                self.dismissPwdAlertController(animated: false)
                
                } as YXResultResponse<JSONAny>).disposed(by: YXUserManager.shared().disposeBag)
        }
    }
    
    /// 根據不同的錯誤類型彈出不同的提示框
    ///
    /// - Parameters:
    ///   - msg: 對話框上的文案
    ///   - alertType: 對話框的類型
//    func alert(withMsg msg: String!, alertType: YXPasswordSetAlertType) {
//
//        let alertView = YXAlertView(message: msg)
//        alertView.clickedAutoHide = false
//        let alertController = YXAlertController(alert: alertView)
//        
//        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "mine_enter_again"), style: .default, handler: {[weak alertView, weak self, weak alertController] action in
//            guard let `self` = self else { return }
//            alertController?.dismissComplete = {
//                let alertControlle = YXTradePwdManager.shared().showValidAlert(successBlock: self.successBlock, failureBlock: self.failureBlock, isToastFailedMessage: self.isToastFailedMessage, viewController: self.viewController, autoLogin: self.autoLogin)
//                self.viewController.present(alertControlle, animated: true, completion: nil)
//            }
//            alertView?.hide()
//        }))
//        
//        viewController?.present(alertController!, animated: true, completion: nil)
//    }
}
