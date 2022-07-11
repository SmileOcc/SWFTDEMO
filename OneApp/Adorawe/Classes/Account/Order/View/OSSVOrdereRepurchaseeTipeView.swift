//
//  OSSVOrdereRepurchaseeTipeView.swift
// XStarlinkProject
//
//  Created by odd on 2021/8/9.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

class OSSVOrdereRepurchaseeTipeView: UIView {

    @objc init(rect:CGRect, title: String) {
        super.init(frame: rect)
        self.backgroundColor = OSSVThemesColors.stlClearColor()
        self.addSubview(self.cotentView)
        
        self.addSubview(self.titleLabel)
        
        self.addSubview(self.arrowView)
        
        self.cotentView.snp.makeConstraints { make in
            make.trailing.equalTo(self.snp.trailing)
            make.top.equalTo(self.snp.top)
            make.bottom.equalTo(self.snp.bottom).offset(-4)
            make.width.lessThanOrEqualTo(self.snp.width)
        }

        self.arrowView.snp.makeConstraints { make in
            make.trailing.equalTo(self.snp.trailing).offset(-8)
            make.top.equalTo(self.cotentView.snp.bottom)
        }

        self.titleLabel.snp.makeConstraints { make in
            make.trailing.equalTo(self.cotentView.snp.trailing).offset(-6)
            make.top.equalTo(self.cotentView.snp.top).offset(2)
            make.bottom.equalTo(self.cotentView.snp.bottom).offset(-2)
            make.leading.equalTo(self.cotentView.snp.leading).offset(6)
        }

        self.titleLabel.text = STLToString(title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc var title:NSString? {
        didSet {
            self.titleLabel.text = STLToString(title)
        }
    }
    
    //MARK: - setter
    
    var titleLabel: UILabel = {
        let lab: UILabel = UILabel.init(frame: CGRect.zero)
        lab.textColor = OSSVThemesColors.col_B62B21()
        lab.font = UIFont.boldSystemFont(ofSize: 10)
        if OSSVSystemsConfigsUtils.isRightToLeftShow() {
            lab.lineBreakMode = .byTruncatingTail
        }
        return lab
    }()
    
    var arrowView: UIImageView = {
        let arr: UIImageView = UIImageView.init(frame: CGRect.zero)
        arr.image = UIImage.init(named: "order_tip_arrow")
        return arr
    }()
    
    var cotentView: UIView = {
        let view: UIView = UIView.init(frame: CGRect.zero)
        view.backgroundColor = OSSVThemesColors.col_FBE9E9()
        return view
    }()
    
}
