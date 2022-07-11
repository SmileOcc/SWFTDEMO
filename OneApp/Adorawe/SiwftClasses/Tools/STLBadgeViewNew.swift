//
//  STLBadgeViewNew.swift
// XStarlinkProject
//
//  Created by odd on 2021/9/1.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

class STLBadgeViewNew: UIView {

    var badgeLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = OSSVThemesColors.stlClearColor()
        label.textAlignment = .center
        label.textColor = OSSVThemesColors.stlWhiteColor()
        label.font = UIFont.systemFont(ofSize: 9)
        return label
    }()
    
    var badgeView: UIView = {
        let view = UIView.init()
        view.layer.cornerRadius = 8
        view.layer.borderColor = OSSVThemesColors.stlWhiteColor().cgColor
        view.layer.borderWidth = 1
        view.layer.masksToBounds = true
        view.backgroundColor = OSSVThemesColors.col_B62B21()
        
        return view
    }()
    
    @objc var badge: String = "" {
        didSet {
            if var badgeStr = badge as NSString?{
                
                let badgeValue = badgeStr.integerValue
                if badgeValue > 0 {
                    badgeStr = badgeValue > 99 ? "99+" : badgeStr
                    self.isHidden = false
                } else {
                    badgeStr = ""
                    self.isHidden = true
                }
                
                self.badgeLabel.text = badgeStr as String
            } else {
                self.isHidden = true
                self.badgeLabel.text = ""
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isHidden = true
        self.addSubview(self.badgeView)
        self.badgeView.addSubview(self.badgeLabel)
        
        self.badgeView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalTo(self)
            make.height.equalTo(16)
            make.width.greaterThanOrEqualTo(16)
        }
        
        self.badgeLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.badgeView.snp.leading).offset(5)
            make.trailing.equalTo(self.badgeView.snp.trailing).offset(-5)
            make.centerY.equalTo(self.badgeView.snp.centerY)
            make.height.equalTo(16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
