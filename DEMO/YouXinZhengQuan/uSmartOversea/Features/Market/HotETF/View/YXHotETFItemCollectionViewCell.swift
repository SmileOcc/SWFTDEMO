//
//  YXHotETFItemCollectionViewCell.swift
//  uSmartOversea
//
//  Created by youxin on 2020/5/21.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXHotETFItemCollectionViewCell: UICollectionViewCell {
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel1()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .center
        return label
    }()
    
    
    var info: [String: Any]? {
        didSet {
            if let dic = info {
                if let name = dic["chsNameAbbr"] as? String {
                    titleLabel.text = name
                }
                
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 4
        layer.masksToBounds = true
        
        backgroundColor = QMUITheme().blockColor()
        
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.lessThanOrEqualToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
