//
//  YXA-HKFundAmountView.swift
//  uSmartOversea
//
//  Created by youxin on 2020/3/13.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXA_HKFundAmountView: UIView {
    
    var direction: YXA_HKDirection?
    
    var model: YXA_HKFundAmountResModel? {
        didSet {
            if let item = model, let direct = direction {
                if direct == .north {
                    firstItem.market = .sh
                    secondItem.market = .hs
                    thirdItem.market = .sz
                }else {
                    firstItem.market = .hksh
                    secondItem.market = .hk
                    thirdItem.market = .hksz
                }
                
                var englishPriceBase = item.priceBase
                var unit = YXLanguageUtility.kLang(key: "common_billion")
                if YXUserManager.isENMode() { // 英文下的单位是十亿，所以需要多除以10，pricebase + 1就是多除以10
                    englishPriceBase = englishPriceBase + 1
                    unit = YXLanguageUtility.kLang(key: "common_unit_billion")
                }
                
                let totalAmountText = String(format: "%.\(item.priceBase)f", Double(item.totalAmount)/Double(pow(10.0, Double(englishPriceBase)))) + unit
                if item.totalAmount > 0 {
                    secondItem.amountLabel.text = "+" + totalAmountText
                    secondItem.amountLabel.textColor = QMUITheme().stockRedColor()
                }else if item.totalAmount < 0 {
                    secondItem.amountLabel.text = totalAmountText
                    secondItem.amountLabel.textColor = QMUITheme().stockGreenColor()
                }else {
                    secondItem.amountLabel.text = "0.00"
                    secondItem.amountLabel.textColor = QMUITheme().textColorLevel1()
                }
                
                
                let shAmountText = String(format: "%.\(item.priceBase)f", Double(item.shAmount)/Double(pow(10.0, Double(englishPriceBase)))) + unit
                if item.shAmount > 0 {
                    firstItem.amountLabel.text = "+" + shAmountText
                    firstItem.amountLabel.textColor = QMUITheme().stockRedColor()
                }else if item.shAmount < 0 {
                    firstItem.amountLabel.text = shAmountText
                    firstItem.amountLabel.textColor = QMUITheme().stockGreenColor()
                }else {
                    firstItem.amountLabel.text = "0.00"
                    firstItem.amountLabel.textColor = QMUITheme().textColorLevel1()
                }
                
                firstItem.ratioLabel.text = String(format: "%@%.2lf%%", YXLanguageUtility.kLang(key: "bubear_used_trade"), Double(item.shRatio)/Double(pow(10.0, Double(item.priceBase))))
                
                let szAmountText = String(format: "%.\(item.priceBase)f", Double(item.szAmount)/Double(pow(10.0, Double(englishPriceBase)))) + unit
                if item.szAmount > 0 {
                    thirdItem.amountLabel.text = "+" + szAmountText
                    thirdItem.amountLabel.textColor = QMUITheme().stockRedColor()
                }else if item.szAmount < 0 {
                    thirdItem.amountLabel.text = szAmountText
                    thirdItem.amountLabel.textColor = QMUITheme().stockGreenColor()
                }else {
                    thirdItem.amountLabel.text = "0.00"
                    thirdItem.amountLabel.textColor = QMUITheme().textColorLevel1()
                }
                
                thirdItem.ratioLabel.text = String(format: "%@%.2lf%%", YXLanguageUtility.kLang(key: "bubear_used_trade"), Double(item.szRatio)/Double(pow(10.0, Double(item.priceBase))))
            }
        }
    }
    
    lazy var firstItem: YXA_HKFundAmountItemView = {
        let item = YXA_HKFundAmountItemView()

        return item
    }()
    
    lazy var secondItem: YXA_HKFundAmountItemView = {
        let item = YXA_HKFundAmountItemView()
        
        return item
    }()
    
    lazy var thirdItem: YXA_HKFundAmountItemView = {
        let item = YXA_HKFundAmountItemView()
        
        return item
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let stackView = UIStackView.init(arrangedSubviews: [firstItem, secondItem, thirdItem])
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 5
        
        self.backgroundColor = QMUITheme().foregroundColor()
        
        addSubview(stackView)
        
        stackView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class YXA_HKFundAmountItemView: UIView {
    
    var market: YXA_HKMarket? {
        didSet {
            titleLabel.text = market?.name
            if market == .hs || market == .hk {
                ratioLabel.isHidden = true
                amountLabel.font = .systemFont(ofSize: 24)
            }else {
                ratioLabel.isHidden = false
                amountLabel.font = .systemFont(ofSize: 18)
            }
        }
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.text = "--"
        label.setContentHuggingPriority(UILayoutPriority.init(252), for: .vertical)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var ratioLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.4)
        label.font = .systemFont(ofSize: 12)
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let stackView = UIStackView.init(arrangedSubviews: [titleLabel, amountLabel, ratioLabel])
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.axis = .vertical
        
        addSubview(stackView)
        
        stackView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-4)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



