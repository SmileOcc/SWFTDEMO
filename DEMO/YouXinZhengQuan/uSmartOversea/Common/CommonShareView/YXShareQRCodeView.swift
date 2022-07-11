//
//  YXShareQRCodeView.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2021/10/28.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXShareQRCodeView: UIView {
    
    var config: YXShareConfig = YXShareConfig()
    
    convenience init(config: YXShareConfig) {
        self.init(frame: .zero, config: config)
    }
    
    init(frame: CGRect, config: YXShareConfig) {
        super.init(frame: frame)
        self.config = config
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        self.backgroundColor = UIColor.themeColor(withNormalHex: "#F6F6F6", andDarkColor: "#292933")
        
        if config.followLogin, YXUserManager.isLogin() {
            addSubview(loginView)
            loginView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        } else {
            addSubview(unLoginView)
            unLoginView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
    }
    
  
    lazy var unLoginView: YXShareQRCodeUnLoginView = {
        let view = YXShareQRCodeUnLoginView(config: self.config)
        
        return view
    }()
    
    lazy var loginView: YXShareQRCodeLoginView = {
        let view = YXShareQRCodeLoginView(config: self.config)
        
        return view
    }()
}

class YXShareQRCodeUnLoginView: UIView {
    
    var config: YXShareConfig = YXShareConfig()
    
    convenience init(config: YXShareConfig) {
        self.init(frame: .zero, config: config)
    }
    
    init(frame: CGRect, config: YXShareConfig) {
        super.init(frame: frame)
        self.config = config
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        self.backgroundColor = UIColor.themeColor(withNormalHex: "#F8F9FC", andDarkColor: "#292933")
        addSubview(leftIconView)
        addSubview(leftImageView)
        addSubview(leftDescLabel)
//        addSubview(rightImageView)
        addSubview(rightLabelImageView)
        
        addSubview(qrBackgroundView)
        qrBackgroundView.addSubview(rightImageView)
//        rightImageView.addSubview(logoImageView)

        var scale: CGFloat = 1.0
        let realWidth: CGFloat = YXConstant.screenWidth - config.lrMargin * 2
        if realWidth < 375 {
            scale = realWidth / 375.0
        }
        
        leftIconView.snp.makeConstraints { (make) in
            make.width.equalTo(28 * scale)
            make.height.equalTo(28 * scale)
            make.left.equalToSuperview().offset(12 * scale)
            make.centerY.equalToSuperview()
        }
        

        leftImageView.snp.makeConstraints { (make) in
            make.width.equalTo(67 * scale)
            make.height.equalTo(12 * scale)
            make.left.equalTo(leftIconView.snp.right).offset(8)
            make.bottom.equalTo(leftIconView.snp.centerY).offset(-2)
        }
        
        leftDescLabel.snp.makeConstraints { make in
            make.left.equalTo(leftIconView.snp.right).offset(8)
            make.top.equalTo(leftIconView.snp.centerY).offset(4)
        }
        
        qrBackgroundView.snp.makeConstraints { (make) in
            make.width.equalTo(32)
            make.height.equalTo(32)
            make.right.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
        }
        
        rightImageView.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().offset(2)
            make.right.bottom.equalToSuperview().offset(-2)
        }

//        logoImageView.snp.makeConstraints { (make) in
//            make.center.equalToSuperview()
//            make.size.equalTo(CGSize.init(width: 6, height: 6))
//        }

//        rightLabelImageView.snp.makeConstraints { (make) in
//            make.centerY.equalToSuperview()
//            make.right.equalTo(rightImageView.snp.left).offset(-8 * scale)
//            make.width.equalTo(114 * scale)
//            make.height.equalTo(38 * scale)
//        }
        
        
        leftImageView.image = UIImage(named: "share_logo")
        leftIconView.image = UIImage(named: "share_logo_icon")?.byRoundCornerRadius(4)

        if let qrImage = YXQRCodeHelper.qrCodeImage(with: config.shortUrl) {
            rightImageView.image = qrImage
        } else if let qrImage = YXQRCodeHelper.qrCodeImage(with: config.longUrl) {
            rightImageView.image = qrImage
        } else {
            let qrCodeImage = YXToolUtility.createCodeImage(YXH5Urls.jumpRegisterUrl())
            rightImageView.image = qrCodeImage
        }
        switch YXUserManager.curLanguage() {
        case .EN:
            rightLabelImageView.image = UIImage(named: "share_en_Label")
        case .CN:
            rightLabelImageView.image = UIImage(named: "share_cn_Label")
        case .HK:
            rightLabelImageView.image = UIImage(named: "share_cn_Label")
        default:
            rightLabelImageView.image = UIImage(named: "share_en_Label")
        }
    }
    
    lazy var leftIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    lazy var leftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    lazy var leftDescLabel: UILabel = {
        let lab = UILabel()
        lab.text = YXLanguageUtility.kLang(key: "learning_intelligence_community")
        lab.font = UIFont.systemFont(ofSize: 10)
        lab.textColor = QMUITheme().textColorLevel2()
        return lab
    }()
    
    lazy var rightImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    lazy var rightLabelImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    lazy var logoImageView : UIImageView = {
        let logoImgView = UIImageView(image: UIImage(named: "icon"))
        return logoImgView
    }()
    
    lazy var qrBackgroundView : UIView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.backgroundColor = .white
        return view
    }()
    
}


//class YXShareQRCodeUnLoginView: UIView {
//
//    var config: YXShareConfig = YXShareConfig()
//
//    convenience init(config: YXShareConfig) {
//        self.init(frame: .zero, config: config)
//    }
//
//    init(frame: CGRect, config: YXShareConfig) {
//        super.init(frame: frame)
//        self.config = config
//        initUI()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func initUI() {
//        self.backgroundColor = UIColor.qmui_color(withHexString: "#F6F6F6")
//
//        addSubview(leftImageView)
//        addSubview(rightImageView)
//        addSubview(rightLabelImageView)
//        addSubview(qrBackgroundView)
//        qrBackgroundView.addSubview(rightImageView)
//        rightImageView.addSubview(logoImageView)
//
//        var scale: CGFloat = 1.0
//        let realWidth: CGFloat = YXConstant.screenWidth - config.lrMargin * 2
//        if realWidth < 375 {
//            scale = realWidth / 375.0
//        }
//
//        leftImageView.snp.makeConstraints { (make) in
//            make.width.equalTo(143 * scale)
//            make.height.equalTo(27 * scale)
//            make.left.equalToSuperview().offset(16 * scale)
//            make.centerY.equalToSuperview()
//        }
//
//        qrBackgroundView.snp.makeConstraints { (make) in
//            make.width.equalTo(48)
//            make.height.equalTo(48)
//            make.right.equalToSuperview().offset(-8)
//            make.centerY.equalToSuperview()
//        }
//
//        rightImageView.snp.makeConstraints { (make) in
//            make.left.top.equalToSuperview().offset(2)
//            make.right.bottom.equalToSuperview().offset(-2)
//        }
//
//        logoImageView.snp.makeConstraints { (make) in
//            make.center.equalToSuperview()
//            make.size.equalTo(CGSize.init(width: 6, height: 6))
//        }
//
//        rightLabelImageView.snp.makeConstraints { (make) in
//            make.centerY.equalToSuperview()
//            make.right.equalTo(rightImageView.snp.left).offset(-8 * scale)
//            make.width.equalTo(114 * scale)
//            make.height.equalTo(38 * scale)
//        }
//
//
//        leftImageView.image = UIImage(named: "share_logo")
//        if let qrImage = YXQRCodeHelper.qrCodeImage(with: config.shortUrl) {
//            rightImageView.image = qrImage
//        } else if let qrImage = YXQRCodeHelper.qrCodeImage(with: config.longUrl) {
//            rightImageView.image = qrImage
//        } else {
//            let qrCodeImage = YXToolUtility.createCodeImage(YXH5Urls.jumpRegisterUrl())
//            rightImageView.image = qrCodeImage
//        }
//        switch YXUserManager.curLanguage() {
//        case .EN:
//            rightLabelImageView.image = UIImage(named: "share_en_Label")
//        case .CN:
//            rightLabelImageView.image = UIImage(named: "share_cn_Label")
//        default:
//            rightLabelImageView.image = UIImage(named: "share_hk_Label")
//        }
//    }
//
//
//    lazy var leftImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleToFill
//        return imageView
//    }()
//
//    lazy var rightImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleToFill
//        return imageView
//    }()
//
//    lazy var rightLabelImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleToFill
//        return imageView
//    }()
//
//    lazy var logoImageView : UIImageView = {
//        let logoImgView = UIImageView(image: UIImage(named: "icon"))
//        return logoImgView
//    }()
//
//    lazy var qrBackgroundView : UIView = {
//        let view = UIImageView()
//        view.clipsToBounds = true
//        view.backgroundColor = .white
//        return view
//    }()
//
//}


class YXShareQRCodeLoginView: UIView {
    
    
    var config: YXShareConfig = YXShareConfig()
    
    convenience init(config: YXShareConfig) {
        self.init(frame: .zero, config: config)
    }
    
    init(frame: CGRect, config: YXShareConfig) {
        super.init(frame: frame)
        self.config = config
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initUI()  {
        
        self.backgroundColor = UIColor.qmui_color(withHexString: "#EAEEF7")

        addSubview(avaterView)
        addSubview(nickNameLabel)
        addSubview(descLabel)
        addSubview(qrBackgroundView)
        qrBackgroundView.addSubview(qrImageView)
        qrImageView.addSubview(logoImageView)
        
        var scale: CGFloat = 1.0
        let realWidth: CGFloat = YXConstant.screenWidth - config.lrMargin * 2
        if realWidth < 375 {
            scale = realWidth / 375.0
        }

        avaterView.snp.makeConstraints { (make) in
            make.width.equalTo(36 * scale)
            make.height.equalTo(36 * scale)
            make.left.equalToSuperview().offset(10 * scale)
            make.centerY.equalToSuperview()
        }
    
        avaterView.layer.cornerRadius = 18 * scale
        
        nickNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(avaterView.snp.right).offset(8*scale)
            make.bottom.equalTo(avaterView.snp.centerY).offset(-1)
            make.height.equalTo(20*scale)
            make.right.equalTo(qrBackgroundView.snp.left).offset(-5)
        }
        nickNameLabel.font = .systemFont(ofSize: 14 * scale)
        
        descLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nickNameLabel)
            make.top.equalTo(avaterView.snp.centerY).offset(1)
            make.right.equalTo(qrBackgroundView.snp.left).offset(-5)
        }
        descLabel.font = .systemFont(ofSize: 12 * scale)
        
        descLabel.text = config.desc
        
        qrBackgroundView.snp.makeConstraints { (make) in
            make.centerY.equalTo(avaterView)
            make.size.equalTo(CGSize.init(width: 48, height: 48))
            make.right.equalTo(-10*scale)
        }
        
        qrBackgroundView.layer.cornerRadius = 4 * scale
        
        qrImageView.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().offset(2)
            make.right.bottom.equalToSuperview().offset(-2)
        }
        
        logoImageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 6, height: 6))
        }
        
        if let qrImage = YXQRCodeHelper.qrCodeImage(with: config.shortUrl) {
            qrImageView.image = qrImage
        } else if let qrImage = YXQRCodeHelper.qrCodeImage(with: config.longUrl) {
            qrImageView.image = qrImage
        } else {
            let qrCodeImage = YXToolUtility.createCodeImage(YXH5Urls.jumpRegisterUrl())
            qrImageView.image = qrCodeImage
        }
        
        avaterView.sd_setImage(with: URL.init(string: YXUserManager.shared().curLoginUser?.avatar ?? ""), placeholderImage: UIImage.init(named: "user_default_photo"), options: .retryFailed, context: nil)
        nickNameLabel.text = YXUserManager.shared().curLoginUser?.nickname
        
    }
    

    lazy var avaterView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var nickNameLabel: UILabel = {
        let nickNameLab = UILabel()
        nickNameLab.textAlignment = .left
        nickNameLab.textColor = QMUITheme().textColorLevel1()
        nickNameLab.font = .systemFont(ofSize: 14)
        return nickNameLab
    }()
    
    lazy var descLabel: UILabel = {
        let descLable = UILabel()
        descLable.textAlignment = .left
        descLable.textColor = QMUITheme().themeTextColor()
        descLable.font = .systemFont(ofSize: 12)
        descLable.numberOfLines = 0
        descLable.lineBreakMode = .byWordWrapping
        //descLable.text = YXLanguageUtility.kLang(key: "stock_share_tip")
        return descLable
    }()
    
    lazy var qrImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    lazy var logoImageView : UIImageView = {
        let logoImgView = UIImageView(image: UIImage(named: "icon"))
        return logoImgView
    }()
    
    lazy var qrBackgroundView : UIView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.backgroundColor = UIColor.qmui_color(withHexString: "#EAEEF7")
        return view
    }()
}

