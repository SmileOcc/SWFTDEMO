//
//  YXStockDetailDepthDistributionView.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2021/8/2.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXStockDetailDepthDistributionView: UIView {
    
    var isTrade: Bool = false
    var lastPoint: CGPoint = .zero
    let buyColor = UIColor.qmui_color(withHexString: "#00C767")
    let sellColor = UIColor.qmui_color(withHexString: "#FF6933")

    var sellX: CGFloat = 0
    var buyX: CGFloat = 0
    var minPrice: Int64 = 0
    var maxPrice: Int64 = 0
    var maxSize: Int64 = 0
    
    @objc var model: YXDepthOrderData? {
        didSet {
            minPrice = 0
            maxPrice = 0
            maxSize = 0
            var buyPrice: Int64 = 0
            var sellPrice: Int64 = 0
            let priceBase = Int(model?.priceBase?.value ?? 0)
            var askList: [YXDepthOrder] = []
            var bidList: [YXDepthOrder] = []
            if let list = model?.ask {
                askList = list
                if let info = list.last {
                    if let value = info.size?.value {
                        maxSize = value
                    }
                    
                    if let price = info.price?.value {
                        maxPrice = price
                    }
                }
                
                if let info = list.first, let price = info.price?.value {
                    sellPrice = price
                }
                
                if model?.bid?.count == 0 {
                    minPrice = sellPrice
                    buyPrice = sellPrice
                }
                
            }
            
            if let list = model?.bid {
                bidList = list
                if let info = list.last {
                    if let value = info.size?.value, maxSize < value {
                        maxSize = value
                    }
                    
                    if let value = info.price?.value {
                        minPrice = value
                    }
                }
                
                if let info = list.first, let price = info.price?.value {
                    buyPrice = price
                }
                
                if model?.ask?.count == 0 {
                    maxPrice = buyPrice
                    sellPrice = buyPrice
                }
            }

            maxVolLabel.text = YXToolUtility.stockVolumeUnit(Int(maxSize))
            subMaxVolLabel.text = YXToolUtility.stockVolumeUnit(Int(Double(maxSize) * 0.33))
            midVolLabel.text = YXToolUtility.stockVolumeUnit(Int(Double(maxSize) * 0.66))
            
            buyPriceLabel.isHidden = false
            sellPriceLabel.isHidden = false
            minPriceLabel.text = YXToolUtility.stockPriceData(Double(minPrice), deciPoint: priceBase, priceBase: priceBase)
            maxPriceLabel.text = YXToolUtility.stockPriceData(Double(maxPrice), deciPoint: priceBase, priceBase: priceBase)
            buyPriceLabel.text = YXToolUtility.stockPriceData(Double(buyPrice), deciPoint: priceBase, priceBase: priceBase)
            sellPriceLabel.text = YXToolUtility.stockPriceData(Double(sellPrice), deciPoint: priceBase, priceBase: priceBase)
            
            
            var priceDiv = maxPrice - minPrice
            if priceDiv == 0 {
                priceDiv = 1
            }
            buyX = self.drawRect.width * CGFloat(buyPrice - minPrice) / CGFloat(priceDiv)
            sellX = self.drawRect.width * CGFloat(sellPrice - minPrice) / CGFloat(priceDiv)
            
            sellPriceLabel.snp.updateConstraints { make in
                make.left.equalToSuperview().offset(sellX + 1.0)
            }
            
            buyPriceLabel.snp.updateConstraints { make in
                make.right.equalToSuperview().offset(-(self.drawRect.width - buyX - 1.0))
            }
            
            if maxSize > 0 {
                drawDistribution(askList: askList, bidList: bidList)
            }
 
            self.layoutIfNeeded()
            DispatchQueue.main.async {
                if buyPrice > sellPrice {
                    self.buyPriceLabel.isHidden = true
                    self.sellPriceLabel.isHidden = true
                }
                
                if self.buyPriceLabel.frame.minX <= self.minPriceLabel.frame.maxX {
                    self.buyPriceLabel.isHidden = true
                }
                
                if self.sellPriceLabel.frame.minX <= self.minPriceLabel.frame.maxX {
                    self.sellPriceLabel.isHidden = true
                }
                
                if self.buyPriceLabel.frame.maxX >= self.maxPriceLabel.frame.minX {
                    self.buyPriceLabel.isHidden = true
                }
                
                if self.sellPriceLabel.frame.maxX >= self.maxPriceLabel.frame.minX {
                    self.sellPriceLabel.isHidden = true
                }
                
                if self.longPressPriceLabel.isHidden == false {
                    self.longPressGestureRecognizerAction(gesture: self.longPressGesture)
                }
            }
        }
    }
    
    
    
    func drawDistribution(askList: [YXDepthOrder], bidList: [YXDepthOrder]) {
        
        var priceDiv = maxPrice - minPrice
        if priceDiv == 0 {
            priceDiv = 1
        }
        
        let drawHeight = self.drawRect.height
 
        if askList.count > 0 {
            let path = UIBezierPath()
            let fillPath = UIBezierPath()
            for (index, info) in askList.enumerated() {
                let yy: CGFloat = drawHeight - (drawHeight * (CGFloat(info.size?.value ?? 0) / CGFloat(maxSize)))
                let price = info.price?.value ?? 0
                let xx: CGFloat = self.drawRect.width * CGFloat(price - minPrice) / CGFloat(priceDiv)
                if (index == 0) {
                    path.move(to: CGPoint(x: xx, y: yy))
                    
                    fillPath.move(to: CGPoint(x: xx, y: drawHeight))
                    fillPath.addLine(to: CGPoint(x: xx, y: yy))
                } else {
                    path.addLine(to: CGPoint(x: xx, y: yy))
                    fillPath.addLine(to: CGPoint(x: xx, y: yy))
                }
                
                if index == askList.count - 1 {
                    fillPath.addLine(to: CGPoint(x: xx, y: drawHeight))
                }
            }
            fillPath.close()
            sellLayer.path = path.cgPath
            sellFillLayer.path = fillPath.cgPath
        }
        
        if bidList.count > 0 {
            let path = UIBezierPath()
            let fillPath = UIBezierPath()
            for (index, info) in bidList.reversed().enumerated() {
                let yy: CGFloat = drawHeight - (drawHeight * (CGFloat(info.size?.value ?? 0) / CGFloat(maxSize)))
                let price = info.price?.value ?? 0
                let xx: CGFloat = self.drawRect.width * CGFloat(price - minPrice) / CGFloat(priceDiv)
                if (index == 0) {
                    path.move(to: CGPoint(x: xx, y: yy))
                    fillPath.move(to: CGPoint(x: xx, y: drawHeight))
                    fillPath.addLine(to: CGPoint(x: xx, y: yy))
                } else {
                    path.addLine(to: CGPoint(x: xx, y: yy))
                    fillPath.addLine(to: CGPoint(x: xx, y: yy))
                }
                
                if index == askList.count - 1 {
                    fillPath.addLine(to: CGPoint(x: xx, y: drawHeight))
                }
            }
            fillPath.close()
            buyLayer.path = path.cgPath
            buyFillLayer.path = fillPath.cgPath
            //self.buyFillGradLayer.mask = self.buyFillLayer
        }
    }
    
    @objc init(frame: CGRect, isTrade: Bool) {
        super.init(frame: frame)
        self.isTrade = isTrade
        let margin: CGFloat = 36
//        if !isTrade {
//            margin = 36
//        }
        self.drawRect = CGRect(x: 0, y: 15, width: YXConstant.screenWidth - margin, height: 108)
        initUI()
        
        self.addGestureRecognizer(longPressGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var drawRect: CGRect = .zero
    
    func initUI() {
        self.backgroundColor = QMUITheme().foregroundColor()
        
        layer.addSublayer(crossLineLayer)
        layer.addSublayer(crossBottomLineLayer)
        layer.addSublayer(buyLayer)
        layer.addSublayer(sellLayer)
        
        layer.addSublayer(buyFillGradLayer)
        layer.addSublayer(sellFillGradLayer)
        
        addSubview(maxVolLabel)
        addSubview(subMaxVolLabel)
        addSubview(midVolLabel)
        addSubview(zeroVolLabel)
        addSubview(minPriceLabel)
        addSubview(maxPriceLabel)
        addSubview(buyPriceLabel)
        addSubview(sellPriceLabel)
        
        let margin: CGFloat = self.isTrade ? 0 : 0
        
        maxVolLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(margin)
            make.top.equalTo(self.snp.top).offset(0)
        }
        
        subMaxVolLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(margin)
            make.top.equalTo(midVolLabel.snp.bottom).offset(26)
        }
        
        midVolLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(margin)
            make.top.equalTo(maxVolLabel.snp.bottom).offset(22)
        }
        
        zeroVolLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(margin)
            make.top.equalTo(subMaxVolLabel.snp.bottom).offset(22)
        }
        
        minPriceLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(margin)
            make.height.equalTo(15)
            make.top.equalToSuperview().offset(self.drawRect.maxY + 8)
        }
        
        maxPriceLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-margin)
            make.height.equalTo(15)
            make.top.equalToSuperview().offset(self.drawRect.maxY + 8)
        }
        
        sellPriceLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(margin)
            make.height.equalTo(15)
            make.top.equalToSuperview().offset(self.drawRect.maxY + 8)
        }
        
        buyPriceLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-margin)
            make.height.equalTo(15)
            make.top.equalToSuperview().offset(self.drawRect.maxY + 8)
        }
        
        drawCrossLineLayer()
        
        
        layer.addSublayer(longPressCrossLayer)
        layer.addSublayer(longPressCircleLayer)
        addSubview(longPressSizeLabel)
        addSubview(longPressPriceLabel)
        
        longPressSizeLabel.snp.makeConstraints { make in
            make.height.equalTo(15)
            make.left.equalToSuperview()
            make.centerY.equalTo(self.snp.top).offset(0)
        }
        
        longPressPriceLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.drawRect.maxY + 5)
            make.height.equalTo(18)
            make.centerX.equalTo(self.snp.left).offset(0)
        }
        
    }
    
    func drawCrossLineLayer() {
        var path = UIBezierPath()
        var startY: CGFloat = 15
        let startX: CGFloat = 0
        path.move(to: CGPoint(x: startX, y: startY))
        path.addLine(to: CGPoint(x: self.drawRect.width, y: startY))
    
        startY += 36
        path.move(to: CGPoint(x: startX, y: startY))
        path.addLine(to: CGPoint(x: self.drawRect.width, y: startY))
        
        startY += 36
        path.move(to: CGPoint(x: startX, y: startY))
        path.addLine(to: CGPoint(x: self.drawRect.width, y: startY))
        
        self.crossLineLayer.path = path.cgPath
        
        path = UIBezierPath()
        startY += 36
        path.move(to: CGPoint(x: startX, y: startY))
        path.addLine(to: CGPoint(x: self.drawRect.width, y: startY))
        
        self.crossBottomLineLayer.path = path.cgPath
       
    }
    
    lazy var sellLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = sellColor?.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 1.0
        layer.frame = self.drawRect
        return layer
    }()
    
    
    lazy var buyLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = buyColor?.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 1.0
        layer.frame = self.drawRect
        return layer
    }()
    
    lazy var sellFillLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.frame = CGRect.init(x: 0, y: 0, width: self.drawRect.size.width, height: self.drawRect.size.height)
        return layer
    }()
    
    
    lazy var buyFillLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.frame = CGRect.init(x: 0, y: 0, width: self.drawRect.size.width, height: self.drawRect.size.height)
        return layer
    }()
    
    lazy var sellFillGradLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.qmui_color(withHexString: "#FF6933")!.withAlphaComponent(0.2).cgColor,UIColor.qmui_color(withHexString: "#FF6933")!.withAlphaComponent(0).cgColor]
        layer.frame = self.drawRect
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 0, y: 1)
        layer.mask = self.sellFillLayer
        return layer
    }()
    
    
    lazy var buyFillGradLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors =  [UIColor.qmui_color(withHexString: "#00C767")!.withAlphaComponent(0.2).cgColor,UIColor.qmui_color(withHexString: "#00C767")!.withAlphaComponent(0).cgColor]
        layer.frame = self.drawRect
        layer.mask = self.buyFillLayer
        return layer
    }()
    
    
    lazy var crossLineLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = QMUITheme().pointColor().cgColor
        layer.fillColor = QMUITheme().pointColor().cgColor
        layer.lineWidth = 0.5
        layer.lineDashPattern = [2,2]
        return layer
    }()
    
    lazy var crossBottomLineLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = QMUITheme().pointColor().cgColor
        layer.fillColor = QMUITheme().pointColor().cgColor
        layer.lineWidth = 0.5
        return layer
    }()
    
    lazy var maxVolLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 10)
        label.text = ""
        label.textAlignment = .left
        return label
    }()
    
    lazy var subMaxVolLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 10)
        label.text = ""
        label.textAlignment = .left
        return label
    }()
    
    
    lazy var midVolLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 10)
        label.text = ""
        label.textAlignment = .left
        return label
    }()
    
    
    lazy var zeroVolLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 10)
        label.text = "0"
        label.textAlignment = .left
        return label
    }()
    
    lazy var minPriceLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 10)
        label.text = "--"
        label.textAlignment = .left
        return label
    }()
    
    lazy var maxPriceLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 10)
        label.text = "--"
        label.textAlignment = .left
        return label
    }()
    
    lazy var buyPriceLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 10)
        label.text = "--"
        label.textAlignment = .left
        return label
    }()
    
    lazy var sellPriceLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 10)
        label.text = "--"
        label.textAlignment = .left
        return label
    }()
    
    
    lazy var longPressGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressGestureRecognizerAction(gesture:)))
        gesture.minimumPressDuration = 0.22
        return gesture
    }()
    
    lazy var longPressSizeLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().foregroundColor()
        label.font = .systemFont(ofSize: 10)
        label.text = ""
        label.textAlignment = .center
        label.contentEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        label.backgroundColor = QMUITheme().textColorLevel1()
        label.isHidden = true
        label.backgroundColor = QMUITheme().textColorLevel1().withAlphaComponent(0.8)
        label.layer.cornerRadius = 2
        label.clipsToBounds = true
        return label
    }()
    
    lazy var longPressPriceLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().foregroundColor()
        label.font = .systemFont(ofSize: 10)
        label.text = ""
        label.textAlignment = .center
        label.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        label.backgroundColor = QMUITheme().textColorLevel1().withAlphaComponent(0.8)
        label.layer.cornerRadius = 2
        label.clipsToBounds = true
        label.isHidden = true
        return label
    }()
    
    lazy var longPressCrossLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
//        layer.strokeColor = QMUITheme().textColorLevel2().cgColor
//        layer.fillColor = QMUITheme().textColorLevel2().cgColor
        layer.fillColor = QMUITheme().textColorLevel3().cgColor
        layer.strokeColor = QMUITheme().textColorLevel3().cgColor
        layer.isHidden = true
        layer.lineWidth = 1.0
        layer.frame = CGRect(x: 0, y: 0, width: self.drawRect.width, height: self.drawRect.maxY)
        layer.lineDashPattern = [2,2]
        return layer
    }()
    
    lazy var longPressCircleLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.qmui_color(withHexString: "#000000")?.withAlphaComponent(0.4).cgColor
        layer.isHidden = true
        layer.lineWidth = 5
        return layer
    }()
}

extension YXStockDetailDepthDistributionView {
    @objc func longPressGestureRecognizerAction(gesture: UILongPressGestureRecognizer) {
        
        guard let depthModel = model else {
            return
        }
        
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        var point = gesture.location(in: self)
        if point.x < 0 {
            point.x = 0
        }
        
        if (point.x > self.frame.width) {
            point.x = self.frame.width
        }
       
        if gesture.state == .changed || gesture.state == .began {
            if gesture.state == .began {
                lastPoint = point
            }
            drawLongPressView(point: point, depthModel: depthModel)
            lastPoint = point
        } else if gesture.state == .ended {
            perform(#selector(hideLongPressView), with: nil, afterDelay: 3.0)
        }
    }
    
    func drawLongPressView(point: CGPoint, depthModel: YXDepthOrderData) {
        
        longPressPriceLabel.isHidden = false
        longPressSizeLabel.isHidden = false
        longPressCrossLayer.isHidden = false
        longPressCircleLayer.isHidden = false
        
        let drawHeight = self.drawRect.height
        var priceRange = maxPrice - minPrice
        if priceRange == 0 {
            priceRange = 1
        }
        
        var orderInfo: YXDepthOrder = YXDepthOrder()
        
        let currentPrice = minPrice + Int64(CGFloat(priceRange) * (point.x / self.drawRect.width))
        let moveToRight = (point.x - lastPoint.x) >= 0
        var moveList: [YXDepthOrder] = []
        
        
        if (point.x >= sellX || moveToRight && point.x > buyX), let list = depthModel.ask, list.count > 0 {
            
            moveList = list
            longPressCircleLayer.strokeColor = sellColor?.cgColor
        } else if let list = depthModel.bid, list.count > 0 {
            moveList = list.reversed()
            longPressCircleLayer.strokeColor = buyColor?.cgColor
        }
        
        for (index, info) in moveList.enumerated() {
            let price = info.price?.value ?? 0
            if price == currentPrice {
                orderInfo = info
                break
            } else if (price > currentPrice) {
                orderInfo = info
                if !moveToRight, index > 0 {
                    orderInfo = moveList[index - 1]
                }
                break
            }
        }
        
        if orderInfo.price == nil {
            if !moveToRight, let info = moveList.last {
                orderInfo = info
            } else if let info = moveList.first {
                orderInfo = info
            }
        }
        
        let orderPrice = orderInfo.price?.value ?? 0
        let orderSize = orderInfo.size?.value ?? 0
        let yy: CGFloat = self.drawRect.minY + drawHeight - (drawHeight * (CGFloat(orderSize) / CGFloat(maxSize)))
        let xx: CGFloat = self.drawRect.width * CGFloat(orderPrice - minPrice) / CGFloat(priceRange)
        
        
//        let circlePath = UIBezierPath(arcCenter: CGPoint(x: xx, y: yy), radius: 3, startAngle: 0, endAngle: CGFloat(Double.pi * 2.0), clockwise: true)
//        
//        longPressCircleLayer.path = circlePath.cgPath
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: xx, y: 0))
        path.addLine(to: CGPoint(x: xx, y: self.drawRect.maxY))
        
        path.move(to: CGPoint(x: 0, y: yy))
        path.addLine(to: CGPoint(x: self.drawRect.maxX, y: yy))
        longPressCrossLayer.path = path.cgPath
        
        longPressSizeLabel.text = YXToolUtility.stockVolumeUnit(Int(orderSize))
        
        let priceBase = Int(model?.priceBase?.value ?? 0)
        let priceText = YXToolUtility.stockPriceData(Double(orderPrice), deciPoint: priceBase, priceBase: priceBase)
        longPressPriceLabel.text = priceText
        
        let priceWidth = 8 + (priceText?.width(for: longPressPriceLabel.font!) ?? 0)
        let halfWidth = priceWidth / 2.0
        var centerPriceX = xx
        if xx + halfWidth > self.drawRect.width {
            centerPriceX = self.drawRect.width - halfWidth
        }
        
        if xx - halfWidth < 0 {
            centerPriceX = halfWidth
        }
        
        longPressPriceLabel.snp.updateConstraints { make in
            make.centerX.equalTo(self.snp.left).offset(centerPriceX)
        }
        
        longPressSizeLabel.snp.updateConstraints { make in
            make.centerY.equalTo(self.snp.top).offset(yy)
        }
    }
    
    @objc func hideLongPressView() {
        longPressPriceLabel.isHidden = true
        longPressSizeLabel.isHidden = true
        longPressCrossLayer.isHidden = true
        longPressCircleLayer.isHidden = true
    }
   
}
