//
//  YXOrgTitleView.swift
//  uSmartOversea
//
//  Created by 欧冬冬 on 2022/4/15.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXOrgTitleView: UIView {

    typealias TitleChanage = (YXSignInType)->()
    
    var didChanage:TitleChanage?
    
    var titleName: String = YXLanguageUtility.kLang(key: "org_login_title")
    var mobileName: String = YXLanguageUtility.kLang(key: "mobile_acount")
    var emailName: String = YXLanguageUtility.kLang(key: "acount_title")
    
    lazy var mainLabel:QMUILabel = {
        let label = QMUILabel.init(frame: .zero)
        label.font = .systemFont(ofSize: 24, weight: .medium)
        label.textAlignment = .left
        label.textColor = QMUITheme().textColorLevel1()
        return label
    }()
    
    lazy var subButton :QMUIButton = {
        let btn = QMUIButton.init(frame: .zero)
        btn.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        btn.imagePosition = .right
        btn.setImage(UIImage.init(named: "icon_more_login_title"), for: .normal)
        btn.spacingBetweenImageAndTitle = 4
        btn.titleLabel?.font = .systemFont(ofSize: 16)
        btn.sizeToFit()
        btn.addTarget(self, action: #selector(exchanage), for: .touchUpInside)
        return btn
    }()
    
    var siginIntype : YXSignInType!


    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(type:YXSignInType, title:String, mobileSubName:String, emialSubName:String) {
        self.init(frame: .zero)
        self.siginIntype = type
        self.titleName = title
        self.mobileName = mobileSubName
        self.emailName = emialSubName
        
        setupUI()
    }
    
   
    func setupUI(){
        addSubview(mainLabel)
        addSubview(subButton)
        
        self.mainLabel.text = self.titleName
        
        mainLabel.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(29)
        };
        
        subButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.height.equalTo(19)
            make.top.equalTo(mainLabel.snp_bottomMargin).offset(12)
        }
        
        refreshTitle()
    }
    
    func refreshTitle() {
        if self.siginIntype == .emailOrDolphin {
            subButton.setTitle(self.mobileName, for: .normal)
        } else {
            subButton.setTitle(self.emailName, for: .normal)

        }
    }
    
    @objc func exchanage(){
        self.siginIntype = self.siginIntype == .mobile ? .emailOrDolphin : .mobile
        refreshTitle()
        didChanage?(self.siginIntype)
    }
}
