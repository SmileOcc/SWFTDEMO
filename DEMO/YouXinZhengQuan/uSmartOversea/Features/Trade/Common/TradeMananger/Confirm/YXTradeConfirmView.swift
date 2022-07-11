//
//  YXTradeConfirmView.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/3/26.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation
import TYAlertController

enum TradeConfirmType {
    case none
    case cancel(option: Bool, fractionalAmount: Bool?)
    case normal(option: Bool, margin: Bool, noPrice: Bool, preAfter: Bool, fractionalAmount: Bool?)
    case smart(margin: Bool, noPrice: Bool, preAfter: Bool, tralingStop: Bool, track: Bool)
    
    fileprivate enum RowType: Int {
        case name                   //股票名称
        case symbol                 //股票代码
        case orderType              //订单类型
        case orderDirection         //委托下单
        case entrustPrice           //委托价格
        case quantity               //委托数量
        case amount                 //订单金额
        
        case preAfter               //盘前盘后
        case line                   //线
        case tip                    //提示
        
        case stock                  //股票(名称代码)
        case smartType              //智能单类型
        case conditionPoint         //触发条件
        case trackAssets            //关联资产
        case triggerPrice           //跟踪价格
        case validDate              //失效时间
        
        case estimatedStopLossPrice //当前预计止损价
    }
}

extension TradeConfirmType {
    fileprivate var rowTypes: [RowType] {
        switch self {
        case .normal(let option, _, let noPrice, let preAfter, let fractionalAmount):
            var rowTypes: [RowType] = [.name, .symbol, .orderDirection, .orderType]
            if option { rowTypes = [.name, .orderDirection, .orderType] }
            if preAfter { rowTypes.append(.preAfter) }
            
            if fractionalAmount == true {
                rowTypes.append(.amount)
                if !noPrice { rowTypes.append(.entrustPrice) }
            } else {
                if !noPrice { rowTypes.append(.entrustPrice) }
                rowTypes.append(.quantity)
                if fractionalAmount == nil { rowTypes.append(.amount) }
            }

//            if margin { rowTypes.append(contentsOf: [.line, .tip]) }
            return rowTypes
        case .smart(let margin, let noPrice, let preAfter, let tralingStop, let track):
            var rowTypes: [RowType] = [.name, .symbol, .smartType]
            if track { rowTypes.append(contentsOf: [.trackAssets, .triggerPrice, .orderDirection]) }
            else { rowTypes.append(.conditionPoint) }
            if tralingStop { rowTypes.append(.estimatedStopLossPrice) }
            rowTypes.append(contentsOf: [.entrustPrice, .quantity])
            if !noPrice { rowTypes.append(.amount) }
            rowTypes.append(.validDate)
            if preAfter { rowTypes.append(.preAfter) }
            if margin { rowTypes.append(contentsOf: [.line, .tip]) }
            
            return rowTypes
        case .cancel(let option, let fractionalAmount):
            var rowTypes: [RowType] = [.name, .symbol, .entrustPrice, .quantity]
            if fractionalAmount == true { rowTypes = [.name, .symbol, .amount, .entrustPrice] }
            if option { rowTypes = [.name, .entrustPrice, .quantity] }
            return rowTypes
        default:
            return []
        }
    }
    
    fileprivate func attributedText(with tradeOrderType: TradeOrderType) -> NSAttributedString {
        var title = ""
        if case .cancel = self {
            title = YXLanguageUtility.kLang(key: "hold_order_recall")
        } else {
            switch tradeOrderType {
            case .smart:
                title = YXLanguageUtility.kLang(key: "confirm_smart_order")
            default:
                title = YXLanguageUtility.kLang(key: "trading_confirm_order")
            }
        }
        
        return NSAttributedString(string: title, attributes: [.foregroundColor: QMUITheme().textColorLevel1(), .font: UIFont.systemFont(ofSize: 16, weight: .medium)])
    }
    
    fileprivate func confirmAttributedText(with direction: TradeDirection) -> NSAttributedString {
        var title = ""
        switch self {
        case .normal:
            if direction == .buy {
                title = YXLanguageUtility.kLang(key: "confirm_buy")
            } else {
                title = YXLanguageUtility.kLang(key: "confirm_sell")
            }
        default:
            title = YXLanguageUtility.kLang(key: "condition_confirm")
        }
        return NSAttributedString(string: title, attributes: [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 16)])
    }
    
    fileprivate static func type(with tradeModel: TradeModel) -> TradeConfirmType {
        var fractionalAmount: Bool? = nil
        if tradeModel.tradeType == .fractional {
            fractionalAmount = tradeModel.fractionalTradeType == .amount
        }
        
        if tradeModel.tradeStatus == .cancel {
            return .cancel(option: tradeModel.market == kYXMarketUsOption, fractionalAmount: fractionalAmount)
        }
        
        switch tradeModel.tradeType {
        case .normal,
             .fractional:
            let tradeOrderType = tradeModel.tradeOrderType
            
            if tradeOrderType == .smart {
                return .smart(margin: YXUserManager.shared().brokerAccountType == .financing && tradeModel.direction == .buy,
                              noPrice: tradeModel.condition.entrustGear != .entrust,
                              preAfter: tradeModel.market == kYXMarketUS && tradeModel.condition.smartOrderType != .tralingStop,
                              tralingStop: tradeModel.condition.smartOrderType == .tralingStop,
                              track: tradeModel.condition.smartOrderType == .stockHandicap)
            }
            


            return .normal(option: tradeModel.market == kYXMarketUsOption,
                           margin: tradeModel.useMargin && tradeModel.direction == .buy,
                           noPrice: tradeOrderType == .market || tradeOrderType == .bidding,
                           preAfter: tradeModel.market == kYXMarketUS,
                           fractionalAmount: fractionalAmount)
        default:
            break
        }
        
        return .none
    }
}

extension TradeConfirmType.RowType {
    static var moneyFormatter: NumberFormatter {
        let moneyFormatter = NumberFormatter()
        moneyFormatter.positiveFormat = "###,##0.00";
        moneyFormatter.locale = Locale(identifier: "zh")
        return moneyFormatter
    }
    
    func height(with tradeModel: TradeModel) -> CGFloat {
        switch self {
        case .line:
            return 12
        case .tip:
            let textHeight = attributedText(with: tradeModel).boundingRect(with: CGSize(width: Int(YXConstant.screenWidth - 90 - 28), height: .max), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).height
            return textHeight + 12
        default:
            let textWidth: CGFloat = min(132, attributedText(with: tradeModel).boundingRect(with: CGSize(width: .max, height: 32), options: .usesLineFragmentOrigin, context: nil).width)
            let textHeight = attributedText(with: tradeModel).boundingRect(with: CGSize(width: textWidth, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil).height
            let descHeight = attributedDesc(with: tradeModel).boundingRect(with: CGSize(width: Int(YXConstant.screenWidth - 90 - textWidth - 28 - 20), height: .max), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).height
            return max(32, max(textHeight, descHeight) + 12)
        }
    }
    
    func attributedDesc(with tradeModel: TradeModel) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right
        var attributes: [NSAttributedString.Key: Any] = [.foregroundColor: QMUITheme().textColorLevel1(), .font: UIFont.systemFont(ofSize: 14), .paragraphStyle: paragraphStyle]
        
        var desc = "--"
        switch self {
        case .name:
            desc = tradeModel.name
        case .symbol:
            if tradeModel.market == kYXMarketUsOption {
                desc = tradeModel.symbol.uppercased()
            } else {
                desc = tradeModel.symbol.uppercased() + "." + tradeModel.market.uppercased()
            }
        case .orderType:
            desc = tradeModel.tradeOrderType.text
            return NSAttributedString(string: tradeModel.tradeOrderType.text, attributes: attributes)
        case .orderDirection:
            desc = tradeModel.direction.text
            attributes[.foregroundColor] = tradeModel.direction.color
        case .entrustPrice:
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.groupingSeparator = ""
            numberFormatter.maximumFractionDigits = 4;
            numberFormatter.locale = Locale(identifier: "zh")
            var entrustPrice = "--"
            if let number = NSNumber(string: tradeModel.entrustPrice), let price = numberFormatter.string(from: number) {
                entrustPrice = price
            }

            attributes[.font] = UIFont.systemFont(ofSize: 14, weight: .medium)
            if tradeModel.tradeOrderType == .smart {
                if tradeModel.condition.entrustGear == .entrust {
                    desc = entrustPrice + YXLanguageUtility.kLang(key: "common_en_space") + tradeModel.currency
                } else {
                    desc = tradeModel.condition.entrustGear.text
                }
            } else {
                desc = entrustPrice + YXLanguageUtility.kLang(key: "common_en_space") + tradeModel.currency
            }
        case .quantity:
            attributes[.font] = UIFont.systemFont(ofSize: 14, weight: .medium)
//            var unit = YXLanguageUtility.kLang(key: "stock_unit")
//            if tradeModel.market == kYXMarketUsOption {
//                unit = ""
//            }
            if tradeModel.tradeType == .fractional {
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal;
                numberFormatter.groupingSize = 3;
                numberFormatter.groupingSeparator = ",";
                numberFormatter.maximumFractionDigits = 4;
                numberFormatter.locale = Locale(identifier: "zh")
                
                if tradeModel.fractionalQuantity.count > 0,
                   let quantity = numberFormatter.string(from: NSNumber(value: tradeModel.fractionalQuantity.doubleValue)) {
                    desc = quantity
                }
                desc = tradeModel.fractionalQuantity //+ unit
            } else {
                desc = tradeModel.entrustQuantity //+ unit
            }
        case .amount:
            attributes[.font] = UIFont.systemFont(ofSize: 14, weight: .medium)
            if tradeModel.tradeType == .fractional {
                let numberFormatter = NumberFormatter()
                numberFormatter.positiveFormat = "###,##0.00";
                numberFormatter.locale = Locale(identifier: "zh")
                if tradeModel.fractionalAmount.count > 0,
                   let amount = numberFormatter.string(from: NSNumber(value: tradeModel.fractionalAmount.doubleValue)) {
                    desc = amount + YXLanguageUtility.kLang(key: "common_en_space") + tradeModel.currency
                }
            } else {
                desc = (tradeModel.totalAmount ?? "--") + YXLanguageUtility.kLang(key: "common_en_space") + tradeModel.currency
            }
            
            if tradeModel.useMargin, tradeModel.direction == .buy, let powerInfo = tradeModel.powerInfo {
                paragraphStyle.lineSpacing = 5
                attributes[.paragraphStyle] = paragraphStyle
                let attributedDesc = NSMutableAttributedString(string: desc, attributes: attributes)
                var estimateAmount = "--"
                
                if tradeModel.tradeType == .fractional, tradeModel.fractionalTradeType == .amount {
                    estimateAmount = Self.moneyFormatter.string(from: NSNumber(value: tradeModel.fractionalAmount.doubleValue - powerInfo.cashPurchasingPower.doubleValue)) ?? "--"
                } else {
                    var entrustQuantity = tradeModel.entrustQuantity
                    if tradeModel.tradeType == .fractional {
                        entrustQuantity = tradeModel.fractionalQuantity
                    }
                    if let entrustPirce = Double(tradeModel.entrustPrice) {
                        let marginAmount = entrustQuantity.doubleValue - powerInfo.maxCashBuyMulti
                        estimateAmount = Self.moneyFormatter.string(from: NSNumber(value: entrustPirce * marginAmount)) ?? "--"
                    }
                }
                
                let marginAmount = estimateAmount + YXLanguageUtility.kLang(key: "common_en_space") + tradeModel.currency
                let marginAmountDesc = "\n" + YXLanguageUtility.kLang(key: "margin_estimated") + ": " + marginAmount
                attributes[.foregroundColor] = QMUITheme().textColorLevel3()
                attributes[.font] = UIFont.systemFont(ofSize:12)

                attributedDesc.append(NSAttributedString(string: marginAmountDesc, attributes: attributes))
                return attributedDesc
            }
        case .preAfter:
            attributes[.font] = UIFont.systemFont(ofSize: 14, weight: .medium)

            desc = YXLanguageUtility.kLang(key: "hold_not_allow")
            if tradeModel.tradePeriod == .preAfter {
                desc = YXLanguageUtility.kLang(key: "hold_allow")
            }
        case .stock:
            desc = tradeModel.name + "(\(tradeModel.symbol))"
        case .smartType:
            attributes[.foregroundColor] = QMUITheme().themeTextColor()
            desc = tradeModel.condition.smartOrderType.text
        case .estimatedStopLossPrice:
            attributes[.font] = UIFont.systemFont(ofSize: 14, weight: .medium)
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.groupingSeparator = ""
            numberFormatter.maximumFractionDigits = 4;
            numberFormatter.locale = Locale(identifier: "zh")
            if let number = NSNumber(string: tradeModel.condition.conditionPrice ?? ""),
               let price = numberFormatter.string(from: number) {
                desc = price + YXLanguageUtility.kLang(key: "common_en_space") + tradeModel.currency
            }
        case .conditionPoint:
            attributes[.font] = UIFont.systemFont(ofSize: 14, weight: .medium)
            
            var conditionPrice = "--"
            if let number = NSNumber(string: tradeModel.condition.conditionPrice ?? "") {
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                numberFormatter.groupingSeparator = ""
                numberFormatter.maximumFractionDigits = 4;
                numberFormatter.locale = Locale(identifier: "zh")
                conditionPrice = numberFormatter.string(from: number) ?? "--"
            }

            switch tradeModel.condition.smartOrderType {
            case .breakBuy:
                if let amountIncrease = tradeModel.condition.amountIncrease?.doubleValue {
                    desc = String(format: YXLanguageUtility.kLang(key: "dialog_price_up_to"), amountIncrease * 100.0, conditionPrice, tradeModel.currency)
                } else {
                    desc = String(format: YXLanguageUtility.kLang(key: "dialog_price_break"), conditionPrice, tradeModel.currency)
                }
            case .breakSell:
                if let amountIncrease = tradeModel.condition.amountIncrease?.doubleValue {
                    desc = String(format: YXLanguageUtility.kLang(key: "dialog_price_down_to"), amountIncrease * 100.0, tradeModel.condition.conditionPrice ?? "--", tradeModel.currency)
                } else {
                    desc = String(format: YXLanguageUtility.kLang(key: "dialog_price_down"), conditionPrice, tradeModel.currency)
                }
            case .lowPriceBuy:
                if let amountIncrease = tradeModel.condition.amountIncrease?.doubleValue {
                    desc = String(format: YXLanguageUtility.kLang(key: "dialog_price_down_to"), amountIncrease * 100.0, tradeModel.condition.conditionPrice ?? "--", tradeModel.currency)
                } else {
                    desc = String(format: YXLanguageUtility.kLang(key: "dialog_price_down"), conditionPrice, tradeModel.currency)
                }
            case .highPriceSell:
                if let amountIncrease = tradeModel.condition.amountIncrease?.doubleValue {
                    desc = String(format: YXLanguageUtility.kLang(key: "dialog_price_up_to"), amountIncrease * 100.0, tradeModel.condition.conditionPrice ?? "--", tradeModel.currency)
                } else {
                    desc = String(format: YXLanguageUtility.kLang(key: "dialog_price_up"), conditionPrice, tradeModel.currency)
                }
            case .stopProfitSell:
                if let amountIncrease = tradeModel.condition.amountIncrease?.doubleValue {
                    desc = String(format: YXLanguageUtility.kLang(key: "costprice_rose_to"), amountIncrease * 100.0, tradeModel.condition.conditionPrice ?? "--", tradeModel.currency)
                }
                break
            case .stopLossSell:
                if let amountIncrease = tradeModel.condition.amountIncrease?.doubleValue {
                    desc = String(format: YXLanguageUtility.kLang(key: "costprice_fell_to"), amountIncrease * 100.0, tradeModel.condition.conditionPrice ?? "--", tradeModel.currency)
                }
                break
            case .tralingStop:
                if let amountIncrease = tradeModel.condition.amountIncrease?.doubleValue {
                    desc = YXLanguageUtility.kLang(key: "drop_more_than") + String(format: "%.2f", amountIncrease * 100) + "%"
                } else if let dropPrice = tradeModel.condition.dropPrice?.doubleValue {
                    desc = YXLanguageUtility.kLang(key: "drop_more_than") + String(format: "%.3f", dropPrice) + YXLanguageUtility.kLang(key: "common_en_space") + tradeModel.currency
                }
            default:
                break
            }
        case .validDate:
            attributes[.font] = UIFont.systemFont(ofSize: 14, weight: .medium)
            let attributedDesc = NSMutableAttributedString(string: tradeModel.condition.strategyEnddateTitle, attributes: attributes)
            attributes[.foregroundColor] = QMUITheme().textColorLevel3()
            attributes[.font] = UIFont.systemFont(ofSize: 12)
            attributedDesc.append(NSAttributedString(string: "\n" + tradeModel.condition.strategyEnddateYearMsg, attributes: attributes))
            return attributedDesc
        case .trackAssets:
            desc = (tradeModel.condition.releationStockName ?? "--") + "(" + (tradeModel.condition.releationStockCode?.uppercased() ?? "--") + "." + (tradeModel.condition.releationStockMarket?.uppercased() ?? "--") + ")"
        case .triggerPrice:
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.groupingSeparator = ""
            numberFormatter.maximumFractionDigits = 4;
            numberFormatter.locale = Locale(identifier: "zh")
            if let number = NSNumber(string: tradeModel.condition.conditionPrice ?? ""),
               let price = numberFormatter.string(from: number) {
                desc = price
                if let currency = tradeModel.condition.releationStockCurrency, currency.count > 0 {
                    desc = price + YXLanguageUtility.kLang(key: "common_en_space") + currency
                }
            }
        default:
            break
        }
        return NSAttributedString(string: desc, attributes: attributes)
    }
    
    func attributedText(with tradeModel: TradeModel) -> NSAttributedString {
        var text = "--"
        var attributes: [NSAttributedString.Key : Any] = [.foregroundColor: QMUITheme().textColorLevel3(), .font: UIFont.systemFont(ofSize: 14)]
        
        switch self {
        case .name,
             .stock:
            text = YXLanguageUtility.kLang(key: "stock_name")
        case .symbol:
            text = YXLanguageUtility.kLang(key: "trade_symbol")
        case .orderType:
            text = YXLanguageUtility.kLang(key: "trading_order_type")
        case .orderDirection:
            text = YXLanguageUtility.kLang(key: "trade_direction")
        case .entrustPrice:
            text = YXLanguageUtility.kLang(key: "delegation_price")
        case .quantity:
            text = YXLanguageUtility.kLang(key: "delegation_number")
        case .amount:
            text = YXLanguageUtility.kLang(key: "trade_amount")
            if tradeModel.tradeOrderType == .market
                || tradeModel.tradeOrderType == .bidding {
                text = YXLanguageUtility.kLang(key: "trade_amount_estimated")
            }
        case .preAfter:
            text = YXLanguageUtility.kLang(key: "hold_fill_rth")
        case .tip:
            attributes[.font] = UIFont.systemFont(ofSize: 12)
            if tradeModel.tradeOrderType == .smart {
                text = YXLanguageUtility.kLang(key: "trade_margin_account_tip")
            } else if tradeModel.tradeOrderType == .market {
                text = YXLanguageUtility.kLang(key: "trade_margin_tip")
            } else {
                //    1.融资股数：委托数量-现金可买数 2.融资金额:融资股数*委托价格 保留两位小数,BigDecimal.ROUND_CEILING
                if let powerInfo = tradeModel.powerInfo {
                    var estimaAmount = "--"
                    
                    if tradeModel.tradeType == .fractional, tradeModel.fractionalTradeType == .amount {
                        estimaAmount = Self.moneyFormatter.string(from: NSNumber(value: tradeModel.fractionalAmount.doubleValue - powerInfo.cashPurchasingPower.doubleValue)) ?? "--"
                    } else {
                        var entrustQuantity = tradeModel.entrustQuantity
                        if tradeModel.tradeType == .fractional {
                            entrustQuantity = tradeModel.fractionalQuantity
                        }
                        if let entrustPirce = Double(tradeModel.entrustPrice) {
                            let marginAmount = entrustQuantity.doubleValue - powerInfo.maxCashBuyMulti
                            estimaAmount = Self.moneyFormatter.string(from: NSNumber(value: entrustPirce * marginAmount)) ?? "--"
                        }
                    }
                    
                    let str = estimaAmount + " " + tradeModel.currency
                    text = String(format: YXLanguageUtility.kLang(key: "trade_margin_tip_estimated"), str)
                    
                    let attr = NSMutableAttributedString(string: text, attributes: attributes)
                    attributes[.foregroundColor] = UIColor.qmui_color(withHexString: "#F9A800")
                    attr.addAttributes(attributes, range: (text as NSString).range(of: str))
                    
                    return attr
                }
            }
        case .estimatedStopLossPrice:
            text = YXLanguageUtility.kLang(key: "estimated_stop_loss_price")
        case .smartType:
            text = YXLanguageUtility.kLang(key: "trade_type")
        case .conditionPoint:
            text = YXLanguageUtility.kLang(key: "trade_conditional_point_n")
        case .validDate:
            text = YXLanguageUtility.kLang(key: "validity_time")
        case .trackAssets:
            text = YXLanguageUtility.kLang(key: "track_stock")
        case .triggerPrice:
            text = YXLanguageUtility.kLang(key: "smart_trigger_price")
        default:
            break
        }
        return NSAttributedString(string: text, attributes: attributes)
    }
}

@objcMembers class YXTradeConfirmView: UIView {
    
    var tradeModel: TradeModel!
    var type: TradeConfirmType!
    private var confirmBlock: (() -> Void)!
    
    var cancelBlock: (() -> Void)?
    
    @objc convenience init(tradeModel: TradeModel, confirmBlock: @escaping (() -> Void)) {
        self.init()
        
        self.tradeModel = tradeModel
        self.confirmBlock = confirmBlock
        self.type = TradeConfirmType.type(with: tradeModel)
        
        backgroundColor = QMUITheme().popupLayerColor()
        clipsToBounds = true
        layer.cornerRadius = 10
        
        setupConfirmView()
        setupStackView()
        
    }
    
    private func setupStackView() {
        var contentHeight: CGFloat = 0
        type.rowTypes.forEach { (rowType) in
            contentHeight += rowType.height(with: tradeModel)
        }
        
        frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth - 90, height: contentHeight + 122)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        addSubview(stackView)
        
        stackView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(58)
            make.left.right.equalToSuperview()
            make.height.equalTo(contentHeight)
        }
        
        type.rowTypes.forEach { (rowType) in
            if rowType != .line {
                let rowTypeView = RowTypeView(rowType: rowType)
                rowTypeView.leftLabel.attributedText = rowType.attributedText(with: tradeModel)
                rowTypeView.rightLabel.attributedText = rowType.attributedDesc(with: tradeModel)
                //                if rowType == .name {
                //                    rowTypeView.rightLabel.numberOfLines = 1
                //                } else {
                //                    rowTypeView.rightLabel.numberOfLines = 0
                //                }
                stackView.addArrangedSubview(rowTypeView)
                rowTypeView.snp.makeConstraints{ (make) in
                    make.height.equalTo(rowType.height(with: tradeModel))
                }
            } else {
                let subView = UIView()
                let line = UIView.line()
                line.backgroundColor = QMUITheme().popSeparatorLineColor()
                subView.addSubview(line)
                line.snp.makeConstraints { (make) in
                    make.left.equalToSuperview().offset(14)
                    make.right.equalToSuperview().offset(-14)
                    make.top.equalToSuperview()
                    make.height.equalTo(1.0/UIScreen.screenScale())
                }
                
                stackView.addArrangedSubview(subView)
                subView.snp.makeConstraints { (make) in
                    make.height.equalTo(rowType.height(with: tradeModel))
                }
            }
        }
    }
    
    private func setupConfirmView() {
        let titleLabel = UILabel()
        titleLabel.attributedText = type.attributedText(with: tradeModel.tradeOrderType)
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(22)
        }
        
        addSubview(confirmBtn)
        addSubview(cancelBtn)
        
        confirmBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(36)
        }
        
        cancelBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(confirmBtn.snp.left).offset(-20)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(36)
            make.width.equalTo(confirmBtn)
        }
    }
    
    private lazy var confirmBtn: UIButton = {
        let btn = QMUIButton()
        btn.layer.cornerRadius = 4
        btn.clipsToBounds = true
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.backgroundColor = QMUITheme().mainThemeColor()
        btn.setTitle(YXLanguageUtility.kLang(key: "common_confirm"), for: .normal)
        btn.addTarget(self, action: #selector(confirmClicked), for: .touchUpInside)
        return btn
    }()
    
    private lazy var cancelBtn: UIButton = {
        let btn = QMUIButton()
        btn.layer.cornerRadius = 4
        btn.clipsToBounds = true
        btn.layer.borderWidth = 1
        btn.layer.borderColor = QMUITheme().alertButtonLayerColor().cgColor
        btn.setTitleColor(UIColor.themeColor(withNormal: QMUITheme().textColorLevel1(), andDarkColor: QMUITheme().textColorLevel3()), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.setTitle(YXLanguageUtility.kLang(key: "common_cancel"), for: .normal)
        btn.addTarget(self, action: #selector(cancelClicked), for: .touchUpInside)
        return btn
    }()
    
    @objc private func confirmClicked() {
        
        if let alertController = self.viewController() as? TYAlertController {
            alertController.dismissComplete = { [weak self] in
                self?.confirmBlock()
            }
        }
        
        hide()
    }
    
    @objc private func cancelClicked() {
        if let alertController = self.viewController() as? TYAlertController {
            alertController.dismissComplete = { [weak self] in
                self?.cancelBlock?()
            }
        }
        
        hide()
    }
}

fileprivate class RowTypeView: UIView {
    lazy var leftLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    lazy var rightLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    convenience init(rowType: TradeConfirmType.RowType) {
        self.init()
        
        if rowType != .tip {
            addSubview(leftLabel)
            addSubview(rightLabel)
            
            leftLabel.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(14)
                make.top.equalToSuperview()
                make.width.lessThanOrEqualTo(132)
            }
            
            rightLabel.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-14)
                make.top.equalToSuperview()
                make.left.greaterThanOrEqualTo(leftLabel.snp.right).offset(20)
            }
            
        } else {
            leftLabel.numberOfLines = 0
            addSubview(leftLabel)
            leftLabel.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(14)
                make.right.equalToSuperview().offset(-14)
                make.top.equalToSuperview()
            }
        }
    }
}

