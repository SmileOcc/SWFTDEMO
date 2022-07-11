//
//  YXOrgForgetPwdEmailView.swift
//  uSmartOversea
//
//  Created by 欧冬冬 on 2022/4/18.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class YXOrgForgetPwdEmailView: UIView {

    let disposeBag = DisposeBag()
    
    var acountField:YXTipsTextField = YXTipsTextField()
    
    
    var signInBtn : QMUIButton = {
        let btn = QMUIButton()
        btn.layer.cornerRadius = 4
        btn.clipsToBounds = true
        btn.backgroundColor = QMUITheme().mainThemeColor()
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .disabled)
        btn.setTitle(YXLanguageUtility.kLang(key: "next_step"), for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "next_step"), for: .disabled)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        return btn
    }()
    
    
    var errorTipLabel : UILabel = {
        let lab = UILabel.init()
        lab.textColor = QMUITheme().errorTextColor()
        lab.font = .systemFont(ofSize: 12)
        lab.text = YXLanguageUtility.kLang(key: "email_wrong_tip")
        lab.isHidden = true
        return lab
    }()
    
    var siginIntype : YXSignInType!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(type:YXSignInType) {
        self.init(frame: .zero)
        self.siginIntype = type
        setupUI()
    }
    
    func setupUI()  {
        backgroundColor = QMUITheme().foregroundColor()
        if self.siginIntype == YXSignInType.mobile {
            acountField = YXPhoneTextField.init(defaultTip: YXLanguageUtility.kLang(key: "mobile_placeholder"), placeholder:"")
        }else {
            acountField = YXTipsTextField.init(defaultTip: YXLanguageUtility.kLang(key: "pwd_email_dolphin_placeholder"), placeholder:"")
        }
        addSubview(acountField)
        addSubview(signInBtn)
        addSubview(errorTipLabel)

        
        acountField.snp.makeConstraints { (make) in
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.height.equalTo(56)
            make.top.equalToSuperview()
        }
        
        errorTipLabel.snp.makeConstraints { (make) in
            make.left.equalTo(acountField)
            make.top.equalTo(acountField.snp.bottom).offset(2)
            make.height.equalTo(17)
        }
        
        signInBtn.snp.makeConstraints { (make) in
            make.top.equalTo(acountField.snp.bottom).offset(28)
            make.height.equalTo(48)
            make.left.right.equalTo(acountField)
        }
        
        acountField.textField.rx.controlEvent(.editingDidEnd).subscribe(onNext: { [weak self] (_) in
            if self?.siginIntype == .emailOrDolphin {
                if self?.acountField.textField.text?.isValidEmail() ?? false  || self?.acountField.textField.text?.count == 0 {

                }else{
                    self?.errorTip(hidden: false)
                }
            }else{
                
            }
        }).disposed(by: disposeBag)
        acountField.textField.rx.controlEvent(.editingDidBegin).subscribe(onNext: { [weak self] (_) in
            self?.errorTip(hidden: true)
        }).disposed(by: disposeBag)
    }
    
    fileprivate func errorTip(hidden:Bool){
        self.errorTipLabel.isHidden = hidden
        self.errorTipLabel.snp.updateConstraints { (make) in
            make.height.equalTo(hidden ? 0 : 17)
        }
    }

}
