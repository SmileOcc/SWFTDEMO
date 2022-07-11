//
//  YXSignUpViewController.swift
//  uSmartOversea
//
//  Created by usmart on 2021/4/2.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

enum YXAlertButtonType {
    case defaultType
    case singleWhiteType
    case singleMainType
}

class YXAlertContainerView: UIView {

    typealias Click = ()->()
    
    var leftClick : Click?
    var rightClick : Click?

    var buttonType = YXAlertButtonType.defaultType
    
    
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.textAlignment = .center
        lab.textColor = QMUITheme().textColorLevel1()
        lab.font = .systemFont(ofSize: 16.sacel375Font(), weight: .semibold)
        lab.lineBreakMode = .byWordWrapping
        lab.numberOfLines = 0
        return lab
    }()
    
    lazy var describLabel : YYLabel = {
        let lab = YYLabel()
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.numberOfLines = 0
        lab.textAlignment = .center
        lab.lineBreakMode = .byWordWrapping
        return lab
    }()
    
    lazy var leftBtn : QMUIButton = {
        let btn = QMUIButton()
        btn.layer.cornerRadius = 4
        btn.clipsToBounds = true
        btn.layer.borderWidth = 1
        btn.layer.borderColor = QMUITheme().alertButtonLayerColor().cgColor
        btn.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14.sacel375f())
        btn.addTarget(self, action: #selector(leftTap), for: .touchUpInside)
        return btn
    }()
    
    lazy var rightBtn : QMUIButton = {
        let btn = QMUIButton()
        btn.layer.cornerRadius = 4
        btn.clipsToBounds = true
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14.sacel375f())
        btn.backgroundColor = QMUITheme().mainThemeColor()
        btn.addTarget(self, action: #selector(rightTap), for: .touchUpInside)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(title:String,describe:NSMutableAttributedString,leftTitle:String,rightTitle:String ,type:YXAlertButtonType = .defaultType){
        self.init()
        self.titleLabel.text = title
        self.describLabel.attributedText = describe
        self.leftBtn.setTitle(leftTitle, for: .normal)
        self.rightBtn.setTitle(rightTitle, for: .normal)
        self.buttonType = type
        setupUI()
    }
    
    func setupUI()  {
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
        self.backgroundColor = QMUITheme().popupLayerColor()
        
        addSubview(titleLabel)
        addSubview(describLabel)
        addSubview(leftBtn)
        addSubview(rightBtn)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(16.sacel375())
            make.top.equalTo(describLabel.text?.count ?? 0 > 0  ? 16.sacel375() : 24.sacel375())
            make.right.equalTo(-16.sacel375())
        }
        
        describLabel.snp.makeConstraints { (make) in
            make.right.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(12.sacel375())
        }

        layoutButtons()
    }
    
    @objc func leftTap(){
        leftClick?()
    }
    
    @objc func rightTap(){
        rightClick?()
    }
    
    private func layoutButtons(){
        
        switch self.buttonType {
        case .defaultType:
            leftBtn.snp.makeConstraints { (make) in
                make.left.equalTo(16.sacel375())
                make.top.equalTo(describLabel.snp.bottom).offset(16.sacel375())
                make.height.equalTo(36.sacel375())
                make.right.equalTo(rightBtn.snp.left).offset(-14.sacel375())
            }
            rightBtn.snp.makeConstraints { (make) in
                make.size.top.bottom.equalTo(leftBtn)
                make.right.equalTo(-16.sacel375())
            }
        case .singleWhiteType:
            leftBtn.snp.makeConstraints { (make) in
                make.left.equalTo(16.sacel375())
                make.top.equalTo(describLabel.snp.bottom).offset(16.sacel375())
                make.height.equalTo(36.sacel375())
                make.right.equalToSuperview().offset(-14.sacel375())
            }
        case .singleMainType:
            rightBtn.snp.makeConstraints { (make) in
                make.left.equalTo(16.sacel375())
                make.top.equalTo(describLabel.snp.bottom).offset(16.sacel375())
                make.height.equalTo(36.sacel375())
                make.right.equalToSuperview().offset(-14.sacel375())
            }
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

class YXAlertViewFactory {
    static func helpAlertView(type:YXMemberAccountType) -> YXAlertController{
            var text = YXLanguageUtility.kLang(key: "receive_code_tip_desc_ph")
            if type == .mobile {
                text = YXLanguageUtility.kLang(key: "receive_code_tip_desc_ph")
            }else {
                text = YXLanguageUtility.kLang(key: "receive_code_tip_desc_em")
            }
        
        let title = YXLanguageUtility.kLang(key: "receive_code_tip_title")
        
        let alertView = YXAlertView.alertView(title: title, message: text)
        let alertController = YXAlertController.init(alert: alertView)
        alertView.clickedAutoHide = false

        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "confirm_btn"), style: .default, handler: { [weak alertView] _ in
            alertView?.hide()
        }))
        
        return alertController ?? YXAlertController()
    }
    
    static func lockAccountAlertView(massage:String,gofindPwd:@escaping ()->())->YXAlertController{
        let text = YXLanguageUtility.kLang(key: "lock_account_title")
        let alertVc = YXAlertViewFactory.alterView(title: text, describe: massage, leftTitle:YXLanguageUtility.kLang(key: "cancel_btn"), rightTitle: YXLanguageUtility.kLang(key: "find_back"),rightTap: gofindPwd,leftTap: nil)
        return alertVc
    }
    
    static func hasSignUPAlertView(massage:String,goLoginTap:@escaping ()->())->YXAlertController{
        let text = massage
        let alertVc = YXAlertViewFactory.alterView(title: text, describe: "", leftTitle:YXLanguageUtility.kLang(key: "cancel_btn"), rightTitle: YXLanguageUtility.kLang(key: "sign_in"),rightTap: goLoginTap,leftTap: nil)
        return alertVc
    }
    
    static func notSignUPAlertView(massage:String,goSinupTap:@escaping ()->())->YXAlertController{
        
        let text = massage
        let alertVc = YXAlertViewFactory.alterView(title: text, describe: "", leftTitle:YXLanguageUtility.kLang(key: "cancel_btn"), rightTitle: YXLanguageUtility.kLang(key: "sign_up"),rightTap: goSinupTap,leftTap: nil)
        return alertVc
    }
    
    static func errorPwdAlerView(massage:String,gofindPwd:@escaping ()->())->YXAlertController{
        let text = YXLanguageUtility.kLang(key: "error_pwd_title")
        let alertVc = YXAlertViewFactory.alterView(title: text, describe: massage, leftTitle:YXLanguageUtility.kLang(key: "cancel_btn"), rightTitle: YXLanguageUtility.kLang(key: "find_back"),rightTap: gofindPwd,leftTap: nil)
        return alertVc
    }
    
   
    
    static func resetPwdSuccessAlert(cancel:@escaping ()->(),relogin:@escaping ()->())->YXAlertController{
        let text = YXLanguageUtility.kLang(key: "login_resetPwdSuccess")
        let alertVc = YXAlertViewFactory.alterView(title: text, describe: "", leftTitle:YXLanguageUtility.kLang(key: "cancel_btn"), rightTitle: YXLanguageUtility.kLang(key: "login_reloginTip"),rightTap: relogin,leftTap: cancel)
        return alertVc
    }
    
    static func changePwdSuccessAlert(cancel:@escaping ()->(),relogin:@escaping ()->())->YXAlertController{
        let text = YXLanguageUtility.kLang(key: "mine_pwd_change_success")
        let alertVc = YXAlertViewFactory.alterView(title: text, describe: "", leftTitle:YXLanguageUtility.kLang(key: "cancel_btn"), rightTitle: YXLanguageUtility.kLang(key: "login_reloginTip"),rightTap: relogin,leftTap: cancel)
        return alertVc
    }
    
    static func noTradePwdAlert(title:String,message:String, cancel:@escaping ()->(),relogin:@escaping ()->())->YXAlertController{
        let text = title
        let alertVc = YXAlertViewFactory.alterView(title: text, describe:message, leftTitle:YXLanguageUtility.kLang(key: "common_cancel"), rightTitle: YXLanguageUtility.kLang(key: "tpwd_setPwdTip"),rightTap: relogin,leftTap: cancel)
        return alertVc
    }
    
    static func noReceivCaptchaAlertView() -> YXAlertController {
        
        let title = YXLanguageUtility.kLang(key: "receive_code_tip_title")
        let msg = YXLanguageUtility.kLang(key: "no_captcha_tip")
        
        let alertView = YXAlertView.alertView(title: title, message: msg)
        let alertController = YXAlertController.init(alert: alertView)
        alertView.clickedAutoHide = false

        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "confirm_btn"), style: .cancel, handler: { [weak alertView] _ in
            alertView?.hide()
        }))
        
        return alertController ?? YXAlertController()
    }
    
    
    static func alterView(title:String,describe:String,leftTitle:String,rightTitle:String,type:YXAlertButtonType = .defaultType,rightTap: (()->())?,leftTap: (()->())?) -> YXAlertController {
        
        let alertView = YXAlertView.alertView(title: title, message: describe)
        let alertController = YXAlertController.init(alert: alertView)
        alertView.clickedAutoHide = false

        alertView.addAction(YXAlertAction(title: leftTitle, style: .cancel, handler: { [weak alertController] _ in
            
            alertController?.dismiss(animated: true, completion: {
                leftTap?()
            })
            
        }))

        alertView.addAction(YXAlertAction(title: rightTitle, style: .default, handler: { [weak alertController] _ in
            alertController?.dismiss(animated: true, completion: {
                rightTap?()
            })
        }))
        
        return alertController ?? YXAlertController()
    }
}


