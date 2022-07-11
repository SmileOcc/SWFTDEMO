//
//  YXChangePhoneNewViewController.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/12.
//  Copyright © 2019 RenRenDai. All rights reserved.
//
/*  模块：更换手机号 第2步
 请验证手机号码 */
import UIKit
import Reusable
import RxSwift
import RxCocoa
import YXKit
import TYAlertController

class YXChangePhoneNewViewController: YXHKViewController, HUDViewModelBased {

    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXChangePhoneNewViewModel!
    
    
    var scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    
   
    //【确认更换手机号码】
    var nextBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle(YXLanguageUtility.kLang(key: "mine_confirm_phone"), for: .normal)
        btn.setSubmmitTheme()
        return btn
    }()

    
    lazy var phoneInput : YXPhoneTextField = {
        let input = YXPhoneTextField.init(defaultTip: "", placeholder: YXLanguageUtility.kLang(key: "user_resetPhone_placeHolder"))
        input.selectStyle = .none
        return input
    }()
    
    lazy var smsCodeInput : YXTimeTextField = {
        let codeInput = YXTimeTextField.init(defaultTip: "", placeholder: YXLanguageUtility.kLang(key: "mine_captcha_placeHolder"))
        codeInput.selectStyle = .none
        return codeInput
    }()
    
    //【收不到验证码】
    var noReceiveBtn: QMUIButton = {
        let btn = QMUIButton(type: .custom)
        btn.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "hlep_receive"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        bindViewModel()
        bindHUD()
    }
 
    
    func bindViewModel() {
        
        noReceiveBtn.rx.tap.subscribe {[weak self] (_) in
            self?.showUnableAlert()
        }.disposed(by: disposeBag)

        
        phoneInput.areaCodeBtn.rx.tap.subscribe { [weak self] (_) in
            self?.showMoreAreaAlert()
        }.disposed(by: disposeBag)

        smsCodeInput.sendBtn.rx.tap.subscribe(onNext: {[weak self] (_) in
            self?.sendCaptcha()
        }).disposed(by: disposeBag)
        //MARK: 【确认更换手机号码】 的响应
        nextBtn.rx.tap.subscribe(onNext: {[weak self] (_) in
            
            guard let strongSelf = self else { return }
            strongSelf.viewModel.hudSubject?.onNext(.loading(nil, false))
            
            var phone = strongSelf.viewModel.phoneRelay.value.removePreAfterSpace()
            phone = YXUserManager.safeDecrypt(string: phone) //手机号
            let captcha = strongSelf.viewModel.captchaRelay.value.removePreAfterSpace() //验证码
            /*更换手机号
             replace-phone/v1 */
            strongSelf.viewModel.services.userService.request(.changePhone(captcha, phone, strongSelf.viewModel.areaCodeRelay.value), response: strongSelf.viewModel.changePhoneResponse).disposed(by: strongSelf.disposeBag)
            
        }).disposed(by: disposeBag)
        
        viewModel.codeSubject.subscribe(onNext: { [weak self] (captcha) in
            guard let `self` = self else { return }
            
            if YXConstant.isAutoFillCaptcha() {
                self.viewModel.captchaRelay.accept(captcha)
                self.smsCodeInput.textField.becomeFirstResponder()
            }
            self.smsCodeInput.startCountDown()
        }).disposed(by: disposeBag)
        /*更换手机号
         replace-phone/v1 成功的处理 */
        self.viewModel.changeSuccessSubject.subscribe(onNext: { [weak self] success in
            self?.changeSuccess()
        }).disposed(by: disposeBag)
        
        self.viewModel.serviceSubject.subscribe(onNext: { [weak self] success in
            self?.showNetServiceAlert()
        }).disposed(by: disposeBag)
        
//        self.viewModel.timeoutSubject.subscribe(onNext: { [weak self] (_) in
//            if (self?.viewModel.sendCode) != nil {
//                 self?.showTimeoutAlert()
//            }
//
//        }).disposed(by: disposeBag)
        
        viewModel.phoneRelay.bind(to: phoneInput.textField.rx.text.orEmpty).disposed(by: disposeBag)
        viewModel.captchaRelay.bind(to: smsCodeInput.textField.rx.text.orEmpty).disposed(by: disposeBag)
        
        phoneInput.textField.rx.text.orEmpty.bind(to: viewModel.phoneRelay).disposed(by: disposeBag)
        smsCodeInput.textField.rx.text.orEmpty.bind(to: viewModel.captchaRelay).disposed(by: disposeBag)
        
        viewModel.everythingValid?.bind(to: nextBtn.rx.isEnabled).disposed(by: disposeBag)
        viewModel.phoneValid?.bind(to: smsCodeInput.sendBtn.rx.isEnabled).disposed(by: disposeBag)
    }
    
    func initUI() {
        //self.navigationItem.title = YXLanguageUtility.kLang(key: "mine_changePhoneNaviTitle")
        
        self.view.backgroundColor = QMUITheme().foregroundColor()
        self.title = YXLanguageUtility.kLang(key: "mine_validation_phone")
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(phoneInput)
        scrollView.addSubview(smsCodeInput)
        scrollView.addSubview(nextBtn)
        scrollView.addSubview(noReceiveBtn)
        //scrollView.addSubview(serviceBtn)
        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeArea.top)
            make.left.right.bottom.equalTo(self.view)
        }
    
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
        self.phoneInput.areaCodeLale.text = "+\(YXUserManager.shared().defCode)"
        
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
        
        noReceiveBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self.view).offset(-16)
            make.top.equalTo(smsCodeInput.snp.bottom).offset(16)
            make.height.equalTo(17)
        }
        
        //【确认更换手机号码】
        nextBtn.snp.makeConstraints { (make) in
            make.top.equalTo(noReceiveBtn.snp.bottom).offset(32)
            make.left.equalTo(scrollView).offset(20)
            make.right.equalTo(self.view).offset(-20)
            make.height.equalTo(44)
        }
        
        
    }
    
    
    /*更换手机号
     replace-phone/v1 成功的处理:返回 */
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
    
    func sendCaptcha() {
        
        self.viewModel.hudSubject?.onNext(.loading(nil, false))
        let areaCode = self.viewModel.areaCodeRelay.value
        var phone = (self.viewModel.phoneRelay.value as String).removePreAfterSpace()
        phone = YXUserManager.safeDecrypt(string: phone)
        viewModel.services.loginService.request(.sendUserInputCaptcha(areaCode, phone, .type103), response: self.viewModel.sendCaptchaResponse).disposed(by: disposeBag)
    }
        
    func showTimeoutAlert(msg:String) {
        self.view.endEditing(true)
        self.viewModel.hudSubject.onNext(.error(msg, false))
        
//        let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "mine_timeout"))
//        alertView.clickedAutoHide = false
//        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "mine_validation"), style: .default, handler: {[weak alertView] action in
//            alertView?.hide()
//            self.navigationController?.popViewController(animated: true)
//        }))
//        alertView.showInWindow()
    }
    
    func showNetServiceAlert() {
        
        let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "mine_phone_registered"))
        alertView.clickedAutoHide = false
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: {[weak alertView] action in
            alertView?.hide()
        }))
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "mine_contact_service"), style: .default, handler: {[weak alertView,weak self] action in
            alertView?.hide()
            self?.serviceAction()
        }))
        alertView.showInWindow()
    }
    
    func showUnableAlert() {
        let  alertVC = YXAlertViewFactory.noReceivCaptchaAlertView()
        alertVC.backgoundTapDismissEnable = true
        self.present(alertVC, animated: true, completion: nil)
    }
}

extension YXChangePhoneNewViewController {

    private func showMoreAreaAlert() {
        let areaCodeModel = YXAreaCodeViewModel()
        areaCodeModel.didSelectSubject.subscribe(onNext: { [weak self] (code) in
            guard let `self` = self else {return}
            self.phoneInput.areaCodeLale.text = "+\(code)"
            self.viewModel.areaCodeRelay.accept(code)
            self.phoneInput.textField.becomeFirstResponder()
        }).disposed(by: self.disposeBag)
        
        let context = YXNavigatable(viewModel: areaCodeModel)
        self.viewModel.navigator.present(YXModulePaths.areaCodeSelection.url, context: context, animated: true)
    }

}



