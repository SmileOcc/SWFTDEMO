//
//  YXDrawHelper.swift
//  uSmartOversea
//
//  Created by youxin on 2019/4/2.
//  Copyright © 2019年 RenRenDai. All rights reserved.
//

import UIKit

class YXDrawHelper: NSObject {
    
    @discardableResult
    class func drawDashLine(superView: UIView, strokeColor: UIColor, topMargin: CGFloat = 45, lineHeight: CGFloat = 2, leftMargin: CGFloat = 18, lineDashWidth: Float = 2.0, lineWidth: Float = 2.0, rightMargin: CGFloat = 18) -> CALayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.bounds = superView.bounds
        shapeLayer.anchorPoint = CGPoint(x: 0, y: 0)
        shapeLayer.strokeColor = strokeColor.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        shapeLayer.lineWidth = lineHeight
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPhase = 0
        shapeLayer.lineDashPattern = [NSNumber(value: lineWidth), NSNumber(value: lineDashWidth)]
        let path = CGMutablePath()
        path.move(to: CGPoint(x: leftMargin, y: topMargin))
        path.addLine(to: CGPoint(x: superView.layer.bounds.width - rightMargin, y: topMargin))
        shapeLayer.path = path
        superView.layer.addSublayer(shapeLayer)
        
        path.closeSubpath()
        
        return shapeLayer
    }
}
