//
//  YXSelectFundView.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/12/6.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXSelectFundView: UIView {
    
    var fund: YXFund? {
        didSet {
            if let fund = fund {
                titleLabel.text = fund.title
                rateDescLabel.text = fund.apyTypeName
                
                var moneyUnit = YXToolUtility.moneyUnit(fund.tradeCurrency ?? 0)
                let initialInvestAmount = YXToolUtility.stockData(Double(fund.initialInvestAmount ?? "0") ?? 0, deciPoint: 0, stockUnit: moneyUnit, priceBase: 0)!
                moneyUnit = YXToolUtility.moneyUnit(fund.fundSizeCurrency ?? 0)
                let fundSize = YXToolUtility.stockData(Double(fund.fundSize ?? "0") ?? 0, deciPoint: 0, stockUnit: moneyUnit, priceBase: 0)!
                
                if YXUserManager.isENMode() {
                    if let fundSizeValue = Double(fund.fundSize ?? "0"), fundSizeValue > 0 {
                        subTitleLabel.text = "\(fund.assetTypeName ?? "") | \(YXLanguageUtility.kLang(key: "fund_initial")) \(initialInvestAmount) | \(YXLanguageUtility.kLang(key: "fund_aum")) \(fundSize)"
                    } else {
                        subTitleLabel.text = "\(fund.assetTypeName ?? "") | \(YXLanguageUtility.kLang(key: "fund_initial")) \(initialInvestAmount)"
                    }
                } else {
                    if let fundSizeValue = Double(fund.fundSize ?? "0"), fundSizeValue > 0 {
                        subTitleLabel.text = "\(fund.assetTypeName ?? "") | \(initialInvestAmount)\(YXLanguageUtility.kLang(key: "fund_initial")) | \(fundSize)\(YXLanguageUtility.kLang(key: "fund_aum"))"
                    } else {
                        subTitleLabel.text = "\(fund.assetTypeName ?? "") | \(initialInvestAmount)\(YXLanguageUtility.kLang(key: "fund_initial"))"
                    }
                }
                
                if let apy = fund.apy, let rate = Double(apy) {
                    if rate > 0 {
                        rateLabel.text = String(format: "+%.02f%%", rate * 100.0)
                        rateLabel.textColor = YXStockColor.currentColor(.up)
                    } else if rate < 0 {
                        rateLabel.text = String(format: "%.02f%%", rate * 100.0)
                        rateLabel.textColor = YXStockColor.currentColor(.down)
                    } else {
                        rateLabel.text = String(format: "%.02f%%", rate * 100.0)
                        rateLabel.textColor = YXStockColor.currentColor(.flat)
                    }
                } else {
                    rateLabel.text = "0.00%"
                    rateLabel.textColor = YXStockColor.currentColor(.flat)
                }
            }
        }
    }
    
    var isFirst: Bool = false {
        didSet {
            if isFirst {
                iconView.image = UIImage(named: "search_fund_first")
            } else {
                iconView.image = UIImage(named: "search_fund_second")
            }
        }
    }

    lazy var iconView: UIImageView = {
        let iconView = UIImageView(image: UIImage(named: "search_fund_first"))
        return iconView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.qmui_color(withHexString: "#191919")
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        label.textColor = UIColor.qmui_color(withHexString: "#666666")
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .left
        return label
    }()
    
    lazy var rateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = YXStockColor.currentColor(.up)
        label.textAlignment = .right
        return label
    }()
    
    lazy var rateDescLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.qmui_color(withHexString: "#666666")
        label.textAlignment = .right
        label.numberOfLines = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(subTitleLabel)
        addSubview(rateLabel)
        addSubview(rateDescLabel)
        iconView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.top.equalToSuperview()
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconView.snp.right).offset(10)
            make.right.equalTo(rateLabel.snp.left).offset(-10)
            make.top.equalToSuperview()
            make.height.equalTo(20)
        }
        
        subTitleLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(4)
            make.height.equalTo(14)
        }
        
        rateLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-18)
            make.width.equalTo(80)
            make.top.equalToSuperview()
            make.height.equalTo(20)
        }
        
        rateDescLabel.snp.makeConstraints { (make) in
            make.right.width.equalTo(rateLabel)
            make.top.equalTo(rateLabel.snp.bottom).offset(4)
            make.height.equalTo(14)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
