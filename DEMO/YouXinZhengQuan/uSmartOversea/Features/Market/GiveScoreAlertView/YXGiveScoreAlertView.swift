//
//  YXGiveScoreAlertView.swift
//  YouXinZhengQuan
//
//  Created by suntao on 2021/7/4.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXGiveScoreAlertView: UIView {

    typealias ClickBlock = () -> Void
    @objc var cancelBlock:ClickBlock?
    @objc var likeBlock:ClickBlock?
    @objc var unlikeBlock:ClickBlock?
    
    lazy var topImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage.init(named: "score_top")
        imageView.clipsToBounds = true
        return imageView
    }()
    lazy var topImageBgView: UIView = {
        let imageView = UIView()
        imageView.backgroundColor = UIColor.qmui_color(withHexString: "#414FFF")
        return imageView
    }()
    
    
    lazy var whiteBgView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    lazy var titleLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = .white
        label.font =  UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.text = YXLanguageUtility.kLang(key: "score_title")
        label.textAlignment = .left
        return label
    }()
    
    lazy var likeButton: QMUIButton = {
        let btn = QMUIButton()
        btn.titleLabel?.font =  UIFont.systemFont(ofSize: 16, weight: .medium)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "score_go_appstroe"), for: .normal)
        btn.addTarget(self, action: #selector(likeAction(_:)), for: .touchUpInside)
        btn.backgroundColor = UIColor.qmui_color(withHexString: "#414FFF")
        btn.layer.cornerRadius = 4
        btn.layer.masksToBounds = true
        return btn
    }()
    
    lazy var unlikeButton: QMUIButton = {
        let btn = QMUIButton()
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        btn.setTitleColor(UIColor.qmui_color(withHexString: "#414FFF"), for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "score_go_feadBack"), for: .normal)
        btn.addTarget(self, action: #selector(unlikeAction(_:)), for: .touchUpInside)
        btn.layer.cornerRadius = 4
        btn.layer.masksToBounds = true
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.qmui_color(withHexString: "#414FFF")?.cgColor
        return btn
    }()
    
    lazy var cancelBtn:QMUIButton = {
        let btn = QMUIButton()
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.setTitleColor(UIColor.qmui_color(withHexString: "#888996"), for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "score_cancle"), for: .normal)
        btn.addTarget(self, action: #selector(cancelAction(_:)), for: .touchUpInside)
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
        
        self.yx_setOnlyLightStyle()
        whiteBgView.addSubview(topImageBgView)
        whiteBgView.addSubview(titleLabel)
        whiteBgView.addSubview(likeButton)
        whiteBgView.addSubview(unlikeButton)
        whiteBgView.addSubview(cancelBtn)
        addSubview(whiteBgView)
        addSubview(topImageView)
        
        whiteBgView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(285)
            make.height.equalTo(314)
        }
        topImageView.snp.makeConstraints { (make) in
            make.top.equalTo(whiteBgView.snp.top).offset(-12)
            make.width.equalTo(whiteBgView.snp.width)
            make.centerX.equalTo(whiteBgView)
            make.height.equalTo(99)
        }
        topImageBgView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(87)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(18)
            make.right.equalToSuperview().offset(-13)
            make.height.equalTo(22)
        }
        
        likeButton.snp.makeConstraints { (make) in
            make.top.equalTo(topImageBgView.snp.bottom).offset(33)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.height.equalTo(48)
        }
        
        unlikeButton.snp.makeConstraints { (make) in
            make.top.equalTo(likeButton.snp.bottom).offset(16)
            make.left.right.equalTo(likeButton)
            make.height.equalTo(48)
        }
        
        cancelBtn.snp.makeConstraints { (make) in
            make.top.equalTo(unlikeButton.snp.bottom)
            make.bottom.left.right.equalToSuperview()
        }

    }
    
    @objc func likeAction(_ sender:QMUIButton) {
        YXGiveScoreAlertView.goToAppCommentStore()
        self.likeBlock?()
    }
    
    @objc func unlikeAction(_ sender:QMUIButton) {
        YXNavigationMap.navigator.push(YXModulePaths.userCenterFeedback.url, context: nil)
        self.unlikeBlock?()
    }
    
    @objc func cancelAction(_ sender:QMUIButton) {
        self.cancelBlock?()
    }
    
    class func goToAppCommentStore() {
        let itunesurl:String = String(format: "itms-apps://itunes.apple.com/cn/app/id%@?mt=8&action=write-review", YXConstant.appId)
        if let url = NSURL.init(string: itunesurl) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }

}
