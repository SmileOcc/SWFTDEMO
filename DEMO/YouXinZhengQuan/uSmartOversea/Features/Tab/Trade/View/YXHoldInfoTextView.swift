//
//  YXHoldInfoTextView.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/5/7.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXHoldInfoTextView: UIView {
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.7)
        titleLabel.textAlignment = .left
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.3
        titleLabel.numberOfLines = 0
        return titleLabel
    }()
    
    lazy var valueLabel: UILabel = {
        let valueLabel = UILabel()
        valueLabel.font = .systemFont(ofSize: 16, weight: .medium)
        valueLabel.textColor = QMUITheme().textColorLevel1()
        valueLabel.textAlignment = .left
        valueLabel.lineBreakMode = .byTruncatingTail
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.3
        return valueLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    public func setTitleLabelText(_ text: String) {
        self.titleLabel.text = text
    }
    
    public func setValueLabelText(_ text: String) {
        self.valueLabel.text = text
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initView() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.valueLabel)
        
        self.isUserInteractionEnabled = false
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(26)
        }
        
        self.valueLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.titleLabel.snp.bottom).offset(2)
            make.height.equalTo(21)
        }
    }
}
