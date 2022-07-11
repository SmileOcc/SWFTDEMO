//
//  YXTradeHoldInfoView.swift
//  YouXinZhengQuan
//
//  Created by suntao on 2021/3/30.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

extension PowerInfo {
    func powerAmount(_ paymentType: TradePaymentType) -> Double {
        switch paymentType {
        case .cash:
            return cashEnableAmount
        case .margin,
             .optionBuy:
            return marginEnableAmount
        case .sell:
            return saleEnableAmount
        }
    }
    
    func powerTypes(_ payment: TradePaymentType) -> [PowerInfo.PowerType] {
        switch payment {
        case .cash:
            return [.buy, .cashBuyPower]
        case .margin:
            return [.buy, .marginBuy, .marginBuyPower]
        case .optionBuy:
            return [.optionBuy]
        case .sell:
            return [.sell]
        }
    }
}


class YXTradePowerInfoView: UIView, YXTradeHeaderSubViewProtocol {
    
    var powerInfo: PowerInfo! {
        didSet {
            viewLayout()
        }
    }
    
    var paymentType: TradePaymentType = .cash {
        didSet {
            if oldValue != paymentType {
                viewLayout()
            }
        }
    }
    
    var powerAmount: Double {
        powerInfo.powerAmount(paymentType)
    }
    
    lazy var floatLayoutView: QMUIFloatLayoutView = {
        let view = QMUIFloatLayoutView()
        
        return view
    }()
    
    convenience init(powerInfo: PowerInfo) {
        self.init()
        
        addSubview(floatLayoutView)
        
        floatLayoutView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(8)
            make.bottom.equalToSuperview()
        }
        self.powerInfo = powerInfo
    }
    
    private func viewLayout() {
        
        floatLayoutView.subviews.forEach { (subView) in
            subView.removeFromSuperview()
        }
        
        var floatLayoutWidth = YXConstant.screenWidth - 64
        
        if floatLayoutView.width > 0 {
            floatLayoutWidth = floatLayoutView.width
        }

        let itemSize = CGSize(width: floatLayoutWidth / 2, height: 26)
        let largeItemSize = CGSize(width: floatLayoutWidth, height: 26)
        let largeItemTwoLineSize = CGSize(width: floatLayoutWidth, height: 40)
        floatLayoutView.maximumItemSize = largeItemTwoLineSize

        var height: CGFloat = 8
        let types = powerInfo.powerTypes(paymentType)
        //if let params = powerInfo.params, params.tradeOrderType == .smart {
        if let params = powerInfo.params {
            if paymentType == .margin {
                floatLayoutView.minimumItemSize = itemSize
            } else {
                floatLayoutView.minimumItemSize = largeItemSize
            }

            types.forEach { powerType in
                let label = UILabel(frame: CGRect(origin: .zero, size: largeItemSize))
                let attributedString = NSMutableAttributedString(attributedString: powerType.attributedText(with: params))
                attributedString.append(NSAttributedString(string: ": ", attributes: [.foregroundColor: QMUITheme().textColorLevel3(), .font: UIFont.systemFont(ofSize: 12)]))
                attributedString.append(powerType.attributedDesc(with: powerInfo))
                label.numberOfLines = 0
                label.attributedText = attributedString
                
                floatLayoutView.addSubview(label)
                
                if paymentType == .margin,
                   (powerType == .buy || powerType == .marginBuy) {
                    label.frame = CGRect(origin: .zero, size: itemSize)
                    if powerType == .marginBuy {
                        label.textAlignment = .right
                        if attributedString.width(limitHeight: 26) > itemSize.width {
                            height += 26
                        } else {
                            height += 0
                        }
                    } else {
                        height += 26
                    }
                } else {
                    height += 26
                }
                
                if powerType == .cashBuyPower {
                    let upgradeButton = QMUIButton()
                    upgradeButton.setTitleColor(QMUITheme().mainThemeColor(), for: .normal)
                    upgradeButton.titleLabel?.font = .systemFont(ofSize: 10)
                    upgradeButton.imagePosition = .left
                    upgradeButton.layer.borderWidth = 1
                    upgradeButton.layer.borderColor = QMUITheme().mainThemeColor().cgColor
                    upgradeButton.layer.cornerRadius = 9
                    upgradeButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
                    upgradeButton.setTitle(YXLanguageUtility.kLang(key: "common_upgrade"), for: .normal)
                    upgradeButton.setImage(UIImage(named: "icon_updrade"), for: .normal)
                    upgradeButton.spacingBetweenImageAndTitle = 1
                    upgradeButton.sizeToFit()
                    label.isUserInteractionEnabled = true
                    label.addSubview(upgradeButton)
                    
                    let stringWidth = attributedString.width(limitHeight: 18)
                    upgradeButton.frame = CGRect(x: stringWidth + 8, y: 4, width: upgradeButton.width, height: 18)
//                    upgradeButton.snp.makeConstraints { make in
//                        make.left.equalTo(stringWidth + 8)
//                        make.height.equalTo(18)
//                        make.width.equalTo(upgradeButton.width)
//                        make.center.equalToSuperview()
//                    }
                    upgradeButton.qmui_tapBlock = { _ in
                        YXWebViewModel.pushToWebVC(YXH5Urls.sgUpgradeMarginUrl())
                    }
                }
            }
        }
//        } else {
//            floatLayoutView.minimumItemSize = largeItemSize
//
//            types.forEach { powerType in
//                let itemView = YXTradePowerInfoItemView(frame: CGRect(origin: .zero, size: largeItemSize))
//                itemView.titleLabel.attributedText = powerType.attributedText(with: powerInfo.params)
//                itemView.valueLabel.attributedText = powerType.attributedDesc(with: powerInfo)
//
//                let titleWidth = itemView.titleLabel.attributedText?.width(limitHeight: 20) ?? 0
//                let valueWidth = itemView.valueLabel.attributedText?.width(limitHeight: 20) ?? 0
//
//                if titleWidth + valueWidth + 10 > floatLayoutWidth {
//                    itemView.frame = CGRect(origin: .zero, size: largeItemTwoLineSize)
//                    height += largeItemTwoLineSize.height
//                } else {
//                    height += largeItemSize.height
//                }
//                floatLayoutView.addSubview(itemView)
//            }
//        }
        
        contentHeight = height
    }
}

extension PowerInfo.PowerType {
    
    static var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.positiveFormat = "###,##0";
        formatter.locale = Locale(identifier: "zh")
        return formatter
    }
    
    static var fractionalNumberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.positiveFormat = "###,##0.0000";
        formatter.locale = Locale(identifier: "zh")
        return formatter
    }
    
    
    
    func attributedDesc(with powerInfo: PowerInfo) -> NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: QMUITheme().textColorLevel1(), .font: UIFont.systemFont(ofSize: 12)]
        let attributedDesc = NSMutableAttributedString(string: "", attributes: attributes)

        let unit = " " + YXLanguageUtility.kLang(key: "SHR")
        let attributedUnit = NSAttributedString(string: unit, attributes: attributes)
        
        switch self {
        case .buy:
            var string = "--"
            if powerInfo.cashEnableAmount >= 0 {
                if powerInfo.params?.tradeType == .fractional {
                    string = Self.fractionalNumberFormatter.string(from: NSNumber(value: powerInfo.cashEnableAmount)) ?? "--"
                } else {
                    string = Self.numberFormatter.string(from: NSNumber(value: powerInfo.cashEnableAmount)) ?? "--"
                }
            }
            attributedDesc.append(NSAttributedString(string: string, attributes: attributes))
            if string != "--" {
                attributedDesc.append(attributedUnit)
            }
        case .marginBuy:
            var string = "--"
            if powerInfo.marginEnableAmount >= 0 {
                if powerInfo.params?.tradeType == .fractional {
                    string = Self.fractionalNumberFormatter.string(from: NSNumber(value: powerInfo.marginEnableAmount)) ?? "--"
                } else {
                    string = Self.numberFormatter.string(from: NSNumber(value: powerInfo.marginEnableAmount)) ?? "--"
                }
            }
            attributedDesc.append(NSAttributedString(string: string, attributes: attributes))
            if string != "--" {
                attributedDesc.append(attributedUnit)
            }
        case .optionBuy:
            var string = "--"
            if powerInfo.marginEnableAmount >= 0 {
                string = Self.numberFormatter.string(from: NSNumber(value: powerInfo.marginEnableAmount)) ?? "--"
            }
            attributedDesc.append(NSAttributedString(string: string, attributes: attributes))
        case .sell:
            var string = "--"
            if powerInfo.saleEnableAmount >= 0 {
                if powerInfo.params?.tradeType == .fractional {
                    string = Self.fractionalNumberFormatter.string(from: NSNumber(value: powerInfo.saleEnableAmount)) ?? "--"
                } else {
                    string = Self.numberFormatter.string(from: NSNumber(value: powerInfo.saleEnableAmount)) ?? "--"
                }
            }
            attributedDesc.append(NSAttributedString(string: string, attributes: attributes))
            if string != "--", powerInfo.params?.market != kYXMarketUsOption {
                attributedDesc.append(attributedUnit)
            }
        case .cashBuyPower:
            let string = powerInfo.cashPurchasingPower
            attributedDesc.append(NSAttributedString(string: string, attributes: attributes))
        case .marginBuyPower:
            let string = powerInfo.marginPurchasingPower
            attributedDesc.append(NSAttributedString(string: string, attributes: attributes))
        }
        return attributedDesc
    }

    func attributedText(with params: PowerInfo.PowerParams?) -> NSAttributedString {
//        guard let params = params else {
//            return NSAttributedString(string: "")
//        }
        var text = ""
        switch self {
        case .buy:
            text = YXLanguageUtility.kLang(key: "trading_cash_buy_tip")
//            if params.powerOrderType == .market || params.powerOrderType == .bidding {
//                text = YXLanguageUtility.kLang(key: "trading_cash_buy_tip") + YXLanguageUtility.kLang(key: "trading_tip_estimate")
//            }
        case .marginBuy:
            text = YXLanguageUtility.kLang(key: "trading_finance_buy_tip")
//            if params.powerOrderType == .market || params.powerOrderType == .bidding {
//                text = YXLanguageUtility.kLang(key: "trading_finance_buy_tip") + YXLanguageUtility.kLang(key: "trading_tip_estimate")
//            }
        case .optionBuy:
            text = YXLanguageUtility.kLang(key: "max_can_bought")
        case .sell:
            text = YXLanguageUtility.kLang(key: "hold_can_sold")
           
        case .cashBuyPower:
            text = YXLanguageUtility.kLang(key: "trading_cash_buy_power")
        case .marginBuyPower:
            text = YXLanguageUtility.kLang(key: "trading_margin_buy_power")
        }
        return NSAttributedString(string: text, attributes: [.foregroundColor: QMUITheme().textColorLevel3(), .font: UIFont.systemFont(ofSize: 12)])
    }
}


//fileprivate class YXTradePowerInfoItemView: UIView {
//
//    let titleLabel : UILabel = {
//        let lab = UILabel()
//        lab.font = .systemFont(ofSize: 12)
//        lab.textColor = QMUITheme().textColorLevel3()
//        lab.textAlignment = .left
//        lab.numberOfLines = 2
//        return lab
//    }()
//
//    let valueLabel : UILabel = {
//        let lab = UILabel()
//        lab.font = .systemFont(ofSize: 12)
//        lab.textColor = QMUITheme().textColorLevel1()
//        lab.textAlignment = .left
//        lab.adjustsFontSizeToFitWidth = true
//        lab.minimumScaleFactor = 0.3
//        return lab
//    }()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupUI()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func setupUI()  {
//        addSubview(titleLabel)
//        addSubview(valueLabel)
//        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
//        titleLabel.snp.makeConstraints { make in
//            make.left.top.equalToSuperview()
//            make.width.greaterThanOrEqualTo(80).priority(.high)
//            make.right.lessThanOrEqualTo(valueLabel.snp.left).offset(-10)
//        }
//
//        valueLabel.snp.makeConstraints { make in
//            make.right.top.equalToSuperview()
//        }
//    }
//
//}
