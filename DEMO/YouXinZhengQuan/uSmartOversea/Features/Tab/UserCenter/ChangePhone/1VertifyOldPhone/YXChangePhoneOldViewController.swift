//
//  YXChangePhoneOldViewController.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/12.
//  Copyright © 2019 RenRenDai. All rights reserved.
//
/* 模块：更换手机号 第1步
 请验证原来的手机号码 */
import UIKit
import Reusable
import RxSwift
import RxCocoa
import YXKit

class YXChangePhoneOldViewController: YXHKViewController, HUDViewModelBased {

    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXChangePhoneOldViewModel!
    
    
    var scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
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
    
    //下一步
    var nextBtn: QMUIButton = {
        let btn = QMUIButton()
        btn.setTitle(YXLanguageUtility.kLang(key: "common_next"), for: .normal)
        btn.setSubmmitTheme()
        return btn
    }()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        bindViewModel()
        bindHUD()
    }
    
    func initUI() {
      
        
        self.view.backgroundColor = QMUITheme().foregroundColor()
        self.title = YXLanguageUtility.kLang(key: "mine_old_phone")
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(smsCodeInput)
        scrollView.addSubview(passwdInput)
        scrollView.addSubview(nextBtn)
//        scrollView.addSubview(serviceBtn)
        scrollView.addSubview(unableBtn)
        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeArea.top)
            make.left.right.bottom.equalTo(self.view)
        }
       
        //【验证码】
        let captchaLab = QMUILabel()
        captchaLab.font = UIFont.systemFont(ofSize: 12)
        captchaLab.text = YXLanguageUtility.kLang(key: "mine_captcha_code")
        captchaLab.textColor = QMUITheme().textColorLevel1()
        scrollView.addSubview(captchaLab)
        captchaLab.snp.makeConstraints { (make) in
            make.top.equalTo(16)
            make.left.equalTo(16)
            make.height.equalTo(14)
            make.right.equalTo(self.view).offset(-16)
        }
        
        smsCodeInput.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.right.equalTo(self.view).offset(-16)
            make.height.equalTo(48)
            make.top.equalTo(captchaLab.snp.bottom).offset(4)
        }
        
        //【登录密码】
        let pwdLab = QMUILabel()
        pwdLab.font = UIFont.systemFont(ofSize: 12)
        pwdLab.text = YXLanguageUtility.kLang(key: "login_pwdTip")
        pwdLab.textColor = QMUITheme().textColorLevel1()
        scrollView.addSubview(pwdLab)
        pwdLab.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(captchaLab)
            make.top.equalTo(smsCodeInput.snp.bottom).offset(14)
        }
        
        passwdInput.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(smsCodeInput)
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
//
    }
    
    func bindViewModel() {
        //【下一步】
        nextBtn.rx.tap.subscribe(onNext: {[weak self] (_) in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.hudSubject?.onNext(.loading(nil, false))
            
            let pwd = YXUserManager.safeDecrypt(string: strongSelf.viewModel.pwdRelay.value)
            let captcha = strongSelf.viewModel.captchaRelay.value.removePreAfterSpace()
            /*校验更换手机号验证码
             verify-replace-phone/v1 */
            strongSelf.viewModel.services.userService.request(.verifyChangePhone(captcha, pwd), response: self?.viewModel.verifyChangePhoneResponse).disposed(by: strongSelf.disposeBag)
            
        }).disposed(by: disposeBag)
        
        
//        serviceBtn.rx.tap.subscribe(onNext: {[weak self] (_) in
//            self?.serviceAction()
//        }).disposed(by: disposeBag)
         
        smsCodeInput.sendBtn.rx.tap.subscribe(onNext: {[weak self] (_) in
            self?.sendCaptcha()
        }).disposed(by: disposeBag)
        
        viewModel.codeSubject.subscribe(onNext: { [weak self] (captcha) in
            guard let `self` = self else { return }
            self.viewModel.hudSubject.onNext(.message(String(format: "%@ %@", YXLanguageUtility.kLang(key: "common_capthca_tip"),YXUserManager.secretPhone()), true))
            if YXConstant.isAutoFillCaptcha() {
                self.viewModel.captchaRelay.accept(captcha)
            }
            self.smsCodeInput.startCountDown()
        }).disposed(by: disposeBag)
        
        unableBtn.rx.tap.subscribe(onNext: {[weak self] (_) in
            self?.showUnableAlert()
        }).disposed(by: disposeBag)
        
        viewModel.freezeSubject.subscribe(onNext: { [weak self] msg in
            
            self?.showFreezeAlertWithMsg(msg: msg)
        }).disposed(by: disposeBag)
        
        viewModel.lockedSubject.subscribe(onNext: { [weak self] msg in
            
            self?.showLockedAlertWithMsg(msg: msg)
        }).disposed(by: disposeBag)
        
        viewModel.sendCaptcha = {[weak self]  in
            
            self?.sendCaptcha()
        }
        
        viewModel.captchaRelay.bind(to: smsCodeInput.textField.rx.text.orEmpty).disposed(by: disposeBag)
        viewModel.pwdRelay.bind(to: passwdInput.textField.rx.text.orEmpty).disposed(by: disposeBag)
        
        smsCodeInput.textField.rx.text.orEmpty.bind(to: viewModel.captchaRelay).disposed(by: disposeBag)
        passwdInput.textField.rx.text.orEmpty.bind(to: viewModel.pwdRelay).disposed(by: disposeBag)
        viewModel.everythingValid?.bind(to: nextBtn.rx.isEnabled).disposed(by: disposeBag)
        
    }
    //发送验证码
    func  sendCaptcha() {
        self.viewModel.hudSubject?.onNext(.loading(nil, false))
        /*获取手机验证码(默认用户手机号)
         type:业务类型（201 重置交易密码短信 202 更换手机号 203 设置登录密码）
         token-send-phone-captcha/v1  */
        self.viewModel.services.userService.request(.tokenSendCaptcha(202), response: self.viewModel.sendCaptchaResponse).disposed(by: disposeBag)
    }
   
    
    //展示 手机号不可用 弹框
    func showUnableAlert() {
        
        let alertVC = YXAlertViewFactory.noReceivCaptchaAlertView()
        alertVC.backgoundTapDismissEnable = true
        self.present(alertVC, animated: true, completion: nil)
        
//        let  helpTipView = YXAlertViewFactory.noReceivCaptchaAlertView()
//        let alertVc = TYAlertController(alert: helpTipView, preferredStyle: .alert, transitionAnimation: .scaleFade)
//        helpTipView.rightBtn.rx.tap.subscribe(onNext:{ [weak alertVc] in
//            alertVc?.dismiss(animated: true, completion: nil)
//        }).disposed(by: disposeBag)
//        helpTipView.leftBtn.rx.tap.subscribe(onNext:{ [weak alertVc] in
//            alertVc?.dismiss(animated: true, completion: nil)
//        }).disposed(by: disposeBag)
//
//        alertVc!.backgoundTapDismissEnable = true
//        self.present(alertVc!, animated: true, completion: nil)
//        let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "mine_phone_service"))
//        alertView.clickedAutoHide = false
//        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: {[weak alertView] action in
//            alertView?.hide()
//        }))
//        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "mine_contact_service"), style: .default, handler: {[weak alertView,weak self] action in
//            alertView?.hide()
//            self?.serviceAction()
//        }))
//        alertView.showInWindow()
    }
    //
    func showLockedAlertWithMsg(msg: String) {
        self.view.endEditing(true)
        self.viewModel.hudSubject.onNext(.error(msg, false))
        
//        self.view.endEditing(true)
//
//        let alertView = YXAlertView(message: msg)
//        alertView.clickedAutoHide = false
//        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_close"), style: .cancel, handler: {[weak alertView] action in
//            alertView?.hide()
//        }))
//        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "login_backPwd"), style: .default, handler: {[weak alertView, weak self] action in
//            guard let `self` = self else { return }
//
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
//        self.view.endEditing(true)
//
//        let alertView = YXAlertView(message: msg)
//        alertView.clickedAutoHide = false
//
//        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_iknow"), style: .default, handler: {[weak alertView] action in
//
//            alertView?.hide()
//        }))
//        alertView.showInWindow()
    }
}
