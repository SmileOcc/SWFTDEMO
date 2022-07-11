//
//  YXSingleTitleView.swift
//  uSmartOversea
//
//  Created by usmart on 2021/4/2.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXSingleTitleView: UIView {

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
    var subTitle = ""
    var currentTitle = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(mainTitle:String,currentTitle:String,subTitle:String) {
        self.init(frame: .zero)
        self.mainTitle = mainTitle
        self.subTitle = subTitle
        self.currentTitle = currentTitle
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
        subButton.setTitle(currentTitle, for: .normal)
    }
    
    @objc func exchanage(){
        let tmp = currentTitle
        currentTitle = subTitle
        subTitle = tmp
        refreshTitle()
        didChanage?(currentTitle)
    }
    
    func isEnabled(_ en:Bool){
        subButton.isEnabled = en
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
