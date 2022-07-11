//
//  YXConfigButtonView.swift
//  YouXinZhengQuan
//
//  Created by suntao on 2021/4/26.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXConfigButtonView: UIView {

    @objc lazy var icon: UIImageView = {
        let imageV = UIImageView()
        imageV.contentMode = .scaleAspectFit
       
        return imageV
    }()
    
    @objc lazy var titleLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = QMUITheme().textColorLevel1()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        layer.masksToBounds = true
        backgroundColor = QMUITheme().foregroundColor()
        addSubview(icon)
        addSubview(titleLabel)
        icon.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 28, height: 28))
//            make.centerY.equalToSuperview().offset(-10)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(icon.snp.bottom).offset(6)
            make.left.equalToSuperview().offset(2)
            make.right.equalToSuperview().offset(-2)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
    
}
