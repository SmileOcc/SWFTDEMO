//
//  YXStockAnalyzeWarrantRadarView.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2020/10/13.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXStockAnalyzeWarrantRadarView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    @objc var scoreArray: [NSNumber] = [] {
        didSet {

            self.setNeedsDisplay()
        }
    }

    let titlesArray: [String] = [ YXLanguageUtility.kLang(key: "warrant_score_year"),
                                  YXLanguageUtility.kLang(key: "warrant_score_out_val"),
                                  YXLanguageUtility.kLang(key: "warrant_score_spreads"),
                                  YXLanguageUtility.kLang(key: "stock_detail_outs_qty")]
    
    let chartDrawWidth: CGFloat = 198

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {

        self.backgroundColor = QMUITheme().foregroundColor()
        
        let titleWidth = (YXConstant.screenWidth - chartDrawWidth) / 2.0 - 10

        for (i, title) in titlesArray.enumerated() {
            var alignment: NSTextAlignment = .center

            if i == 0 {
                alignment = .right
            } else if i == 2 {
                alignment = .left
            }
            let label = createLabel(title, alignment: alignment)
            addSubview(label)
            label.snp.makeConstraints { (make) in
                if i == 0 {
                    make.left.equalToSuperview()
                    make.width.equalTo(titleWidth)
                    make.centerY.equalToSuperview()
                } else if i == 1 {
                    make.centerX.equalToSuperview()
                    make.top.equalToSuperview()
                    make.height.equalTo(16)
                } else if i == 2 {
                    make.right.equalToSuperview()
                    make.width.equalTo(titleWidth)
                    make.centerY.equalToSuperview()
                } else {
                    make.centerX.equalToSuperview()
                    make.bottom.equalToSuperview()
                    make.height.equalTo(16)
                }
            }
        }


    }

    override func draw(_ rect: CGRect) {

        let optionalContext = UIGraphicsGetCurrentContext()
        guard let context = optionalContext else { return }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        drawRectangle(context: context, rect: rect)
        
        drawGradient(context: context, rect: rect)
        
        CATransaction.commit()

    }

    //画外围四边形
    func drawRectangle(context: CGContext, rect: CGRect) {
        var leftX: CGFloat = (rect.size.width - chartDrawWidth) / 2.0
        var topY: CGFloat = 26
        var drawHeight: CGFloat = chartDrawWidth
        var drawWidth: CGFloat = chartDrawWidth
        let xMargin: CGFloat = (drawWidth) / 8.0
        let yMargin: CGFloat = (drawHeight) / 8.0

        let outSideColor = UIColor.qmui_color(withHexString: "#C9CDFF")!
        let insideColor = outSideColor
        context.saveGState()
        context.setLineWidth(1.0)
        context.setAlpha(1.0)
        
        let path = CGMutablePath()


        for i in 0..<4 {
            if i == 0 {
                context.setStrokeColor(outSideColor.cgColor)
            } else {
                context.saveGState()
                context.setStrokeColor(insideColor.cgColor)

                leftX += (xMargin)
                drawWidth -= (2.0 * xMargin)

                topY += (yMargin)
                drawHeight -= (2.0 * yMargin)
            }

            let p1 = CGPoint(x: leftX, y: topY + drawHeight / 2.0)
            let p2 = CGPoint(x: leftX + drawWidth / 2.0, y: topY)
            let p3 = CGPoint(x: leftX + drawWidth, y: topY + drawHeight / 2.0)
            let p4 = CGPoint(x: leftX + drawWidth / 2.0, y: topY + drawHeight)

            context.strokeLineSegments(between: [p1, p2])
            context.strokeLineSegments(between: [p2, p3])
            context.strokeLineSegments(between: [p3, p4])
            context.strokeLineSegments(between: [p4, p1])

            if i == 0 {
                
                context.strokeLineSegments(between: [p1, p3])
                context.strokeLineSegments(between: [p2, p4])
                context.restoreGState()
                path.move(to: p1)
                path.addLine(to: p2)
                path.addLine(to: p3)
                path.addLine(to: p4)
                path.closeSubpath()
            }
        }

        context.restoreGState()
        
        let fillColor = UIColor.qmui_color(withHexString: "#414FFF")!.withAlphaComponent(0.1)
        context.saveGState()
        context.beginPath()
        context.addPath(path)
        context.setFillColor(fillColor.cgColor)
        context.fillPath()
        context.restoreGState()
    }

    //画内层Layer
    func drawGradient(context: CGContext, rect: CGRect) {

        guard !scoreArray.isEmpty else {
            return
        }

        context.saveGState()

        let leftX: CGFloat = (rect.size.width - chartDrawWidth) / 2.0
        let topY: CGFloat = 26
        let drawHeight: CGFloat = chartDrawWidth
        let drawWidth: CGFloat = chartDrawWidth

        var pointArray: [CGPoint] = []
        for (i, number) in scoreArray.enumerated() {
            //总分加起来=100
            var value = number.doubleValue / 25.0
            if value > 1.0 {
                value = 1.0
            }
            if i == 0 {
                let x = leftX + CGFloat(1.0 - value) * drawWidth / 2.0
                let y = topY + drawHeight / 2.0
                pointArray.append(CGPoint(x: x, y: y))
            } else if i == 1 {
                let x = leftX + drawWidth / 2.0
                let y = topY + CGFloat(1.0 - value) * drawHeight / 2.0
                pointArray.append(CGPoint(x: x, y: y))
            } else if i == 2 {
                let x = leftX + CGFloat(1.0 + value) * drawWidth / 2.0
                let y = topY + drawHeight / 2.0
                pointArray.append(CGPoint(x: x, y: y))
            } else  {
                let x = leftX + drawWidth / 2.0
                let y = topY + CGFloat(1.0 + value) * drawHeight / 2.0
                pointArray.append(CGPoint(x: x, y: y))
            }
        }

        let path = CGMutablePath()
        let dotPath = CGMutablePath()

        for (i, point) in pointArray.enumerated() {
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
            let dot = CGMutablePath()
            dot.addRoundedRect(in: CGRect(x: point.x - 3, y: point.y - 3, width: 6, height: 6), cornerWidth: 3, cornerHeight: 3)
            dotPath.addPath(dot)
        }

        path.addLine(to: pointArray[0])

        path.closeSubpath()


        let fillColor = UIColor.qmui_color(withHexString: "#414FFF")!.withAlphaComponent(0.4)
        let strokeColor = UIColor.qmui_color(withHexString: "#414FFF")!

        do {
            context.saveGState()
            context.beginPath()
            context.addPath(path)
         
            context.setFillColor(fillColor.cgColor)
            context.fillPath()

            context.restoreGState()
        }
        
        do {
            context.saveGState()
            context.beginPath()
            context.addPath(dotPath)
      
            context.setFillColor(strokeColor.cgColor)
            context.fillPath()

            context.restoreGState()
        }

        do {
            context.setStrokeColor(strokeColor.cgColor)
            context.setLineWidth(1.0)
            context.setAlpha(1.0)

            context.beginPath()
            context.addPath(path)
            context.strokePath()
        }

        context.restoreGState()
    }


    func createLabel(_ text: String, alignment: NSTextAlignment) -> UILabel {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.textAlignment = alignment
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 14)
//        label.adjustsFontSizeToFitWidth = true
//        label.minimumScaleFactor = 0.8
        return label
    }

}

