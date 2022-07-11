//
//  YXOrgForgetPwdResetViewController.swift
//  uSmartOversea
//
//  Created by 欧冬冬 on 2022/4/14.
//  Copyright © 2022 RenRenDai. All rights reserved.
//
/* 模块：找回密码--第2步
 重置密码  */

import UIKit
import Reusable
import RxSwift
import RxCocoa
import SnapKit
import YXKit

class YXOrgForgetPwdResetViewController: YXHKViewController, HUDViewModelBased {
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    
    var viewModel: YXOrgForgetPwdResetViewModel!

    var timeCount = 60
    let timerMark = "forgetPwd"
    var tempCaptcha: String = ""

    let codeRelay = BehaviorRelay<String>(value: "")
    
    var scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
//    var phoneLab: UILabel = {
//        let lab = UILabel()
//        lab.font = UIFont.systemFont(ofSize: uniSize(18))
//        lab.textColor = QMUITheme().textColorLevel1()
//        return lab
//    }()
    
//    var gridInputView: YXGridInputView = {
//        let gridWidth:CGFloat
//        switch YXConstant.screenSize {
//        case .size3_5,.size4:
//            gridWidth = 34
//        default:
//            gridWidth = 44
//        }
//        let view = YXGridInputView(gridWidth: gridWidth, viewWidth: UIScreen.main.bounds.width-40, isSecure: false)
//        if #available(iOS 12.0, *) {
//            view.textField.textContentType = .oneTimeCode
//        }
//        return view
//    }()
    
    //验证码
    var codeTextField: YXTimeTextField = {
        let textField = YXTimeTextField.init(defaultTip: YXLanguageUtility.kLang(key: "login_codeTip"), placeholder:"")
        return textField
    }()
    
    var pwdTextField: YXSecureTextField = {
        let textField = YXSecureTextField.init(defaultTip: YXLanguageUtility.kLang(key: "login_pwdPlaceHolder"), placeholder:"")
        return textField
    }()
    
    var confirmPwdTextField: YXSecureTextField = {
        let textField = YXSecureTextField.init(defaultTip: YXLanguageUtility.kLang(key: "login_pwdPlaceHolder"), placeholder:"")
        return textField
    }()
    
    var completeBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle(YXLanguageUtility.kLang(key: "confirm_btn"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize:16)
        btn.setDisabledTheme(4)
        return btn
    }()
    

    var sendTipLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.normalFont16()
        label.textColor = QMUITheme().textColorLevel2()
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindHUD()
        initUI()
        bindViewModel()
        sendCaptcha()
        
        var headerContnet = ""
        var content = ""
        if self.viewModel.isEmail {
            headerContnet = YXLanguageUtility.kLang(key: "org_email_verification_code_sent_to")
            content = self.viewModel.email
        } else {
            headerContnet = YXLanguageUtility.kLang(key: "org_sms_verification_code_sent_to")
            content = "+" + self.viewModel.code + " " + self.viewModel.phone
        }
        
        self.sendTipLabel.text = headerContnet + " " + content
    }
    
    func bindViewModel() {
        
        Observable.combineLatest(codeTextField.textField.rx.text.orEmpty, pwdTextField.textField.rx.text.orEmpty, confirmPwdTextField.textField.rx.text.orEmpty)
        {
            textValue1, textValue2, textValue3 -> Bool in
            (textValue1.count > 0 && textValue2.count > 0 && textValue3.count > 0)
            }
            .bind(to: completeBtn.rx.isEnabled)
            .disposed(by: disposeBag)
        
        codeTextField.textField.rx.text.orEmpty.bind(to: self.viewModel.captcha).disposed(by: disposeBag)
        pwdTextField.textField.rx.text.orEmpty.bind(to: self.viewModel.password).disposed(by: disposeBag)
        
        pwdTextField.clearBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.viewModel.password.accept("")
            self?.completeBtn.isEnabled = false
        }).disposed(by: disposeBag)
        
        confirmPwdTextField.clearBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.completeBtn.isEnabled = false
        }).disposed(by: disposeBag)
        
        
        //【获取验证码】
        codeTextField.sendBtn.rx.tap.subscribe(onNext: {[weak self] in
            self?.sendCaptcha()
        }).disposed(by: disposeBag)
        
        //驗證碼發送成功，
        viewModel.codeSubject.subscribe(onNext: { [weak self] (captcha) in
            guard let `self` = self else { return }
            
            if YXConstant.isAutoFillCaptcha() && !captcha.isEmpty {
                // Toast
                self.tempCaptcha = captcha
                self.autoFillVerifyCode()
            }
            
            //开始计时
            self.codeTextField.startCountDown()
        }).disposed(by: disposeBag)
        

        completeBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            
            if (self.viewModel.password.value != self.confirmPwdTextField.textField.text) {
                self.viewModel.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "mine_pwd_diff") , false))
                return
            }
            self.resetUserPwd()
            
        }).disposed(by: disposeBag)
        
        //重设成功 的回调
        self.viewModel.resetSuccessSubject.subscribe(onNext: { [weak self] success in
            self?.resetSuccess()
        }).disposed(by: disposeBag)
    }
    
    func autoFillVerifyCode() {
        if YXConstant.isAutoFillCaptcha() {
            self.codeTextField.textField.insertText(self.tempCaptcha)
        }
    }
    
    func initUI() {
                
        codeTextField.textField.becomeFirstResponder()
        
        view.addSubview(scrollView)
        scrollView.addSubview(sendTipLabel)
        scrollView.addSubview(codeTextField)
        scrollView.addSubview(pwdTextField)
        scrollView.addSubview(confirmPwdTextField)
        scrollView.addSubview(completeBtn)
        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeArea.top)
            make.left.right.bottom.equalTo(self.view)
        }
        
        let horSpace = 30
        //提示
        let tipLab = AccountTipLabel()
        tipLab.text = YXLanguageUtility.kLang(key: "org_reset_password")
        tipLab.font = UIFont.systemFont(ofSize: 24)
        scrollView.addSubview(tipLab)
        tipLab.snp.makeConstraints { (make) in
            make.top.equalTo(scrollView).offset(24)
            make.left.equalTo(scrollView).offset(horSpace)
            make.height.equalTo(30)
        }
       
        sendTipLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(horSpace)
            make.right.equalToSuperview().offset(-horSpace)
            make.top.equalTo(tipLab.snp.bottom).offset(uniVerLength(5))
        }
        

        codeTextField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(horSpace)
            make.right.equalToSuperview().offset(-horSpace)
            make.top.equalTo(sendTipLabel.snp.bottom).offset(30)
            make.height.equalTo(56)
        }
        
        //MARK: - 新密码
        pwdTextField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(horSpace)
            make.right.equalToSuperview().offset(-horSpace)
            make.top.equalTo(codeTextField.snp.bottom).offset(24)
            make.height.equalTo(56)
        }
        
        //为了阻断连续加密的输入框，不然输入键盘会 灰白，没有内容 （14.2的问题），
        let hidTextField = UITextField.init()
        hidTextField.isHidden = false
        hidTextField.backgroundColor = UIColor.clear
        hidTextField.isUserInteractionEnabled = false
        hidTextField.isEnabled = false
        scrollView.addSubview(hidTextField)
        hidTextField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(horSpace)
            make.right.equalToSuperview().offset(-horSpace)
            make.top.equalTo(pwdTextField.snp.bottom).offset(24)
            make.height.equalTo(1)
        }
        
        //MARK: - 确认
        confirmPwdTextField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(horSpace)
            make.right.equalToSuperview().offset(-horSpace)
            make.top.equalTo(pwdTextField.snp.bottom).offset(24)
            make.height.equalTo(56)
        }
        

        completeBtn.snp.makeConstraints { (make) in
            
            make.top.equalTo(confirmPwdTextField.snp.bottom).offset(40)
            make.left.equalToSuperview().offset(horSpace)
            make.right.equalToSuperview().offset(-horSpace)
            make.height.equalTo(48)
            make.width.equalTo(YXConstant.screenWidth - 30 * 2)
        }
        
        //是否需要加【*】号
//        if viewModel.isSecure == true {
//            phoneLab.text = String(format: "+%@ %@", self.viewModel.code, YXUserManager.secretPhone())
//        } else {
//            phoneLab.text = String(format: "+%@ %@", self.viewModel.code, viewModel.phone)
//        }
    }
    //发送验证码
    func sendCaptcha() {
        self.viewModel.hudSubject.onNext(.loading(nil, false))
        
        if self.viewModel.isEmail {
            let emailNumber = self.viewModel.email.removePreAfterSpace()
            self.viewModel.services.loginService.request(.sendEmailInputCaptcha(emailNumber, .type102), response: self.viewModel.sendUserInputCaptchaResponse).disposed(by: disposeBag)
        } else {
            let areaCode = self.viewModel.code
            let phoneNumber = YXUserManager.safeDecrypt(string: self.viewModel.phone.removePreAfterSpace())
            self.viewModel.services.loginService.request(.sendUserInputCaptcha(areaCode, phoneNumber, .type102), response: self.viewModel.sendUserInputCaptchaResponse).disposed(by: disposeBag)
        }
    }
    
    func resetUserPwd() {
        self.viewModel.hudSubject.onNext(.loading(nil, false))
        
        if self.viewModel.isEmail {
            let emailNumber = YXUserManager.safeDecrypt(string: self.viewModel.email.removePreAfterSpace())
            let captcha = self.viewModel.captcha.value.removePreAfterSpace()
            let password = YXUserManager.safeDecrypt(string: self.viewModel.password.value)

            self.viewModel.services.loginService.request(.orgResetPwd("", "", emailNumber, captcha, password, "2"), response: self.viewModel.forgetPwdResponse).disposed(by: self.disposeBag)
            
        } else {
            let areaCode = self.viewModel.code
            let phoneNumber = YXUserManager.safeDecrypt(string:self.viewModel.phone.removePreAfterSpace())
            let captcha = self.viewModel.captcha.value.removePreAfterSpace()
            let password = YXUserManager.safeDecrypt(string: self.viewModel.password.value)

            self.viewModel.services.loginService.request(.orgResetPwd(areaCode, phoneNumber, "", captcha, password, "1"), response: self.viewModel.forgetPwdResponse).disposed(by: self.disposeBag)
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
                if self.navigationController?.viewControllers.contains(vc) ?? false {
                    self.navigationController?.popToViewController(vc, animated: true)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
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
                //刷新
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: ["index" : YXTabIndex.community])
            }
        }))
        //【重新登录】
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "login_reloginTip"), style: .default, handler: {[weak alertView] action in
            alertView?.hide()
            //
            let allViewControllers = self.navigationController?.viewControllers
            //未登录状态，一般是从 登录页面进来的。
            for vc in allViewControllers ?? [] {
                if vc.isKind(of: YXOrgDefaultLoginViewController.self) {
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
