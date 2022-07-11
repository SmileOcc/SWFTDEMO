//
//  YXNewCourseCell.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2020/7/22.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit


class YXNewCourseSectionHeaderView: UICollectionReusableView {
    
    @objc let titleLabel = UILabel.init()
    @objc let subTitleLabel = UILabel.init()
    @objc let arrowImage = UIImageView.init()
    let clickControl = UIControl.init()
    
    @objc var callBack: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = QMUITheme().backgroundColor()
        
        titleLabel.textColor = QMUITheme().textColorLevel1()
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        
        subTitleLabel.textColor = QMUITheme().textColorLevel2()
        subTitleLabel.text = YXLanguageUtility.kLang(key: "newStock_detail_see_more")
        
        subTitleLabel.font = UIFont.systemFont(ofSize: 12)
        
        arrowImage.image = UIImage(named: "mine_arrow")
        
        clickControl.addTarget(self, action: #selector(self.click(_:)), for: .touchUpInside)
        
        addSubview(titleLabel)
        addSubview(subTitleLabel)
        addSubview(arrowImage)
        addSubview(clickControl)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(11)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-12)
        }
        arrowImage.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
        subTitleLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-36)
            make.centerY.equalToSuperview()
        }
        clickControl.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func click(_ sender: UIControl) {
        callBack?()
    }
    
}

class YXNewCourseCell: UICollectionViewCell {
    
    let iconView = UIImageView.init()
    let titleLabel = UILabel.init()
    let subTitleLabel = UILabel.init()
    let playIconView = UIImageView.init()
    let playCountLabel = UILabel.init()
    let playTimeLabel = UILabel.init()
    let redLabel = UILabel.init()
    
    @objc var model: YXNewCourseVideoInfoModel? {
        didSet {
            if let model = model {
                if model.type == 2 {
                    self.iconView.sd_setImage(with: URL.init(string: model.set_video_info.picture_url.show) , completed: nil)
                    self.titleLabel.text = model.set_video_info.title.show
                    self.subTitleLabel.text = model.set_video_info.sub_title.show
                    self.redLabel.isHidden = !model.set_video_info.hot_flag
                    self.playIconView.isHidden = true
                    self.playCountLabel.isHidden = true
                    self.playTimeLabel.isHidden = true
                    self.redLabel.text = " " +  model.set_video_info.corner_mark + " ";
                } else {
                    self.iconView.sd_setImage(with: URL.init(string: model.video_info.picture_url.show) , completed: nil)
                    self.titleLabel.text = model.video_info.title.show
                    self.subTitleLabel.text = model.video_info.sub_title.show
                    
                    self.redLabel.isHidden = !model.video_info.hot_flag
                    self.playIconView.isHidden = false
                    self.playCountLabel.isHidden = false
                    self.playTimeLabel.isHidden = false
                    self.redLabel.text = " " + model.video_info.corner_mark + " ";
                    
                    let shadowView = NSShadow.init()
                    shadowView.shadowColor = UIColor.black.withAlphaComponent(0.85)
                    shadowView.shadowOffset = CGSize.init(width: 2, height: 1)
                    shadowView.shadowBlurRadius = 4

                    let attCount = NSMutableAttributedString.init(string: model.video_info.video_extra_info.times + "次", attributes: [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 8), .shadow: shadowView])
                    let attTime = NSMutableAttributedString.init(string: model.video_info.video_extra_info.finalTime, attributes: [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 8), .shadow: shadowView])
                    self.playCountLabel.attributedText = attCount
                    self.playTimeLabel.attributedText = attTime
                }
            }
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = QMUITheme().foregroundColor()
        redLabel.backgroundColor = UIColor.qmui_color(withHexString: "#E02020")
        redLabel.text = "HOT"
        redLabel.textAlignment = .center
        redLabel.textColor = UIColor.white
        redLabel.font = UIFont.systemFont(ofSize: 10)
        redLabel.layer.cornerRadius = 2
        redLabel.clipsToBounds = true
        self.layer.cornerRadius = 6
        self.clipsToBounds = true
        
        titleLabel.textColor = QMUITheme().textColorLevel1()
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        
        subTitleLabel.textColor = QMUITheme().textColorLevel2()
        subTitleLabel.font = .systemFont(ofSize: 10)
        
        playCountLabel.textColor = UIColor.white
        playCountLabel.font = .systemFont(ofSize: 8)
        
        playTimeLabel.textColor = UIColor.white
        playTimeLabel.font = .systemFont(ofSize: 8)
        
        playIconView.image = UIImage(named: "course_play")
        
        let bottomView = UIView.init()
        
        contentView.addSubview(bottomView)
        bottomView.addSubview(titleLabel)
        bottomView.addSubview(subTitleLabel)
        
        contentView.addSubview(iconView)
        contentView.addSubview(redLabel)
        contentView.addSubview(playIconView)
        contentView.addSubview(playCountLabel)
        contentView.addSubview(playTimeLabel)

        bottomView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(54)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().offset(6)
            make.right.equalToSuperview().offset(-6)
            make.height.equalTo(20)
        }
        subTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(6)
            make.right.equalToSuperview().offset(-6)
            make.bottom.equalToSuperview().offset(-12)
            make.height.equalTo(14)
        }
        iconView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top)
        }
        playIconView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(5)
            make.width.height.equalTo(15)
            make.bottom.equalToSuperview().offset(-57)
        }
        playCountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(playIconView.snp.right).offset(2)
            make.centerY.equalTo(playIconView)
        }
        playTimeLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-6)
            make.centerY.equalTo(playIconView)
        }
        
        redLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-6)
            make.top.equalToSuperview().offset(5)
//            make.width.equalTo(28)
            make.height.equalTo(12)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
