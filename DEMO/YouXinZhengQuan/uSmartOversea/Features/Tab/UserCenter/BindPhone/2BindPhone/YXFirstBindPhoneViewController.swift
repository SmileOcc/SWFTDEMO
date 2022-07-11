//
//  YXFirstBindPhoneViewController.swift
//  uSmartOversea
//
//  Created by rrd on 2019/5/14.
//  Copyright © 2019 RenRenDai. All rights reserved.
//
/*模块：绑定手机号  第2步
 请输入验证码、登录密码 */
import UIKit
import RxSwift
import RxCocoa
import SnapKit


class YXFirstBindPhoneViewController: YXHKViewController, HUDViewModelBased {

    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    
    var viewModel: YXFirstBindPhoneViewModel!
    
    
    let codeRelay = BehaviorRelay<String>(value: "")
    
    var scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
  
    //【完成绑定】
    var completeBtn: QMUIButton = {
        let btn = QMUIButton()
        btn.setTitle(YXLanguageUtility.kLang(key: "common_confirm"), for: .normal)
       // btn.setTitle(YXLanguageUtility.kLang(key: "user_finishBind"), for: .disabled)
        btn.setSubmmitTheme()
        return btn
    }()
    //【手机号不可用？】
    var unableBtn: QMUIButton = {
        let btn = QMUIButton(type: .custom)
        btn.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "hlep_receive"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return btn
    }()
   
    
    lazy var phoneInput : YXPhoneTextField = {
        let input = YXPhoneTextField.init(defaultTip: "", placeholder: YXLanguageUtility.kLang(key: "user_bindPhone_placeHolder"))
        input.selectStyle = .none
        return input
    }()
    
    lazy var smsCodeInput : YXTimeTextField = {
        let codeInput = YXTimeTextField.init(defaultTip: "", placeholder: YXLanguageUtility.kLang(key: "mine_captcha_placeHolder"))
        codeInput.selectStyle = .none
        return codeInput
    }()
    
    lazy var passwdInput : YXSecureTextField = {
        let passwdInput = YXSecureTextField.init(defaultTip: "", placeholder: YXLanguageUtility.kLang(key: "mine_validation_pwd"))
        passwdInput.selectStyle = .none
        return passwdInput
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        bindViewModel()
        bindHUD()
        // Do any additional setup after loading the view.
    }
    
    func initUI() {
        //右导航栏-消息
        
        self.view.addSubview(scrollView)
        
        scrollView.addSubview(completeBtn)
        scrollView.addSubview(unableBtn)
        
        scrollView.addSubview(phoneInput)
        scrollView.addSubview(smsCodeInput)
        scrollView.addSubview(passwdInput)
        
        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeArea.top)
            make.left.right.bottom.equalTo(self.view)
        }
        
        self.title = YXLanguageUtility.kLang(key: "user_bindPhoneTitle")
     
        //手机号
        let phoneLab = UILabel()
        phoneLab.text = YXLanguageUtility.kLang(key: "phone_number")
        phoneLab.font = UIFont.systemFont(ofSize: 12)
        phoneLab.textColor = QMUITheme().textColorLevel1()
        scrollView.addSubview(phoneLab)
        phoneLab.snp.makeConstraints { (make) in
            make.top.equalTo(16)
            make.left.equalTo(16)
            make.height.equalTo(14)
            make.right.equalTo(self.view).offset(-16)
        }
        
        phoneInput.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.right.equalTo(self.view).offset(-16)
            make.height.equalTo(48)
            make.top.equalTo(phoneLab.snp.bottom).offset(4)
        }
        
        //【验证码】
        let captchaLab = QMUILabel()
        captchaLab.font = UIFont.systemFont(ofSize: 12)
        captchaLab.text = YXLanguageUtility.kLang(key: "mine_get_captcha")
        captchaLab.textColor = QMUITheme().textColorLevel1()
        scrollView.addSubview(captchaLab)
        captchaLab.snp.makeConstraints { (make) in
            make.left.height.right.equalTo(phoneLab)
            make.top.equalTo(phoneInput.snp.bottom).offset(14)
        }
        
        smsCodeInput.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(phoneInput)
            make.top.equalTo(captchaLab.snp.bottom).offset(4)
        }
        
     
      
        //【登录密码】
        let pwdLab = QMUILabel()
        pwdLab.font = UIFont.systemFont(ofSize: 12)
        pwdLab.text = YXLanguageUtility.kLang(key: "login_pwdTip")
        pwdLab.textColor = QMUITheme().textColorLevel1()
        scrollView.addSubview(pwdLab)
        pwdLab.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(phoneLab)
            make.top.equalTo(smsCodeInput.snp.bottom).offset(14)
        }
        
        passwdInput.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(phoneInput)
            make.top.equalTo(pwdLab.snp.bottom).offset(4)
        }
        
        //【手机号不可用？】
        unableBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self.view).offset(-16)
            make.top.equalTo(passwdInput.snp.bottom).offset(16)
            make.height.equalTo(17)
        }
     
        
        //【完成绑定】
        completeBtn.snp.makeConstraints { (make) in
            make.top.equalTo(unableBtn.snp.bottom).offset(34)
            make.left.equalTo(scrollView).offset(16)
            make.right.equalTo(self.view).offset(-16)
            make.height.equalTo(48)
        }
       
        
    }
    
    func bindViewModel() {
        
        //【完成绑定】的响应
        completeBtn.rx.tap.subscribe(onNext: {[weak self] (_) in
            guard let strongSelf = self else { return }
            
            strongSelf.viewModel.hudSubject?.onNext(.loading(nil, false))
            
            let pwd = YXUserManager.safeDecrypt(string: strongSelf.viewModel.pwdRelay.value ) //密码
            let phone = YXUserManager.safeDecrypt(string: strongSelf.viewModel.phoneRelay.value.removePreAfterSpace())//手机号
            let captcha = strongSelf.viewModel.captchaRelay.value.removePreAfterSpace()//验证码
            /*第一次绑定手机号
             api/bind-phone/v1  */
            strongSelf.viewModel.services.userService.request(.bindPhone(areaCode: strongSelf.viewModel.areaCodeRelay.value, captcha: captcha, password: pwd, phoneNumber: phone), response: strongSelf.viewModel.bindPhoneResponse).disposed(by: strongSelf.disposeBag)
        
        }).disposed(by: disposeBag)
        
        
        //【获取验证码】
        smsCodeInput.sendBtn.rx.tap.subscribe(onNext: {[weak self] in
            self?.sendCaptcha()
        }).disposed(by: disposeBag)
        //【手机号不可用？】
        unableBtn.rx.tap.subscribe(onNext: {[weak self] in
            self?.showUnableAlert()
        }).disposed(by: disposeBag)
       
        //MARK: viewModel
        //token-send-phone-captcha/v1  接口的成功处理
        viewModel.codeSubject.subscribe(onNext: { [weak self] (captcha) in
            guard let `self` = self else { return }//关键字要加【``】,就可以使用self了
            
            if YXConstant.isAutoFillCaptcha() {
                self.viewModel.captchaRelay.accept(captcha)
            }
            //开始计时
            self.smsCodeInput.startCountDown()
        }).disposed(by: disposeBag)
        
        //成功 返回
        viewModel.bindPhoneSuccessSubject.subscribe(onNext: { [weak self] success in
            guard let strongSelf = self else {return}
            if ((self?.viewModel.bindCallBack) != nil) {
                return
            }
            if success {
                self?.viewModel.hudSubject.onNext(.success("Bind Successfully", true))
                //返回
                if let vc = strongSelf.viewModel.sourceVC {
                    strongSelf.navigationController?.popToViewController(vc, animated: true)
                } else {
                    let allViewControllers = strongSelf.navigationController?.viewControllers
                    var tempVc: UIViewController? = nil
                    for vc in allViewControllers ?? [] {
                        if vc.isKind(of: YXAccountViewController.self) || vc.isKind(of: YXOrgAccountViewController.self) {
                            tempVc = vc
                        }
                    }
                    if let vc = tempVc {
                        strongSelf.navigationController?.popToViewController(vc, animated: true)
                    }
                }
                
            }
        }).disposed(by: disposeBag)
        
        phoneInput.areaCodeBtn.rx.tap.subscribe {[weak self] (_) in
            self?.showMoreAreaAlert()
        }.disposed(by: disposeBag)
        
        viewModel.phoneRelay.bind(to: phoneInput.textField.rx.text.orEmpty).disposed(by: disposeBag)
        viewModel.captchaRelay.bind(to: smsCodeInput.textField.rx.text.orEmpty).disposed(by: disposeBag)
        viewModel.pwdRelay.bind(to: passwdInput.textField.rx.text.orEmpty).disposed(by: disposeBag)
        
        phoneInput.textField.rx.text.orEmpty.bind(to: viewModel.phoneRelay).disposed(by: disposeBag)
        smsCodeInput.textField.rx.text.orEmpty.bind(to: viewModel.captchaRelay).disposed(by: disposeBag)
        passwdInput.textField.rx.text.orEmpty.bind(to: viewModel.pwdRelay).disposed(by: disposeBag)
        
        viewModel.everythingValid?.bind(to: completeBtn.rx.isEnabled).disposed(by: disposeBag)
        viewModel.phoneValid?.bind(to: smsCodeInput.sendBtn.rx.isEnabled).disposed(by: disposeBag)
    }
    
    //发送验证码
    func sendCaptcha() {
        self.viewModel.hudSubject?.onNext(.loading(nil, false))
        
        /*获取手机验证码(用户输入手机号)
         type 验证码类型 101注册 102重置密码 103更换手机号 104绑定手机号 105新设备登录校验 106短信登录
         send-phone-captcha/v1 */
        let areaCode = self.viewModel.areaCodeRelay.value
        let phone = YXUserManager.safeDecrypt(string: self.viewModel.phoneRelay.value.removePreAfterSpace())
        self.viewModel.services.loginService.request(.sendUserInputCaptcha(areaCode,phone,.type104), response: self.viewModel.sendCaptchaResponse).disposed(by: disposeBag)
    }
 
    //展示 手机号不可用 弹框
    func showUnableAlert() {
        
//        let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "mine_phone_service"))
//        alertView.clickedAutoHide = false
//        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: {[weak alertView] action in
//            alertView?.hide()
//        }))
//        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "mine_contact_service"), style: .default, handler: {[weak alertView,weak self] action in
//            alertView?.hide()
//            //展示 【联系客服】 弹框
//            self?.serviceAction()
//        }))
//        alertView.showInWindow()
        
        let  alertVC = YXAlertViewFactory.noReceivCaptchaAlertView()
        alertVC.backgoundTapDismissEnable = true
        self.present(alertVC, animated: true, completion: nil)
        
    }
    
    private func showMoreAreaAlert() {
        let areaCodeModel = YXAreaCodeViewModel()
        areaCodeModel.didSelectSubject.subscribe(onNext: { [weak self] (code) in
            guard let `self` = self else {return}
            self.phoneInput.areaCodeLale.text = "+\(code)"
            self.viewModel.areaCodeRelay.accept(code)
        }).disposed(by: self.disposeBag)
        
        let context = YXNavigatable(viewModel: areaCodeModel)
        self.viewModel.navigator.present(YXModulePaths.areaCodeSelection.url, context: context, animated: true)

    }
}
