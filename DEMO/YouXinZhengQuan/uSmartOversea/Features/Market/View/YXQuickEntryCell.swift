//
//  YXQuickEntryCell.swift
//  uSmartOversea
//
//  Created by youxin on 2021/4/21.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXQuickEntryCell: UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel1()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.numberOfLines = 2
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = QMUITheme().foregroundColor()
        
        layer.borderWidth = 1
        layer.borderColor = QMUITheme().separatorLineColor().cgColor
        layer.cornerRadius = 20
        
        addSubview(imageView)
        addSubview(titleLabel)
        
        imageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(4)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(imageView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-4)
            make.centerY.equalToSuperview()
        }
        
        imageView.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        imageView.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
