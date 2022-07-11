//
//  YXSmartOrderListCell.swift
//  YouXinZhengQuan
//
//  Created by Mac on 2020/4/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXSmartOrderListCell: YXTableViewCell {

    @objc var isOrderPage: Bool = true {
        didSet {
            topView.isOrderPage = isOrderPage
        }
    } // 是否在下单页

    @objc var isShowExpandCell: Bool = false {
        didSet {
            containerView.snp.updateConstraints { make in
                make.bottom.equalToSuperview().offset(isShowExpandCell ? 0 : -8)
            }
        }
    }

    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()

    lazy var topView: YXSmartOrderListCellTopView = {
        let view = YXSmartOrderListCellTopView()
        view.isOrderPage = isOrderPage
        return view
    }()

    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 0
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    }()

    lazy var typeView: YXSmartOrderListCellItemView = {
        let view = YXSmartOrderListCellItemView()
        view.titleLabel.text = YXLanguageUtility.kLang(key: "order_type")
        return view
    }()

    lazy var conditionView: UIView = {
        let view = UIView()
        view.addSubview(conditionLabel)

        conditionLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-8)
        }
        return view
    }()

    lazy var conditionLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .right
        label.numberOfLines = 0
        return label
    }()

    lazy var trackAssetsView: YXSmartOrderListCellItemView = {
        let view = YXSmartOrderListCellItemView()
        view.titleLabel.text = YXLanguageUtility.kLang(key: "track_stock")
        return view
    }()

    lazy var triggerPriceView: YXSmartOrderListCellItemView = {
        let view = YXSmartOrderListCellItemView()
        view.titleLabel.text = YXLanguageUtility.kLang(key: "smart_trigger_price")
        return view
    }()

    lazy var directionView: YXSmartOrderListCellItemView = {
        let view = YXSmartOrderListCellItemView()
        return view
    }()

    lazy var lastestTriggerPriceView: YXSmartOrderListCellItemView = {
        let view = YXSmartOrderListCellItemView()
        view.titleLabel.text = YXLanguageUtility.kLang(key: "latest_trigger_price")
        return view
    }()

    lazy var amountView: YXSmartOrderListCellItemView = {
        let view = YXSmartOrderListCellItemView()
        view.titleLabel.text = YXLanguageUtility.kLang(key: "trigger_amount")
        return view
    }()

    lazy var setView: YXSmartOrderListCellItemView = {
        let view = YXSmartOrderListCellItemView()
        view.titleLabel.text = YXLanguageUtility.kLang(key: "order_set")
        return view
    }()

    lazy var validDateView: UIView = {
        let view = UIView()
        view.addSubview(validDateLabel)

        validDateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-8)
        }
        return view
    }()

    lazy var validDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 10)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.numberOfLines = 0
        label.textAlignment = .right
        return label
    }()

    fileprivate lazy var moneyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.positiveFormat = "###,##0.00";
        formatter.locale = Locale(identifier: "zh")
        return formatter;
    }()

    fileprivate lazy var priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal;
        formatter.groupingSeparator = ""
        formatter.maximumFractionDigits = 4
        return formatter;
    }()

    override func initialUI() {
        super.initialUI()

        backgroundColor = QMUITheme().backgroundColor()
        contentView.backgroundColor = QMUITheme().backgroundColor()

        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
        }

        containerView.addSubview(topView)
        topView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(60)
        }

        containerView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }

        stackView.addArrangedSubview(typeView)
        stackView.addArrangedSubview(conditionView)
        stackView.addArrangedSubview(trackAssetsView)
        stackView.addArrangedSubview(triggerPriceView)
        stackView.addArrangedSubview(directionView)
        stackView.addArrangedSubview(lastestTriggerPriceView)
        stackView.addArrangedSubview(amountView)
        stackView.addArrangedSubview(setView)
        stackView.addArrangedSubview(validDateView)
    }
    
    override func refreshUI() {
        super.refreshUI()
        
        guard let model = model as? YXConditionOrderModel else {
            return
        }

        topView.bind(to: model)

        let orderType = SmartOrderType(rawValue: Int(model.conditionType))
        let unit = YXToolUtility.currencyName(model.currency)

        typeView.valueLabel.text = model.conditionTypeDesc

        var conditionPriceStr = "--"
        let conditionPrice = model.conditionPrice.doubleValue
        if conditionPrice != 0 {
            conditionPriceStr = priceFormatter.string(from: model.conditionPrice) ?? "--"
        }

        switch orderType {
        case .breakBuy,
             .highPriceSell:
            if let amountIncrease = model.amountIncrease?.doubleValue {
                conditionLabel.text = String(format: YXLanguageUtility.kLang(key: "dialog_price_up_to"), amountIncrease * 100, conditionPriceStr, unit)
            } else {
                conditionLabel.text = String(format: YXLanguageUtility.kLang(key: "dialog_price_break"), conditionPriceStr, unit)
            }

        case .lowPriceBuy,
             .breakSell:
            if let amountIncrease = model.amountIncrease?.doubleValue {
                conditionLabel.text = String(format: YXLanguageUtility.kLang(key: "dialog_price_down_to"), amountIncrease * 100, conditionPriceStr, unit)
            } else {
                conditionLabel.text = String(format: YXLanguageUtility.kLang(key: "dialog_price_down"), conditionPriceStr, unit)
            }
        case .stopProfitSell:
            if let amountIncrease = model.amountIncrease?.doubleValue {
                conditionLabel.text = String(format: YXLanguageUtility.kLang(key: "costprice_rose_to_for_order_list"), amountIncrease * 100.0, conditionPriceStr, unit)
            }
            break
        case .stopLossSell:
            if let amountIncrease = model.amountIncrease?.doubleValue {
                conditionLabel.text = String(format: YXLanguageUtility.kLang(key: "costprice_fell_to_for_order_list"), amountIncrease * 100.0, conditionPriceStr, unit)
            }
        case .tralingStop:
            if let amountIncrease = model.amountIncrease?.doubleValue, amountIncrease > 0 {
                conditionLabel.text = YXLanguageUtility.kLang(key: "drop_more_than") + String(format: "%.2f", amountIncrease * 100) + "%"
            } else if let dropPrice = model.dropPrice, let dropPriceString = priceFormatter.string(from: dropPrice) {
                conditionLabel.text = String(format: YXLanguageUtility.kLang(key: "drop_more_than_to"), dropPriceString, unit)
            }
        default:
            conditionLabel.text = nil
            break
        }

        if let text = conditionLabel.text, !text.isEmpty {
            conditionView.isHidden = false
        } else {
            conditionView.isHidden = true
        }

        if orderType == .stockHandicap {
            trackAssetsView.isHidden = false
            triggerPriceView.isHidden = false
            trackAssetsView.valueLabel.text = model.releationStockName

            var priceString = priceFormatter.string(from: model.triggerPrice) ?? "--"
            if !model.relatedStockCurrency.isEmpty {
                priceString += YXLanguageUtility.kLang(key: "common_en_space")
                priceString += YXToolUtility.currencyName(model.relatedStockCurrency)
            }
            triggerPriceView.valueLabel.text = priceString
        } else {
            trackAssetsView.isHidden = true
            triggerPriceView.isHidden = true
        }

        if model.entrustSide == "B" {
            directionView.titleLabel.text = YXLanguageUtility.kLang(key: "hold_trade_buy")
        } else {
            directionView.titleLabel.text = YXLanguageUtility.kLang(key: "hold_trade_sell")
        }

        if orderType == .tralingStop  {
            lastestTriggerPriceView.isHidden = false
            lastestTriggerPriceView.valueLabel.text = (priceFormatter.string(from: model.triggerPrice) ?? "--") + YXLanguageUtility.kLang(key: "common_en_space") + unit;
        } else {
            lastestTriggerPriceView.isHidden = true
        }

        amountView.isHidden = model.entrustGear != nil

        let unitStr = YXLanguageUtility.kLang(key: "stock_unit")

        if let entrustGear = model.entrustGear,
           let entrustGearStr = GearType(rawValue: entrustGear.intValue)?.text {
            directionView.valueLabel.text = entrustGearStr + "*\(model.entrustAmount)" + unitStr
            amountView.valueLabel.text = "--"
        } else {
            if model.entrustPrice.doubleValue > 0 {
                ///「xxx*xxx股」
                let entrustAttr = (priceFormatter.string(from: model.entrustPrice) ?? "--") + "*\(model.entrustAmount)" + unitStr;
                directionView.valueLabel.text = entrustAttr

                ///金额 - 值
                if let formatString = moneyFormatter.string(from: model.entrustTotalMoney()) {
                    amountView.valueLabel.text = formatString + YXLanguageUtility.kLang(key: "common_en_space") + unit
                } else {
                    amountView.valueLabel.text = "--"
                }
            } else {
                directionView.valueLabel.text = "--"
                amountView.valueLabel.text = "--"
            }
        }

        setView.valueLabel.text = YXDateHelper.commonDateString(model.createTime, format: .DF_MDYHMS)

        var dateText = ""
        switch Int(model.strategyEnddateDesc) {
        case 1:
            dateText = YXLanguageUtility.kLang(key: "quote_before_close_effective")
        case 2:
            dateText = YXLanguageUtility.kLang(key: "two_days") + YXLanguageUtility.kLang(key: "valid_for_xx_days")
        case 3:
            dateText = YXLanguageUtility.kLang(key: "three_days") + YXLanguageUtility.kLang(key: "valid_for_xx_days")
        case 4:
            dateText = YXLanguageUtility.kLang(key: "one_weeks") + YXLanguageUtility.kLang(key: "valid_for_xx_days")
        case 5:
            dateText = YXLanguageUtility.kLang(key: "two_weeks") + YXLanguageUtility.kLang(key: "valid_for_xx_days")
        case 6:
            dateText = YXLanguageUtility.kLang(key: "thirty_day") + YXLanguageUtility.kLang(key: "valid_for_xx_days")
        case 7:
            dateText = "16:15-18:30 " + YXLanguageUtility.kLang(key: "valid_for_xx_days")
        case 8:
            dateText = "14:15-16:30 " + YXLanguageUtility.kLang(key: "valid_for_xx_days")
        case 9:
            dateText = YXLanguageUtility.kLang(key: "sixty_day") + YXLanguageUtility.kLang(key: "valid_for_xx_days")
        case 10:
            dateText = YXLanguageUtility.kLang(key: "ninety_day") + YXLanguageUtility.kLang(key: "valid_for_xx_days")
        default:
            break
        }

        if model.market == YXMarketType.US.rawValue.uppercased() {
            if model.tradePeriod == "A" ||  model.tradePeriod == "B" ||  model.tradePeriod == "AB" {
                dateText += ", "
                dateText += YXLanguageUtility.kLang(key: "support_pre_after")
            }
        }
        validDateLabel.text = dateText

        var color = QMUITheme().textColorLevel1()
        if self.isOrderPage && model.status != 0 {
            color = QMUITheme().textColorLevel4()
            validDateLabel.textColor = color
        } else {
            validDateLabel.textColor = QMUITheme().textColorLevel3()
        }
        typeView.valueLabel.textColor = color
        conditionLabel.textColor = color
        trackAssetsView.valueLabel.textColor = color
        triggerPriceView.valueLabel.textColor = color
        directionView.valueLabel.textColor = color
        lastestTriggerPriceView.valueLabel.textColor = color
        amountView.valueLabel.textColor = color
        setView.valueLabel.textColor = color
    }

}

class YXSmartOrderListCellTopView: UIView {

    @objc var isOrderPage: Bool = true // 是否在下单页

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()

    lazy var marketLabel: YXMarketIconLabel = {
        let label = YXMarketIconLabel()
        return label
    }()

    lazy var symbolLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()

    lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 16)
        return label
    }()

    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .right
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(nameLabel)
        addSubview(marketLabel)
        addSubview(symbolLabel)
        addSubview(statusLabel)
        addSubview(timeLabel)

        let lineView = UIView()
        lineView.backgroundColor = QMUITheme().separatorLineColor()
        addSubview(lineView)

        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(18)
            make.right.lessThanOrEqualTo(statusLabel.snp.left).offset(-10)
        }

        marketLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.left)
            make.centerY.equalTo(symbolLabel)
        }

        symbolLabel.snp.makeConstraints { (make) in
            make.left.equalTo(marketLabel.snp.right).offset(4)
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
        }

        statusLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(nameLabel)
        }

        timeLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(symbolLabel)
            make.right.equalTo(statusLabel.snp.right)
        }

        lineView.snp.makeConstraints { (make) in
            make.top.equalTo(symbolLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(QMUIHelper.pixelOne)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(to model: YXConditionOrderModel) {
        nameLabel.text = model.stockName
        marketLabel.market = model.market?.lowercased()
        symbolLabel.text = model.stockCode
        statusLabel.text = model.statusDes

        ///有效期
        var over = YXLanguageUtility.kLang(key: "hold_over")
        if YXUserManager.isENMode() {
            over = " " + YXLanguageUtility.kLang(key: "orderfilter_lost_effectiveness")
        }
        if model.strategyEnddate.count > 0 {
            timeLabel.text = YXDateHelper.commonDateString(model.strategyEnddate, format: .DF_MDHM) + over
        } else {
            timeLabel.text = ""
        }

        if self.isOrderPage && model.status != 0 {
            let color = QMUITheme().textColorLevel3()
            nameLabel.textColor = color
            statusLabel.textColor = color

            let color2 = QMUITheme().textColorLevel4()
            symbolLabel.textColor = color2
        } else {
            if model.status == 0 {
                statusLabel.textColor = QMUITheme().themeTextColor()
            } else if model.status == 1 {
                statusLabel.textColor = UIColor.qmui_color(withHexString: "#F9A800")
            } else if model.status == 2 {
                statusLabel.textColor = QMUITheme().textColorLevel3()
            } else if model.status == 3 {
                statusLabel.textColor = QMUITheme().textColorLevel3()
            }

            let color = QMUITheme().textColorLevel1()
            nameLabel.textColor = color

            let color2 = QMUITheme().textColorLevel3()
            symbolLabel.textColor = color2
        }
    }

}


class YXSmartOrderListCellItemView: UIView {

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 14)
        return label
    }()

    lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(titleLabel)
        addSubview(valueLabel)

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(8)
            make.bottom.equalToSuperview().offset(-8)
        }

        valueLabel.snp.makeConstraints { make in
            make.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(8)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(8)
            make.bottom.equalToSuperview().offset(-8)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
