//
//  YXUserCenterHeaderView.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2021/4/14.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXUserCenterQuotationView: UIView {
    
    
    let usLabel = UILabel.init(text: "Delayed", textColor: QMUITheme().textColorLevel3(), textFont: UIFont.systemFont(ofSize: 10))!
    
    let hkLabel = UILabel.init(text: "Delayed", textColor: QMUITheme().textColorLevel3(), textFont: UIFont.systemFont(ofSize: 10))!
    
    //let cnLabel = UILabel.init(text: "Delayed", textColor: QMUITheme().textColorLevel3(), textFont: UIFont.systemFont(ofSize: 10))!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func initUI() {
        let usTitleLabel = UILabel.init(text: "US", textColor: QMUITheme().textColorLevel3(), textFont: UIFont.systemFont(ofSize: 10))!
        usTitleLabel.backgroundColor = QMUITheme().blockColor()
        
        let hkTitleLabel = UILabel.init(text: "HK", textColor: QMUITheme().textColorLevel3(), textFont: UIFont.systemFont(ofSize: 10))!
        hkTitleLabel.backgroundColor = QMUITheme().blockColor()
        
        //let cnTitleLabel = UILabel.init(text: "CN", textColor: QMUITheme().textColorLevel3(), textFont: UIFont.systemFont(ofSize: 10))!
        //cnTitleLabel.backgroundColor = QMUITheme().blockColor()
        
        usTitleLabel.textAlignment = .center
        hkTitleLabel.textAlignment = .center
        //®cnTitleLabel.textAlignment = .center
        
        addSubview(usTitleLabel)
        addSubview(usLabel)
        addSubview(hkTitleLabel)
        addSubview(hkLabel)
//        addSubview(cnTitleLabel)
//        addSubview(cnLabel)
        
        usTitleLabel.snp.makeConstraints { (make) in
            make.width.equalTo(19)
            make.height.equalTo(14)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
        }
        usLabel.snp.makeConstraints { (make) in
            make.left.equalTo(usTitleLabel.snp.right).offset(4)
            make.centerY.equalTo(usTitleLabel)
        }
        
        hkTitleLabel.snp.makeConstraints { (make) in
            make.width.equalTo(19)
            make.height.equalTo(14)
            make.centerY.equalToSuperview()
            make.left.equalTo(usLabel.snp.right).offset(14)
        }
        hkLabel.snp.makeConstraints { (make) in
            make.left.equalTo(hkTitleLabel.snp.right).offset(4)
            make.centerY.equalTo(hkTitleLabel)
        }
        
//        cnTitleLabel.snp.makeConstraints { (make) in
//            make.width.equalTo(19)
//            make.height.equalTo(14)
//            make.centerY.equalToSuperview()
//            make.left.equalTo(hkLabel.snp.right).offset(14)
//        }
//        cnLabel.snp.makeConstraints { (make) in
//            make.left.equalTo(cnTitleLabel.snp.right).offset(4)
//            make.centerY.equalTo(cnTitleLabel)
//        }
    }
}

class YXUserCenterHeaderView: UIView {

    var loginClickCallBack: (()->())?

    let nameLabel = UILabel.init(text: "--", textColor: QMUITheme().textColorLevel1(), textFont: UIFont.systemFont(ofSize: 22, weight: .medium))!

    let idTitleLabel = UILabel.init(text: "uSMART ID:", textColor: QMUITheme().textColorLevel2(), textFont: UIFont.systemFont(ofSize: 12))!

    
    let idLabel = UILabel.init(text: "--", textColor: QMUITheme().textColorLevel2(), textFont: UIFont.systemFont(ofSize: 12))!
    
    let iconView = UIImageView.init(image: UIImage(named: "user_default_photo"))
    
    let bottomLineView = UIView.line()
    
    let quotationView = YXUserCenterQuotationView.init()
    
    let loginView = UIView()
    
    let loginBtn = QMUIButton.init(type: .custom)
    
    let copyBtn = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
                
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
       
        loginBtn.setTitle(YXLanguageUtility.kLang(key: "mine_account_login_reg"), for: .normal)
        loginBtn.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        loginBtn.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        loginBtn.addTarget(self, action: #selector(self.loginBtnClick(_:)), for: .touchUpInside)
        loginBtn.setImage(UIImage(named: "mine_arrow"), for: .normal)
        loginBtn.imagePosition = .right
        loginBtn.spacingBetweenImageAndTitle = 8
        
        loginBtn.isHidden = true
        
        iconView.layer.cornerRadius = 28
        iconView.clipsToBounds = true
        
        copyBtn.setImage(UIImage.init(named: "icon_copy_mine"), for: .normal)
        
        addSubview(loginView)
        addSubview(loginBtn)
        addSubview(iconView)
        addSubview(bottomLineView)
        bottomLineView.isHidden = true
        addSubview(quotationView)
        addSubview(copyBtn)
        
        loginView.addSubview(nameLabel)
        loginView.addSubview(idTitleLabel)
        loginView.addSubview(idLabel)
        
        loginView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview().offset(-80)
            make.top.equalToSuperview()
            make.height.equalTo(88)
        }
        
        loginBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalTo(loginView)
//            make.width.equalTo(150)
            make.height.equalTo(30)
        }
        
        iconView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(56)
            make.centerY.equalTo(loginView)
        }
        bottomLineView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(0.5)
            make.top.equalTo(loginView.snp.bottom)
        }
        
        quotationView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(bottomLineView.snp.bottom).offset(7)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(14)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(26)
            make.top.equalToSuperview().offset(19)
            make.right.equalToSuperview().offset(-16)
        }
        idTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.height.equalTo(16)
        }
        idLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(idTitleLabel)
            make.left.equalTo(idTitleLabel.snp.right).offset(3)
        }
        
        
        copyBtn.snp.makeConstraints { make in
            make.centerY.equalTo(idTitleLabel.snp.centerY)
            make.left.equalTo(idLabel.snp.right).offset(4)
        }
        
        copyBtn.addBlock(for: .touchUpInside) { _ in
            let pasteboard = UIPasteboard.general
            pasteboard.string = YXUserManager.shared().curLoginUser?.dolphinNo ?? ""
            YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "copy_success"))
        }
        
        self.refreshUI()
    }
    
    
    func refreshUI() {
        if YXUserManager.isLogin() {
            
            if let curLoginUser = YXUserManager.shared().curLoginUser{
                self.nameLabel.text = "Hi \(curLoginUser.nickname ?? "")"
                self.idLabel.text = "\(curLoginUser.dolphinNo ?? "")"
                self.iconView.sd_setImage(with: URL.init(string: curLoginUser.avatar ?? ""), placeholderImage:self.iconView.image ?? UIImage.init(named: "user_default_photo"), options: .retryFailed, completed: nil)
               // self.quotationView.cnLabel.text = quotationLevel(kYXMarketChina)
                self.quotationView.usLabel.text = quotationLevel(kYXMarketUS)
                self.quotationView.hkLabel.text = quotationLevel(kYXMarketHK)
              
                // 赋值
                self.loginBtn.isHidden = true
                self.loginView.isHidden = false
                self.quotationView.isHidden = true
                self.iconView.isHidden = false
                copyBtn.isHidden = false
            }
            
        } else {
            self.loginBtn.isHidden = false
            self.loginView.isHidden = true
            self.quotationView.isHidden = true
            self.iconView.image = UIImage.init(named: "user_default_photo")
            self.iconView.isHidden = true
            self.copyBtn.isHidden = true
        }
    }
    
    
    @objc func loginBtnClick(_ sender: UIButton) {
        loginClickCallBack?()
    }
}

func quotationLevel( _ market:String) -> String{
    
    let lv = YXUserManager.userLevel(market)
    switch lv {
    case .usDelay,
         .hkDelay,
         .cnDelay:
        return "Delayed"
    case .hkBMP:
         return "BMP"
    case .hkLevel2,
         .hkWorldLevel2:
        return "Lv2"
    case .usLevel1,
         .cnLevel1:
        return "Lv1"
    default:
        return ""
    }
}
