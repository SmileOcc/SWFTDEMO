//
//  YXStockFilterCollectionViewCell.swift
//  uSmartOversea
//
//  Created by youxin on 2020/9/2.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXStockFilterCollectionViewCell: UICollectionViewCell {
    override var isSelected: Bool {
        didSet {
            if isSelected {
                
            }else {
                
            }
        }
    }
    
    @objc lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel1()
        label.numberOfLines = 2
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var bgView: UIView = {
        let view = UIView()
        return view
    }()
    
    var model: YXStockFilterItem? {
        didSet {
            if let item = model {
                titleLabel.text = item.name
                if item.isSelected {
                    self.titleLabel.textColor = QMUITheme().themeTextColor()//UIColor.init(hexString: "#2F79FF")!.withAlphaComponent(0.8)
                    self.layer.borderColor = QMUITheme().themeTextColor().cgColor//UIColor.init(hexString: "#2F79FF")!.withAlphaComponent(0.8).cgColor
                    bgView.backgroundColor = QMUITheme().themeTextColor().withAlphaComponent(0.05)//UIColor.init(hexString: "#2F79FF")!.withAlphaComponent(0.1)
                    
                }else {
                    self.titleLabel.textColor = QMUITheme().textColorLevel1()
                    self.layer.borderColor = QMUITheme().itemBorderColor().cgColor
                    bgView.backgroundColor = .clear
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 2
        self.layer.borderColor = QMUITheme().itemBorderColor().cgColor
        
        contentView.addSubview(bgView)
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(5)
            make.right.equalTo(self).offset(-5)
            make.centerY.equalToSuperview()
        }
        
        bgView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
