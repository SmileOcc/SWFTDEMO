//
//  YXFractionalQuantityView.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2022/4/25.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXFractionalQuantityView: UIView, YXTradeHeaderSubViewProtocol {
    
    private lazy var bgView: YXInputBaseView = {
        let view = YXInputBaseView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var quantityTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font =  .systemFont(ofSize: 14)
        label.text = YXLanguageUtility.kLang(key: "quantity_estimated")
        label.baselineAdjustment = .alignCenters
        label.textAlignment = .left
        return label
    }()
    
    private lazy var quantityLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font =  .systemFont(ofSize: 16, weight: .medium)
        label.text = "--"
        label.minimumScaleFactor = 0.1
        label.adjustsFontSizeToFitWidth = true
        label.baselineAdjustment = .alignCenters
        label.textAlignment = .right
        return label
    }()

    var quantity: String? {
        didSet {
            updateQuantity()
        }
    }
    
    func updateQuantity() {
        var quantityTextColor: UIColor = QMUITheme().textColorLevel3()
        
        if let quantity = quantity {
            quantityTextColor = QMUITheme().textColorLevel1()
            
            quantityLabel.text = quantity + " " + YXLanguageUtility.kLang(key: "stock_unit")
        } else {
            quantityLabel.text = "--"
        }
        quantityLabel.textColor = quantityTextColor
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialUI() {
        
        addSubview(bgView)
        bgView.addSubview(quantityTitleLabel)
        bgView.addSubview(quantityLabel)

        bgView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(44)
        }
                     
        quantityTitleLabel.snp.makeConstraints { (make) in
            make.bottom.top.equalToSuperview()
            make.left.equalToSuperview()
        }
        
        quantityLabel.snp.makeConstraints { (make) in
            make.bottom.top.equalTo(quantityTitleLabel)
            make.right.equalToSuperview()
            make.left.greaterThanOrEqualTo(quantityTitleLabel.snp.right).offset(5)
        }
        quantityLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        contentHeight = 52
    }
}

extension TradeModel {
    var franctionalEstimatedQuantity: String? {
        
        if tradeOrderType == .smart, condition.conditionOrderType == .market {
            return nil
        }
        
        var priceValue = Double(entrustPrice) ?? 0
        if tradeOrderType == .bidding
            || tradeOrderType == .market {
            priceValue = Double(latestPrice ?? "") ?? 0
        }
        
        let fractionalAmountValue = fractionalAmount.doubleValue

        if priceValue > 0, fractionalAmountValue > 0 {
            let numberFormatter = NumberFormatter()
            numberFormatter.positiveFormat = "###,##0.0000"
            numberFormatter.locale = Locale(identifier: "zh")
            numberFormatter.roundingMode = .down
            
            let quantityValue = fractionalAmountValue / priceValue
            return numberFormatter.string(from: NSNumber(value: quantityValue))
        }
        return nil
    }
}

