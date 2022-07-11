//
//  YXForgetSetViewController.swift
//  uSmartOversea
//
//  Created by mac on 2019/3/27.
//  Copyright © 2019 RenRenDai. All rights reserved.
//
/*模块：找回密码--第3步
 设置新密码 */
import UIKit
import Reusable
import RxSwift
import RxCocoa
import SnapKit

import YXKit

class YXForgetPwdSetViewController: YXHKViewController, HUDViewModelBased {
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    
    var viewModel: YXForgetPwdSetViewModel!
    
    var scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    var titleLable : UILabel = {
        let lab = UILabel.init()
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        lab.textColor = UIColor.qmui_color(withHexString: "#1A1A21")
        lab.textAlignment = .left
        lab.text = YXLanguageUtility.kLang(key: "reset_password")
        return lab
    }()
    
    var tipLable : UILabel = {
        let lab = UILabel.init()
        lab.textColor = QMUITheme().textColorLevel2()
        lab.textAlignment = .left
        lab.text = YXLanguageUtility.kLang(key: "password_tip")
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        return lab
    }()
    
    var resetPwdView : YXResetPasswordView = {
        let resetView = YXResetPasswordView.init(frame: .zero)
        return resetView
    }()
    
    
    func setupNavigationBar() {
        //导航栏右按钮
        let signinItme = UIBarButtonItem.qmui_item(withTitle: YXLanguageUtility.kLang(key: "sign_up"), target: self, action: nil);
        
        signinItme.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            let context = YXNavigatable(viewModel: YXSignUpViewModel.init(withCode: "", phone: "", sendCaptchaType: .type101, vc: self, loginCallBack: nil),userInfo: nil)
            
            self.viewModel.navigator.push(YXModulePaths.signUp.url, context: context)
            }.disposed(by: self.disposeBag)
        navigationItem.rightBarButtonItems = [signinItme]
        navigationItem.rightBarButtonItem?.tintColor = QMUITheme().themeTextColor()
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindHUD()
        initUI()
        bindViewModel()
        setupNavigationBar()
    }
    
    func bindViewModel() {

//        //输入框绑定viewModel.pwd
//        pwdInputView.textField.rx.text.orEmpty.bind(to: self.viewModel.pwd).disposed(by: disposeBag)
        //重设成功 的回调
        self.viewModel.resetSuccessSubject.subscribe(onNext: { [weak self] success in
            self?.resetSuccess()
        }).disposed(by: disposeBag)
        //抱歉，验证码已过期，请重新获取 的处理
        self.viewModel.codeSubject.subscribe(onNext: { [weak self] success in
            
            if let sendCode = self?.viewModel.sendCode {
                sendCode()
                self?.navigationController?.popViewController(animated: true)
            }
            
        }).disposed(by: disposeBag)
        
        if let fillPhone = self.viewModel.callBack {
            fillPhone([self.viewModel.phone, self.viewModel.code])
        }
        
        
        self.viewModel.handleInput(passWord:resetPwdView.orgPassWordField.textField.rx.text.orEmpty.asObservable(),
                                   subPassword:resetPwdView.subPassWordField.textField.rx.text.orEmpty.asObservable())
        self.viewModel.everythingValid?.bind(to: resetPwdView.resetBtn.rx.isEnabled).disposed(by: disposeBag)
        self.viewModel.passWordValid?.bind(to: resetPwdView.errorTipLabel.rx.isHidden).disposed(by: disposeBag)
        self.viewModel.equePassWordValid?.bind(to: resetPwdView.subErrorTipLabel.rx.isHidden).disposed(by: disposeBag)
        
        resetPwdView.resetBtn.rx.tap.subscribe(onNext:{[weak self] in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.hudSubject.onNext(.loading(nil, false))
            let areaCode = strongSelf.viewModel.code
            let phoneNumber = YXUserManager.safeDecrypt(string:strongSelf.viewModel.phone.removePreAfterSpace())
            let captcha = strongSelf.viewModel.captcha.removePreAfterSpace()
            let password = YXUserManager.safeDecrypt(string: strongSelf.resetPwdView.subPassWordField.textField.text ?? "")
            strongSelf.viewModel.services.loginService.request(.resetPwd(areaCode, phoneNumber, captcha, password), response: strongSelf.viewModel.forgetPwdResponse).disposed(by: strongSelf.disposeBag)
        }).disposed(by: disposeBag)
    }
    
    func initUI() {
        
       // self.pwdInputView.textField.becomeFirstResponder()
        
        self.view.addSubview(scrollView)

        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeArea.top)
            make.left.right.bottom.equalTo(self.view)
        }

        
        scrollView.addSubview(titleLable)
        scrollView.addSubview(tipLable)
        scrollView.addSubview(resetPwdView)
        
        titleLable.snp.makeConstraints { (make) in
            make.left.equalTo(30)
            make.top.equalTo(24)
            make.height.equalTo(24)
            make.width.equalTo(YXConstant.screenWidth - 60)
        }
        
        tipLable.snp.makeConstraints { (make) in
            make.left.right.equalTo(titleLable)
            make.top.equalTo(titleLable.snp.bottom).offset(12)
            make.height.equalTo(12)
            
        }
        
        resetPwdView.snp.makeConstraints { (make) in
            make.top.equalTo(tipLable.snp.bottom).offset(60)
            make.height.equalTo(340)
            make.width.equalToSuperview()
        }
        
    }
    //重设成功
    func resetSuccess() {
        YXUserManager.loginOut(request: false)
        
        self.view.endEditing(true)
        //【登录密码重置成功，请重新登录】
        let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "login_resetPwdSuccess"))
        alertView.clickedAutoHide = false
        //【取消】
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: {[weak alertView,self] action in
            alertView?.hide()
            if let vc = self.viewModel.sourceVC {
                //未登录状态，一般是从 登录页面进来的。
                self.navigationController?.popToViewController(vc, animated: true)
            } else {
                /* 模块：修改登录密码- 修改登录密码 的 【忘记密码】 的取消返回。
                 已登录状态。   返回到YXUserCenterViewController，返回后已经是未登录状态了。*/
                let allViewControllers = self.navigationController?.viewControllers
                for vc in allViewControllers ?? [] {
                    if vc.isKind(of: YXUserCenterViewController.self) {
                        self.navigationController?.popToViewController(vc, animated: true)
                        return
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: ["index" : YXTabIndex.market])
            }
        }))
        //【重新登录】
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "login_reloginTip"), style: .default, handler: {[weak alertView] action in
            alertView?.hide()
            //
            let allViewControllers = self.navigationController?.viewControllers
            //未登录状态，一般是从 登录页面进来的。
            for vc in allViewControllers ?? [] {
                if vc.isKind(of: YXDefaultLoginViewController.self) {
                    self.navigationController?.popToViewController(vc, animated: true)
                    return
                }
            }
            /* 模块：修改登录密码- 修改登录密码 的 【忘记密码】 的的【重新登录】
             已登录状态。   返回到YXUserCenterViewController，返回后再跳转到登录页面。*/
            for vc in allViewControllers ?? [] {
                if vc.isKind(of: YXUserCenterViewController.self) {
                    self.navigationController?.popToViewController(vc, animated: false)
                    NotificationCenter.default.post(name: NSNotification.Name("goLogin"), object: nil)
                    return
                }
            }
        }))
        alertView.showInWindow()
    }
    
}
