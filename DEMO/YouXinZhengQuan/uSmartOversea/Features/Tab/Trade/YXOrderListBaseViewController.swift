//
//  YXOrderListBaseViewController.swift
//  uSmartOversea
//
//  Created by ZhiYun Huang on 2019/5/20.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

//class YXOrderListBaseViewController: YXHKTableViewController {
//    
//    let tradingViewModel = YXTradingViewModel()
//    
//    func deleteOrder(item :YXOrderItem,completed : (()->Void)? = nil) {
//        
////        tradingViewModel.setOrder(with: item, updateQuote: false)
//        tradingViewModel.securityType = .stock
//        tradingViewModel.order.sessionType = .delete
//        
//        guard isTradingUnlocked.value == true else {
//            
//            showTradingLoginAlert(completed:completed)
//            
//            return
//        }
//        
//        showDeleteConfirmAlert(completed:completed)
//        
//    }
//    
//    func deleteBondOrder(item :YXBondOrderModel, tradeToken: String, completed : (()->Void)? = nil) {
//        
//        tradingViewModel.bondOrder = item
//        tradingViewModel.tradeToken = tradeToken
//        tradingViewModel.securityType = .bond
//        tradingViewModel.order.sessionType = .delete
//        
//        guard isTradingUnlocked.value == true else {
//            
//            showTradingLoginAlert(completed:completed)
//            
//            return
//        }
//        
//        showDeleteConfirmAlert(completed:completed)
//        
//    }
//    
//    //弹出交易登录框
//    func showTradingLoginAlert(completed : (()->Void)? = nil, confirmed :Bool = false) {
//        
//        var type = YXPasswordSetAlertType.valid
//        
//        if YXUserManager.shared().curLoginUser?.tradePassword != true {
//            type = .pwd
//            
//            if !confirmed {
//                
//                let alertView: YXAlertView = YXAlertView.init(title: YXLanguageUtility.kLang(key: "traiding_pwd_setting_message"), message: nil)
//                alertView.clickedAutoHide = false
//                let alertController = YXAlertController.init(alert: alertView)!
//                
//                alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_isOK"), style: .default, handler: { [weak self, weak alertView, weak alertController](action) in
//                    alertController?.dismissComplete = {
//                        self?.showTradingLoginAlert(completed: completed, confirmed: true)
//                    }
//                    alertView?.hide()
//                    
//                }))
//                let vc = UIViewController.current()
//                vc.present(alertController, animated: true, completion: nil)
//            }
//        }
//        
//        let ctrl = YXTradePwdManager.shared().show(type: type, successBlock: { [weak self] (_) in
//            
//            isTradingUnlocked.value = true
//            self?.showDeleteConfirmAlert(completed: completed)
//            
//            }, failureBlock: {(Int, String) in
//                
//        }, isToastFailedMessage: nil, viewController: self, autoLogin: true)
//        
//        present(ctrl, animated: true, completion: nil)
//    }
//    
//    func createOrUpdateOrder(_ forceEntrustFlag:Bool, completed :(()->Void)? = nil) {
//        
//        let hud = YXProgressHUD()
//        hud.showLoading(nil)
//        
//        _ = tradingViewModel.createOrUpdateOrder(forceEntrustFlag).subscribe(onSuccess: { [weak self] (nextStep) in
//            
//            hud.hideHud()
//            //如果需要登录
//            if nextStep.next == .login {
//                self?.showTradingLoginAlert(completed: {[weak self] () in
//                    self?.createOrUpdateOrder(false)
//                })
//            }
//            else if nextStep.next == .outPriceRange {
//                // 410207、410211 和 407295（9倍24档）的逻辑一样
//                self?.showOutPriceRangeAlert(msg: nextStep.msg)
//            }
//            else {
//                completed?()
//                
//                var title = YXLanguageUtility.kLang(key: "trading_alert_cancel_order_success")
//                if self?.tradingViewModel.order.curOrderType.value == .condition {
//                    title = YXLanguageUtility.kLang(key: "trading_alert_cancel_cond_order_success")
//                }
//                YXProgressHUD.showSuccess(title)
//            }
//            
//            
//            }, onError: {(error) in
//                
//                hud.hideHud()
//                completed?()
//                
//                if let err = error as? YXError {
//                    
//                    switch err {
//                    case .businessError(_, let msg):
//                        YXProgressHUD.showError(msg)
//                    default: break
//                    }
//                    
//                } else {
//                    YXProgressHUD.showError((error as NSError).localizedDescription)
//                }
//        }).disposed(by: disposeBag)
//    }
//    
//    //展示提交失败弹窗
//    func showFailedAlert(msg :String?) {
//        
//        let alertView: YXAlertView = YXAlertView.init(title: YXLanguageUtility.kLang(key: "newStock_cancel_success"), message: msg)
//        
//        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_iknow"), style: .default, handler: { [weak alertView](action) in
//            alertView?.hide()
//        }))
//        let alertController = YXAlertController.init(alert: alertView)!
//        let vc = UIViewController.current()
//        vc.present(alertController, animated: true, completion: nil)
//    }
//    
//    //展示确认撤销弹窗
//    func showDeleteConfirmAlert(completed :(()->Void)? = nil) {
//        
//        var title = YXLanguageUtility.kLang(key: "trading_alert_cancel_order_title")
//        var confirmBtnTitle = YXLanguageUtility.kLang(key: "trading_alert_cancel_order_confirm")
//        
//        if self.tradingViewModel.order.curOrderType.value == .condition {
//            title = YXLanguageUtility.kLang(key: "trading_alert_cancel_cond_order_title")
//            confirmBtnTitle = YXLanguageUtility.kLang(key: "trading_alert_cancel_cond_order_confirm")
//        }
//        
//        let alertView: YXAlertView = YXAlertView(title: title, message: nil)
//        alertView.clickedAutoHide = false
//       let alertController = YXAlertController.init(alert: alertView)!
//        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: { [weak alertView](action) in
//            alertView?.hide()
//        }))
//        
//        alertView.addAction(YXAlertAction(title: confirmBtnTitle, style: .default, handler: { [weak alertView, weak self, weak alertController](action) in
//            alertController?.dismissComplete = {
//                self?.createOrUpdateOrder(false,completed: completed)
//            }
//            alertView?.hide()
//            
//        }))
//        
//        let vc = UIViewController.current()
//        vc.present(alertController, animated: true, completion: nil)
//    }
//    
//    
//    //超出价格档位校验设置范围，需要弹框提示
//    func showOutPriceRangeAlert(msg: String?) {
//        let alertView: YXAlertView = YXAlertView.init(title: YXLanguageUtility.kLang(key: "newStock_tips"), message: msg)
//        alertView.clickedAutoHide = false
//        let alertController = YXAlertController.init(alert: alertView)!
//        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: { [weak alertView](action) in
//            alertView?.hide()
//            self.presentedViewController?.dismiss(animated: true, completion: nil)
//        }))
//        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "trading_continue_submit"), style: .default, handler: { [weak alertView, weak self, weak alertController] (action) in
//            alertController?.dismissComplete = {
//                self?.createOrUpdateOrder(true,completed: {
//                    self?.presentedViewController?.dismiss(animated: true, completion: nil)
//                })
//            }
//            alertView?.hide()
//        }))
//        
//        let vc = UIViewController.current()
//        vc.present(alertController, animated: true, completion: nil)
//    }
//}
