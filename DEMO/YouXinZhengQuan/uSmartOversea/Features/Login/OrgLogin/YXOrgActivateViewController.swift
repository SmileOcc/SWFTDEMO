//
//  YXOrgActivateViewController.swift
//  uSmartOversea
//
//  Created by 欧冬冬 on 2022/4/14.
//  Copyright © 2022 RenRenDai. All rights reserved.
//
/*模块：激活机构户 */
import UIKit
import Reusable
import RxSwift
import RxCocoa
import YXKit

class YXOrgActivateViewController: YXHKViewController, HUDViewModelBased {
    
    var networkingHUD: YXProgressHUD! = YXProgressHUD()

    var viewModel: YXOrgActivateViewModel!
    
    var timeCount = 60
    let timerMark = "activateCode"
    
    var tempCaptcha: String = ""
    
    var scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    //验证码
    var codeTextField: YXTimeTextField = {
        let textField = YXTimeTextField.init(defaultTip: YXLanguageUtility.kLang(key: "login_codeTip"), placeholder:"")
        return textField
    }()
    
    //证件号
    var idCodeTextField: YXTipsTextField = {
        let textField = YXTipsTextField.init(defaultTip: YXLanguageUtility.kLang(key: "org_register_code_plachold"), placeholder:"")
        if YXLanguageUtility.kLang(key: "org_register_code_plachold").contains("\n") {
            textField.tipsNumber = 2
        }
        return textField
    }()
    
    var pwdTextField: YXSecureTextField = {
        let textField = YXSecureTextField.init(defaultTip: YXLanguageUtility.kLang(key: "login_pwdPlaceHolder"), placeholder:"")
//        if #available(iOS 12.0, *) {
//            textField.textField.textContentType = .newPassword
//        }else{
//            if #available(iOS 11.0, *) {
//                textField.textField.textContentType = .username
//            }
//        }

        return textField
    }()
    
    var confirmPwdTextField: YXSecureTextField = {
        let textField = YXSecureTextField.init(defaultTip: YXLanguageUtility.kLang(key: "login_pwdPlaceHolder"), placeholder:"")
//        if #available(iOS 12.0, *) {
//            textField.textField.textContentType = .newPassword
//        }else{
//            if #available(iOS 11.0, *) {
//                textField.textField.textContentType = .username
//            }
//        }
        return textField
    }()
    
    var completeBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle(YXLanguageUtility.kLang(key: "confirm_activate"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize:16)
        btn.setDisabledTheme(4)
        return btn
    }()
    
    var phoneUnuseBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle(YXLanguageUtility.kLang(key: "login_phoneUnuse"), for: .normal)
        btn.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return btn
    }()
    
    
    var sendTipLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.normalFont16()
        label.textColor = QMUITheme().textColorLevel2()
        label.numberOfLines = 0
        return label
    }()
    
    lazy var declareView : YXDeclareView = {
        let view = YXDeclareView.init(frame: .zero)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        bindViewModel()
        bindHUD()
        
        self.sendCaptcha()
        
        var headerContnet = ""
        var content = ""
        if self.viewModel.isEmail {
            headerContnet = YXLanguageUtility.kLang(key: "org_email_verification_code_sent_to")
            content = self.viewModel.email
        } else {
            headerContnet = YXLanguageUtility.kLang(key: "org_sms_verification_code_sent_to")
            content = "+" + self.viewModel.areaCode + " " + self.viewModel.phone
        }
        
        self.sendTipLabel.text = headerContnet + " " + content
    }
    
    func initUI() {
        
        if self.viewModel.isEmail {
            codeTextField = YXTimeTextField.init(defaultTip: YXLanguageUtility.kLang(key: "login_codeTip"), placeholder:"")
        } else {
            codeTextField = YXTimeTextField.init(defaultTip: YXLanguageUtility.kLang(key: "login_codeTip"), placeholder:"")
        }
        
        let horSpace = 30
        
        self.view.addSubview(scrollView)
        
        scrollView.addSubview(codeTextField)
        scrollView.addSubview(sendTipLabel)
        scrollView.addSubview(idCodeTextField)
        scrollView.addSubview(pwdTextField)
        scrollView.addSubview(confirmPwdTextField)
        scrollView.addSubview(completeBtn)
        scrollView.addSubview(phoneUnuseBtn)
        scrollView.addSubview(declareView)

        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeArea.top)
            make.left.right.bottom.equalTo(self.view)
        }
        
        let tipLab = AccountTipLabel()
        tipLab.text = YXLanguageUtility.kLang(key: "org_activate_title")
        tipLab.font = UIFont.systemFont(ofSize: uniSize(24))
        tipLab.numberOfLines = 0
        scrollView.addSubview(tipLab)
        tipLab.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(24)
            make.left.equalToSuperview().offset(horSpace)
            make.right.equalToSuperview().offset(-horSpace)
        }
        
        sendTipLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(horSpace)
            make.right.equalToSuperview().offset(-horSpace)
            make.top.equalTo(tipLab.snp.bottom).offset(uniVerLength(5))
        }
        
//        let space = uniSize(5) //20
        let labelSize = uniSize(16)
        
        idCodeTextField.textField.font = UIFont.systemFont(ofSize: labelSize)
        idCodeTextField.textField.adjustsFontSizeToFitWidth = true
        codeTextField.textField.font = UIFont.systemFont(ofSize: labelSize)
        pwdTextField.textField.font = UIFont.systemFont(ofSize: labelSize)
        confirmPwdTextField.textField.font = UIFont.systemFont(ofSize: labelSize)
        //MARK: - 【验证码】
        codeTextField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(horSpace)
            make.right.equalToSuperview().offset(-horSpace)
            make.top.equalTo(sendTipLabel.snp.bottom).offset(30)
            make.height.equalTo(56)
        }

        idCodeTextField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(horSpace)
            make.right.equalToSuperview().offset(-horSpace)
            make.top.equalTo(codeTextField.snp.bottom).offset(24)
            make.height.equalTo(56)
        }
        
        //MARK: - 新密码
        pwdTextField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(horSpace)
            make.right.equalToSuperview().offset(-horSpace)
            make.top.equalTo(idCodeTextField.snp.bottom).offset(24)
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
            
            if !self.viewModel.isExitPwd {
                make.top.equalTo(confirmPwdTextField.snp.bottom).offset(40)
            } else {
                make.top.equalTo(idCodeTextField.snp.bottom).offset(40)
            }
            
            make.left.equalToSuperview().offset(horSpace)
            make.right.equalToSuperview().offset(-horSpace)
            make.height.equalTo(48)
            make.width.equalTo(YXConstant.screenWidth - 30 * 2)
        }
        
        phoneUnuseBtn.snp.makeConstraints { (make) in
            make.top.equalTo(completeBtn.snp.bottom).offset(uniVerLength(12))
            make.centerX.equalTo(completeBtn)
            make.height.equalTo(uniVerLength(20))
        }
        
        declareView.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.snp.bottom).offset(-42)
            make.left.equalTo(30.sacel375())
            make.right.equalTo(-30.sacel375())
            make.height.equalTo(36.sacel375())
        }
        
        
        if self.viewModel.isEmail {
            self.phoneUnuseBtn.isHidden = true
        }
        
        if self.viewModel.isExitPwd {
            self.pwdTextField.isHidden = true
            self.confirmPwdTextField.isHidden = true
        }
        
    }

    func bindViewModel() {
        
        if !self.viewModel.isExitPwd {
            Observable.combineLatest(codeTextField.textField.rx.text.orEmpty, pwdTextField.textField.rx.text.orEmpty, confirmPwdTextField.textField.rx.text.orEmpty, idCodeTextField.textField.rx.text.orEmpty)
            {
                textValue1, textValue2, textValue3, textValue4 -> Bool in
                (textValue1.count > 0 && textValue2.count > 0 && textValue3.count > 0 && textValue4.count > 0)
            }
            .bind(to: completeBtn.rx.isEnabled)
            .disposed(by: disposeBag)
            
        } else {
            
            Observable.combineLatest(codeTextField.textField.rx.text.orEmpty, idCodeTextField.textField.rx.text.orEmpty)
            {
                textValue1, textValue2 -> Bool in
                (textValue1.count > 0 && textValue2.count > 0)
                }
                .bind(to: completeBtn.rx.isEnabled)
                .disposed(by: disposeBag)
        }


        idCodeTextField.textField.rx.text.orEmpty.bind(to: self.viewModel.registCode).disposed(by: disposeBag)
        codeTextField.textField.rx.text.orEmpty.bind(to: self.viewModel.captcha).disposed(by: disposeBag)
        pwdTextField.textField.rx.text.orEmpty.bind(to: self.viewModel.password).disposed(by: disposeBag)


        idCodeTextField.clearBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.viewModel.registCode.accept("")
            self?.completeBtn.isEnabled = false
        }).disposed(by: disposeBag)

        pwdTextField.clearBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.viewModel.password.accept("")
            self?.completeBtn.isEnabled = false
        }).disposed(by: disposeBag)

        confirmPwdTextField.clearBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.completeBtn.isEnabled = false

        }).disposed(by: disposeBag)
        
       
        
        completeBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            
            if (self.viewModel.password.value != self.confirmPwdTextField.textField.text && !self.viewModel.isExitPwd) {
                self.viewModel.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "mine_pwd_diff") , false))
                return
            }
            
            self.viewModel.hudSubject?.onNext(.loading(nil, false))
            let captcha = self.viewModel.captcha.value
            let password = YXUserManager.safeDecrypt(string: self.viewModel.password.value)
            let email = YXUserManager.safeDecrypt(string: self.viewModel.email)
            let phone = YXUserManager.safeDecrypt(string: self.viewModel.phone)
            let type = self.viewModel.isEmail ? "2" : "1"
            let registNumber = self.viewModel.registCode.value
            
            self.viewModel.services.aggregationService.request(.orgActiviteLogin(self.viewModel.areaCode, phone, email, captcha, type, registNumber, password), response: self.viewModel.activiteResponse).disposed(by: self.disposeBag)
            
        }).disposed(by: disposeBag)
                
        
        //登錄成功的回調
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
//                if ((self?.viewModel.loginCallBack) == nil) {//防止异常处理，没有传入回调
//                    YXUserManager.registerLoginInitRootViewControler()
//                }
//            }
            
        }).disposed(by: disposeBag)
        
        //手机号码无法使用？ 的响应
        phoneUnuseBtn.rx.tap.bind{[weak self] in
            self?.showPhoneUnuseAlert()
        }.disposed(by: disposeBag)
        
        //【获取验证码】
        codeTextField.sendBtn.rx.tap.subscribe(onNext: {[weak self] in
            self?.sendCaptcha()
        }).disposed(by: disposeBag)
        
        
        //驗證碼發送成功，
        viewModel.codeSubject.subscribe(onNext: { [weak self] (argument) in
            let (_, captcha) = argument
            guard let `self` = self else { return }
            if YXConstant.isAutoFillCaptcha() && !captcha.isEmpty {
                // Toast 顯示驗證碼
                self.tempCaptcha = captcha
                self.autoFillVerifyCode()
            }
            //开始计时
            self.codeTextField.startCountDown()
        }).disposed(by: disposeBag)
        
        declareView.didClickPrivacy = {[weak self]  in
            let dic: [String: Any] = [
                YXWebViewModel.kWebViewModelUrl: YXH5Urls.PRIVACY_POLICY_URL(),
                YXWebViewModel.kWebViewModelCachePolicy : URLRequest.CachePolicy.reloadIgnoringLocalCacheData
            ]
            self?.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        }
        declareView.didClickService = {[weak self] in
            let dic: [String: Any] = [
                YXWebViewModel.kWebViewModelUrl: YXH5Urls.USER_REGISTRATION_AGREEMENT_URL(),
                YXWebViewModel.kWebViewModelCachePolicy : URLRequest.CachePolicy.reloadIgnoringLocalCacheData
            ]
            self?.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        }
    }
    
    func autoFillVerifyCode() {
        if YXConstant.isAutoFillCaptcha() {
            self.codeTextField.textField.insertText(self.tempCaptcha)
        }
    }
    
    //如果手机号码无法使用，请联系客服验证
    func showPhoneUnuseAlert() {
        self.view.endEditing(true)
        
        let alertView = YXAlertView.init(title: YXLanguageUtility.kLang(key: "receive_code_tip_title"), message: YXLanguageUtility.kLang(key: "receive_code_tip_desc_comm_email"))
        
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_confirm"), style: .default, handler: {[weak alertView] action in
            alertView?.hide()
        }))
        alertView.showInWindow()
        
    }
    
    //MARK: 发送验证码
    func sendCaptcha() {
        self.viewModel.hudSubject?.onNext(.loading(nil, false))
        //清空 验证码
        codeTextField.textField.text = ""
        
        if self.viewModel.isEmail {
            let email = self.viewModel.email.removePreAfterSpace()
            self.viewModel.services.loginService.request(.sendEmailInputCaptcha(email, self.viewModel.sendCaptchaType), response: self.viewModel.sendUserInputCaptchaResponse).disposed(by: disposeBag)
        } else {
            let areaCode = self.viewModel.areaCode
            let phoneNumber = YXUserManager.safeDecrypt(string: self.viewModel.phone)
            
            /*获取手机验证码(用户输入手机号)
             type 验证码类型 101注册 102重置密码 103更换手机号 104绑定手机号 105新设备登录校验 106短信登录
             send-phone-captcha/v1 */
            viewModel.services.loginService.request(.sendUserInputCaptcha(areaCode, phoneNumber, self.viewModel.sendCaptchaType), response: self.viewModel.sendUserInputCaptchaResponse).disposed(by: disposeBag)
        }
    }
}
