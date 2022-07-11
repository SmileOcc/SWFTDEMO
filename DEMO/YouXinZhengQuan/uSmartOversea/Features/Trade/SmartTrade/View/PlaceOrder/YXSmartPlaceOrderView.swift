//
//  YXSmartPlaceOrderView.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2021/12/28.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation

class YXSmartPlaceOrderView: UIView, YXTradeHeaderSubViewProtocol, YXTradeHeaderViewProtocol {
    
    var heightDidChange: (() -> Void)?
    var dataDidChange: (() -> Void)?
    var powerInfoDidChange: (() -> Void)?
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = NSAttributedString(string: YXLanguageUtility.kLang(key: "trade_condition_place_order"),
                                                  attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium),
                                                               .foregroundColor: QMUITheme().textColorLevel1()])
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().blockColor()
        
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    
    
    lazy var directionView: YXSmartDirectionView = {
        var typeArr: [TradeDirection] = [.buy, .sell]
        if tradeModel.tradeStatus == .change {
            typeArr = [tradeModel.direction]
        }
        let view = YXSmartDirectionView(typeArr: typeArr, selectType: tradeModel.direction) { [weak self] type in
            self?.directionDidChange(type)
        }
        view.isHidden = true
        return view
    }()
    
    func directionDidChange(_ direction: TradeDirection) {
        tradeModel.direction = direction
        updatePaymentTypeView()
        paymentTypeView.resetLevelIfNeed()
        updateMoneyView()
        dataDidChange?()
    }
    
    @objc lazy var smartTradePriceView: YXSmartTradePriceView = {
        let view = YXSmartTradePriceView(params: tradeModel.priceParams) { [weak self] gearType, price in
            self?.priceDidChange(price, entrustGear: gearType)
        }
        return view
    }()
    
    @objc lazy var errorTipsView: YXTradeErrorTipsView = {
        let view = YXTradeErrorTipsView(params: tradeModel.inputTipParams)
        view.tradePriceView = smartTradePriceView
        view.isHidden = true
        return view
    }()
    
    func priceDidChange(_ price: String, entrustGear: GearType) {
        tradeModel.entrustPrice = price
        tradeModel.condition.entrustGear = entrustGear
        if entrustGear == .market {
            tradeModel.condition.conditionOrderType = .market
        } else {
            if tradeModel.market == kYXMarketHK {
                tradeModel.condition.conditionOrderType = .limitEnhanced
            } else {
                tradeModel.condition.conditionOrderType = .limit
            }
        }
        
        errorTipsView.params = tradeModel.inputTipParams
        paymentTypeView.resetLevelIfNeed()
        updateMoneyView()
        requestCanBuy(needReset: false)
        dataDidChange?()
    }
    
    @objc lazy var smartTradeNumberView: YXSmartTradeNumberView = {
        let view = YXSmartTradeNumberView { [weak self] number in
            self?.tradeNumberDidChange(number)
        }
        
        view.showPaymentButton.qmui_tapBlock = { [weak self] sender in
            guard let strongSelf = self else { return }

            if let button = sender {
                button.isSelected = !button.isSelected
            }
            strongSelf.paymentTypeView.isHidden = !strongSelf.paymentTypeView.isHidden
            MMKV.default().set(strongSelf.paymentTypeView.isHidden, forKey: YXPlaceOrderView.paymentHiddenKey)
        }
        view.inputNumberView.updateInput(tradeModel.entrustQuantity)
        return view
    }()
    
    func tradeNumberDidChange(_ number: String) {
        tradeModel?.entrustQuantity = number
        paymentTypeView.resetLevelIfNeed()
        updateMoneyView()
        dataDidChange?()
    }
    
    lazy var paymentTypeView: YXTradePaymentTypeView = {
        var typeArr: [TradePaymentType] = [.cash]
        if YXUserManager.shared().canMargin {
            typeArr = [.margin]
        }
        if tradeModel.direction == .sell {
            typeArr = [.sell]
        }
        let view = YXTradePaymentTypeView(typeArr: typeArr, isSmart: true, axis: .horizontal) { [weak self] paymentType in
            self?.powerInfoView.paymentType = paymentType
        } paymentBlock: {  [weak self] paymentLevel in
            self?.updateTradeNumber(paymentLevel)
        }
        
        let line = UIView.line()
        view.addSubview(line)

        line.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        return view
    }()
    
    func updatePaymentTypeView() {
        if tradeModel.direction == .sell {
            paymentTypeView.updateType([.sell])
        } else {
            if tradeModel.symbol.count > 0 {
                if tradeModel.canMargin {
                    paymentTypeView.updateType([.margin])
                } else {
                    paymentTypeView.updateType([.cash])
                }
            } else {
                if YXUserManager.shared().canMargin {
                    paymentTypeView.updateType([.margin])
                } else {
                    paymentTypeView.updateType([.cash])
                }
            }
        }
    }
    
    @objc func updatePaymentHidden() {
        smartTradeNumberView.showPaymentButton.isSelected = !MMKV.default().bool(forKey: YXPlaceOrderView.paymentHiddenKey, defaultValue: false)
        paymentTypeView.isHidden = MMKV.default().bool(forKey: YXPlaceOrderView.paymentHiddenKey, defaultValue: false)
    }
    
    func updateTradeNumber(_ paymentLevel: PaymentLevel) {
        let amount = Int(floor(Float(powerInfoView.powerAmount) * paymentLevel.denominator))
        
        if let unit = tradeModel.trdUnit {
            if amount < unit  {
                paymentTypeView.resetLevelIfNeed()
                if tradeModel.market == kYXMarketUsOption {
                    YXProgressHUD.showError(YXLanguageUtility.kLang(key: "option_trading_less_one_hand"), in: UIViewController.current().view, hideAfterDelay: 1.5)
                } else {
                    YXProgressHUD.showError(YXLanguageUtility.kLang(key: "trading_less_one_hand"), in: UIViewController.current().view, hideAfterDelay: 1.5)
                }
            }else {
                paymentTypeView.setCannotResetLevel()
                smartTradeNumberView.inputNumberView.updateInput(NSNumber(value: amount))
            }
        }else {
            paymentTypeView.resetLevelIfNeed()
            if tradeModel.market == kYXMarketUsOption {
                YXProgressHUD.showError(YXLanguageUtility.kLang(key: "option_trading_less_one_hand"), in: UIViewController.current().view, hideAfterDelay: 1.5)
            } else {
                YXProgressHUD.showError(YXLanguageUtility.kLang(key: "trading_less_one_hand"), in: UIViewController.current().view, hideAfterDelay: 1.5)
            }
        }
    }
    
    /// 购买力view
    lazy var powerInfoView:YXTradePowerInfoView = {
        if tradeModel.powerInfo == nil {
            tradeModel.powerInfo = tradeModel.defaultPowerInfo()
        }
        let view = YXTradePowerInfoView(powerInfo: tradeModel.powerInfo!)
        return view
    }()
    
    func updatePowerInfo() {
        guard let powerInfo = tradeModel.powerInfo else {
            return
        }
        
        powerInfoView.powerInfo = powerInfo
        updateMoneyView()
        powerInfoDidChange?()
    }
    
    lazy var moneyView: YXTradeTotalAmountView = {
        let view = YXTradeTotalAmountView()
        view.isSmart = true
        view.amountTitleLab.font = .systemFont(ofSize: 16, weight: .medium)
        view.amountTitleLab.textColor = QMUITheme().textColorLevel1()
        return view
    }()
    
    func updateMoneyView() {
        if tradeModel.condition.smartOrderType == .tralingStop {
            moneyView.isHidden = true
        } else {
            moneyView.isHidden = false
            moneyView.currency = tradeModel.currency
            moneyView.useMargin = tradeModel.useMargin
            moneyView.totalAmount = tradeModel.totalAmount
        }
    }
    
    var needRequestCanBuy = false
    func requestCanBuyIfNeed() {
        if needRequestCanBuy {
            if tradeModel.latestPrice != nil, tradeModel.trdUnit != nil {
                requestCanBuy(needReset: false)
                needRequestCanBuy = false
            }
        }
    }
    
    @objc func requestCanBuy(needReset: Bool = true) {
        if (needReset) {
            tradeModel.powerInfo = tradeModel.defaultPowerInfo()
            powerInfoView.powerInfo = tradeModel.powerInfo
            updateMoneyView()
        }
        
        if tradeModel.trdUnit == nil {
            needRequestCanBuy = true
            updateMoneyView()
            return
        }
        
        YXTradePowerManager.shared.requestCanBuy(tradeModel) { [weak self] in
            self?.updatePowerInfo()
        }
    }
    
    var tradeModel: TradeModel! {
        didSet {
            setupUI()
        }
    }
    
    func setupUI() {
        if tradeModel.condition.smartOrderType == .stockHandicap {
            directionView.isHidden = false
        } else {
            directionView.isHidden = true
        }
        
        smartTradePriceView.inputPriceView.updateInput(tradeModel.entrustPrice)
        smartTradePriceView.selectGearTypeView.selectView.updateType(selected: .entrust)
        
        errorTipsView.params = tradeModel.inputTipParams
        
        if let trdUnit = tradeModel.trdUnit {
            smartTradeNumberView.inputNumberView.resetMinChange(String(trdUnit))
        } else {
            smartTradeNumberView.inputNumberView.resetMinChange()
        }
        smartTradeNumberView.inputNumberView.updateInput(tradeModel.entrustQuantity)
        
        updatePaymentTypeView()
        requestCanBuy()
    }
    
    var quote: YXV2Quote? {
        didSet {
            smartTradePriceView.isInlineWarrant = quote?.isInlineWarrant
            smartTradePriceView.spreadTable = YXSpreadTableManager.shared.spreadTable(with: tradeModel.market, stc: quote?.stc?.value, spreadTab: quote?.spreadTab, condition: true)
            smartTradePriceView.params = tradeModel.priceParams
            
            if let trdUnit = quote?.trdUnit?.value {
                smartTradeNumberView.inputNumberView.resetMinChange(String(trdUnit))
            } else {
                smartTradeNumberView.inputNumberView.resetMinChange()
            }
            
            if let quote = quote, quote.isDerivatives {
                smartTradePriceView.selectGearTypeView.selectView.updateType(selected: .entrust)
                smartTradePriceView.selectGearTypeView.isHidden = true
            } else {
                smartTradePriceView.selectGearTypeView.isHidden = false
            }
        }
    }
    
    convenience init(tradeModel: TradeModel) {
        self.init()
        
        self.tradeModel = tradeModel
        
        if tradeModel.tradeStatus == .change {
            needRequestCanBuy = true
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(32)
            make.right.equalToSuperview().offset(-16)
        }
        
        setupStackView()
        configStackView()
        updateHeight()
        
        setupUI()
    }

    func setupStackView() {
        addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(topMargin)
            make.bottom.equalToSuperview().offset(-bottomMargin)
        }
        
        stackView.addArrangedSubview(directionView)
        stackView.addArrangedSubview(smartTradePriceView)
        stackView.addArrangedSubview(errorTipsView)
        stackView.addArrangedSubview(smartTradeNumberView)
        stackView.addArrangedSubview(paymentTypeView)
        stackView.addArrangedSubview(moneyView)
        stackView.addArrangedSubview(powerInfoView)
        
        insertSubview(shadowView, at: 0)
        shadowView.snp.makeConstraints { make in
            make.top.equalTo(stackView).offset(-margin)
            make.left.right.equalTo(stackView)
            make.bottom.equalTo(stackView).offset(bottomMargin)
        }
    }
    
    private let margin: CGFloat = 4
    
    var topMargin: CGFloat {
        return 48 + margin
    }
    
    var bottomMargin: CGFloat {
        return 12
    }
}
