//
//  YXMarketIPOCenterCell.swift
//  uSmartOversea
//
//  Created by youxin on 2020/12/17.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXMarketIPOCenterPurchasingCell: UICollectionViewCell {
    
    lazy var grey: YXMarketIPOCenterItemView = {
        let item = YXMarketIPOCenterItemView()
        item.titleLabel.text = YXLanguageUtility.kLang(key: "")
        return item
    }()
    
    lazy var publish: YXMarketIPOCenterItemView = {
        let item = YXMarketIPOCenterItemView()
        item.titleLabel.text = YXLanguageUtility.kLang(key: "")
        return item
    }()
    
    lazy var marketed: YXMarketIPOCenterItemView = {
        let item = YXMarketIPOCenterItemView()
        item.titleLabel.text = YXLanguageUtility.kLang(key: "")
        return item
    }()
    
    lazy var selling: YXMarketIPOCenterItemView = {
        let item = YXMarketIPOCenterItemView()
        item.titleLabel.text = YXLanguageUtility.kLang(key: "")
        
        return item
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let vLine = UIView.line()
        
        contentView.addSubview(vLine)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class YXMarketIPOCenterItemView: UIView {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = QMUITheme().textColorLevel1()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = QMUITheme().textColorLevel1()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let blueView = UIView()
        blueView.backgroundColor = QMUITheme().mainThemeColor()
        
        addSubview(blueView)
        addSubview(titleLabel)
        addSubview(valueLabel)
        
        blueView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.equalTo(3)
            make.height.lessThanOrEqualTo(8)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(blueView.snp.right).offset(6)
            make.top.bottom.equalToSuperview()
        }
        
        valueLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalTo(titleLabel)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
