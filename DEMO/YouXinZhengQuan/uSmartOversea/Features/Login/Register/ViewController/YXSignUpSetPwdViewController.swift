//
//  YXSignUpSetPwdViewController.swift
//  uSmartOversea
//
//  Created by 欧冬冬 on 2022/6/6.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXSignUpSetPwdViewController: YXHKViewController, HUDViewModelBased {

    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    
    var viewModel: YXSignUpSetPwdViewModel!
    
    var scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    var titleLabel: AccountTipLabel = {
        let label = AccountTipLabel()
        label.text = YXLanguageUtility.kLang(key: "please_set_login_password")
        label.font = UIFont.systemFont(ofSize: uniSize(24))
        label.numberOfLines = 0
        return label
    }()
    
    lazy var passWordField : YXSecureTextField = {
        let field = YXSecureTextField.init(defaultTip: YXLanguageUtility.kLang(key: "input_password"), placeholder: YXLanguageUtility.kLang(key: "signup_pwd_placeholder"))
        field.needAnmitionSelect = false
        field.tipsLable.isHidden = true
        return field
    }()
    
    var confirmButton : QMUIButton = {
        let btn = QMUIButton()
        btn.layer.cornerRadius = 4
        btn.clipsToBounds = true
        btn.backgroundColor = QMUITheme().mainThemeColor()
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .disabled)
        btn.setTitle(YXLanguageUtility.kLang(key: "confirm_btn"), for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "confirm_btn"), for: .disabled)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        return btn
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bindHUD()
        setupNavigationBar()
        initUI()
        bindViewModel()
        viewModelResponse()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        YXConstant.registerICode = ""
    }
    
    func setupNavigationBar() {
        
        //导航栏左侧 - 返回
        let backItem = UIBarButtonItem.qmui_item(with: UIImage(named: "nav_back") ?? UIImage(), target: self, action: nil)
        backItem.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            
            for vc in (self.navigationController?.children ?? [UIViewController]()) {
                if vc is YXSignUpViewController {
                    self.navigationController?.popToViewController(vc, animated: true)
                    return
                }
            }
            self.navigationController?.popViewController(animated: true)
            
        }.disposed(by: disposeBag)
        backItem.imageInsets = UIEdgeInsets(top: 0, left: -8.0, bottom: 0, right: 3.0)

        self.navigationItem.leftBarButtonItems = [backItem]
    
    }
    

    func bindViewModel() {
        
        confirmButton.rx.tap.bind { [weak self] (_) in
            guard let strongSelf = self else { return }
            
            strongSelf.viewModel.hudSubject?.onNext(.loading(nil, false))
            let pwd = YXUserManager.safeDecrypt(string: strongSelf.passWordField.textField.text ?? "")
            if pwd.isNotEmpty() {
                strongSelf.viewModel.signUpRequest(pwd)
            }
            
        }.disposed(by: disposeBag)
        
        self.viewModel.password.bind(to: self.passWordField.textField.rx.text).disposed(by: disposeBag)
        self.passWordField.textField.rx.text.orEmpty.bind(to: self.viewModel.password).disposed(by: disposeBag)

        self.viewModel.passwordValid?.bind(to: self.confirmButton.rx.isEnabled).disposed(by: disposeBag)
        
        passWordField.clearBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let strongSelf = self else {return}
            strongSelf.confirmButton.isEnabled = false
            
        }).disposed(by: disposeBag)
    }
    
    func initUI() {
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(passWordField)
        scrollView.addSubview(confirmButton)
        
        scrollView.snp.makeConstraints {(make) in
            make.top.equalTo(self.view.safeArea.top)
            make.left.right.bottom.equalTo(self.view)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(24)
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.width.equalTo(YXConstant.screenWidth - 60)
        }
        
        passWordField.snp.makeConstraints {(make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.left.right.equalTo(titleLabel)
            make.height.equalTo(56)
        }
        
        
        confirmButton.snp.makeConstraints {(make) in
            make.left.right.equalTo(titleLabel)
            make.height.equalTo(48)
            make.top.equalTo(passWordField.snp.bottom).offset(64)
        }
    }

}


//MARK: 接口返回的 处理
extension YXSignUpSetPwdViewController {
    
    func viewModelResponse() {
        //登錄成功的回調
        viewModel.loginSuccessSubject.subscribe(onNext: { [weak self] success in
            if success {
                self?.view.endEditing(true)
                YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "login_loginSuccess"))
                self?.loginSuccessBack(self?.viewModel.vc, loginCallBack: self?.viewModel.loginCallBack)
                
//                if YXLaunchGuideManager.isGuideToLogin() == false {
//                    if YXUserManager.isShowLoginRegister() {
//                        YXUserManager.registerLoginInitRootViewControler()
//                        return
//                    }
//                    if let vc = self?.viewModel.vc {
//                        if self?.navigationController?.viewControllers.contains(vc) ?? false {
//                            self?.navigationController?.popToViewController(vc, animated: true)
//                            return
//                        }
//                    }
//                    self?.navigationController?.popToRootViewController(animated: true)
//
//                } else {
//                    YXLaunchGuideManager.setGuideToLogin(withFlag: false)   //关闭从引导页到登录的标记
//                    if YXUserManager.isShowLoginRegister() {
//                        YXUserManager.registerLoginInitRootViewControler()
//                        return
//                    }
//                }
                
            }

        }).disposed(by: disposeBag)
        
        viewModel.registerSMSTimeoutSubject.subscribe(onNext: { [weak self] msg in
            self?.view.endEditing(true)
            
            let alertView = YXAlertView.alertView(title: msg, message: "")
            alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "login_captchaTimeDown"), style: .default, handler: { [weak self, weak alertView] (action) in
                guard let strongSelf = self else { return }
                
                alertView?.hide()
                
                for vc in (strongSelf.navigationController?.children ?? [UIViewController]()) {
                    if vc is YXSignUpViewController {
                        strongSelf.navigationController?.popToViewController(vc, animated: true)
                        return
                    }
                }
                strongSelf.navigationController?.popViewController(animated: true)
                
            }))
            alertView.showInWindow()

        }).disposed(by: disposeBag)
    }
}
