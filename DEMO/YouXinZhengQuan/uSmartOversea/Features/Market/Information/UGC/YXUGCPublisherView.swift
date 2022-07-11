//
//  YXUGCPublisherView.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/5/28.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

@objc enum PublisherStyle: Int {
    case normal
    case navBar
}

extension PublisherStyle {
    var contentHeight: CGFloat {
        switch self {
        case .normal:
            return 70
        case .navBar:
            return 44
        }
    }
    
    var buttonSize: CGSize {
        switch self {
        case .normal:
            return CGSize(width: 76, height: 30)
        case .navBar:
            return CGSize(width: 56, height: 24)
        }
    }
}

@objcMembers class YXUGCPublisherView: UIView {
    
    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }

//    dynamic var isFollow: NumberBool? {
//        didSet {
////            if oldValue?.value == false, isFollow?.value == true {
////                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
////                    self?.followButton.isHidden = true
////                }
////            } else {
////                followButton.isHidden = isFollow?.value ?? true
////            }
//            followButton.isSelected = isFollow?.value ?? true
//
//        }
//    }
    
    lazy var control: UIControl = {
        let control = UIControl()
        control.qmui_tapBlock = { [weak self] (_) in
            guard let strongSelf = self else { return }
            if let uid = strongSelf.userModel?.uid {
                YXUGCCommentManager.gotoUserCenter(uid: uid)
            }
        }
        return control
    }()
    
    lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var levelImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage.init(named: "da_V")
        imageView.isHidden = true
        return imageView
    }()
    
    lazy var nickNameLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    lazy var proImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
//    lazy var followButton: QMUIButton = {
//        let button = QMUIButton()
//        button.setBackgroundImage(UIImage.qmui_image(with: UIColor.qmui_color(withHexString: "#0091FF")?.withAlphaComponent(0.1), size: style.buttonSize, cornerRadius: 12), for: .normal)
//        button.setBackgroundImage(UIImage.qmui_image(with: UIColor.qmui_color(withHexString: "#999999")?.withAlphaComponent(0.5), size: style.buttonSize, cornerRadius: 12), for: .selected)
//
//        button.setTitleColor(UIColor.qmui_color(withHexString: "#0091FF"), for: .normal)
//        button.setTitleColor(UIColor.white, for: .selected)
//        button.setTitle(YXLanguageUtility.kLang(key: "ugc_attention"), for: .normal)
//        button.setTitle(YXLanguageUtility.kLang(key: "ugc_attentioned"), for: .selected)
//        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
//        button.isHidden = true
//        button.addTarget(self, action: #selector(followEvent), for: .touchUpInside)
//        return button
//    }()
    
    @objc lazy var descLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    @objc var userModel: YXCreateUserModel? {
        didSet {

            var placeHoderImage:UIImage = UIImage(named: "nav_user") ?? UIImage()
            if style == .normal {
                placeHoderImage = UIImage.init(named:"nav_user") ?? UIImage()
            }

            photoImageView.sd_setImage(with: URL(string: userModel?.avatar ?? ""), placeholderImage: placeHoderImage, options: [], context: [:])
            nickNameLabel.text = userModel?.nickName ?? ""
            
            let auth_user = userModel?.auth_user ?? false
            levelImageView.isHidden = !auth_user
            
            proImageView.isHidden = false
            let pro = userModel?.pro ?? 0
            switch pro {
            case 2:
                proImageView.image = UIImage(named: "VIP2")
            case 4:
                proImageView.image = UIImage(named: "VIP1")
            case 5:
                proImageView.image = UIImage(named: "VIP3")
            default:
                proImageView.isHidden = true
            }
            
//            if isFollow == nil {
//                getFollowStauts()
//            }
        }
    }
    
    var style: PublisherStyle!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc convenience init(style: PublisherStyle) {
        self.init()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(self.followSuccessNoti(_ :)), name: NSNotification.Name(rawValue: YXUserManager.notiFollowAuthorSuccess), object: nil)
        
        self.style = style
        height = style.contentHeight
        if style == .normal {
            nickNameLabel.textColor = QMUITheme().textColorLevel1()
//            followButton.setBackgroundImage(UIImage.qmui_image(withStroke: QMUITheme().textColorLevel1().withAlphaComponent(0.2), size: style.buttonSize, lineWidth: 0, cornerRadius: 12), for: .disabled)
//            followButton.setTitleColor(QMUITheme().textColorLevel3(), for: .disabled)
            descLabel.textColor = QMUITheme().textColorLevel3()
        }
        
        addSubview(photoImageView)
//        addSubview(followButton)
        addSubview(levelImageView)
        addSubview(nickNameLabel)
        addSubview(descLabel)
        addSubview(proImageView)
        addSubview(control)

        photoImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
            make.width.height.equalTo(uniVerLength(40))
        }
        
//        followButton.snp.makeConstraints { make in
//            make.right.equalToSuperview()
//            make.size.equalTo(style.buttonSize)
//            make.centerY.equalTo(photoImageView)
//        }
        
        levelImageView.snp.makeConstraints { (make) in
            make.bottom.equalTo(photoImageView.snp.bottom)
            make.right.equalTo(photoImageView.snp.right)
            make.width.height.equalTo(12)
        }
        
        nickNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(photoImageView.snp.top).offset(-2)
            make.left.equalTo(photoImageView.snp.right).offset(8)
            make.right.equalTo(proImageView.snp.left).offset(-8)
            make.height.equalTo(20)
        }
        
        descLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nickNameLabel.snp.left)
            make.bottom.equalTo(photoImageView.snp.bottom)
            make.height.equalTo(18)
        }
        
        proImageView.snp.makeConstraints { (make) in
            make.right.lessThanOrEqualToSuperview().offset(-12)
            make.width.equalTo(40)
            make.height.equalTo(13)
            make.centerY.equalTo(nickNameLabel)
        }
        
        control.snp.makeConstraints { make in
            make.left.top.bottom.equalTo(photoImageView)
            make.right.equalTo(nickNameLabel.snp.right)
        }
    }
    
//    func getFollowStauts() {
//        if let uid = userModel?.uid, uid != "\(YXUserManager.userUUID())" {
//            let requestModel = YXLiveHasConcernRequestModel()
//            requestModel.target_uid = uid
//            let request = YXRequest(request: requestModel)
//            request.startWithBlock(success: { [weak self] responseModel in
//                if responseModel.code == .success, let boolValue = responseModel.data?["flag"] as? Bool {
//                    self?.followButton.isHidden = false
//                    self?.isFollow = NumberBool(boolValue)
////                    self?.followButton.isHidden = boolValue
//                }
//            }, failure: { _ in
//
//            })
//        }
//    }
    
//    @objc func followEvent() {
//        if let uid = userModel?.uid {
//            if YXUserManager.isLogin() {
//
//                func follow() {
//                    let requestModel = YXLiveConcernRequestModel()
//                    requestModel.target_uid = uid
//                    requestModel.focus_status = followButton.isSelected ? 2 : 1
//                    requestModel.uid = "\(YXUserManager.userUUID())"
//                    let request = YXRequest(request: requestModel)
//                    request.startWithBlock(success: { [weak self] responseModel in
//                        guard let strongSelf = self else { return }
//                        if responseModel.code == .success {
//                            let para = ["uid": uid, "follow": strongSelf.followButton.isSelected ? "2" : "1"]
//                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiFollowAuthorSuccess), object: nil, userInfo: para)
//                        }
//                    }, failure: { _ in
//                    })
//                }
//
//                if followButton.isSelected {
//                    let alertView = YXAlertView.alertView(message: YXLanguageUtility.kLang(key: "confirm_no_follow"))
//                    alertView.clickedAutoHide = true
//                    alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: { action in
//
//                    }))
//
//                    alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_confirm"), style: .default, handler: { action in
//                        follow()
//                    }))
//
//                    alertView.showInWindow()
//                } else {
//                    follow()
//                }
//
//            } else {
//                YXToolUtility.handleBusinessWithLogin {
//
//                }
//            }
//        }
//    }
//
//    @objc func followSuccessNoti(_ noti: Notification) {
//
//        if let uid = noti.userInfo?["uid"] as? String, uid == (userModel?.uid ?? "") {
//            if let follow = noti.userInfo?["follow"] as? String, follow == "1" {
//                self.isFollow = NumberBool(true)
//            } else {
//                self.isFollow = NumberBool(false)
//            }
//        }
//
//    }
}


@objcMembers class YXUGCPublisherHeadView: UIView {
    
    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }

//    dynamic var isFollow: NumberBool? {
//        didSet {
////            if oldValue?.value == false, isFollow?.value == true {
////                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
////                    self?.followButton.isHidden = true
////                }
////            } else {
////                followButton.isHidden = isFollow?.value ?? true
////            }
//            followButton.isSelected = isFollow?.value ?? true
//
//        }
//    }
    
    lazy var control: UIControl = {
        let control = UIControl()
        control.qmui_tapBlock = { [weak self] (_) in
            guard let strongSelf = self else { return }
            if let uid = strongSelf.userModel?.uid {
                YXUGCCommentManager.gotoUserCenter(uid: uid)
            }
        }
        return control
    }()
    
    lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 14
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var levelImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage.init(named: "da_V")
        imageView.isHidden = true
        return imageView
    }()
    
    lazy var nickNameLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    lazy var proImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
//    lazy var followButton: QMUIButton = {
//        let button = QMUIButton()
//        button.setBackgroundImage(UIImage.qmui_image(with: UIColor.qmui_color(withHexString: "#0091FF")?.withAlphaComponent(0.1), size: style.buttonSize, cornerRadius: 12), for: .normal)
//        button.setBackgroundImage(UIImage.qmui_image(with: UIColor.qmui_color(withHexString: "#999999")?.withAlphaComponent(0.5), size: style.buttonSize, cornerRadius: 12), for: .selected)
//
//        button.setTitleColor(UIColor.qmui_color(withHexString: "#0091FF"), for: .normal)
//        button.setTitleColor(UIColor.white, for: .selected)
//        button.setTitle(YXLanguageUtility.kLang(key: "ugc_attention"), for: .normal)
//        button.setTitle(YXLanguageUtility.kLang(key: "ugc_attentioned"), for: .selected)
//        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
//        button.isHidden = true
//        button.addTarget(self, action: #selector(followEvent), for: .touchUpInside)
//        return button
//    }()
    
    @objc lazy var descLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    @objc var userModel: YXCreateUserModel? {
        didSet {

            var placeHoderImage:UIImage = UIImage(named: "nav_user") ?? UIImage()
            if style == .normal {
                placeHoderImage = UIImage.init(named:"nav_user") ?? UIImage()
            }

            photoImageView.sd_setImage(with: URL(string: userModel?.avatar ?? ""), placeholderImage: placeHoderImage, options: [], context: [:])
            nickNameLabel.text = userModel?.nickName ?? ""
            
            let auth_user = userModel?.auth_user ?? false
            levelImageView.isHidden = !auth_user
            
            proImageView.isHidden = false
            let pro = userModel?.pro ?? 0
            switch pro {
            case 2:
                proImageView.image = UIImage(named: "VIP2")
            case 4:
                proImageView.image = UIImage(named: "VIP1")
            case 5:
                proImageView.image = UIImage(named: "VIP3")
            default:
                proImageView.isHidden = true
            }
            
//            if isFollow == nil {
//                getFollowStauts()
//            }
        }
    }
    
    var style: PublisherStyle!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc convenience init(style: PublisherStyle) {
        self.init()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(self.followSuccessNoti(_ :)), name: NSNotification.Name(rawValue: YXUserManager.notiFollowAuthorSuccess), object: nil)
        
        self.style = style
        height = style.contentHeight
        if style == .normal {
            nickNameLabel.textColor = QMUITheme().textColorLevel1()
//            followButton.setBackgroundImage(UIImage.qmui_image(withStroke: QMUITheme().textColorLevel1().withAlphaComponent(0.2), size: style.buttonSize, lineWidth: 0, cornerRadius: 12), for: .disabled)
//            followButton.setTitleColor(QMUITheme().textColorLevel3(), for: .disabled)
            descLabel.textColor = QMUITheme().textColorLevel3()
        }
        
        addSubview(photoImageView)
//        addSubview(followButton)
        addSubview(levelImageView)
        addSubview(nickNameLabel)
//        addSubview(descLabel)
        addSubview(proImageView)
        addSubview(control)

        photoImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
            make.width.height.equalTo(28)
        }
        
//        followButton.snp.makeConstraints { make in
//            make.right.equalToSuperview()
//            make.size.equalTo(style.buttonSize)
//            make.centerY.equalTo(photoImageView)
//        }
        
        levelImageView.snp.makeConstraints { (make) in
            make.bottom.equalTo(photoImageView.snp.bottom)
            make.right.equalTo(photoImageView.snp.right)
            make.width.height.equalTo(12)
        }
        
        nickNameLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(photoImageView.snp.right).offset(8)
            make.right.equalTo(proImageView.snp.left).offset(-8)
            make.height.equalTo(20)
        }
        
//        descLabel.snp.makeConstraints { (make) in
//            make.left.equalTo(nickNameLabel.snp.left)
//            make.bottom.equalTo(photoImageView.snp.bottom)
//            make.height.equalTo(18)
//        }
        
        proImageView.snp.makeConstraints { (make) in
            make.right.lessThanOrEqualToSuperview().offset(-12)
            make.width.equalTo(40)
            make.height.equalTo(13)
            make.centerY.equalTo(nickNameLabel)
        }
        
        control.snp.makeConstraints { make in
            make.left.top.bottom.equalTo(photoImageView)
            make.right.equalTo(nickNameLabel.snp.right)
        }
    }
    
//    func getFollowStauts() {
//        if let uid = userModel?.uid, uid != "\(YXUserManager.userUUID())" {
//            let requestModel = YXLiveHasConcernRequestModel()
//            requestModel.target_uid = uid
//            let request = YXRequest(request: requestModel)
//            request.startWithBlock(success: { [weak self] responseModel in
//                if responseModel.code == .success, let boolValue = responseModel.data?["flag"] as? Bool {
//                    self?.followButton.isHidden = false
//                    self?.isFollow = NumberBool(boolValue)
////                    self?.followButton.isHidden = boolValue
//                }
//            }, failure: { _ in
//
//            })
//        }
//    }
    
//    @objc func followEvent() {
//        if let uid = userModel?.uid {
//            if YXUserManager.isLogin() {
//
//                func follow() {
//                    let requestModel = YXLiveConcernRequestModel()
//                    requestModel.target_uid = uid
//                    requestModel.focus_status = followButton.isSelected ? 2 : 1
//                    requestModel.uid = "\(YXUserManager.userUUID())"
//                    let request = YXRequest(request: requestModel)
//                    request.startWithBlock(success: { [weak self] responseModel in
//                        guard let strongSelf = self else { return }
//                        if responseModel.code == .success {
//                            let para = ["uid": uid, "follow": strongSelf.followButton.isSelected ? "2" : "1"]
//                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiFollowAuthorSuccess), object: nil, userInfo: para)
//                        }
//                    }, failure: { _ in
//                    })
//                }
//
//                if followButton.isSelected {
//                    let alertView = YXAlertView.alertView(message: YXLanguageUtility.kLang(key: "confirm_no_follow"))
//                    alertView.clickedAutoHide = true
//                    alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: { action in
//
//                    }))
//
//                    alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_confirm"), style: .default, handler: { action in
//                        follow()
//                    }))
//
//                    alertView.showInWindow()
//                } else {
//                    follow()
//                }
//
//            } else {
//                YXToolUtility.handleBusinessWithLogin {
//
//                }
//            }
//        }
//    }
//
//    @objc func followSuccessNoti(_ noti: Notification) {
//
//        if let uid = noti.userInfo?["uid"] as? String, uid == (userModel?.uid ?? "") {
//            if let follow = noti.userInfo?["follow"] as? String, follow == "1" {
//                self.isFollow = NumberBool(true)
//            } else {
//                self.isFollow = NumberBool(false)
//            }
//        }
//
//    }
}
