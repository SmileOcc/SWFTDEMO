//
//  YXAreaCodeHeadView.swift
//  YouXinZhengQuan
//
//  Created by usmart on 2021/4/7.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXAreaCodeHeadView: UIView {

    lazy var backBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "icon_backbarbtn"), for: .normal)
        return btn
    }()
    
    lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = QMUITheme().textColorLevel1()
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        addSubview(backBtn)
        addSubview(titleLabel)
        
        backBtn.snp.makeConstraints { (make) in
            make.left.top.equalTo(0)
            make.size.equalTo(CGSize.init(width: 40, height: 40))
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(60)
            make.top.equalTo(0)
            make.right.equalTo(-60)
            make.height.equalToSuperview()
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
