//
//  YXMarketHSFundFlowCell.swift
//  uSmartOversea
//
//  Created by youxin on 2019/9/19.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class YXMarketHSFundFlowCell: UICollectionViewCell {
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
        label.text = YXLanguageUtility.kLang(key: "markets_news_north_flow")
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.numberOfLines = 2
        return label
    }()
    
    fileprivate lazy var shLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.text = YXLanguageUtility.kLang(key: "markets_news_sh_connect")
        return label
    }()
    
    fileprivate lazy var shValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .left;
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.text = "--"
        return label
    }()
    
    fileprivate lazy var szLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.text = YXLanguageUtility.kLang(key: "markets_news_sz_connect")
        return label
    }()
    
    fileprivate lazy var szValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.text = "--"
        return label
    }()
    
    
    var info: YXMarketHSSCMResponseModel? {
        didSet {
            updateInfo()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        initializeViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func updateInfo() {
        
        if let list = info?.list {
            for item in list {
                let priceBase = Double(pow(10.0, Double(item.priceBase ?? 0)))
                let v = 100000000.0;
                if let netTurnover = item.netTurnover, let code = item.code {
                    let flowInAmount = Double(netTurnover)/priceBase/v
                    let flowInAmountStr = YXToolUtility.stockData(Double(netTurnover), deciPoint: 2, stockUnit: "", priceBase: (item.priceBase ?? 0))
                    if code == "HKSCSH" {
                        shValueLabel.text = flowInAmountStr
                        if flowInAmount > 0 {
                            shValueLabel.textColor = QMUITheme().stockRedColor()
                        }else if flowInAmount < 0 {
                            shValueLabel.textColor = QMUITheme().stockGreenColor()
                        }else {
                            shValueLabel.textColor = QMUITheme().textColorLevel1()
                        }
                    }else if code == "HKSCSZ" {
                        szValueLabel.text = flowInAmountStr
                        if flowInAmount > 0 {
                            szValueLabel.textColor = QMUITheme().stockRedColor()
                        }else if flowInAmount < 0 {
                            szValueLabel.textColor = QMUITheme().stockGreenColor()
                        }else {
                            szValueLabel.textColor = QMUITheme().textColorLevel1()
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func initializeViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(shLabel)
        contentView.addSubview(shValueLabel)
        contentView.addSubview(szLabel)
        contentView.addSubview(szValueLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            if titleLabel.text?.count ?? 0 > 8 {
                make.top.equalTo(5)
                titleLabel.font = .systemFont(ofSize: 12)
            }else {
                make.top.equalTo(15)
                titleLabel.font = .systemFont(ofSize: 14)
            }
            
            make.centerX.equalTo(self)
            make.width.lessThanOrEqualToSuperview()
        }
        
        shLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(9)
            make.right.lessThanOrEqualToSuperview()
        }
        
        shValueLabel.snp.makeConstraints { (make) in
            make.top.equalTo(shLabel.snp.bottom).offset(2)
            make.left.equalTo(shLabel)
            make.right.lessThanOrEqualToSuperview()
        }
        
        szLabel.snp.makeConstraints { (make) in
            make.top.equalTo(shValueLabel.snp.bottom).offset(10)
            make.left.equalTo(shLabel)
            make.right.lessThanOrEqualToSuperview()
        }
        
        szValueLabel.snp.makeConstraints { (make) in
            make.top.equalTo(szLabel.snp.bottom).offset(2)
            make.left.equalTo(szLabel)
            make.right.lessThanOrEqualToSuperview()
        }
    }
}
