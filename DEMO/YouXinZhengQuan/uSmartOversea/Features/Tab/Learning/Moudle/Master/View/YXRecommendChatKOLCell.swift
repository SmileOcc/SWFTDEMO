//
//  YXRecommendChatKOLCell.swift
//  uSmartEducation
//
//  Created by usmart on 2021/11/30.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation
import UIKit
import QMUIKit
import SnapKit

class YXRecommendChatKOLCell: UICollectionViewCell {
    
    //kol头像
    lazy var kolImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    //kol名称
    lazy var kolNameLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.numberOfLines = 1
        return label
    }()
    
    lazy var badgeView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "F95151")!
        view.layer.cornerRadius = 6
        return view
    }()
    
    //kol试用提示
    lazy var tipsLable: QMUILabel = {
        let label = QMUILabel()
        label.textColor = UIColor(hexString: "FF8B00")
        label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.text = YXLanguageUtility.kLang(key: "nbb_title_free_trial")
        return label
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
        backgroundColor = QMUITheme().foregroundColor()
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.qmui_color(withHexString: "#000000")?.withAlphaComponent(0.05).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 12.0
        
        contentView.addSubview(kolImageView)
        contentView.addSubview(kolNameLabel)
        contentView.addSubview(tipsLable)
        contentView.addSubview(badgeView)
        
        kolImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(13)
            make.size.equalTo(50)
            make.centerX.equalToSuperview()
        }
        
        badgeView.snp.makeConstraints { make in
            make.top.equalTo(kolImageView.snp.top)
            make.right.equalTo(kolImageView.snp.right)
            make.size.equalTo(12)
        }
        
        kolNameLabel.snp.makeConstraints { make in
            make.top.equalTo(kolImageView.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().inset(8)
        }
        
        tipsLable.snp.makeConstraints { make in
            make.top.equalTo(kolNameLabel.snp.bottom).offset(2)
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
        }
        badgeView.isHidden = true
        tipsLable.isHidden = true
    }
    
}
