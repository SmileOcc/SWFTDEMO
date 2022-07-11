//
//  YXStockDetailEmptyView.swift
//  uSmartOversea
//
//  Created by youxin on 2019/9/3.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXStockDetailEmptyView: UIView {
    
    var refreshBlock: (() -> Void)?
    enum EmptyType: Int {
        case stockStop      //股票停盘
        case greyTrade      //暗盘交易
        case toBeListed     //将要上市的新股
        case requestError   //请求错误
        case noData         //请求成功但无数据
        case none
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    func setEmptyType(type: EmptyType) {
        
        var imageName = ""
        var title = ""
        emptyButton.isHidden = true
        switch type {
        case .stockStop:
            imageName = "stock_stop_empty"
            title = YXLanguageUtility.kLang(key: "stock_detail_suspended")
        case .greyTrade:
            imageName = "grey_trade_empty"
            title = YXLanguageUtility.kLang(key: "grey_mkt_start_soon")
        case .toBeListed:
            imageName = "stock_stop_empty"
            title = YXLanguageUtility.kLang(key: "newStock_center_prelist")
        case .requestError:
            imageName = "network_nodata"
            title = YXLanguageUtility.kLang(key: "common_load_fail")
            emptyButton.isHidden = false
        case .noData:
            imageName = "empty_noData"
            title = YXLanguageUtility.kLang(key: "common_string_of_emptyPicture")
        case .none:
            break
        }
        emptyImageView.image = UIImage(named: imageName)
        emptyLabel.text = title
    }
    
    func initUI() {
        
        self.backgroundColor = QMUITheme().foregroundColor()
        addSubview(emptyImageView)
        addSubview(emptyLabel)
        addSubview(emptyButton)
        
        emptyImageView.snp.makeConstraints { (make) in
            make.width.equalTo(130)
            make.height.equalTo(120)
            make.centerX.equalToSuperview()
            make.centerY.equalTo(self.snp.centerY).offset(-20)
        }
        
        emptyLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(emptyImageView.snp.bottom).offset(20)
        }
        
        emptyButton.snp.makeConstraints { (make) in
            make.top.equalTo(emptyLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
    }
    
    lazy var emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    lazy var emptyButton: QMUIButton = {
        let button = QMUIButton()
        button.setTitle(YXLanguageUtility.kLang(key: "common_click_refresh"), for: .normal)
        button.imagePosition = .right
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(QMUITheme().mainThemeColor(), for: .normal)
        button.spacingBetweenImageAndTitle = 3.0
        button.setImage(UIImage(named: "error_refresh"), for: .normal)
        button.addTarget(self, action: #selector(refreshAction), for: .touchUpInside)
        return button
    }()
    
    @objc func refreshAction() {
        refreshBlock?()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
}
