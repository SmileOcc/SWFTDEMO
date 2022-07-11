//
//  YXHoldBondListCell.swift
//  uSmartOversea
//
//  Created by youxin on 2019/11/8.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxCocoa
import NSObject_Rx

class YXHoldBondListCell: QMUITableViewCell, HasDisposeBag {

    lazy var stock = BehaviorRelay<YXBondHoldModel?>(value: nil)
    
    
    var labels =  [UILabel]()
    var detailLabels =  [UILabel]()
    var sortTypes: [YXStockRankSortType]
    var config: YXNewStockMarketConfig
    
    var isDelay: Bool = false
    
    func refreshUI(model: YXBondHoldModel?) {
        
        nameLabel.text = model?.bondName ?? "--"
        
        for label in labels {
            label.text = "--"
            if let sortType = YXStockRankSortType.init(rawValue: label.tag) {
                setLabelText(type: sortType, label: label, model: model)
            }
        }
        
        for label in detailLabels {
            label.text = "--"
            if let sortType = YXStockRankSortType.init(rawValue: label.tag) {
                setDetailLabelText(type: sortType, label: label, model: model)
            }
        }
        
        // 延时
        delayLabel.isHidden = !isDelay
        
    }
    
    func setDetailLabelText(type: YXStockRankSortType, label: UILabel, model: YXBondHoldModel?) {
        let moneyFormatter = NumberFormatter()
        moneyFormatter.positiveFormat = "###,##0.00"
        moneyFormatter.locale = Locale(identifier: "zh")
        
        switch type {
        case .dailyBalance: //上市日期
            if let dailyBalancePercent = model?.profitRatio, let value = Double(dailyBalancePercent) {
                if value == 0 {
                    label.text = "0.00%"
                } else {
                    label.text = String(format: "%+.2f%%", value * 100)
                }
                
                if value > 0 {
                    label.textColor = QMUITheme().stockRedColor()
                } else if value == 0 {
                    label.textColor = QMUITheme().stockGrayColor()
                } else {
                    label.textColor = QMUITheme().stockGreenColor()
                }
            }
        case .holdingBalance:
            if let holdingBalancePercent = model?.totalProfitRatio, let value = Double(holdingBalancePercent) {
                if value == 0 {
                    label.text = "0.00%"
                } else {
                    label.text = String(format: "%+.2f%%", value * 100)
                }
                
                if value > 0 {
                    label.textColor = QMUITheme().stockRedColor()
                } else if value == 0 {
                    label.textColor = QMUITheme().stockGrayColor()
                } else {
                    label.textColor = QMUITheme().stockGreenColor()
                }
            }
        case .lastAndCostPrice:
            if let costPrice = model?.costPrice, let value = Double(costPrice) {
                if value == 0 {
                    label.text = "0.00"
                } else {
                    label.text = String(format: "%.4f", value)
                }
            }
        case .marketValueAndNumber:
            if let currentAmount = model?.positionQuantity, let value = Double(currentAmount) {
                if value == 0 {
                    label.text = "0"
                } else {
                    let formatter = NumberFormatter()
                    formatter.locale = Locale(identifier: "zh")
                    formatter.positiveFormat = "###,##0"
                    label.text = String(format: "%@%@", formatter.string(from: NSNumber(value: value)) ?? "0", YXLanguageUtility.kLang(key: "copies"))
                }
            }
            
        default:
            break
        }
    }
    
    func setLabelText(type: YXStockRankSortType, label: UILabel, model:YXBondHoldModel?) {
        switch type {
        case .dailyBalance: //上市日期
            if let dailyBalance = model?.profit, let value = Double(dailyBalance) {
                if value == 0 {
                    label.text = "0.00"
                } else {
                    let formatter = NumberFormatter()
                    formatter.locale = Locale(identifier: "zh")
                    formatter.positiveFormat = "###,##0.00"
                    label.text = String(format: "%@", formatter.string(from: NSNumber(value: value)) ?? "0.00")
                    
                    if value < 0 {
                        label.text = String(format: "%@", formatter.string(from: NSNumber(value: value)) ?? "0.00")
                    } else {
                        label.text = String(format: "+%@", formatter.string(from: NSNumber(value: value)) ?? "0.00")
                    }
                }
                
                if value > 0 {
                    label.textColor = QMUITheme().stockRedColor()
                } else if value == 0 {
                    label.textColor = QMUITheme().stockGrayColor()
                } else {
                    label.textColor = QMUITheme().stockGreenColor()
                }
            }
        case .holdingBalance:
            if let holdingBalance = model?.totalProfit, let value = Double(holdingBalance) {
                if value == 0 {
                    label.text = "0.00"
                } else {
                    let formatter = NumberFormatter()
                    formatter.positiveFormat = "###,##0.00"
                    formatter.locale = Locale(identifier: "zh")
                    if value < 0 {
                        label.text = String(format: "%@", formatter.string(from: NSNumber(value: value)) ?? "0.00")
                    } else {
                        label.text = String(format: "+%@", formatter.string(from: NSNumber(value: value)) ?? "0.00")
                    }
                }
                
                if value > 0 {
                    label.textColor = QMUITheme().stockRedColor()
                } else if value == 0 {
                    label.textColor = QMUITheme().stockGrayColor()
                } else {
                    label.textColor = QMUITheme().stockGreenColor()
                }
            }
        case .lastAndCostPrice:
            if let lastPrice = model?.price, let value = Double(lastPrice) {
                if value == 0 {
                    label.text = "0.00"
                } else {
                    label.text = String(format: "%.4f", value)
                }
            }
        case .marketValueAndNumber:
            if let marketValue = model?.marketValue, let value = Double(marketValue) {
                if value == 0 {
                    label.text = "0.00"
                } else {
                    let formatter = NumberFormatter()
                    formatter.locale = Locale(identifier: "zh")
                    formatter.positiveFormat = "###,##0.00"
                    label.text = String(format: "%@", formatter.string(from: NSNumber(value: value)) ?? "0.00")
                }
            }
            
        default:
            break
        }
    }
    
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, sortTypes: [YXStockRankSortType], config: YXNewStockMarketConfig) {
        
        self.sortTypes = sortTypes
        self.config = config
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        contentView.addGestureRecognizer(scrollView.panGestureRecognizer)
        initializeViews()
    }
    
    func initializeViews() {
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(symbolLabel)
        contentView.addSubview(delayLabel)
        contentView.addSubview(scrollView)
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
            make.width.lessThanOrEqualTo(self.config.leftItemWidth - self.config.fixMargin)
            make.height.equalTo(20)
        }
        
        symbolLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.left)
            make.bottom.equalToSuperview().offset(-14)
            make.width.lessThanOrEqualTo(self.config.leftItemWidth - self.config.fixMargin - self.config.itemMargin)
            make.height.equalTo(15)
        }
        
        delayLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(symbolLabel.snp.centerY)
            make.left.equalTo(symbolLabel.snp.right).offset(6)
        }
        
        scrollView.snp.makeConstraints { (make) in
            make.top.bottom.right.equalToSuperview()
            make.left.equalToSuperview().offset(self.config.leftItemWidth + self.config.fixMargin)
        }
        
        let width = self.config.itemWidth
        for (index, type) in sortTypes.enumerated() {
            //第一行
            let label = UILabel()
            label.textColor = QMUITheme().textColorLevel1()
            label.font = .systemFont(ofSize: 16)
            label.textAlignment = .right
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.3
            label.tag = type.rawValue
            
            labels.append(label)
            scrollView.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.centerY.equalTo(nameLabel)
                make.width.equalTo(width - 10)
                make.left.equalToSuperview().offset(width * CGFloat(index) + 10)
            }
            //第二行
            let detailLabel = UILabel()
            detailLabel.textColor = QMUITheme().textColorLevel1()
            detailLabel.font = .systemFont(ofSize: 12)
            detailLabel.textAlignment = .right
            detailLabel.adjustsFontSizeToFitWidth = true
            detailLabel.minimumScaleFactor = 0.3
            detailLabel.tag = type.rawValue
            
            detailLabels.append(detailLabel)
            scrollView.addSubview(detailLabel)
            detailLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(symbolLabel)
                make.width.equalTo(label)
                make.left.equalTo(label)
            }
        }
        scrollView.contentSize = CGSize(width: width * CGFloat(labels.count) + self.config.itemMargin, height: self.frame.height)
    }
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isUserInteractionEnabled = false
        return scrollView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 12.0/16.0
        return label
    }()
    
    lazy var symbolLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    lazy var delayLabel: QMUILabel = {
        let label = QMUILabel()
        label.text = YXLanguageUtility.kLang(key: "common_delay")
        label.font = .systemFont(ofSize: 8)
        label.textColor = QMUITheme().textColorLevel3()
        label.backgroundColor = QMUITheme().separatorLineColor()
        label.layer.cornerRadius = 1.0
        label.layer.masksToBounds = true
        label.contentEdgeInsets = UIEdgeInsets(top: 1, left: 2, bottom: 1, right: 2)
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

