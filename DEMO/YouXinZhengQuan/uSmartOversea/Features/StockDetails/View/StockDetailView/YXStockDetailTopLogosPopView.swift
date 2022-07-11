//
//  YXStockDetailTopLogosPopView.swift
//  uSmartOversea
//
//  Created by youxin on 2020/10/10.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

@objc enum YXStockDetailTopLogosType: Int {
    case market
    case userLevel  //行情权限
    case shsz       //沪股通 深股通
    case financing  //融资股票
    case dayMargin  //日内融股票
    case shortSell  //卖空股票
    case fundLever  //基金杠杆
}


class YXStockDetailTopLogosPopView: UIView {

    @objc var itemClickBlock: ((_ type: YXStockDetailTopLogosType, _ quote: YXV2Quote?) -> Void)?

    var totalHeight: CGFloat = 0;
    @objc func showFromView(_ desView: UIView) {
        let fatherView = UIApplication.shared.keyWindow!
        let rect = desView.convert(desView.bounds, to: fatherView)

        self.frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: fatherView.height)
        fatherView.addSubview(self)
        
        self.dimmingView.frame = CGRect(x: 0, y: rect.maxY, width: self.frame.width, height: fatherView.height - rect.maxY)

        self.scrollview.frame = CGRect(x: 0, y: rect.maxY, width: self.frame.width, height: 0)

        self.dimmingView.alpha = 0.0

        UIView.animate(withDuration: 0.3, animations: {
            self.dimmingView.alpha = 1.0
            self.scrollview.mj_h = self.totalHeight
        }, completion: { _ in

        })
    }

    @objc func hideSheetView(_ animated: Bool = true) {

        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.dimmingView.alpha = 0.0
                self.scrollview.alpha = 0.0
            }, completion: { _ in
                self.removeFromSuperview()
            })
        } else {
            self.dimmingView.alpha = 0.0
            self.scrollview.alpha = 0.0
            self.removeFromSuperview()
        }
    }

    var viewArray: [YXStockDetailTopLogosSubview] = []

    var shortSellModel: YXStockShortSellModel? {
        didSet {
            for view in viewArray {
                if view.type == .shortSell {
                    view.shortSellModel = shortSellModel
                    break
                }
            }
        }
    }

    @objc var quote: YXV2Quote? {
        didSet {

            if let quoteModel = quote {

                for view in viewArray {
                    view.removeFromSuperview()
                }
                viewArray.removeAll()

                if let _ = quoteModel.market {

                    let subview = YXStockDetailTopLogosSubview.init(frame: .zero, type: .market)
                    subview.quote = quote
                    viewArray.append(subview)
                }
                
                //是否是融资股票
                if YXStockDetailTool.isFinancingStock(quoteModel) {

                    let subview = YXStockDetailTopLogosSubview.init(frame: .zero, type: .financing)
                    subview.quote = quote
                    viewArray.append(subview)
                    subview.itemClickBlock = {
                        [weak self] (type, quote) in
                        guard let `self` = self else { return }

                        self.itemClickBlock?(type, quote)
                    }
                }

                do { //行情权限
                    if YXUserManager.shared().getHighestUsaThreeLevel() == .delay && YXStockDetailOCTool.isUSIndex(quoteModel){
                        //美股三大指数无权限时不显示
                    }else{
                        let subview = YXStockDetailTopLogosSubview.init(frame: .zero, type: .userLevel)
                        subview.quote = quote
                        viewArray.append(subview)
                        subview.itemClickBlock = {
                            [weak self] (type, quote) in
                            guard let `self` = self else { return }

                            self.itemClickBlock?(type, quote)
                        }
                    }
                }
                
                //occ测试数据
//                if let shortSellFlag = quoteModel.shortSellFlag?.value, shortSellFlag,
//                   let market = quoteModel.market, market == kYXMarketUS {
                    let subview = YXStockDetailTopLogosSubview.init(frame: .zero, type: .shortSell)
                    subview.quote = quote
                    subview.shortSellModel = shortSellModel
                    viewArray.append(subview)
                    subview.itemClickBlock = {
                        [weak self] (type, quote) in
                        guard let `self` = self else { return }

                        self.itemClickBlock?(type, quote)
                    }
//                }
                
                /*
                //沪港通 深港通
                if YXStockDetailOCTool.hkCanTradeSH(quoteModel) || YXStockDetailOCTool.hkCanTradeSZ(quoteModel) ||
                    YXStockDetailOCTool.szCanTradeHK(quoteModel) ||
                    YXStockDetailOCTool.shCanTradeHK(quoteModel){
                    let subview = YXStockDetailTopLogosSubview.init(frame: .zero, type: .shsz)
                    subview.quote = quote
                    viewArray.append(subview)
                }

                //是否是日内融股票
                if quoteModel.dailyMargin?.value == true {

                    let subview = YXStockDetailTopLogosSubview.init(frame: .zero, type: .dayMargin)
                    subview.quote = quote
                    viewArray.append(subview)
                }

               
                //是否是卖空股票
                if let shortSellFlag = quoteModel.shortSellFlag?.value, shortSellFlag,
                   let market = quoteModel.market, market == kYXMarketUS {
                    let subview = YXStockDetailTopLogosSubview.init(frame: .zero, type: .shortSell)
                    subview.quote = quote
                    subview.shortSellModel = shortSellModel
                    viewArray.append(subview)
                }

                //是否是港股ETF, 美股ETN 反向杠杆倍数
                if let lever = quoteModel.lever?.value, lever != 0,
                   let type3 = quoteModel.type3?.value, (type3 == OBJECT_SECUSecuType3.stEtf.rawValue || type3 == OBJECT_SECUSecuType3.stFundUsEtn.rawValue) {
                    let subview = YXStockDetailTopLogosSubview.init(frame: .zero, type: .fundLever)
                    subview.quote = quote
                    viewArray.append(subview)
                }
                 */

                let itemHeight: CGFloat = 56.0
                let itemWidth: CGFloat = YXConstant.screenWidth

                for (index, subview) in viewArray.enumerated() {
                    scrollview.addSubview(subview)
                    subview.snp.makeConstraints { (make) in
                        make.left.equalToSuperview()
                        make.width.equalTo(itemWidth)
                        make.height.equalTo(itemHeight)
                        make.top.equalToSuperview().offset(CGFloat(index) * itemHeight + 12.0 + 10)
                        if index == viewArray.count - 1 {
                            make.bottom.equalToSuperview().offset(-12)
                        }
                    }
                }

                totalHeight = itemHeight * CGFloat(viewArray.count) + 24.0 + 10
            }

        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {

        addSubview(dimmingView)
        addSubview(scrollview)
        
        let lineView = UIView()
        lineView.backgroundColor = QMUITheme().separatorLineColor()
        scrollview.addSubview(lineView)

        lineView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalTo(self)
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(0.5)
        }

        let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(tapGesAction(_:)))

        self.addGestureRecognizer(tapGes)
    }

    @objc func tapGesAction(_ tap: UITapGestureRecognizer) {

        let point = tap.location(in: self)
        if scrollview.frame.contains(point) {

        } else {
            self.hideSheetView()
        }
    }

    lazy var scrollview: UIScrollView = {
        let scrollview = UIScrollView()
        scrollview.backgroundColor = QMUITheme().foregroundColor()
        scrollview.layer.cornerRadius = 16.0
        scrollview.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return scrollview
    }()

    lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().shadeLayerColor()
        return view
    }()

}


class YXStockDetailTopLogosSubview: UIView {

    @objc var itemClickBlock: ((_ type: YXStockDetailTopLogosType, _ quote: YXV2Quote?) -> Void)?
    var type: YXStockDetailTopLogosType = .market
    var quote: YXV2Quote? {
        didSet {
            if self.type == .market {

                if let market = self.quote?.market {
                    //市场
                    let imagePrefix = "stock_detail_"
                    var imageName: String = market.lowercased()
                    if market == kYXMarketUsOption {
                        imageName = kYXMarketUS.lowercased()
                    }
                    logoImageView.image = UIImage(named: imagePrefix + imageName)
                }

                var exchangeStr = YXStockDetailOCTool.getQuoteExchangeName(self.quote?.exchange?.value ?? 0)
                let boardStr = YXStockDetailOCTool.sectorLabelString(quote)

                if boardStr.isEmpty {
                    titleLabel.text = exchangeStr
                } else {
                    titleLabel.text = exchangeStr + "·" + boardStr
                }
                
                if self.quote?.market == kYXMarketUS, self.quote?.type1?.value == 6 {
                   
                    switch self.quote?.symbol {
                    case YXMarketIndex.DJI.rawValue:
                        exchangeStr = YXLanguageUtility.kLang(key: "dow_jonwa_index")//"Dow Jones Industrial Average"
                    case YXMarketIndex.IXIC.rawValue:
                        exchangeStr = YXLanguageUtility.kLang(key: "nasdaq_index_detail")// "Nasdaq Composite"
                    case YXMarketIndex.SPX.rawValue:
                        exchangeStr =  YXLanguageUtility.kLang(key: "s&p_500_index")//"S&P 500"
                    default:
                        break
                    }
                }
                
                if boardStr.isEmpty {
                    titleLabel.text = exchangeStr
                } else {
                    titleLabel.text = exchangeStr + "·" + boardStr
                }
                
                if self.quote?.market == kYXMarketCryptos {
                    titleLabel.text = "Digital Currency"
                }

                subTitleLabel.text = YXStockDetailTool.stockLabelString(quote)
            } else if self.type == .financing {
                let ratio = quote?.marginRatio?.value ?? 0
                self.subTitleLabel.text = String(format: YXLanguageUtility.kLang(key: "financing_mortgage_rate"), ratio * 100)
            } else if self.type == .dayMargin {
                let gearing = quote?.dailyMarginGearing?.value ?? 0

                self.subTitleLabel.text = String.init(format: YXLanguageUtility.kLang(key: "intraday_max_margin"), gearing)
            } else if self.type == .userLevel {
                
                //行情权限
                let market = self.quote?.market ?? kYXMarketHK
               
                var level: QuoteLevel = .delay
                if let tempLevel = QuoteLevel(rawValue: Int(self.quote?.level?.value ?? 0)) {
                    level = tempLevel
                }

                var levelText = ""
                var levelSubText = ""
                if level == .delay {
                    
                    levelText = YXLanguageUtility.kLang(key: "delay_title")
                    if market == kYXMarketSG {
                        levelSubText = YXLanguageUtility.kLang(key: "sg_delay_subTitle")
                    } else {
                        levelSubText = YXLanguageUtility.kLang(key: "delay_subTitle")
                    }
                    
                } else if level == .bmp {
                    
                    levelText = YXLanguageUtility.kLang(key: "bmp_title")
                    levelSubText = YXLanguageUtility.kLang(key: "bmp_subTitle")
                } else if level == .level1 {
                    
                    levelText = YXLanguageUtility.kLang(key: "L1_title")
                    levelSubText = YXLanguageUtility.kLang(key: "L1_subTitle")
                    if let qouteM = quote {
                        if YXStockDetailOCTool.isUSIndex(qouteM) {
                            levelSubText = YXLanguageUtility.kLang(key: "L1_subTitle")
                        } else if market == kYXMarketUS {
                            levelText = YXLanguageUtility.kLang(key: "quote_nsdq_title")
                        } else if market == kYXMarketUsOption {
                            levelText = YXLanguageUtility.kLang(key: "quote_usoption_title")
                        }
                    }
                } else if level == .level2 {
                    levelText = YXLanguageUtility.kLang(key: "L2_title")
                    if market == kYXMarketSG {
                        levelSubText = YXLanguageUtility.kLang(key:"SG_L2_subTitle")
                    } else {
                        levelSubText = YXLanguageUtility.kLang(key:"L2_subTitle")
                    }
                } else if level == .usNational {
                    levelText = YXLanguageUtility.kLang(key: "quote_usnation_title")
                    levelSubText = YXLanguageUtility.kLang(key: "quote_sub_usnation_title")
                }

                logoImageView.image = UIImage(named: level.stockDetailImageName(with: self.quote?.market ?? ""))

                titleLabel.text = levelText
                subTitleLabel.text = levelSubText

            }  else if self.type == .shsz {
                if let quoteModel = quote {
                    if YXStockDetailOCTool.canTradeBothHKAndSH(quoteModel) {
                        titleLabel.text = "沪港通&深港通"
                    } else if YXStockDetailOCTool.hkCanTradeSZ(quoteModel) || YXStockDetailOCTool.szCanTradeHK(quoteModel)  {
                        titleLabel.text = "深港通"
                    } else if YXStockDetailOCTool.hkCanTradeSH(quoteModel) || YXStockDetailOCTool.shCanTradeHK(quoteModel) {
                        titleLabel.text = "沪港通"
                    }
                }
            } else if self.type == .fundLever {
                let lever = quote?.lever?.value ?? 0
                if (lever > 0) {
                    logoLabel.text = String(format: "+%dx", lever)
                    titleLabel.text = String(format: "%d倍正向杠杆", quote?.lever?.value ?? 0)
                } else {
                    logoLabel.text = String(format: "%dx", lever)
                    titleLabel.text = String(format: "%d倍反向杠杆", abs(quote?.lever?.value ?? 0))
                }

            } else if self.type == .shortSell {
                //occ测试数据
//                logoImageView.image =
//                logoLabel
                titleLabel.text = "Support Short Selling"
                subTitleLabel.text = String(format: "Short Selling Margin Ratio %d", 10)
            }

        }
    }

    var shortSellModel: YXStockShortSellModel? {
        didSet {

        }
    }

    init(frame: CGRect, type: YXStockDetailTopLogosType) {
        super.init(frame: frame)
        self.type = type
        initUI()

        let tapGes = UITapGestureRecognizer.init { [weak self] (_) in
            guard let `self` = self else { return }

            self.itemClickBlock?(self.type, self.quote)
//            if self.type == .financing || self.type == .shortSell {
//                self.aboutButtonEvent()
//            }
        }
        self.addGestureRecognizer(tapGes)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {

        addSubview(logoImageView)
        addSubview(titleLabel)
        addSubview(subTitleLabel)
        addSubview(infoButton)

//        logoLabel.snp.makeConstraints { (make) in
//            make.width.height.equalTo(24)
//            make.top.equalToSuperview().offset(20)
//            make.centerX.equalToSuperview()
//        }
    
        logoImageView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        infoButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(14)
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }

        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(logoImageView.snp.right).offset(12)
            make.top.equalToSuperview().offset(11)
            make.height.equalTo(18)
            make.right.lessThanOrEqualTo(infoButton.snp.left).offset(-5)
        }

        subTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom)
            make.height.equalTo(16)
            make.right.lessThanOrEqualTo(infoButton.snp.left).offset(-5)
        }
        
        
        if self.type == .shortSell || self.type == .userLevel {
            infoButton.isHidden = false
        } else {
            infoButton.isHidden = true
        }

        if self.type == .market {

        } else if self.type == .financing {
            logoImageView.image = UIImage(named: "stock_detail_margin")
            titleLabel.text = YXLanguageUtility.kLang(key: "support_financing_buy")
        }
        
//        else if self.type == .dayMargin {
//            logoLabel.text = "DM"
//            logoLabel.backgroundColor = UIColor.qmui_color(withHexString: "#FF7127")
//
//            titleLabel.text = YXLanguageUtility.kLang(key: "support_day_margin")
//        } else if self.type == .shsz {
//            logoLabel.text = "通"
//            logoLabel.backgroundColor = QMUITheme().themeTextColor()
//        } else if self.type == .shortSell {
//
//            logoLabel.text = YXLanguageUtility.kLang(key: "short_sell_logo")
//            logoLabel.backgroundColor = UIColor.qmui_color(withHexString: "#FFBA00")
//
//            titleLabel.text = YXLanguageUtility.kLang(key: "support_short_sell")
//        } else if self.type == .fundLever {
//            logoLabel.backgroundColor = UIColor.qmui_color(withHexString: "#FF7127")
//        }

    }
    
    lazy var logoImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleToFill
        return view
    }()

    lazy var logoLabel: UILabel = {
        let label = UILabel()
        label.layer.cornerRadius = 3.0
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label;
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()

    lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()

    lazy var infoButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.expandX = 5
        button.expandY = 5
        button.setImage(UIImage(named: "right_arrow_14"), for: .normal)
        button.addTarget(self, action: #selector(aboutButtonEvent), for: .touchUpInside)
        return button
    }()


    @objc func aboutButtonEvent() {

        if self.type == .financing {
            let tipStr = YXLanguageUtility.kLang(key: "financing_mortgage_toast")

            let alertView = YXAlertView.init(title: nil, message: tipStr, prompt: nil, style: .default, messageAlignment: .left)
            alertView.messageLabel.font = .systemFont(ofSize: 16)
            alertView.messageLabel.textAlignment = .left
            let action = YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_iknow"), style: .default) { (action) in

            }
            alertView.addAction(action)

            alertView.showInWindow()
        } else if self.type == .shortSell {
            let alertView = YXAlertView(title: YXLanguageUtility.kLang(key: "support_short_sell"), message: nil, prompt: nil, style: .default, messageAlignment: .left)
            alertView.messageLabel.font = .systemFont(ofSize: 16)
            alertView.messageLabel.textAlignment = .left
            let action = YXAlertAction.action(title:
                                                YXLanguageUtility.kLang(key: "common_iknow"), style: .default) { (action) in

            }
            alertView.addAction(action)

            let shortSellView = UIView(frame: CGRect(x: 0, y: 0, width: 285, height: 90))

            let marginView = YXStockDetailLogoAlertSubView()
            marginView.leftLabel.text = YXLanguageUtility.kLang(key: "short_sell_margin_rate")
            if let shorStart = shortSellModel?.shortStart {
                marginView.rightLabel.text = String(format: "%.2f%%", shorStart * 100)
            }


            let rateView = YXStockDetailLogoAlertSubView()
            rateView.leftLabel.text = YXLanguageUtility.kLang(key: "short_sell_reference_rate")
            if let feeRate = shortSellModel?.feeRate {
                rateView.rightLabel.text = String(format: "%.2f%%", feeRate * 100)
            }

            let remainView = YXStockDetailLogoAlertSubView()
            remainView.leftLabel.text = YXLanguageUtility.kLang(key: "short_sell_pool_remain")

            if let maxAvailable = shortSellModel?.maxAvailable {

                var showIntergers = false
                if YXUserManager.isENMode() {
                    showIntergers = (maxAvailable < 1000)
                } else {
                    showIntergers = (maxAvailable < 10000)
                }

                if showIntergers {
                    remainView.rightLabel.text = "\(maxAvailable)"
                } else {
                    remainView.rightLabel.text = YXToolUtility.stockData(Double(maxAvailable), deciPoint: 2, stockUnit: "", priceBase: 0)
                }
            }

            shortSellView.addSubview(marginView)
            shortSellView.addSubview(rateView)
            shortSellView.addSubview(remainView)

            alertView.addCustomView(shortSellView)

            marginView.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(10)
                make.right.equalToSuperview().offset(-10)
                make.top.equalToSuperview()
                make.height.equalTo(30)
            }

            rateView.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(10)
                make.right.equalToSuperview().offset(-10)
                make.top.equalTo(marginView.snp.bottom)
                make.height.equalTo(30)
            }

            remainView.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(10)
                make.right.equalToSuperview().offset(-10)
                make.top.equalTo(rateView.snp.bottom)
                make.height.equalTo(30)
            }



            alertView.showInWindow()
        }



    }

}

class YXStockDetailLogoAlertSubView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        addSubview(leftLabel)
        addSubview(rightLabel)

        leftLabel.snp.makeConstraints { (make) in
            make.left.centerY.equalToSuperview()
        }

        rightLabel.snp.makeConstraints { (make) in
            make.right.centerY.equalToSuperview()
            make.left.greaterThanOrEqualTo(leftLabel.snp.right).offset(5)
        }
    }

    lazy var leftLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        return label
    }()

    lazy var rightLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.text = "--"
        return label
    }()
}





