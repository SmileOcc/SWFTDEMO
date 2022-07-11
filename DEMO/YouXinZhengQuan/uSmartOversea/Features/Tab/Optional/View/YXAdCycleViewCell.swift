//
//  YXAdCycleViewCell.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/9/29.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXAdCycleViewCell: YXCycleViewCell {
    public static let AD_CYCLE_ICON_VIEW_WIDTH: CGFloat = YXConstant.screenWidth
    public static let AD_CYCLE_ICON_VIEW_HEIGHT: CGFloat = uniVerLength(76)
    
    var closeClick:(()->())?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(iconView)
        contentView.addSubview(nameLabel)
    
        
        iconView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(0)
            make.top.equalToSuperview().offset(0)
            make.size.equalTo(CGSize(width: YXAdCycleViewCell.AD_CYCLE_ICON_VIEW_WIDTH, height: YXAdCycleViewCell.AD_CYCLE_ICON_VIEW_HEIGHT))
        }
        

//        titleLabel.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(38)
//            make.right.equalToSuperview().offset(-90)
//            make.top.equalToSuperview()
//            make.height.equalToSuperview()
//        }
//
//        nameLabel.snp.makeConstraints { (make) in
//            make.right.equalToSuperview()
//            make.height.equalTo(20)
//            make.centerY.equalToSuperview()
//            make.width.equalTo(60)
//        }
    }
    

   
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .left
        return label
    }()
    
    lazy var iconView: UIImageView = {
        let iconView = UIImageView()
        return iconView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().foregroundColor()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center        
        label.backgroundColor = QMUITheme().holdMark()
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    func setButtonText(text: String) {
        nameLabel.text = text
        if text.count > 0 {
            nameLabel.isHidden = false
            nameLabel.snp.updateConstraints({ (make) in
                make.width.equalTo(60)
            })
        } else {
            nameLabel.isHidden = true
            nameLabel.snp.updateConstraints({ (make) in
                make.width.equalTo(0)
            })
        }
    }
    
    override func layoutSubviews() {
        
    }
}
