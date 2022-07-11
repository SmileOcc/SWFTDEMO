//
//  YXCancelOrderDetailView.swift
//  uSmartOversea
//
//  Created by 覃明明 on 2021/7/16.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXCancelOrderDetailView: UIView {
    
    @objc var model: YXOrderModel? {
        didSet {
            if let m = model {
                nameValueLabel.text = m.symbolName
                symbolValueLabel.text = m.symbol
                priceValueLabel.text = String(format: "%.2lf", m.entrustPrice?.doubleValue ?? 0)
                
                if let entrustAmount = m.entrustQty, let tradedAmount = m.businessQty {
                    let amount = entrustAmount.intValue - tradedAmount.intValue
                    if let formatString = countFormatter.string(from: NSNumber.init(value: amount)) {
                        quantityValueLabel.text = formatString
                    }else {
                        quantityValueLabel.text = "--"
                    }
                    
                } else {
                    quantityValueLabel.text = "--"
                }
            }
        }
    }
    
    lazy var nameLabel: UILabel = {
        let label = creatTitleLabel()
        label.text = "Stock Name"
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    lazy var symbolLabel: UILabel = {
        let label = creatTitleLabel()
        label.text = "Symbol"
        return label
    }()
    
    lazy var priceLabel: UILabel = {
        let label = creatTitleLabel()
        label.text = "Price"
        return label
    }()
    
    lazy var quantityLabel: UILabel = {
        let label = creatTitleLabel()
        label.text = "Quantity"
        return label
    }()
    
    lazy var nameValueLabel: UILabel = {
        let label = creatValueLabel()
        return label
    }()
    
    lazy var symbolValueLabel: UILabel = {
        let label = creatValueLabel()
        return label
    }()
    
    lazy var priceValueLabel: UILabel = {
        let label = creatValueLabel()
        return label
    }()
    
    lazy var quantityValueLabel: UILabel = {
        let label = creatValueLabel()
        return label
    }()
    
    func creatTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel3()
        return label
    }
    
    func creatValueLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel1()
        label.textAlignment = .right
        return label
    }
    
    fileprivate lazy var countFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.positiveFormat = "###,##0";
        formatter.locale = Locale(identifier: "zh")
        return formatter;
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let titles = [nameLabel, symbolLabel, priceLabel, quantityLabel]
        let values = [nameValueLabel, symbolValueLabel, priceValueLabel, quantityValueLabel]
        
        for label in titles {
            addSubview(label)
        }
        
        for label in values {
            addSubview(label)
        }
        
        titles.snp.makeConstraints { make in
            make.left.equalToSuperview()
        }
        titles.snp.distributeViewsAlong(axisType: .vertical, fixedItemLength: 20, leadSpacing: 0, tailSpacing: 0)
        
        values.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.left.equalTo(nameLabel.snp.right).offset(20)
        }
        values.snp.distributeViewsAlong(axisType: .vertical, fixedItemLength: 20, leadSpacing: 0, tailSpacing: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
