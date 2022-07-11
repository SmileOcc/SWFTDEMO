//
//  YXShareOptionsHeaderView.swift
//  uSmartOversea
//
//  Created by youxin on 2020/11/23.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXShareOptionsHeaderView: UIView {
    
    var tapStockAction: ((_ market: String, _ symbol: String) -> Void)?
    
    lazy var stockLabel: UILabel = {
        let label = creatLabel(font: .systemFont(ofSize: 14), textColor: QMUITheme().textColorLevel2())
        label.text = YXLanguageUtility.kLang(key: "hold_stock_name")
        return label
    }()
    
    lazy var nameLabel: UILabel = {
        let label = creatLabel(font: .systemFont(ofSize: 16), textColor: QMUITheme().textColorLevel1())
        return label
    }()
    
    lazy var symbolLabel: UILabel = {
        let label = creatLabel(font: .systemFont(ofSize: 14), textColor: QMUITheme().textColorLevel3())
        return label
    }()
    
    lazy var priceLabel: UILabel = {
        let label = creatLabel(font: .systemFont(ofSize: 18), textColor: QMUITheme().stockGrayColor())
        return label
    }()
    
    lazy var changeLabel: UILabel = {
        let label = creatLabel(font: .systemFont(ofSize: 14), textColor: QMUITheme().stockGrayColor())
        return label
    }()
    
    lazy var rocLabel: UILabel = {
        let label = creatLabel(font: .systemFont(ofSize: 14), textColor: QMUITheme().stockGrayColor())
        return label
    }()
    
    lazy var searchButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "warrant_search"), for: .normal)
        return button
    }()
    
    lazy var line: UIView = {
        let line = UIView.line()
        return line
    }()
    
    lazy var delayLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 8)
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.4)
        label.backgroundColor = QMUITheme().textColorLevel1().withAlphaComponent(0.05)
        label.layer.cornerRadius = 1.0
        label.layer.masksToBounds = true
        label.contentEdgeInsets = UIEdgeInsets.init(top: 1, left: 2, bottom: 1, right: 2)
        label.text = YXLanguageUtility.kLang(key: "common_delay")
        
        return label
    }()
    
    func creatLabel(font: UIFont, textColor: UIColor) -> UILabel {
        let label = UILabel()
        label.font = font
        label.textColor = textColor
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.text = "--"
        return label
    }
    
    var isLandscape: Bool = false {
        didSet {
            stockLabel.isHidden = isLandscape
            line.isHidden = isLandscape
            searchButton.isHidden = isLandscape
            
            if isLandscape {
            
                nameLabel.snp.remakeConstraints { (make) in
                    if #available(iOS 11.0, *) {
                        make.left.equalTo(self.safeAreaLayoutGuide).offset(12)
                    } else {
                        make.left.equalToSuperview().offset(12)
                    }
                    make.centerY.equalToSuperview()
                }
                priceLabel.snp.remakeConstraints { (make) in
                    make.left.equalTo(symbolLabel.snp.right).offset(28)
                    make.centerY.equalToSuperview()
                }
                
            }else {

                nameLabel.snp.remakeConstraints { (make) in
                    make.centerY.equalTo(stockLabel)
                    make.left.equalTo(stockLabel.snp.right).offset(26)
                }
                priceLabel.snp.remakeConstraints { (make) in
                    make.left.equalTo(nameLabel)
                    make.top.equalTo(line.snp.bottom).offset(6)
                }
            }
        }
    }
    
    var quoteModel: YXV2Quote? {
        didSet {
            if let model = quoteModel {
                let priceBase = model.priceBase?.value ?? 0
                let base = pow(10.0, Double(priceBase))
                nameLabel.text = model.name
                symbolLabel.text = "(\(model.symbol ?? "--"))"
                
                if let price = model.latestPrice?.value {
                    priceLabel.text = String(format: "%.\(priceBase)lf", Double(price) / base)
                }
                
                var op = ""
                var color: UIColor = QMUITheme().stockGrayColor()
                if let change = model.netchng?.value {
                    if change > 0 {
                        op = "+"
                        color = QMUITheme().stockRedColor()
                    }else if change < 0 {
                        color = QMUITheme().stockGreenColor()
                    }
                    changeLabel.text = String(format: "%@%.\(priceBase)lf", op, Double(change) / base)
                }
                
                if let roc = model.pctchng?.value {
                    rocLabel.text = String(format: "(%@%.2lf%%)", op, Double(roc) / 100.0)
                }

                priceLabel.textColor = color
                changeLabel.textColor = color
                rocLabel.textColor = color
                
                if YXUserManager.shared().getLevel(with: model.market ?? kYXMarketUS) == .delay {
                    delayLabel.isHidden = false
                }else {
                    delayLabel.isHidden = true
                }
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = QMUITheme().foregroundColor()
        
        let tap = UITapGestureRecognizer.init(actionBlock: { [weak self] _ in
            if let market = self?.quoteModel?.market, let symbol = self?.quoteModel?.symbol {
                self?.tapStockAction?(market, symbol)
            }
        })
        
        addGestureRecognizer(tap)
        
        addSubview(stockLabel)
        addSubview(nameLabel)
        addSubview(symbolLabel)
        addSubview(priceLabel)
        addSubview(changeLabel)
        addSubview(rocLabel)
        addSubview(searchButton)
        addSubview(delayLabel)
        
        addSubview(line)
        
        stockLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(10)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(stockLabel)
            make.left.equalTo(stockLabel.snp.right).offset(26)
        }
        
        symbolLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(nameLabel)
            make.left.equalTo(nameLabel.snp.right).offset(6)
            make.right.lessThanOrEqualTo(searchButton.snp.left).offset(-20)
            make.width.greaterThanOrEqualTo(20)
        }
        
        priceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.top.equalTo(line.snp.bottom).offset(6)
        }
        
        changeLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(priceLabel)
            make.left.equalTo(priceLabel.snp.right).offset(10)
        }
        
        rocLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(priceLabel)
            make.left.equalTo(changeLabel.snp.right).offset(6)
        }
        
        delayLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(symbolLabel)
            make.left.equalTo(symbolLabel.snp.right).offset(3)
            make.height.equalTo(12)
        }
        
        line.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.right.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
        }
        
        searchButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalTo(stockLabel)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
