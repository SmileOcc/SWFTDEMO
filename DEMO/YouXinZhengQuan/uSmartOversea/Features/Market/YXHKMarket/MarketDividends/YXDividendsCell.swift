//
//  YXDividendsCell.swift
//  uSmartOversea
//
//  Created by lennon on 2022/5/19.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class YXDividendsCell: UITableViewCell, HasDisposeBag {
    var rankType: YXRankType = .adr
    var items =  [YXHKADRItemView]()
    var sortTypes: [YXStockRankSortType]
    fileprivate var linePatternLayer: CALayer?
    fileprivate var showLine: Bool = true
    var isDelay: Bool = false
    var tapHKCodeAction: (() -> Void)?
    var clickCellAction: (() -> Void)?
    
    var config: YXNewStockMarketConfig
    
    
    func refreshUI(model: YXMarketRankCodeListInfo, isLast: Bool) {
        
        stockInfoView.delayLabel.isHidden = !isDelay
        stockInfoView.name = model.chsNameAbbr ?? "--"
        stockInfoView.symbol = model.secuCode ?? "--"
        stockInfoView.market = model.trdMarket
        
        for item in self.items {
            item.topLabel.text = "--"
            if let sortType = YXStockRankSortType.init(rawValue: item.tag) {
                setLabelText(type: sortType, item: item, model: model)
            }
        }
        
        showLine = !isLast
        linePatternLayer?.isHidden = isLast
    }
    
    func setLabelText(type: YXStockRankSortType, item: YXHKADRItemView, model:YXMarketRankCodeListInfo) {
        
        guard let priceBase = model.priceBase else { return }
        
        switch type {
            
        case .dividendsPriceChg:
            item.topLabel.isHidden = false
            item.bottomLabel.font = .systemFont(ofSize: 12)
            let latestPrice = model.latestPrice
            let pctChng = model.pctChng
            var op = ""
            if let roc = pctChng, roc > 0 {
                op = "+"
                item.topLabel.textColor = QMUITheme().stockRedColor()
                item.bottomLabel.textColor = QMUITheme().stockRedColor()
            } else if let roc = pctChng, roc < 0 {
                item.topLabel.textColor = QMUITheme().stockGreenColor()
                item.bottomLabel.textColor = QMUITheme().stockGreenColor()
            } else {
                item.topLabel.textColor = QMUITheme().stockGrayColor()
                item.bottomLabel.textColor = QMUITheme().stockGrayColor()
            }
            
            if let pctChng = pctChng {
                item.bottomLabel.text = op + String(format: "%.2f%%", Double(pctChng)/100.0)
            }else {
                item.bottomLabel.text = "--"
            }
            
            if let now = latestPrice {
                item.topLabel.text = String(format: "%.\(priceBase)f", Double(now)/Double(pow(10.0, Double(priceBase))))
            } else {
                item.topLabel.text = "--"
            }
            
        case .dividendsRate:
            
            item.bottomLabel.isHidden = true
            
            if let value = model.divAmountYear, value > 0 {
                let valueString = YXToolUtility.stockPriceData(Double(value), deciPoint: priceBase, priceBase: priceBase)
                item.topLabel.text = valueString
            } else {
                item.topLabel.text =  "--"
            }
            
            
        case .dividendsYield:
            item.bottomLabel.isHidden = true
            item.topLabel.text = ""
            if let yieldRatio = model.divYieldYear, yieldRatio > 0 {
//                let yieldString = String.init(format: "%.2f%@", Double(yieldRatio)/100, "%")
                let yieldString = YXToolUtility.stockPercentDataNoPositive(Double(yieldRatio), priceBasic: priceBase, deciPoint: 2) ?? "0.00"
                item.topLabel.text = yieldString
            } else {
                item.topLabel.text =  "--"
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
        initializeViews()
    }
    
    func initializeViews() {
        backgroundColor = QMUITheme().foregroundColor()
        contentView.addSubview(stockInfoView)
        contentView.addSubview(scrollView)
        
        stockInfoView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.bottom.equalToSuperview()
            make.width.lessThanOrEqualTo(self.config.leftItemWidth - self.config.fixMargin)
        }
        
        scrollView.snp.makeConstraints { (make) in
            make.top.bottom.right.equalToSuperview()
            make.left.equalToSuperview().offset(self.config.leftItemWidth + self.config.fixMargin)
        }
        
        
        let width = self.config.itemWidth
        for (index, type) in sortTypes.enumerated() {
            let item = YXHKADRItemView()
            item.tag = type.rawValue
            
            if type == .adrHKCode {
                let tap = UITapGestureRecognizer.init { [weak self](tap) in
                    if let action = self?.tapHKCodeAction {
                        action()
                    }
                }
                item.addGestureRecognizer(tap)
            }
            
            items.append(item)
            scrollView.addSubview(item)
            item.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.width.equalTo(width - 2)
                make.left.equalToSuperview().offset(width * CGFloat(index))
            }
        }
        scrollView.contentSize = CGSize(width: width * CGFloat(items.count), height: self.frame.height)
        
        let tap = UITapGestureRecognizer.init { [weak self](tap) in
            if let action = self?.clickCellAction {
                action()
            }
        }
        addGestureRecognizer(tap)
    }
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    lazy var stockInfoView: YXStockBaseinfoView = {
        return YXStockBaseinfoView()
    }()
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
