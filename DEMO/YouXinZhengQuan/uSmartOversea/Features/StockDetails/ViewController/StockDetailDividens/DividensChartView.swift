//
//  DividensChartView.swift
//  uSmartOversea
//
//  Created by lennon on 2022/5/21.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class DividensBarChartView: UIView {
    
    let barChartViewHeight = 172.0

    var shapeLayers = [CAShapeLayer]()

//    fileprivate lazy var titles: [String] = {
//        let titles = ["1","2","3","4","5","6","7","8","9","10","11","12"]
//        return titles
//    }()
    var titles: [String]? = nil
    
    fileprivate lazy var topLabels: [UILabel] = {
        var labels = [UILabel]()
        if let titles = titles {
            for _ in 1...titles.count {
                labels.append(barChartLabel())
            }
        }
        return labels
    }()
    
    fileprivate lazy var bottomLabels: [UILabel] = {
        var labels = [UILabel]()
        if let titles = titles {
            for _ in 1...titles.count {
                labels.append(barChartLabel())
            }
        }
        return labels
    }()
    
    func barChartLabel() -> UILabel {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawBarChart(titles: [String], values: [Double], topShowValues:[Double],isExp:[Int]) {

        let maxValue = Double(values.max() ?? 1)
        guard maxValue > 0 else { return }
        let count = Double(values.count)
        let leftMargin = 16.0 // 柱状图距离父视图左边距离
        let topMargin = 20.0  // 柱状图距离父视图顶部距离
        let bottomMargin = 20.0 // 柱状图距离父视图底部距离
        let barWidth = 12.0 // 柱子宽度
        let w: Double = Double(YXConstant.screenWidth) - (2.0 * leftMargin) - (count * barWidth) // 去掉柱状图左右边距和所有柱子宽度后剩下的宽度
        var distance: Double = w
        if count == 1 {
            distance = w
        }else {
            distance =  w/(count - 1) // 得到柱子间的间距
        }
        
        for layer in shapeLayers {
            layer.removeFromSuperlayer()
        }
        
        for (index, value) in values.enumerated() {
            let x = leftMargin + (barWidth + distance) * Double(index)
            let h = Double(value) * ((barChartViewHeight - topMargin - bottomMargin)/maxValue) // 需要根据最大值计算出每根柱子的高度
            let y = barChartViewHeight - h - bottomMargin // 柱子的Y坐标（这样才能使柱子的底部在一个水平上）
            let barRect = CGRect.init(x: x, y: y, width: barWidth, height: h)
            let path = UIBezierPath.init(roundedRect: barRect, cornerRadius: 2)
        
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.strokeColor = UIColor.clear.cgColor
            
            let isExpValue = isExp[index]
            var fillColor:UIColor?
            if isExpValue == 0 {
                fillColor = QMUITheme().mainThemeColor()
                shapeLayer.fillColor = fillColor!.cgColor
            } else if isExpValue == 1 {
                
                fillColor = UIColor.themeColor(withNormalHex: "#F9A800", andDarkColor: "#C49F00")
                shapeLayer.fillColor = fillColor!.cgColor
            } else {
                fillColor = QMUITheme().textColorLevel1()
            }
            
            self.layer.addSublayer(shapeLayer)
            shapeLayers.append(shapeLayer)
            
            if index < titles.count {
                let topLabel = topLabels[index]
                if value != 0 {
                    topLabel.text = String(format: "%.3f", topShowValues[index])
                } else {
                    topLabel.text = ""
                }
                topLabel.frame = CGRect.init(x: barRect.origin.x - 8, y: barRect.origin.y - 15.0, width: 28.0, height: 10.0)
                topLabel.textColor = fillColor!

                if topLabel.superview == nil {
                    self.addSubview(topLabel)
                }
            }
            
            if index < titles.count {
                let bottomLabel = bottomLabels[index]
                bottomLabel.text = titles[index]
                let x = Double(barRect.origin.x)
                bottomLabel.frame = CGRect.init(x: x - 8, y: (barChartViewHeight - 15.0), width: 28.0, height: 10.0)

                if bottomLabel.superview == nil {
                    self.addSubview(bottomLabel)
                }
            }
            if index == 0 {
                let linePath = UIBezierPath.init()
                linePath.move(to: CGPoint.init(x: leftMargin, y:  barChartViewHeight - bottomMargin))
                linePath.addLine(to: CGPoint.init(x: Double(YXConstant.screenWidth) - leftMargin, y:  barChartViewHeight - bottomMargin))

                let shapeLayer = CAShapeLayer()
                shapeLayer.path = linePath.cgPath
                shapeLayer.lineWidth = 1
                shapeLayer.fillColor = UIColor.clear.cgColor
                shapeLayer.strokeColor = QMUITheme().pointColor().cgColor
                self.layer.addSublayer(shapeLayer)
                shapeLayers.append(shapeLayer)
            }
        }
        
        
    }
}

class DividensChartView: UIView,YXStockDetailSubHeaderViewProtocol {
    
    enum DividensChartViewType {
        case Quarter(yearStr:String)
        case Year
    }
    
    var selectModel:StockDetailDividensYearModel?  = nil
    
    var model:[StockDetailDividensYearModel]? {
        didSet {
            guard let model = model,model.count > 0 else {
                return
            }
            
            yearsTitles = model.map { $0.date }
            yearBartView.titles = yearsTitles
            quarterBartView.titles = monthTitles
            
            //构建年数据
            model.forEach { yearModel in
                yearDataMap[yearModel.date] = yearModel
            }
            selectModel = model.last
            if let m = selectModel {
                
                if let type = self.type {
                    updateUI(type: type)
                } else {
                    self.type = .Quarter(yearStr: m.date)
                    updateUI(type: self.type!)
                }
            }
            
        }
        
    }
    
    var monthTitles:[String] = ["1","2","3","4","5","6","7","8","9","10","11","12"]
    
    var yearsTitles:[String] = []
    
    var yearDataMap:[String:StockDetailDividensYearModel] = [:]
    
    
    var type:DividensChartViewType?
    
    @objc var selectCallBack: ((_ tag: NSInteger) -> ())?
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .mediumFont20()
        label.textColor = QMUITheme().textColorLevel1()
        label.text = YXLanguageUtility.kLang(key: "stock_detail_dividends_per_share")
        return label
    }()
    
    lazy var typeView: YXTapButtonView = {
        let view = YXTapButtonView.init(titles: [YXLanguageUtility.kLang(key: "stock_detail_dividends_quarter"), YXLanguageUtility.kLang(key: "stock_detail_dividends_year")])
        view.tapAction = { [weak self] index in
            guard let `self` = self else { return }
            
            if index == 0 {
                if let m = self.selectModel {
                    self.type = .Quarter(yearStr: m.date)
                }
            } else if index == 1 {
                self.type = .Year
            }
            self.selectCallBack?(index)
        }
        return view
    }()
    
    fileprivate lazy var yearBartView: DividensBarChartView = {
        let view = DividensBarChartView()
        view.isHidden = true
        return view
    }()
    
    fileprivate lazy var quarterBartView: DividensBarChartView = {
        let view = DividensBarChartView()
        view.isHidden = false
        return view
    }()
    
    lazy var confirmedBtn:QMUIButton = {
        let btn = QMUIButton.init()
        btn.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "stock_detail_dividends_confirmed"), for: .normal)
        btn.setImage(UIImage.qmui_image(with: QMUITheme().mainThemeColor(),size: CGSize(width: 8, height: 8),cornerRadius: 1), for: .normal)
        btn.imagePosition = .left
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.spacingBetweenImageAndTitle = 4
        btn.isUserInteractionEnabled = false
        return btn
    }()
    
    lazy var expectedBtn:QMUIButton = {
        let btn = QMUIButton.init()
        btn.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "stock_detail_dividends_expected"), for: .normal)
        btn.setImage(UIImage.qmui_image(with: UIColor.themeColor(withNormalHex: "#F9A800", andDarkColor: "#C49F00"),size: CGSize(width: 8, height: 8),cornerRadius: 1), for: .normal)
        btn.imagePosition = .left
        btn.spacingBetweenImageAndTitle = 4
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.isUserInteractionEnabled = false
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalTo(16)
        }
        
        addSubview(typeView)
        typeView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.height.equalTo(30)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        addSubview(quarterBartView)
        quarterBartView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.top.equalTo(typeView.snp.bottom).offset(20)
            make.height.equalTo(quarterBartView.barChartViewHeight)
        }
        
        addSubview(yearBartView)
        yearBartView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.top.equalTo(typeView.snp.bottom).offset(20)
            make.height.equalTo(yearBartView.barChartViewHeight)
        }
        
        addSubview(confirmedBtn)
        confirmedBtn.snp.makeConstraints { make in
            make.top.equalTo(quarterBartView.snp.bottom).offset(24)
            make.right.equalTo(self.snp.centerX).offset(-12)
        }
        
        addSubview(expectedBtn)
        expectedBtn.snp.makeConstraints { make in
            make.top.equalTo(quarterBartView.snp.bottom).offset(24)
            make.left.equalTo(self.snp.centerX).offset(12)
        }
                
    }
    
    func updateUI(type:DividensChartViewType) {
        
        switch type {
        case .Quarter(let yearStr):
            if let m = yearDataMap[yearStr]  {
                self.selectModel = m
                self.type = .Quarter(yearStr: m.date)
                var hasMonth:[Int:StockDetailDividensDataModel] = [:]
                m.month.forEach { hasMonth[Int($0.monthNum)] = $0 }
                
                var values:[Double] = []
                var isExps:[Int] = []
                var topShowValues:[Double] = []
                
                let maxValue = Double(m.month.map{ $0.div_amount?.doubleValue ?? 0 }.max() ?? 1)
                guard maxValue > 0 else { return }

                for (_,item) in monthTitles.enumerated() {
                    let monthNum = Int(item.int64Value)
                    if hasMonth.keys.contains(monthNum) {
                        if let value = hasMonth[monthNum] {
                            values.append( Double((value.div_amount?.doubleValue ?? 0.0)/maxValue) )
                            topShowValues.append(value.div_amount?.doubleValue ?? 0.0)
                            isExps.append(value.is_exp)
                        }
                    } else {
                        values.append(0)
                        topShowValues.append(0)
                        isExps.append(-1)
                    }
                    
                }
                self.quarterBartView.drawBarChart(titles: monthTitles, values: values,topShowValues:topShowValues, isExp:isExps)
                self.quarterBartView.isHidden = false
                self.yearBartView.isHidden = true
            }
        case .Year:
            if let m = model  {
                self.type = .Year
                let maxValue = Double(m.map{ $0.div_amount?.doubleValue ?? 0 }.max() ?? 1)
                guard maxValue > 0 else { return }
                
                let values = m.map { Double(($0.div_amount?.doubleValue ?? 0.0)/maxValue) }
                let topShowValues = m.map { $0.div_amount?.doubleValue ?? 0.0 }
                let isExps = m.map { $0.is_exp }
                self.yearBartView.drawBarChart(titles: yearsTitles, values: values, topShowValues:topShowValues, isExp:isExps)
                self.quarterBartView.isHidden = true
                self.yearBartView.isHidden = false
            }
            
        }
    }
    
    
}
