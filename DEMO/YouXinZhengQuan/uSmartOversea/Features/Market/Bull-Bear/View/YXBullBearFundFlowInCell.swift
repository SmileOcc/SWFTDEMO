//
//  YXBullBearFundFlowInCell.swift
//  uSmartOversea
//
//  Created by youxin on 2020/4/8.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXBullBearFundFlowInCell: YXTableViewCell {

    let chartViewMaxWidth = 90/375.0*YXConstant.screenWidth
    var maxFlow: Int64 = 0
    
    var tapStockNameAction: ((_ market: String, _ symbol: String, _ name: String) -> Void)?
    var tapDerivativeOrRocAction: ((_ market: String, _ symbol: String) -> Void)?
    
    var item: YXBullBearFundFlowItem? {
        didSet {
            if let model = item {
                var assetType: String
                switch model.asset?.type {
                case .buy:
                    assetType = YXLanguageUtility.kLang(key: "bullbear_call_mark")//"购"
                case .sell:
                    assetType = YXLanguageUtility.kLang(key: "bullbear_put_mark")//"沽"
                case .bull:
                    assetType = YXLanguageUtility.kLang(key: "bullbear_bull_mark")//"牛"
                case .bear:
                    assetType = YXLanguageUtility.kLang(key: "bullbear_bear_mark")//"熊"
                default:
                    assetType = ""
                }
                nameLabel.text = (model.asset?.name ?? "--") + "(\(assetType))"
                let chartViewWidth = CGFloat(abs(model.asset?.netInflow ?? 0)) / CGFloat(maxFlow) * chartViewMaxWidth
                if maxFlow != 0 {
                    chartView.snp.updateConstraints { (make) in
                        make.width.equalTo(chartViewWidth)
                    }
                }else {
                    chartView.snp.updateConstraints { (make) in
                        make.width.equalTo(0)
                    }
                }
                
                yxselectionLabel.text = model.top?.name ?? YXLanguageUtility.kLang(key: "bullbear_not_available")
                
                var op = ""
                if model.top?.netchng ?? 0 > 0 {
                    op = "+"
                    rocLabel.textColor = QMUITheme().stockRedColor()
                }else if model.top?.netchng ?? 0 < 0 {
                    rocLabel.textColor = QMUITheme().stockGreenColor()
                }else {
                    rocLabel.textColor = QMUITheme().stockGrayColor()
                }
                
                if model.asset?.netInflow ?? 0 > 0 {
                    chartView.backgroundColor = QMUITheme().stockRedColor()
                }else if model.asset?.netInflow ?? 0 < 0 {
                    chartView.backgroundColor = QMUITheme().stockGreenColor()
                }else {
                    chartView.backgroundColor = QMUITheme().stockGrayColor()
                }
                
                rocLabel.text = op + String(format: "%.2lf%%", Double(model.top?.pctchng ?? 0) / 100.0)
            }
        }
    }
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        let tap = UITapGestureRecognizer.init { [weak self](tap) in
            if let action = self?.tapStockNameAction, let market = self?.item?.asset?.market, let symbol = self?.item?.asset?.symbol {
                action(market, symbol, self?.item?.asset?.name ?? "")
            }
        }
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tap)
        return label
    }()
    
    lazy var chartView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var yxselectionLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 12)
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        let tap = UITapGestureRecognizer.init { [weak self](tap) in
            if let action = self?.tapDerivativeOrRocAction, let market = self?.item?.top?.market, let symbol = self?.item?.top?.symbol {
                action(market, symbol)
            }
        }
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tap)
        return label
    }()
    
    lazy var rocLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        let tap = UITapGestureRecognizer.init { [weak self](tap) in
            if let action = self?.tapDerivativeOrRocAction, let market = self?.item?.top?.market, let symbol = self?.item?.top?.symbol {
                action(market, symbol)
            }
        }
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tap)
        return label
    }()
    
    
    override func initialUI() {
        
        super.initialUI()
        
        self.backgroundColor = QMUITheme().foregroundColor()
        
        self.selectionStyle  = .none
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(chartView)
        contentView.addSubview(yxselectionLabel)
        contentView.addSubview(rocLabel)
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(11)
            make.centerY.equalToSuperview()
            make.right.equalTo(chartView.snp.left).offset(-9)
        }
        
        chartView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(100/375.0*YXConstant.screenWidth)
            make.centerY.equalToSuperview()
            make.height.equalTo(14)
            make.width.equalTo(chartViewMaxWidth)
        }
        
        yxselectionLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(200/375.0*YXConstant.screenWidth)
            make.centerY.equalToSuperview()
            make.right.equalTo(rocLabel.snp.left).offset(-15)
        }
        
        rocLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(307/375.0*YXConstant.screenWidth)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-11)
        }
    }


}
