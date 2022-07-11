//
//  YXStockAskBidQuoteButton.swift
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2022/1/12.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import FLAnimatedImage

enum QuoteMenuStatusType {
    case normal
    case select
    case disable
}

extension YXUSPosQuoteType {
    var title: String {
        switch self {
        case .nsdq:
            return "NSDQ"
        case .usNation:
            return "National"
        default:
            return ""
        }
    }
    
    var imageStr: String {
        switch self {
        case .nsdq:
            return "ask_nsdq_logo"
        case .usNation:
            return "ask_usnation_logo"
        default:
            return ""
        }
    }
    
    var status: QuoteMenuStatusType {
        switch self {
        case .nsdq:
            let levle = YXUserManager.usNsdqLevel()
            if levle == .usLevel1 {
                return .normal
            }
            return .disable
        case .usNation:
            let levle = YXUserManager.shared().getLevel(with: "us")
            if levle == .usNational {
                return .normal
            }
            return .disable
        default:
            return .disable
        }
    }
}


class YXStockUsNationChangeView: UIView {
    
    @objc var posQuoteType: YXUSPosQuoteType = .none {
        didSet {
            if posQuoteType == .nsdq {
                self.nsdqBtn.isSelected = true
                self.usNationBtn.isSelected = false
            } else {
                self.nsdqBtn.isSelected = false
                self.usNationBtn.isSelected = true
            }
        }
    }

    @objc var clickItemBlock: ((_ selectIndex: Int) -> Void)?
    
    lazy var nsdqBtn: QMUIButton = {
        let btn = QMUIButton.init(type: .custom)
        btn.setTitle(YXUSPosQuoteType.nsdq.title, for: .normal)
        btn.setImage(UIImage(named: "ask_nsdq_logo"), for: .normal)
        btn.setImage(UIImage(named: "ask_nsdq_logo_select"), for: .selected)
        btn.setTitleColor(QMUITheme().themeTintColor(), for: .selected)
        btn.setTitleColor(QMUITheme().textColorLevel4(), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.imagePosition = .left
        btn.spacingBetweenImageAndTitle = 4
        btn.contentHorizontalAlignment = .right
        btn.qmui_tapBlock = { [weak self] sender in
            guard !(sender?.isSelected ?? false) else { return }
            self?.selectQuote(with: .nsdq)
        }
        return btn
    }()
    
    lazy var usNationBtn: QMUIButton = {
        let btn = QMUIButton.init(type: .custom)
        btn.setTitle(YXUSPosQuoteType.usNation.title, for: .normal)
        btn.setImage(UIImage(named: "ask_usnation_logo"), for: .normal)
        btn.setImage(UIImage(named: "ask_usnation_logo_select"), for: .selected)
        btn.setTitleColor(QMUITheme().themeTintColor(), for: .selected)
        btn.setTitleColor(QMUITheme().textColorLevel4(), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.imagePosition = .left
        btn.spacingBetweenImageAndTitle = 4
        btn.contentHorizontalAlignment = .left
        btn.qmui_tapBlock = { [weak self] sender in
            guard !(sender?.isSelected ?? false) else { return }
            self?.selectQuote(with: .usNation)
        }
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        
        self.posQuoteType = YXStockDetailUtility.getUsAskBidSelect()
        
        let lineView = UIView()
        lineView.backgroundColor = QMUITheme().separatorLineColor()
        
        addSubview(lineView)
        addSubview(nsdqBtn)
        addSubview(usNationBtn)
        
        lineView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(16)
            make.width.equalTo(1)
            make.centerY.equalToSuperview()
        }
        
        nsdqBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(lineView.snp.left).offset(-8)
            make.height.equalTo(20)
//            make.left.greaterThanOrEqualToSuperview().offset(8)
        }
        usNationBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(lineView.snp.right).offset(8)
            make.height.equalTo(20)
//            make.right.lessThanOrEqualToSuperview().offset(-8)
        }
        
    }
    
    func selectQuote(with type: YXUSPosQuoteType) {
        YXStockDetailUtility.setUsAskBidSelect(type)
        // 刷新View
        self.posQuoteType = type
        self.clickItemBlock?(type.rawValue)
    }
    
    @objc func resetPosQuote() {
        // 重置按钮的状态
        self.posQuoteType = YXStockDetailUtility.getUsAskBidSelect()
    }
}

class YXStockUsNationChangeTipView: UIView {
    
    lazy var bgImageView: FLAnimatedImageView = {
        let imageView = FLAnimatedImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
                
        if let path = Bundle.main.path(forResource: "askAndBid".themeSuffix, ofType: "gif"),
           let data = try? Data.init(contentsOf: URL(fileURLWithPath: path)) {
            let image = FLAnimatedImage(animatedGIFData: data)
            imageView.animatedImage = image
        }
        
        return imageView
    }()
    
    @objc var posQuoteType: YXUSPosQuoteType = .usNation {
        didSet {
            let status = posQuoteType.status
            if status == .disable {
                self.isHidden = false
                if posQuoteType == .nsdq {
                    self.titleLabel.text = YXLanguageUtility.kLang(key: "us_quote_tip2")
                } else {
                    self.titleLabel.text = YXLanguageUtility.kLang(key: "usnation_tip_des")
                }
            } else {
                self.isHidden = true
            }
        }
    }
    
    lazy var accessBtn: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setTitle(YXLanguageUtility.kLang(key: "depth_order_get"), for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 4
        btn.clipsToBounds = true
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.backgroundColor = QMUITheme().themeTextColor()
        btn.qmui_tapBlock = { [weak self] sender in
            guard !(sender?.isSelected ?? false) else { return }
            var levelType: Int = 0
            if self?.posQuoteType == .usNation {
                levelType = 1
            }
            YXWebViewModel.pushToWebVC(YXH5Urls.YX_MY_QUOTES_URL(tab: 1))
        }
        
        return btn
    }()
    
    let titleLabel = UILabel.init(text: "--", textColor: QMUITheme().textColorLevel1(), textFont: UIFont.systemFont(ofSize: 14))!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        
        titleLabel.numberOfLines = 2
                
        addSubview(bgImageView)
        addSubview(accessBtn)
        addSubview(titleLabel)

        bgImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        accessBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-32)
            make.centerY.equalToSuperview()
            make.width.equalTo(70)
            make.height.equalTo(32)
        }
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(32)
            make.right.lessThanOrEqualTo(accessBtn.snp.left).offset(-32)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if let path = Bundle.main.path(forResource: "askAndBid".themeSuffix, ofType: "gif"),
           let data = try? Data.init(contentsOf: URL(fileURLWithPath: path)) {
            let image = FLAnimatedImage(animatedGIFData: data)
            bgImageView.animatedImage = image
        }
    }
}
