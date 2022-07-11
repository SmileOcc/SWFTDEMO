//
//  YXCommentReplyUserView.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/6/8.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXCommentReplyUserView: UIView {
    
    lazy var photoBtn:QMUIButton = {
        let btn = QMUIButton()
        btn.addTarget(self, action: #selector(phoneAction(_ :)), for: .touchUpInside)
        
        return btn
    }()
    lazy var phoneImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 13
        imageView.layer.masksToBounds = true
        
        return imageView
    }()

    lazy var nickNameLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    lazy var levelImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage.init(named: "da_V")
        return imageView
    }()
    
    lazy var timeLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 9)
        return label
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
        addSubview(nickNameLabel)
        addSubview(levelImageView)
        addSubview(timeLabel)
        addSubview(photoBtn)
        
        phoneImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.width.height.equalTo(26)
        }
        levelImageView.snp.makeConstraints { (make) in
            make.bottom.equalTo(phoneImageView.snp.bottom)
            make.right.equalTo(phoneImageView.snp.right)
            make.width.height.equalTo(12)
        }
        nickNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(phoneImageView.snp.top)
            make.left.equalTo(phoneImageView.snp.right).offset(10)
            make.right.equalToSuperview().offset(-14)
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nickNameLabel.snp.left)
            make.top.equalTo(nickNameLabel.snp.bottom).offset(2)
        }
        
        photoBtn.snp.makeConstraints { make in
            make.left.equalTo(phoneImageView)
            make.top.equalTo(phoneImageView)
            make.right.equalTo(nickNameLabel.snp.right)
            make.height.equalTo(phoneImageView)
        }
    }
    
    var model:YXCreateUserModel?
    
    func updateUI(model:YXCreateUserModel?, createTime:String) {
        self.model = model
        let placeHoderImage:UIImage = UIImage(named: "nav_user") ?? UIImage()
        self.phoneImageView.sd_setImage(with: URL.init(string: model?.avatar ?? "" ), placeholderImage: placeHoderImage, options: [], context: [:])
        self.nickNameLabel.text = model?.nickName
        self.timeLabel.text = YXToolUtility.compareCurrentTime(createTime)
        self.levelImageView.isHidden = !(model?.auth_user ?? false)
//        if let user = self.model {
//            self.proImageView.isHidden = false
//            if user.pro == 1 { //Pro账户取值：1：普通账户  2：Pro2账户   4：Pro1账户    5：Pro3账户
//                self.proImageView.isHidden = true
//            }else if user.pro == 2 {
//                self.proImageView.image = UIImage.init(named: String(format: "VIP2"))
//            }else if user.pro == 4 {
//                self.proImageView.image = UIImage.init(named: String(format: "VIP1"))
//            }else if user.pro == 5 {
//                self.proImageView.image = UIImage.init(named: String(format: "VIP3"))
//            }else{
//                self.proImageView.isHidden = true
//            }
//        }
    }
    
    @objc func phoneAction(_ sender: QMUIButton) {
        if let model = self.model {
            YXUGCCommentManager.gotoUserCenter(uid: model.uid )
        }
    }

}
