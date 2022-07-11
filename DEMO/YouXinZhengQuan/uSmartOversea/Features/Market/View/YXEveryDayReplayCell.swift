//
//  YXEveryDayReplayCell.swift
//  uSmartOversea
//
//  Created by youxin on 2020/5/8.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXEveryDayReplayCell: UICollectionViewCell {
    @objc lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel3()
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = QMUITheme().foregroundColor()
        
        contentView.addSubview(contentLabel)
        
        contentLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
            make.top.equalToSuperview().offset(9)
            make.bottom.equalToSuperview().offset(-9)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
