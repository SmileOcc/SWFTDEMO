//
//  YXHKADRCell.swift
//  uSmartOversea
//
//  Created by youxin on 2019/12/20.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class YXHKADRItemView: UIView {
    lazy var topLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = QMUITheme().textColorLevel1()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        label.textAlignment = .right
        return label
    }()
    
    lazy var bottomLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel3()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        label.textAlignment = .right
        return label
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView.init()
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.distribution = .fill
        stackView.alignment = .trailing
        return stackView
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        stackView.addArrangedSubview(topLabel)
        stackView.addArrangedSubview(bottomLabel)
        
        addSubview(stackView)
        
        stackView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class YXHKADRCell: UITableViewCell, HasDisposeBag {
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
        
        if self.rankType == .adr {
            stockInfoView.name = model.chsNameAbbr ?? "--"
            stockInfoView.symbol = model.secuCode ?? "--"
            stockInfoView.market = model.trdMarket
        }else if self.rankType == .ah {
            stockInfoView.name = model.hNameAbbr ?? "--"
            stockInfoView.symbol = model.secuCode ?? "--"
        }
        
        for item in self.items {
            item.topLabel.text = "--"
            if let sortType = YXStockRankSortType.init(rawValue: item.tag) {
                if sortType == .adrHKCode {
                    item.bottomLabel.isHidden = true
                    if let code = model.secuCode, let market = model.trdMarket {
                        item.topLabel.text = "\(code).\(market.uppercased())"
                        
                    }else {
                        item.topLabel.text = "--"
                    }
                    
                }else {
                    setLabelText(type: sortType, item: item, model: model)
                }
                
            }
        }
        
        showLine = !isLast
        linePatternLayer?.isHidden = isLast
    }
    
    func setLabelText(type: YXStockRankSortType, item: YXHKADRItemView, model:YXMarketRankCodeListInfo) {
        
        item.topLabel.isHidden = false
        item.bottomLabel.font = .systemFont(ofSize: 12)
        
        var latestPrice: Int?
        var pctChng: Int?
        
        switch type {
            
        
        case .adrPrice, .hStock:
            latestPrice = model.latestPrice
            pctChng = model.pctChng
            
        case .adrExchangePrice: //ADR换算价
            latestPrice = model.adrExchangePrice
            pctChng = model.adrPctchng
            
        case .adrPriceSpread: //相对港股
            
            latestPrice = model.adrPriceSpread
            pctChng = model.adrPriceSpreadRate
            
        case .aStock:
            latestPrice = model.ahLastestPrice
            pctChng = model.ahPctchng
            
        case .ahSpread:
            item.topLabel.isHidden = true
            item.bottomLabel.font = .systemFont(ofSize: 16)
            latestPrice = model.ahPriceSpread
            pctChng = model.ahPriceSpreadRate
            
        default:
            break
        }
        
        
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
        
        // AH股的溢价不需要跟随涨跌色，固定为一级文字颜色
        if type == .ahSpread {
            item.bottomLabel.textColor = QMUITheme().textColorLevel1()
        }
        
        if let pctChng = pctChng {
            item.bottomLabel.text = op + String(format: "%.2f%%", Double(pctChng)/100.0)
        }else {
            item.bottomLabel.text = "--"
        }
        
        if let now = latestPrice, let priceBase = model.priceBase {
            if type == .adrPriceSpread {
                item.topLabel.text = op + String(format: "%.\(priceBase)f", Double(now)/Double(pow(10.0, Double(priceBase))))
            }else {
                item.topLabel.text = String(format: "%.\(priceBase)f", Double(now)/Double(pow(10.0, Double(priceBase))))
            }
            
        } else {
            item.topLabel.text = "--";
        }
        
    }
    
    //MARK: initialization Method
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, sortTypes: [YXStockRankSortType], config: YXNewStockMarketConfig) {
        
        self.sortTypes = sortTypes
        self.config = config
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
//        self.addGestureRecognizer(scrollView.panGestureRecognizer)
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
    
//    lazy var nameLabel: UILabel = {
//        let label = UILabel()
////        label.numberOfLines = 2
//        label.textColor = QMUITheme().textColorLevel1()
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.adjustsFontSizeToFitWidth = true
//        label.minimumScaleFactor = 12.0 / 14.0
//        return label
//    }()
//
//    lazy var symbolLabel: QMUILabel = {
//        let label = QMUILabel()
//        label.font = .systemFont(ofSize: 12)
//        label.textColor = QMUITheme().textColorLevel3()
//        return label
//    }()
//
//    private lazy var delayLabel: QMUILabel = {
//        let label = QMUILabel()
//        label.text = YXLanguageUtility.kLang(key: "common_delay")
//        label.font = .systemFont(ofSize: 10)
//        label.textColor = QMUITheme().textColorLevel3()
//        label.backgroundColor = QMUITheme().separatorLineColor()
//        label.isHidden = true
//        label.contentEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
//        return label
//    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
