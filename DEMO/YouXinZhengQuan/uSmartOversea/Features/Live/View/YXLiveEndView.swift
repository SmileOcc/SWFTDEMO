//
//  YXLiveEndView.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2020/9/11.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXLiveEndView: UIView {
    
    @objc var btnClickCallBack: ((_ sender: UIButton)->())?
    
    let bgImageView = UIImageView.init()
    let countLabel = UILabel.init(text: "--", textColor: UIColor.white, textFont: UIFont.systemFont(ofSize: 18, weight: .medium))!
    
    @objc var liveModel: YXLiveDetailModel? {
        didSet {
            if let count = liveModel?.watchUserCountChange {
                self.countLabel.text = count + YXLanguageUtility.kLang(key: "live_viewer")
            }
            if let urlStr = liveModel?.anchor?.image_url, let url = URL.init(string: urlStr) {
                self.bgImageView.sd_setImage(with: url, completed: nil)
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
        
        bgImageView.contentMode = .scaleAspectFit
        backgroundColor = UIColor.black.withAlphaComponent(1)
        let backBtn = UIButton.init(type: .custom, image: UIImage(named: "user_back_icon"), target: self, action: #selector(self.btnClick(_:)))!
        backBtn.tag = 0
        
        let effect = UIBlurEffect.init(style: .dark)
        let effectView = UIVisualEffectView.init(effect: effect)
        
        let titleLabel = UILabel.init(text: YXLanguageUtility.kLang(key: "live_finished"), textColor: UIColor.white, textFont: UIFont.systemFont(ofSize: 24, weight: .medium))!
        let watchTitleLabel = UILabel.init(text: YXLanguageUtility.kLang(key: "live_viewer_count"), textColor: QMUITheme().textColorLevel2(), textFont: UIFont.systemFont(ofSize: 18))!
        
        let shareTitle = UILabel.init(text: "—— " + YXLanguageUtility.kLang(key: "live_share_to") + " ——", textColor: QMUITheme().textColorLevel2(), textFont: UIFont.systemFont(ofSize: 12))!
        let shareBtn = UIButton.init(type: .custom, image: UIImage(named: "icon_live_share"), target: self, action: #selector(self.shareClick))!
        shareBtn.tag = 1
        
        addSubview(bgImageView)
        addSubview(backBtn)
        addSubview(titleLabel)
        addSubview(watchTitleLabel)
        addSubview(countLabel)
        addSubview(shareTitle)
        addSubview(shareBtn)
        
        bgImageView.addSubview(effectView)
        effectView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
                
        bgImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        backBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(52)
            make.width.height.equalTo(30)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(162)
        }
        watchTitleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.height.equalTo(25)
        }
        countLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(watchTitleLabel.snp.bottom).offset(3)
            make.height.equalTo(25)
        }
        shareTitle.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(countLabel.snp.bottom).offset(91)
            make.height.equalTo(17)
        }
        shareBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(shareTitle.snp.bottom).offset(19)
            make.width.height.equalTo(52)
        }
    }

    
    @objc func btnClick(_ sender: UIButton) {
        btnClickCallBack?(sender)
    }
    
    @objc func shareClick(_ sender: UIButton) {
        self.share()
    }
    
    func share() {
        
        YXLiveShareTool.share(liveModel: self.liveModel, viewController: self.yy_viewController)

    }
    
}
