//
//  YXPieChartView.swift
//  ChartsDemo-iOS
//
//  Created by chenmingmao on 2019/7/15.
//  Copyright © 2019 dcg. All rights reserved.
//

import UIKit
import Charts

class YXPieChartView: UIView {

    var chartView: PieChartView!
    
    let colors = [QMUITheme().stockGreenColor(),
                  QMUITheme().stockGreenColor().withAlphaComponent(0.7),
                  QMUITheme().stockGreenColor().withAlphaComponent(0.4),
                  QMUITheme().stockRedColor().withAlphaComponent(0.4),
                  QMUITheme().stockRedColor().withAlphaComponent(0.7),
                  QMUITheme().stockRedColor()]
    
    
    var selectColors = [UIColor]()

    var chartYValuePositon: PieChartDataSet.ValuePosition = .outsideSlice

    var isDrawValueEnabled: Bool = true

    var edgeInsets: UIEdgeInsets? {
        didSet {
            if let edge = self.edgeInsets {
                chartView.setExtraOffsets(left: edge.left, top: edge.top, right: edge.right, bottom: edge.bottom)
            }
        }
    }
    
    @objc var dataArr = [NSNumber]() {
        didSet {
            
            if dataArr.count == 0 {
                self.setNoData()
            } else {
                var entries = [PieChartDataEntry]()
                selectColors.removeAll()
                for i in 0..<dataArr.count {
                    let value = dataArr[i]
                    if value.doubleValue > 0 {
                        let entry = PieChartDataEntry(value: value.doubleValue)
                        entries.append(entry)
                        if i < self.colors.count {
                            selectColors.append(self.colors[i])
                        }
                    }
                }
                
                self.setDataCount(with: entries)
            }
            if oldValue.count == 0 {
                chartView.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        chartView = PieChartView.init()
        self.addSubview(chartView)
        chartView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        chartView.legend.enabled = false
        chartView.setExtraOffsets(left: 40, top: 20, right: 40, bottom: 20)

        let textM = NSAttributedString.init(string: YXLanguageUtility.kLang(key: "analytics_money_distribution"), attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: QMUITheme().textColorLevel1()])
        
        chartView.centerAttributedText = textM
        chartView.holeColor = .clear
        chartView.holeRadiusPercent = 0.6
        chartView.transparentCircleRadiusPercent = 0
        chartView.rotationEnabled = false
        chartView.drawEntryLabelsEnabled = false
//        chartView.rotationAngle = 90;
//        setNoData()
    }
    
    func setDataCount(with entries: [PieChartDataEntry]) {
        let set = PieChartDataSet(entries: entries, label: "Election Results")
        set.sliceSpace = 0
        set.sliceSpace = 2
        set.colors = self.selectColors
        
        set.valueLinePart1OffsetPercentage = 0.4
        set.selectionShift = 0
        set.valueLinePart1Length = 0.4
        set.valueLinePart2Length = 0.8
        set.yValuePosition = self.chartYValuePositon
        set.useValueColorForLine = true
        
        let data = PieChartData(dataSet: set)
        data.setDrawValues(self.isDrawValueEnabled)

        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 2
        pFormatter.minimumFractionDigits = 2
        pFormatter.locale = Locale(identifier: "zh")
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        data.setValueFont(UIFont.systemFont(ofSize: 12, weight: .regular))
        data.setValueTextColor(QMUITheme().textColorLevel1())
        chartView.data = data
        chartView.highlightValues(nil)
    }
    
    func setNoData() {
        let entries = [PieChartDataEntry(value: 100)]
        let set = PieChartDataSet(entries: entries, label: "Election Results")
        set.sliceSpace = 0
        
        set.colors = [UIColor.lightGray]
        
        set.valueLinePart1OffsetPercentage = 0.4
        set.selectionShift = 0
        set.valueLinePart1Length = 0.4
        set.valueLinePart2Length = 0.8
        set.yValuePosition = self.chartYValuePositon
        set.useValueColorForLine = true
        set.drawValuesEnabled = false
        let data = PieChartData(dataSet: set)
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 2
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = "%"
        pFormatter.locale = Locale(identifier: "zh")
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        data.setValueFont(UIFont.systemFont(ofSize: 12, weight: .regular))
        data.setValueTextColor(QMUITheme().textColorLevel1())
        
        chartView.data = data
    }
}
