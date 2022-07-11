//
//  YXOrgForgetPwdCheckAccountViewController.swift
//  uSmartOversea
//
//  Created by 欧冬冬 on 2022/4/14.
//  Copyright © 2022 RenRenDai. All rights reserved.
//
/* 模块：找回密码-第1步
 验证手机号码 */
import UIKit
import Reusable
import RxSwift
import RxCocoa
import SnapKit
import YXKit
import TYAlertController

class YXOrgForgetPwdCheckAccountViewController: YXHKViewController, HUDViewModelBased  /*YXAreaCodeBtnProtocol*/  {
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    
    var viewModel: YXOrgForgetPwdCheckAccountViewModel!
    
    var scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    lazy var headTitleView : YXOrgTitleView = {
        if self.viewModel.accoutType.value == .mobile {
            let view = YXOrgTitleView.init(type: .mobile, title: YXLanguageUtility.kLang(key: "org_reset_account_title"), mobileSubName: YXLanguageUtility.kLang(key: "org_mobile_acount"), emialSubName: YXLanguageUtility.kLang(key: "acount_activate_email"))
            return view
        } else {
            let view = YXOrgTitleView.init(type: .emailOrDolphin, title: YXLanguageUtility.kLang(key: "org_reset_account_title"), mobileSubName: YXLanguageUtility.kLang(key: "org_mobile_acount"), emialSubName: YXLanguageUtility.kLang(key: "acount_activate_email"))
            return view
        }
    }()
    
    lazy var mobileSignInView : YXOrgForgetPwdEmailView = {
        let view = YXOrgForgetPwdEmailView.init(type: .mobile)
        let phoneTextField:YXPhoneTextField = view.acountField as! YXPhoneTextField
        phoneTextField.areaCodeLale.text = "+\(self.viewModel.areaCode.value)"
        return view
    }()
    
    lazy var emailSignInView : YXOrgForgetPwdEmailView = {
        let view = YXOrgForgetPwdEmailView.init(type: .emailOrDolphin)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindHUD()
        bindViewModel()
        initUI()
    }
    
    func bindViewModel() {
//        if YXUserManager.isLogin() {
//            self.mobileSignInView.acountField.textField.isClear = false  //登录状态下，带入手机号需加密。强制设置为 false
//        }
        
        mobileSignInView.acountField.textField.text = viewModel.mobile.value
        emailSignInView.acountField.textField.text = viewModel.email.value
        
        self.viewModel.mobile.bind(to: mobileSignInView.acountField.textField.rx.text).disposed(by: disposeBag)
        self.viewModel.email.bind(to: emailSignInView.acountField.textField.rx.text).disposed(by: disposeBag)
        
        mobileSignInView.acountField.textField.rx.text.orEmpty.bind(to: self.viewModel.mobile).disposed(by: disposeBag)
        emailSignInView.acountField.textField.rx.text.orEmpty.bind(to: self.viewModel.email).disposed(by: disposeBag)
        
        //MARK: - viewModel的响应
        
        viewModel.checkAccountSubject.subscribe(onNext: {[weak self]  msg in
            
            guard let `self` = self else { return }
            
            if self.viewModel.accoutType.value == .email {
                let emailNumber = (self.viewModel.email.value as String).removePreAfterSpace()
                let context = YXNavigatable(viewModel: YXOrgForgetPwdResetViewModel(withCode: "", phone: "", email: emailNumber, isEmail: true, isSecure: true, callBack: self.viewModel.callBack!, sourceVC: self.viewModel.fromVC))
                self.viewModel.navigator.push(YXModulePaths.orgForgetPwdReset.url, context: context)
                
            } else {
                
                let areaCode = self.viewModel.areaCode.value
                let phoneNumber = (self.viewModel.mobile.value as String).removePreAfterSpace()
                let context = YXNavigatable(viewModel: YXOrgForgetPwdResetViewModel(withCode: areaCode, phone: phoneNumber, email: "", isEmail: false, isSecure: true, callBack: self.viewModel.callBack!, sourceVC: self.viewModel.fromVC))
                self.viewModel.navigator.push(YXModulePaths.orgForgetPwdReset.url, context: context)
                
            }
            

        }).disposed(by: disposeBag)
        
        //去激活
        viewModel.activationSubject.subscribe(onNext: {[weak self] model in
            guard let `self` = self else { return }
                        
            let alertView = YXAlertView(message: model.msg)
            alertView.clickedAutoHide = false
            alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: {[weak alertView] action in
                alertView?.hide()
            }))
            alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "login_goToActivate"), style: .default, handler: {[weak alertView, weak self] action in
                guard let `self` = self else { return }
                alertView?.hide()
                
                if self.viewModel.accoutType.value == .email {
                    let context = YXNavigatable(viewModel: YXOrgActivateViewModel(withCode: self.viewModel.areaCode.value, phone: "", email: self.viewModel.email.value, isEmail: true, isExitPwd: model.existPassword, vc: self.viewModel.sourceVC, loginCallBack: self.viewModel.loginCallBack))
                    self.viewModel.navigator.push(YXModulePaths.orgActiviteAccount.url, context: context)
                    
                } else {
                    let context = YXNavigatable(viewModel: YXOrgActivateViewModel(withCode: self.viewModel.areaCode.value, phone: self.viewModel.mobile.value, email: "", isEmail: false, isExitPwd: model.existPassword, vc: self.viewModel.sourceVC, loginCallBack: self.viewModel.loginCallBack))
                    self.viewModel.navigator.push(YXModulePaths.orgActiviteAccount.url, context: context)

                }
                
            }))
            alertView.showInWindow()

        }).disposed(by: disposeBag)
        
        let phoneTextField:YXPhoneTextField = self.mobileSignInView.acountField as! YXPhoneTextField
        phoneTextField.areaCodeBtn.rx.tap.subscribe(onNext:{[weak self] in
            self?.showMoreAreaAlert()
        }).disposed(by: disposeBag)

        headTitleView.didChanage = { [weak self] type in
            if type == .mobile {
                self?.viewModel.handelAccountChanage(title: YXLanguageUtility.kLang(key: "org_mobile_acount"))
            } else {
                self?.viewModel.handelAccountChanage(title: YXLanguageUtility.kLang(key: "acount_title"))
            }
        }
        
        self.viewModel.emailHidden.bind(to: emailSignInView.rx.isHidden).disposed(by: disposeBag)
        self.viewModel.mobileHidden.bind(to: mobileSignInView.rx.isHidden).disposed(by: disposeBag)
        self.viewModel.mUsernameValid?.bind(to: mobileSignInView.signInBtn.rx.isEnabled).disposed(by: disposeBag)
        self.viewModel.eUsernameValid?.bind(to: emailSignInView.signInBtn.rx.isEnabled).disposed(by: disposeBag)
        
        mobileSignInView.acountField.clearBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.viewModel.mobile.accept("")
            self?.mobileSignInView.signInBtn.isEnabled = false
        }).disposed(by: disposeBag)
        
        emailSignInView.acountField.clearBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.viewModel.email.accept("")
            self?.emailSignInView.signInBtn.isEnabled = false
        }).disposed(by: disposeBag)
        
        emailSignInView.signInBtn.rx.tap.subscribe(onNext:{[weak self] in
            guard let `self` = self else { return }
            
            self.viewModel.hudSubject?.onNext(.loading(nil, false))
            var emailBumber = (self.viewModel.email.value as String).removePreAfterSpace()
            emailBumber = YXUserManager.safeDecrypt(string: emailBumber)
            // 登录之前,先校验
            self.viewModel.services.loginService.request(.checkOrgAccount("", "", 2, emailBumber), response: self.viewModel.checkPhoneResponse)
                .disposed(by: `self`.disposeBag)
            
            
        }).disposed(by: disposeBag)
        
        mobileSignInView.signInBtn.rx.tap.subscribe(onNext:{[weak self] in
            guard let `self` = self else { return }

            self.viewModel.hudSubject?.onNext(.loading(nil, false))
            let areaCode = self.viewModel.areaCode.value
            var phoneNumber = (self.viewModel.mobile.value as String).removePreAfterSpace()
            phoneNumber = YXUserManager.safeDecrypt(string: phoneNumber)
            // 登录之前,先校验
            self.viewModel.services.loginService.request(.checkOrgAccount(areaCode, phoneNumber, 1, ""), response: self.viewModel.checkPhoneResponse)
                .disposed(by: `self`.disposeBag)
            
            
        }).disposed(by: disposeBag)
        
        self.viewModel.accoutType.accept(self.viewModel.accoutType.value)
    }
    
    func initUI() {
        if !YXUserManager.isLogin() {
            if self.viewModel.accoutType.value == .mobile {
                mobileSignInView.acountField.textField.becomeFirstResponder()
            } else {
                emailSignInView.acountField.textField.becomeFirstResponder()
            }
        }
        
        view.addSubview(scrollView)
        scrollView.addSubview(headTitleView)
        scrollView.addSubview(mobileSignInView)
        scrollView.addSubview(emailSignInView)
        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeArea.top)
            make.left.right.bottom.equalTo(self.view)
        }
        headTitleView.snp.makeConstraints { make in
            make.top.equalTo(24)
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.height.equalTo(60)
        }
        
        mobileSignInView.snp.makeConstraints { (make) in
            make.top.equalTo(headTitleView.snp.bottom).offset(40)
            make.left.width.equalToSuperview()
            make.height.equalTo(244)

        }
        
        emailSignInView.snp.makeConstraints { (make) in
            make.size.equalTo(mobileSignInView)
            make.top.left.equalTo(mobileSignInView)
        }
        
        //如果登录了
//        if YXUserManager.isLogin() {
//            //viewModel.phone.value = YXUserManager.secretPhone()
//            if viewModel.accoutType.value == .mobile {
//                viewModel.mobile.accept(YXUserManager.secretPhone())
//                viewModel.areaCode.accept(YXUserManager.shared().curLoginUser?.areaCode ?? YXUserManager.shared().defCode)
//
//            } else {
//                viewModel.email.accept(YXUserManager.secretEmail())
//            }
//        }
        
    }
}

extension YXOrgForgetPwdCheckAccountViewController {
    
    
    private func showMoreAreaAlert() {
        let areaCodeModel = YXAreaCodeViewModel()
        areaCodeModel.didSelectSubject.subscribe(onNext: { [weak self] (code) in
            guard let `self` = self else {return}
            let phoneTextField:YXPhoneTextField = self.mobileSignInView.acountField as! YXPhoneTextField
            phoneTextField.areaCodeLale.text = "+\(code)"
            self.viewModel.areaCode.accept(code)
                        
        }).disposed(by: self.disposeBag)
        
        let context = YXNavigatable(viewModel: areaCodeModel)
        self.viewModel.navigator.present(YXModulePaths.areaCodeSelection.url, context: context, animated: true)

    }
    
}
