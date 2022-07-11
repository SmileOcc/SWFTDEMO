//
//  YXQuickEntryCell.swift
//  uSmartOversea
//
//  Created by youxin on 2021/4/21.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class YXLearningMasterCell: UICollectionViewCell,HasDisposeBag {
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
//        imageView.layer.cornerRadius = 25
//        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var tagImageView1: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "kol_header_tag_licensed")

        return imageView
    }()
    
    lazy var tagImageView2: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "kol_header_tag_licensed")

        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel1()
//        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel3()
//        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    lazy var followBtn: UIButton = {
        let btn =  UIButton(type: .custom)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "nbb_tab_follow"), for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "nbb_btn_following"), for: .selected)
        btn.layer.cornerRadius = 4
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        btn.clipsToBounds = true
        btn.setBackgroundImage(UIImage.init(color: QMUITheme().mainThemeColor()), for: .normal)
        btn.setBackgroundImage(UIImage.init(color:  UIColor.themeColor(withNormalHex: "#F8F9FC", andDarkColor: "#212129")), for: .selected)
        btn.setTitleColor(QMUITheme().textColorLevel4(), for: .selected)
    //    btn.setSubmmitTheme()
        return btn
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = QMUITheme().foregroundColor()
        
//        layer.borderWidth = 1
//        layer.borderColor = QMUITheme().separatorLineColor().cgColor
//        layer.cornerRadius = 20
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(tagImageView1)
        contentView.addSubview(tagImageView2)
        contentView.addSubview(followBtn)

        imageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(48)
        }
        
        followBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 62, height: 24))
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(imageView.snp.right).offset(8)
            make.bottom.equalTo(contentView.snp.centerY)
            make.right.equalTo(followBtn.snp.left).offset(-8)
        }
        
        subTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(imageView.snp.right).offset(8)
            make.top.equalTo(contentView.snp.centerY).offset(5)
            make.right.equalTo(followBtn.snp.left).offset(-8)
        }
        
        tagImageView2.snp.makeConstraints { (make) in
            make.bottom.equalTo(imageView.snp.bottom)
            make.right.equalTo(imageView.snp.right)
            make.size.equalTo(16)
        }
        
        tagImageView1.snp.makeConstraints { (make) in
            make.bottom.equalTo(imageView.snp.bottom)
            make.size.equalTo(16)
            make.centerX.equalTo(tagImageView2.snp.centerX).offset(4)
        }
        
        self.layoutIfNeeded()
        imageView.layer.cornerRadius = imageView.frame.size.width / 2;
        imageView.layer.masksToBounds = true
        tagImageView1.layer.cornerRadius = tagImageView1.frame.size.width / 2;
        tagImageView1.layer.masksToBounds = true
        tagImageView2.layer.cornerRadius = tagImageView2.frame.size.width / 2;
        tagImageView2.layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var data :YXSpecialKOLItem? {
        didSet {
            if let item = data {                
                imageView.sd_setImage(with: URL(string: item.photoUrl ?? ""), placeholderImage: UIImage(named: "user_default_photo"), options: [], context: nil)
                titleLabel.text = item.nick
                subTitleLabel.text = item.personalProfile
                followBtn.isSelected = item.isFollowed
                addKolTags(tags: item.tags?.compactMap{YXKOLHomeTagType(rawValue: $0.id ?? "1")} ?? [])
                
                
            }
        }
    }
    
    func addKolTags(tags: [YXKOLHomeTagType]) {
        tagImageView1.isHidden = true
        tagImageView2.isHidden = true
        
        let tag1 = tags[safe: 0]
        let tag2 = tags[safe: 1]
        
        if let tag = tag1 {
            let t = tag as YXKOLHomeTagType
            let image = t.headIcon()
            tagImageView1.image = image
            tagImageView1.isHidden = false
        }

        if let tag = tag2 {
            let t = tag as YXKOLHomeTagType
            let image = t.headIcon()
            tagImageView2.image = image
            tagImageView2.isHidden = false
        }
    }

}
