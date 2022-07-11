//
//  YXCYQChartView.swift
//  uSmartOversea
//
//  Created by youxin on 2020/6/2.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXCYQChartView: UIView {

    var priceBase: Int = 0
    var lineWidth: CGFloat = 1.0
    var dashLineCount = 29
    var isChipDetail = false

    var commonFont: UIFont {
        if isChipDetail {
            return UIFont.systemFont(ofSize: 12, weight: .regular)
        } else {
            return UIFont.systemFont(ofSize: 10, weight: .regular)
        }
    }
    var model: YXCYQList? {
        didSet {
            refreshUI()
        }
    }

    var maxPriceValue: Int64 = 0
    var minPriceValue: Int64 = 0
    
    func reSetChart(with maxValue: Int64, minValue: Int64) {
        guard maxPriceValue != maxValue, minPriceValue != minValue else {
            return
        }
        maxPriceValue = maxValue
        minPriceValue = minValue
        refreshUI()
    }

    func refreshUI() {
        
        if maxPriceValue == 0 {
            maxPriceValue = Int64(model?.column?.first?.price ?? 0)
        }
        if minPriceValue == 0 {
            minPriceValue = Int64(model?.column?.last?.price ?? 0)
        }
        
        guard maxPriceValue > 0, minPriceValue > 0 else {
            return
        }

        if let info = model {
            let priceBase = self.priceBase

            averageTextLayer.isHidden = true
            averageLineLayer.isHidden = true

            supportTextLayer.isHidden = true
            supportLineLayer.isHidden = true

            pressureTextLayer.isHidden = true
            pressureLineLayer.isHidden = true

            let closePrice = info.close
            var avgPrice = 0
            var supportPrice = 0
            var pressurePrice = 0
            var avgSize: CGSize = .zero
            var supportSize: CGSize = .zero
            var pressureSize: CGSize = .zero
            var maxWidth: CGFloat = 0
                                    
            maxPriceLabel.text = YXToolUtility.stockPriceData(Double(maxPriceValue), deciPoint: priceBase, priceBase: priceBase)
            minPriceLabel.text = YXToolUtility.stockPriceData(Double(minPriceValue), deciPoint: priceBase, priceBase: priceBase)

            if info.avgCost > 0, priceCanShow(value: Int64(info.avgCost)) {
                let value = YXToolUtility.stockPriceData(Double(info.avgCost), deciPoint: priceBase, priceBase: priceBase)
                averageTextLayer.string = value
                avgPrice = info.avgCost
                avgSize = textSize(value ?? "")
                if maxWidth < avgSize.width {
                    maxWidth = avgSize.width
                }

                averageTextLayer.isHidden = false
            }

            if info.supPosition > 0, priceCanShow(value: Int64(info.supPosition)) {
                let value = YXToolUtility.stockPriceData(Double(info.supPosition), deciPoint: priceBase, priceBase: priceBase)
                supportTextLayer.string = value
                supportPrice = info.supPosition
                supportSize = textSize(value ?? "")
                if maxWidth < supportSize.width {
                    maxWidth = supportSize.width
                }

                supportTextLayer.isHidden = false
            }

            if info.pressPosition > 0, priceCanShow(value: Int64(info.pressPosition)) {
                let value = YXToolUtility.stockPriceData(Double(info.pressPosition), deciPoint: priceBase, priceBase: priceBase)
                pressureTextLayer.string = value
                pressurePrice = info.pressPosition
                pressureSize = textSize(value ?? "")
                if maxWidth < pressureSize.width {
                    maxWidth = pressureSize.width
                }

                pressureTextLayer.isHidden = false
            }

            if let columnList = info.column, columnList.count > 0 {

                let arr = columnList.map { $0.vol }
                var maxVol = arr.max() ?? 0
                if maxVol == 0 {
                    maxVol = 1
                }
                let count = columnList.count
                let greenVolumePath = UIBezierPath()
                let redVolumePath = UIBezierPath()
                let margin: CGFloat = 0 //5
                let height = self.frame.height  / CGFloat(count)
                let width = self.frame.width - maxWidth - margin
                for (_, columnModel) in columnList.enumerated() {

                    let price = columnModel.price
                    
                    guard priceCanShow(value: Int64(price)) else { continue }
                    
                    let vol = columnModel.vol
                    let volY = YXKLineUtility.getYCoordinate(withMaxPrice: CGFloat(maxPriceValue), minPrice: CGFloat(minPriceValue), price: CGFloat(price), distance: self.frame.height, zeroY: self.frame.height)
                    let rect = CGRect(x: 0, y: volY, width: width * CGFloat(vol) / CGFloat(maxVol), height: height)
                                        
                    let path = UIBezierPath(rect: rect)
                    path.close()
                    if price < closePrice {
                        greenVolumePath.append(path)
                    } else {
                        redVolumePath.append(path)
                    }

                    if avgPrice > 0, price <= avgPrice, averageLineLayer.isHidden {
                        averageLineLayer.isHidden = false

                        CATransaction.begin()
                        CATransaction.setDisableActions(true)

                        let path = UIBezierPath()
                        path.move(to: CGPoint(x: 0, y: rect.minY - 0.5))
                        path.addLine(to: CGPoint(x: self.frame.width - margin - avgSize.width, y: rect.minY - 0.5))
                        path.close()
                        averageLineLayer.lineWidth = self.lineWidth
                        averageLineLayer.path = path.cgPath

                        averageTextLayer.frame = CGRect(x: self.frame.width - avgSize.width, y: rect.minY - avgSize.height / 2.0, width: avgSize.width, height: avgSize.height)

                        CATransaction.commit()
                    }

                    if supportPrice > 0, price <= supportPrice, supportLineLayer.isHidden {
                        supportLineLayer.isHidden = false

                        CATransaction.begin()
                        CATransaction.setDisableActions(true)

                        let path = UIBezierPath()
                        path.move(to: CGPoint(x: 0, y: rect.minY - 0.5))
                        path.addLine(to: CGPoint(x: self.frame.width - margin - supportSize.width, y: rect.minY - 0.5))
                        path.close()
                        supportLineLayer.lineWidth = self.lineWidth
                        supportLineLayer.path = path.cgPath

                        supportTextLayer.frame = CGRect(x: self.frame.width - supportSize.width, y: rect.minY - supportSize.height / 2.0, width: supportSize.width, height: supportSize.height)

                        CATransaction.commit()
                    }

                    if pressurePrice > 0, price <= pressurePrice, pressureLineLayer.isHidden {
                        pressureLineLayer.isHidden = false

                        CATransaction.begin()
                        CATransaction.setDisableActions(true)

                        let path = UIBezierPath()
                        path.lineWidth = self.lineWidth
                        path.move(to: CGPoint(x: 0, y: rect.minY - 0.5))
                        path.addLine(to: CGPoint(x: self.frame.width - margin - pressureSize.width, y: rect.minY - 0.5))
                        path.close()
                        /*
                         let dashWidth = (self.frame.width - margin - pressureSize.width) / CGFloat(self.dashLineCount)
                         let count = (self.dashLineCount + 1) / 2
                         for i in 0..<count {
                            path.move(to: CGPoint(x: CGFloat(i * 2) * dashWidth, y: rect.minY - 0.5))
                            path.addLine(to: CGPoint(x: CGFloat(i * 2 + 1) * dashWidth, y: rect.minY - 0.5))
                        }
                         */
                        pressureLineLayer.lineWidth = self.lineWidth
                        pressureLineLayer.path = path.cgPath

                        pressureTextLayer.frame = CGRect(x: self.frame.width - pressureSize.width, y: rect.minY - pressureSize.height / 2.0, width: pressureSize.width, height: pressureSize.height)

                        CATransaction.commit()
                    }

                }

                greenVolumeLayer.path = greenVolumePath.cgPath
                redVolumeLayer.path = redVolumePath.cgPath
            }

        }
    }
    
    func priceCanShow(value: Int64) -> Bool {
        if value > minPriceValue && value < maxPriceValue {
            return true
        }
        return false
    }

    func textSize(_ text: String) -> CGSize {
        let rect = (text as NSString).boundingRect(with: CGSize(width: self.frame.width, height: 15), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 10, weight: .regular)], context: nil)
        return CGSize(width: rect.width + 3, height: isChipDetail ? 18 : 13)
    }

    init(frame: CGRect, isChipDetail: Bool = false) {
        super.init(frame: frame)
        initUI()

        self.qmui_frameDidChangeBlock = {
            [weak self] (view, rect) in
            guard let `self` = self else { return }
            self.refreshUI()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        addSubview(maxPriceLabel)
        addSubview(minPriceLabel)

        maxPriceLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(isChipDetail ? 4 : 0)
        }

        minPriceLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(isChipDetail ? -4 : 0)
        }

        layer.addSublayer(greenVolumeLayer)
        layer.addSublayer(redVolumeLayer)

        layer.addSublayer(supportLineLayer)
        layer.addSublayer(pressureLineLayer)
        layer.addSublayer(averageLineLayer)

        layer.addSublayer(supportTextLayer)
        layer.addSublayer(pressureTextLayer)
        layer.addSublayer(averageTextLayer)
    }

    lazy var maxPriceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel2()
        label.font = commonFont
        label.textAlignment = .right
        return label
    }()

    lazy var minPriceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel2()
        label.font = commonFont
        label.textAlignment = .right
        return label
    }()

    lazy var greenVolumeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineCap = .square
        layer.lineJoin = CAShapeLayerLineJoin.bevel
        layer.fillColor = QMUITheme().stockRedColor().cgColor
        layer.strokeColor = QMUITheme().stockRedColor().cgColor
        return layer
    }()


    lazy var redVolumeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineCap = .square
        layer.lineJoin = CAShapeLayerLineJoin.bevel
        layer.fillColor = QMUITheme().stockGreenColor().cgColor
        layer.strokeColor = QMUITheme().stockGreenColor().cgColor
        return layer
    }()

    lazy var averageLineLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.backgroundColor = UIColor.clear.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = QMUITheme().themeTextColor().cgColor
        layer.isHidden = true
        layer.lineWidth = 0.5
        return layer
    }()

    lazy var supportLineLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.backgroundColor = UIColor.clear.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.qmui_color(withHexString: "#FF6933")?.cgColor
        layer.isHidden = true
        layer.lineWidth = 0.5
        return layer
    }()

    lazy var pressureLineLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.backgroundColor = UIColor.clear.cgColor
        //layer.lineDashPattern = [NSNumber.init(value: 3), NSNumber.init(value: 3)]
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.qmui_color(withHexString: "#F9A800")?.cgColor
        layer.isHidden = true
        layer.lineWidth = 0.5
        return layer
    }()

    lazy var averageTextLayer: CATextLayer = {
        let textLayer = CATextLayer()
        textLayer.backgroundColor = QMUITheme().themeTextColor().cgColor
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.alignmentMode = .center
        textLayer.foregroundColor = UIColor.white.cgColor
        let font = commonFont
        let fontRef = CGFont.init(font.fontName as CFString)
        textLayer.font = fontRef
        textLayer.fontSize = commonFont.pointSize
        textLayer.isHidden = true
        textLayer.cornerRadius = 2.0
        return textLayer
    }()

    lazy var supportTextLayer: CATextLayer = {
        let textLayer = CATextLayer()
        textLayer.backgroundColor = UIColor.qmui_color(withHexString: "#FF6933")?.cgColor
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.alignmentMode = .center
        textLayer.foregroundColor = UIColor.white.cgColor
        let font = commonFont
        let fontRef = CGFont.init(font.fontName as CFString)
        textLayer.font = fontRef
        textLayer.fontSize = commonFont.pointSize
        textLayer.isHidden = true
        textLayer.cornerRadius = 2.0
        return textLayer
    }()

    lazy var pressureTextLayer: CATextLayer = {
        let textLayer = CATextLayer()
        textLayer.backgroundColor = UIColor.qmui_color(withHexString: "#F9A800")?.cgColor
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.alignmentMode = .center
        textLayer.foregroundColor = UIColor.white.cgColor
        let font = commonFont
        let fontRef = CGFont.init(font.fontName as CFString)
        textLayer.font = fontRef
        textLayer.fontSize = commonFont.pointSize
        textLayer.isHidden = true
        textLayer.cornerRadius = 2.0
        return textLayer
    }()

}

