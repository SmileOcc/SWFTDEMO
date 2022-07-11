//
//  YXWarrantsTableViewCell.swift
//  uSmartOversea
//
//  Created by 井超 on 2019/8/3.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXWarrantsTableViewCell: UITableViewCell {

    var labels =  [UILabel]()
    var sortTypes: [YXStockRankSortType]
    var config: YXNewStockMarketConfig
    fileprivate var linePatternLayer: CALayer?
    fileprivate var showLine: Bool = true
    var isDelay: Bool = false
    
//    override func draw(_ rect: CGRect) {
//
//        DispatchQueue.main.async {
//            if  self.linePatternLayer == nil {
//                self.linePatternLayer = YXDrawHelper.drawDashLine(superView: self.contentView, strokeColor: QMUITheme().dashLineColor(withAlpha: 0.07), topMargin:self.contentView.frame.height - 2, lineHeight: 1, leftMargin: self.config.itemMargin, rightMargin: 2)
//                self.linePatternLayer?.isHidden = !self.showLine
//            }
//        }
//    }
    
    func refreshUI(model: YXWarrantsDetailModel, market:String, isLast: Bool) {
        
        stockInfoView.name = model.name ?? "--"
        stockInfoView.symbol = model.code ?? "--"
        stockInfoView.market = market
        
        for label in self.labels {
            label.text = "--"
            if let sortType = YXStockRankSortType.init(rawValue: label.tag) {
                setLabelText(type: sortType, label: label, model: model, priceBase: Double(4))
            }
        }
        
        // 延时
        stockInfoView.delayLabel.isHidden = !isDelay
        
        showLine = !isLast
        linePatternLayer?.isHidden = isLast
    }
    
    func setLabelText(type: YXStockRankSortType, label: UILabel, model:YXWarrantsDetailModel, priceBase: Double) {
        switch type {
        case .warrantsNow: //最新价
            if let latestPrice = model.latestPrice {
                if latestPrice != 0 {
                    label.text = String(format: "%0.3f", Double(latestPrice) / pow(10, priceBase))
                } else {
                    label.text = "--"
                }
            } else {
                label.text = "--"
            }
            label.textColor = YXStockColor.currentColor(model.priceChangeRate != nil ? Double(model.priceChangeRate!) : 0.0)
            
        case .roc: //涨跌幅
            if let roc = model.priceChangeRate {
                label.text = String(format: "%@%.2lf%%", roc > 0 ? "+" : "", Double(roc) / 100.0)
            } else {
                label.text = "0.00%"
            }
            label.textColor = YXStockColor.currentColor(model.priceChangeRate != nil ? Double(model.priceChangeRate!) : 0.0)
            
        case .yxScore:
            if let score = model.score {
                label.text = "\(score)"
            }else {
                label.text = "--"
            }
            
        case .change: //涨跌额
            if let change = model.priceChange {
                label.text = String(format: "%@%0.3f", change > 0 ? "+" : "", Double(change) / pow(10, priceBase))
            } else {
                label.text = "0.000"
            }
            label.textColor = YXStockColor.currentColor(model.priceChange != nil ? Double(model.priceChange!) : 0.0)
            
        case .volume: //成交量
            if let volume = model.volume {
                label.text = YXToolUtility.stockData(Double(volume), deciPoint: 2, stockUnit: YXLanguageUtility.kLang(key: "stock_unit_en"), priceBase: 0)
            } else {
                label.text = YXToolUtility.stockData(Double(0), deciPoint: 2, stockUnit: YXLanguageUtility.kLang(key: "stock_unit_en"), priceBase: 0)
            }
            
        case .amount: //成交额
            if let turnover = model.turnover {
                label.text = YXToolUtility.stockData(Double(turnover), deciPoint: 2, stockUnit: "", priceBase: Int(priceBase))
            } else {
                label.text = "0.00"
            }
            
        case .endDate: //到期日期
            if let listDate = model.expireDate {
                if listDate != 0 {
                    
                    label.text = YXDateHelper.commonDateStringWithNumber(UInt64(listDate))
                } else {
                    label.text = "--"
                }
            } else {
                label.text = "--"
            }
            
        case .premium: //溢价
            if let premium = model.premium {
                label.text = String(format: "%.2lf%%", Double(premium) / 100.0)
            } else {
                label.text = "0.00%"
            }
            
        case .outstandingRatio: //街货比
            if let outstandingRatio = model.outstandingRatio {
                label.text = String(format: "%.2lf%%", Double(outstandingRatio) / pow(10, priceBase))
            } else {
                label.text = "0.00%"
            }
            
        case .leverageRatio: //杠杆比率
            if let leverageRatio = model.leverageRatio {
                label.text = String(format: "%.2lf", Double(leverageRatio) / pow(10, priceBase))
            } else {
                label.text = "0.00"
            }
        case .exchangeRatio: //换股比率
            if let exchangeRatio = model.exchangeRatio {
                label.text = String(format: "%.2lf", Double(exchangeRatio) / pow(10, priceBase))
            } else {
                label.text = "0.00"
            }
        case .strikePrice:
            if let strikePrice = model.strikePrice {
                if strikePrice != 0 {
                    label.text = String(format: "%.3lf", Double(strikePrice) / pow(10, priceBase))
                } else {
                    label.text = "--"
                }
            } else {
                label.text = "--"
            }
        case .moneyness:
            if let moneyness = model.moneyness {
                label.text = String(format: "%0.2f%%", Double(moneyness) / 100)
            } else {
                label.text = "0.00%"
            }
        case .impliedVolatility:
            if let impliedVolatility = model.impliedVolatility, impliedVolatility != 0 {
                label.text = String(format: "%0.2f", Double(impliedVolatility) / pow(10, priceBase))
            } else {
                label.text = "--"
            }
        case .actualLeverage:
            if let effectiveLeverage = model.effectiveLeverage, effectiveLeverage != 0 {
                label.text = String(format: "%0.2f", Double(effectiveLeverage) / pow(10, priceBase))
            } else {
                label.text = "--"
            }
        case .callPrice:
            if let callPrice = model.callPrice, callPrice != 0 {
                label.text = String(format: "%0.3f", Double(callPrice) / pow(10, priceBase))
            } else {
                label.text = "--"
            }
        case .toCallPrice:
            if let toCallPrice = model.toCallPrice, toCallPrice != 0 {
                label.text = String(format: "%.2lf%%", Double(toCallPrice) / 100.0)
            } else {
                label.text = "--"
            }
        case .lowerStrike:
            if let pricelFoor = model.pricelFoor, pricelFoor != 0 {
                label.text = String(format: "%0.3f", Double(pricelFoor) / pow(10, priceBase))
            } else {
                label.text = "--"
            }
        case .upperStrike:
            if let priceCeiling = model.priceCeiling, priceCeiling != 0 {
                label.text = String(format: "%0.3f", Double(priceCeiling) / pow(10, priceBase))
            } else {
                label.text = "--"
            }
        case .toLowerStrike:
            if let toPriceFloor = model.toPriceFloor {
                label.text = String(format: "%.2lf%%", Double(toPriceFloor) / 100.0)
            } else {
                label.text = "--"
            }
        case .toUpperStrike:
            if let toPriceCeiling = model.toPriceCeiling {
                label.text = String(format: "%.2lf%%", Double(toPriceCeiling) / 100.0)
            } else {
                label.text = "--"
            }
        case .bidSize:
            if let volume = model.bidSize {
                var unit = YXLanguageUtility.kLang(key: "stock_unit_en")
                label.text = YXToolUtility.stockData(Double(volume), deciPoint: 2, stockUnit: unit, priceBase: 0)
            }

        case .askSize:
            if let volume = model.askSize {
                var unit = YXLanguageUtility.kLang(key: "stock_unit_en")
                label.text = YXToolUtility.stockData(Double(volume), deciPoint: 2, stockUnit: unit, priceBase: 0)
            }
        case .delta:
            if let delta = model.delta {
                label.text = String(format: "%.3lf", delta)
            }
        case .status:
            if let status = model.status {
                label.text = "\(status)"
            }

        default:
            break
        }
    }
    
    //MARK: initialization Method
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, sortTypes: [YXStockRankSortType], config: YXNewStockMarketConfig) {
        
        self.sortTypes = sortTypes
        self.config = config
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        contentView.addGestureRecognizer(scrollView.panGestureRecognizer)
        initializeViews()
    }
    
    func initializeViews() {
        backgroundColor = QMUITheme().foregroundColor()
//        contentView.addSubview(nameLabel)
//        contentView.addSubview(symbolLabel)
//        contentView.addSubview(delayLabel)
        contentView.addSubview(stockInfoView)
        contentView.addSubview(scrollView)
        
//        nameLabel.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(self.config.itemMargin)
//            make.top.equalToSuperview().offset(11)
//            make.width.lessThanOrEqualTo(self.config.leftItemWidth - self.config.fixMargin)
//        }
//
//        symbolLabel.snp.makeConstraints { (make) in
//            make.left.equalTo(nameLabel.snp.left)
//            make.bottom.equalToSuperview().offset(-12)
//            make.width.lessThanOrEqualTo(self.config.leftItemWidth - self.config.fixMargin - self.config.itemMargin)
//        }
//
//        delayLabel.snp.makeConstraints { (make) in
//            make.centerY.equalTo(symbolLabel.snp.centerY)
//            make.left.equalTo(symbolLabel.snp.right).offset(6)
//        }
        
        stockInfoView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.bottom.equalToSuperview()
            make.width.lessThanOrEqualTo(self.config.leftItemWidth - self.config.fixMargin)
        }
        
        scrollView.snp.makeConstraints { (make) in
            make.top.bottom.right.equalToSuperview()
            make.left.equalToSuperview().offset(self.config.leftItemWidth + self.config.fixMargin)
        }
        
        var width: CGFloat = self.config.itemWidth
        var totalWidth: CGFloat = 0
        for (index, type) in sortTypes.enumerated() {
            let label = UILabel()
            label.textColor = QMUITheme().textColorLevel1()
            label.font = UIFont.systemFont(ofSize: 16)
            label.textAlignment = .right
            label.tag = type.rawValue
            
            labels.append(label)
            scrollView.addSubview(label)
            
            width = self.config.itemWidth
            if type == .endDate, YXUserManager.isENMode() {
                width = self.config.itemWidth + 20
            } else if type == .yxScore {
                width = self.config.itemWidth - 20
            }
            label.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.width.equalTo(width - 2)
                make.right.equalTo(scrollView.snp.left).offset(width + totalWidth - 2)
            }
            totalWidth += width
        }
        scrollView.contentSize = CGSize(width: totalWidth + self.config.itemMargin, height: self.frame.height)
    }
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isUserInteractionEnabled = false
        return scrollView
    }()
    
    lazy var stockInfoView: YXStockBaseinfoView = {
        return YXStockBaseinfoView()
    }()
    
//    lazy var nameLabel: UILabel = {
//        let label = UILabel()
//        label.textColor = QMUITheme().textColorLevel1()
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.adjustsFontSizeToFitWidth = true
//        label.minimumScaleFactor = 12.0/16.0
//        return label
//    }()
//
//    lazy var symbolLabel: UILabel = {
//        let label = UILabel()
//        label.textColor = QMUITheme().commonTextColor(withAlpha: 0.5)
//        label.font = .systemFont(ofSize: 12)
//        return label
//    }()
//
//    lazy var delayLabel: QMUILabel = {
//        let label = QMUILabel()
//        label.text = YXLanguageUtility.kLang(key: "common_delay")
//        label.font = .systemFont(ofSize: 8)
//        label.textColor = QMUITheme().textColorLevel3()
//        label.backgroundColor = QMUITheme().separatorLineColor()
//        label.layer.cornerRadius = 1.0
//        label.layer.masksToBounds = true
//        label.contentEdgeInsets = UIEdgeInsets(top: 1, left: 2, bottom: 1, right: 2)
//        return label
//    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
