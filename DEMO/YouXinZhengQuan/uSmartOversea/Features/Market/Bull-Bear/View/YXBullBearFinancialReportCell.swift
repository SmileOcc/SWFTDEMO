//
//  YXFinancialReportCell.swift
//  uSmartOversea
//
//  Created by youxin on 2020/4/8.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXBullBearFinancialReportCell: YXTableViewCell {
    
    var tapStockNameAction: ((_ market: String, _ symbol: String) -> Void)?
    var tapRiseStockAction: ((_ market: String, _ symbol: String) -> Void)?
    var tapDownStockAction: ((_ market: String, _ symbol: String) -> Void)?
    
    var item: YXBullBearFinancialReportItem? {
        didSet {
            if let model = item {
                nameLabel.text = model.finance?.name
                dateLabel.text = YXDateHelper.commonDateString(model.finance?.publishDate ?? "", format: .DF_MD)
                
                riseStockLabel.text = model.rise?.name ?? YXLanguageUtility.kLang(key: "bullbear_not_available")
                downStockLabel.text = model.fall?.name ?? YXLanguageUtility.kLang(key: "bullbear_not_available")
            }
        }
    }
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        let tap = UITapGestureRecognizer.init { [weak self](tap) in
            if let action = self?.tapStockNameAction, let market = self?.item?.finance?.market, let symbol = self?.item?.finance?.symbol {
                action(market, symbol)
            }
        }
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tap)
        return label
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var riseStockLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 12)
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        let tap = UITapGestureRecognizer.init { [weak self](tap) in
            if let action = self?.tapRiseStockAction, let market = self?.item?.rise?.market, let symbol = self?.item?.rise?.symbol {
                action(market, symbol)
            }
        }
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tap)
        return label
    }()
    
    lazy var downStockLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 12)
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        let tap = UITapGestureRecognizer.init { [weak self](tap) in
            if let action = self?.tapDownStockAction, let market = self?.item?.fall?.market, let symbol = self?.item?.fall?.symbol {
                action(market, symbol)
            }
        }
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tap)
        return label
    }()
    
    override func initialUI() {
        
        super.initialUI()
        
        self.backgroundColor = QMUITheme().foregroundColor()
        
        self.selectionStyle  = .none
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(riseStockLabel)
        contentView.addSubview(downStockLabel)
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(11)
            make.centerY.equalToSuperview()
            make.right.equalTo(dateLabel.snp.left).offset(-3)
        }
        
        dateLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(100/375.0*YXConstant.screenWidth)
            make.centerY.equalToSuperview()
        }
        
        riseStockLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(160/375.0*YXConstant.screenWidth)
            make.centerY.equalToSuperview()
            
        }
        
        downStockLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(272/375.0*YXConstant.screenWidth)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-11)
        }
    }


}
