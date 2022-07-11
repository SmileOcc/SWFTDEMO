//
//  YXBullBearLongShortSignalCell.swift
//  uSmartOversea
//
//  Created by youxin on 2020/4/8.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXBullBearLongShortSignalCell: YXTableViewCell {
    
    var tapStockNameAction: ((_ market: String, _ symbol: String) -> Void)?

    var item: YXBullBearPbSignalItem? {
        didSet {
            if let model = item {
                let dateModel = YXDateToolUtility.dateTime(withTime: model.signal?.latestTime ?? "")
                dateLabel.text = "\(dateModel.hour):\(dateModel.minute):\(dateModel.second)"
                signalLabel.text = model.signal?.indicatorsName ?? "--"
                yxselectionLabel.text = model.top?.name ?? YXLanguageUtility.kLang(key: "bullbear_not_available")
            }
        }
    }
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 12)
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var signalLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 12)
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.numberOfLines = 2
        return label
    }()
    
    lazy var yxselectionLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        let tap = UITapGestureRecognizer.init { [weak self](tap) in
            if let action = self?.tapStockNameAction, let market = self?.item?.top?.market, let symbol = self?.item?.top?.symbol {
                action(market, symbol)
            }
        }
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tap)
        
        return label
    }()
    
    lazy var highlightLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 8)
        label.textColor = QMUITheme().textColorLevel3()
        label.layer.borderWidth = 0.5
        label.layer.borderColor = QMUITheme().textColorLevel3().cgColor
        label.layer.cornerRadius = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.text = YXLanguageUtility.kLang(key: "bullbear_usmart_highlight")
        label.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        return label
    }()
    
    override func initialUI() {
        
        super.initialUI()
        
        self.backgroundColor = QMUITheme().foregroundColor()
        
        self.selectionStyle  = .none
        
//        let stackView = UIStackView.init(arrangedSubviews: [dateLabel, signalLabel, yxselectionLabel])
//        stackView.alignment = .center
//        stackView.axis = .horizontal
//        stackView.distribution = .equalSpacing
//        contentView.addSubview(stackView)
        
        contentView.addSubview(yxselectionLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(signalLabel)
        contentView.addSubview(highlightLabel)
        
        yxselectionLabel.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview().offset(16)
        }
        
        highlightLabel.snp.makeConstraints { (make) in
            make.left.equalTo(yxselectionLabel.snp.right).offset(4)
            make.centerY.equalTo(yxselectionLabel)
            make.right.lessThanOrEqualTo(dateLabel.snp.left).offset(-5)
        }
        
        dateLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(yxselectionLabel)
        }
        
        signalLabel.snp.makeConstraints { (make) in
            make.left.equalTo(yxselectionLabel)
            make.top.equalTo(yxselectionLabel.snp.bottom).offset(6)
            make.right.lessThanOrEqualToSuperview().offset(-16)
        }
    }

}
