//
//  YXDoubleCheckViewController.swift
//  uSmartOversea
//
//  Created by mac on 2019/3/28.
//  Copyright © 2019 RenRenDai. All rights reserved.
//
//检测到新设备登录，请输入短信验证码
import UIKit
import Reusable
import RxSwift
import RxCocoa
import SnapKit

import YXKit
import TYAlertController //联系客服 弹框

class YXDoubleCheckViewController: YXHKViewController, HUDViewModelBased {
    var networkingHUD: YXProgressHUD! = YXProgressHUD()

    var viewModel: YXDoubleCheckViewModel!

    var timeCount = 60
    let timerMark = "doubleCheck"
    
    var scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    //手机号码
    var phoneLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: uniSize(18))
        lab.textColor = QMUITheme().textColorLevel1()
        lab.numberOfLines = 0
       
        return lab
    }()
    //输入视图
    var gridInputView: YXGridInputView = {
        let gridWidth:CGFloat
        switch YXConstant.screenSize {
        case .size3_5,.size4:
            gridWidth = 40
        default:
            gridWidth = 50
        }
        let view = YXGridInputView(gridWidth: gridWidth, viewWidth: UIScreen.main.bounds.width-40, isSecure: false)
        view.textField.font = UIFont.systemFont(ofSize: 26)
        if #available(iOS 12.0, *) {
            view.textField.textContentType = .oneTimeCode
        }
        return view
    }()
    //重新发送
    var codeBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle(YXLanguageUtility.kLang(key: "login_resend"), for: .normal)
        btn.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        btn.setTitleColor(QMUITheme().textColorLevel1(), for: .disabled)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return btn
    }()
    //手机号码无法使用？
    var phoneUnuseBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle(YXLanguageUtility.kLang(key: "login_phoneUnuse"), for: .normal)
        btn.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindHUD()
        initUI()
        bindViewModel()
        sendCaptcha()
    }
    
    func bindViewModel() {
        //重新发送 的响应
        codeBtn.rx.tap.bind { [weak self] in
            self?.sendCaptcha()
            }
            .disposed(by: disposeBag)
        //输入视图的 响应
        gridInputView.textField.rx.text.orEmpty.asObservable()
            .filter {
                $0.count >= 6
            }
            .subscribe(onNext: { [weak self] string in
                guard let strongSelf = self else { return }
                let captcha = string.removePreAfterSpace()
                strongSelf.viewModel.captcha = captcha
                strongSelf.gridInputView.clearText()
                strongSelf.viewModel.hudSubject?.onNext(.loading(nil, false))
                
                if strongSelf.viewModel.email.count > 0 {
                    let email = YXUserManager.safeDecrypt(string: strongSelf.viewModel.email.removePreAfterSpace())
                    strongSelf.viewModel.services.aggregationService.request(.orgDouableCheckLogin("", "", email, captcha, "2"), response: strongSelf.viewModel.loginResponse).disposed(by: strongSelf.disposeBag)
                } else {
                    let areaCode = strongSelf.viewModel.code
                    let phoneNumber = YXUserManager.safeDecrypt(string: strongSelf.viewModel.phone.removePreAfterSpace())
                    if strongSelf.viewModel.isOrg {
                        strongSelf.viewModel.services.aggregationService.request(.orgDouableCheckLogin(areaCode, phoneNumber, "", captcha, "1"), response: strongSelf.viewModel.loginResponse).disposed(by: strongSelf.disposeBag)
                    } else {
                        /* 短信验证码登录聚合接口
                         captcha-login-aggregation/v1 */
                        strongSelf.viewModel.services.aggregationService.request(.captchaLogin(areaCode, phoneNumber, captcha), response: strongSelf.viewModel.loginResponse).disposed(by: strongSelf.disposeBag)
                    }
                }
            })
            .disposed(by: disposeBag)
        //手机号码无法使用？ 的响应
        phoneUnuseBtn.rx.tap.bind{[weak self] in
            self?.showPhoneUnuseAlert()
        }.disposed(by: disposeBag)
        
        //被冻结的 响应
        self.viewModel.freezeSubject.subscribe(onNext: { [weak self] msg in
            self?.showFreezeAlertWithMsg(msg: msg)
        }).disposed(by: disposeBag)
        //時間超時 响应
        self.viewModel.timeoutSubject.subscribe(onNext: { [weak self] msg in
            self?.timeoutAlert()
        }).disposed(by: disposeBag)
        //验证码发送成功 的响应
        self.viewModel.codeSubject.subscribe(onNext: { [weak self] (captcha) in
            guard let `self` = self else { return }
            
            if YXConstant.isAutoFillCaptcha() && !captcha.isEmpty {
                self.viewModel.hudSubject.onNext(.message("\(captcha)", false))
            }
            self.startTimer()
        }).disposed(by: disposeBag)
        //登录成功 的响应
        self.viewModel.loginSuccessSubject.subscribe(onNext: { [weak self] success in
            self?.view.endEditing(true)
            YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "login_loginSuccess"))
            for vc in self?.navigationController?.viewControllers ?? [] {
                if vc.isKind(of: YXUserCenterViewController.self) {
                    self?.navigationController?.popToViewController(vc, animated: false)
                    return
                }
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: ["index" : YXTabIndex.market])
        }).disposed(by: disposeBag)
        
    }
    
    func initUI() {
        
        self.gridInputView.textField.becomeFirstResponder()
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(gridInputView)
        scrollView.addSubview(phoneLab)
        scrollView.addSubview(codeBtn)
        scrollView.addSubview(phoneUnuseBtn)
        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeArea.top)
            make.left.right.bottom.equalTo(self.view)
        }
        //頂部文字提示
        let tipLab = UILabel()
        if self.viewModel.email.count > 0 {
            tipLab.text = YXLanguageUtility.kLang(key: "device_email_verify")
        } else {
            tipLab.text = YXLanguageUtility.kLang(key: "login_codeLoginTip")
        }
        tipLab.font = UIFont.systemFont(ofSize: uniSize(30))
        tipLab.numberOfLines = 0
        tipLab.textColor = QMUITheme().textColorLevel1()
        scrollView.addSubview(tipLab)
        tipLab.snp.makeConstraints { [weak self](make) in
            guard let strongSelf = self else {return}
            make.top.equalToSuperview().offset(80)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(strongSelf.view).offset(-20)
            //make.height.equalTo(50)
        }
        //驗證碼已發送至
//        let tipLab2 = UILabel()
//        tipLab2.text = YXLanguageUtility.kLang(key: "email_code_send")
//        tipLab2.font = UIFont.systemFont(ofSize: uniSize(20))
//        tipLab2.textColor = QMUITheme().textColorLevel1()
//        scrollView.addSubview(tipLab2)
//        tipLab2.snp.makeConstraints { (make) in
//            make.top.equalTo(tipLab.snp.bottom).offset(4)
//            make.left.equalTo(scrollView).offset(20)
//            make.height.equalTo(28)
//        }
        //【驗證碼已發送至】右侧的手机号码
        phoneLab.snp.makeConstraints { (make) in
            make.top.equalTo(tipLab.snp.bottom).offset(4)
            make.left.equalTo(scrollView).offset(20)
            make.width.equalTo(YXConstant.screenWidth - 40)
        }
        //输入视图
        gridInputView.snp.makeConstraints { (make) in
            make.top.equalTo(phoneLab.snp.bottom).offset(42)
            make.left.equalTo(scrollView).offset(20)
            make.height.equalTo(50)
            make.right.equalTo(self.view).offset(-20)
        }
        //重新发送
        codeBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self.view).offset(-20)
            make.height.equalTo(20)
            make.top.equalTo(gridInputView.snp.bottom).offset(12)
        }
        //手机号码无法使用？
        phoneUnuseBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.top.equalTo(codeBtn.snp.bottom).offset(80)
        }
                        
        if self.viewModel.email.count > 0 {
            phoneUnuseBtn.isHidden = true
            phoneLab.text = String(format: "%@   %@", YXLanguageUtility.kLang(key: "email_code_send"), self.viewModel.email)
        } else {
            phoneUnuseBtn.isHidden = false
            phoneLab.text = String(format: "%@   +%@ %@",YXLanguageUtility.kLang(key: "email_code_send"), self.viewModel.code, self.viewModel.phone)
        }
        
    }
    //发送验证码
    func sendCaptcha() {
        self.viewModel.hudSubject?.onNext(.loading(nil, false))
        
        if self.viewModel.email.count > 0 {
            let email = self.viewModel.email.removePreAfterSpace()
            self.viewModel.services.loginService.request(.sendEmailInputCaptcha(email, .type105), response: self.viewModel.sendUserInputCaptchaResponse).disposed(by: disposeBag)
        } else {
            let areaCode = self.viewModel.code
            let phoneNumber = YXUserManager.safeDecrypt(string: self.viewModel.phone.removePreAfterSpace())
            self.viewModel.services.loginService.request(.sendUserInputCaptcha(areaCode, phoneNumber, .type105), response: self.viewModel.sendUserInputCaptchaResponse).disposed(by: disposeBag)
        }

    }
    //如果手机号码无法使用，请联系客服验证
    func showPhoneUnuseAlert() {
        self.view.endEditing(true)
        
        let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "login_phoneUnuseAlertMsg"))
        alertView.clickedAutoHide = false
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: {[weak alertView] action in
            alertView?.hide()
        }))
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "mine_contact_service"), style: .default, handler: {[weak alertView,weak self] action in
            alertView?.hide()
            //联系客服  的响应
            self?.serviceAction()
        }))
        alertView.showInWindow()
    }
    //开始计时
    func startTimer() {
        
        YXTimer.shared.cancleTimer(WithTimerName: self.timerMark)
        YXTimer.shared.scheduledDispatchTimer(WithTimerName: self.timerMark, timeInterval: 1, queue: .main, repeats: true) { [weak self] in
            self?.timerAction()
        }
    }
    
    @objc func timerAction() {
        
        if timeCount >= 0 {
            codeBtn.isEnabled = false
            codeBtn .setTitle( String(format: "%lds%@", timeCount, YXLanguageUtility.kLang(key: "login_afterSend")), for: .disabled)
            timeCount -= 1
        }else {
            timeCount = 60
            codeBtn.isEnabled = true
            codeBtn.isEnabled = true
            YXTimer.shared.cancleTimer(WithTimerName: timerMark)
        }
    }
    //展示 冻结 弹框
    func showFreezeAlertWithMsg(msg: String) {
        self.view.endEditing(true)
        
        let alertView = YXAlertView(message: msg)
        alertView.clickedAutoHide = false
        
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_iknow"), style: .default, handler: {[weak alertView] action in
            
            alertView?.hide()
        }))
        alertView.showInWindow()
    }
    //時間超時
    func timeoutAlert() {
        
        self.view.endEditing(true)
        let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "login_timeout"))
        alertView.clickedAutoHide = false
        
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "login_revalidation"), style: .default, handler: {[weak alertView] action in
            alertView?.hide()
            self.navigationController?.popViewController(animated: true)
        }))
        alertView.showInWindow()
    }
    
    
    deinit {
        YXTimer.shared.cancleTimer(WithTimerName: timerMark)
    }
    
}
