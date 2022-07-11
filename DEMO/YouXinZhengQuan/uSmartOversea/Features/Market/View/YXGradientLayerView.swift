//
//  YXGradientLayerView.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2021/4/8.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

enum YXGradientDirection {
    case horizontal
    case vertical
}

class YXGradientLayerView: UIView {

    var direction: YXGradientDirection = .horizontal {
        didSet {
            if let layer = self.layer as? CAGradientLayer {
                if direction == .horizontal {
                    layer.startPoint = CGPoint(x: 0, y: 0)
                    layer.endPoint = CGPoint(x: 1, y: 0)
                }else {
                    layer.startPoint = CGPoint(x: 0, y: 0)
                    layer.endPoint = CGPoint(x: 0, y: 1)
                }
            }
        }
    }
    
    var colors: [UIColor] = [] {
        didSet {
            if let layer = self.layer as? CAGradientLayer {
                layer.colors = colors.map({ (color) -> CGColor in
                    return color.cgColor
                })
            }
        }
    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
}
