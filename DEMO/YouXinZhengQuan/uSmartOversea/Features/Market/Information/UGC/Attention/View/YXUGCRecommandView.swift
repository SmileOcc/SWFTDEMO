//
//  YXUGCRecommandView.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/29.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXUGCRecommandView: UIView {
    
    lazy var phoneImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 17
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var levelImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage.init(named: "da_V")
        return imageView
    }()
    
    lazy var titleLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    lazy var subTitleLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    lazy var proImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    lazy var attentionButton:QMUIButton = {
        let btn = QMUIButton()
        btn.setTitle("关注", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = QMUITheme().themeTextColor()
        btn.layer.cornerRadius = 2
        btn.layer.masksToBounds = true
        
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(phoneImageView)
        addSubview(levelImageView)
        addSubview(titleLabel)
        addSubview(subTitleLabel)
        addSubview(attentionButton)
        
        phoneImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(26)
            make.left.equalToSuperview().offset(12)
            make.width.height.equalTo(34)
        }
        levelImageView.snp.makeConstraints { (make) in
            make.bottom.equalTo(phoneImageView.snp.bottom)
            make.right.equalTo(phoneImageView.snp.right)
            make.width.height.equalTo(12)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(phoneImageView.snp.top)
            make.left.equalTo(phoneImageView.snp.right).offset(8)
            make.right.equalTo(proImageView.snp.left).offset(-8)
        }
        proImageView.snp.makeConstraints { (make) in
            make.right.lessThanOrEqualToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(13)
            make.centerY.equalTo(titleLabel.snp.centerY)
        }
        subTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.left)
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
        }
        attentionButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalTo(phoneImageView.snp.centerY)
            make.width.equalTo(76)
            make.height.equalTo(30)
        }
    }

}
