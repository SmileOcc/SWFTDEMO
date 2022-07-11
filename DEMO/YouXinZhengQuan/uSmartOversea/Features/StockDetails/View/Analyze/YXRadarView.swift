//
//  YXRadarView.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/7/30.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import Charts

class YXRadarView: UIView {
    
    var chartView: RadarChartView?
    
    let infoBtn = UIButton.init()
    
//    let clickControl = UIControl.init()
    
    var jumpDetailCallBack: (() -> ())?
    
    var mixArr: [[String: Any]]? {
        didSet {
            guard let mixArr = self.mixArr else {
                return
            }
            
            var entries1 = [RadarChartDataEntry]()
            var entries2 = [RadarChartDataEntry]()
            var title1 = "--"
            var title2 = "--"
            
            for i in 0..<mixArr.count {
                if i == 0 {
                    let dic = mixArr[i]
                    if let list = dic["list"] as? [NSNumber] {
                        for value in list {
                            var finalValue = value.doubleValue
                            if value.doubleValue > 95 {
                                finalValue = 95
                            }
                            entries1.append(RadarChartDataEntry.init(value: finalValue))
                        }
                    }
                    if let title = dic["title"] as? String {
                        title1 = title
                    }
                }  else if i == 1 {
                    let dic = mixArr[i]
                    if let list = dic["list"] as? [NSNumber] {
                        for value in list {
                            var finalValue = value.doubleValue
                            if value.doubleValue > 95 {
                                finalValue = 95
                            }
                            entries2.append(RadarChartDataEntry.init(value: finalValue))
                        }
                    }
                    if let title = dic["title"] as? String {
                        title2 = title
                    }
                }
            }
            
            let set1 = RadarChartDataSet.init(entries: entries1, label: title1)
            set1.setColor(UIColor.qmui_color(withHexString: "#0055FF")!)
            set1.fillColor = UIColor.qmui_color(withHexString: "#0055FF")!
            set1.drawFilledEnabled = true
            set1.fillAlpha = 0.15
            set1.lineWidth = 2.0
            set1.drawHighlightCircleEnabled = true
            set1.setDrawHighlightIndicators(false)
            
            if title1.count > 5 {
                let l = chartView?.legend
                l?.font = .systemFont(ofSize: 12)
                l?.xEntrySpace = 20
            }
            
            let set2 = RadarChartDataSet.init(entries: entries2, label: title2)
            set2.setColor(UIColor.qmui_color(withHexString: "#F1B92D")!)
            set2.fillColor = UIColor.qmui_color(withHexString: "#F1B92D")!
            set2.drawFilledEnabled = true
            set2.fillAlpha = 0.15
            set2.lineWidth = 2.0
            set2.drawHighlightCircleEnabled = true
            set2.setDrawHighlightIndicators(false)
            
            let data = RadarChartData.init(dataSets: [set1, set2])
            data.setValueFont(UIFont.systemFont(ofSize: 12))
            data.setDrawValues(false)
            data.setValueTextColor(.white)
            
            self.chartView?.data = data
            self.chartView?.animate(xAxisDuration: 1.4, yAxisDuration: 1.4, easingOption: .easeOutBack)
        }
    }
    
    var activities = [ YXLanguageUtility.kLang(key: "analytics_label_profitability"), YXLanguageUtility.kLang(key: "analytics_label_growth"), YXLanguageUtility.kLang(key: "analytics_label_operating"), YXLanguageUtility.kLang(key: "analytics_label_dividend"), YXLanguageUtility.kLang(key: "analytics_label_valuation"), YXLanguageUtility.kLang(key: "analytics_label_trend"), YXLanguageUtility.kLang(key: "analytics_label_turnover"), YXLanguageUtility.kLang(key: "analytics_label_industry") ]

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
        chartView = RadarChartView.init()
        chartView?.isUserInteractionEnabled = false
//        clickControl.addTarget(self, action: #selector(self.arrowBtnClick(_:)), for: .touchUpInside)
        infoBtn.addTarget(self, action: #selector(self.infoClick(_:)), for: .touchUpInside)
        
        infoBtn.setImage(UIImage(named: "analyze_info"), for: .normal)
        // 手动计算frame
        if YXToolUtility.is4InchScreenWidth() {
            if YXUserManager.isENMode() {
                infoBtn.frame = CGRect.init(x: 51 - 14, y: 58, width: 20, height: 20)
            } else {
                infoBtn.frame = CGRect.init(x: 40, y: 47, width: 20, height: 20)
            }
        } else {
            if YXUserManager.isENMode() {
                infoBtn.frame = CGRect.init(x: 17.5, y: 68, width: 20, height: 20)
            } else {
                infoBtn.frame = CGRect.init(x: 17.5, y: 57, width: 20, height: 20)
            }
        }
        
        addSubview(chartView!)
//        addSubview(self.clickControl)
        addSubview(infoBtn)
//
//        self.clickControl.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
        
        self.chartView?.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        chartView?.chartDescription?.enabled = false
        chartView?.webLineWidth = 1.0
        chartView?.innerWebLineWidth = 1.0
        
        chartView?.webColor = UIColor.white
        chartView?.innerWebColor = UIColor.qmui_color(withHexString: "#C8C8C8")!
        chartView?.webAlpha = 1.0
        chartView?.highlightPerTapEnabled = false
        chartView?.rotationEnabled = false
        
        guard let xAxis = chartView?.xAxis else { return }
        if YXUserManager.isENMode() {
            xAxis.labelFont = .systemFont(ofSize: 9)
        } else {
            xAxis.labelFont = .systemFont(ofSize: 14)
        }
        xAxis.xOffset = 0
        xAxis.yOffset = 10.0
        xAxis.valueFormatter = self
        xAxis.labelTextColor = QMUITheme().textColorLevel1().withAlphaComponent(0.8)
        
        guard let yAxis = chartView?.yAxis else { return }
        yAxis.labelCount = 6
        yAxis.axisMinimum = 0.0
        yAxis.axisMaximum = 100.0
        yAxis.forceLabelsEnabled = true
        yAxis.axisMaxLabels = 6
        yAxis.drawZeroLineEnabled = true
        yAxis.labelXOffset = 0
        yAxis.labelAlignment = .center
        yAxis.labelTextColor = QMUITheme().textColorLevel3()
        yAxis.labelFont = .systemFont(ofSize: 14)
        
        guard let l = chartView?.legend else { return }
        l.horizontalAlignment = .center
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = true
        if YXUserManager.isENMode() {
            l.font = .systemFont(ofSize: 12)
        } else {
            l.font = .systemFont(ofSize: 14)
        }
        l.formSize = 10
        l.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.8)
        l.yOffset = 0
        l.form = .circle
        l.xEntrySpace = 40
        l.formToTextSpace = 10
    }
    
//    @objc func arrowBtnClick(_ sender: UIButton) {
//        self.jumpDetailCallBack?()
//    }
    
    @objc func infoClick(_ sender: UIButton) {
        let alertView = YXAlertView.alertView(message: YXLanguageUtility.kLang(key: "analytics_industry_title"))
        alertView.messageLabel.font = .systemFont(ofSize: 16)
        alertView.messageLabel.textAlignment = .left
        alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_iknow"), style: .default, handler: { (action) in
            
        }))
        alertView.showInWindow()
    }
    
    func deleChartView() {
        self.chartView?.removeFromSuperview()
        self.chartView = nil
    }
}


extension YXRadarView: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {

        self.activities[ Int(value) % self.activities.count ]
    }
}
