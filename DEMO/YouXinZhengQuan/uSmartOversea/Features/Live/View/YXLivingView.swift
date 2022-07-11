//
//  YXLivingView.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2020/9/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import NSObject_Rx

class YXLivingUserInfoView: UIView {
    
    let iconView = UIImageView.init()
    var nameLabel = UILabel.init(text: "----", textColor: UIColor.white, textFont: UIFont.systemFont(ofSize: 14, weight: .medium))!
    let likeCount = UILabel.init(text: "--", textColor: UIColor.white, textFont: UIFont.systemFont(ofSize: 12))!
    
    @objc var liveModel: YXLiveDetailModel? {
        didSet {
            self.iconView.sd_setImage(with: URL.init(string: self.liveModel?.anchor?.image_url ?? ""), placeholderImage: UIImage(named: "nav_user"), options: [], context: nil)
            self.nameLabel.text = self.liveModel?.anchor?.nick_name
            if let count = self.liveModel?.likeCount {
                self.likeCount.text = "\(count)" + YXLanguageUtility.kLang(key: "live_like")
            }
        }
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        iconView.image = UIImage(named: "nav_user")
        let likeIcon = UIImageView.init(image: UIImage(named: "icon-like"))
        
        layer.cornerRadius = 20
        clipsToBounds = true
        backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        iconView.layer.cornerRadius = 18
        iconView.layer.borderColor = UIColor.qmui_color(withHexString: "#D4A980")?.cgColor
        iconView.layer.borderWidth = 1
        iconView.clipsToBounds = true
        
        addSubview(iconView)
        addSubview(nameLabel)
        addSubview(likeIcon)
        addSubview(likeCount)
        
        iconView.snp.makeConstraints { (make) in
            make.width.height.equalTo(36)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(2)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(2)
            make.height.equalTo(20)
            make.left.equalTo(iconView.snp.right).offset(4)
            make.right.equalToSuperview().offset(-12)
        }
        likeIcon.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(0)
            make.width.height.equalTo(15)
        }
        likeCount.snp.makeConstraints { (make) in
            make.left.equalTo(likeIcon.snp.right).offset(2)
            make.height.equalTo(16)
            make.centerY.equalTo(likeIcon)
            make.right.equalToSuperview().offset(-12)
        }
    }
}

class YXLivingView: UIView {

    @objc var btnClickCallBack: ((_ sender: UIButton)->())?
    
    let userInfoView = YXLivingUserInfoView.init()
    let countLabel = QMUILabel.init(with: UIColor.white, font: UIFont.systemFont(ofSize: 14), text: "--")
    
    lazy var commentView: YXCommentView = {
        let commentView = YXCommentView()
        
        commentView.shareButton.rx.tap.subscribe(onNext: { [weak self] () in
            guard let strongSelf = self else { return }
            strongSelf.share(YXH5Urls.playNewsLiveUrl(with: strongSelf.liveModel?.id ?? ""))
        }).disposed(by: rx.disposeBag)
        
        commentView.closeButton.rx.tap.subscribe(onNext: { [weak self] () in
            if let btn = self?.commentView.closeButton {
                btn.tag = 3
                self?.btnClickCallBack?(btn)
            }
        }).disposed(by: rx.disposeBag)
        return commentView
    }()
    
    @objc var liveModel: YXLiveDetailModel? {
        didSet {
            if self.commentView.liveModel == nil {
                self.commentView.liveModel = liveModel
            }
            self.userInfoView.liveModel = liveModel
            if let count = liveModel?.watchUserCountChange {
                self.countLabel.text = count + YXLanguageUtility.kLang(key: "live_viewer")
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        countLabel.contentEdgeInsets = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
        countLabel.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        countLabel.layer.cornerRadius = 20
        countLabel.clipsToBounds = true
        
        let mirrorBtn = self.getBtn(with: YXLanguageUtility.kLang(key: "live_mirror"), imageStr: "icon-mirror")
        mirrorBtn.tag = 1
        let beautyBtn = self.getBtn(with: YXLanguageUtility.kLang(key: "live_beautify"), imageStr: "icon-beauty")
        beautyBtn.tag = 0
        let flipBtn = self.getBtn(with: YXLanguageUtility.kLang(key: "live_flip"), imageStr: "icon-flip")
        flipBtn.tag = 2
                        
        addSubview(userInfoView)
        addSubview(countLabel)
        addSubview(mirrorBtn)
        addSubview(beautyBtn)
        addSubview(flipBtn)
        
        userInfoView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(54)
            make.width.equalTo(140)
            make.height.equalTo(40)
        }
        
        countLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-13)
            make.centerY.equalTo(userInfoView)
        }
        
        flipBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-13)
            make.height.equalTo(68)
            make.width.equalTo(60)
            make.top.equalTo(countLabel.snp.bottom).offset(30)
        }
        mirrorBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-13)
            make.height.equalTo(68)
            make.width.equalTo(60)
            make.top.equalTo(flipBtn.snp.bottom).offset(10)
        }
        beautyBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-13)
            make.height.equalTo(68)
            make.width.equalTo(60)
            make.top.equalTo(mirrorBtn.snp.bottom).offset(10)
        }
        
        
        addSubview(commentView)
        
        commentView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(commentView.bounds.height)
        }
    }
    
    @objc func btnClick(_ sender: UIButton) {
        btnClickCallBack?(sender)
    }
    
    func getBtn(with title: String, imageStr: String) -> (QMUIButton) {
        let mirrorBtn = QMUIButton.init(type: .custom, image: UIImage(named: imageStr), target: self, action: #selector(self.btnClick(_:)))!
        mirrorBtn.imagePosition = .top
        mirrorBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        mirrorBtn.setTitleColor(UIColor.white, for: .normal)
        mirrorBtn.setTitle(title, for: .normal)
        mirrorBtn.spacingBetweenImageAndTitle = 0
        mirrorBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        mirrorBtn.titleLabel?.minimumScaleFactor = 0.3
        return mirrorBtn
    }
    
    func share(_ url: String?) {
        
        YXLiveShareTool.share(liveModel: self.liveModel, viewController: self.yy_viewController)
        

    }
    
    @objc func closeCommentTimer() {
        self.commentView.closeTimer()
    }
}



