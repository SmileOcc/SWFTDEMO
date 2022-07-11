//
//  YXHoldShareContentView.swift
//  uSmartOversea
//
//  Created by Evan on 2022/1/13.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

/// 盈利状态
@objc enum HoldStatus: Int {
    case average // 持平
    case profit // 盈利
    case loss // 亏损
}

@objc enum HoldShareSubType: Int {
    case normalPercent      // 单只股票总盈亏比率
    case normalAmount       // 单只股票总盈亏额
    case assetDailyPercent  // 资产今日盈亏比率
    case assetDailyAmount   // 资产今日盈亏额
    case assetTotalAmount   // 资产总盈亏额
    case order              // 订单
}

extension HoldShareSubType {
    var title: String {
        switch self {
        case .normalPercent, .assetDailyPercent:
            return YXLanguageUtility.kLang(key: "hold_balance_percent")
        case .normalAmount, .assetDailyAmount:
            return YXLanguageUtility.kLang(key: "hold_balance")
        case .assetTotalAmount:
            return YXLanguageUtility.kLang(key: "hold_total_balance")
        case .order:
            return YXLanguageUtility.kLang(key: "hold_share_order_title")
        }
    }

    var descString: String {
        switch self {
        case .assetDailyPercent, .assetDailyAmount:
            return YXLanguageUtility.kLang(key: "daily_P&L_title")
        case .normalPercent, .normalAmount, .assetTotalAmount:
            return YXLanguageUtility.kLang(key: "total_P&L_title")
        default:
            return ""
        }
    }
}

class YXHoldShareContentView: UIView {
    
    private var textColorLevel1 = UIColor.qmui_color(withHexString: "#2A2A34")!
    private var textColorLevel2 = UIColor.qmui_color(withHexString: "#555665")!
    private var textColorLevel3 = UIColor.qmui_color(withHexString: "#888996")!
    private var separatorLineColor = UIColor.qmui_color(withHexString: "#DDDDDD")!
    
    @objc var holdStockModel: YXAccountAssetHoldListItem? {
        didSet {

            var balanceTitle = subShareType.descString
            if subShareType == .normalAmount {
                balanceTitle.append("(\(unitString))")
            }
            balanceTitleLabel.text = balanceTitle

            var holdStatus: HoldStatus = .average
            var balanceStr = ""

            if self.subShareType == .normalPercent {
                if let percent = holdStockModel?.holdingBalancePercent?.doubleValue, percent != 0 {

                    if percent > 0 {
                        holdStatus = .profit
                    } else if percent < 0 {
                        holdStatus = .loss
                    }

                    let string = String(format: "%@%.02f%%", (percent > 0 ? "+" : ""), percent * 100.0)
                    balanceStr = string
                } else {
                    balanceStr = "--"
                }
            } else {
                if let value = holdStockModel?.holdingBalance,
                   let formatString = moneyFormatter.string(from: value) {

                    if value.doubleValue > 0 {
                        holdStatus = .profit
                    } else if value.doubleValue < 0 {
                        holdStatus = .loss
                    }

                    let string = String(format: "%@%@", (value.doubleValue > 0 ? "+" : ""), formatString)
                    balanceStr = string
                } else {
                    balanceStr = "0.00"
                }
            }

            balanceLabel.text = balanceStr

            var stockname = holdStockModel?.stockName ?? ""
            if stockname.count > 30 {
                stockname = String(stockname.prefix(30))
                stockname += "..."
            }
            self.stocknameLabel.text = stockname

            var market = ".HK"
            if self.exchangeType == YXExchangeType.us.rawValue || self.exchangeType == YXExchangeType.usop.rawValue {
                market = ".US"
            } else if self.exchangeType == YXExchangeType.sg.rawValue {
                market = ".SG"
            }

            if let stockCode = holdStockModel?.stockCode {
                self.symbolLabel.isHidden = false
                self.symbolLabel.text = "\(stockCode + market)"
            } else {
                self.symbolLabel.text = nil
                self.symbolLabel.isHidden = true
            }

            var priceString = "--"
            if let lastPrice = holdStockModel?.lastPrice {
                priceString =  quotePriceFormatter.string(from: lastPrice) ?? "--"
            }

            var costString = "--"
            if let startPrice = holdStockModel?.startPrice {
                costString = priceFormatter.string(from: startPrice) ?? "--"
            }

            self.nowPriceLabel.text = String(format: "%@: %@", YXLanguageUtility.kLang(key: "hold_share_price"), priceString)
            self.costLabel.text = String(format: "%@: %@", YXLanguageUtility.kLang(key: "hold_share_cost"), costString)

            reloadUI(with: holdStatus)
        }
    }

    var assetModel: YXAccountAssetData? {
        didSet {
            guard let assetModel = assetModel else {
                return
            }

            var balanceTitle = subShareType.descString
            if subShareType == .assetDailyAmount || subShareType == .assetTotalAmount {
                balanceTitle.append("(\(unitString))")
            }
            balanceTitleLabel.text = balanceTitle

            var holdStatus: HoldStatus = .average
            var balanceStr = ""

            if self.subShareType == .assetDailyPercent {
                if let percent = assetModel.todayProfitPercent?.doubleValue {

                    if percent > 0 {
                        holdStatus = .profit
                    } else if percent < 0 {
                        holdStatus = .loss
                    }

                    let string = String(format: "%@%.02f%%", (percent > 0 ? "+" : ""), percent * 100.0)
                    balanceStr = string
                } else {
                    balanceStr = "--"
                }
            } else if self.subShareType == .assetDailyAmount {
                if let value = assetModel.todayProfit,
                   let formatString = moneyFormatter.string(from: value) {

                    if value.doubleValue > 0 {
                        holdStatus = .profit
                    } else if value.doubleValue < 0 {
                        holdStatus = .loss
                    }

                    let string = String(format: "%@%@", (value.doubleValue > 0 ? "+" : ""), formatString)
                    balanceStr = string
                } else {
                    balanceStr = "0.00"
                }
            } else if self.subShareType == .assetTotalAmount {
                if let value = assetModel.totalHoldingBalance,
                   let formatString = moneyFormatter.string(from: value) {

                    if value.doubleValue > 0 {
                        holdStatus = .profit
                    } else if value.doubleValue < 0 {
                        holdStatus = .loss
                    }

                    let string = String(format: "%@%@", (value.doubleValue > 0 ? "+" : ""), formatString)
                    balanceStr = string
                } else {
                    balanceStr = "0.00"
                }
            }

            balanceLabel.text = balanceStr

            reloadUI(with: holdStatus)
        }
    }

    var orderModel: YXOrderModel? {
        didSet {
            self.statusLabel.isHidden = true
            self.statusImageView.image = UIImage(named: "img_share_order")

            var stockname = orderModel?.symbolName ?? ""
            if stockname.count > 30 {
                stockname = String(stockname.prefix(30))
                stockname += "..."
            }
            self.stocknameLabel.text = stockname

            var market = ".HK"
            if self.exchangeType == YXExchangeType.us.rawValue {
                market = ".US"
            } else if self.exchangeType == YXExchangeType.sg.rawValue {
                market = ".SG"
            }

            if let stockCode = orderModel?.symbol {
                self.symbolLabel.isHidden = false
                self.symbolLabel.text = "\(stockCode + market)"
            } else {
                self.symbolLabel.text = nil
                self.symbolLabel.isHidden = true
            }

            let priceAttributedText = NSMutableAttributedString()

            do {
                let string = "\(YXLanguageUtility.kLang(key: "share_hold_transaction_price"))(\(orderModel?.market.lowercased().coinName ?? "")): "
                let attributes: [NSAttributedString.Key : Any] = [.foregroundColor: textColorLevel3,
                                                                  .font: UIFont.systemFont(ofSize: 12)]
                let attributedText = NSAttributedString.init(string: string, attributes: attributes)
                priceAttributedText.append(attributedText)
            }

            do {
                var string = "--"
                if let entrustPrice = orderModel?.businessAvgPrice,
                   let priceStr = priceFormatter.string(from: entrustPrice) {
                    string = priceStr
                }
                let attributes: [NSAttributedString.Key : Any] = [.foregroundColor: textColorLevel1,
                                                                  .font: UIFont.systemFont(ofSize: 12, weight: .medium)]
                let attributedText = NSAttributedString.init(string: string, attributes: attributes)
                priceAttributedText.append(attributedText)
            }

            do {
                let tradeDirection: TradeDirection = orderModel?.entrustSide == TradeDirection.buy.entrustSide ? .buy : .sell
                let string = " \(tradeDirection.text.uppercased())"
                let attributes: [NSAttributedString.Key : Any] = [.foregroundColor: tradeDirection.color,
                                                                  .font: UIFont.systemFont(ofSize: 12)]
                let attributedText = NSAttributedString.init(string: string, attributes: attributes)
                priceAttributedText.append(attributedText)
            }

            orderPriceLabel.attributedText = priceAttributedText

            let quantityAttributedText = NSMutableAttributedString()

            do {
                var string = YXLanguageUtility.kLang(key: "share_hold_transaction_num")
                if orderModel?.symbolType != 4 {  // 期权不用显示数量单位
                    string.append("(\(YXLanguageUtility.kLang(key: "SHR")))")
                }
                string.append(": ")

                let attributes: [NSAttributedString.Key : Any] = [.foregroundColor: textColorLevel3,
                                                                  .font: UIFont.systemFont(ofSize: 12)]
                let attributedText = NSAttributedString.init(string: string, attributes: attributes)
                quantityAttributedText.append(attributedText)
            }

            do {
                var string = "--"
                if let entrustQty = orderModel?.businessQty,
                   let countStr = countFormatter.string(from: entrustQty) {
                    string = countStr
                }
                let attributes: [NSAttributedString.Key : Any] = [.foregroundColor: textColorLevel1,
                                                                  .font: UIFont.systemFont(ofSize: 12, weight: .medium)]
                let attributedText = NSAttributedString.init(string: string, attributes: attributes)
                quantityAttributedText.append(attributedText)
            }

            quantityLabel.attributedText = quantityAttributedText
        }
    }

    var orderDetailModel: YXOrderDetailData? {
        didSet {
            let orderInfo = orderDetailModel?.detailList?.last

            self.statusLabel.isHidden = true
            self.statusImageView.image = UIImage(named: "img_share_order")

            var stockname = orderDetailModel?.symbolName ?? ""
            if stockname.count > 30 {
                stockname = String(stockname.prefix(30))
                stockname += "..."
            }
            self.stocknameLabel.text = stockname

            var market = ".HK"
            if self.exchangeType == YXExchangeType.us.rawValue {
                market = ".US"
            } else if self.exchangeType == YXExchangeType.sg.rawValue {
                market = ".SG"
            }

            if let stockCode = orderDetailModel?.symbol {
                self.symbolLabel.isHidden = false
                self.symbolLabel.text = "\(stockCode + market)"
            } else {
                self.symbolLabel.text = nil
                self.symbolLabel.isHidden = true
            }

            let priceAttributedText = NSMutableAttributedString()

            do {
                let string = "\(YXLanguageUtility.kLang(key: "share_hold_transaction_price"))(\(orderDetailModel?.market?.lowercased().coinName ?? "")): "
                let attributes: [NSAttributedString.Key : Any] = [.foregroundColor: textColorLevel3,
                                                                  .font: UIFont.systemFont(ofSize: 12)]
                let attributedText = NSAttributedString.init(string: string, attributes: attributes)
                priceAttributedText.append(attributedText)
            }

            do {
                var string = "--"
                if let entrustPrice = orderInfo?.businessAvgPrice?.value as? NSNumber,
                   let priceStr = priceFormatter.string(from: entrustPrice) {
                    string = priceStr
                }
                let attributes: [NSAttributedString.Key : Any] = [.foregroundColor: textColorLevel1,
                                                                  .font: UIFont.systemFont(ofSize: 12, weight: .medium)]
                let attributedText = NSAttributedString.init(string: string, attributes: attributes)
                priceAttributedText.append(attributedText)
            }

            do {
                let tradeDirection: TradeDirection = orderDetailModel?.entrustSide == TradeDirection.buy.entrustSide ? .buy : .sell
                let string = " \(tradeDirection.text.uppercased())"
                let attributes: [NSAttributedString.Key : Any] = [.foregroundColor: tradeDirection.color,
                                                                  .font: UIFont.systemFont(ofSize: 12)]
                let attributedText = NSAttributedString.init(string: string, attributes: attributes)
                priceAttributedText.append(attributedText)
            }

            orderPriceLabel.attributedText = priceAttributedText

            let quantityAttributedText = NSMutableAttributedString()

            do {
                var string = YXLanguageUtility.kLang(key: "share_hold_transaction_num")
                if orderDetailModel?.symbolType != "4" { // 期权不用显示数量单位
                    string.append("(\(YXLanguageUtility.kLang(key: "SHR")))")
                }
                string.append(": ")

                let attributes: [NSAttributedString.Key : Any] = [.foregroundColor: textColorLevel3,
                                                                  .font: UIFont.systemFont(ofSize: 12)]
                let attributedText = NSAttributedString.init(string: string, attributes: attributes)
                quantityAttributedText.append(attributedText)
            }

            do {
                var string = "--"
                if let entrustQty = orderInfo?.businessQty?.value as? NSNumber,
                   let countStr = countFormatter.string(from: entrustQty) {
                    string = countStr
                }
                let attributes: [NSAttributedString.Key : Any] = [.foregroundColor: textColorLevel1,
                                                                  .font: UIFont.systemFont(ofSize: 12, weight: .medium)]
                let attributedText = NSAttributedString.init(string: string, attributes: attributes)
                quantityAttributedText.append(attributedText)
            }

            quantityLabel.attributedText = quantityAttributedText
        }
    }

    fileprivate lazy var moneyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.positiveFormat = "###,##0.00";
        formatter.locale = Locale(identifier: "zh")
        return formatter;
    }()

    fileprivate lazy var countFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal;
        formatter.groupingSize = 3;
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 4
        return formatter;
    }()

    fileprivate lazy var quotePriceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal;
        formatter.groupingSeparator = ""
        formatter.maximumFractionDigits = 3
        formatter.minimumFractionDigits = 3
        return formatter;
    }()

    fileprivate lazy var priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal;
        formatter.groupingSeparator = ""
        formatter.maximumFractionDigits = 4
        return formatter;
    }()

    var loadImageBlock: (() -> Void)?
    var updateHeightBlock: ((_ height: CGFloat) -> Void)?
    var shareType: HoldShareType = .hold
    var unitString: String = ""
    var exchangeType: Int = 0
    var totalHeight: CGFloat = 0
    var qrcodeUrlString: String = ""
    var subShareType: HoldShareSubType = .normalPercent

    //MARK: Initializer
    init(frame: CGRect, shareType: HoldShareType, exchangeType: Int, qrcodeUrlString: String, subShareType: HoldShareSubType) {
        super.init(frame: frame)

        self.shareType = shareType
        self.exchangeType = exchangeType
        if exchangeType == YXExchangeType.hk.rawValue {
            unitString = YXLanguageUtility.kLang(key: "common_hk_dollar")
        } else if exchangeType == YXExchangeType.us.rawValue || exchangeType == YXExchangeType.usop.rawValue {
            unitString = YXLanguageUtility.kLang(key: "common_us_dollar")
        } else if exchangeType == YXExchangeType.sg.rawValue {
            unitString = YXLanguageUtility.kLang(key: "common_sg_dollar")
        }
        self.qrcodeUrlString = qrcodeUrlString
        self.subShareType = subShareType

        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds
    }

    func initUI() {
        layer.addSublayer(gradientLayer)

        addSubview(logoImageView)
        logoImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(20)
        }

        addSubview(userAndDateLabel)
        userAndDateLabel.snp.makeConstraints { (make) in
            make.left.greaterThanOrEqualTo(logoImageView.snp.right).offset(8)
            make.centerY.equalTo(logoImageView.snp.centerY)
            make.right.equalToSuperview().offset(-16)
        }

        let formatter = DateFormatter.en_US_POSIX()
        if YXUserManager.isENMode() {
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "dd MMM, yyyy"
        } else {
            formatter.dateFormat = "yyyy-MM-dd"
        }
        userAndDateLabel.text = "\(YXUserManager.shared().curLoginUser?.nickname ?? "") - \(formatter.string(from: Date()))"

        addSubview(statusLabel)
        statusLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(50)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.height.equalTo(44)
        }

        if shareType == .order {
            addSubview(activityTipsView)
            activityTipsView.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(66)
                make.centerX.equalToSuperview()
                make.height.equalTo(24)
            }
        }

        addSubview(statusImageView)
        statusImageView.snp.makeConstraints { (make) in
            let top = shareType == .hold ? 94 : 106
            make.top.equalToSuperview().offset(top)
            make.centerX.equalToSuperview()
            make.width.equalTo(260)
            make.height.equalTo(140)
        }

        if shareType == .hold || shareType == .asset {
            addSubview(balanceTitleLabel)
            balanceTitleLabel.snp.makeConstraints { (make) in
                let top = shareType == .asset ? 28 : 8
                make.top.equalTo(statusImageView.snp.bottom).offset(top)
                make.left.equalToSuperview().offset(30)
                make.right.equalToSuperview().offset(-30)
            }

            addSubview(balanceLabel)
            balanceLabel.snp.makeConstraints { (make) in
                make.top.equalTo(balanceTitleLabel.snp.bottom).offset(6)
                make.left.equalToSuperview().offset(30)
                make.right.equalToSuperview().offset(-30)
            }
        }

        if shareType == .hold || shareType == .order {
            let stockView = UIStackView(arrangedSubviews: [stocknameLabel, symbolLabel])
            stockView.axis = .horizontal
            stockView.spacing = 4
            stockView.distribution = .fill

            addSubview(stockView)

            stockView.snp.makeConstraints { (make) in
                if shareType == .hold {
                    make.top.equalTo(balanceLabel.snp.bottom).offset(8)
                } else {
                    make.top.equalTo(statusImageView.snp.bottom).offset(20)
                }
                make.centerX.equalToSuperview()
                make.left.greaterThanOrEqualToSuperview().offset(8)
                make.right.lessThanOrEqualToSuperview().offset(-8)
            }

            if shareType == .hold {
                addSubview(nowPriceLabel)

                let separator = UIView()
                separator.backgroundColor = textColorLevel3
                addSubview(separator)

                addSubview(costLabel)

                nowPriceLabel.snp.makeConstraints { (make) in
                    make.centerY.equalTo(separator)
                    make.right.equalTo(separator.snp.left).offset(-12)
                }

                separator.snp.makeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.top.equalTo(stockView.snp.bottom).offset(9)
                    make.width.equalTo(1)
                    make.height.equalTo(10)
                }

                costLabel.snp.makeConstraints { (make) in
                    make.centerY.equalTo(separator)
                    make.left.equalTo(separator.snp.right).offset(12)
                }
            } else if shareType == .order {
                addSubview(orderPriceLabel)
                orderPriceLabel.snp.makeConstraints { (make) in
                    make.left.equalToSuperview().offset(30)
                    make.right.equalToSuperview().offset(-30)
                    make.top.equalTo(stockView.snp.bottom).offset(12)
                }

                addSubview(quantityLabel)
                quantityLabel.snp.makeConstraints { (make) in
                    make.left.equalToSuperview().offset(30)
                    make.right.equalToSuperview().offset(-30)
                    make.top.equalTo(orderPriceLabel.snp.bottom).offset(4)
                }
            }
        }

        addSubview(bottomBgView)
        bottomBgView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(120)
        }

        bottomBgView.addSubview(qrCodeImageView)
        qrCodeImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(56)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
        }

        if let image = YXQRCodeHelper.qrCodeImage(with: self.qrcodeUrlString) {
            self.qrCodeImageView.image = image
        }

        let advertisementStackView = UIStackView(arrangedSubviews: [advertisementView, topBottomView, bottomBottomView])
        advertisementStackView.distribution = .equalSpacing
        advertisementStackView.axis = .vertical
        bottomBgView.addSubview(advertisementStackView)
        advertisementStackView.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.top.equalTo(16)
            make.bottom.equalTo(-16)
            make.right.equalTo(qrCodeImageView.snp.left).offset(-5)
        }
    }

    lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.qmui_color(withHexString: "#FBFDFF")!.cgColor, UIColor.qmui_color(withHexString: "#E5EFFF")!.cgColor]
        layer.locations = [0, 1.0]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.79, y: 0.79)
        layer.frame = self.bounds
        return layer
    }()

    lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.image = UIImage(named: "hold_share_logo_blue")
        return imageView
    }()

    lazy var userAndDateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = textColorLevel2
        label.font = .systemFont(ofSize: 10)
        label.textAlignment = .right
        return label
    }()

    lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = textColorLevel1
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    lazy var statusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var activityTipsView: QMUIButton = {
        let view = QMUIButton()
        view.backgroundColor = QMUITheme().themeTintColor().withAlphaComponent(0.09)
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.setImage(UIImage(named: "icon_gift"), for: .normal)
        view.setTitle(YXLanguageUtility.kLang(key: "share_to_get_mystery_box_tip"), for: .normal)
        view.tintColor = QMUITheme().themeTintColor()
        view.adjustsImageTintColorAutomatically = true
        view.adjustsTitleTintColorAutomatically = true
        view.spacingBetweenImageAndTitle = 4
        view.titleLabel?.font = .systemFont(ofSize: 12)
        view.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return view
    }()

    lazy var balanceTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = textColorLevel3
        label.textAlignment = .center
        label.text = "Total Profit and Loss"
        return label
    }()

    lazy var balanceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 28, weight: .semibold)
        label.textColor = textColorLevel1
        label.textAlignment = .center
        label.text = "--"
        return label
    }()

    lazy var heaverRatioLabel: QMUILabel = {
        let label = QMUILabel()
        label.numberOfLines = 1
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.contentEdgeInsets = UIEdgeInsets(top: 3, left: 7, bottom: 3, right: 7)
        label.layer.cornerRadius = 4
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.white.cgColor
        return label
    }()

    lazy var stocknameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = textColorLevel1
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        return label
    }()

    lazy var symbolLabel: QMUILabel = {
        let label = QMUILabel()
        label.numberOfLines = 1
        label.textColor = textColorLevel2
        label.font = .systemFont(ofSize: 8)
        label.textAlignment = .center
        label.contentEdgeInsets = UIEdgeInsets(top: 1, left: 4, bottom: 1, right: 4)
        label.layer.borderColor = textColorLevel2.cgColor
        label.layer.borderWidth = QMUIHelper.pixelOne
        label.layer.cornerRadius = 2
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    lazy var nowPriceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = textColorLevel3
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .right
        return label
    }()

    lazy var costLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = textColorLevel3
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .left
        return label
    }()

    lazy var orderPriceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()

    lazy var quantityLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()

    lazy var qrCodeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()

    lazy var advertisementView: YXHoldShareContentBottomView = {
//        let separator = YXUserManager.curLanguage() == .EN ? " - " : "\n"
        let separator = "\n"
        let view = YXHoldShareContentBottomView(
            title: YXLanguageUtility.kLang(key: "hold_Advantage_title"),
            detail: YXLanguageUtility.kLang(key: "hold_Advantage"),
            separator: separator
        )
        return view
    }()

    lazy var topBottomView: YXHoldShareContentBottomView = {
//        let separator = YXUserManager.curLanguage() == .EN ? " - " : "\n"
        let separator = "\n"
        let view = YXHoldShareContentBottomView(
            title: YXLanguageUtility.kLang(key: "hold_Advantage_title1"),
            detail: YXLanguageUtility.kLang(key: "hold_Advantage1"),
            separator: separator
        )
        return view
    }()

    lazy var bottomBottomView: YXHoldShareContentBottomView = {
//        let separator = YXUserManager.curLanguage() == .EN ? " - " : "\n"
        let separator = "\n"
        let view = YXHoldShareContentBottomView(
            title: YXLanguageUtility.kLang(key: "hold_Advantage_title2"),
            detail: YXLanguageUtility.kLang(key: "hold_Advantage2"),
            separator: separator
        )
        return view
    }()

    lazy var bottomBgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.qmui_color(withHexString: "#FBFDFF")
        return view
    }()

}

extension YXHoldShareContentView {

    func reloadUI(with holdStatus: HoldStatus) {
        var statusImage: UIImage?
        var desString: String?
        var color: UIColor?

        switch holdStatus {
        case .average:
            statusImage = UIImage(named: "img_hold_status_average")

            var texts = [YXLanguageUtility.kLang(key: "hold_average_share_desc1"),
                         YXLanguageUtility.kLang(key: "hold_average_share_desc2"),
                         YXLanguageUtility.kLang(key: "hold_average_share_desc3")]
            if YXUserManager.curLanguage() == .CN { // 简体多一个文案
                texts.append("休整休整，来日方长")
            }
            desString = texts.randomElement()

            color = textColorLevel1
        case .profit:
            statusImage = UIImage(named: "img_hold_status_profit")
            desString = [YXLanguageUtility.kLang(key: "hold_profit_share_desc1"),
                         YXLanguageUtility.kLang(key: "hold_profit_share_desc2"),
                         YXLanguageUtility.kLang(key: "hold_profit_share_desc3"),
                         YXLanguageUtility.kLang(key: "hold_profit_share_desc4"),
                         YXLanguageUtility.kLang(key: "hold_profit_share_desc5"),
                         YXLanguageUtility.kLang(key: "hold_profit_share_desc6"),
                         YXLanguageUtility.kLang(key: "hold_profit_share_desc7")].randomElement()
            color = QMUITheme().stockRedColor()
        case .loss:
            statusImage = UIImage(named: "img_hold_status_loss")

            var texts = [YXLanguageUtility.kLang(key: "hold_loss_share_desc1"),
                         YXLanguageUtility.kLang(key: "hold_loss_share_desc2"),
                         YXLanguageUtility.kLang(key: "hold_loss_share_desc3")]
            if YXUserManager.curLanguage() == .CN { // 简体多一个文案
                texts.append("反向之王，原来是我")
            }
            desString = texts.randomElement()

            color = QMUITheme().stockGreenColor()
        }

        statusLabel.text = desString
        statusImageView.image = statusImage
        balanceLabel.textColor = color
    }

}
