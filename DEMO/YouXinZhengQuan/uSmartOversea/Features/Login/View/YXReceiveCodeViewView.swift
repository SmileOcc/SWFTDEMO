//
//  YXSignUpViewController.swift
//  uSmartOversea
//
//  Created by usmart on 2021/4/1.
//  Copyright © 2021 RenRenDai. All rights reserved.
//


import UIKit
import RxSwift
import RxCocoa

enum YXAcountBindType {
    case mobile
    case email
}
class YXReceiveCodeView: UIView {

    let disposeBag:DisposeBag = DisposeBag()
    
    lazy var verifictionCodeField : YXTimeTextField = {
        let field = YXTimeTextField.init(defaultTip: YXLanguageUtility.kLang(key: "verCode_placeholder"), placeholder: YXLanguageUtility.kLang(key: "verCode_placeholder"))
        return field
    }()
    
    lazy var pwdTextFeild : YXSecureTextField = {
        let field = YXSecureTextField.init(defaultTip: YXLanguageUtility.kLang(key: "input_password"), placeholder: YXLanguageUtility.kLang(key: "set_pwd_placeholder"))
        field.needAnmitionSelect = false
        field.tipsLable.isHidden = true
        return field
    }()
    
    lazy var acountField:YXTipsTextField = YXTipsTextField()
    
    var bindBtn : QMUIButton = {
        let btn = QMUIButton()
        btn.layer.cornerRadius = 4
        btn.clipsToBounds = true
        btn.backgroundColor = QMUITheme().mainThemeColor()
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .disabled)
        btn.setTitle(YXLanguageUtility.kLang(key: "verify_btn"), for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "verify_btn"), for: .disabled)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        
        return btn
    }()
    
    lazy var helpBtn : QMUIButton = {
       let btn = QMUIButton()
        btn.setTitle(YXLanguageUtility.kLang(key: "hlep_receive"), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        btn.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        btn.sizeToFit()
        return btn
    }()
    
    lazy var errorTipLabel : UILabel = {
        let lab = UILabel.init()
        lab.textColor = QMUITheme().errorTextColor()
        lab.font = .systemFont(ofSize: 12)
        lab.text = YXLanguageUtility.kLang(key: "password_tip")
        lab.isHidden = true
        return lab
    }()
    
    lazy var accountErrorTipLable:UILabel = {
        let lab = UILabel.init()
        lab.textColor = QMUITheme().errorTextColor()
        lab.font = .systemFont(ofSize: 12)
        lab.text = YXLanguageUtility.kLang(key: "wrong_mail_tip")
        lab.isHidden = true
        return lab
    }()
    
    var bindType : YXAcountBindType!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(type:YXAcountBindType) {
        self.init(frame: .zero)
        self.bindType = type
        setupUI()
    }
    
    func setupUI()  {
        backgroundColor = QMUITheme().foregroundColor()
        if self.bindType == YXAcountBindType.mobile {
            acountField = YXPhoneTextField.init(defaultTip: YXLanguageUtility.kLang(key: "mobile_placeholder"), placeholder:"")
        }else {
            acountField = YXTipsTextField.init(defaultTip: YXLanguageUtility.kLang(key: "email_placeholder"), placeholder:"")
        }
        
        addSubview(acountField)
        addSubview(accountErrorTipLable)
        addSubview(verifictionCodeField)
        addSubview(pwdTextFeild)
        addSubview(bindBtn)
        addSubview(errorTipLabel)
       // addSubview(helpBtn)
        
        acountField.snp.makeConstraints { (make) in
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.height.equalTo(56)
            make.top.equalToSuperview()
        }
        
        accountErrorTipLable.snp.makeConstraints { (make) in
            make.left.equalTo(acountField)
            make.top.equalTo(acountField.snp.bottom).offset(2)
            make.height.equalTo(14)
        }
        
        verifictionCodeField.snp.makeConstraints { (make) in
            make.size.left.equalTo(acountField)
            make.top.equalTo(acountField.snp.bottom).offset(24)
        }
        
        
        pwdTextFeild.snp.makeConstraints { (make) in
            make.size.left.equalTo(verifictionCodeField)
            make.top.equalTo(verifictionCodeField.snp.bottom).offset(24)
        }
        
        errorTipLabel.snp.makeConstraints { (make) in
            make.left.equalTo(acountField)
            make.top.equalTo(pwdTextFeild.snp.bottom).offset(2)
            make.height.equalTo(14)
        }
        
        
        bindBtn.snp.makeConstraints { (make) in
            make.left.equalTo(pwdTextFeild)
            make.top.equalTo(pwdTextFeild.snp.bottom).offset(40)
            make.height.equalTo(48)
            make.right.equalTo(pwdTextFeild)
        }
        
//        helpBtn.snp.makeConstraints { (make) in
//            make.top.equalTo(bindBtn.snp.bottom).offset(16)
//            make.height.equalTo(20)
//            make.right.right.equalTo(bindBtn)
//        }
        
        acountField.textField.rx.controlEvent(.editingDidEnd).subscribe(onNext: { [weak self] (_) in
            if self?.bindType == .email {
                if self?.acountField.textField.text?.isValidEmail() ?? false  ||
                    self?.acountField.textField.text?.count == 0 {

                }else{
                    //self?.acountField.showErrorTip(YXLanguageUtility.kLang(key: "email_wrong_tip"))
                    self?.accountErrorTip(hidden: false)
                }
            }else{
                
            }
        }).disposed(by: disposeBag)
        acountField.textField.rx.controlEvent(.editingDidBegin).subscribe(onNext: { [weak self] (_) in
            self?.accountErrorTip(hidden: true)
        }).disposed(by: disposeBag)
    }
    
     func accountErrorTip(hidden:Bool){
        self.accountErrorTipLable.isHidden = hidden
        self.accountErrorTipLable.snp.updateConstraints { (make) in
            make.height.equalTo(hidden ? 0 : 17)
        }
        self.verifictionCodeField.snp.updateConstraints { (make) in
            make.top.equalTo(acountField.snp.bottom).offset(hidden ? 24 : 40)
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

class YXBindAccountView: YXReceiveCodeView {
    
}

