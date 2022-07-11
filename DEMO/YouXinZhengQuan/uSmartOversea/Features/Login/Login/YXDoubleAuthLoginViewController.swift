//
//  YXDouleAuthLoginViewController.swift
//  uSmartOversea
//
//  Created by ysx on 2022/2/16.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class YXDoubleAuthLoginViewController: YXHKViewController,HUDViewModelBased {
    typealias ViewModelType = YXDoubleAuthLoginViewModel
    
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXDoubleAuthLoginViewModel!
    
    private var scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    lazy var acountField:YXTipsTextField = YXTipsTextField()
    
    lazy var loginBtn : QMUIButton = {
        let btn = QMUIButton()
        btn.layer.cornerRadius = 4
        btn.clipsToBounds = true
        btn.backgroundColor = QMUITheme().mainThemeColor()
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .disabled)
        btn.setTitle(YXLanguageUtility.kLang(key: "mine_2fa_login_title"), for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "mine_2fa_login_title"), for: .disabled)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        
        return btn
    }()
    
    lazy var verifictionCodeField : YXTimeTextField = {
        let field = YXTimeTextField.init(defaultTip: YXLanguageUtility.kLang(key: "verCode_placeholder"), placeholder: YXLanguageUtility.kLang(key: "verCode_placeholder"))
        return field
    }()
    
    
    lazy var helpBtn : QMUIButton = {
       let btn = QMUIButton()
        btn.setTitle(YXLanguageUtility.kLang(key: "hlep_receive"), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        btn.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        btn.sizeToFit()
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

         initUI()
         bindHUD()
         bindViewModel()
        // Do any additional setup after loading the view.
    }
    func initUI(){
        var tmpField:YXPhoneTextField
        if self.viewModel.loginType == .mobile {
            acountField = YXPhoneTextField.init(defaultTip: YXLanguageUtility.kLang(key: "mobile_acount"), placeholder:"")
            acountField.textField.text = self.viewModel.loginUser?.phoneNumber
            tmpField = acountField as! YXPhoneTextField
            tmpField.areaCodeLale.text = "+" + (self.viewModel.loginUser?.areaCode ?? "")
            tmpField.areaCodeLale.textColor = QMUITheme().textColorLevel4()
            tmpField.areaCodeBtn.isEnabled = false
            
        }else {
            let t = self.viewModel.loginUser?.thirdBindBit ?? 0
            let bindEmail = (t & YXLoginBindType.email.rawValue) == YXLoginBindType.email.rawValue
            if bindEmail{
                acountField = YXTipsTextField.init(defaultTip: YXLanguageUtility.kLang(key: "email_placeholder"), placeholder: "")
                acountField.textField.text = self.viewModel.loginUser?.email
            }else{
                acountField = YXPhoneTextField.init(defaultTip: YXLanguageUtility.kLang(key: "mobile_acount"), placeholder:"")
                acountField.textField.text = self.viewModel.loginUser?.phoneNumber
                tmpField = acountField as! YXPhoneTextField
                tmpField.areaCodeLale.text = "+" + (self.viewModel.loginUser?.areaCode ?? "")
                tmpField.areaCodeLale.textColor = QMUITheme().textColorLevel4()
                tmpField.areaCodeBtn.isEnabled = false
                self.viewModel.loginType = .mobile
            }
        }
        acountField.didBegin()
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.acountField.textField.isEnabled = false
            self.acountField.clearBtn.isHidden = true
            self.acountField.textField.textColor = QMUITheme().textColorLevel4()
           // self.view.endEditing(true)
        }

        view.addSubview(scrollView)
        scrollView.addSubview(acountField)
        scrollView.addSubview(verifictionCodeField)
        scrollView.addSubview(helpBtn)
        scrollView.addSubview(loginBtn)
        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeArea.top)
            make.left.right.bottom.equalTo(self.view)
        }
        
        let titleLab = UILabel()
        scrollView.addSubview(titleLab)
        titleLab.text = YXLanguageUtility.kLang(key: "mine_2fa_title")
        titleLab.textColor = QMUITheme().textColorLevel1()
        titleLab.font = .systemFont(ofSize: 24, weight: .medium)
        titleLab.minimumScaleFactor = 0.7
        titleLab.adjustsFontSizeToFitWidth = true
        
        titleLab.snp.makeConstraints { (make) in
            make.top.equalTo(24)
            make.left.equalTo(30)
            make.height.equalTo(24)
        }
        
        
        acountField.snp.makeConstraints { (make) in
            make.top.equalTo(titleLab.snp.bottom).offset(52)
            make.left.equalTo(30)
            make.height.equalTo(58)
            make.right.equalTo(view).offset(-30)
        }
        
        verifictionCodeField.snp.makeConstraints { (make) in
            make.top.equalTo(acountField.snp.bottom).offset(24)
            make.left.equalTo(30)
            make.height.right.height.equalTo(acountField)
        }
        
        loginBtn.snp.makeConstraints { (make) in
            make.top.equalTo(verifictionCodeField.snp.bottom).offset(40)
            make.left.right.equalTo(acountField)
            make.height.equalTo(48)
        }
        
        helpBtn.snp.makeConstraints { (make) in
            make.top.equalTo(loginBtn.snp.bottom).offset(16)
            make.height.equalTo(20)
            make.right.equalTo(loginBtn)
        }
        
    }
    func bindViewModel(){
        verifictionCodeField.sendBtn.rx.tap.subscribe(onNext:{[weak self] in
            guard let `self` = self else { return }
            self.viewModel.sendCaptcha()
        }).disposed(by: disposeBag)
        
        self.viewModel.captchaBehaviorRelay.bind(to:verifictionCodeField.textField.rx.text.orEmpty).disposed(by: disposeBag)
        verifictionCodeField.textField.rx.text.orEmpty.bind(to: self.viewModel.captchaBehaviorRelay).disposed(by: disposeBag)
        
        self.viewModel.captchaBehaviorRelay.map({ $0.count > 0 }).bind(to:self.loginBtn.rx.isEnabled).disposed(by: disposeBag)
        
        self.loginBtn.rx.tap.subscribe(onNext:{[weak self] in
            guard let `self` = self else { return }
            self.viewModel.checkCaptcha()
        }).disposed(by: disposeBag)
        
        self.viewModel.didSendSubject.subscribe(onNext:{[weak self] captcha in
            guard let `self` = self else { return }
            if YXConstant.isAutoFillCaptcha() {
                self.viewModel.captchaBehaviorRelay.accept(captcha)
                self.verifictionCodeField.didBegin()
            }
            self.verifictionCodeField.startCountDown()
        }).disposed(by: disposeBag)
        
        self.viewModel.didCheckSubject.subscribe(onNext:{[weak self] _ in
            guard let `self` = self else { return }
            self.viewModel.loginCallBack?()
        }).disposed(by: disposeBag)
        
        helpBtn.rx.tap.subscribe(onNext:{[weak self] in
            guard let `self` = self else { return }
            self.noReiverCodeAletr()
        }).disposed(by: disposeBag)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.sendCaptcha()
    }
    
    fileprivate func noReiverCodeAletr(){
        let alertView = YXAlertView.init(title: YXLanguageUtility.kLang(key: "receive_code_tip_title"), message: YXLanguageUtility.kLang(key: "receive_code_tip_desc_comm_email"))
        let cancelAction = YXAlertAction.init(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel) {[weak alertView] _ in
            alertView?.hideInController()
        }
        let confirmAction = YXAlertAction.init(title: YXLanguageUtility.kLang(key: "common_confirm"), style: .fullDefault) {[weak alertView] _ in
            alertView?.hideInController()
//            let str = "tel:+6563030663"
//            let application = UIApplication.shared
//            let URL = NSURL(string: str)
//            if let URL = URL {
//                application.open(URL as URL, options: [:], completionHandler: { success in
//                })
//            }
        }
        
//        alertView.addAction(cancelAction)
        alertView.addAction(confirmAction)
        alertView.show(in: self)
    }
}
