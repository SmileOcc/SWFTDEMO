//
//  YXStareListSectionView.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2020/1/19.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXStareListSectionView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension YXStareListSectionView {
    
    func initUI() {
        let timeLabel = UILabel.init(text: YXLanguageUtility.kLang(key: "stock_deal_time"), textColor: QMUITheme().textColorLevel2(), textFont: UIFont.systemFont(ofSize: 12))!
        let stockLabel = UILabel.init(text: YXLanguageUtility.kLang(key: "hold_stock_name"), textColor: QMUITheme().textColorLevel2(), textFont: UIFont.systemFont(ofSize: 12))!
        let typeLabel = UILabel.init(text: YXLanguageUtility.kLang(key: "abnormal_type"), textColor: QMUITheme().textColorLevel2(), textFont: UIFont.systemFont(ofSize: 12))!
        let dataLabel = UILabel.init(text: YXLanguageUtility.kLang(key: "abnormal_data"), textColor: QMUITheme().textColorLevel2(), textFont: UIFont.systemFont(ofSize: 12))!
        addSubview(timeLabel)
        addSubview(stockLabel)
        addSubview(typeLabel)
        addSubview(dataLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }
        dataLabel.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
        let scale = UIScreen.main.bounds.size.width / 375.0
        
        stockLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(scale * 84)
            make.centerY.equalToSuperview()
        }
        typeLabel.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-scale * 104)
            make.centerY.equalToSuperview()
        }
    }
}
