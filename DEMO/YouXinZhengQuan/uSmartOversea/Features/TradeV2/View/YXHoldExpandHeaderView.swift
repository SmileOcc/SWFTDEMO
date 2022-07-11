//
//  YXHoldExpandHeaderView.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2019/9/24.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXHoldExpandHeaderView: UIView {
    
    typealias TapClosure = (_ isExpand: Bool) -> Void
    
    @objc var tapClosure: TapClosure?
    
    @objc var isExpand: Bool = true
    
    @objc var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    @objc lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "account_fund_value")
        return label
    }()
    
    lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView()
        let imgName = self.isExpand ? "grey_down_arrow" : "grey_up_arrow"
        imageView.image = UIImage.init(named: imgName)
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let tap = UITapGestureRecognizer.init { (tap) in
            if self.isExpand {
                self.isExpand = false
                self.arrowImageView.image = UIImage.init(named: "grey_up_arrow")
            } else {
                self.isExpand = true
                self.arrowImageView.image = UIImage.init(named: "grey_down_arrow")
            }
            
            if let action = self.tapClosure {
                action(self.isExpand)
            }
        }
        self.addGestureRecognizer(tap)
        
        self.backgroundColor = QMUITheme().foregroundColor()
        
        let line = UIView.line()
        
        addSubview(titleLabel)
        addSubview(arrowImageView)
        addSubview(line)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(16)
            make.centerY.equalTo(self)
        }
        
        arrowImageView.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-13)
            make.centerY.equalTo(self)
        }
        
        line.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.bottom.equalTo(self)
            make.height.equalTo(1)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func arrowDerection(up: Bool) {
        if up {
            arrowImageView.image = UIImage.init(named: "grey_up_arrow")
        }else {
            arrowImageView.image = UIImage.init(named: "grey_down_arrow")
        }
    }
}
