//
//  YXKOLHomeNavView.swift
//  uSmartEducation
//
//  Created by usmart on 2021/12/13.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation
import UIKit
import QMUIKit
import SnapKit
import YXKit

class YXKOLHomeNavView: UIView {
    
    lazy var backBtn: QMUIButton = {
        let btn = QMUIButton()
        btn.setImage(UIImage(named: "nav_back"), for: .normal)
        return btn
    }()
    
    lazy var backBtn_white: QMUIButton = {
        let btn = QMUIButton()
        btn.setImage(UIImage(named: "nav_whiteback"), for: .normal)
        btn.isHidden = true
        return btn
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var kolHearderImage: UIImageView = {
        let imageView = UIImageView(image:UIImage(named: "user_default_photo"))
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var nameLabel: QMUILabel = {
        let label = QMUILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = QMUITheme().textColorLevel1()
        return label
    }()
    
    lazy var followBtn: QMUIButton = {
        let btn = QMUIButton()
        btn.backgroundColor = .clear
        btn.setBackgroundImage(UIImage(color: QMUITheme().mainThemeColor()), for: .normal)
        btn.setBackgroundImage(UIImage(color: QMUITheme().blockColor()), for: .selected)
        btn.setTitle("+ \(YXLanguageUtility.kLang(key: "nbb_btn_follow"))", for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "nbb_btn_following"), for: .selected)
        btn.setTitleColor(UIColor(hexString: "C4C5CE"), for: .selected)
        btn.setTitleColor(.white, for: .normal)
        btn.cornerRadius = 4
        btn.layer.masksToBounds = true
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.contentEdgeInsets = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        return btn
    }()
    
    lazy var askBtn: QMUIButton = {
        let btn = QMUIButton()
        btn.backgroundColor = .clear
        btn.setImage(UIImage(named: "kol_hone_nav_icon"), for: .normal)
        btn.cornerRadius = QMUIButtonCornerRadiusAdjustsBounds
//        btn.backgroundColor = UIColor(hexString: "F9A800")
//        btn.layer.cornerRadius = 14
        /*
         btn.setImage(UIImage(named: "kol_home_ask_icon"), for: .normal)
         btn.layer.cornerRadius = 7
         btn.backgroundColor = UIColor(hexString: "F9A800")
         btn.titleTextColor = UIColor.white
         btn.titleLabel?.font = .systemFont(ofSize: 14)
         btn.setTitle(YXLanguageUtility.kLang(key: "nbb_title_ask"), for: .normal)
         btn.contentEdgeInsets = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
         btn.imageEdgeInsets = UIEdgeInsets(top: 2, left: 0, bottom: -2, right: 0)
         */
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = QMUITheme().foregroundColor()
        contentView.alpha = 0
        addSubview(contentView)
        addSubview(backBtn)
        addSubview(backBtn_white)
        contentView.addSubview(kolHearderImage)
        contentView.addSubview(nameLabel)
        contentView.addSubview(followBtn)
        contentView.addSubview(askBtn)
        
        backBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        backBtn_white.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-10)
        }

        
        contentView.snp.makeConstraints { make in
            make.left.bottom.right.top.equalToSuperview()
        }
        
        kolHearderImage.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-6)
            make.size.equalTo(32)
            make.left.equalToSuperview().offset(45)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-10)
            make.left.equalTo(kolHearderImage.snp.right).offset(8)
            make.right.equalTo(followBtn.snp.left).offset(-8)
        }
        
        askBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(24)
            make.width.equalTo(24)
            make.centerY.equalTo(followBtn.snp.centerY)
        }
        
        followBtn.snp.makeConstraints { make in
            make.centerY.equalTo(kolHearderImage.snp.centerY)
            make.right.equalTo(askBtn.snp.left).offset(-8)
            make.height.equalTo(32)
            make.width.equalTo(86)
        }
        
    }
    
}
