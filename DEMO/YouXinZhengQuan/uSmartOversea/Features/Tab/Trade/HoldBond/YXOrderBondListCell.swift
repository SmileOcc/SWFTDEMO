//
//  YXOrderBondListCell.swift
//  uSmartOversea
//
//  Created by youxin on 2019/11/8.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxCocoa

class YXOrderBondListCell: QMUITableViewCell {
    lazy var order = BehaviorRelay<YXBondOrderModel?>(value: nil)

    lazy var nameLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = QMUITheme().textColorLevel1()
        return label
    }()
    
    lazy var symbolLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel3()
        return label
    }()
    
    lazy var failReasonLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel3()
        label.isHidden = true
        return label
    }()
    
    lazy var flagLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 12)
        label.contentEdgeInsets = UIEdgeInsets(top: 1, left: 3, bottom: 1, right: 3)
        label.layer.cornerRadius = 2
        label.layer.masksToBounds = true
        label.layer.borderWidth = 1
        label.isHidden = true
        label.textAlignment = .center
        return label
    }()
    
    lazy var costLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = QMUITheme().textColorLevel1()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .right
        return label
    }()
    
    lazy var numLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel1()
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var entrustDirectionLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .right
        label.baselineAdjustment = .alignCenters;
        return label
    }()
    
    lazy var statusNameLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .right
        return label
    }()
    
    override func didInitialize(with style: UITableViewCell.CellStyle) {
        super.didInitialize(with: style)
        
        self.selectionStyle = .none
        
        contentView.addSubview(flagLabel)
        contentView.addSubview(costLabel)
        contentView.addSubview(numLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(symbolLabel)
        contentView.addSubview(entrustDirectionLabel)
        contentView.addSubview(statusNameLabel)
        contentView.addSubview(failReasonLabel)
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(14)
            make.right.equalTo(costLabel.snp.left).offset(-15)
            make.left.equalTo(18)
        }
        
        symbolLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.left.equalTo(nameLabel)
        }
        
        failReasonLabel.snp.makeConstraints { (make) in
            make.top.equalTo(symbolLabel.snp.bottom).offset(8)
            make.left.equalTo(nameLabel)
        }
        
        flagLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(symbolLabel)
            make.left.equalTo(symbolLabel.snp.right).offset(6)
        }
        
        costLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-160)
            make.centerY.equalTo(nameLabel)
            make.width.equalTo(60)
        }
        
        numLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-85)
            make.centerY.equalTo(nameLabel)
            make.width.equalTo(60)
        }
        
        statusNameLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-18)
            make.centerY.equalTo(nameLabel)
            make.width.equalTo(60)
        }
        
        entrustDirectionLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-18)
            make.centerY.equalTo(symbolLabel)
        }
    }
}
