//
//  YXStockDetailDepthTradeSettingView.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2021/6/24.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

@objc enum YXDepthTradeSettingType: Int {
    case colorPrice = 0
    case orderNumber
    case combineSamePrice
    case priceDistribution
    
    var text: String {
        switch self {
        case .colorPrice:
            return YXLanguageUtility.kLang(key: "depth_price_color")
        case .orderNumber:
            return YXLanguageUtility.kLang(key: "depth_order_number")
        case .combineSamePrice:
            return YXLanguageUtility.kLang(key: "depth_combine_same_price")
        case .priceDistribution:
            return YXLanguageUtility.kLang(key: "depth_price_distribution")
        }
    }
    
    var shouldShow: Bool {
        switch self {
        case .colorPrice:
            return YXStockDetailUtility.showDepthTradeColorPrice()
        case .orderNumber:
            return YXStockDetailUtility.showDepthTradeOrderNumber()
        case .combineSamePrice:
            return YXStockDetailUtility.showDepthTradeCombineSamePrice()
        case .priceDistribution:
            return YXStockDetailUtility.showDepthTradePriceDistribution()
        }
    }
    
    func saveShouldShow(_ isSelect: Bool) {
        switch self {
        case .colorPrice:
            return YXStockDetailUtility.setDepthTradeColorPrice(isSelect)
        case .orderNumber:
            return YXStockDetailUtility.setDepthTradeOrderNumber(isSelect)
        case .combineSamePrice:
            return YXStockDetailUtility.setDepthTradeCombineSamePrice(isSelect)
        case .priceDistribution:
            return YXStockDetailUtility.setDepthTradePriceDistribution(isSelect)
        }
    }

}

class YXStockDetailDepthTradeSettingControl: UIControl {
    
    var type: YXDepthTradeSettingType = .colorPrice
    override var isSelected: Bool {
        didSet {
            if isSelected {
                checkImageView.image = UIImage(named: "selectStockBg")
            } else {
                checkImageView.image = UIImage(named: "noSelectStockBg")
            }
            
            type.saveShouldShow(isSelected)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        self.backgroundColor = QMUITheme().popupLayerColor()
        
        addSubview(checkImageView)
        checkImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(15)
        }
        
        addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(checkImageView.snp.right).offset(6)
            make.right.equalTo(self.snp.right).offset(-2)
        }
        addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.bottom.equalToSuperview()
            make.left.equalTo(8)
            make.right.equalToSuperview().offset(-8)
        }
    }
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = ""
        label.textAlignment = .left
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        
        return label
    }()
    
    lazy var checkImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "edit_uncheck_WhiteSkin")
        return view
    }()
    
    lazy var lineView : UIView = {
        let lineView = UIView()
        lineView.backgroundColor = QMUITheme().popSeparatorLineColor()
        return lineView
    }()
    
}
