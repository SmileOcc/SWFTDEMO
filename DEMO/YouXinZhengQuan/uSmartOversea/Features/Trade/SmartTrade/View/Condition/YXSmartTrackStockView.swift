//
//  YXSmartTrackStockView.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2022/6/8.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXSmartTrackStockView: UIView, YXTradeHeaderSubViewProtocol {
    
    typealias ClickBlock = () -> Void
    @objc var clickBlock: ClickBlock?
    @objc var refreshBlock: ClickBlock?
    
    private var tradeModel: TradeModel?
    
    private var showRefreshBtn: Bool = false {
        didSet {
            self.refreshButton.isHidden = !showRefreshBtn
        }
    }
    
    lazy var stockBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = UIColor.clear;
        btn.setTitle("", for: .normal)
        btn.addTarget(self, action: #selector(clickAction), for: .touchUpInside)
        return btn
    }()
    
    lazy var textField: YXTextField = {
        let textFld = YXTextField()
        textFld.textColor = QMUITheme().textColorLevel1()
        textFld.font = .systemFont(ofSize: 16, weight: .medium)
        textFld.adjustsFontSizeToFitWidth = true
        textFld.minimumFontSize = 10
        textFld.attributedPlaceholder = NSAttributedString(string: YXLanguageUtility.kLang(key: "track_assets_name_symbol"), attributes: [.foregroundColor: QMUITheme().textColorLevel4(), .font: UIFont.systemFont(ofSize: 16, weight: .medium)])
        textFld.banAction = true
        textFld.isUserInteractionEnabled = false
        
        return textFld
    }()
    
    
    /// price
    lazy var priceLabel:QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().stockGrayColor()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .left
//        label.contentEdgeInsets = UIEdgeInsets.init(top: , left: 0, bottom: 1, right: 0)

        return label
    }()
    
    var panpreImage: UIImage?
    var panAfterImage: UIImage?
    /// 盘前盘后显示
    lazy var marketStatusLab: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 8)
        label.backgroundColor = QMUITheme().stockGrayColor()
        label.textColor = UIColor.white
        label.layer.cornerRadius = 2
        label.layer.masksToBounds = true
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textAlignment = .center
        label.baselineAdjustment = .alignCenters
        label.contentEdgeInsets = UIEdgeInsets(top: 0, left:2, bottom: 0, right: 2)
       
        return label
    }()

    @objc lazy var delayLabel: UILabel = {
        let label = UILabel.delay()!
        label.text = YXLanguageUtility.kLang(key: "common_delay")
        label.isHidden = true
        return label
    }()
        
    @objc lazy var refreshButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.isHidden = true
        btn.setImage(UIImage(named: "trade_refresh")?.qmui_image(withAlpha: 0.8), for: .normal)
        btn.addTarget(self, action: #selector(refreshClick(_:)), for: .touchUpInside)
        
        return btn
    }()
    
    @objc lazy var marginLabel: QMUILabel = {
        let label = QMUILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 8)
        label.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 4, bottom: 0, right: 4)
        label.isHidden = true
        label.clipsToBounds = true
        label.layer.cornerRadius = 2
        label.textColor = UIColor.qmui_color(withHexString: "#FF6933")
        label.backgroundColor = UIColor.qmui_color(withHexString: "#FF6933")?.withAlphaComponent(0.1)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        let topView = UIView.init()
        topView.addSubview(textField)
        topView.addSubview(stockBtn)
        addSubview(topView)
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .bottom
        addSubview(stackView)
        
        stackView.addArrangedSubview(priceLabel)
        stackView.addArrangedSubview(delayLabel)
        stackView.addArrangedSubview(marginLabel)
        stackView.addArrangedSubview(refreshButton)
        
        let lineView = UIView.line()
        addSubview(lineView)
        
        topView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview()
            make.height.equalTo(52)
        }
                        
        textField.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview().offset(-30)
            make.top.bottom.equalToSuperview()
        }
        
        stockBtn.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        lineView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(0.5)
            make.bottom.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(-8)
            make.height.equalTo(16)
            make.left.equalTo(topView)
            make.right.lessThanOrEqualTo(topView)
        }
        
        marginLabel.snp.makeConstraints { make in
            make.height.equalTo(12)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.height.equalTo(12)
        }
        
        delayLabel.snp.makeConstraints { make in
            make.height.equalTo(12)
        }
        
        contentHeight = 50
    }
    
    /// 外部用 先赋值 后有行情
    @objc func updateStockNameSymbol(name: String, market: String?, symbol: String?) {
        var text: String = ""
        
        if let symbol = symbol, symbol.count > 0 {
            contentHeight = 72

            text = "--"
            if name.count > 0 {
                text = name
            }
            
            if let market = market,
               market.count > 0,
               market != kYXMarketUsOption {
                text = text + "(" + symbol + "." + market.uppercased() + ")"
            }
            textField.text = text
        } else {
            clearStock()
            contentHeight = 52
        }
    }
    
    @objc func clearView() {
        let color = QMUITheme().stockGrayColor()
        priceLabel.attributedText = attrubutPriceString(price: "--", change: "--", changePer: "--", color: color, panText: "")
        priceLabel.textColor = color
      
    }
    
    func clearStock() {
        textField.text = nil
        priceLabel.attributedText = nil
        contentHeight = 52
        delayLabel.isHidden = true
        updataMargn()
    }
    
    func updataMargn(canMargin:Bool = false,marginRatio:Double = 0) {
        if canMargin == true {
            self.marginLabel.isHidden = false
            self.marginLabel.text = String.init(format: YXLanguageUtility.kLang(key: "trading_mortgage_rate"), marginRatio)
        }else {
            self.marginLabel.isHidden = true
            self.marginLabel.text = ""
        }
    }
    
    func updateUI(quote: YXV2Quote?, tradeModel: TradeModel? = nil) {
        
        if let trademodelValue = tradeModel {
            self.tradeModel = trademodelValue
            if trademodelValue.tradeStatus == .change {
                self.stockBtn.isEnabled = false
            }else{
                self.stockBtn.isEnabled = true
            }
            
            if trademodelValue.symbol.count == 0 {
                return
            }
        }
        
        if let level = quote?.level?.value, level == 0 {
            self.delayLabel.isHidden = false
            self.delayLabel.text = YXLanguageUtility.kLang(key: "common_delay")
        } else {
            self.delayLabel.isHidden = true
            self.delayLabel.text = ""
        }
       
        var color = QMUITheme().stockGrayColor()
        var priceStr: String = "--"
        var changeStr: String = "--"
        var changePerStr: String = "--"
        var pantext: String = ""
        if let simpleQuote = quote?.simpleQuote(withPreAfter: true) {
            if simpleQuote.latestPrice?.count ?? 0 > 0 {
                priceStr = simpleQuote.latestPrice ?? "--"
            }
            if let pctchng = simpleQuote.pctchng, pctchng.count > 0 {
                changePerStr = pctchng
            }
            if let netchng = simpleQuote.netchng, netchng.count > 0 {
                changeStr = netchng
            }
            if simpleQuote.marketStatus == .pre {
                pantext = "common_pre_opening"
            }else if simpleQuote.marketStatus == .after {
                pantext = "common_after_opening"
            }
            
            if simpleQuote.upDownType == .up {
                color = QMUITheme().stockRedColor()
            }else if simpleQuote.upDownType == .down {
                color = QMUITheme().stockGreenColor()
            }else{
                color = QMUITheme().stockGrayColor()
            }
    
        }
        
        if YXUserManager.shared().getLevel(with: tradeModel?.market ?? "") == .bmp {
            self.showRefreshBtn = true
        }else{
            self.showRefreshBtn = false
        }
        priceLabel.attributedText = attrubutPriceString(price: priceStr, change: changeStr, changePer: changePerStr, color: color, panText: pantext)
      
    }
    
    func attrubutPriceString(price: String, change: String, changePer:String, color:UIColor, panText: String) -> NSAttributedString {
        let font = UIFont.systemFont(ofSize: 12, weight: .medium)
        let attributOne: NSMutableAttributedString = NSMutableAttributedString(string: price, attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor:color])
        let changeStr: String = String(format: "  %@  %@",  change, changePer)
        
        let attributeTwo: NSAttributedString = NSAttributedString(string: changeStr, attributes:[NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor:color])
        attributOne.append(attributeTwo)
        
        if panText.count > 0 {
            var image: UIImage = UIImage()
            if panText == "common_pre_opening" && panpreImage == nil {
                self.marketStatusLab.text = YXLanguageUtility.kLang(key: panText)
                self.marketStatusLab.sizeToFit()
                self.marketStatusLab.height = 12
                panpreImage = getImageFromView(view: self.marketStatusLab)
            }else{
                if panAfterImage == nil {
                    self.marketStatusLab.text = YXLanguageUtility.kLang(key: panText)
                    self.marketStatusLab.sizeToFit()
                    self.marketStatusLab.height = 12
                    panAfterImage = getImageFromView(view: self.marketStatusLab)
                }
            }
            if panText == "common_pre_opening" {
                image = panpreImage ?? UIImage()
            }else{
                image = panAfterImage ?? UIImage()
            }
            let imageAttachment: NSTextAttachment = NSTextAttachment()
            imageAttachment.image = image
            imageAttachment.bounds = CGRect(x: 0, y: (font.capHeight - 12).rounded()/2.0 + 2 - 1.0/UIScreen.main.scale, width: self.marketStatusLab.width, height: 12)
            
            attributOne.appendString("  ")
            let attributeThree: NSAttributedString = NSAttributedString(attachment: imageAttachment)
            attributOne.append(attributeThree)
        }
        
        return attributOne
    }
    
    private func getImageFromView(view: UIView) -> UIImage {
        // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
        UIGraphicsBeginImageContextWithOptions(view.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        view.layer.render(in: context!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    @objc func clickAction() {
        trackViewClickEvent(name: "search_Tab")
        clickBlock?()
    }

    @objc func refreshClick(_ sender: UIButton) {
        sender.isEnabled = false
        
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.toValue = NSNumber(value: .pi * 2.0)
        animation.duration = 0.4
        animation.isCumulative = true
        animation.repeatCount = 1
        animation.delegate = self
        self.refreshButton.imageView?.layer.add(animation, forKey: "rotationAnimation")
        
        refreshBlock?()
    }
}

extension YXSmartTrackStockView : CAAnimationDelegate{
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            self.refreshButton.isEnabled = true
        }
    }
}

