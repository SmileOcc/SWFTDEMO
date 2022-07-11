//
//  YXWarrantsKLineView.swift
//  uSmartOversea
//
//  Created by youxin on 2020/9/25.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXWarrantsKLineView: UIView {
    
    let pointCount = 332.0
    var timeLinePointWidth: CGFloat {
        return chartView.width/CGFloat(pointCount)
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = QMUITheme().textColorLevel1()
        label.text = YXLanguageUtility.kLang(key: "market_capital_net_inflows")
        return label
    }()
    
    lazy var maxValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = QMUITheme().textColorLevel3()
        return label
    }()
    
    lazy var midValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = QMUITheme().textColorLevel3()
        label.text = "0"
        return label
    }()
    
    lazy var minValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = QMUITheme().textColorLevel3()
        return label
    }()
    
    lazy var startTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = QMUITheme().textColorLevel3()
        label.text = "9:30"
        return label
    }()
    
    lazy var midTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = QMUITheme().textColorLevel3()
        label.text = "12:00/13:00"
        return label
    }()
    
    lazy var endTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = QMUITheme().textColorLevel3()
        label.text = "16:00"
        return label
    }()
    
    lazy var generator: YXLayerGenerator = {
        return YXLayerGenerator()
    }()
    
    lazy var longPosLineLayer: CAShapeLayer = {
        let layer = self.generator.ma5Layer
        layer?.strokeColor = QMUITheme().stockRedColor().cgColor
        layer?.lineWidth = 2
        return layer ?? CAShapeLayer()
    }()
    
    lazy var shortPosLineLayer: CAShapeLayer = {
        let layer = self.generator.ma20Layer
        layer?.strokeColor = QMUITheme().stockGreenColor().cgColor
        layer?.lineWidth = 2
        return layer ?? CAShapeLayer()
    }()
    
    lazy var chartView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var graphicSymbolView: UIView = {
        let view = UIView()
        let blue = UIView()
        blue.backgroundColor = QMUITheme().stockRedColor()
        let longPositionLabel = UILabel()
        longPositionLabel.font = .systemFont(ofSize: 10)
        longPositionLabel.textColor = QMUITheme().textColorLevel2()
        longPositionLabel.text = YXLanguageUtility.kLang(key: "stock_detail_interests_long")
        
        let yellow = UIView()
        yellow.backgroundColor = QMUITheme().stockGreenColor()
        let shortPositionLabel = UILabel()
        shortPositionLabel.font = .systemFont(ofSize: 10)
        shortPositionLabel.textColor = QMUITheme().textColorLevel2()
        shortPositionLabel.text = YXLanguageUtility.kLang(key: "stock_detail_interests_short")
        
        view.addSubview(blue)
        view.addSubview(longPositionLabel)
        view.addSubview(yellow)
        view.addSubview(shortPositionLabel)
        
        blue.snp.makeConstraints { (make) in
            make.width.equalTo(12)
            make.height.equalTo(2)
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        longPositionLabel.snp.makeConstraints { (make) in
            make.left.equalTo(blue.snp.right).offset(5)
            make.centerY.equalToSuperview()
        }
        
        yellow.snp.makeConstraints { (make) in
            make.width.equalTo(12)
            make.height.equalTo(2)
            make.left.equalTo(longPositionLabel.snp.right).offset(32)
            make.centerY.equalToSuperview()
        }
        
        shortPositionLabel.snp.makeConstraints { (make) in
            make.left.equalTo(yellow.snp.right).offset(5)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        return view
    }()
    
    func drawCrossLayer() {
        
        let horizenPath = UIBezierPath.init()
        let verticalPath = UIBezierPath.init()
        let height = chartView.size.height/2.0
        let width = chartView.size.width/2.0
        
        for index in 0...2 {
            let hpath = UIBezierPath()
            hpath.move(to: CGPoint.init(x: 0, y: CGFloat(index) * height))
            hpath.addLine(to: CGPoint.init(x: chartView.size.width, y: CGFloat(index) * height))
            horizenPath.append(hpath)
            
            let vpath = UIBezierPath()
            vpath.move(to: CGPoint.init(x: CGFloat(index) * width, y: 0))
            vpath.addLine(to: CGPoint.init(x: CGFloat(index) * width, y: chartView.size.height))
            verticalPath.append(vpath)
        }
        
        generator.horizonLayer.path = horizenPath.cgPath
        generator.verticalLayer.path = verticalPath.cgPath
    }
    
    var kLineData: YXWarrantsFundFlowKLineResModel? {
        didSet {
            
            if let longPos = kLineData?.longPos, let shortPos = kLineData?.shortPos {
                let priceBase = longPos.priceBase
                let longArray = longPos.data.map { (item) -> Int64 in
                    return abs(item.netin)
                }
                
                let shortArray = shortPos.data.map { (item) -> Int64 in
                    return abs(item.netin)
                }
                let sortLongPosArray = longArray.sorted { (item1, item2) -> Bool in
                    return item1 > item2
                }
                
                let sortShortPosArray = shortArray.sorted { (item1, item2) -> Bool in
                    return item1 > item2
                }
                
                let maxLong = sortLongPosArray.first ?? 0
                let maxShort = sortShortPosArray.first ?? 0
                
                let maxVlue = max(maxLong, maxShort)
                let maxPrice = Double(maxVlue)/pow(10.0, longPos.priceBase)
                
                maxValueLabel.attributedText = YXToolUtility.stocKNumberData(maxVlue, deciPoint: 2, stockUnit: "", priceBase: Int(priceBase), number: .systemFont(ofSize: 10), unitFont: .systemFont(ofSize: 10), color: QMUITheme().textColorLevel3())
                minValueLabel.attributedText = YXToolUtility.stocKNumberData(-maxVlue, deciPoint: 2, stockUnit: "", priceBase: Int(priceBase), number: .systemFont(ofSize: 10), unitFont: .systemFont(ofSize: 10), color: QMUITheme().textColorLevel3())
                
                let distance = chartView.size.height
                let longPosPath = UIBezierPath()
                let shortPosPath = UIBezierPath()
                
                for (index, item) in longPos.data.enumerated() {
                    let x = CGFloat(index) * timeLinePointWidth
                    let longPosPrice = Double(item.netin)/pow(10.0, priceBase)
                    
                    let longPosY = YXKLineUtility.getYCoordinate(withMaxPrice: CGFloat(maxPrice), minPrice: CGFloat(-maxPrice), price: CGFloat(longPosPrice), distance: distance, zeroY: distance)
                    
                    if index == 0 {
                        longPosPath.move(to: CGPoint.init(x: x, y: longPosY))
                    }else {
                        longPosPath.addLine(to: CGPoint.init(x: x, y: longPosY))
                    }
                }
                
                for (index, item) in shortPos.data.enumerated() {
                    let x = CGFloat(index) * timeLinePointWidth
                    let shortPosPrice = Double(item.netin)/pow(10.0, priceBase)
                    
                    let shortPosY = YXKLineUtility.getYCoordinate(withMaxPrice: CGFloat(maxPrice), minPrice: CGFloat(-maxPrice), price: CGFloat(shortPosPrice), distance: distance, zeroY: distance)
                    
                    if index == 0 {
                        shortPosPath.move(to: CGPoint.init(x: x, y: shortPosY))
                    }else {
                        shortPosPath.addLine(to: CGPoint.init(x: x, y: shortPosY))
                    }
                }
                
                longPosLineLayer.path = longPosPath.cgPath
                shortPosLineLayer.path = shortPosPath.cgPath
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawCrossLayer()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        chartView.layer.addSublayer(generator.horizonLayer)
        chartView.layer.addSublayer(generator.verticalLayer)
        chartView.layer.addSublayer(longPosLineLayer)
        chartView.layer.addSublayer(shortPosLineLayer)
        
        addSubview(titleLabel)
        addSubview(chartView)
        addSubview(graphicSymbolView)
        addSubview(maxValueLabel)
        addSubview(midValueLabel)
        addSubview(minValueLabel)
        addSubview(startTimeLabel)
        addSubview(midTimeLabel)
        addSubview(endTimeLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(14)
        }
        
        chartView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.top.equalTo(titleLabel.snp.bottom).offset(28)
            make.bottom.equalToSuperview().offset(-60)
        }
        
        graphicSymbolView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
            make.height.equalTo(18)
        }
        
        maxValueLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(chartView.snp.top).offset(-3)
            make.left.equalTo(chartView)
        }
        
        midValueLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(chartView).offset(-5)
            make.left.equalTo(chartView)
        }
        
        minValueLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(chartView).offset(-3)
            make.left.equalTo(chartView)
        }
        
        startTimeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(chartView)
            make.top.equalTo(chartView.snp.bottom).offset(6)
        }
        
        midTimeLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(chartView)
            make.top.equalTo(startTimeLabel)
        }
        
        endTimeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(chartView)
            make.top.equalTo(startTimeLabel)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
