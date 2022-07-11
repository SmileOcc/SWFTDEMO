//
//  YXOrgCheckActivateViewController.swift
//  uSmartOversea
//
//  Created by 欧冬冬 on 2022/4/18.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXOrgCheckActivateViewController: YXHKViewController, HUDViewModelBased  /*YXAreaCodeBtnProtocol*/  {
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    
    var viewModel: YXOrgCheckActivateViewModel!
    
    var scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    lazy var headTitleView : YXOrgTitleView = {
        if self.viewModel.accoutType.value == .mobile {
            let view = YXOrgTitleView.init(type: .mobile, title: YXLanguageUtility.kLang(key: "org_activate_title"), mobileSubName: YXLanguageUtility.kLang(key: "org_mobile_acount"), emialSubName: YXLanguageUtility.kLang(key: "acount_activate_email"))
            return view
        } else {
            let view = YXOrgTitleView.init(type: .emailOrDolphin, title: YXLanguageUtility.kLang(key: "org_activate_title"), mobileSubName: YXLanguageUtility.kLang(key: "org_mobile_acount"), emialSubName: YXLanguageUtility.kLang(key: "acount_activate_email"))
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

        mobileSignInView.acountField.textField.text = viewModel.mobile.value
        emailSignInView.acountField.textField.text = viewModel.email.value
        
        self.viewModel.mobile.bind(to: mobileSignInView.acountField.textField.rx.text).disposed(by: disposeBag)
        self.viewModel.email.bind(to: emailSignInView.acountField.textField.rx.text).disposed(by: disposeBag)
        
        mobileSignInView.acountField.textField.rx.text.orEmpty.bind(to: self.viewModel.mobile).disposed(by: disposeBag)
        emailSignInView.acountField.textField.rx.text.orEmpty.bind(to: self.viewModel.email).disposed(by: disposeBag)
        
        
        //MARK: - viewModel的响应
        
        //未注册 ->去个人登录页
        viewModel.jumpPersonAccontSubject.subscribe(onNext: { [weak self] msg in
            guard let `self` = self else { return }
            self.showNoRegisterAccountAlert(withMsg: msg)
        }).disposed(by: disposeBag)
        
        //已经激活
        viewModel.checkAccountSubject.subscribe(onNext: {[weak self] model in
            guard let `self` = self else { return }
            self.showHadActivateAlert(withMsg: "")

        }).disposed(by: disposeBag)
        
        //未激活
        viewModel.activationSubject.subscribe(onNext: {[weak self] model in
            guard let `self` = self else { return }
            
            if self.viewModel.accoutType.value == .email {
                let context = YXNavigatable(viewModel: YXOrgActivateViewModel(withCode: self.viewModel.areaCode.value, phone: "", email: self.viewModel.email.value, isEmail: true, isExitPwd: model.existPassword, vc: self.viewModel.vc, loginCallBack: self.viewModel.loginCallBack))
                self.viewModel.navigator.push(YXModulePaths.orgActiviteAccount.url, context: context)
                
            } else {
                let context = YXNavigatable(viewModel: YXOrgActivateViewModel(withCode: self.viewModel.areaCode.value, phone: self.viewModel.mobile.value, email: "", isEmail: false, isExitPwd: model.existPassword, vc: self.viewModel.vc, loginCallBack: self.viewModel.loginCallBack))
                self.viewModel.navigator.push(YXModulePaths.orgActiviteAccount.url, context: context)

            }

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
            var email = (self.viewModel.email.value as String).removePreAfterSpace()
            email = YXUserManager.safeDecrypt(string: email)
            // 登录之前,先校验
            self.viewModel.services.loginService.request(.checkOrgAccount("", "", 2, email), response: self.viewModel.checkActiviteResponse)
                .disposed(by: `self`.disposeBag)
            
        }).disposed(by: disposeBag)
        
        mobileSignInView.signInBtn.rx.tap.subscribe(onNext:{[weak self] in
            guard let `self` = self else { return }

            self.viewModel.hudSubject?.onNext(.loading(nil, false))
            let areaCode = self.viewModel.areaCode.value
            var mobileNumber = (self.viewModel.mobile.value as String).removePreAfterSpace()
            mobileNumber = YXUserManager.safeDecrypt(string: mobileNumber)
            // 登录之前,先校验
            self.viewModel.services.loginService.request(.checkOrgAccount(areaCode, mobileNumber, 1, ""), response: self.viewModel.checkActiviteResponse)
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
    
    
    //已激活 ->去登录
    func showHadActivateAlert(withMsg msg: String) {
        
        let alertView = YXAlertView(title: YXLanguageUtility.kLang(key: "org_account_had_activate_tip"), message: "", prompt: nil, style: .default)
        alertView.clickedAutoHide = false
        //取消
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: {[weak alertView] action in
            alertView?.hide()
        }))
        //去登录
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "login_pwdLogin"), style: .default, handler: {[weak alertView,self] action in
            alertView?.hide()
            self.viewModel.navigator.popViewModel(animated: true)
        }))
        alertView.showInWindow()
    }
    
    //未注册 ->去个人登录页
    func showNoRegisterAccountAlert(withMsg msg: String) {
        
        //login_pwdLogin
        let alertView = YXAlertView(title: msg, message: nil, prompt: nil, style: .default)
        alertView.clickedAutoHide = false
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: {[weak alertView] action in
            alertView?.hide()
        }))
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "org_personal_invertor_login"), style: .default, handler: {[weak alertView,self] action in
            alertView?.hide()
            
            for vc in (self.navigationController?.children ?? [UIViewController]()) {
                if vc is YXDefaultLoginViewController {
                    self.navigationController?.popToViewController(vc, animated: true)
                    break
                }
            }
        }))
        alertView.showInWindow()
    }

}

extension YXOrgCheckActivateViewController {

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
