//
//  YXStockDetailAskBidView.swift
//  uSmartOversea
//
//  Created by Kelvin on 2019/4/11.
//  Copyright © 2019年 RenRenDai. All rights reserved.
//

import UIKit
import YXKit
import FLAnimatedImage

let askColor = UIColor.qmui_color(withHexString: "#FF6933") ?? .white
let bidColor = UIColor.qmui_color(withHexString: "#00C767") ?? .white

class YXTickTitleView: UIView {
    
    lazy var bidView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = bidColor
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        view.layer.cornerRadius = 2.0
        return view
    }()
    
    lazy var askView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = askColor
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        view.layer.cornerRadius = 2.0
        return view
    }()
  
    lazy var bidRatioLabel: QMUILabel = {
        let lab = QMUILabel()
        lab.text = String(format: "--")
        lab.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        lab.textColor = UIColor.white
        return lab
    }()
    
    lazy var askRatioLabel: QMUILabel = {
        let lab = QMUILabel()
        lab.text = String(format: "--")
        lab.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        lab.textColor = UIColor.white
        return lab
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let askGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1.0, y: 1.0)
        layer.colors = [askColor.cgColor, financialRedColor.cgColor];
        layer.locations = [0, 1.0]
        return layer
    }()
    
    func initUI() -> Void {
        addSubview(bidView)
        addSubview(askView)
        addSubview(bidRatioLabel)
        addSubview(askRatioLabel)
        
        bidView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo((UIScreen.main.bounds.size.width - 32) * 0.5)
        }
        askView.snp.makeConstraints { (make) in
            make.bottom.top.right.equalToSuperview()
            make.left.equalTo(bidView.snp.right)
        }
        
        bidRatioLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(self.snp.left).offset(4)
        }
        
        askRatioLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(self.snp.right).offset(-4)
        }
    }
    
}

class YXTickValueView: UIView {
    
    var bidView = YXTickValueSubView(frame: .zero, isBuy: true)
    
    var askView = YXTickValueSubView(frame: .zero, isBuy: false)

    var askSize: Int64 = -1
    var bidSize: Int64 = -1

    var cryptosAskSize: Double = 0
    var cryptosBidSize: Double = 0

    @objc var tapBlock: ((_ priceString: String?, _ number: NSNumber?) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() -> Void {
        
        addSubview(bidView)
        addSubview(askView)
        
        bidView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(self.snp.centerX)
        }
        askView.snp.makeConstraints { (make) in
            make.right.top.bottom.equalToSuperview()
            make.left.equalTo(self.snp.centerX)
        }
    }

    func refreshBidAnimation(_ change: Double) {
        if change == 0 {
            return
        }
        if change > 0 {
            self.bidView.animationView.backgroundColor = QMUITheme().stockRedColor().withAlphaComponent(0.4)
        } else {
            self.bidView.animationView.backgroundColor = QMUITheme().stockGreenColor().withAlphaComponent(0.4)
        }

        UIView.animate(withDuration: 0.05, delay: 0, options: .allowUserInteraction, animations: {
            self.bidView.animationView.alpha = 1.0
        }) { (_) in
            UIView.animate(withDuration: 0.05, delay: 0, options: .allowUserInteraction, animations: {
                self.bidView.animationView.alpha = 0
            }, completion: nil)
        }
    }

    func refreshAskAnimation(_ change: Double) {
        if change == 0 {
            return
        }
        if change > 0 {
            self.askView.animationView.backgroundColor = QMUITheme().stockRedColor().withAlphaComponent(0.4)
        } else {
            self.askView.animationView.backgroundColor = QMUITheme().stockGreenColor().withAlphaComponent(0.4)
        }

        UIView.animate(withDuration: 0.05, delay: 0, options: .allowUserInteraction, animations: {
            self.askView.animationView.alpha = 1.0
        }) { (_) in
            UIView.animate(withDuration: 0.05, delay: 0, options: .allowUserInteraction, animations: {
                self.askView.animationView.alpha = 0
            }, completion: nil)
        }
    }
}

class YXTickValueSubView: UIView {

    var isBuy = false
    init(frame: CGRect, isBuy: Bool) {
        super.init(frame: frame)
        self.isBuy = isBuy
        initUI()
        if isBuy {
            colorView.backgroundColor = bidColor.withAlphaComponent(0.1)
        } else {
            colorView.backgroundColor = askColor.withAlphaComponent(0.1)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func layoutColorView(_ ratio: CGFloat) {
        let width: CGFloat = (120.0 / 375.0) * YXConstant.screenWidth
        colorView.snp.updateConstraints { (make) in
            make.width.equalTo(width * ratio)
        }
    }

    func initUI() {
        addSubview(colorView)
        addSubview(tapPriceColorView)
        addSubview(sortLabel)
        addSubview(priceLabel)
        addSubview(titleLabel)
        addSubview(numLabel)
        addSubview(brokerCountLabel)
        addSubview(animationView)

        colorView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(0)
            if self.isBuy {
                make.right.equalToSuperview()
            } else {
                make.left.equalToSuperview()
            }
        }

        sortLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            if self.isBuy {
                make.left.equalToSuperview()
            } else {
                make.right.equalToSuperview()
            }
        }

        priceLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            if self.isBuy {
                make.right.equalToSuperview().offset(-4)
            } else {
                make.left.equalToSuperview().offset(4)
            }
        }
        
        tapPriceColorView.snp.makeConstraints { make in
            make.left.right.equalTo(priceLabel)
            make.top.bottom.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            if self.isBuy {
                make.left.equalToSuperview().offset(0)
            } else {
                make.right.equalToSuperview().offset(-4)
            }
        }
        
        numLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            if self.isBuy {
                make.left.equalToSuperview().offset(20)
            } else {
                make.right.equalTo(brokerCountLabel.snp.left)
            }
        }

        brokerCountLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            if self.isBuy {
                make.left.equalTo(numLabel.snp.right)
            } else {
                make.right.equalToSuperview().offset(-20)
            }
            make.width.equalTo(0)
        }

        animationView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(2)
            make.bottom.equalToSuperview().offset(-2)
            make.width.equalTo(84)
            if self.isBuy {
                make.left.equalTo(numLabel).offset(-3)
            } else {
                make.right.equalTo(brokerCountLabel).offset(3)
            }
        }

    }
    
    func showPriceTapAnimation() {
        
        AudioServicesPlaySystemSound(1520)

        UIView.animate(withDuration: 0.05, delay: 0, options: .allowUserInteraction) {
            self.tapPriceColorView.alpha = 1.0
        } completion: { finish in
            UIView.animate(withDuration: 0.05, delay: 0, options: .allowUserInteraction) {
                self.tapPriceColorView.alpha = 0.0
            } completion: { finish in
                 
            }
        }

    }
    
    lazy var tapPriceColorView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().themeTintColor().withAlphaComponent(0.2)
        view.alpha = 0
        return view
    }()

    lazy var priceLabel: QMUILabel = {
        let lab = QMUILabel()
        lab.text = "--"
        lab.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        lab.textColor = QMUITheme().textColorLevel1()
        return lab
    }()
    
    lazy var titleLabel: QMUILabel = {
        let lab = QMUILabel()
        lab.text = ""
        lab.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lab.textColor = QMUITheme().textColorLevel1()
        return lab
    }()
    
    lazy var numLabel: QMUILabel = {
        let lab = QMUILabel()
        lab.text = "--"
        lab.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lab.textColor = QMUITheme().textColorLevel1()
        return lab
    }()

    lazy var colorView: UIView = {
        let view = UIView()
        view.backgroundColor = bidColor.withAlphaComponent(0.1)
        return view
    }()
    lazy var brokerCountLabel: QMUILabel = {
        let lab = QMUILabel()
        lab.text = "--"
        lab.textAlignment = .right
        lab.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lab.textColor = QMUITheme().textColorLevel1()
        return lab
    }()
    lazy var animationView: UIView = {
        let view = UIView()
        view.alpha = 0
        return view
    }()

    lazy var sortLabel: QMUILabel = {
        let lab = QMUILabel()
        lab.text = "--"
        lab.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lab.textColor = QMUITheme().textColorLevel3()
        return lab
    }()

}


//买卖档
class YXStockDetailAskBidView: UIView, YXStockDetailSubHeaderViewProtocol {
    
    var hideTen = false
    
    var showNumber: Int = 1 {
        didSet {
             if market == kYXMarketUS || market == kYXMarketSG || market == kYXMarketUsOption {
                self.contentHeight = 124.0 + 10 + 36.0 * CGFloat(showNumber)
            } else {
                self.contentHeight = 124.0 + 36.0 * CGFloat(showNumber)
            }
            self.tickGradeButton.setTitle("\(showNumber)", for: .normal)
            
            self.tickGradeButton.isHidden = self.showNumber == 1
            
            for (i,view) in askBidViews.enumerated() {
                if (i < self.showNumber) {
                    view.isHidden = false
                } else {
                    view.isHidden = true
                }
            }
        }
    }
    
    @objc var market: String = YXMarketType.HK.rawValue {
        didSet {
            self.askBidMaskView.market = market
            if YXQuoteTipHelper.isShowTip(market) {
                
                let info = YXQuoteTipHelper.tipMessage(market)
                self.askBidMaskView.registerButton.setTitle(info.buttonTitle, for: .normal)
                _ = self.askBidMaskView.setDescText(info.message)
                
                self.showNumber = 1
                self.askBidMaskView.isHidden = false
                self.contentHeight = 120
            } else {
                // 默认初始化买卖档
                if market == kYXMarketUS || market == kYXMarketSG || market == kYXMarketUsOption {
                    self.showNumber = 1
                } else {
                    if YXUserManager.hkLevel() == .hkLevel1 {
                        self.showNumber = 1
                    } else {
                        self.showNumber = 5
                    }
                }
                self.askBidMaskView.isHidden = true
                // 港股实时行情.可以点击切换档位
                if market == kYXMarketHK && YXUserManager.shared().getLevel(with: kYXMarketHK) == .level2 {
                    self.tickGradeButton.isUserInteractionEnabled = true
                } else {
                    self.tickGradeButton.isUserInteractionEnabled = false
                }
            }
            
            if market == kYXMarketUS, YXUserManager.shared().getLevel(with: "us") != .delay {
                self.usNationTipView.posQuoteType = YXStockDetailUtility.getUsAskBidSelect()
            } else {
                self.usNationTipView.isHidden = true
            }
            
            self.usPosButton.isHidden = market != kYXMarketUS
            
            for view in askBidViews {
                if market != YXMarketType.HK.rawValue {
                    view.askView.sortLabel.isHidden = true
                    view.askView.brokerCountLabel.snp.updateConstraints { (make) in
                        make.right.equalToSuperview().offset(-63)
                    }
                    view.bidView.sortLabel.isHidden = true
                    view.bidView.numLabel.snp.updateConstraints { (make) in
                        make.left.equalToSuperview().offset(63)
                    }
                } else {
                    view.askView.sortLabel.isHidden = false
                    view.askView.brokerCountLabel.snp.updateConstraints { (make) in
                        make.right.equalToSuperview().offset(-20)
                    }
                    view.bidView.sortLabel.isHidden = false
                    view.bidView.numLabel.snp.updateConstraints { (make) in
                        make.left.equalToSuperview().offset(20)
                    }
                }
            }

        }
    }
    
    @objc var tapBlock: ((_ priceString: String?, _ number: NSNumber?) -> Void)?
    
    //model
    var posBroker: PosBroker? {
        
        didSet {
            refreshUI()
        }
    }
    
    func refreshUI() -> Void {
        guard let posBroker = posBroker else {
            return
        }
        guard let market = posBroker.market else {
            return
        }
        buyTitleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_bid_buy")
        sellTitleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_ask_sell")
                        
        if market == kYXMarketCryptos {

            refreshCryptosUI()
            return
        }

        let priceBase: Int = Int(posBroker.priceBase?.value ?? 1);
        if let status = posBroker.msInfo?.status?.value, market == YXMarketType.US.rawValue {
            if status == OBJECT_MARKETMarketStatus.msPreHours.rawValue {
                if YXUserManager.isENMode() {
                    if YXUserManager.curLanguage() != .EN {
                        buyTitleLabel.font = UIFont.systemFont(ofSize: 10)
                        sellTitleLabel.font = UIFont.systemFont(ofSize: 10)
                    } else {
                        buyTitleLabel.font = UIFont.systemFont(ofSize: 12)
                        sellTitleLabel.font = UIFont.systemFont(ofSize: 12)
                    }
                } else {
                    buyTitleLabel.font = UIFont.systemFont(ofSize: 14)
                    sellTitleLabel.font = UIFont.systemFont(ofSize: 14)
                }
                buyTitleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_pre_bid")
                sellTitleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_pre_ask")
            } else if status == OBJECT_MARKETMarketStatus.msAfterHours.rawValue ||
                status == OBJECT_MARKETMarketStatus.msClose.rawValue ||
                status == OBJECT_MARKETMarketStatus.msStart.rawValue {
                buyTitleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_post_bid")
                sellTitleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_post_ask")
                if YXUserManager.isENMode() {
                    if YXUserManager.curLanguage() != .EN {
                        buyTitleLabel.font = UIFont.systemFont(ofSize: 10)
                        sellTitleLabel.font = UIFont.systemFont(ofSize: 10)
                    } else {
                        buyTitleLabel.font = UIFont.systemFont(ofSize: 12)
                        sellTitleLabel.font = UIFont.systemFont(ofSize: 12)
                    }
                } else {
                    buyTitleLabel.font = UIFont.systemFont(ofSize: 14)
                    sellTitleLabel.font = UIFont.systemFont(ofSize: 14)
                }
            } else {
                buyTitleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_bid_buy")
                sellTitleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_ask_sell")
            }
        }

        let preClose = posBroker.getRealPreClose()?.value ?? 0
        let position: [PosData]? = posBroker.pos?.posData

        guard let finalPostion = position, finalPostion.count > 0 else {
            var title = ""
            if market == YXMarketType.US.rawValue {
                if self.usPosButton.posQuoteType == .nsdq {
                    title = "NSDQ"
                } else if self.usPosButton.posQuoteType == .usNation {
                    title = "BBO"
                }
            }
            /// 清空操作
            askBidViews.forEach { view in
                view.askView.titleLabel.text = title
                view.askView.priceLabel.text = "--"
                view.askView.numLabel.text = "--"
                
                view.bidView.titleLabel.text = title
                view.bidView.priceLabel.text = "--"
                view.bidView.numLabel.text = "--"
                
                tickTitleView.bidView.snp.updateConstraints { (make) in
                    make.width.equalTo((UIScreen.main.bounds.size.width - 32) * CGFloat(0.5))
                }
                tickTitleView.bidRatioLabel.text = "--"
                tickTitleView.askRatioLabel.text = "--"
            }
            
            return
        }
        
        //size
        if let askSize = finalPostion[0].askSize?.value, let bidSize = finalPostion[0].bidSize?.value, askSize + bidSize > 0 {
            let bidRatio = Double(bidSize) * 1.0 / Double(askSize + bidSize)
            let askRatio = Double(askSize) * 1.0 / Double(askSize + bidSize)
            tickTitleView.bidView.snp.updateConstraints { (make) in
                make.width.equalTo((UIScreen.main.bounds.size.width - 32) * CGFloat(bidRatio))
            }
            tickTitleView.bidRatioLabel.text = String(format: "%.2lf%@",  bidRatio * Double(100), "%")
            tickTitleView.askRatioLabel.text = String(format: "%.2lf%@", askRatio * Double(100), "%")
        }
        
        var isShowBroker = false
        if (posBroker.brokerData?.askBroker?.count ?? 0) > 0 {
            isShowBroker = true
        }
        
        if posBroker.market == kYXMarketHK && YXUserManager.hkLevel() == .hkLevel1 {
            isShowBroker = false
        }

        var maxSize: UInt64 = 0
        for item in finalPostion {
            if let size = item.askSize?.value, maxSize < size {
                maxSize = size
            }

            if let size = item.bidSize?.value, maxSize < size {
                maxSize = size
            }
        }

        for x in 0..<finalPostion.count {
            let positionModel = finalPostion[x]
            let tickView = askBidViews[x]
            
            if isShowBroker {

            } else {
                tickView.askView.brokerCountLabel.snp.updateConstraints { (make) in
                    make.width.equalTo(0)
                }
                tickView.bidView.brokerCountLabel.snp.updateConstraints { (make) in
                    make.width.equalTo(0)
                }
            }
            var title = ""
            if market == YXMarketType.US.rawValue {
                if self.usPosButton.posQuoteType == .nsdq {
                    title = "NSDQ"
                } else if self.usPosButton.posQuoteType == .usNation {
                    title = "BBO"
                }
            }
            tickView.askView.titleLabel.text = title
            tickView.bidView.titleLabel.text = title


            if let bidPrice = positionModel.bidPrice?.value, bidPrice > 0 {
                tickView.bidView.priceLabel.text = YXToolUtility.stockPriceData(Double(bidPrice), deciPoint: priceBase, priceBase: priceBase)
                if preClose > 0 {
                    tickView.bidView.priceLabel.textColor = YXToolUtility.priceTextColor(Double(bidPrice), comparedData: Double(preClose))
                }
            } else {
                tickView.bidView.priceLabel.text = "--"
                tickView.bidView.priceLabel.textColor = QMUITheme().themeTintColor()
            }
            
            // 数量
            var tempBidSize: Int64 = 0
            if let bidSize = positionModel.bidSize?.value, bidSize > 0 {
                tempBidSize = Int64(bidSize)
                tickView.bidView.numLabel.text = YXToolUtility.stockVolumeUnit(Int(bidSize))
            } else {
                tickView.bidView.numLabel.text = "0"
            }
            if x < self.showNumber, tickView.bidSize > 0 {
                tickView.refreshBidAnimation(Double(tempBidSize - tickView.bidSize))
            }
            tickView.bidSize = tempBidSize
            
            if let askPrice = positionModel.askPrice?.value, askPrice > 0 {
                tickView.askView.priceLabel.text = YXToolUtility.stockPriceData(Double(askPrice), deciPoint: priceBase, priceBase: priceBase)
                if preClose > 0 {
                    tickView.askView.priceLabel.textColor = YXToolUtility.priceTextColor(Double(askPrice), comparedData: Double(preClose))
                }
            } else {
                tickView.askView.priceLabel.text = "--"
                tickView.askView.priceLabel.textColor = QMUITheme().themeTintColor()
            }

            var tempAskSize: Int64 = 0
            if let askSize = positionModel.askSize?.value, askSize > 0 {
                tempAskSize = Int64(askSize)
                tickView.askView.numLabel.text = YXToolUtility.stockVolumeUnit(Int(askSize))
            } else {
                tickView.askView.numLabel.text = "0"
            }
            if x < self.showNumber, tickView.askSize >= 0 {
                tickView.refreshAskAnimation(Double(tempAskSize - tickView.askSize))
            }
            tickView.askSize = tempAskSize

            if maxSize > 0 {
                tickView.bidView.layoutColorView(CGFloat(tempBidSize) / CGFloat(maxSize))
            } else {
                tickView.bidView.layoutColorView(1.0)
            }

            if maxSize > 0 {
                tickView.askView.layoutColorView(CGFloat(tempAskSize) / CGFloat(maxSize))
            } else {
                tickView.askView.layoutColorView(1.0)
            }

            // 经纪商
            if isShowBroker {
                tickView.bidView.numLabel.text = (tickView.bidView.numLabel.text ?? "") + "("
                tickView.askView.numLabel.text = (tickView.askView.numLabel.text ?? "") + "("

                var tempBidSize: UInt64 = 0
                if let bidSize = positionModel.bidOrderCount?.value, bidSize > 0 {
                    tempBidSize = bidSize
                }

                tickView.bidView.brokerCountLabel.snp.updateConstraints { (make) in
                    make.width.equalTo(tempBidSize > 999 ? 35 : 28.0)
                }
                tickView.bidView.brokerCountLabel.text = "\(tempBidSize)" + ")"

                var tempAskSize: UInt64 = 0
                if let askSize = positionModel.askOrderCount?.value, askSize > 0 {
                    tempAskSize = askSize

                }
                tickView.askView.brokerCountLabel.snp.updateConstraints { (make) in
                    make.width.equalTo(tempAskSize > 999 ? 35 : 28.0)
                }
                tickView.askView.brokerCountLabel.text = "\(tempAskSize)" + ")"
            }
        }
    }

    func refreshCryptosUI() {


//        //美股 买卖档的价格比较 盘前盘后 用收盘价比较， 盘中 用昨收比较
//        let preClose: Double = Double(quoteModel?.btRealTime?.preClose ?? "0") ?? 0
//
//        buyTitleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_bid_buy")
//        sellTitleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_ask_sell")
//
//        let position: [BTOrderBookItem]? = quoteModel?.btOrderBook?.items
//
//        guard let finalPostion = position, finalPostion.count > 0 else {
//            return
//        }
//
//        let decimalCount = 0 //YXToolUtility.btDecimalPoint(quoteModel?.btRealTime?.now)
//        //size
//        if let askSizeStr = finalPostion[0].askVolume, let bidSizeStr = finalPostion[0].bidVolume, let askSize = Double(askSizeStr), let bidSize = Double(bidSizeStr), askSize + bidSize > 0 {
//            let bidRatio = Double(bidSize) * 1.0 / Double(askSize + bidSize)
//            let askRatio = Double(askSize) * 1.0 / Double(askSize + bidSize)
//            tickTitleView.bidView.snp.updateConstraints { (make) in
//                make.width.equalTo((UIScreen.main.bounds.size.width - 32) * CGFloat(bidRatio))
//            }
//            tickTitleView.bidRatioLabel.text = String(format: "%.2lf%@", bidRatio * Double(100), "%")
//            tickTitleView.askRatioLabel.text = String(format: "%.2lf%@", askRatio * Double(100), "%")
//        }
//
//        var maxBidSize: Double = 0
//        var maxAskSize: Double = 0
//        for item in finalPostion {
//            if let sizeStr = item.askVolume, let size = Double(sizeStr), maxAskSize < size {
//                maxAskSize = size
//            }
//
//            if let sizeStr = item.bidVolume, let size = Double(sizeStr), maxBidSize < size {
//                maxBidSize = size
//            }
//        }
//
//        for x in 0..<finalPostion.count {
//            let positionModel = finalPostion[x]
//            let tickView = askBidViews[x]
//
//            tickView.askView.brokerCountLabel.snp.updateConstraints { (make) in
//                make.width.equalTo(0)
//            }
//            tickView.bidView.brokerCountLabel.snp.updateConstraints { (make) in
//                make.width.equalTo(0)
//            }
//
//            tickView.askView.sortLabel.isHidden = true
//            tickView.askView.brokerCountLabel.snp.updateConstraints { (make) in
//                make.right.equalToSuperview().offset(-4)
//            }
//            tickView.bidView.sortLabel.isHidden = true
//            tickView.bidView.numLabel.snp.updateConstraints { (make) in
//                make.left.equalToSuperview().offset(4)
//            }
//
//            if let bidPriceStr = positionModel.bidPrice, let bidPrice = Double(bidPriceStr), bidPrice > 0 {
//                tickView.bidView.priceLabel.text = YXToolUtility.btNumberString(bidPriceStr, decimalPoint: 0)
//                if preClose > 0 {
//                    tickView.bidView.priceLabel.textColor = YXToolUtility.priceTextColor(Double(bidPrice), comparedData: Double(preClose))
//                }
//            } else {
//                tickView.bidView.priceLabel.text = "0"
//                tickView.bidView.priceLabel.textColor = QMUITheme().themeTintColor()
//            }
//
//            // 数量
//            var tempBidSize: Double = 0
//            if let bidSizeStr = positionModel.bidVolume, let bidSize = Double(bidSizeStr),  bidSize > 0 {
//                tempBidSize = bidSize
//                tickView.bidView.numLabel.text = YXToolUtility.btNumberString(bidSizeStr, isVol: true)
//            } else {
//                tickView.bidView.numLabel.text = "0"
//            }
//            if x < self.showNumber, tickView.cryptosBidSize > 0 {
//                tickView.refreshBidAnimation(tempBidSize - tickView.cryptosBidSize)
//            }
//            tickView.cryptosBidSize = tempBidSize
//
//            if let askPriceStr = positionModel.askPrice, let askPrice = Double(askPriceStr), askPrice > 0 {
//                tickView.askView.priceLabel.text = YXToolUtility.btNumberString(askPriceStr, decimalPoint: 0)
//                if preClose > 0 {
//                    tickView.askView.priceLabel.textColor = YXToolUtility.priceTextColor(Double(askPrice), comparedData: Double(preClose))
//                }
//            } else {
//                tickView.askView.priceLabel.text = "0"
//                tickView.askView.priceLabel.textColor = QMUITheme().themeTintColor()
//            }
//
//            var tempAskSize: Double = 0
//            if let askSizeStr = positionModel.askVolume, let askSize = Double(askSizeStr),  askSize > 0 {
//                tempAskSize = askSize
//                tickView.askView.numLabel.text = YXToolUtility.btNumberString(askSizeStr, isVol: true)
//            } else {
//                tickView.askView.numLabel.text = "0"
//            }
//            if x < self.showNumber, tickView.cryptosAskSize >= 0 {
//                tickView.refreshAskAnimation(tempAskSize - tickView.cryptosAskSize)
//            }
//            tickView.cryptosAskSize = tempAskSize
//
//            if maxBidSize > 0 {
//                tickView.bidView.layoutColorView(CGFloat(tempBidSize / maxBidSize))
//            } else {
//                tickView.bidView.layoutColorView(1.0)
//            }
//
//            if maxAskSize > 0 {
//                tickView.askView.layoutColorView(CGFloat(tempAskSize / maxAskSize))
//            } else {
//                tickView.askView.layoutColorView(1.0)
//            }
//
//        }
    }

    func refreshTitle(_ number: Int) {
        self.showNumber = number
        self.tickGradeButton.setTitle("\(number)", for: .normal)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        initUI()
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var pop: YXStockPopover?
    
    var askBidmenuCallBack: ((_ number: Int, _ animated: Bool) -> ())?
    
    func initUI() -> Void {

        addSubview(titleLabel)
        addSubview(self.buyTitleLabel)
        addSubview(self.sellTitleLabel)
        addSubview(self.tickGradeButton)
        addSubview(self.usPosButton)

        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(24)
            make.top.equalToSuperview().offset(20)
        }

        self.buyTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(26)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(tickGradeButton.snp.leading).offset(-5)
            make.height.equalTo(16)
        }

        self.sellTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.buyTitleLabel)
            make.trailing.equalToSuperview().offset(-16)
            make.leading.equalTo(tickGradeButton.snp.trailing).offset(5)
            make.height.equalTo(16)
        }

        self.tickGradeButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.sellTitleLabel)
            make.width.height.equalTo(20)
            make.centerX.equalToSuperview()
        }
        
        self.usPosButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.sellTitleLabel)
            make.height.equalTo(22)
            make.width.equalTo(200)
            make.centerX.equalToSuperview()
        }
        
        addSubview(tickTitleView)
        addSubview(bidView)
        tickTitleView.snp.makeConstraints { (make) in
            make.top.equalTo(buyTitleLabel.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(18)
        }
        
        bidView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-14)
            make.top.equalTo(tickTitleView.snp.bottom)
        }
        
        
        for x in 0..<askBidViews.count {
            let view: YXTickValueView = askBidViews[x]
//            if x == 0 {
//                view.bidView.backgroundColor = QMUITheme().mainThemeColor().withAlphaComponent(0.1)
//                view.askView.backgroundColor = QMUITheme().financialRedColor().withAlphaComponent(0.1)
//            }
            view.askView.rx.tapGesture().subscribe(onNext: { [weak self, weak view] ges in
                if ges.state == .ended, let tapBlock = self?.tapBlock {                        tapBlock(view?.askView.priceLabel.text, nil)
                    view?.askView.showPriceTapAnimation()
                }
                
            }).disposed(by: self.rx.disposeBag)
            
            view.bidView.rx.tapGesture().subscribe(onNext: { [weak self, weak view] ges in
                if ges.state == .ended, let tapBlock = self?.tapBlock {
                    tapBlock(view?.bidView.priceLabel.text, nil)
                    view?.bidView.showPriceTapAnimation()
                }
                
            }).disposed(by: self.rx.disposeBag)
            
            
            bidView.addSubview(view)
            view.snp.makeConstraints { (make) in
                make.left.right.equalTo(tickTitleView)
                make.height.equalTo(36)
                make.top.equalToSuperview().offset(36 * x)
            }
        }

        addSubview(askBidMaskView)
        askBidMaskView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        addSubview(usNationTipView)
        usNationTipView.snp.makeConstraints { make in
            make.left.right.equalTo(bidView)
            make.top.equalTo(tickTitleView).offset(4)
            make.height.equalTo(60)
        }
    }

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "askBid_title")
        return label
    }()

    lazy var tickTitleView: YXTickTitleView = {
        let view = YXTickTitleView()
        return view
    }()

    lazy var askBidViews: [YXTickValueView] = {
        var views: [YXTickValueView] = []
        for x in 0..<10 {
            let view: YXTickValueView = YXTickValueView()
            view.bidView.sortLabel.text = "\(x + 1)"
            view.askView.sortLabel.text = "\(x + 1)"
            views.append(view)
        }
        return views
    }()

    lazy var buyTitleLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "stock_detail_bid_buy")
        return label
    }()

    lazy var sellTitleLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .right
        label.text = YXLanguageUtility.kLang(key: "stock_detail_ask_sell")
        return label
    }()

    lazy var tickGradeButton: YXStockDetailPopBtn = {
        let button = YXStockDetailPopBtn()
        button.addTarget(self, action: #selector(tickGradeButtonDidClick(_:)), for: .touchUpInside)
//        button.imagePosition = .right
//        button.spacingBetweenImageAndTitle = 1
        button.isSelected = true
        return button
    }()

    lazy var usPosButton: YXStockUsNationChangeView = {
        let btn = YXStockUsNationChangeView.init()
        btn.isHidden = true
        return btn
    }()
    
    lazy var usNationTipView: YXStockUsNationChangeTipView = {
        let view = YXStockUsNationChangeTipView.init()
        view.isHidden = true
        return view
    }()

    lazy var bidView: UIView = {
        let view = UIView.init()
        view.clipsToBounds = true
        return view
    }()

    lazy var askBidMaskView: YXStockDetailAskBidMaskView = {
        let view = YXStockDetailAskBidMaskView()
        view.isHidden = true
        view.rx.observe(Bool.self, "hidden")
            .subscribe(onNext: {
                [weak self, weak view] hidden in
                guard let `self` = self else { return }
                
                if hidden == false, view?.backImageView.animatedImage == nil {
                    if let path = Bundle.main.path(forResource: "askAndBid".themeSuffix, ofType: "gif"),
                       let data = try? Data.init(contentsOf: URL(fileURLWithPath: path)) {
                        let image = FLAnimatedImage(animatedGIFData: data)
                        view?.backImageView.animatedImage = image
                    }
                }
                view?.backImageView.isHidden = hidden ?? true
                
            }).disposed(by: self.rx.disposeBag)
        return view
    }()
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if let path = Bundle.main.path(forResource: "askAndBid".themeSuffix, ofType: "gif"),
           let data = try? Data.init(contentsOf: URL(fileURLWithPath: path)) {
            let image = FLAnimatedImage(animatedGIFData: data)
            askBidMaskView.backImageView.animatedImage = image
        }
    }
}


extension YXStockDetailAskBidView {
    
    @objc func tickGradeButtonDidClick(_ sender: YXStockDetailPopBtn) {
        
        self.pop = YXStockPopover()
        self.pop?.show(self.getMenuView(), from: sender)
    }
    
    func getMenuView() -> YXStockLineMenuView {
        
        var arr = ["1", "5", "10"]
        if hideTen {
            arr = ["1", "5"]
        }

        var maxWidth: CGFloat = 0
        for title in arr {
            let width = (title as NSString).boundingRect(with: CGSize(width: 1000, height: 30), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)], context: nil).size.width
            if maxWidth < width {
                maxWidth = width
            }
        }
        let menuView = YXStockLineMenuView.init(frame: CGRect(x: 0, y: 0, width: maxWidth + 48, height: CGFloat(48 * arr.count)), andTitles: arr)
        menuView.clickCallBack = {
            [weak self] sender in
            guard let `self` = self else { return }

            self.pop?.dismiss()
            if sender.isSelected {
                return
            }

            var number = 1
            if sender.tag == 1 {
                number = 5
            } else if sender.tag == 2 {
                number = 10
            }
            /*
            if number == 1 {
                buyTitleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_buy_one")
                sellTitleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_sell_one")
            } else if number == 5 {
                buyTitleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_buy_five")
                sellTitleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_sell_five")
            } else {
                buyTitleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_buy_ten")
                sellTitleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_buy_ten")
            }
             */
            self.showNumber = number
            self.askBidmenuCallBack?(number, true)

        }
        let selectValue = self.tickGradeButton.titleLabel?.text ?? "1"
        for (index, title) in arr.enumerated() {
            if title == selectValue {
                menuView.selectIndex = index
                break;
            }
        }

        return menuView

    }
    
}


class YXStockDetailAskBidMaskView: UIView {

    @objc var market: String = YXMarketType.HK.rawValue

    @objc func setDescText(_ text: String)-> CGFloat {

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 3
        paragraph.alignment = .left
        let attibutesDic: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : descLabel.font!,
                                                            NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1(),
                                                            NSAttributedString.Key.paragraphStyle : paragraph]

        descLabel.attributedText = NSAttributedString.init(string: text, attributes: attibutesDic)
        var height = (text as NSString).boundingRect(with: CGSize(width: YXConstant.screenWidth - 28 - 100, height: CGFloat.greatestFiniteMagnitude), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: attibutesDic, context: nil).height + 26
        if height < 66 {
            height = 66
        }
        return height
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func initUI() {
        self.backgroundColor = QMUITheme().foregroundColor()

        self.addSubview(backImageView)
        backImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(0)
            make.right.equalToSuperview().offset(0)
            make.centerY.equalToSuperview()
            make.height.equalTo(80)
        }

//        let blurEffect = UIBlurEffect(style: .light)
//        let blurview = UIVisualEffectView(effect: blurEffect)
//        self.addSubview(blurview)
//        blurview.snp.makeConstraints { (make) in
//            make.left.top.bottom.right.equalToSuperview()
//        }
//
//        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
//        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
//        blurview.contentView.addSubview(vibrancyView)
//        vibrancyView.snp.makeConstraints { (make) in
//            make.left.top.bottom.right.equalToSuperview()
//        }

        backImageView.addSubview(descLabel)
        backImageView.addSubview(registerButton)

        registerButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
            make.width.greaterThanOrEqualTo(115)
        }
        registerButton.layer.cornerRadius = 4
        registerButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        registerButton.titleLabel?.setContentCompressionResistancePriority(.required, for: .horizontal)

        descLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualTo(registerButton.snp.left).offset(-12)
        }
        descLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

    }

    lazy var descLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.text = YXLanguageUtility.kLang(key: "tip_quote_permission_login")
        return label
    }()

    @objc lazy var registerButton: QMUIButton = {
        let button = QMUIButton()
        button.setTitle(YXLanguageUtility.kLang(key: "default_loginTip"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = QMUITheme().mainThemeColor()
        button.titleLabel?.numberOfLines = 1
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
//        button.isUserInteractionEnabled = false
        button.layer.masksToBounds = true
        button.qmui_tapBlock = { [weak self]_ in
            guard let `self` = self else { return }
            if !YXUserManager.isLogin() {
                // 未登錄
                YXToolUtility.handleBusinessWithLogin {
                    
                }
            } else {
                if YXQuoteTipHelper.isShowTip(self.market) {
                    let info = YXQuoteTipHelper.tipMessage(self.market)
                    if let url = URL(string: YXH5Urls.goBuyOnLineUrl()),info.jumpUrl == url.absoluteString {//跳官网
                        UIApplication.shared.open(url)
                    } else if info.jumpUrl == YXQuoteTipHelper.kOpenAccount{
                        YXOpenAccountWebViewModel.pushToWebVC(YXH5Urls.YX_OPEN_ACCOUNT_APPLY_URL())
                    } else {
                        YXWebViewModel.pushToWebVC(info.jumpUrl)
                    }
                }
            }
        }
        return button
    }()


    lazy var backImageView : FLAnimatedImageView = {
        let imageView = FLAnimatedImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        
        imageView.layer.cornerRadius = 6.0
        imageView.layer.masksToBounds = true
        return imageView

    }()

    let gradientOrangeImage: UIImage = {

        if let color1 = UIColor.qmui_color(withHexString: "#0EC0F1"), let color2 = UIColor.qmui_color(withHexString: "#535AF0") {
            return UIImage.init(gradientColors: [color1, color2])
        }
        return UIImage.init(gradientColors: [UIColor(red: 241/255.0, green: 185/255.0, blue: 45/255.0, alpha: 1), UIColor(red: 255/255.0, green: 157/255.0, blue: 69/255.0, alpha: 1)])
    }()


    let backColorImage: UIImage = {

        if let color1 = UIColor.qmui_color(withHexString: "#0EC0F1"), let color2 = UIColor.qmui_color(withHexString: "#535AF0") {
            return UIImage.init(gradientColors: [color1, color2])
        }
        return UIImage.init(gradientColors: [UIColor(red: 14/255.0, green: 192/255.0, blue: 241/255.0, alpha: 1), UIColor(red: 83/255.0, green: 90/255.0, blue: 240/255.0, alpha: 1)])
    }()

}

