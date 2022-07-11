//
//  YXNewWarrantsDealCell.swift
//  uSmartOversea
//
//  Created by youxin on 2020/9/22.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import Charts

class YXNewWarrantsDealCell: UICollectionViewCell {
    
    let colors = [UIColor.init(hexString: "#41A6FF")!, UIColor.init(hexString: "#414FFF")!, UIColor.init(hexString: "#414FFF")!.withAlphaComponent(0.2)]
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = QMUITheme().textColorLevel1()
        return label
    }()
    
    lazy var chartView: PieChartView = {
        let chart = PieChartView()
        chart.legend.enabled = false

        chart.holeColor = .clear
        chart.holeRadiusPercent = 0.6
        chart.transparentCircleRadiusPercent = 0
        chart.rotationEnabled = false
        chart.drawEntryLabelsEnabled = false
        return chart
    }()
    
    lazy var warrantAmountLabel: UILabel = {
        return valueLabel()
    }()
    
    lazy var bullBearAmountLabel: UILabel = {
        return valueLabel()
    }()
    
    lazy var totalAmountLabel: UILabel = {
        return valueLabel()
    }()
    
    lazy var warrantRatioLabel: UILabel = {
        return valueLabel()
    }()
    
    lazy var bullBearRatioLabel: UILabel = {
        return valueLabel()
    }()
    
    lazy var totalRatioLabel: UILabel = {
        return valueLabel()
    }()
    
    func valueLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = QMUITheme().textColorLevel1()
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }
    
    func descLabel() -> UILabel {
        let label = valueLabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel3()
        return label
    }
    
    var data: YXWarrantsDealResModel? {
        didSet {
            if let model = data {
                
                let warrantChartData = PieChartDataEntry.init(value: model.warrant?.ratio ?? 0.0)
                let bullbearChartData = PieChartDataEntry.init(value: model.cbbc?.ratio ?? 0.0)
                let totalChartData = PieChartDataEntry.init(value: model.other?.ratio ?? 0.0)
                let entries = [warrantChartData, bullbearChartData, totalChartData]
                
                setChartData(with: entries)
                
                let priceBase = model.priceBase
                
                if let warrantAmount = model.warrant?.amount, let ratio = model.warrant?.ratio {
                    warrantAmountLabel.attributedText = YXToolUtility.stocKNumberData(warrantAmount, deciPoint: 2, stockUnit: "", priceBase: priceBase, number: .systemFont(ofSize: 16), unitFont: .systemFont(ofSize: 16))
                    warrantRatioLabel.text = String(format: "%.2lf%%", ratio/100.0)
                }
                if let cbbcAmount = model.cbbc?.amount, let ratio = model.cbbc?.ratio {
                    bullBearAmountLabel.attributedText = YXToolUtility.stocKNumberData(cbbcAmount, deciPoint: 2, stockUnit: "", priceBase: priceBase, number: .systemFont(ofSize: 16), unitFont: .systemFont(ofSize: 16))
                    bullBearRatioLabel.text = String(format: "%.2lf%%", ratio/100.0)
                }
                if let totalAmount = model.other?.amount, let ratio = model.other?.ratio {
                    totalAmountLabel.attributedText = YXToolUtility.stocKNumberData(totalAmount, deciPoint: 2, stockUnit: "", priceBase: priceBase, number: .systemFont(ofSize: 16), unitFont: .systemFont(ofSize: 16))
                    totalRatioLabel.text = String(format: "%.2lf%%", ratio/100.0)
                }
            }
        }
    }
    
    func setChartData(with entries: [PieChartDataEntry]) {
        let set = PieChartDataSet(entries: entries, label: "Election Results")
        
        set.colors = self.colors
        
        set.valueLinePart1OffsetPercentage = 0.4
        set.selectionShift = 0
        set.valueLinePart1Length = 0.4
        set.valueLinePart2Length = 0.8
        set.yValuePosition = .outsideSlice
        set.useValueColorForLine = true
        set.sliceSpace = 2
        
        let data = PieChartData(dataSet: set)
        data.setDrawValues(false)
        
        chartView.data = data
        chartView.highlightValues(nil)
    }
    
    func setNoData() {
        let entries = [PieChartDataEntry(value: 100)]
        let set = PieChartDataSet(entries: entries, label: "Election Results")
        set.sliceSpace = 0
        
        set.colors = [UIColor(hexString: "#414FFF")?.withAlphaComponent(0.2) ?? UIColor.gray]
        
        set.valueLinePart1OffsetPercentage = 0.4
        set.selectionShift = 0
        set.valueLinePart1Length = 0.4
        set.valueLinePart2Length = 0.8
        set.yValuePosition = .outsideSlice
        set.useValueColorForLine = true
        set.drawValuesEnabled = false
        let data = PieChartData(dataSet: set)
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 2
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = "%"
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        data.setValueFont(.systemFont(ofSize: 12))
        data.setValueTextColor(QMUITheme().textColorLevel1())
        
        chartView.data = data
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let containerView = UIView()
        containerView.backgroundColor = QMUITheme().blockColor()
        containerView.layer.cornerRadius = 4
        containerView.layer.masksToBounds = true
        
        titleLabel.text = YXLanguageUtility.kLang(key: "warrant_to_market_turnover")
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(containerView)
        
        containerView.addSubview(chartView)
        containerView.addSubview(warrantAmountLabel)
        containerView.addSubview(bullBearAmountLabel)
        containerView.addSubview(totalAmountLabel)
        containerView.addSubview(warrantRatioLabel)
        containerView.addSubview(bullBearRatioLabel)
        containerView.addSubview(totalRatioLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.height.equalTo(190)
        }
        
        chartView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            if YXConstant.screenHeight <= 667 {
                make.width.height.equalTo(105)
            } else {
                make.width.height.equalTo(120)
            }
        }
        
        warrantRatioLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-25)
            make.top.equalToSuperview().offset(34)
        }
        
//        warrantAmountLabel.snp.makeConstraints { (make) in
//            make.right.equalToSuperview().offset(-132)
//            make.centerY.equalTo(warrantRatioLabel)
//        }
        //改成以图右边间距
        warrantAmountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(chartView.snp.right).offset(28)
            make.centerY.equalTo(warrantRatioLabel)
        }
        
        bullBearRatioLabel.snp.makeConstraints { (make) in
            make.left.equalTo(warrantRatioLabel)
            make.top.equalTo(warrantRatioLabel.snp.bottom).offset(42)
        }
        
        bullBearAmountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(warrantAmountLabel)
            make.centerY.equalTo(bullBearRatioLabel)
        }
        
        totalRatioLabel.snp.makeConstraints { (make) in
            make.left.equalTo(warrantRatioLabel)
            make.top.equalTo(bullBearRatioLabel.snp.bottom).offset(42)
        }
        
        totalAmountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(warrantAmountLabel)
            make.centerY.equalTo(totalRatioLabel)
        }
        
        
        let titles = [YXLanguageUtility.kLang(key: "warrant_flow_turnover"), YXLanguageUtility.kLang(key: "cbbc_flow_turnover"), YXLanguageUtility.kLang(key: "total_flow_turnover")]
        let valueLabels = [warrantAmountLabel, bullBearAmountLabel, totalAmountLabel]
        
        for index in 0...2 {
            let dot = UIView()
            dot.backgroundColor = colors[index]
            dot.layer.cornerRadius = 3
            
            let label = descLabel()
            label.text = titles[index]
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.7;
            
            let valueLabel = valueLabels[index]
            
            contentView.addSubview(dot)
            contentView.addSubview(label)
            
            dot.snp.makeConstraints { (make) in
                make.width.height.equalTo(6)
                make.centerY.equalTo(label)
                make.right.equalTo(label.snp.left).offset(-6)
            }
            
            label.snp.makeConstraints { (make) in
                make.left.equalTo(chartView.snp.right).offset(28)
                make.right.equalToSuperview().offset(-25)
                make.bottom.equalTo(valueLabel.snp.top).offset(-4)
            }
        }
        
        setNoData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
