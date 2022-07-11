//
//  YXSetLoginPwdViewController.swift
//  uSmartOversea
//
//  Created by rrd on 2019/5/13.
//  Copyright © 2019 RenRenDai. All rights reserved.
//
/*
 模块：设置登录密码
 请验证手机号码，设置登录密码
 参考了 YXChangePhoneOldViewController 【请验证原来的手机号】 类
 
 */
import UIKit
import RxSwift
import RxCocoa
import SnapKit


class YXSetLoginPwdViewController: YXHKViewController, HUDViewModelBased {
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    
    var viewModel: YXSetLoginPwdViewModel!
    
    var timeCount = 60
    let timerMark = "changePhoneCode"
    
    let codeRelay = BehaviorRelay<String>(value: "")
    
    var scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    //验证码 输入框
    var captchaInputView: YXInputView = {
        let inputView = YXInputView(placeHolder: YXLanguageUtility.kLang(key: "mine_captcha_placeHolder"), type: .normal)
        inputView.textField.keyboardType = UIKeyboardType.numberPad
        if #available(iOS 12.0, *) {
            inputView.textField.textContentType = .oneTimeCode
        }
        return inputView
    }()
    //密码输入框
    var pwdInputView: YXInputView = {
        let inputView = YXInputView(placeHolder: YXLanguageUtility.kLang(key: "login_pwdPlaceHolder"), type: .password)
        return inputView
    }()
    //获取验证码
    var captchaBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle(YXLanguageUtility.kLang(key: "mine_get_captcha"), for: .normal)
        btn.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        btn.setTitleColor(QMUITheme().textColorLevel3(), for: .disabled)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.contentHorizontalAlignment = .right
        return btn
    }()
    //下一步
    var completeBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle(YXLanguageUtility.kLang(key: "login_completeSet"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize:16)
        btn.setDisabledTheme()
        return btn
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        bindViewModel()
        bindHUD()
        sendCaptcha()
        // Do any additional setup after loading the view.
    }
    
    func initUI() {
        //右导航栏-消息
        self.navigationItem.rightBarButtonItems = [messageItem]
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(captchaInputView)
        scrollView.addSubview(captchaBtn)
        scrollView.addSubview(pwdInputView)
        scrollView.addSubview(completeBtn)
        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeArea.top)
            make.left.right.bottom.equalTo(self.view)
        }
        
        let tipLab = UILabel()
        tipLab.numberOfLines = 0
        tipLab.text = YXLanguageUtility.kLang(key: "login_setLoginPwdTip")
        tipLab.font = UIFont.systemFont(ofSize: 28)
        tipLab.textColor = QMUITheme().textColorLevel1()
        scrollView.addSubview(tipLab)
        tipLab.snp.makeConstraints {[weak self] (make) in
            guard let strongSelf = self else {return}
            make.top.equalTo(scrollView).offset(6)
            make.left.equalTo(scrollView).offset(20)
            make.right.equalTo(strongSelf.view).offset(-20)
            //make.height.equalTo(40)
        }
        //【短信验证码已发送至】
        let tipLab2 = UILabel()
        tipLab2.text = YXLanguageUtility.kLang(key: "mine_captcha_send")
        tipLab2.font = UIFont.systemFont(ofSize: 14)
        tipLab2.textColor = QMUITheme().textColorLevel3()
        scrollView.addSubview(tipLab2)
        tipLab2.snp.makeConstraints { (make) in
            make.top.equalTo(tipLab.snp.bottom).offset(4)
            make.left.equalTo(scrollView).offset(20)
            make.height.equalTo(20)
        }
        //手机号
        let phoneLab = UILabel()
        phoneLab.text = String(format: "+%@ %@", YXUserManager.shared().curLoginUser?.areaCode ?? "", YXUserManager.secretPhone())
        phoneLab.font = UIFont.systemFont(ofSize: 14)
        phoneLab.textColor = QMUITheme().textColorLevel1()
        scrollView.addSubview(phoneLab)
        phoneLab.snp.makeConstraints { (make) in
            make.top.equalTo(tipLab.snp.bottom).offset(4)
            make.left.equalTo(tipLab2.snp.right).offset(10)
            make.height.equalTo(20)
        }
        //【验证码】
        let captchaLab = QMUILabel()
        captchaLab.font = UIFont.systemFont(ofSize: 16)
        captchaLab.text = YXLanguageUtility.kLang(key: "mine_captcha_tip")
        scrollView.addSubview(captchaLab)
        captchaLab.snp.makeConstraints { (make) in
            make.left.equalTo(scrollView).offset(18)
            make.top.equalTo(tipLab.snp.bottom).offset(60)
            make.height.equalTo(22)
            make.width.equalTo(50)
        }
        //【获取验证码】
        let fitCaptchaSize = captchaBtn.sizeThatFits(CGSize(width: 100, height: 20))
        captchaBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self.view).offset(-18)
            make.centerY.equalTo(captchaLab)
            make.size.equalTo(fitCaptchaSize)
        }
        //验证码 输入框
        captchaInputView.snp.makeConstraints { (make) in
            make.left.equalTo(captchaLab.snp.right).offset(36)
            make.centerY.equalTo(captchaLab)
            make.right.equalTo(captchaBtn.snp.left).offset(-3)
        }
        //【登录密码】
        let pwdLab = QMUILabel()
        pwdLab.font = UIFont.systemFont(ofSize: 16)
        pwdLab.text = YXLanguageUtility.kLang(key: "login_pwdTip")
        scrollView.addSubview(pwdLab)
        pwdLab.snp.makeConstraints { (make) in
            make.left.equalTo(scrollView).offset(18)
            make.top.equalTo(captchaLab.snp.bottom).offset(40)
            make.height.equalTo(22)
        }
        //密码输入框
        pwdInputView.snp.makeConstraints { (make) in
            make.right.equalTo(self.view).offset(-18)
            make.centerY.equalTo(pwdLab)
            make.left.equalTo(captchaInputView)
        }
        //输入框下面的横线
        for i in 0...1 {
            let lineView = UIView()
            lineView.backgroundColor = QMUITheme().separatorLineColor()
            scrollView.addSubview(lineView)
            
            lineView.snp.makeConstraints { (make) in
                make.right.equalTo(self.view).offset(-18)
                make.left.equalTo(scrollView).offset(18)
                make.height.equalTo(1)
                if i == 0 {
                    make.top.equalTo(captchaLab.snp.bottom).offset(10)
                }else {
                    make.top.equalTo(pwdLab.snp.bottom).offset(10)
                }
            }
        }
        //【完成设置】
        completeBtn.snp.makeConstraints { (make) in
            make.top.equalTo(pwdLab.snp.bottom).offset(90)
            make.left.equalTo(scrollView).offset(20)
            make.right.equalTo(self.view).offset(-20)
            make.height.equalTo(44)
        }
    }
    
    func bindViewModel() {
        //【完成设置】的响应
        completeBtn.rx.tap.subscribe(onNext: {[weak self] (_) in
            
            guard let strongSelf = self else { return }
            strongSelf.viewModel.hudSubject?.onNext(.loading(nil, false))
            
            let pwd = YXUserManager.safeDecrypt(string: strongSelf.pwdInputView.textField.text ?? "")
            let captcha = (strongSelf.captchaInputView.textField.text ?? "").removePreAfterSpace()
            
            /* 设置登陆密码 post
             set-login-password/v1  */
            strongSelf.viewModel.services.userService.request(.setLoginPwd(captcha: captcha, password: pwd), response: strongSelf.viewModel.setLoginPwdResponse).disposed(by: strongSelf.disposeBag)
                        
        }).disposed(by: disposeBag)
        
        Observable.combineLatest(captchaInputView.textField.rx.text.orEmpty, pwdInputView.textField.rx.text.orEmpty)
        {
            textValue1, textValue2 -> Bool in
            (textValue1.count > 0 && textValue2.count > 0)
            }
            .bind(to: completeBtn.rx.isEnabled)
            .disposed(by: disposeBag)
        
        self.codeRelay.asObservable().bind(to: captchaInputView.textField.rx.text.orEmpty).disposed(by: self.disposeBag)
        
        captchaInputView.cleanBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.completeBtn.isEnabled = false
            self?.captchaInputView.updateTextConstraint()
        }).disposed(by: disposeBag)
        
        pwdInputView.cleanBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.completeBtn.isEnabled = false
            self?.pwdInputView.updateTextConstraint()
        }).disposed(by: disposeBag)
        
        
        captchaBtn.rx.tap.subscribe(onNext: {[weak self] (_) in
            self?.sendCaptcha()
        }).disposed(by: disposeBag)
        
        //MARK: viewModel
        //token-send-phone-captcha/v1接口的成功处理
        viewModel.codeSubject.subscribe(onNext: { [weak self] (captcha) in
            guard let `self` = self else { return }//关键字要加【``】,就可以使用self了
            
            if YXConstant.isAutoFillCaptcha() {
                self.codeRelay.accept(captcha)
            }
            //开始计时
            self.startTimer()
        }).disposed(by: disposeBag)
        
        viewModel.freezeSubject.subscribe(onNext: { [weak self] msg in
            
            self?.showFreezeAlertWithMsg(msg: msg)
        }).disposed(by: disposeBag)
        
        viewModel.lockedSubject.subscribe(onNext: { [weak self] msg in
            
            self?.showLockedAlertWithMsg(msg: msg)
        }).disposed(by: disposeBag)
        
        //成功 返回
        viewModel.setLoginPwdSuccessSubject.subscribe(onNext: { [weak self] success in
            if success {
                self?.viewModel.hudSubject.onNext(.message(YXLanguageUtility.kLang(key: "mine_set_success"), true))
                //为解决： 设置完登录密码后，返回来再点击，还是会来到【设置登录密码】页面 的问题
                //更新用户信息数据
                YXUserManager.getUserInfo(complete: nil)
                //发送通知
                NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiUpdateUserInfo), object: nil)
                //返回
                self?.navigationController?.popViewController(animated: true)
            }
        }).disposed(by: disposeBag)
        
        //s发送验证码
        viewModel.sendCaptcha = {[weak self]  in
            self?.sendCaptcha()
        }
    }

    //发送验证码
    func  sendCaptcha() {
        self.viewModel.hudSubject?.onNext(.loading(nil, false))
        /*获取手机验证码(默认用户手机号)
         type:业务类型（201 重置交易密码短信 202 更换手机号 203 设置登录密码）
         token-send-phone-captcha/v1  */
        self.viewModel.services.userService.request(.tokenSendCaptcha(203), response: self.viewModel.sendCaptchaResponse).disposed(by: disposeBag)
    }
    //开始计时
    func startTimer() {
        
        timeCount = 60
        YXTimer.shared.cancleTimer(WithTimerName: self.timerMark)
        YXTimer.shared.scheduledDispatchTimer(WithTimerName: self.timerMark, timeInterval: 1, queue: .main, repeats: true) { [weak self] in
            self?.timerAction()
        }
    }
    
    @objc func timerAction() {
        
        if timeCount >= 0 {
            captchaBtn.isEnabled = false
            captchaBtn.setTitle( String(format: "%lds%@", timeCount, YXLanguageUtility.kLang(key: "login_afterSend")), for: .disabled)
            timeCount -= 1
        }else {
            captchaBtn.isEnabled = true
            captchaBtn.setTitle(YXLanguageUtility.kLang(key: "login_captchaTimeDown"), for: .normal)
            YXTimer.shared.cancleTimer(WithTimerName: timerMark)
        }
        let fitCaptchaSize = captchaBtn.sizeThatFits(CGSize(width: 100, height: 20))
        captchaBtn.snp.updateConstraints { (make) in
            make.size.equalTo(fitCaptchaSize)
        }
    }
    //
    func showLockedAlertWithMsg(msg: String) {
        
        self.view.endEditing(true)
        
        let alertView = YXAlertView(message: msg)
        alertView.clickedAutoHide = false
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_close"), style: .cancel, handler: {[weak alertView] action in
            alertView?.hide()
        }))
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "login_backPwd"), style: .default, handler: {[weak alertView, weak self] action in
            guard let `self` = self else { return }
            
            alertView?.hide()            
            let context = YXNavigatable(viewModel: YXForgetPwdPhoneViewModel(with: YXUserManager.shared().curLoginUser?.areaCode ?? "", phone: YXUserManager.shared().curLoginUser?.phoneNumber ?? "", isLogin: true, callBack: {_ in }, loginCallBack: nil, fromVC:self,sourceVC:self))
            self.viewModel.navigator.push(YXModulePaths.forgetPwdPhone.url, context: context)
        }))
        alertView.showInWindow()
    }
    
    func showFreezeAlertWithMsg(msg: String) {
        
        self.view.endEditing(true)
        
        let alertView = YXAlertView(message: msg)
        alertView.clickedAutoHide = false
        
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_iknow"), style: .default, handler: {[weak alertView] action in
            
            alertView?.hide()
        }))
        alertView.showInWindow()
    }

}
