//
//  YXUserUtility.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/2/1.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXUserUtility: NSObject {
    
    /// 彈出沒有設置交易密碼的對話框
    ///
    /// - Parameters:
    ///   - viewController: 對話框所在的UIViewController
    ///   - successBlock: 設置成功的回調
    ///   - failureBlock: 設置失敗的回調
    ///   - isToastFailedMessage: 當設置或驗證交易密碼時，如果有錯誤消息是否彈出
    ///   - autoLogin: 是否設置完成后自動登錄
    @objc class func noTradePwdAlert(inViewController viewController: UIViewController, successBlock: ((String?) -> Void)?, failureBlock: ((Int, String) -> Void)?, isToastFailedMessage: (() -> Bool)?, autoLogin:Bool, needToken: Bool) {
        
        var tips = YXLanguageUtility.kLang(key: "mine_no_tpwd_sg")
        if YXUserManager.shared().curBroker == .sg {
            tips = YXLanguageUtility.kLang(key: "mine_no_tpwd_sg")
        }else if YXUserManager.shared().curBroker == .nz{
            tips = YXLanguageUtility.kLang(key: "mine_no_tpwd_nz")
        }
        let alertVC = YXAlertViewFactory.noTradePwdAlert(title: YXLanguageUtility.kLang(key: "mine_tpwd_title"), message: tips) {
            failureBlock?(-1, "")
        } relogin: {
            YXTradePwdManager.shared().setTradePwd(successBlock: successBlock, failureBlock: failureBlock, isToastFailedMessage: isToastFailedMessage, viewController: viewController, autoLogin: autoLogin, needToken: needToken)
        }

        viewController.present(alertVC, animated: true, completion: nil)

    }
    
    /// 驗證交易密碼
    ///
    /// - Parameters:
    ///   - viewController: 對話框所在的UIViewController
    ///   - successBlock: 驗證成功的回調
    ///   - failureBlock: 驗證失敗的回調
    ///   - isToastFailedMessage: 當設置或驗證交易密碼時，如果有錯誤消息是否彈出
    class func validateTradePwd(inViewController viewController: UIViewController, successBlock: ((String?) -> Void)?, failureBlock: ((Int, String) -> Void)?, isToastFailedMessage: (() -> Bool)?, needToken: Bool? = false) {
        if viewController.presentedViewController != YXTradePwdManager.shared().pwdAlertController {
            if (YXUserManager.shared().tradePassword()) {
                let alertControlle = YXTradePwdManager.shared().showValidAlert(successBlock: successBlock, failureBlock: failureBlock, isToastFailedMessage: isToastFailedMessage, viewController: viewController, autoLogin: false, needToken: needToken ?? false)
                viewController.present(alertControlle, animated: true, completion: nil)
            } else {
                YXTradePwdManager.shared().checkSetTradePwd(nil) { b in
                    if b {
                        let alertControlle = YXTradePwdManager.shared().showValidAlert(successBlock: successBlock, failureBlock: failureBlock, isToastFailedMessage: isToastFailedMessage, viewController: viewController, autoLogin: false, needToken: needToken ?? false)
                        viewController.present(alertControlle, animated: true, completion: nil)
                    } else {
                        YXUserUtility.noTradePwdAlert(inViewController: viewController, successBlock: nil, failureBlock: nil, isToastFailedMessage: nil, autoLogin: true, needToken: false)
                    }
                }
            }
        }
    }
    
    @objc class func validateTradePwd(inViewController viewController: UIViewController, successBlock: ((String?) -> Void)?, failureBlock: ((Int, String) -> Void)?) {
        YXUserUtility.validateTradePwd(inViewController: viewController, successBlock: successBlock, failureBlock: failureBlock, isToastFailedMessage: nil)
    }
    
    
    
}
