
//
//  YXStockDetailLoadingView.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/8/7.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXStockDetailLoadingView: UIView {

    var activityView = UIActivityIndicatorView.init(style: .gray)
    var noDataLabel = QMUILabel.init()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        backgroundColor = QMUITheme().foregroundColor()
        noDataLabel.text = YXLanguageUtility.kLang(key: "common_loading_with_dot")
        noDataLabel.textColor = QMUITheme().textColorLevel2()
        noDataLabel.font = .systemFont(ofSize: 16)
        
        activityView.hidesWhenStopped = true
        
        addSubview(noDataLabel)
        addSubview(activityView)
        
        noDataLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        activityView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(30)
            make.bottom.equalTo(noDataLabel.snp.top).offset(-10)
        }
        activityView.startAnimating()
    }
}
