//
//  YXStockBaseinfoView.swift
//  uSmartOversea
//
//  Created by youxin on 2021/4/21.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXStockBaseinfoView: UIView {
    
    @objc var market: String? {
        didSet {
            if let m = market {
                iconLabel.market = m
            }else {
                iconLabel.market = "--"
            }
        }
    }
    
    @objc var symbol: String? {
        didSet {
            if let s = symbol {
                symbolLabel.text = s
            }else {
                symbolLabel.text = "--"
            }
        }
    }
    
    @objc var name: String? {
        didSet {
            if let n = name {
                nameLabel.text = n
            }else {
                nameLabel.text = "--"
            }
        }
    }

    @objc lazy var symbolLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 12,weight: .light)
        label.textColor = QMUITheme().textColorLevel3()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.4
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    @objc lazy var moneyTypeLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 8)
        label.layer.cornerRadius = 2
        label.layer.borderWidth = 0.5
        label.layer.borderColor = label.textColor.cgColor
        label.layer.masksToBounds = true
        label.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        label.isHidden = true
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    @objc lazy var delayLabel: UILabel = {
        let label = UILabel.delay()!
        label.text = YXLanguageUtility.kLang(key: "common_delay")
        label.isHidden = true
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    @objc lazy var iconLabel: YXMarketIconLabel = {
        return YXMarketIconLabel()
    }()
    
    @objc lazy var dividensImageView: UIImageView = {
        let view = UIImageView(image: UIImage.init(named: "dividensFlag"))
        view.isHidden = true
        return view
    }()

    @objc lazy var nameLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = QMUITheme().textColorLevel1()
//        label.adjustsFontSizeToFitWidth = true
//        label.minimumScaleFactor = 0.7
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        let stackView = UIStackView()
        stackView.distribution = .fill
        stackView.spacing = 4
        stackView.axis = .horizontal
        stackView.alignment = .center
        addSubview(stackView)

        stackView.addArrangedSubview(iconLabel)
        stackView.addArrangedSubview(symbolLabel)
        stackView.addArrangedSubview(moneyTypeLabel)
        stackView.addArrangedSubview(delayLabel)
        stackView.addArrangedSubview(dividensImageView)

        addSubview(nameLabel)


        nameLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview()
            make.right.lessThanOrEqualToSuperview()
        }
        
        stackView.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
            make.height.equalTo(20)
            make.left.equalToSuperview()
            make.right.lessThanOrEqualToSuperview()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
