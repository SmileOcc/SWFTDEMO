//
//  YXMineUserHeaderView.swift
//  uSmartOversea
//
//  Created by Mac on 2019/8/30.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

open class CAGradientView: UIView {
    
    override open class var layerClass: AnyClass {
        CAGradientLayer.self
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
//
//        if let gradientLayer = self.layer as? CAGradientLayer {
//            gradientLayer.colors = [UIColor(red: 13/255.0, green: 126/255.0, blue: 204/255.0, alpha: 1).cgColor, UIColor(red: 43/255.0, green: 79/255.0, blue: 128/255.0, alpha: 1).cgColor]
//            gradientLayer.locations = [0, 1]
//            gradientLayer.startPoint = CGPoint(x: 0.31, y: -0.13)
//            gradientLayer.endPoint = CGPoint(x: 0.62, y: 0.81)
//        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        let imageView = UIImageView.init()
        imageView.image = UIImage(named: "trade_hold")
        addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class YXMineUserProBtn: UIButton {
    
    var bgLayer1 = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // fillCode
        bgLayer1.colors = [UIColor(red: 0.4, green: 0.76, blue: 1, alpha: 1).cgColor, UIColor(red: 0.03, green: 0.12, blue: 0.49, alpha: 1).cgColor]
        bgLayer1.locations = [0, 1]
        
        bgLayer1.startPoint = CGPoint(x: 0.13, y: 0)
        bgLayer1.endPoint = CGPoint(x: 1, y: 1)
        
        self.layer.addSublayer(bgLayer1)
        
        self.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        self.setTitleColor(UIColor.white, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        bgLayer1.frame = self.bounds
        
    }
}


extension YXMineUserHeaderView {
    fileprivate func marketImageView() -> UIImageView {
        let imageView = UIImageView()
        return imageView
    }
    fileprivate func marketLabel() -> UILabel {
        let lab = QMUILabel()
        lab.font = UIFont.systemFont(ofSize: uniSize(12))
        lab.textColor = QMUITheme().textColorLevel1()
        lab.numberOfLines = 0
        return lab
    }
}

class YXMineUserHeaderView: UIView {
    let MINE_USER_HEADER_IMAGE_WIDTH: CGFloat = 60
    let MINE_USER_HEADER_IMAGE_HEIGHT: CGFloat = 60
    
    /// 头像
    lazy var accountImgView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "user_default_photo"))
        iv.layer.cornerRadius = 30
        iv.layer.masksToBounds = true
        iv.backgroundColor = UIColor.qmui_color(withHexString: "#E4E3E3")
        return iv
    }()
    
    //点击登录
    var loginBtn: QMUIButton = {
        let btn = QMUIButton()
        btn.setTitle(YXLanguageUtility.kLang(key: "user_clickLogin"), for: .normal)
        btn.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        btn.setImage(UIImage.qmui_image(with: .triangle, size: CGSize(width: 12, height: 8), tintColor: QMUITheme().themeTextColor())?.qmui_image(with: .right), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        btn.imagePosition = .right
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
        return btn
    }()
    //账号
    var accountLab: UILabel = {
        let lab = QMUILabel()
        lab.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        lab.textColor = QMUITheme().textColorLevel1()
        lab.numberOfLines = 0
        lab.lineBreakMode = .byTruncatingMiddle
        lab.textAlignment = .center
        return lab
    }()
    lazy var loginHorLine:UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().textColorLevel1()
        return view
    }()  //已登录视图的白色区域的横线

    
    lazy var proButton: YXMineUserProBtn = {
        let button = YXMineUserProBtn()
        
        button.layer.cornerRadius = 9
        button.layer.masksToBounds = true
        
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.3
        return button
    }()
    
    lazy var smartScoreViewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = UIColor.qmui_color(withHexString: "#FA6400")
        label.text = "--"
        return label
    }()
    
    lazy var smartScoreView: UIView = {
        let view = UIView()
        
        let tap = UITapGestureRecognizer.init(actionBlock: { [weak self] _ in
            YXWebViewModel.pushToWebVC(YXH5Urls.smartScoreUrl())
        })
        view.addGestureRecognizer(tap)
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "smart_score")
        
        view.addSubview(imageView)
        view.addSubview(smartScoreViewLabel)
        
        imageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(18)
        }
        smartScoreViewLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(25)
        }
        
        return view
    }()

    
    //MARK: 市场标签
    //=== 港股
    lazy var hkImageView: UIImageView = self.marketImageView()
    lazy var hkStockLab: UILabel = self.marketLabel()
    //=== 美股
    lazy var usImageView: UIImageView = self.marketImageView()
    lazy var usStockLab: UILabel = self.marketLabel()
    //=== A股
    lazy var hsImageView: UIImageView = self.marketImageView()
    lazy var hsStockLab: UILabel = self.marketLabel()
    
    //用于响应点击
    let centBotLoginBtn: UIButton = UIButton(type: .custom)
    
    let proControl = UIControl.init()
    
    lazy var centBotLab: UILabel = {
        let lab = UILabel()
        //lab.text = YXLanguageUtility.kLang(key: "me_login_get_quote")
        lab.textColor = QMUITheme().textColorLevel1()
        lab.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lab.textAlignment = .left
        lab.numberOfLines = 0
        return lab
    }()
    
    
    lazy var proLeveLab: UILabel = {
        let lab = UILabel()
        //lab.text = YXLanguageUtility.kLang(key: "me_login_get_quote")
        lab.textColor = QMUITheme().textColorLevel3()
        lab.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lab.textAlignment = .left
        lab.numberOfLines = 0
        return lab
    }()
    
    lazy var proTipLab: UILabel = {
        let lab = UILabel()
        //lab.text = YXLanguageUtility.kLang(key: "me_login_get_quote")
        lab.textColor = QMUITheme().themeTextColor()
        lab.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lab.textAlignment = .left
        lab.numberOfLines = 0
        return lab
    }()
    
    lazy var centerLoginView: UIView = {
        //中间的白框
        let centerView = UIView()
        centerView.backgroundColor = QMUITheme().foregroundColor()
        centerView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        centerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        centerView.layer.shadowOpacity = 1
        centerView.layer.shadowRadius = 4
        centerView.layer.cornerRadius = 8
        addSubview(centerView)
        
        //MARK: 登录视图
        /// 头像
        centerView.addSubview(accountImgView)
        accountImgView.snp.remakeConstraints { (make) in
            make.left.top.equalToSuperview().offset(10)
            make.size.equalTo(CGSize(width: MINE_USER_HEADER_IMAGE_WIDTH, height: MINE_USER_HEADER_IMAGE_HEIGHT))
        }
        //账号
        centerView.addSubview(accountLab)
        centerView.addSubview(smartScoreView)
        
        accountLab.snp.makeConstraints { (make) in
            make.left.equalTo(accountImgView.snp.right).offset(20)
            make.top.equalTo(accountImgView)
            make.height.equalTo(22)
        }
        
        smartScoreView.snp.makeConstraints { (make) in
            make.left.equalTo(accountLab.snp.right).offset(8)
            make.right.lessThanOrEqualToSuperview().offset(-5)
            make.centerY.equalTo(accountLab)
            make.width.equalTo(60)
            make.height.equalTo(20)
        }
        
        centerView.addSubview(self.proLeveLab)
        proLeveLab.snp.makeConstraints { (make) in
            make.left.equalTo(accountImgView.snp.right).offset(20)
            make.height.equalTo(17)
            make.top.equalTo(accountLab.snp.bottom)
            make.right.equalToSuperview().offset(-20)
        }
                
        //pro标签
        centerView.addSubview(proButton)
        proButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-12)
            make.width.equalTo(54)
            make.height.equalTo(18)
            make.bottom.equalToSuperview().offset(-40)
        }
        
        centerView.addSubview(self.proTipLab)
        proTipLab.snp.makeConstraints { (make) in
            make.left.equalTo(accountImgView.snp.right).offset(20)
            make.bottom.equalToSuperview().offset(-40)
            make.right.lessThanOrEqualTo(proButton.snp.right).offset(-12)
        }
                
        //横线
        centerView.addSubview(loginHorLine)
        loginHorLine.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(accountImgView.snp.bottom).offset(10)
        }
        
        //点击响应
        centerView.addSubview(centBotLoginBtn)
        centBotLoginBtn.snp.makeConstraints({ (make) in
            make.top.equalTo(loginHorLine.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        })
        
        //MARK: 未登录视图
        //点击登录
        centerView.addSubview(loginBtn)
        loginBtn.snp.makeConstraints { (make) in
            make.left.equalTo(accountImgView.snp.right).offset(20)
            make.top.equalTo(accountImgView).offset(7)
            
        }
        
        
        centerView.addSubview(centBotLab)
        centBotLab.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.left.equalTo(loginBtn)
            make.top.equalTo(loginBtn.snp.bottom).offset(8)
        }
        
        //MARK: 公共部分
        let verSpace = 7.0
        let imgWidth: CGFloat = 22.0
        let imgHeight: CGFloat = 15.0
        //港股
        centerView.addSubview(hkImageView)
        hkImageView.snp.makeConstraints({ (make) in
            make.left.equalToSuperview().offset(10)
            make.top.equalTo(loginHorLine.snp.bottom).offset(verSpace)
            make.width.equalTo(imgWidth)
            make.height.equalTo(imgHeight)
            make.bottom.equalToSuperview().offset(-verSpace)
        })
        centerView.addSubview(hkStockLab)
        hkStockLab.snp.makeConstraints({ (make) in
            make.left.equalTo(hkImageView.snp.right).offset(uniHorLength(5))
            make.centerY.equalTo(hkImageView)
        })
        //美股
        centerView.addSubview(usImageView)
        usImageView.snp.makeConstraints({ (make) in
            make.left.equalTo(hkStockLab.snp.right).offset(10)
            make.top.equalTo(loginHorLine.snp.bottom).offset(verSpace)
            make.width.equalTo(imgWidth)
            make.height.equalTo(imgHeight)
            make.bottom.equalToSuperview().offset(-verSpace)
        })
        centerView.addSubview(usStockLab)
        usStockLab.snp.makeConstraints({ (make) in
            make.left.equalTo(usImageView.snp.right).offset(uniHorLength(5))
            make.centerY.equalTo(usImageView)
        })
        //A股
        centerView.addSubview(hsImageView)
        hsImageView.snp.makeConstraints({ (make) in
            make.left.equalTo(usStockLab.snp.right).offset(10)
            make.top.equalTo(loginHorLine.snp.bottom).offset(verSpace)
            make.width.equalTo(imgWidth)
            make.height.equalTo(imgHeight)
            make.bottom.equalToSuperview().offset(-verSpace)
        })
        centerView.addSubview(hsStockLab)
        hsStockLab.snp.makeConstraints({ (make) in
            make.left.equalTo(hsImageView.snp.right).offset(uniHorLength(5))
            make.centerY.equalTo(hsImageView)
        })
        
        centerView.addSubview(self.proControl)
        proControl.snp.makeConstraints { (make) in
            make.left.top.equalTo(proLeveLab)
            make.bottom.right.equalTo(proButton)
        }
        
        return centerView
    }()
    //渐变背景
    let layerView = CAGradientView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func initialUI() {
        self.backgroundColor = .clear
        self.clipsToBounds = true //把渐变向上延伸出来的部分截取掉
        //渐变背景
        var layerHeight = uniVerLength(96)
        if YXConstant.screenHeight < 812.0 {
            layerHeight = 96
        }
        layerView.frame = CGRect(x: 0, y: -YXConstant.navBarHeight(), width: YXConstant.screenWidth, height: YXConstant.navBarHeight() + layerHeight)
        addSubview(layerView)
        //底部白色遮罩view
        let botWhiteView = UIView()
        botWhiteView.backgroundColor = QMUITheme().foregroundColor()
        addSubview(botWhiteView)
        botWhiteView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(layerView.snp.bottom)
        }
        
        centerLoginView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(uniHorLength(18))
            make.right.equalToSuperview().offset(-uniHorLength(18))
            make.top.equalToSuperview().offset(15)
//            make.bottom.lessThanOrEqualToSuperview().offset(-5)
            make.height.equalTo(111)
            
        }
        
        proControl.addTarget(self, action: #selector(self.proControlClick(_:)), for: .touchUpInside)
    }
    
    func updateCentBotLab(with text: String?) {
        if let t = text {
            centBotLab.text = t
        }
    }
    
    @objc func proControlClick(_ sender: UIControl) {
        self.proButton.sendActions(for: .touchUpInside)
    }
    
    //更新头部视图
    func updateView() {
        //已登录
        if YXUserManager.isLogin() {
            //显示和隐藏
            accountLab.isHidden = false
            proButton.isHidden = false
            proLeveLab.isHidden = false
            proTipLab.isHidden = false
            proControl.isHidden = false
            smartScoreView.isHidden = false
            
            loginBtn.isHidden = true
            centBotLab.isHidden = true
            //昵称
            self.accountLab.text = YXUserManager.shared().curLoginUser?.nickname
            //头像
            if let avatarName = YXUserManager.shared().curLoginUser?.avatar {
                
                let transformer = SDImageResizingTransformer(size: CGSize(width: MINE_USER_HEADER_IMAGE_WIDTH * UIScreen.main.scale, height: MINE_USER_HEADER_IMAGE_HEIGHT * UIScreen.main.scale), scaleMode: .aspectFill)
                accountImgView.sd_setImage(with: URL(string: avatarName), placeholderImage: UIImage(named: "user_default_photo"), options: [], context: [SDWebImageContextOption.imageTransformer: transformer], progress: nil, completed: { [weak self] (image, error, cacheType, url) in
                    guard let `self` = self else { return }
                    
                    if error == nil {
                        let tempImage = image?.drawCorner(in: CGRect(x: 0, y: 0, width: self.MINE_USER_HEADER_IMAGE_WIDTH, height: self.MINE_USER_HEADER_IMAGE_HEIGHT), cornerRadius: CGFloat(self.MINE_USER_HEADER_IMAGE_WIDTH / 2))
                        self.accountImgView.image = tempImage
                    }
                })
            } else {//默认头像
                accountImgView.image = UIImage(named: "user_default_photo")
            }
            
            proTipLab.text = YXUserManager.shared().goProTip
            
            let type = YXUserManager.getProLevel()
            if type == .common {
                proLeveLab.text = YXLanguageUtility.kLang(key: "pro_account_standard")
                self.proButton.setTitle(YXLanguageUtility.kLang(key: "upgrade_immediately"), for: .normal)
            } else if type == .level1 {
                proLeveLab.text = YXLanguageUtility.kLang(key: "pro_account_v1")
                self.proButton.setTitle(YXLanguageUtility.kLang(key: "see_detail"), for: .normal)
            } else {
                proLeveLab.text = YXLanguageUtility.kLang(key: "pro_account_v2")
                self.proButton.setTitle(YXLanguageUtility.kLang(key: "see_detail"), for: .normal)
            }
            
            if type == .common && YXUserManager.isENMode() {
                self.proButton.snp.updateConstraints { (make) in
                    make.width.equalTo(70)
                }
            } else {
                self.proButton.snp.updateConstraints { (make) in
                    make.width.equalTo(54)
                }
            }
                                    
        } else {
            //显示和隐藏
            accountLab.isHidden = true
            proButton.isHidden = true
            proLeveLab.isHidden = true
            proTipLab.isHidden = true
            proControl.isHidden = true
            smartScoreView.isHidden = true
            
            loginBtn.isHidden = false
            centBotLab.isHidden = false
            
            accountImgView.image = UIImage(named: "user_default_photo")
        }
        
        
        //调整 loginBtn 和 centBotLab 的 UI
        if centBotLab.isHidden == false, let centBotText = centBotLab.text, centBotText.isNotEmpty() {
            loginBtn.snp.remakeConstraints { (make) in
                make.left.equalTo(accountImgView.snp.right).offset(20)
                make.top.equalTo(accountImgView).offset(7)
            }
            
            centBotLab.snp.remakeConstraints { (make) in
                make.right.equalToSuperview()
                make.left.equalTo(loginBtn)
                make.top.equalTo(loginBtn.snp.bottom).offset(8)
            }
        } else {
            loginBtn.snp.remakeConstraints { (make) in
                make.left.equalTo(accountImgView.snp.right).offset(20)
                make.centerY.equalTo(accountImgView)
            }
        }
        
        //HK
        if let hk = YXUserManager.shared().curLoginUser?.highestUserQuotationVOList?.hk {
            hkStockLab.text = hk.shorterName
        } else {
            let (text,_) = self.getQuoteVOText(with: kYXMarketHK)
            hkStockLab.text = text
        }
        hkImageView.image = getImage(name: "flag_hk")
        //US
        if let usa = YXUserManager.shared().curLoginUser?.highestUserQuotationVOList?.usa {
            usStockLab.text = usa.shorterName
        } else {
            let (text,_) = self.getQuoteVOText(with: kYXMarketUS)
            usStockLab.text = text
        }
        usImageView.image = getImage(name: "flag_us")
        //A股
        if let zht = YXUserManager.shared().curLoginUser?.highestUserQuotationVOList?.zht {
            hsStockLab.text = zht.shorterName
        } else {
            let (text,_) = self.getQuoteVOText(with: kYXMarketHS)
            hsStockLab.text = text
        }
        hsImageView.image = getImage(name: "flag_cn")
    }
    
    //获取权限文字
    private func getQuoteVOText(with market: String) -> (String,QuoteLevel) {
        let quoteLevel:QuoteLevel =  YXUserManager.shared().getHighestUserLevel(with: market)
        if quoteLevel == .level2 {
            return (YXLanguageUtility.kLang(key: "user_quote_lv2"), .level2)       //LV2
        } else if quoteLevel == .bmp {
            return (YXLanguageUtility.kLang(key: "user_quote_bmp"), .bmp)        //BMP
        } else if quoteLevel == .level1 {
            return (YXLanguageUtility.kLang(key: "user_quote_lv1"), .level1)      //LV1
        }
        return (YXLanguageUtility.kLang(key: "user_quote_delayed"), .delay)
    }
}



