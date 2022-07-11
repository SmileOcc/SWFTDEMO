//
//  YXNewStockMarketedCell.swift
//  uSmartOversea
//
//  Created by youxin on 2019/4/8.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXNewStockMarketedCell: UITableViewCell {
    
    var labels =  [UILabel]()
    var sortTypes: [YXStockRankSortType]
    fileprivate var linePatternLayer: CALayer?
    fileprivate var showLine: Bool = true
    var isDelay: Bool = false
    var config: YXNewStockMarketConfig
    
//    override func draw(_ rect: CGRect) {
//
//        DispatchQueue.main.async {
//            if  self.linePatternLayer == nil {
//                self.linePatternLayer = YXDrawHelper.drawDashLine(superView: self.contentView, strokeColor: QMUITheme().dashLineColor(withAlpha: 0.07), topMargin:self.contentView.frame.height - 2, lineHeight: 1, leftMargin: self.config.itemMargin, rightMargin: 2)
//                self.linePatternLayer?.isHidden = !self.showLine
//            }
//        }
//    }
    
    func refreshUI(model: YXMarketRankCodeListInfo, isLast: Bool) {
        
        stockInfoView.name = model.chsNameAbbr
        stockInfoView.symbol = model.secuCode
        stockInfoView.market = model.trdMarket
        
        for label in self.labels {
            label.text = "--"
            if let sortType = YXStockRankSortType.init(rawValue: label.tag) {
                setLabelText(type: sortType, label: label, model: model, priceBase: Double(model.priceBase ?? 0))
            }
        }
        
        // 延时
        stockInfoView.delayLabel.isHidden = !isDelay
        
        showLine = !isLast
        linePatternLayer?.isHidden = isLast
    }
    
    func setLabelText(type: YXStockRankSortType, label: UILabel, model:YXMarketRankCodeListInfo, priceBase: Double) {
        switch type {
        case .listDate: //上市日期
            if let listDate = model.listDate {
//                let dateModel = YXDateToolUtility.dateTime(withTime: String(listDate))
//                label.text = String(format: "%@-%@-%@", dateModel.year, dateModel.month, dateModel.day)
                label.text = YXDateHelper.commonDateStringWithNumber(UInt64(listDate))
            }
        case .issuePrice: //发行价
            if let issuePrice = model.issuePrice {
                label.text = String(format: "%0.3f", Double(issuePrice) / pow(10, priceBase))
            }
        case .now: //最新价
            if let latestPrice = model.latestPrice {
                label.text = String(format: "%0.3f", Double(latestPrice) / pow(10, priceBase))
            }
            if self.sortTypes.contains(.totalRoc) {
                label.textColor = YXStockColor.currentColor(model.accuPctchng != nil ? Double(model.accuPctchng!) : 0.0)
            } else {
                label.textColor = YXStockColor.currentColor(model.pctChng != nil ? Double(model.pctChng!) : 0.0)
            }
        case .totalRoc: //累计涨幅
            if let accuPctchng = model.accuPctchng {
                label.text = String(format: "%@%.2lf%%", accuPctchng > 0 ? "+" : "", Double(accuPctchng) / 100.0)
            }
            label.textColor = YXStockColor.currentColor(model.accuPctchng != nil ? Double(model.accuPctchng!) : 0.0)
        case .listedDays: //上市天数
            if let listDays = model.listDays {
                label.text = String(format: "%ld", listDays)
            }
        case .firstDayClosePrice: //首日收盘
            if let ipoDayColse = model.ipoDayClose {
                label.text = String(format: "%0.3f", Double(ipoDayColse) / pow(10, priceBase))
            }
            label.textColor = YXStockColor.currentColor(model.ipoDayPctchng != nil ? Double(model.ipoDayPctchng!) : 0.0)
        case .firstDayRoc:
            if let ipoDayPctchng = model.ipoDayPctchng {
                label.text = String(format: "%@%.2lf%%", ipoDayPctchng > 0 ? "+" : "", Double(ipoDayPctchng) / 100.0)
            }
            label.textColor = YXStockColor.currentColor(model.ipoDayPctchng != nil ? Double(model.ipoDayPctchng!) : 0.0)
        case .roc, .preRoc, .afterRoc:
            if let pctchng = model.pctChng {
                label.text = String(format: "%@%.2lf%%", pctchng > 0 ? "+" : "", Double(pctchng) / 100.0)
            }
            label.textColor = YXStockColor.currentColor(model.pctChng != nil ? Double(model.pctChng!) : 0.0)
        case .change:
            if let netchng = model.netChng {
                label.text = String(format: "%@%0.3f", netchng > 0 ? "+" : "", Double(netchng) / pow(10, priceBase))
            }
            label.textColor = YXStockColor.currentColor(model.pctChng != nil ? Double(model.pctChng!) : 0.0)
        case .volume:
            if let volume = model.volume {
                var unit = YXLanguageUtility.kLang(key: "stock_unit_en")
                if model.trdMarket == kYXMarketUsOption {
                    unit = YXLanguageUtility.kLang(key: "options_page")
                }
                label.text = YXToolUtility.stockData(Double(volume), deciPoint: 2, stockUnit: unit, priceBase: 0)
            }
        case .amount:
            if let trunover = model.turnover {
                label.text = YXToolUtility.stockData(Double(trunover), deciPoint: 2, stockUnit: "", priceBase: model.priceBase ?? 0)
            }
        case .turnoverRate:
            
            if let turnoverRate = model.turnoverRate {
                label.text = String(format: "%.2lf%%", Double(turnoverRate) / 100.0)
            } else {
                label.text = "0.00%"
            }
        case .volumeRatio:
            if let volRatio = model.volRatio {
                label.text = YXToolUtility.stockData(Double(volRatio), deciPoint: 2, stockUnit: "", priceBase: 4)
            }
        case .amp:
            if let amplitude = model.amplitude {
                label.text = String(format: "%.2lf%%", Double(amplitude) / 100.0)
            } else {
                label.text = "0.00%"
            }
        case .marketValue:
            if let totalMarketValue = model.totalMarketValue {
                label.text = YXToolUtility.stockData(Double(totalMarketValue), deciPoint: 2, stockUnit: "", priceBase: model.priceBase ?? 0)
            }
        case .pe:
            if let pe = model.peStatic {
                if pe < 0 {
                    label.text = YXLanguageUtility.kLang(key: "stock_detail_loss")
                } else {
                    label.text = YXToolUtility.stockData(Double(pe), deciPoint: 2, stockUnit: "", priceBase: 4)
                }
            }
        case .pb:
            label.text = YXToolUtility.stockData(Double(model.pb ?? 0), deciPoint: 2, stockUnit: "", priceBase: 4)
        case .accer3:
            var op = ""
            if let accer3 = model.accer3, accer3 > 0 {
                op = "+"
                label.textColor = QMUITheme().stockRedColor()
            } else if let accer3 = model.accer3, accer3 < 0 {
                label.textColor = QMUITheme().stockGreenColor()
            } else {
                label.textColor = QMUITheme().stockGrayColor()
            }
            label.text = op + String(format: "%.2f%%", Double(model.accer3 ?? 0)/100.0)
        case .accer5:
            var op = ""
            if let accer5 = model.accer5, accer5 > 0 {
                op = "+"
                label.textColor = QMUITheme().stockRedColor()
            } else if let accer5 = model.accer5, accer5 < 0 {
                label.textColor = QMUITheme().stockGreenColor()
            } else {
                label.textColor = QMUITheme().stockGrayColor()
            }
            label.text = op + String(format: "%.2f%%", Double(model.accer5 ?? 0)/100.0)
        case .netInflow:
            if let netInflow = model.netInflow {
                label.attributedText = YXToolUtility.stocKNumberData(netInflow, deciPoint: 2, stockUnit: "", priceBase: model.priceBase ?? 0, number: .systemFont(ofSize: 16), unitFont: .systemFont(ofSize: 16))
            }
        case .mainInflow:
            if let mainInflow = model.mainInflow {
                label.attributedText = YXToolUtility.stocKNumberData(mainInflow, deciPoint: 2, stockUnit: "", priceBase: model.priceBase ?? 0, number: .systemFont(ofSize: 16), unitFont: .systemFont(ofSize: 16))
            }
        case .dividendYield:
            let text = String(format: "%.2f%%", Double(model.dividendYield ?? 0)/100.0)
            label.attributedText = NSAttributedString.init(string: text)
        case .marginRatio:
            let text = String(format: "%.2f%%", model.marginRatio ?? 0)
            label.attributedText = NSAttributedString.init(string: text)
        case .bail:
            if let bail = model.bail {
                label.text = String(format: "%0.3f", Double(bail) / pow(10, priceBase))
            }
        case .greyChgPct:
            if let greyChgPct = model.greyChgPct {
                label.text = String(format: "%@%.2lf%%", greyChgPct > 0 ? "+" : "", Double(greyChgPct) / 100.0)
            }
            label.textColor = YXStockColor.currentColor(model.greyChgPct != nil ? Double(model.greyChgPct!) : 0.0)
        case .winningRate:
            let text = String(format: "%.2f%%", Double(model.winningRate ?? 0)/100.0)
            label.attributedText = NSAttributedString.init(string: text)
        case .gearingRatio:
            if let gearingRatio = model.gearingRatio {
                label.text = String(format: "%dX", gearingRatio)
            }else {
                label.text = "--"
            }
        case .preAndClosePrice:
            //盘前价
            let textColor = YXStockColor.currentColor(model.pctChng != nil ? Double(model.pctChng!) : 0.0)
            var price = "--"
            if let latestPrice = model.latestPrice {
                price = String(format: "%0.3f", Double(latestPrice) / pow(10, priceBase))
            }
            //收盘价
            var closePrice = "--"
            if let prevClose = model.prevClose {
                closePrice = String(format: "%0.3f", Double(prevClose) / pow(10, priceBase))
            }
            price = price + "\n"
            let topString = NSMutableAttributedString.init(string: price, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor : textColor])
            let bottom = NSMutableAttributedString.init(string: closePrice, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1()])
            topString.append(bottom)
            label.numberOfLines = 2
            label.attributedText = topString
        case .afterAndClosePrice:
            //盘前价
            let textColor = YXStockColor.currentColor(model.pctChng != nil ? Double(model.pctChng!) : 0.0)
            var price = "--"
            if let latestPrice = model.latestPrice {
                price = String(format: "%0.3f", Double(latestPrice) / pow(10, priceBase))
            }
            //收盘价
            var closePrice = "--"
            if let close = model.closePrice {
                closePrice = String(format: "%0.3f", Double(close) / pow(10, priceBase))
            }
            price = price + "\n"
            let topString = NSMutableAttributedString.init(string: price, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor : textColor])
            let bottom = NSMutableAttributedString.init(string: closePrice, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1()])
            topString.append(bottom)
            label.numberOfLines = 2
            label.attributedText = topString
        case .bid:
            if let bid = model.bid {
                label.text = String(format: "%0.3f", Double(bid) / pow(10, priceBase))
            }
        case .bidSize:
            if let volume = model.bidSize {
                var unit = YXLanguageUtility.kLang(key: "stock_unit_en")
                label.text = YXToolUtility.stockData(Double(volume), deciPoint: 2, stockUnit: unit, priceBase: 0)
            }
        case .ask:
            if let ask = model.ask {
                label.text = String(format: "%0.3f", Double(ask) / pow(10, priceBase))
            }
        case .askSize:
            if let volume = model.askSize {
                var unit = YXLanguageUtility.kLang(key: "stock_unit_en")
                label.text = YXToolUtility.stockData(Double(volume), deciPoint: 2, stockUnit: unit, priceBase: 0)
            }
        case .cittthan:
            if let cittthan = model.cittthan {
                label.text = String(format: "%.2lf%%", Double(cittthan) / 100.0)
            } else {
                label.text = "0.00%"
            }
        case .currency:
            if let currency = model.currency {
                label.text = currency
            } else {
                label.text = "--"
            }
        case .expiryDate:
            if let expiryDate = model.expiryDate {
                label.text =  YXDateHelper.commonDateStringWithNumber(UInt64(expiryDate), format: .DF_MDY)
            } else {
                label.text = "--"
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
        contentView.addSubview(stockInfoView)
//        contentView.addSubview(nameLabel)
//        contentView.addSubview(symbolLabel)
//        contentView.addSubview(delayLabel)
        contentView.addSubview(scrollView)
        
        stockInfoView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(self.config.leftItemWidth)
        }
        
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
        
        scrollView.snp.makeConstraints { (make) in
            make.top.bottom.right.equalToSuperview()
            make.left.equalToSuperview().offset(self.config.leftItemWidth + self.config.fixMargin)
        }

        let width = self.config.itemWidth
        for (index, type) in sortTypes.enumerated() {
            let label = UILabel()
            label.textColor = QMUITheme().textColorLevel1()
            label.font = UIFont.systemFont(ofSize: 16)
            label.textAlignment = .right
            label.tag = type.rawValue
            
            labels.append(label)
            scrollView.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.width.equalTo(width - 2)
                make.left.equalToSuperview().offset(width * CGFloat(index))
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
