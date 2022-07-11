//
//  YXMonthlyStockHeaderView.swift
//  uSmartOversea
//
//  Created by youxin on 2021/3/6.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXMonthlyStockHeaderView: UICollectionReusableView {
    
    lazy var commonHeader: YXMarketCommonHeaderCell = {
        let view = YXMarketCommonHeaderCell()
        view.title = YXLanguageUtility.kLang(key: "hot_monthly_stock")
        view.icon = UIImage(named: "monthly_stock")
        return view
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel3()
        label.text = YXLanguageUtility.kLang(key: "market_codeName")
        return label
    }()
    
    lazy var ratioLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel3()
        label.text = YXLanguageUtility.kLang(key: "stock_detail_gx")
        return label
    }()
    
    lazy var fiftyTwoWeekLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel3()
        label.text = YXLanguageUtility.kLang(key: "quote_52_high_low")
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        
        clipsToBounds = true
        
        addSubview(commonHeader)
        addSubview(nameLabel)
        addSubview(ratioLabel)
        addSubview(fiftyTwoWeekLabel)
        
//        let line = UIView.line()
//        addSubview(line)
        
        commonHeader.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(55)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.top.equalTo(commonHeader.snp.bottom)
        }
        
        ratioLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(nameLabel)
        }
        
        fiftyTwoWeekLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-18)
            make.centerY.equalTo(nameLabel)
        }
        
//        line.snp.makeConstraints { (make) in
//            make.left.right.bottom.equalToSuperview()
//            make.height.equalTo(1)
//        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
}
