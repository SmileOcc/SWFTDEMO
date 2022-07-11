//
//  YXStockFilterCollectionHeaderView.swift
//  uSmartOversea
//
//  Created by youxin on 2020/9/3.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXStockFilterCollectionHeaderView: UICollectionReusableView {
    
    var action: (() -> Void)?
    var isSpread: Bool = true {
        didSet {
            var angle: CGFloat = 0.0
            if isSpread {
                angle = .pi
            }
            self.arrowView.transform = CGAffineTransform.init(rotationAngle: angle)
            UIView.animate(withDuration: 0.3) {
                self.arrowView.transform = CGAffineTransform.init(rotationAngle: angle)
            }
        }
    }
    
    @objc lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = QMUITheme().textColorLevel1()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    @objc lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel2()
        label.numberOfLines = 0
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var arrowView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "market_arrow_WhiteSkin")
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let tap = UITapGestureRecognizer.init { [weak self](tap) in
            guard let `self` = self else { return }
            self.action?()
        }
        
        addGestureRecognizer(tap)
        
        backgroundColor = QMUITheme().foregroundColor()
        
        addSubview(titleLabel)
        
        addSubview(countLabel)
        
        addSubview(arrowView)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalTo(self)
            make.width.lessThanOrEqualTo(YXConstant.screenWidth-70)
        }
        
        countLabel.snp.makeConstraints { (make) in
            make.right.equalTo(arrowView.snp.left).offset(-6)
            make.centerY.equalTo(self)
        }
        
        arrowView.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-12)
            make.centerY.equalTo(self)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
