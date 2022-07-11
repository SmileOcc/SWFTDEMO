//
//  YXForgetPwdPhoneViewController.swift
//  uSmartOversea
//
//  Created by mac on 2019/3/27.
//  Copyright © 2019 RenRenDai. All rights reserved.
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


class YXForgetPwdPhoneViewController: YXHKViewController, HUDViewModelBased/*, YXAreaCodeBtnProtocol*/{
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    
    var viewModel: YXForgetPwdPhoneViewModel!
    
    var scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    lazy var headTitleView : YXSingleTitleView = {
        if self.viewModel.accoutType.value == .email{
            let view = YXSingleTitleView.init(mainTitle: YXLanguageUtility.kLang(key: "recover_password"),currentTitle: YXLanguageUtility.kLang(key: "verify_email") ,subTitle: YXLanguageUtility.kLang(key: "verify_mobile"))
            return view
        }else {
            let view = YXSingleTitleView.init(mainTitle: YXLanguageUtility.kLang(key: "recover_password"),currentTitle: YXLanguageUtility.kLang(key: "verify_mobile") ,subTitle: YXLanguageUtility.kLang(key: "verify_email"))
            return view
        }
    }()
    
    lazy var mobileResetView : YXReceiveCodeView = {
        let view = YXReceiveCodeView.init(type: .mobile)
        let phoneTextField:YXPhoneTextField = view.acountField as! YXPhoneTextField
        phoneTextField.areaCodeLale.text = "+\(self.viewModel.areaCode.value)"
        phoneTextField.areaCodeBtn.isEnabled = self.viewModel.canChangeType()
        return view
    }()
    
    lazy var emailResetView : YXReceiveCodeView = {
        let view = YXReceiveCodeView.init(type: .email)
        return view
    }()
    
    lazy var helpBtn : QMUIButton = {
       let btn = QMUIButton()
        btn.setTitle(YXLanguageUtility.kLang(key: "hlep_receive"), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        btn.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        btn.sizeToFit()
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindHUD()
        bindViewModel()
        initUI()
        viewModelResponse()
    }
    
    func bindViewModel() {
        
        self.viewModel.mobile.bind(to: mobileResetView.acountField.textField.rx.text).disposed(by: disposeBag)
        self.viewModel.email.bind(to: emailResetView.acountField.textField.rx.text).disposed(by: disposeBag)
        
        mobileResetView.acountField.textField.rx.text.orEmpty.bind(to: self.viewModel.mobile).disposed(by: disposeBag)
        emailResetView.acountField.textField.rx.text.orEmpty.bind(to: self.viewModel.email).disposed(by: disposeBag)
     
        self.viewModel.mCaptcha.bind(to: mobileResetView.verifictionCodeField.textField.rx.text.orEmpty).disposed(by: disposeBag)
        mobileResetView.verifictionCodeField.textField.rx.text.orEmpty.bind(to: self.viewModel.mCaptcha).disposed(by: disposeBag)

        self.viewModel.eCaptcha.bind(to: emailResetView.verifictionCodeField.textField.rx.text.orEmpty).disposed(by: disposeBag)
        emailResetView.verifictionCodeField.textField.rx.text.orEmpty.bind(to: self.viewModel.eCaptcha).disposed(by: disposeBag)
       
        mobileResetView.pwdTextFeild.textField.rx.text.orEmpty.asObservable().bind(to: self.viewModel.mPwd).disposed(by: disposeBag)
        emailResetView.pwdTextFeild.textField.rx.text.orEmpty.asObservable().bind(to: self.viewModel.ePwd).disposed(by: disposeBag)

       //MARK: - viewModel的响应
        //手机号码没有注册过 的响应
        self.viewModel.unRegiestSubject.subscribe(onNext: { [weak self] (msg) in
            self?.unRegisteredAlert(msg)
        }).disposed(by: disposeBag)
        
        
        let phoneTextField:YXPhoneTextField = self.mobileResetView.acountField as! YXPhoneTextField
        phoneTextField.areaCodeBtn.rx.tap.subscribe(onNext:{[weak self] in
            self?.showMoreAreaAlert()
        }).disposed(by: disposeBag)
        
        headTitleView.didChanage = { [weak self] title in
            self?.viewModel.handelAccountChanage(title: title)
        }
        headTitleView.isEnabled(self.viewModel.canChangeType())
        self.viewModel.emailHidden.bind(to: emailResetView.rx.isHidden).disposed(by: disposeBag)
        self.viewModel.mobileHidden.bind(to: mobileResetView.rx.isHidden).disposed(by: disposeBag)
        self.viewModel.mEverythingValid?.bind(to: mobileResetView.bindBtn.rx.isEnabled).disposed(by: disposeBag)
        self.viewModel.eEverythingValid?.bind(to: emailResetView.bindBtn.rx.isEnabled).disposed(by: disposeBag)
        
        self.viewModel.mUsernameValid?.bind(to: mobileResetView.verifictionCodeField.sendBtn.rx.isEnabled).disposed(by: disposeBag)
        self.viewModel.eUsernameValid?.bind(to: emailResetView.verifictionCodeField.sendBtn.rx.isEnabled).disposed(by: disposeBag)
        
        self.viewModel.ePassWordValid?.bind(to: emailResetView.errorTipLabel.rx.isHidden).disposed(by: disposeBag)
        self.viewModel.mPassWordValid?.bind(to: mobileResetView.errorTipLabel.rx.isHidden).disposed(by: disposeBag)
        
        emailResetView.verifictionCodeField.sendBtn.rx.tap.subscribe(onNext: {[weak self] in
            guard let `self` = self else { return }
            self.viewModel.sendEmailCodeRequest()
        }).disposed(by: disposeBag)
        
        mobileResetView.verifictionCodeField.sendBtn.rx.tap.subscribe(onNext:{[weak self] in
            guard let `self` = self else { return }
            self.viewModel.sendMobileCodeRequest()
        }).disposed(by: disposeBag)
        
        
        emailResetView.bindBtn.rx.tap.subscribe(onNext:{[weak self] in
            self?.viewModel.emailVerifyRequest()
        }).disposed(by: disposeBag)
        
        mobileResetView.bindBtn.rx.tap.subscribe(onNext:{[weak self] in
            self?.viewModel.mobileVerifyRequest()
        }).disposed(by: disposeBag)
        
        mobileResetView.helpBtn.rx.tap.subscribe(onNext:{[weak self] in
            guard let `self` = self else {return}
            self.alertReceiveCodeHelp()
        }).disposed(by: disposeBag)
        emailResetView.helpBtn.rx.tap.subscribe(onNext:{[weak self] in
            guard let `self` = self else {return}
            self.alertReceiveCodeHelp()
        }).disposed(by: disposeBag)
        
        self.viewModel.accoutType.accept(self.viewModel.accoutType.value)
        if self.viewModel.mobile.value.count > 0 {
            mobileResetView.acountField.textField.becomeFirstResponder()
            if self.viewModel.isLogin {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.mobileResetView.acountField.textField.isEnabled = false
                    self.mobileResetView.acountField.clearBtn.isHidden = true
                    self.mobileResetView.acountField.textField.textColor = QMUITheme().textColorLevel4()
                    if let phtextField = self.mobileResetView.acountField as? YXPhoneTextField{
                        phtextField.areaCodeLale.textColor = QMUITheme().textColorLevel4()
                        phtextField.areaCodeBtn.isEnabled = false
                    }
                    
                }
            }
        }
        if self.viewModel.email.value.count > 0 {
            emailResetView.acountField.textField.becomeFirstResponder()
            emailResetView.acountField.didBegin()
            if self.viewModel.isLogin {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.emailResetView.acountField.textField.isEnabled = false
                    self.emailResetView.acountField.clearBtn.isHidden = true
                    self.emailResetView.acountField.textField.textColor = QMUITheme().textColorLevel4()
                }
            }
        }
    }
    
    func initUI() {
        
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
        
        scrollView.addSubview(mobileResetView)
        mobileResetView.snp.makeConstraints { (make) in
            make.top.equalTo(headTitleView.snp.bottom).offset(40)
            make.left.width.equalToSuperview()
            make.height.equalTo(300)
        }
        
        scrollView.addSubview(emailResetView)
        emailResetView.snp.makeConstraints { (make) in
            make.size.equalTo(mobileResetView)
            make.top.left.equalTo(mobileResetView)
        }
        scrollView.addSubview(helpBtn)
        helpBtn.snp.makeConstraints { (make) in
            make.top.equalTo(mobileResetView.snp.bottom).offset(16)
            make.height.equalTo(20)
            make.right.equalTo(view.snp.right).offset(-30)
        }
        
    }
    
    func viewModelResponse(){
        viewModel.resetSuccessSubject.subscribe(onNext: { [weak self] success in
            self?.view.endEditing(true)
            
            let alerVC = YXAlertViewFactory.resetPwdSuccessAlert {
                if let vc = self?.viewModel.sourceVC {
                    //未登录状态，一般是从 登录页面进来的。
                    self?.navigationController?.popToViewController(vc, animated: true)
                } else {
                    /* 模块：修改登录密码- 修改登录密码 的 【忘记密码】 的取消返回。
                     已登录状态。   返回到YXUserCenterViewController，返回后已经是未登录状态了。*/
                    let allViewControllers = self?.navigationController?.viewControllers
                    for vc in allViewControllers ?? [] {
                        if vc.isKind(of: YXUserCenterViewController.self) {
                            self?.navigationController?.popToViewController(vc, animated: true)
                            return
                        }
                    }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: ["index" : YXTabIndex.market])
                }
            } relogin: {
                let allViewControllers = self?.navigationController?.viewControllers
                //未登录状态，一般是从 登录页面进来的。
                for vc in allViewControllers ?? [] {
                    if vc.isKind(of: YXDefaultLoginViewController.self) {
                        self?.navigationController?.popToViewController(vc, animated: true)
                        return
                    }
                }
                /* 模块：修改登录密码- 修改登录密码 的 【忘记密码】 的的【重新登录】
                 已登录状态。   返回到YXUserCenterViewController，返回后再跳转到登录页面。*/
                
                for vc in allViewControllers ?? [] {
                    if vc.isKind(of: YXUserCenterViewController.self) {
                        self?.navigationController?.popToViewController(vc, animated: false)
                        NotificationCenter.default.post(name: NSNotification.Name("goLogin"), object: nil)
                        return
                    }
                }
            }
            
            self?.present(alerVC, animated: true, completion: nil)
            
        }).disposed(by: disposeBag)
        
        //未注册
        viewModel.unRegiestSubject.subscribe(onNext: { [weak self] (msg) in
            guard let `self` = self else {return}
            self.unRegisteredAlert(msg)
        }).disposed(by: disposeBag)
        
        viewModel.eCodeSubject.subscribe(onNext:{[weak self] (argument) in
            guard let `self` = self else {return}
            self.emailResetView.verifictionCodeField.send()
            self.emailResetView.verifictionCodeField.textField.becomeFirstResponder()
            if argument.0 == true {
                if YXConstant.isAutoFillCaptcha() {
                    self.viewModel.eCaptcha.accept(argument.1)
                    self.emailResetView.verifictionCodeField.showDefaultTip()
                }
            }else {
                
            }
        }).disposed(by: disposeBag)
        
        viewModel.mCodeSubject.subscribe(onNext:{[weak self] (argument) in
            guard let `self` = self else {return}
            self.mobileResetView.verifictionCodeField.send()
            self.mobileResetView.verifictionCodeField.textField.becomeFirstResponder()
            if argument.0 == true {
                if YXConstant.isAutoFillCaptcha() {
                    self.viewModel.mCaptcha.accept(argument.1)
                    self.mobileResetView.verifictionCodeField.showDefaultTip()
                }
            }else {
                
            }
        }).disposed(by: disposeBag)
        
        helpBtn.rx.tap.subscribe(onNext:{[weak self] in
            guard let `self` = self else { return }
            self.noReiverCodeAletr()
        }).disposed(by: disposeBag)
    }
    
}

extension YXForgetPwdPhoneViewController {
    
    
    private func showMoreAreaAlert() {
        let areaCodeModel = YXAreaCodeViewModel()
        areaCodeModel.didSelectSubject.subscribe(onNext: { [weak self] (code) in
            guard let `self` = self else {return}
            let phoneTextField:YXPhoneTextField = self.mobileResetView.acountField as! YXPhoneTextField
            phoneTextField.areaCodeLale.text = "+\(code)"
            self.viewModel.areaCode.accept(code)
        }).disposed(by: self.disposeBag)
        
        let context = YXNavigatable(viewModel: areaCodeModel)
        // self.viewModel.navigator.push(YXModulePaths.areaCodeSelection.url, context: context)
        self.viewModel.navigator.present(YXModulePaths.areaCodeSelection.url, context: context, animated: true)
    }
    
    fileprivate func alertReceiveCodeHelp(){
        
        let  alertVC = YXAlertViewFactory.helpAlertView(type: self.viewModel.accoutType.value)
        alertVC.backgoundTapDismissEnable = true
        self.present(alertVC, animated: true, completion: nil)
    }
    
    //手机号码没有注册过 弹框
    fileprivate func unRegisteredAlert(_ msg:String) {
        self.view.endEditing(true)
        let alertVc = YXAlertViewFactory.notSignUPAlertView(massage: msg) {[weak self] in
            self?.viewModel.gotoRegister()
        }
        alertVc.backgoundTapDismissEnable = true
        self.present(alertVc, animated: true, completion: nil)
    }
    
    fileprivate func noReiverCodeAletr(){
        let alertView = YXAlertView.init(title: YXLanguageUtility.kLang(key: "receive_code_tip_title"), message: YXLanguageUtility.kLang(key: "receive_code_tip_desc_comm_email"))
        let cancelAction = YXAlertAction.init(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel) {[weak alertView] _ in
            alertView?.hideInController()
        }
        let confirmAction = YXAlertAction.init(title: YXLanguageUtility.kLang(key: "common_confirm"), style: .fullDefault) {[weak alertView] _ in
            alertView?.hideInController()
//            let str = "tel:+6563030663"
//            let application = UIApplication.shared
//            let URL = NSURL(string: str)
//            if let URL = URL {
//                application.open(URL as URL, options: [:], completionHandler: { success in
//                })
//            }
        }
//        alertView.addAction(cancelAction)
        alertView.addAction(confirmAction)
        alertView.show(in: self)
    }
    
}
