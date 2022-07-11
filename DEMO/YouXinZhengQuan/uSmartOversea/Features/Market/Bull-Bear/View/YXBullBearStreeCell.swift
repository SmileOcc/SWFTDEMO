//
//  YXBullBearStreeCell.swift
//  uSmartOversea
//
//  Created by youxin on 2020/4/8.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXBullBearStreeCell: YXTableViewCell {
    
    let chartViewMaxWidth = 70/375.0*YXConstant.screenWidth
    var maxOutstanding: Int64 = 0
    var tapNameAction: ((_ market: String, _ symbol: String) -> Void)?
    var tapRangeAction: ((_ prcLower: String, _ prcUpper: String) -> Void)?
    
    var item: YXBullBearaContractStreetItem? {
        didSet {
            if let model = item, let outstanding = model.outstanding {
                let base = pow(10.0, Double(model.priceBase))
                nameLabel.text = model.top?.name
                // 正股价格区域
                rangeLabel.text = String(format: "%.1lf-%.1lf", Double(outstanding.PrcLower) / base, Double(outstanding.PrcUpper) / base)
                let chartViewWidth = CGFloat(outstanding.Outstanding) / CGFloat(maxOutstanding) * chartViewMaxWidth
                if maxOutstanding != 0 {
                    chartView.snp.updateConstraints { (make) in
                        make.width.equalTo(chartViewWidth)
                    }
                }else {
                    chartView.snp.updateConstraints { (make) in
                        make.width.equalTo(0)
                    }
                }
                
                if outstanding.CallPutFlag == 4 {
                    chartView.backgroundColor = QMUITheme().stockGreenColor()
                }else {
                    chartView.backgroundColor = QMUITheme().stockRedColor()
                }
                
                amountLabel.text = String(format: "%.1lf", Double(outstanding.Outstanding) / 100.0)
                var op = ""
                var color: UIColor
                if outstanding.Change > 0 {
                    color = QMUITheme().stockRedColor()
                    op = "+"
                }else if outstanding.Change < 0 {
                    color = QMUITheme().stockGreenColor()
                }else {
                    color = QMUITheme().stockGrayColor()
                }
                changeLabel.text = String(format: "[%@%.1lf]", op, Double(outstanding.Change) / 100.0)
                changeLabel.textColor = color
            }
            
        }
    }
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().mainThemeColor()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        let tap = UITapGestureRecognizer.init { [weak self](tap) in
            if let action = self?.tapNameAction, let market = self?.item?.top?.market, let symbol = self?.item?.top?.symbol {
                action(market, symbol)
            }
        }
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tap)
        return label
    }()
    
    lazy var rangeLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    lazy var chartView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 10)
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var changeLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 10)
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var rangeActionButton: UIButton = {
        let button = UIButton()
        _ = button.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self](btn) in
            if let action = self?.tapRangeAction {
                if let str = self?.rangeLabel.text, str != "--" {
                    let arr = str.components(separatedBy: "-")
                    if arr.count == 2 {
                        action(arr[0], arr[1])
                    }
                }
            }
        })
        return button
    }()
    
    override func initialUI() {
        
        super.initialUI()
        
        self.backgroundColor = QMUITheme().foregroundColor()
        
        self.selectionStyle  = .none
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(rangeLabel)
        contentView.addSubview(chartView)
        contentView.addSubview(amountLabel)
        contentView.addSubview(changeLabel)
        contentView.addSubview(rangeActionButton)
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(11)
            make.centerY.equalToSuperview()
            make.right.equalTo(rangeLabel.snp.left).offset(-10)
        }
        
        rangeLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(133/375.0*YXConstant.screenWidth)
            make.centerY.equalToSuperview()
            make.right.equalTo(chartView.snp.left).offset(-15)
        }
        
        chartView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(226/375.0*YXConstant.screenWidth)
            make.centerY.equalToSuperview()
            make.height.equalTo(14)
            make.width.equalTo(chartViewMaxWidth)
        }
        
        amountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(chartView.snp.right).offset(4)
            make.centerY.equalToSuperview()
        }
        
        changeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(amountLabel.snp.right).offset(2)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualTo(self).offset(-2)
        }
        
        rangeActionButton.snp.makeConstraints { (make) in
            make.left.equalTo(rangeLabel)
            make.height.equalTo(rangeLabel)
            make.right.equalToSuperview()
        }
    }

}
