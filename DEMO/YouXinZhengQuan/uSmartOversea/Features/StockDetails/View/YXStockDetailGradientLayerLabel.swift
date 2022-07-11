//
//  YXStockDetailGradientLayerLabel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/8/8.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

import SnapKit

class YXStockDetailGradientLayerLabel: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.insertSublayer(gradientLayer, at: 0)
        self.addSubview(crossingPriceLabel)
        
        crossingPriceLabel.snp.makeConstraints { (make) in
            make.left.top.right.bottom.equalToSuperview()
        }
    }
    
    @objc var text: String = "" {
        didSet {
            crossingPriceLabel.text = text
        }
    }
    
    let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.09, y: -0.52)
        layer.endPoint = CGPoint(x: 1.14, y: 1.55)
        layer.colors = [UIColor.qmui_color(withHexString: "#0EC0F1")?.cgColor, UIColor.qmui_color(withHexString: "#535AF0")?.cgColor];
        layer.locations = [0, 1.0]
        return layer
    }()
    
    lazy var crossingPriceLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = UIColor.white
        label.contentEdgeInsets = UIEdgeInsets(top: 3, left: 5, bottom: 3, right: 5)
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds
    }
}


class YXStockDetailGradientLayerButton: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.insertSublayer(gradientLayer, at: 0)
        self.addSubview(contentButton)
        
        contentButton.snp.makeConstraints { (make) in
            make.left.top.right.bottom.equalToSuperview()
        }
    }
    
    let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1.0, y: 1.0)
        layer.locations = [0, 1.0]
        return layer
    }()
    
    lazy var contentButton: QMUIButton = {
        let button = QMUIButton()
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.3
        return button
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds
    }
}
