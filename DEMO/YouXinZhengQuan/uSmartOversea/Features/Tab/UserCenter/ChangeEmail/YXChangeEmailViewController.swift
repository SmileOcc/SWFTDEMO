//
//  YXChangeEmailViewController.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/12.
//  Copyright © 2019 RenRenDai. All rights reserved.
//
/*模块：更换邮箱
 更换邮箱*/
import UIKit
import Reusable
import RxSwift
import RxCocoa
import YXKit

class YXChangeEmailViewController: YXHKViewController, HUDViewModelBased {

    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXChangeEmailViewModel!
    
    var scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    
    //【确认更换邮箱】
    var nextBtn: QMUIButton = {
        let btn = QMUIButton()
        btn.setTitle(YXLanguageUtility.kLang(key: "mine_confirm_email"), for: .normal)
        btn.setSubmmitTheme()
        return btn
    }()
    
    
    lazy var emailInput : YXTipsTextField = {
        let input = YXTipsTextField.init(defaultTip: "", placeholder: YXLanguageUtility.kLang(key: "user_bindEmail_placeHolder"))
        input.selectStyle = .none
        return input
    }()
    
    lazy var captchaInput : YXTimeTextField = {
        let codeInput = YXTimeTextField.init(defaultTip: "", placeholder: YXLanguageUtility.kLang(key: "mine_captcha_placeHolder"))
        codeInput.selectStyle = .none
        return codeInput
    }()
    
    lazy var passwdInput : YXSecureTextField = {
        let passwdInput = YXSecureTextField.init(defaultTip: "", placeholder: YXLanguageUtility.kLang(key: "mine_validation_pwd"))
        passwdInput.selectStyle = .none
        return passwdInput
    }()
    
    //【收不到验证码？】
    var unableBtn: QMUIButton = {
        let btn = QMUIButton(type: .custom)
        btn.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "hlep_receive"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return btn
    }()
    
//    //联系客服
//    var serviceBtn: QMUIButton = {
//        let btn = QMUIButton(type: .custom)
//        return btn
//    }()
//
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        bindViewModel()
        bindHUD()
    }
    
    func initUI() {
        //右导航-消息
       
        self.title = self.viewModel.title
        self.view.backgroundColor = QMUITheme().foregroundColor()
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(emailInput)
        scrollView.addSubview(captchaInput)
        scrollView.addSubview(passwdInput)
        scrollView.addSubview(nextBtn)
        scrollView.addSubview(unableBtn)
     //   scrollView.addSubview(serviceBtn)
        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeArea.top)
            make.left.right.bottom.equalTo(self.view)
        }
     
        //emil
        let emailLab = UILabel()
        emailLab.text = YXLanguageUtility.kLang(key: "mine_email_tips")
        emailLab.font = UIFont.systemFont(ofSize: 12)
        emailLab.textColor = QMUITheme().textColorLevel1()
        scrollView.addSubview(emailLab)
        emailLab.snp.makeConstraints { (make) in
            make.top.equalTo(16)
            make.left.equalTo(16)
            make.height.equalTo(14)
            make.right.equalTo(self.view).offset(-16)
        }
        
        emailInput.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.right.equalTo(self.view).offset(-16)
            make.height.equalTo(48)
            make.top.equalTo(emailLab.snp.bottom).offset(4)
        }
    
        //【验证码】
        let captchaLab = QMUILabel()
        captchaLab.font = UIFont.systemFont(ofSize: 12)
        captchaLab.text = YXLanguageUtility.kLang(key: "mine_captcha_code")
        captchaLab.textColor = QMUITheme().textColorLevel1()
        scrollView.addSubview(captchaLab)
        captchaLab.snp.makeConstraints { (make) in
            make.left.height.right.equalTo(emailLab)
            make.top.equalTo(emailInput.snp.bottom).offset(14)
        }
        
        captchaInput.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(emailInput)
            make.top.equalTo(captchaLab.snp.bottom).offset(4)
        }
        
        //【登录密码】
        let pwdLab = QMUILabel()
        pwdLab.font = UIFont.systemFont(ofSize: 12)
        pwdLab.text = YXLanguageUtility.kLang(key: "login_pwdTip")
        pwdLab.textColor = QMUITheme().textColorLevel1()
        scrollView.addSubview(pwdLab)
        pwdLab.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(emailLab)
            make.top.equalTo(captchaInput.snp.bottom).offset(14)
        }
        
        passwdInput.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(captchaInput)
            make.top.equalTo(pwdLab.snp.bottom).offset(4)
        }
        
        unableBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self.view).offset(-16)
            make.top.equalTo(passwdInput.snp.bottom).offset(16)
            make.height.equalTo(17)
        }
        
        nextBtn.snp.makeConstraints { (make) in
            make.top.equalTo(unableBtn.snp.bottom).offset(32)
            make.left.equalTo(scrollView).offset(16)
            make.right.equalTo(self.view).offset(-16)
            make.height.equalTo(48)
        }
        
       
        
//        //联系客服
//        let serviceImgView = UIImageView(image: UIImage(named: "user_service"))
//        serviceBtn.addSubview(serviceImgView)
//        serviceImgView.snp.makeConstraints { (make) in
//            make.top.equalTo(13)
//            make.centerX.equalToSuperview()
//        }
//        let serviceLabel = UILabel()
//        serviceLabel.text = YXLanguageUtility.kLang(key: "mine_contact_service")
//        serviceLabel.textColor = QMUITheme().textColorLevel3()
//        serviceLabel.font = UIFont.systemFont(ofSize: uniSize(12))
//        serviceBtn.addSubview(serviceLabel)
//        serviceLabel.snp.makeConstraints { (make) in
//            make.top.equalTo(serviceImgView.snp.bottom).offset(6)
//            make.centerX.equalToSuperview()
//        }
//
//        serviceBtn.snp.makeConstraints { (make) in
//            make.centerX.equalTo(nextBtn)
//            make.top.equalTo(scrollView).offset(YXConstant.screenHeight-YXConstant.navBarHeight()-90)
//            make.width.equalTo(70)
//            make.height.equalTo(69)
//        }
//
//        let lineView = UIView()
//        lineView.backgroundColor = QMUITheme().separatorLineColor()
//        scrollView.addSubview(lineView)
//        lineView.snp.makeConstraints { (make) in
//            make.height.equalTo(0.5)
//            make.width.equalTo(self.view)
//            make.bottom.equalTo(serviceBtn.snp.top)
//        }
     
    }
    
    func bindViewModel() {
        
        //MARK:【确认更换邮箱】
        nextBtn.rx.tap.subscribe(onNext: {[weak self] (_) in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.hudSubject.onNext(.loading("", false))
            let pwd = YXUserManager.safeDecrypt(string: strongSelf.viewModel.pwdRelay.value)
            let email = strongSelf.viewModel.emailRelay.value.removePreAfterSpace()
            let captcha = strongSelf.viewModel.captchaRelay.value
            /*更换邮箱
             replace-email/v2 */
            strongSelf.viewModel.services.userService.request(.verifyChangeEmail(email, captcha, pwd), response: strongSelf.viewModel.changeEmailResponse).disposed(by: strongSelf.disposeBag)
        }).disposed(by: disposeBag)
        
//        serviceBtn.rx.tap.subscribe {[weak self] (_) in
//            self?.serviceAction()
//        }.disposed(by: disposeBag)

        unableBtn.rx.tap.subscribe {[weak self] (_) in
            self?.showUnableAlert()
        }.disposed(by: disposeBag)

        
        viewModel.changeSuccessSubject.subscribe(onNext: { [weak self] success in
            self?.changeSuccess()
        }).disposed(by: disposeBag)
        
        viewModel.freezeSubject.subscribe(onNext: { [weak self] msg in
            
            self?.showFreezeAlertWithMsg(msg: msg)
        }).disposed(by: disposeBag)
        //密码错误次数过多账号已锁定，请%d分钟后重新登录或找回密码
        viewModel.lockedSubject.subscribe(onNext: { [weak self] msg in
            self?.showLockedAlertWithMsg(msg: msg)
        }).disposed(by: disposeBag)
        
        captchaInput.sendBtn.rx.tap.subscribe {[weak self] (_) in
            self?.sendCaptcha()
        }.disposed(by: disposeBag)
        
        viewModel.codeSubject.subscribe(onNext: { [weak self] (captcha) in
            guard let `self` = self else { return }//
            
            if YXConstant.isAutoFillCaptcha() {
                self.viewModel.captchaRelay.accept(captcha)
            }
            //开始计时
            self.captchaInput.startCountDown()
        }).disposed(by: disposeBag)
        

        
        viewModel.emailRelay.bind(to: emailInput.textField.rx.text.orEmpty).disposed(by: disposeBag)
        viewModel.captchaRelay.bind(to: captchaInput.textField.rx.text.orEmpty).disposed(by: disposeBag)
        viewModel.pwdRelay.bind(to: passwdInput.textField.rx.text.orEmpty).disposed(by: disposeBag)
        
        emailInput.textField.rx.text.orEmpty.bind(to: viewModel.emailRelay).disposed(by: disposeBag)
        captchaInput.textField.rx.text.orEmpty.bind(to: viewModel.captchaRelay).disposed(by: disposeBag)
        passwdInput.textField.rx.text.orEmpty.bind(to: viewModel.pwdRelay).disposed(by: disposeBag)
        
        viewModel.everythingValid?.bind(to: nextBtn.rx.isEnabled).disposed(by: disposeBag)
        viewModel.emailValid?.bind(to: captchaInput.sendBtn.rx.isEnabled).disposed(by: disposeBag)
    }
    
    
    //发送验证码
    func sendCaptcha() {
        self.viewModel.hudSubject?.onNext(.loading(nil, false))
        let email = self.viewModel.emailRelay.value.removePreAfterSpace()
        self.viewModel.services.loginService.request(.sendEmailInputCaptcha(email, .type10005), response: self.viewModel.sendCaptchaResponse).disposed(by: disposeBag)
    }
    
    func changeSuccess() {
        let allViewControllers = self.navigationController?.viewControllers
        var tempVc: UIViewController? = nil
        for vc in allViewControllers ?? [] {
            if vc.isKind(of: YXAccountViewController.self) || vc.isKind(of: YXOrgAccountViewController.self) {
                tempVc = vc
            }
        }
        
        if let vc = tempVc {
            self.navigationController?.popToViewController(vc, animated: true)
        }
    }
    //密码错误次数过多账号已锁定，请%d分钟后重新登录或找回密码
    func showLockedAlertWithMsg(msg: String) {
        
        self.view.endEditing(true)
        self.viewModel.hudSubject.onNext(.error(msg, false))
        
//        let alertView = YXAlertView(message: msg)
//        alertView.clickedAutoHide = false
//        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_close"), style: .cancel, handler: {[weak alertView] action in
//            alertView?.hide()
//        }))
//
//        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "login_backPwd"), style: .default, handler: {[weak alertView] action in
//            alertView?.hide()
//
//            let context = YXNavigatable(viewModel: YXForgetPwdPhoneViewModel(with: YXUserManager.shared().curLoginUser?.areaCode ?? "", phone: YXUserManager.shared().curLoginUser?.phoneNumber ?? "", isLogin: true, callBack: {_ in }, loginCallBack: nil, fromVC:nil,sourceVC:self))
//            self.viewModel.navigator.push(YXModulePaths.forgetPwdInputPhone.url, context: context)
//        }))
//        alertView.showInWindow()
    }
    
    func showFreezeAlertWithMsg(msg: String) {
        
        self.view.endEditing(true)
        self.viewModel.hudSubject.onNext(.error(msg, false))

        
//        let alertView = YXAlertView(message: msg)
//        alertView.clickedAutoHide = false
//
//        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_iknow"), style: .default, handler: {[weak alertView] action in
//
//            alertView?.hide()
//        }))
//        alertView.showInWindow()
    }
    
    
    func showUnableAlert() {
        let  alertVC = YXAlertViewFactory.noReceivCaptchaAlertView()
        alertVC.backgoundTapDismissEnable = true
        self.present(alertVC, animated: true, completion: nil)
        
    }

}
