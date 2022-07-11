//
//  YXSignUpViewController.swift
//  uSmartOversea
//
//  Created by usmart on 2021/4/1.
//  Copyright © 2021 RenRenDai. All rights reserved.
//


import UIKit

class YXResetPasswordView: UIView {

    lazy var orgPassWordField : YXSecureTextField = {
        let field = YXSecureTextField.init(defaultTip: "", placeholder: YXLanguageUtility.kLang(key: "set_pwd_placeholder"))
        field.textField.addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        return field
    }()
    
    lazy var subPassWordField : YXSecureTextField = {
        let field = YXSecureTextField.init(defaultTip: "", placeholder: YXLanguageUtility.kLang(key: "reset_pwd_placeholder"))
        field.textField.addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        return field
    }()
    
    lazy var resetBtn : QMUIButton = {
        let btn = QMUIButton()
        btn.layer.cornerRadius = 4
        btn.clipsToBounds = true
        btn.backgroundColor = QMUITheme().mainThemeColor()
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .disabled)
        btn.setTitle(YXLanguageUtility.kLang(key: "reset_password_btn"), for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "reset_password_btn"), for: .disabled)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        
        return btn
    }()
    
    lazy var errorTipLabel : UILabel = {
        let lab = UILabel.init()
        lab.textColor = QMUITheme().errorTextColor()
        lab.font = .systemFont(ofSize: 12)
        lab.text = YXLanguageUtility.kLang(key: "password_tip")
        return lab
    }()
    
    lazy var subErrorTipLabel : UILabel = {
        let lab = UILabel.init()
        lab.textColor = QMUITheme().errorTextColor()
        lab.font = .systemFont(ofSize: 12)
        lab.text = YXLanguageUtility.kLang(key: "not_match")
        return lab
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupUI()  {
        backgroundColor = UIColor.white
        
        addSubview(orgPassWordField)
        addSubview(subPassWordField)
        addSubview(errorTipLabel)
        addSubview(subErrorTipLabel)
        addSubview(resetBtn)
        
        orgPassWordField.snp.makeConstraints { (make) in
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.height.equalTo(56)
            make.top.equalToSuperview()
        }
        
        errorTipLabel.snp.makeConstraints { (make) in
            make.left.equalTo(orgPassWordField)
            make.top.equalTo(orgPassWordField.snp.bottom).offset(4)
            make.height.equalTo(14)
        }
        
        subPassWordField.snp.makeConstraints { (make) in
            make.size.left.equalTo(orgPassWordField)
            make.top.equalTo(orgPassWordField.snp.bottom).offset(24)
        }
        
        subErrorTipLabel.snp.makeConstraints { (make) in
            make.left.equalTo(errorTipLabel.snp.left)
            make.top.equalTo(subPassWordField.snp.bottom).offset(4)
        }
        
        resetBtn.snp.makeConstraints { (make) in
            make.top.equalTo(subPassWordField.snp.bottom).offset(48)
            make.height.equalTo(50)
            make.left.right.equalTo(orgPassWordField)
        }
    }
    

    
    @objc func  editingDidBegin(textField:UITextField){
//        self.orgPassWordField.hiddenTip()
//        self.subPassWordField.hiddenTip()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

