//
//  BorderView.swift
//  Adorawe
//
//  Created by fan wang on 2021/11/3.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

class BorderView: UIView {
    
    var cornerRadius:CGFloat = 0
    var borderWidth:CGFloat = 0
    var borderColor:UIColor?{
        didSet{
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            borderLayer.strokeColor = borderColor?.cgColor
            CATransaction.commit()
        }
    }
    var fillColor:UIColor?{
        didSet{
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            borderLayer.fillColor = fillColor?.cgColor
            CATransaction.commit()
        }
    }
    
    var lineDashPattern: [NSNumber]?{
        didSet{
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            borderLayer.lineDashPattern = lineDashPattern
            CATransaction.commit()
        }
    }
    
    
    

    private weak var borderLayer:CAShapeLayer!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        let border = CAShapeLayer()
        border.frame = CGRect(x: 1, y: 1, width: bounds.width - 2, height: bounds.height - 2)
        border.fillColor = UIColor.clear.cgColor
        layer.addSublayer(border)
        borderLayer = border
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        borderLayer.frame = CGRect(x: 1, y: 1, width: bounds.width - 2, height: bounds.height - 2)
        borderLayer.path = UIBezierPath(roundedRect: borderLayer.bounds, cornerRadius: cornerRadius).cgPath
        borderLayer.lineWidth = borderWidth
        borderLayer.strokeColor = borderColor?.cgColor
        borderLayer.lineDashPattern = lineDashPattern
        CATransaction.commit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
