//
//  YXOrderPartView.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2020/2/13.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXOrderPartView: UIView {

    var symbolType = ""
    var oddTradeType = 0
    
    lazy var partStateLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.numberOfLines = 2
        return label
    }()
    
    lazy var partTimeLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .right
        return label
    }()
    
    var exchangeType: YXExchangeType = .hk
    
    var partLeftLabels: [QMUILabel] = []
    var partRightLabels: [QMUILabel] = []
    
    func leftLabel() -> QMUILabel {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 14);
        return label
    }
    
    func rightLabel() -> QMUILabel {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14);
        label.textAlignment = .right
        return label
    }
    
    var item: YXOrderInfoItem?
    {
        didSet {
            let numberFormatter = NumberFormatter()
            numberFormatter.positiveFormat = "###,##0.00"
            numberFormatter.locale = Locale(identifier: "zh")

            let countFormatter = NumberFormatter()
            countFormatter.numberStyle = .decimal;
            countFormatter.groupingSize = 3;
            countFormatter.groupingSeparator = ","
            countFormatter.maximumFractionDigits = 4
            
            partStateLabel.text = item?.detailStatusName?.yx_orderStatueName()
            partTimeLabel.text = item?.createTime
            partTimeLabel.text = (item?.createTime ?? "").yx_orderTime()
            if item?.createTime?.count ?? 0 < 4 {
                partTimeLabel.text = ""
            }
            var unit = YXLanguageUtility.kLang(key: "stock_unit")
            if exchangeType == .usop {
                unit = ""
            }
            
            partRightLabels.enumerated().forEach({ [weak self] (offset, label) in
                guard let strongSelf = self else { return }
                guard let item = strongSelf.item else { return }
                
                switch offset {
                case 0:
                    if let businessAveragePrice = item.businessAvgPrice?.value as? NSNumber {
                        label.text = priceFormatter.string(from: businessAveragePrice)
                    } else if let businessAveragePrice = item.businessAvgPrice?.value as? String, let value = Double(businessAveragePrice) {
                        label.text = priceFormatter.string(from: NSNumber(value: value))
                    }
                case 1:
                    if let businessAmount = item.businessQty?.value as? Int64 {
                        label.text = (countFormatter.string(from: NSNumber(value: businessAmount)) ?? "0") + unit
                    } else if let entrustAmount = item.businessQty?.value as? Double {
                        label.text = (countFormatter.string(from: NSNumber(value: entrustAmount)) ?? "0") + unit
                    }  else if let businessAmount = item.businessQty?.value as? String, let value = Double(businessAmount) {
                        label.text = (countFormatter.string(from: NSNumber(value: value)) ?? "0") + unit
                    }
                case 2:
                    if let businessBalance = item.businessBalance?.value as? Double {
                        label.text = numberFormatter.string(from: NSNumber(value: businessBalance))
                    } else if let businessBalance = item.businessBalance?.value as? Int64 {
                        label.text = numberFormatter.string(from: NSNumber(value: businessBalance))
                    } else if let businessBalance = item.businessBalance?.value as? String, let value = Double(businessBalance) {
                        label.text = numberFormatter.string(from: NSNumber(value: value))
                    }
                    
                default:
                    break
                }
                if label.text == nil || label.text == ""  {
                    label.text = "--"
                }
            })
        }
    }

    fileprivate lazy var priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal;
        formatter.groupingSeparator = ""
        formatter.maximumFractionDigits = 4
        return formatter;
    }()
    
    lazy var lineView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = QMUITheme().textColorLevel1().withAlphaComponent(0.05)
        return lineView
    }()
    
    init(
        frame: CGRect,
        symbolType: String = "",
        oddTradeType: Int = 0
    ) {
        super.init(frame: frame)
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
        self.layer.borderWidth = 0.5
        self.layer.borderColor = QMUITheme().separatorLineColor().cgColor

        self.symbolType = symbolType
        self.oddTradeType = oddTradeType

        addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(53)
            make.height.equalTo(1)
        }
        
        addSubview(partStateLabel)
        partStateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(12)
            make.top.equalTo(9)
            make.height.equalTo(40)
            make.right.equalTo(self.snp.centerX).offset(-9)
        }
        
        addSubview(partTimeLabel)
        partTimeLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalTo(partStateLabel)
            make.left.equalTo(self.snp.centerX).offset(9)
        }
        
        let label1 = leftLabel()
        label1.text = YXLanguageUtility.kLang(key: "hold_transaction_price")
        
        let label2 = leftLabel()
        label2.text = YXLanguageUtility.kLang(key: "hold_transaction_num")
        
        let label3 = leftLabel()
        label3.text = YXLanguageUtility.kLang(key: "hold_transaction_money")
        
        addSubview(label1)
        addSubview(label2)
        addSubview(label3)
        
        partLeftLabels = [label1, label2, label3]
        partLeftLabels.snp.distributeViewsAlong(axisType: .vertical, fixedItemLength: 22, leadSpacing: 68, tailSpacing: 16)
        partLeftLabels.snp.makeConstraints { (make) in
            make.left.equalTo(12)
        }
        
        var rightLabels = [QMUILabel]()
        for _ in 0...2 {
            let label = rightLabel()
            addSubview(label)
            rightLabels.append(label)
        }
        partRightLabels = rightLabels
        partRightLabels.snp.distributeViewsAlong(axisType: .vertical, fixedItemLength: 22, leadSpacing: 68, tailSpacing: 16)
        partRightLabels.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-12)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}

