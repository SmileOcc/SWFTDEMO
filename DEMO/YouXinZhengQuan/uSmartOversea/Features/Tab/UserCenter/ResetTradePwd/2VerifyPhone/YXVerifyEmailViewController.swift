//
//  YXVerifyPhoneViewController.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/12.
//  Copyright © 2019 RenRenDai. All rights reserved.
//
/* 模块：重置交易密码 第2步
 请验证邮箱  */
import UIKit
import Reusable
import RxSwift
import RxCocoa
import YXKit
import TYAlertController

class AccountTipLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.textColor = QMUITheme().textColorLevel1()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class YXVerifyEmailViewController: YXHKViewController, HUDViewModelBased {

    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXVerifyEmailViewModel!
    
    let codeRelay = BehaviorRelay<String>(value: "")
    
    
    var scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    lazy var captchaInputView : YXTimeTextField = {
        let codeInput = YXTimeTextField.init(defaultTip: "", placeholder: YXLanguageUtility.kLang(key: "mine_captcha_placeHolder"))
        codeInput.selectStyle = .none
        return codeInput
    }()
 
    
    var nextBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle(YXLanguageUtility.kLang(key: "common_next"), for: .normal)
        btn.setSubmmitTheme()
        return btn
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        bindViewModel()
        bindHUD()
        
        sendCaptcha()
    }
    
    func initUI() {
        
        
        view.addSubview(scrollView)
        scrollView.addSubview(captchaInputView)
        scrollView.addSubview(nextBtn)
    
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeArea.top)
            make.left.right.bottom.equalTo(self.view)
        }
        //【请验证手机号码】
        let tipLab = UILabel()
        tipLab.text = YXLanguageUtility.kLang(key: "mine_vertfy_email_tip")
        tipLab.font = UIFont.systemFont(ofSize: 20)
        tipLab.textColor = QMUITheme().textColorLevel1()
        scrollView.addSubview(tipLab)
        tipLab.snp.makeConstraints { [weak self](make) in
            guard let strongSelf = self else {return}
            make.top.equalTo(scrollView).offset(16)
            make.left.equalTo(scrollView).offset(16)
            make.right.equalTo(strongSelf.view).offset(-16)
            //make.height.equalTo(50)
        }
        
        
        let tipLab2 = UILabel()
        tipLab2.text = String(format: "%@ %@",YXLanguageUtility.kLang(key: "mine_captcha_sendto"),YXUserManager.secretEmail())
        tipLab2.font = UIFont.systemFont(ofSize: 14)
        tipLab2.textColor = QMUITheme().textColorLevel3()
        scrollView.addSubview(tipLab2)
        tipLab2.snp.makeConstraints { (make) in
            make.top.equalTo(tipLab.snp.bottom).offset(8)
            make.left.right.equalTo(tipLab)
        }
        
        let tipLab3 = UILabel()
        tipLab3.font = .systemFont(ofSize: 12)
        tipLab3.textColor = QMUITheme().textColorLevel1()
        tipLab3.text = YXLanguageUtility.kLang(key: "verCode_tip")
        scrollView.addSubview(tipLab3)
        
        tipLab3.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.bottom.equalTo(captchaInputView.snp.top).offset(-4)
        }
       
        captchaInputView.snp.makeConstraints { (make) in
            make.top.equalTo(tipLab2.snp.bottom).offset(48)
            make.right.equalTo(self.view.snp.right).offset(-16)
            make.left.equalTo(16)
            make.height.equalTo(48)
        }
        
        nextBtn.snp.makeConstraints { (make) in
            make.top.equalTo(captchaInputView.snp.bottom).offset(205)
            make.left.equalTo(scrollView).offset(16)
            make.right.equalTo(self.view).offset(-16)
            make.height.equalTo(48)
        }
        
        
    }
    
    func bindViewModel() {
        //MARK: 【下一步】的响应
        nextBtn.rx.tap.subscribe(onNext: {[weak self] (_) in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.hudSubject.onNext(.loading("", false))
            /* 校验邮箱验证码是否正确
             type: 业务类型（1）
             check-email-captcha/v1 */
           let captcha = (strongSelf.viewModel.captcha.value as String).removePreAfterSpace()
            strongSelf.viewModel.services.userService.request(.checkEmailCaptcha(captcha, type: .type1, email: YXUserManager.shared().curLoginUser?.email ?? ""), response: strongSelf.viewModel.checkCaptchaResponse).disposed(by: strongSelf.disposeBag)
           
        }).disposed(by: disposeBag)
        
        captchaInputView.textField.rx.text.orEmpty
            .asDriver()
            .map{$0.count > 0}
            .drive(nextBtn.rx.isEnabled)
            .disposed(by: disposeBag)
        
        codeRelay.asObservable().bind(to: captchaInputView.textField.rx.text.orEmpty).disposed(by: self.disposeBag)

        
        captchaInputView.sendBtn.rx.tap.subscribe {[weak self] (_) in
            self?.sendCaptcha()
        } .disposed(by: disposeBag)

        
        viewModel.codeSubject.subscribe(onNext: { [weak self] (captcha) in
            guard let `self` = self else { return }
            
            if YXConstant.isAutoFillCaptcha() {
                self.viewModel.captcha.accept(captcha)
            }
            let msg = String(format: "%@ %@",YXLanguageUtility.kLang(key: "mine_captcha_sendto"),YXUserManager.secretEmail())
            self.viewModel.hudSubject.onNext(.message(msg, true))
            self.captchaInputView.startCountDown()
            self.captchaInputView.textField.becomeFirstResponder()
        }).disposed(by: disposeBag)
        /* 校验验证码是否正确
         type:
         check-email-captcha/v1  成功的处理 */
        viewModel.checkSubject.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            let captcha = self.viewModel.captcha.value
            let context = YXNavigatable(viewModel:YXSetTradePwdViewModel(.reSet, oldPwd: "", captcha:captcha, sourceVC: self.viewModel.vc, successBlock: nil))
            self.viewModel.navigator.push(YXModulePaths.setTradePwd.url, context: context)
        }).disposed(by: disposeBag)
        
        captchaInputView.textField.rx.text.orEmpty.asObservable().bind(to: self.viewModel.captcha).disposed(by: disposeBag)
        self.viewModel.captcha.bind(to: captchaInputView.textField.rx.text.orEmpty).disposed(by: disposeBag)
    }
    
    //【手机号不可用？】的响应 弹框
    func showUnableAlert() {
        
        let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "mine_phone_service"))
        alertView.clickedAutoHide = false
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: {[weak alertView] action in
            alertView?.hide()
            
        }))
        
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "mine_contact_service"), style: .default, handler: {[weak alertView, weak self] action in
            alertView?.hide()
            self?.serviceAction()
        }))
        alertView.showInWindow()
    }
    
    func sendCaptcha() {
        self.viewModel.hudSubject?.onNext(.loading(nil, false))
        viewModel.services.userService.request(.sendEmailInputCaptcha(YXUserManager.shared().curLoginUser?.email ?? "", .type1), response: self.viewModel.sendCaptchaResponse).disposed(by: disposeBag)
    }
    
    deinit {
    }
    
    func backAlert() {
        let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "mine_giveup_forget"))
        alertView.clickedAutoHide = false
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "mine_no"), style: .cancel, handler: {[weak alertView] action in
            alertView?.hide()
        }))

        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "mine_yes"), style: .default, handler: {[weak alertView] action in
            alertView?.hide()
            self.back()
        }))
        alertView.showInWindow()
    }
    
    override func shouldPopViewController(byBackButtonOrPopGesture byPopGesture: Bool) -> Bool {
        backAlert()
        return false
    }
    
    func back() {
        self.navigationController?.popViewController(animated: true)
//        for vc in self.navigationController?.viewControllers ?? [] {
//            if let viewController = vc as? YXChangeTradePwdViewController {
//                if viewController.viewModel.funType == YXTradePwdFunType.change {
//                    self.navigationController?.popToViewController(vc, animated: true)
//                    return
//                }
//            }
//        }
//
//        self.navigationController?.popToViewController(self.viewModel.vc, animated: true)
    }
    
}
