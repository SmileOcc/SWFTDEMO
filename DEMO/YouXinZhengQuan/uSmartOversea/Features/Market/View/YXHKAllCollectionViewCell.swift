//
//  YXHKAllCollectionViewCell.swift
//  uSmartOversea
//
//  Created by youxin on 2020/3/2.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class YXHKAllCollectionViewCell: UICollectionViewCell, HasDisposeBag {
    
    // 第三列的类型
    var additionalType: YXStockRankSortType = .roc
    
    // 是否展示第三列
    @objc var isShowAdditionalType: Bool = false
    
    lazy var stockInfoView: YXStockBaseinfoView = {
        return YXStockBaseinfoView()
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .right
        return label
    }()
    
    private lazy var rocLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    var level: Int? {
        didSet {
            if let l = level, l == 0 {
                stockInfoView.delayLabel.isHidden = false
            }else {
                stockInfoView.delayLabel.isHidden = true
            }
        }
    }
    
    var model: YXMarketRankCodeListInfo? = nil  {
        didSet {
            if let obj = model {
                stockInfoView.name = obj.chsNameAbbr
                stockInfoView.symbol = obj.secuCode
                stockInfoView.market = obj.trdMarket
                
                if let price = obj.latestPrice, let priceBase = obj.priceBase, price > 0 {
                    priceLabel.text = String(format: "%.\(priceBase)f", Double(price)/Double(pow(10.0, Double(priceBase))))
                } else {
                    priceLabel.text = "--";
                }
                
                priceLabel.textColor = QMUITheme().stockGrayColor()
                rocLabel.textColor = QMUITheme().stockGrayColor()
                
                var op = ""
                var color  = QMUITheme().stockGrayColor()
                
                if let roc = obj.pctChng, roc > 0 {
                    op = "+"
                    color = QMUITheme().stockRedColor()
                } else if let change = obj.netChng, change < 0 {
                    color = QMUITheme().stockGreenColor()
                } else {
                    color = QMUITheme().stockGrayColor()
                }
                
                priceLabel.textColor = color
                
                switch additionalType {
                case .roc:
                    rocLabel.text = op + String(format: "%.2f%%", Double(obj.pctChng ?? 0)/100.0)
                    rocLabel.textColor = color
                case .accer3:
                    var op = ""
                    if let accer3 = obj.accer3, accer3 > 0 {
                        op = "+"
                        rocLabel.textColor = QMUITheme().stockRedColor()
                    } else if let accer3 = obj.accer3, accer3 < 0 {
                        rocLabel.textColor = QMUITheme().stockGreenColor()
                    } else {
                        rocLabel.textColor = QMUITheme().stockGrayColor()
                    }
                    rocLabel.text = op + String(format: "%.2f%%", Double(obj.accer3 ?? 0)/100.0)
                case .accer5:
                    var op = ""
                    if let accer5 = obj.accer5, accer5 > 0 {
                        op = "+"
                        rocLabel.textColor = QMUITheme().stockRedColor()
                    } else if let accer5 = obj.accer5, accer5 < 0 {
                        rocLabel.textColor = QMUITheme().stockGreenColor()
                    } else {
                        rocLabel.textColor = QMUITheme().stockGrayColor()
                    }
                    rocLabel.text = op + String(format: "%.2f%%", Double(obj.accer5 ?? 0)/100.0)
                case .volume:
                    if let volume = obj.volume {
                        rocLabel.text = YXToolUtility.stockData(Double(volume), deciPoint: 2, stockUnit: YXLanguageUtility.kLang(key: "stock_unit_en"), priceBase: 0)
                    }
                case .amount:
                    if let trunover = obj.turnover {
                        rocLabel.text = YXToolUtility.stockData(Double(trunover), deciPoint: 2, stockUnit: "", priceBase: obj.priceBase ?? 0)
                    }
                case .mainInflow:
                    if let mainInflow = obj.mainInflow {
                        rocLabel.attributedText = YXToolUtility.stocKNumberData(mainInflow, deciPoint: 2, stockUnit: "", priceBase: obj.priceBase ?? 0, number: .systemFont(ofSize: 16), unitFont: .systemFont(ofSize: 16))
                    }
                    
                case .netInflow:
                    if let netInflow = obj.netInflow {
                        rocLabel.attributedText = YXToolUtility.stocKNumberData(netInflow, deciPoint: 2, stockUnit: "", priceBase: obj.priceBase ?? 0, number: .systemFont(ofSize: 16), unitFont: .systemFont(ofSize: 16))
                    }
                    
                case .turnoverRate:
                    if let turnoverRate = obj.turnoverRate {
                        rocLabel.text = String(format: "%.2lf%%", Double(turnoverRate) / 100.0)
                    } else {
                        rocLabel.text = "0.00%"
                    }
                case .marketValue:
                    if let totalMarketValue = obj.totalMarketValue {
                        rocLabel.text = YXToolUtility.stockData(Double(totalMarketValue), deciPoint: 2, stockUnit: "", priceBase: obj.priceBase ?? 0)
                    }
                case .pe:
                    if let pe = obj.peStatic {
                        if pe < 0 {
                            rocLabel.text = YXLanguageUtility.kLang(key: "stock_detail_loss")
                        } else {
                            rocLabel.text = YXToolUtility.stockData(Double(pe), deciPoint: 2, stockUnit: "", priceBase: 4)
                        }
                    }
                case .pb:
                    rocLabel.text = YXToolUtility.stockData(Double(obj.pb ?? 0), deciPoint: 2, stockUnit: "", priceBase: 4)
                case .dividendYield:
                    let text = String(format: "%.2f%%", Double(obj.dividendYield ?? 0)/100.0)
                    rocLabel.text = text
                case .volumeRatio:
                    if let volRatio = obj.volRatio {
                        rocLabel.text = YXToolUtility.stockData(Double(volRatio), deciPoint: 2, stockUnit: "", priceBase: 4)
                    }
                case .amp:
                    if let amplitude = obj.amplitude {
                        rocLabel.text = String(format: "%.2lf%%", Double(amplitude) / 100.0)
                    } else {
                        rocLabel.text = "0.00%"
                    }
                default:
                    break
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = QMUITheme().foregroundColor()
        initializeViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func initializeViews() {
//        contentView.addSubview(marketIconView)
        contentView.addSubview(stockInfoView)
        contentView.addSubview(priceLabel)
        contentView.addSubview(rocLabel)
//        contentView.addSubview(otherLabel)
        
//        marketIconView.snp.makeConstraints { (make) in
//            make.left.equalTo(self).offset(4)
//            make.top.equalTo(self).offset(16)
//        }
        
        stockInfoView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.bottom.equalToSuperview()
            make.right.equalTo(priceLabel.snp.left).offset(-5)
        }
        rocLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-16)
            make.centerY.equalTo(self)
            make.left.greaterThanOrEqualTo(priceLabel.snp.right).offset(3)
        }
        
        priceLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-130)
            make.centerY.equalTo(self)
        }
        
//        otherLabel.snp.makeConstraints { (make) in
//            make.right.equalTo(self).offset(-20)
//            make.centerY.equalTo(self)
//            make.width.lessThanOrEqualTo(80)
//        }
        
    }
}
