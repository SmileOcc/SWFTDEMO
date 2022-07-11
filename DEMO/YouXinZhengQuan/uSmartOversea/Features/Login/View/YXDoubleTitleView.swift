//
//  YXDoubleTitleView.swift
//  uSmartOversea
//
//  Created by usmart on 2021/3/29.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

import SnapKit



class YXDoubleTitleView: UIView {

    typealias TitleChanage = (String)->()
    
    var didChanage:TitleChanage?
    
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
    
    var mainTitle = ""
    var subTittle = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(mainTitle:String,subTitle:String) {
        self.init(frame: .zero)
        self.mainTitle = mainTitle
        self.subTittle = subTitle
        setupUI()
    }
    
   
    func setupUI(){
        addSubview(mainLabel)
        addSubview(subButton)
        
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
        mainLabel.text = mainTitle
        subButton.setTitle(subTittle, for: .normal)
    }
    
    @objc func exchanage(){
        let tmp = mainTitle
        mainTitle = subTittle
        subTittle = tmp
        refreshTitle()
        didChanage?(mainTitle)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
