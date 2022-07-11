//
//  YXOrgRegisterEmailViewController.swift
//  uSmartOversea
//
//  Created by 欧冬冬 on 2022/4/21.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import Reusable
import RxSwift
import RxCocoa
import YXKit

class YXOrgRegisterEmailViewController: YXHKViewController, HUDViewModelBased {

    var networkingHUD: YXProgressHUD! = YXProgressHUD()

    var viewModel: YXOrgRegisterEmailVertifyViewModel!
    
    var timeCount = 60
    let timerMark = "activateCode"
    
    var tempCaptcha: String = ""
    
    var scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    var titleLabel: AccountTipLabel = {
        let label = AccountTipLabel()
        label.text = YXLanguageUtility.kLang(key: "verify_current_email_address")
        label.font = UIFont.systemFont(ofSize: uniSize(24))
        label.numberOfLines = 0
        return label
    }()
    
    var sendTipLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.normalFont16()
        label.textColor = QMUITheme().textColorLevel2()
        label.numberOfLines = 0
        return label
    }()
    
    //验证码
    var codeTextField: YXTimeTextField = {
        let textField = YXTimeTextField.init(defaultTip: YXLanguageUtility.kLang(key: "login_codeTip"), placeholder:"")
        return textField
    }()
    
    var nextBtn : QMUIButton = {
        let btn = QMUIButton()
        btn.layer.cornerRadius = 4
        btn.clipsToBounds = true
        btn.backgroundColor = QMUITheme().mainThemeColor()
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .disabled)
        btn.setTitle(YXLanguageUtility.kLang(key: "next_step"), for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "next_step"), for: .disabled)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        bindViewModel()
        bindHUD()
        
        self.sendCaptcha()
        
        let headerContnet = YXLanguageUtility.kLang(key: "org_email_verification_code_sent_to")
        self.sendTipLabel.text = headerContnet + " " + (YXUserManager.shared().curLoginUser?.email ?? "")
    }
    
    func bindViewModel() {

        
        self.viewModel.captcha.bind(to: codeTextField.textField.rx.text).disposed(by: disposeBag)
        codeTextField.textField.rx.text.orEmpty.bind(to: self.viewModel.captcha).disposed(by: disposeBag)
        
        
        //MARK: - viewModel的响应
        
        self.viewModel.captchaValid?.bind(to: self.nextBtn.rx.isEnabled).disposed(by: disposeBag)
        
        self.nextBtn.rx.tap.subscribe(onNext:{[weak self] in
            guard let `self` = self else { return }
            
            self.viewModel.hudSubject?.onNext(.loading(nil, false))
            // 登录之前,先校验
            let captcha = (self.viewModel.captcha.value as String).removePreAfterSpace()
            self.viewModel.services.userService.request(.checkEmailCaptcha(captcha, type: .type1, email: YXUserManager.shared().curLoginUser?.email ?? ""), response: self.viewModel.checkUserInputCaptchaResponse).disposed(by: `self`.disposeBag)

            
        }).disposed(by: disposeBag)
        
        //【获取验证码】
        codeTextField.sendBtn.rx.tap.subscribe(onNext: {[weak self] in
            self?.sendCaptcha()
        }).disposed(by: disposeBag)
        
        
        //驗證碼發送成功，
        viewModel.codeSubject.subscribe(onNext: { [weak self] (captcha) in
            
            guard let `self` = self else { return }
            if YXConstant.isAutoFillCaptcha() && !captcha.isEmpty {
                // Toast 顯示驗證碼
                self.tempCaptcha = captcha
                self.autoFillVerifyCode()
            }
            //开始计时
            self.codeTextField.startCountDown()
        }).disposed(by: disposeBag)
        
        viewModel.checkAccountSubject.subscribe(onNext: { [weak self] _ in
            
            guard let `self` = self else { return }
            let captcha = self.viewModel.captcha.value
            let context = YXNavigatable(viewModel:YXSetTradePwdViewModel(.reSet, oldPwd: "", captcha:captcha, sourceVC: self.viewModel.sourceVC, successBlock: nil))
            self.viewModel.navigator.push(YXModulePaths.setTradePwd.url, context: context)
           
        }).disposed(by: disposeBag)
    }
    
    func initUI() {
        
        self.codeTextField.textField.becomeFirstResponder()
        
        view.addSubview(scrollView)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(sendTipLabel)
        scrollView.addSubview(codeTextField)
        scrollView.addSubview(nextBtn)
        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeArea.top)
            make.left.right.bottom.equalTo(self.view)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(24)
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.height.equalTo(30)
        }
        
        sendTipLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
        }
        
        codeTextField.snp.makeConstraints { (make) in
            make.top.equalTo(sendTipLabel.snp.bottom).offset(40)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.height.equalTo(56)

        }
        
        nextBtn.snp.makeConstraints { (make) in
            make.top.equalTo(codeTextField.snp.bottom).offset(40)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.width.equalTo(YXConstant.screenWidth - 30 * 2)
            make.height.equalTo(48)
        }
        
    }
    
    //MARK: 发送验证码
    func sendCaptcha() {
        self.viewModel.hudSubject?.onNext(.loading(nil, false))
        //清空 验证码
        codeTextField.textField.text = ""
        let email = (YXUserManager.shared().curLoginUser?.email ?? "").removePreAfterSpace()
        self.viewModel.services.userService.request(.sendEmailInputCaptcha(email, .type1), response: self.viewModel.sendUserInputCaptchaResponse).disposed(by: disposeBag)
    }
    
    func autoFillVerifyCode() {
        if YXConstant.isAutoFillCaptcha() {
            self.codeTextField.textField.insertText(self.tempCaptcha)
        }
    }

}
