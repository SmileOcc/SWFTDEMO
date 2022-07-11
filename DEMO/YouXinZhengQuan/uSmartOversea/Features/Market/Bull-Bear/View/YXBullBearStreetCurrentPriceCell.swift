//
//  YXBullBearStreetCurrentPriceCell.swift
//  uSmartOversea
//
//  Created by youxin on 2020/4/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXBullBearStreetCurrentPriceCell: YXTableViewCell {
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.font = .systemFont(ofSize: 14)
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.font = .systemFont(ofSize: 14)
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    override func initialUI() {
        
        super.initialUI()
        
        self.selectionStyle  = .none
        self.backgroundColor = QMUITheme().separatorLineColor()
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(11)
            make.centerY.equalToSuperview()
        }
        
        priceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.right).offset(5)
            make.centerY.equalToSuperview()
        }
    }

}
