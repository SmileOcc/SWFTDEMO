//
//  YXStockNoticeButton.swift
//  uSmartOversea
//
//  Created by Kelvin on 2019/4/11.
//  Copyright © 2019年 RenRenDai. All rights reserved.
//

import YXKit


class YXStockDetailLZButton: QMUIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = QMUITheme().foregroundColor()
        addSubview(belowView)
        addSubview(backView)
        backView.addSubview(leftImageView)
        backView.addSubview(contentLabel)
        backView.addSubview(arrowImageView)
        
        belowView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        backView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        arrowImageView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
            make.width.equalTo(30)
            make.height.equalTo(30)
            make.centerY.equalToSuperview()
        }
        
        leftImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.width.equalTo(30)
            make.height.equalTo(30)
            make.left.equalToSuperview().offset(6)
        }
        
        contentLabel.snp.makeConstraints { (make) in
            make.right.equalTo(arrowImageView.snp.left).offset(-6)
            make.centerY.equalToSuperview()
            make.left.equalTo(leftImageView.snp.right).offset(6)
        }
        contentLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
        
        
        belowView.layer.backgroundColor = QMUITheme().foregroundColor().cgColor
        belowView.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        belowView.layer.shadowOffset = CGSize(width: 0, height: 0)
        belowView.layer.shadowOpacity = 1.0
        belowView.layer.shadowRadius = 5.0
        
        contentLabel.text = YXLanguageUtility.kLang(key: "warrants_warrants")
        backView.layer.mask = maskLayer
    }
    
    let maskLayer = CAShapeLayer()
    override func draw(_ rect: CGRect) {

        belowView.layer.cornerRadius = self.frame.height / 2.0
        let bezierPath = UIBezierPath.init(roundedRect: backView.bounds, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: self.frame.height / 2.0, height: self.frame.height / 2.0))
        maskLayer.path = bezierPath.cgPath
        maskLayer.frame = backView.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc lazy var belowView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()
    
    @objc lazy var backView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()
    
    @objc lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.image = UIImage(named: "right_black_arrow")
        return imageView
    }()
    
    @objc lazy var leftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.image = UIImage(named: "lz_icon")
        return imageView
    }()
    
    @objc lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
}


class YXStockNoticeButton: YXExpandAreaButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = QMUITheme().foregroundColor()
        addSubview(belowView)
        addSubview(backView)
        backView.addSubview(contentLabel)
        
        belowView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        backView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }

        contentLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(11)
        }
        contentLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
        
        
        belowView.layer.shadowOffset = CGSize(width: 0, height: 0)
        belowView.layer.shadowOpacity = 1.0
        belowView.layer.shadowRadius = 5.0
        
        contentLabel.text = YXLanguageUtility.kLang(key: "warrants_warrants")
        backView.layer.mask = maskLayer
    }
    
    func setBgColor(_ color: UIColor?) {
        self.belowView.backgroundColor = color
        self.backView.backgroundColor = color
        belowView.layer.backgroundColor = color?.cgColor
        belowView.layer.shadowColor = color?.withAlphaComponent(0.1).cgColor
    }
    
    let maskLayer = CAShapeLayer()
    override func draw(_ rect: CGRect) {

        belowView.layer.cornerRadius = self.frame.height / 2.0
        let bezierPath = UIBezierPath.init(roundedRect: backView.bounds, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: self.frame.height / 2.0, height: self.frame.height / 2.0))
        maskLayer.path = bezierPath.cgPath
        maskLayer.frame = backView.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    lazy var belowView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    lazy var backView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }()
}
