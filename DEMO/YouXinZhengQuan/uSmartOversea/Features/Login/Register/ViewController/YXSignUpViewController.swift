//
//  YXSignUpViewController.swift
//  uSmartOversea
//
//  Created by usmart on 2021/4/1.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXSignUpViewController: YXHKViewController,HUDViewModelBased {
    typealias ViewModelType = YXSignUpViewModel
    
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXSignUpViewModel!
    
    private var scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    lazy var headTitleView : YXDoubleTitleView = {
        if self.viewModel.accoutType.value == .mobile{
        let view = YXDoubleTitleView.init(mainTitle: YXLanguageUtility.kLang(key: "mobile_acount"), subTitle: YXLanguageUtility.kLang(key: "email_acount"))
            return view
        }else {
            let view = YXDoubleTitleView.init(mainTitle: YXLanguageUtility.kLang(key: "email_acount"), subTitle: YXLanguageUtility.kLang(key: "mobile_acount"))
                return view
        }
    }()
    
    lazy var mobileSignUpView :YXSignUpView  = {
        let view = YXSignUpView.init(type: .mobile)
        let phoneTextField:YXPhoneTextField = view.acountField as! YXPhoneTextField
        phoneTextField.areaCodeLale.text = "+\(self.viewModel.areaCode.value)"
        return view
    }()
    
    lazy var emailSignUpView : YXSignUpView = {
        let view = YXSignUpView.init(type: .email)
        return view
    }()
    
    
    lazy var declareView : YXDeclareView = {
        let view = YXDeclareView.init(frame: .zero)
        declareView.isHidden = true
        return view
    }()
    
    override var pageName: String {
            return "Register"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

         iniUI()
         bindHUD()
         bindViewModel()
         viewModelResponse()
        // Do any additional setup after loading the view.
        
        self.viewModel.requestAdData()

    }
    

    
    func setupNavigationBar() {
        
        //导航栏右按钮
        let signinBtn = UIButton.init(type: .custom)
        signinBtn.setTitle(YXLanguageUtility.kLang(key: "sign_in"), for: .normal)
        signinBtn.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        signinBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        signinBtn.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
        let signinItme = UIBarButtonItem.init(customView: signinBtn)
        navigationItem.rightBarButtonItems = [signinItme]
        navigationItem.rightBarButtonItem?.tintColor = QMUITheme().themeTextColor()
    
    }
    
    func iniUI(){
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeArea.top)
            make.left.right.bottom.equalTo(self.view)
        }
        
        scrollView.addSubview(headTitleView)
        headTitleView.snp.makeConstraints { (make) in
            make.top.equalTo(24)
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.height.equalTo(60)
        }
        
        scrollView.addSubview(mobileSignUpView)
        mobileSignUpView.snp.makeConstraints { (make) in
            make.top.equalTo(headTitleView.snp.bottom).offset(40)
            make.left.width.equalToSuperview()
            if YXConstant.screenHeight <= 667 {
                make.height.equalTo(580)
            } else {
                make.height.equalTo(620)
            }
            make.bottom.equalTo(scrollView.snp.bottom).offset(-20);
        }
        
        scrollView.addSubview(emailSignUpView)
        emailSignUpView.isHidden = true
        emailSignUpView.snp.makeConstraints { (make) in
            make.size.equalTo(mobileSignUpView)
            make.top.left.equalTo(mobileSignUpView)
        }
        

        
        setupNavigationBar()
        
        if self.viewModel.email.value.count > 0 , self.viewModel.accoutType.value == .email   {
            emailSignUpView.acountField.textField.becomeFirstResponder()
        }
        if self.viewModel.mobile.value.count > 0 , self.viewModel.accoutType.value == .mobile {
            mobileSignUpView.acountField.textField.becomeFirstResponder()
        }
    }
    
    func bindViewModel() {
        
        //邀请码
        mobileSignUpView.inviteSeletexSubject.bind(to: emailSignUpView.inviteBtn.rx.isSelected).disposed(by: disposeBag)
        emailSignUpView.inviteSeletexSubject.bind(to: mobileSignUpView.inviteBtn.rx.isSelected).disposed(by: disposeBag)
        mobileSignUpView.inviteField.textField.rx.text.orEmpty.bind(to: emailSignUpView.inviteField.textField.rx.text.orEmpty).disposed(by: disposeBag)
        emailSignUpView.inviteField.textField.rx.text.orEmpty.bind(to: mobileSignUpView.inviteField.textField.rx.text.orEmpty).disposed(by: disposeBag)
        mobileSignUpView.inviteField.textField.rx.text.orEmpty.bind(to: self.viewModel.inviteCode).disposed(by: disposeBag)
        emailSignUpView.inviteField.textField.rx.text.orEmpty.bind(to: self.viewModel.inviteCode).disposed(by: disposeBag)
        self.viewModel.inviteCode.bind(to: mobileSignUpView.inviteField.textField.rx.text.orEmpty).disposed(by: disposeBag)
        self.viewModel.inviteCode.bind(to: emailSignUpView.inviteField.textField.rx.text.orEmpty).disposed(by: disposeBag)

        mobileSignUpView.inviteField.clearBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.viewModel.inviteCode.accept("")
        }).disposed(by: disposeBag)
        
        emailSignUpView.inviteField.clearBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.viewModel.inviteCode.accept("")
        }).disposed(by: disposeBag)
        
        self.viewModel.mobile.bind(to: mobileSignUpView.acountField.textField.rx.text).disposed(by: disposeBag)
        self.viewModel.email.bind(to: emailSignUpView.acountField.textField.rx.text).disposed(by: disposeBag)
        
        mobileSignUpView.acountField.textField.rx.text.orEmpty.bind(to: self.viewModel.mobile).disposed(by: disposeBag)
        emailSignUpView.acountField.textField.rx.text.orEmpty.bind(to: self.viewModel.email).disposed(by: disposeBag)
//        mobileSignUpView.passWordField.textField.rx.text.orEmpty.bind(to: self.viewModel.mPwd).disposed(by: disposeBag)
//        emailSignUpView.passWordField.textField.rx.text.orEmpty.bind(to: self.viewModel.ePwd).disposed(by: disposeBag)
//
//        self.viewModel.mCaptcha.bind(to: mobileSignUpView.verifictionCodeField.textField.rx.text.orEmpty).disposed(by: disposeBag)
//        mobileSignUpView.verifictionCodeField.textField.rx.text.orEmpty.bind(to: self.viewModel.mCaptcha).disposed(by: disposeBag)
//
//        self.viewModel.eCaptcha.bind(to: emailSignUpView.verifictionCodeField.textField.rx.text.orEmpty).disposed(by: disposeBag)
//        emailSignUpView.verifictionCodeField.textField.rx.text.orEmpty.bind(to: self.viewModel.eCaptcha).disposed(by: disposeBag)
      
        
        let phoneTextField:YXPhoneTextField = self.mobileSignUpView.acountField as! YXPhoneTextField
        phoneTextField.areaCodeBtn.rx.tap.subscribe(onNext:{[weak self] in
            self?.showMoreAreaAlert()
        }).disposed(by: disposeBag)
        
        
        headTitleView.didChanage = {[weak self] title in
            guard let `self` = self else { return }
            self.view.endEditing(true)
            
            self.mobileSignUpView.inviteSeletexSubject.onNext(self.mobileSignUpView.inviteBtn.isSelected)
            self.emailSignUpView.inviteSeletexSubject.onNext(self.emailSignUpView.inviteBtn.isSelected)
            
            if self.viewModel.inviteCode.value.isEmpty || self.mobileSignUpView.inviteBtn.isSelected == false {
                self.viewModel.inviteCode.accept("")
                self.mobileSignUpView.inviteField.didEndNoAnmition()
                self.emailSignUpView.inviteField.didEndNoAnmition()
            } else {
                self.mobileSignUpView.inviteField.didBeginOnAnmition()
                self.emailSignUpView.inviteField.didBeginOnAnmition()
            }
            

            if title == YXLanguageUtility.kLang(key: "mobile_acount") {
                self.trackViewClickEvent(name: "Mobile_Tab")
            }else{
                self.trackViewClickEvent(name: "Email_Tab")
            }
            self.viewModel.handelAccountChanage(title: title)
        }

        self.viewModel.emailHidden.bind(to: emailSignUpView.rx.isHidden).disposed(by: disposeBag)
        self.viewModel.mobileHidden.bind(to: mobileSignUpView.rx.isHidden).disposed(by: disposeBag)
        self.viewModel.mUsernameValid?.bind(to: mobileSignUpView.signUpBtn.rx.isEnabled).disposed(by: disposeBag)
        self.viewModel.eUsernameValid?.bind(to: emailSignUpView.signUpBtn.rx.isEnabled).disposed(by: disposeBag)
//        self.viewModel.mUsernameValid?.bind(to: emailSignUpView.verifictionCodeField.sendBtn.rx.isEnabled).disposed(by: disposeBag)
//        self.viewModel.eUsernameValid?.bind(to: mobileSignUpView.verifictionCodeField.sendBtn.rx.isEnabled).disposed(by: disposeBag)
//        self.viewModel.ePassWordValid?.bind(to: emailSignUpView.errorTipLabel.rx.isHidden).disposed(by: disposeBag)
//        self.viewModel.mPassWordValid?.bind(to: mobileSignUpView.errorTipLabel.rx.isHidden).disposed(by: disposeBag)
//        self.viewModel.mUsernameValid?.bind(to: mobileSignUpView.verifictionCodeField.sendBtn.rx.isEnabled).disposed(by: disposeBag)
//        self.viewModel.eUsernameValid?.bind(to: emailSignUpView.verifictionCodeField.sendBtn.rx.isEnabled).disposed(by: disposeBag)
        
        
        emailSignUpView.signUpBtn.rx.tap.subscribe(onNext:{[weak self] in
            guard let `self` = self else { return }
            if !self.emailSignUpView.inviteBtn.isSelected {
                self.viewModel.inviteCode.accept("")
            }
//            self.viewModel.emailSignupRequest()
//            self.viewModel.sendEmailCodeRequest()
            self.viewModel.checkAccount()
        }).disposed(by: disposeBag)
        
        mobileSignUpView.signUpBtn.rx.tap.subscribe(onNext:{[weak self] in
            guard let `self` = self else { return }
            if !self.mobileSignUpView.inviteBtn.isSelected {
                self.viewModel.inviteCode.accept("")
            }
//            self.viewModel.mobileSignupRequest()
//            self.viewModel.sendMobileCodeRequest()
            self.viewModel.checkAccount()
        }).disposed(by: disposeBag)
        
//        emailSignUpView.verifictionCodeField.sendBtn.rx.tap.subscribe(onNext: {[weak self] in
//            guard let `self` = self else { return }
//            self.viewModel.sendEmailCodeRequest()
//        }).disposed(by: disposeBag)
//
//        mobileSignUpView.verifictionCodeField.sendBtn.rx.tap.subscribe(onNext:{[weak self] in
//            guard let `self` = self else { return }
//            self.viewModel.sendMobileCodeRequest()
//        }).disposed(by: disposeBag)
        
        
//        mobileSignUpView.helpBtn.rx.tap.subscribe(onNext:{[weak self] in
//            guard let `self` = self else {return}
//            self.alertReceiveCodeHelp()
//        }).disposed(by: disposeBag)
//        emailSignUpView.helpBtn.rx.tap.subscribe(onNext:{[weak self] in
//            guard let `self` = self else {return}
//            self.alertReceiveCodeHelp()
//        }).disposed(by: disposeBag)
        

        

        self.viewModel.accoutType.accept(self.viewModel.accoutType.value)
       
        bannerOrPrivacy()
    }

    fileprivate func alertReceiveCodeHelp(){
        let  alertVC = YXAlertViewFactory.helpAlertView(type: self.viewModel.accoutType.value)
        alertVC.backgoundTapDismissEnable = true
        self.present(alertVC, animated: true, completion: nil)
        
    }
    
    private func showMoreAreaAlert() {
        let areaCodeModel = YXAreaCodeViewModel()
        areaCodeModel.didSelectSubject.subscribe(onNext: { [weak self] (code) in
            guard let `self` = self else {return}
            let phoneTextField:YXPhoneTextField = self.mobileSignUpView.acountField as! YXPhoneTextField
            self.viewModel.areaCode.accept(code)
            phoneTextField.areaCodeLale.text = "+\(code)"
                        
        }).disposed(by: self.disposeBag)
        
        let context = YXNavigatable(viewModel: areaCodeModel)
        self.viewModel.navigator.present(YXModulePaths.areaCodeSelection.url, context: context, animated: true)
        //self.viewModel.navigator.push(YXModulePaths.areaCodeSelection.url, context: context)
    }
    func bannerOrPrivacy() {
        
        mobileSignUpView.didClickPrivacy = {[weak self]  in
            let dic: [String: Any] = [
                YXWebViewModel.kWebViewModelUrl: YXH5Urls.PRIVACY_POLICY_URL(),
                YXWebViewModel.kWebViewModelCachePolicy : URLRequest.CachePolicy.reloadIgnoringLocalCacheData
            ]
            self?.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        }
        mobileSignUpView.didClickService = {[weak self] in
            let dic: [String: Any] = [
                YXWebViewModel.kWebViewModelUrl: YXH5Urls.USER_REGISTRATION_AGREEMENT_URL(),
                YXWebViewModel.kWebViewModelCachePolicy : URLRequest.CachePolicy.reloadIgnoringLocalCacheData
            ]
            self?.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        }
        
        emailSignUpView.didClickPrivacy = {[weak self]  in
            let dic: [String: Any] = [
                YXWebViewModel.kWebViewModelUrl: YXH5Urls.PRIVACY_POLICY_URL(),
                YXWebViewModel.kWebViewModelCachePolicy : URLRequest.CachePolicy.reloadIgnoringLocalCacheData
            ]
            self?.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        }
        emailSignUpView.didClickService = {[weak self] in
            let dic: [String: Any] = [
                YXWebViewModel.kWebViewModelUrl: YXH5Urls.USER_REGISTRATION_AGREEMENT_URL(),
                YXWebViewModel.kWebViewModelCachePolicy : URLRequest.CachePolicy.reloadIgnoringLocalCacheData
            ]
            self?.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        }
        
        mobileSignUpView.didCloseBlock = {[weak self] in
            guard let strongSelf = self else { return }
            strongSelf.emailSignUpView.showBanner(false)
            strongSelf.updateContent()
        }
        mobileSignUpView.tapBannerBlock = {[weak self] (index) in
            guard let strongSelf = self else { return }
            
            if index < strongSelf.viewModel.adListRelay.value.count {
                let model = strongSelf.viewModel.adListRelay.value[index]
                let url = model.jumpURL ?? ""
                if url.count > 0 {
                    YXBannerManager.goto(withBanner: model, navigator: strongSelf.viewModel.navigator)
                }
            }
        }
        
        emailSignUpView.didCloseBlock = {[weak self] in
            guard let strongSelf = self else { return }
            strongSelf.mobileSignUpView.showBanner(false)
            strongSelf.updateContent()
        }
        emailSignUpView.tapBannerBlock = {[weak self] (index) in
            guard let strongSelf = self else { return }
            
            if index < strongSelf.viewModel.adListRelay.value.count {
                let model = strongSelf.viewModel.adListRelay.value[index]
                let url = model.jumpURL ?? ""
                if url.count > 0 {
                    YXBannerManager.goto(withBanner: model, navigator: strongSelf.viewModel.navigator)
                }
            }
        }
    }
    
    func updateContent() {
        
        let contentH = 580 + self.mobileSignUpView.bannerSizeHeight()
        self.mobileSignUpView.snp.remakeConstraints { (make) in
            make.top.equalTo(self.headTitleView.snp.bottom).offset(40)
            make.left.width.equalToSuperview()
            if YXConstant.screenHeight <= 667 {
                make.height.equalTo(contentH)
            } else {
                make.height.equalTo(contentH)
            }
            make.bottom.equalTo(self.scrollView.snp.bottom).offset(-20);
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension YXSignUpViewController{
    
    func viewModelResponse(){
        viewModel.loginSuccessSubject.subscribe(onNext: { [weak self] success in
            self?.view.endEditing(true)
            YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "login_loginSuccess"))
            self?.loginSuccessBack(self?.viewModel.vc, loginCallBack: self?.viewModel.loginCallBack)
//            if YXLaunchGuideManager.isGuideToLogin() == false {
//                if YXUserManager.isShowLoginRegister() {
//                    YXUserManager.registerLoginInitRootViewControler()
//                    return
//                }
//                if let vc = self?.viewModel.vc {
//                    if self?.navigationController?.viewControllers.contains(vc) ?? false {
//                        self?.navigationController?.popToViewController(vc, animated: true)
//                        return
//                    }
//                }
//                self?.navigationController?.popToRootViewController(animated: true)
//
//            } else {
//                YXLaunchGuideManager.setGuideToLogin(withFlag: false)   //关闭从引导页到登录的标记
//                if YXUserManager.isShowLoginRegister() {
//                    YXUserManager.registerLoginInitRootViewControler()
//                    return
//                }
//            }
            
        }).disposed(by: disposeBag)
        
        //已注册
        viewModel.hasRegisterSubject.subscribe(onNext: { [weak self] (msg) in
            guard let `self` = self else {return}
            self.goLoginAlert(withMsg: msg)
        }).disposed(by: disposeBag)
        
//        viewModel.eCodeSubject.subscribe(onNext:{[weak self] (argument) in
//            guard let `self` = self else {return}
//            self.emailSignUpView.verifictionCodeField.send()
//            self.emailSignUpView.verifictionCodeField.textField.becomeFirstResponder()
//            if argument.0 == true {
//                if YXConstant.isAutoFillCaptcha() {
//                    self.viewModel.eCaptcha.accept(argument.1)
//                    self.emailSignUpView.verifictionCodeField.showDefaultTip()
//                }
//            }else {
//
//            }
//        }).disposed(by: disposeBag)
        
//        viewModel.mCodeSubject.subscribe(onNext:{[weak self] (argument) in
//            guard let `self` = self else {return}
//            self.mobileSignUpView.verifictionCodeField.send()
//            self.mobileSignUpView.verifictionCodeField.textField.becomeFirstResponder()
//            if argument.0 == true {
//                if YXConstant.isAutoFillCaptcha() {
//                    self.viewModel.mCaptcha.accept(argument.1)
//                    self.mobileSignUpView.verifictionCodeField.showDefaultTip()
//                }
//            }
//        }).disposed(by: disposeBag)
        
        //adListRelay订阅信号的实现，banner广告展示
        viewModel.adListRelay.asDriver().skip(1).drive(onNext: { [weak self] (adList) in
            guard let `self` = self else {return}
            
            if adList.count > 0 {
                var adImageUrls = [String]()
                adList.forEach({ (model) in
                    adImageUrls.append(model.pictureURL ?? "")
                })
                self.mobileSignUpView.bannerView.imageURLStringsGroup = adImageUrls
                self.emailSignUpView.bannerView.imageURLStringsGroup = adImageUrls
                self.mobileSignUpView.showBanner(true)
                self.emailSignUpView.showBanner(true)
                self.updateContent()
            } else {
                self.mobileSignUpView.showBanner(false)
                self.emailSignUpView.showBanner(false)
                self.updateContent()
            }

        }).disposed(by: disposeBag)
    }
    
    func goLoginAlert(withMsg msg: String) {
        self.view.endEditing(true)
        
        let alertView = YXAlertView.alertView(title: msg, message: "")
        alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: {_ in }))
        alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "sign_in"), style: .default, handler: { [weak self] (action) in
            self?.viewModel.gotoLogin()
        }))
        
        alertView.showInWindow()
    }
}
