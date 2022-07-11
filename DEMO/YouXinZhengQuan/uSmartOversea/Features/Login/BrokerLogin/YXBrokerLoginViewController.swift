//
//  YXBrokerLoginViewController.swift
//  uSmartOversea
//
//  Created by ysx on 2021/11/9.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit


class YXBrokerLoginViewController: YXHKViewController, HUDViewModelBased {

    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXBrokerLoginViewModel!
    
    var passWordTextField : YXSecureTextField = {
        let field = YXSecureTextField(defaultTip: "", placeholder: "Transaction password")
        field.selectStyle = .none
        field.textField.keyboardType = .numberPad
        return field
    }()
    var accountTextField : YXTipsTextField = {
        let field = YXTipsTextField(defaultTip: "", placeholder:"Trading account number")
        field.selectStyle = .none
        field.textField.keyboardType = .numberPad
        return field
    }()
    
    var confirmBtn:QMUIButton = {
        let btn = QMUIButton()
         btn.setTitle(YXLanguageUtility.kLang(key: "login_loginBtnName"), for: .normal)
         btn.setSubmmitTheme()
         return btn
    }()
    
    var forgotBtn:QMUIButton = {
        let btn = QMUIButton(type: .custom)
        btn.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        btn.setTitle("Foget account number?", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return btn
    }()
    
    var forgoPwdtBtn:QMUIButton = {
        let btn = QMUIButton(type: .custom)
        btn.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        btn.setTitle("Foget password？", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return btn
    }()
    
    var scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    var brokerLogoImageView:UIImageView = {
        let imageView = UIImageView.init()
        return imageView
    }()
    
    var brokerNameLabel : UILabel = {
        let lab = UILabel()
        lab.textAlignment = .left
        lab.textColor = QMUITheme().textColorLevel3()
        lab.font = .systemFont(ofSize: 16)
        return lab
    }()
    
    var titlelabel : UILabel = {
       let lab = UILabel()
        lab.textColor = QMUITheme().textColorLevel1()
        lab.textAlignment = .left
        lab.font = .systemFont(ofSize: 24)
        lab.text = "Login Brokerage"
        return lab
    }()
    
    var bottomLabel : UILabel = {
        let lab = UILabel()
         lab.textColor = UIColor.qmui_color(withHexString: "#C4C5CE")
         lab.textAlignment = .left
         lab.font = .systemFont(ofSize: 12)
         return lab
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        bindViewModel()
        bindHUD()
        // Do any additional setup after loading the view.
    }
    

    func initUI()  {
        self.view.addSubview(scrollView)
        
        
        scrollView.addSubview(brokerLogoImageView)
        scrollView.addSubview(brokerNameLabel)
        scrollView.addSubview(titlelabel)
        scrollView.addSubview(accountTextField)
        scrollView.addSubview(passWordTextField)
        scrollView.addSubview(confirmBtn)
        scrollView.addSubview(forgotBtn)
        scrollView.addSubview(forgoPwdtBtn)
        
        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeArea.top)
            make.left.right.bottom.equalTo(self.view)
        }
        
      
        brokerLogoImageView.snp.makeConstraints { make in
            make.left.equalTo(30)
            make.top.equalTo(30)
            make.size.equalTo(CGSize.init(width: 72, height: 72))
        }
        
        titlelabel.snp.makeConstraints { make in
            make.left.equalTo(brokerLogoImageView.snp.right).offset(8)
            make.height.equalTo(29)
            make.bottom.equalTo(brokerLogoImageView.snp.centerY)
        }
        
        brokerNameLabel.snp.makeConstraints { make in
            make.left.equalTo(titlelabel)
            make.top.equalTo(titlelabel.snp.bottom).offset(8)
            make.height.equalTo(20)
        }
        
        
        accountTextField.snp.makeConstraints { make in
            make.left.equalTo(30)
            make.right.equalTo(self.view).offset(-30)
            make.height.equalTo(48)
            make.top.equalTo(brokerNameLabel.snp.bottom).offset(69)
        }
        
        passWordTextField.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(accountTextField)
            make.top.equalTo(accountTextField.snp.bottom).offset(24)
        }
        
        forgotBtn.snp.makeConstraints { (make) in
            make.left.equalTo(passWordTextField)
            make.top.equalTo(passWordTextField.snp.bottom).offset(12)
            make.height.equalTo(20)
        }
        
        forgoPwdtBtn.snp.makeConstraints { (make) in
            make.right.equalTo(passWordTextField)
            make.top.equalTo(passWordTextField.snp.bottom).offset(12)
            make.height.equalTo(20)
        }
        
        
        confirmBtn.snp.makeConstraints { (make) in
            make.top.equalTo(forgotBtn.snp.bottom).offset(40)
            make.width.left.equalTo(passWordTextField)
            make.height.equalTo(48)
        }
        
        
        let imageView = UIImageView.init(image: UIImage.init(named: "icon_auth_broker"))
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-30)
            make.left.equalTo(16)
        }
        
        view.addSubview(bottomLabel)
        bottomLabel.snp.makeConstraints { make in
            make.centerY.equalTo(imageView)
            make.left.equalTo(imageView.snp.right).offset(4)
            make.right.equalToSuperview().offset(-16)
        }
    }
    
    func bindViewModel()  {
        self.bottomLabel.text = "Securities trading services are provided by " + self.viewModel.broker.text
        self.brokerNameLabel.text =  self.viewModel.broker.text + " Broker"
        self.brokerLogoImageView.image = UIImage.init(named: "broker_login_" + self.viewModel.broker.brokerNo())
        YXUserManager.shared().curBroker = self.viewModel.broker
        
        forgotBtn.rx.tap.subscribe {[weak self] (_) in
            self?.alertForgetPwd()
        }.disposed(by: disposeBag)
        
        forgoPwdtBtn.rx.tap.subscribe{[weak self] (_) in
            guard let `self` = self else { return }
            
            if YXUserManager.shared().curLoginUser?.orgEmailLoginFlag ?? false {
                let context = YXNavigatable(viewModel: YXOrgRegisterNumberVertifyViewModel(vc: self.viewModel.vc))
                self.viewModel.navigator.push(YXModulePaths.orgCheckRegisterNumber.url, context: context)

            } else {
                let context = YXNavigatable(viewModel: YXAuthenticateViewModel(type: 1, vc: self.viewModel.vc))
                self.viewModel.navigator.push(YXModulePaths.authenticate.url, context: context)
            }

        }.disposed(by: disposeBag)

        confirmBtn.rx.tap.subscribe {[weak self] (_) in
            guard let `self` = self else { return }
            
            if !self.viewModel.clientIdRelay.value.isAllNumber() || self.viewModel.clientIdRelay.value.count != 8 {
                YXProgressHUD.showSuccess("Please enter your 8-digit trading account number")
                return
            }
            
            
            if !self.viewModel.pwdRelay.value.isAllNumber() || self.viewModel.pwdRelay.value.count != 6 {
                YXProgressHUD.showSuccess("Please enter a 6-digit transaction password")
                return
            }
            
            self.viewModel.hudSubject.onNext(.loading("", false))
            
            self.viewModel.loginSubject.subscribe {[weak self] _ in
                self?.viewModel.hudSubject.onNext(.hide)
            } onError: { [weak self] error in
                self?.viewModel.hudSubject.onNext(.hide)
            }.disposed(by: self.disposeBag)

          
        }.disposed(by: disposeBag)
        
        passWordTextField.textField.rx.text.orEmpty
            .asObservable()
            .bind(to: self.viewModel.pwdRelay)
            .disposed(by: disposeBag)

        accountTextField.textField.rx.text.orEmpty
            .asObservable()
            .bind(to: self.viewModel.clientIdRelay)
            .disposed(by: disposeBag)

        self.viewModel.pwdRelay
            .bind(to: passWordTextField.textField.rx.text.orEmpty)
            .disposed(by: disposeBag)
        
        self.viewModel.clientIdRelay
            .bind(to: accountTextField.textField.rx.text.orEmpty)
            .disposed(by: disposeBag)
        
        self.viewModel.inputValid?
            .bind(to: self.confirmBtn.rx.isEnabled)
            .disposed(by: disposeBag)
        
        self.viewModel.loginSucesSubject.subscribe{[weak self] res in
            guard let `self` = self else { return }
            self.viewModel.isLoginSuccess = true
            YXUserManager.shared().curBrokerToken = res.element?.token ?? ""
            YXMarginManager.shared.requestUserAccType(boker: self.viewModel.broker.brokerNo()) { _ in }
            
            if YXUserManager.isShowLoginRegister() {
                YXUserManager.registerLoginInitRootViewControler()
                return
            }
            
            self.navigationController?.popViewController(animated: true)
            NotificationCenter.default.post(name: Notification.Name.init(YXUserManager.notiLoginbroker), object: nil)
        }.disposed(by: self.disposeBag)

    }
    
    fileprivate func alertForgetPwd(){
        
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 285, height: 220))
        view.backgroundColor = QMUITheme().foregroundColor()
        view.clipsToBounds = true
        view.layer.cornerRadius = 7
        let topLabel = UILabel.init(frame: .zero)
        topLabel.textAlignment = .center
        topLabel.textColor = QMUITheme().textColorLevel1()
        topLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        topLabel.text = "Reminder"
        view.addSubview(topLabel)
        
        let descLabel = UILabel()
        descLabel.textAlignment = .center
        descLabel.font = .systemFont(ofSize: 14)
        descLabel.numberOfLines = 0
        descLabel.textColor = QMUITheme().textColorLevel1()
        descLabel.text = "If you forget your account number, you can check it in the email with the successful account opening."
        view.addSubview(descLabel)
        
        let abottmomLabel = UILabel()
        view.addSubview(abottmomLabel)
        abottmomLabel.font = .systemFont(ofSize: 12)
        abottmomLabel.textAlignment = .center
        abottmomLabel.numberOfLines = 0
        abottmomLabel.textColor = QMUITheme().textColorLevel4()
        abottmomLabel.text = "If you can't find it, please contact customer service, XXX"
        
        let lineView = UIView.line()
        view.addSubview(lineView)
        
        let okBtn = UIButton(type: .custom)
        okBtn.setTitle("OK", for: .normal)
        view.addSubview(okBtn)
        okBtn.setTitleColor(QMUITheme().mainThemeColor(), for: .normal)
        okBtn.titleLabel?.font = .systemFont(ofSize: 16)
        
        topLabel.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(22)
        }
        
        descLabel.snp.makeConstraints { make in
            make.left.right.equalTo(topLabel)
            make.top.equalTo(topLabel.snp.bottom).offset(12)
        }
        
        abottmomLabel.snp.makeConstraints { make in
            make.left.right.equalTo(descLabel)
            make.top.equalTo(descLabel.snp.bottom).offset(12)
        }
        
        lineView.snp.makeConstraints { make in
            make.top.equalTo(abottmomLabel.snp.bottom).offset(16)
            make.width.left.equalTo(abottmomLabel)
            make.height.equalTo(1)
        }
        
        okBtn.snp.makeConstraints { make in
            make.left.right.equalTo(lineView)
            make.top.equalTo(lineView.snp.bottom)
            make.height.equalTo(36)
        }
        
     
        let alert =  TYAlertController(alert: view, preferredStyle: .alert, transitionAnimation: .scaleFade)
        okBtn.addBlock(for: .touchUpInside) { [weak alert] _ in
            alert?.dismiss(animated: false, completion: nil)
        }
        
     
    
        self.present(alert!, animated: true, completion: nil)
    }
    
    override func shouldPopViewController(byBackButtonOrPopGesture byPopGesture: Bool) -> Bool {
      
        return true
    }
    
    deinit {
        if  self.viewModel.isLoginSuccess == false{
            YXUserManager.loginOutBroker(request: true)
        }
    }
    
   
}

//extension YXBrokerLoginViewController:UITextFieldDelegate{
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        let str = textField.text as NSString?
//        let str2 = str?.replacingCharacters(in: range, with: string)
//
//            if str2?.count ?? 0 > 6{
//                return false
//            }
//            if string.count > 0 && !(str2?.isAllNumber() ?? false) {
//                return false
//            }
//        return true
//    }
//}
