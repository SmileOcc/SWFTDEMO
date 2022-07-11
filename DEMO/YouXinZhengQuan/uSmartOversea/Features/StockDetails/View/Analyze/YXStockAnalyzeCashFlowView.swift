//
//  YXStockAnalyzeCashFlowView.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/7/18.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXStockAnalyzeCashFlowView: YXStockDetailBaseView {
    
    
    enum YXCashFlowUnitType {
        case tenThousand
        case hundredMillion
        case none
        case million
        case billion
    }
    
    @objc var currentList = [NSNumber]() {
        didSet {
            self.drawCashFlow()
        }
    }
    
    var pointCount = 332
    
    var unitTpe: YXCashFlowUnitType = .tenThousand
    
    
    var market = "hk" {
        didSet {
            if self.market == "hk" {
                minTimeLabel.text = "9:30"
                midTimeLabel.text = "12:00/13:00"
                maxTimeLabel.text = "16:00"
                pointCount = 332
            } else if self.market == "us" {
                minTimeLabel.text = "9:30"
                midTimeLabel.text = "12:45"
                maxTimeLabel.text = "16:00"
                pointCount = 391
            } else if self.market == "sg" {
                minTimeLabel.text = "9:00"
                midTimeLabel.text = "12:00/13:00"
                maxTimeLabel.text = "17:16"
                pointCount = 438
            } else {
                minTimeLabel.text = "9:30"
                midTimeLabel.text = "11:30/13:00"
                maxTimeLabel.text = "15:00"
                pointCount = 242
            }
        }
    }
    
    var maxValueLabel = UILabel.init()
    var subMaxValueLabel = UILabel.init()
    var subMinValueLabel = UILabel.init()
    var minValueLabel = UILabel.init()
    
    var maxTimeLabel = UILabel.init()
    var midTimeLabel = UILabel.init()
    var minTimeLabel = UILabel.init()
    
//    var untiValueLabel = UILabel.init()
    
    var currentValueLabel = UILabel.init()

    let drawRect = CGRect(x: 16, y: 64, width: YXConstant.screenWidth - 32.0, height: 142)

    lazy var maskLayer: CALayer = {
        let layer = CALayer()
        layer.frame = self.drawRect

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = layer.bounds
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientLayer.colors = [UIColor.qmui_color(withHexString: "#F9A800")!.withAlphaComponent(0.2).cgColor, UIColor.qmui_color(withHexString: "#F9A800")!.withAlphaComponent(0.00).cgColor]
        gradientLayer.locations = [0, 1.0]
//        gradientLayer.rasterizationScale = UIScreen.main.scale

        layer.addSublayer(gradientLayer)

        return layer
    }()
    
    lazy var redLayer: CAShapeLayer = {
        let layer: CAShapeLayer = CAShapeLayer()
        layer.lineWidth = 1.0
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.qmui_color(withHexString: "#F9A800")!.cgColor
        return layer
    }()
    
    lazy var redCircleLayer: CAShapeLayer = {
        let layer: CAShapeLayer = CAShapeLayer()
        layer.fillColor = UIColor.qmui_color(withHexString: "#F9A800")!.cgColor
        layer.strokeColor = UIColor.qmui_color(withHexString: "#F9A800")!.cgColor
        return layer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {

        maxValueLabel.textColor = QMUITheme().textColorLevel3()
        maxValueLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        maxValueLabel.text = "--"
        
        subMaxValueLabel.textColor = QMUITheme().textColorLevel3()
        subMaxValueLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        subMaxValueLabel.text = "--"

        subMinValueLabel.textColor = QMUITheme().textColorLevel3()
        subMinValueLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        subMinValueLabel.text = "--"

        minValueLabel.textColor = QMUITheme().textColorLevel3()
        minValueLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        minValueLabel.text = "--"
        
        maxTimeLabel.textColor = QMUITheme().textColorLevel3()
        maxTimeLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        
        midTimeLabel.textColor = QMUITheme().textColorLevel3()
        midTimeLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        
        minTimeLabel.textColor = QMUITheme().textColorLevel3()
        minTimeLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        
        let titleLabel = UILabel.init(with: QMUITheme().textColorLevel1(), font: UIFont.systemFont(ofSize: 20, weight: .medium), text: YXLanguageUtility.kLang(key: "analytics_money_trend"))

        let horizontalLine = UIView.init()
        horizontalLine.backgroundColor = QMUITheme().separatorLineColor()

        let dashlineLayer1 = dashLineLayer()
        let dashlineLayer2 = dashLineLayer()
        let dashlineLayer3 = dashLineLayer()
        
        self.addSubview(titleLabel)
        self.addSubview(horizontalLine)

        self.layer.addSublayer(dashlineLayer1)
        self.layer.addSublayer(dashlineLayer2)
        self.layer.addSublayer(dashlineLayer3)

        self.layer.addSublayer(maskLayer)
        self.layer.addSublayer(self.redLayer)
        self.layer.addSublayer(self.redCircleLayer)

        self.addSubview(maxValueLabel)
        self.addSubview(subMaxValueLabel)
        self.addSubview(subMinValueLabel)
        self.addSubview(minValueLabel)
        self.addSubview(maxTimeLabel)
        self.addSubview(minTimeLabel)
        self.addSubview(midTimeLabel)
        //self.addSubview(currentValueLabel)

        
        titleLabel.snp.makeConstraints({ (make) in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(15)
            make.height.equalTo(24)
        })

    
        horizontalLine.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(1)
            make.top.equalToSuperview().offset(self.drawRect.maxY)
        }

        minTimeLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(horizontalLine.snp.bottom).offset(8)
        }

        midTimeLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(horizontalLine.snp.bottom).offset(8)
        }

        maxTimeLabel.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(horizontalLine.snp.bottom).offset(8)
        }
        
        minValueLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(self.drawRect.minX)
            make.height.equalTo(12)
            make.top.equalToSuperview().offset(self.drawRect.maxY - 4 - 12)
        }

        let height = self.drawRect.height / 3.0;
        
        maxValueLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(minValueLabel)
            make.top.equalToSuperview().offset(self.drawRect.minY - 4 - 12)
            make.height.equalTo(12)
        }
        let path1 = UIBezierPath.init(rect: CGRect(x: self.drawRect.minX, y: self.drawRect.minY, width: self.drawRect.width, height: 0.5))
        dashlineLayer1.path = path1.cgPath

        subMaxValueLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(minValueLabel)
            make.top.equalToSuperview().offset(self.drawRect.minY + height - 4 - 12)
            make.height.equalTo(12)
        }

        let path2 = UIBezierPath(rect: CGRect(x: self.drawRect.minX, y: self.drawRect.minY + height, width: self.drawRect.width, height: 0.5))
        dashlineLayer2.path = path2.cgPath

        subMinValueLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(minValueLabel)
            make.top.equalToSuperview().offset(self.drawRect.minY + height * 2.0 - 4.0 - 12)
            make.height.equalTo(12)
        }

        let path3 = UIBezierPath(rect: CGRect(x: self.drawRect.minX, y: self.drawRect.minY + height * 2.0, width: self.drawRect.width, height: 0.5))
        dashlineLayer3.path = path3.cgPath

    }


    func dashLineLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.lineDashPattern = [NSNumber(3), NSNumber(2)]
        layer.lineWidth = 0.5
        layer.strokeColor = QMUITheme().pointColor().cgColor
        layer.fillColor = UIColor.clear.cgColor

        return layer
    }

    
    func drawCashFlow() {
        
        let padding_x: CGFloat = 16
        let margin: CGFloat = (YXConstant.screenWidth - padding_x * 2) / CGFloat(self.pointCount)
    
        let redPath = UIBezierPath()
        let maskPath = UIBezierPath()
        let redCirclePath = UIBezierPath()
        
        var maxValue: Float = 0.00
        var subMaxValue: Float = 0.00
        var minValue: Float = 0.00
        var subMinValue: Float = 0.00
        
        var numbers = self.currentList.map {
            $0.floatValue
        }
        maxValue = numbers.max() ?? 0
        minValue = numbers.min() ?? 0

        let diffValue = (maxValue - minValue) / 3.0

        if maxValue == minValue { return }
    
        subMinValue = minValue + diffValue
        subMaxValue = minValue + 2.0 * diffValue
        
        self.maxValueLabel.text = YXToolUtility.stockData(Double(maxValue), deciPoint: 2, stockUnit: "", priceBase: 0)
        self.subMaxValueLabel.text = YXToolUtility.stockData(Double(subMaxValue), deciPoint: 2, stockUnit: "", priceBase: 0)
        self.subMinValueLabel.text = YXToolUtility.stockData(Double(subMinValue), deciPoint: 2, stockUnit: "", priceBase: 0)
        self.minValueLabel.text = YXToolUtility.stockData(Double(minValue), deciPoint: 2, stockUnit: "", priceBase: 0)
        
        numbers.reverse()
        maskPath.move(to: CGPoint(x: 0, y: self.drawRect.height))
        for i in 0..<numbers.count {
            let value = numbers[i]
            let pointY = YXKLineUtility.getYCoordinate(withMaxPrice: CGFloat(maxValue), minPrice: CGFloat(minValue), price: CGFloat(value), distance: self.drawRect.height, zeroY: self.drawRect.maxY)

            let maskY = YXKLineUtility.getYCoordinate(withMaxPrice: CGFloat(maxValue), minPrice: CGFloat(minValue), price: CGFloat(value), distance: self.drawRect.height, zeroY: self.drawRect.height)
            
            if i == 0 {
                redPath.move(to: CGPoint(x: padding_x + margin * CGFloat(i), y: CGFloat(pointY)))
            } else {
                redPath.addLine(to: CGPoint(x: padding_x + margin * CGFloat(i), y: CGFloat(pointY)))
            }

            maskPath.addLine(to: CGPoint(x:margin * CGFloat(i), y: CGFloat(maskY)))

            if i == numbers.count - 1 {
                // 最后一个点
                let circlePath = UIBezierPath.init(roundedRect: CGRect.init(x: padding_x + margin * CGFloat(i) - 2.5, y: CGFloat(pointY) - 2.5, width: 5, height: 5), cornerRadius: 2.5)
                redCirclePath.append(circlePath)
                maskPath.addLine(to: CGPoint(x: margin * CGFloat(i), y: self.drawRect.height))
                maskPath.addLine(to: CGPoint(x: 0, y: self.drawRect.height))
            }
        }
        
        self.redLayer.path = redPath.cgPath
        self.redCircleLayer.path = redCirclePath.cgPath

        let layer = CAShapeLayer()
        layer.path = maskPath.cgPath
        self.maskLayer.mask = layer

    }
    
    func calUntiType(with maxValue: Float, minValue: Float) -> YXCashFlowUnitType {
        var type: YXCashFlowUnitType = .none
        if abs(maxValue) >= 100000000 || abs(minValue) >= 100000000 {
            type = .hundredMillion
        } else if (10000 < abs(maxValue) && abs(maxValue) < 100000000) || (10000 < abs(minValue) && abs(minValue) <= 100000000) {
            type = .tenThousand
        } else if (0 <= abs(maxValue) && abs(maxValue) < 10000) || (0 <= abs(minValue) && abs(minValue) < 10000) {
            type = .none
        }
        return type
    }
    
    func getUntiPrice() -> Float {
        var unit: Float = 1
        switch self.unitTpe {
        case .none:
            unit = 1.0
        case .tenThousand:
            unit = 10000
        case .hundredMillion:
            unit = 100000000
        case .billion:
            unit = 1000000
        case .million:
            unit = 10000000000
        }
        return unit
    }
    
}
