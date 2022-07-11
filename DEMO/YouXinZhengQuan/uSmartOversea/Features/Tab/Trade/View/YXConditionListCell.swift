//
//  YXConditionListCell.swift
//  uSmartOversea
//
//  Created by ellison on 2019/5/18.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxCocoa

class YXConditionListCell: QMUITableViewCell {
    
    lazy var order = BehaviorRelay<YXOrderItem?>(value: nil)
    
    func setTextColor(_ isValid: Bool) {
        var color = QMUITheme().textColorLevel1()
        if isValid == false {
            color = QMUITheme().textColorLevel2()
        }
        nameLabel.textColor = color
        statusLabel.textColor = color
        moneyLabel.textColor = color
        entrustLabel.textColor = color
        entrustTotalMoneyLabel.textColor = color
    }

    lazy var nameLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = QMUITheme().textColorLevel1()
        return label
    }()
    
    lazy var timeLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel2()
        label.textAlignment = .right
        return label
    }()
    
    lazy var statusLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel1()
        return label
    }()
    
    lazy var conditionLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel2()
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
    
    lazy var entrustLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    lazy var moneyLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.text = YXLanguageUtility.kLang(key: "trigger_amount")
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    lazy var entrustTotalMoneyLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.baselineAdjustment = .alignCenters
        return label
    }()
    
    lazy var greyFlagLabel: QMUILabel = {
        let label = QMUILabel()
        label.text = YXLanguageUtility.kLang(key: "grey_mkt")
        label.font = .systemFont(ofSize: 10)
        label.layer.cornerRadius = 1
        label.layer.masksToBounds = true
        label.textColor = UIColor.qmui_color(withHexString: "#7A4CFF")
        label.layer.borderColor = UIColor.qmui_color(withHexString: "#7A4CFF")?.cgColor
        label.layer.borderWidth = 0.5
        label.isHidden = true
        label.textAlignment = .center
        label.contentEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 3)
        return label
    }()
    
    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().separatorLineColor()
        return view
    }()

    override func didInitialize(with style: UITableViewCell.CellStyle) {
        super.didInitialize(with: style)
        
        self.selectionStyle = .none
        
        contentView.addSubview(statusLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(conditionLabel)
        contentView.addSubview(entrustLabel)
        contentView.addSubview(entrustDirectionLabel)
        contentView.addSubview(moneyLabel)
        contentView.addSubview(entrustTotalMoneyLabel)
        contentView.addSubview(greyFlagLabel)
        contentView.addSubview(lineView)
        
        statusLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-18)
            make.top.equalTo(14)
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(statusLabel.snp.left).offset(-2)
            make.centerY.equalTo(statusLabel)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(18)
            make.top.equalTo(self).offset(14)
            make.right.lessThanOrEqualTo(timeLabel.snp.left).offset(-10)
        }

        conditionLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
        }
        
        greyFlagLabel.snp.makeConstraints { (make) in
            make.right.equalTo(statusLabel)
            make.centerY.equalTo(conditionLabel)
            make.height.equalTo(16)
        }
        
        entrustTotalMoneyLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-18)
            make.bottom.equalTo(self).offset(-14)
            //make.width.equalTo(65)
        }
        
        moneyLabel.snp.makeConstraints { (make) in
            make.right.equalTo(entrustTotalMoneyLabel.snp.left).offset(-8)
            make.bottom.equalTo(entrustTotalMoneyLabel)
        }
        
        entrustDirectionLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.centerY.equalTo(entrustTotalMoneyLabel)
        }
        
        entrustLabel.snp.makeConstraints { (make) in
            make.left.equalTo(entrustDirectionLabel.snp.right).offset(8)
            make.centerY.equalTo(entrustTotalMoneyLabel)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.left)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.right.equalToSuperview().offset(-18)
        }
        
    }
}
