//
//  YXSignUpRegisterCodeViewController.swift
//  uSmartOversea
//
//  Created by 欧冬冬 on 2022/6/2.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXSignUpRegisterCodeViewController: YXHKViewController, HUDViewModelBased {

    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    
    var viewModel: YXSignUpRegisterCodeViewModel!
    
    var timeCount = 60
    let timerMark = "activateCode"
    
    var tempCaptcha: String = ""
    var recommendCode: String = ""//推荐码
    
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
    
    let gridInputView: YXGridInputView = {
        let gridWidth:CGFloat
        let gridHeight:CGFloat
        switch YXConstant.screenSize {
        case .size3_5,.size4:
            gridWidth = 34
            gridHeight = 46
        default:
            gridWidth = 44
            gridHeight = 56

        }
        let view = YXGridInputView(gridWidth: gridWidth, gridHeight: gridHeight, viewWidth: UIScreen.main.bounds.width-60, isSecure: false, isShowBorder: true)
        view.seletedColor = QMUITheme().textColorLevel1()
        
        if #available(iOS 12.0, *) {
            view.textField.textContentType = .oneTimeCode
        }
        return view
    }()
    
    var errorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.normalFont12()
        label.textColor = QMUITheme().errorTextColor()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.isHidden = true
        return label
    }()
    
    var codeBtn: UIButton = {
        let btn = UIButton()

        btn.setTitle(YXLanguageUtility.kLang(key: "login_resend"), for: .normal)
        btn.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        btn.setTitleColor(QMUITheme().textColorLevel3(), for: .disabled)
        btn.titleLabel?.font = .mediumFont16()
        //btn.layer.borderColor = QMUITheme().separatorLineColor().cgColor
        btn.layer.borderColor = UIColor.themeColor(withNormalHex: "#F3F3F3", andDarkColor: "#292933").cgColor
        btn.layer.borderWidth = 1.0
        btn.layer.cornerRadius = 4.0
        btn.layer.masksToBounds = true

        btn.setBackgroundImage(UIImage.init(color: UIColor.themeColor(withNormalHex: "#FFFFFF", andDarkColor: "#101014")), for: .normal)
        btn.setBackgroundImage(UIImage.init(color: UIColor.themeColor(withNormalHex: "#F3F3F3", andDarkColor: "#292933")), for: .disabled)

        return btn
    }()
    
    var helpBtn : QMUIButton = {
       let btn = QMUIButton()
        btn.setTitle(YXLanguageUtility.kLang(key: "hlep_receive"), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        btn.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        btn.sizeToFit()
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bindHUD()
        initUI()
        bindViewModel()
        viewModelResponse()
        
        if !self.viewModel.email.value.isEmpty {
            self.titleLabel.text = YXLanguageUtility.kLang(key: "verify_mailbox_code_title")
            let headerContnet = YXLanguageUtility.kLang(key: "mailbox_verification_code_sent_to")
            self.sendTipLabel.text = headerContnet + " " + self.viewModel.email.value
            
        } else {
            self.titleLabel.text = YXLanguageUtility.kLang(key: "verify_phone_code_title")
            let headerContnet = YXLanguageUtility.kLang(key: "phone_verification_code_sent_to")
            self.sendTipLabel.text = headerContnet + " +" + self.viewModel.areaCode.value + " " + self.viewModel.mobile.value
        }
        
        self.startTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.gridInputView.textField.becomeFirstResponder()
        if YXConstant.isAutoFillCaptcha(), self.tempCaptcha.count > 0 {
            autoFillVerifyCode()
        } else {
            self.gridInputView.textField.becomeFirstResponder()
        }
        
    }

    func autoFillVerifyCode() {
        self.gridInputView.textField.insertText(self.tempCaptcha)
        self.gridInputView.textFieldDidChange(textField: self.gridInputView.textField)
    }
    
    func bindViewModel() {
          
        self.helpBtn.rx.tap.subscribe(onNext:{[weak self] in
            guard let `self` = self else {return}
            self.alertReceiveCodeHelp()
        }).disposed(by: disposeBag)
        
        //发送验证码
        codeBtn.rx.tap.bind { [weak self] in
            self?.sendCaptcha()
        }.disposed(by: disposeBag)
        
        //驗證碼發送成功，
        viewModel.codeSubject.subscribe(onNext: { [weak self] (argument) in
            let (_, captcha) = argument
            guard let `self` = self else { return }
            if YXConstant.isAutoFillCaptcha() && !captcha.isEmpty {
                self.tempCaptcha = captcha
                self.viewModel.captcha.accept("")
                self.autoFillVerifyCode()
            }
            self.startTimer()
        }).disposed(by: disposeBag)
        
        
        //MARK: 验证
        gridInputView.textField.rx.text.orEmpty.distinctUntilChanged().asObservable()
            .subscribe(onNext: { [weak self] codeString in
                guard let `self` = self else { return }
                if self.viewModel.captcha.value.count < 6 && codeString.count == 6 {
                    self.errorLabel.isHidden = true
                    self.viewModel.captcha.accept(codeString)
                    self.viewModel.signUpRequest()
                    self.view.endEditing(true)
                } else {
                    self.viewModel.captcha.accept(codeString)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.registerSMSErrorSubject.subscribe(onNext: { [weak self] (msg) in
            guard let `self` = self else { return }
            self.errorLabel.text = msg
            self.errorLabel.isHidden = false
        }).disposed(by: disposeBag)
        
        //已注册
        viewModel.hasRegisterSubject.subscribe(onNext: { [weak self] (msg) in
            guard let `self` = self else {return}
            self.goLoginAlert(withMsg: msg)
        }).disposed(by: disposeBag)
        
    }
    
    func initUI() {
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(sendTipLabel)
        scrollView.addSubview(gridInputView)
        scrollView.addSubview(errorLabel)
        scrollView.addSubview(codeBtn)
        scrollView.addSubview(helpBtn)
        
        scrollView.snp.makeConstraints { [weak self] (make) in
            guard let strongSelf = self else {return}
            make.top.equalTo(strongSelf.view.safeArea.top)
            make.left.right.bottom.equalTo(strongSelf.view)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(24)
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.width.equalTo(YXConstant.screenWidth - 60)
        }
        
        sendTipLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(30)
            make.width.equalTo(YXConstant.screenWidth - 60)
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
        }
        
        gridInputView.snp.makeConstraints {[weak self] (make) in
            guard let strongSelf = self else {return}
            make.top.equalTo(sendTipLabel.snp.bottom).offset(40)
            make.left.equalToSuperview().offset(30)
            make.height.equalTo(50)
            make.right.equalTo(strongSelf.view).offset(-30)
        }
        
        errorLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(gridInputView.snp.bottom).offset(10)
        }
        
        codeBtn.snp.makeConstraints {(make) in
            make.left.right.equalTo(titleLabel)
            make.height.equalTo(48)
            make.top.equalTo(gridInputView.snp.bottom).offset(64)
        }
        
        helpBtn.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(codeBtn.snp.bottom).offset(12)
        }
        
        codeBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -(codeBtn.imageView?.image?.size.width ?? 0), bottom: 0, right: (codeBtn.imageView?.image?.size.width ?? 0))
        codeBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: (codeBtn.titleLabel?.frame.size.width ?? 0)+3, bottom: 0, right: -(codeBtn.titleLabel?.frame.size.width ?? 0)-3)
        
    }
    
    //MARK: 发送验证码
    func sendCaptcha() {
        self.viewModel.hudSubject?.onNext(.loading(nil, false))
        //清空 验证码
        gridInputView.clearText()
        self.viewModel.sendCodeRequest()
    }
    
    func startTimer() {
        timeCount = 60
        YXTimer.shared.cancleTimer(WithTimerName: self.timerMark)
        YXTimer.shared.scheduledDispatchTimer(WithTimerName: self.timerMark, timeInterval: 1, queue: .main, repeats: true) { [weak self] in
            self?.timerAction()
        }
    }
    
    @objc func timerAction() {
        
        if timeCount >= 0 {
            codeBtn.isEnabled = false
            codeBtn.layer.borderColor = UIColor.themeColor(withNormalHex: "#F3F3F3", andDarkColor: "#292933").cgColor
            codeBtn.setTitle( String(format: "%lds%@", timeCount, YXLanguageUtility.kLang(key: "login_afterSend")), for: .disabled)
            timeCount -= 1
            codeBtn.titleEdgeInsets = .zero
            codeBtn.imageEdgeInsets = .zero
            

            
        }else {
            codeBtn.isEnabled = true
            codeBtn.layer.borderColor = UIColor.themeColor(withNormalHex: "#DDDDDD", andDarkColor: "#292933").cgColor

            YXTimer.shared.cancleTimer(WithTimerName: timerMark)
            codeBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -(codeBtn.imageView?.image?.size.width ?? 0), bottom: 0, right: (codeBtn.imageView?.image?.size.width ?? 0))
            codeBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: (codeBtn.titleLabel?.frame.size.width ?? 0)+3, bottom: 0, right: -(codeBtn.titleLabel?.frame.size.width ?? 0)-3)
        }
    }
    
    deinit {
        YXTimer.shared.cancleTimer(WithTimerName: timerMark)
    }

}

//MARK: 接口返回的 处理
extension YXSignUpRegisterCodeViewController {
    
    func viewModelResponse() {
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
//            }

        }).disposed(by: disposeBag)
    }

    
    func goLoginAlert(withMsg msg: String) {
        self.view.endEditing(true)
        
        let alertView = YXAlertView.alertView(title: msg, message: "")
        alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: {_ in }))
        alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "sign_in"), style: .default, handler: { [weak self, weak alertView] (action) in
            alertView?.hide()
            self?.viewModel.gotoLogin()
        }))
        
        alertView.showInWindow()
    }
    
    fileprivate func alertReceiveCodeHelp(){
        let  alertVC = YXAlertViewFactory.helpAlertView(type: self.viewModel.accoutType.value)
        alertVC.backgoundTapDismissEnable = true
        self.present(alertVC, animated: true, completion: nil)
        
    }
    
}
