//
//  YXNewWarrantsBullBearHeaderView.swift
//  uSmartOversea
//
//  Created by youxin on 2020/9/22.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXNewWarrantsBullBearHeaderView: UICollectionReusableView {
    
    var action: (() -> Void)?
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel1()
        return label
    }()
    
    fileprivate lazy var arrowView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "common_arrow")
        return imageView
    }()
    
    lazy var colorTipView: UIView = {
        let view = UIView()
        let redView = UIView()
        redView.backgroundColor = QMUITheme().stockRedColor()
        
        let greenView = UIView()
        greenView.backgroundColor = QMUITheme().stockGreenColor()
        
        let bullLabel = UILabel()
        bullLabel.font = .systemFont(ofSize: 12)
        bullLabel.textColor = QMUITheme().textColorLevel2()
        bullLabel.text = "牛证"
        
        let bearLabel = UILabel()
        bearLabel.font = .systemFont(ofSize: 12)
        bearLabel.textColor = QMUITheme().textColorLevel2()
        bearLabel.text = "熊证"
        
        view.addSubview(redView)
        view.addSubview(greenView)
        view.addSubview(bullLabel)
        view.addSubview(bearLabel)
        
        redView.snp.makeConstraints { (make) in
            make.width.height.equalTo(10)
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        bullLabel.snp.makeConstraints { (make) in
            make.left.equalTo(redView.snp.right).offset(2)
            make.centerY.equalToSuperview()
        }
        
        greenView.snp.makeConstraints { (make) in
            make.width.height.equalTo(10)
            make.left.equalTo(bullLabel.snp.right).offset(5)
            make.centerY.equalToSuperview()
        }
        
        bearLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.left.equalTo(greenView.snp.right).offset(2)
        }
        
        return view
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let tap = UITapGestureRecognizer.init { [weak self](e) in
            self?.action?()
        }
        
        addGestureRecognizer(tap)
        
        self.backgroundColor = QMUITheme().foregroundColor()
        
        addSubview(titleLabel)
        addSubview(colorTipView)
        addSubview(arrowView)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }
        
        colorTipView.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
        
        arrowView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
