//
//  YXPlaceOrderView.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2022/1/14.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

@objcMembers class YXPlaceOrderView: UIView, YXTradeHeaderViewProtocol, YXTradeHeaderSubViewProtocol {
    
    var heightDidChange: (() -> Void)?

    var updateAskBid: (()->(Void))?
    var needRequestCanBuy = false
    var needSetSellEntrustAmount = false
    var updateChangeErrorTip = true
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    
//    lazy var askBidView: YXTradeAskBidView = {
//        let view = YXTradeAskBidView()
//
//        view.clickCallBack = { [weak self] value in
//            if value.count == 0 {
//                return
//            }
//            self?.tradeModel.entrustPrice = value
//            self?.tradePriceView.inputPriceView.updateInput(value)
//        }
//
//        view.usPosButton.clickItemBlock = { [weak self] value in
//            self?.loadPosData()
//        }
//
//        return view
//    }()
    
    @objc lazy var fractionalTradeTypeView: YXFractionalTradeTypeView = {
        let view = YXFractionalTradeTypeView { [weak self] type in
            guard let strongSelf = self else { return }

            if strongSelf.tradeModel.tradeType == .fractional,
               strongSelf.tradeModel.fractionalTradeType != type {
                strongSelf.tradeModel.fractionalTradeType = type

                strongSelf.updateFractionalTrade()
            }
        }
        view.isHidden = true
        return view
    }()
    
    func updateFractionalTradeType() {
        if tradeModel.tradeType == .fractional {
            if tradeModel.direction == .sell {
                fractionalTradeTypeView.updateType([.shares])
                fractionalTradeTypeView.isHidden = true
            } else if tradeModel.tradeStatus == .change {
                fractionalTradeTypeView.updateType([tradeModel.fractionalTradeType])
                fractionalTradeTypeView.isHidden = false
            } else {
                fractionalTradeTypeView.updateType(selected: tradeModel.fractionalTradeType)
                fractionalTradeTypeView.isHidden = false
            }
        }
    }

    func updateFractionalTrade() {
        if tradeModel.fractionalTradeType == .amount {
            fractionalTradeNumberView.isHidden = true
            moneyView.isHidden = true
            
            fractionalTradeAmountView.isHidden = false
            fractionalQuantityView.isHidden = false

            updateFractionalQuantity()
            
        } else {
            
            fractionalTradeAmountView.isHidden = true
            fractionalQuantityView.isHidden = true
            
            moneyView.isHidden = false
            fractionalTradeNumberView.isHidden = false
            
            fractionalTradeNumberView.refreshMinChange(with: tradeModel.entrustPrice)
        }
    }
    
    @objc lazy var fractionalTradeAmountView: YXTradeAmountView = {
        let view = YXTradeAmountView { [weak self] amount in
            self?.amountDidChange(amount)
        }
        view.isHidden = true
        return view
    }()
    
    func amountDidChange(_ amount: String) {
        tradeModel.fractionalAmount = amount
        updateFractionalQuantity()
        dataDidChange?()
    }
    
    @objc lazy var tradePriceView: YXTradePriceView = {
        let view = YXTradePriceView(params: tradeModel.priceParams) { [weak self] price in
            self?.priceDidChange(price)
        }
        return view
    }()
    
    func priceDidChange(_ price: String) {
        tradeModel.entrustPrice = price
        errorTipsView.params = tradeModel.inputTipParams
        
        if tradeModel.tradeType == .fractional {
            fractionalTradeNumberView.refreshMinChange(with: price)
            updateFractionalQuantity()
        }

        updateAskBid?()
        paymentTypeView.resetLevelIfNeed()
        updateMoneyView()
        dataDidChange?()
        requestCanBuy(needReset: false)
    }
    
    @objc lazy var errorTipsView: YXTradeErrorTipsView = {
        let view = YXTradeErrorTipsView(params: tradeModel.inputTipParams)
        view.tradePriceView = tradePriceView
        view.isHidden = true
        
        view.tipsLabel.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview()
            make.width.equalTo(210)
            make.right.equalToSuperview().offset(-16)
        }
        return view
    }()
    
    @objc lazy var tradeNumberView: YXTradeNumberView = {
        let view = YXTradeNumberView { [weak self] (number) in
            guard let strongSelf = self else { return }

            if strongSelf.tradeModel.tradeType != .fractional {
                strongSelf.tradeNumberDidChange(number)
            }
        }
        view.showPaymentButton.qmui_tapBlock = { [weak self] sender in
            guard let strongSelf = self else { return }
            
            if let button = sender {
                button.isSelected = !button.isSelected
            }
            strongSelf.paymentTypeView.isHidden = !strongSelf.paymentTypeView.isHidden
            MMKV.default().set(strongSelf.paymentTypeView.isHidden, forKey: YXPlaceOrderView.paymentHiddenKey)
        }

        return view
    }()
    
    @objc func updatePaymentHidden() {
        tradeNumberView.showPaymentButton.isSelected = !MMKV.default().bool(forKey: YXPlaceOrderView.paymentHiddenKey, defaultValue: false)
        if tradeModel.tradeType == .normal {
            paymentTypeView.isHidden = MMKV.default().bool(forKey: YXPlaceOrderView.paymentHiddenKey, defaultValue: false)
        }
    }
    
    func tradeNumberDidChange(_ number: String) {
        tradeModel.fractionalQuantity = number
        tradeModel.entrustQuantity = number
        if tradeModel.tradeType != .fractional {
            paymentTypeView.resetLevelIfNeed()
        }
        updateMoneyView()
        dataDidChange?()
    }
    
    @objc lazy var fractionalTradeNumberView: YXFractionalTradeNumberView = {
        let view = YXFractionalTradeNumberView { [weak self] (number) in
            guard let strongSelf = self else { return }

            if strongSelf.tradeModel.tradeType == .fractional {
                strongSelf.tradeNumberDidChange(number)
            }
        }
        return view
    }()
    
    @objc lazy var numberTipsView: YXTradeTipsView = {
        let view = YXTradeTipsView()
        view.isHidden = true
        return view
    }()
    
    
    /// 金额view
    lazy var moneyView: YXTradeTotalAmountView = {
        let view = YXTradeTotalAmountView()
        return view
    }()
    
    func updateMoneyView() {
        moneyView.currency = tradeModel.currency
        let showEstimated = tradeModel.tradeOrderType == .market || tradeModel.tradeOrderType == .bidding
        moneyView.showEstimated = showEstimated
        if showEstimated {
            moneyView.useMargin = false
        } else {
            moneyView.useMargin = tradeModel.useMargin
        }
        moneyView.totalAmount = tradeModel.totalAmount
    }
    
    lazy var fractionalQuantityView: YXFractionalQuantityView = {
        let view = YXFractionalQuantityView()
        view.isHidden = true
        return view
    }()
    
    func updateFractionalQuantity() {
        fractionalQuantityView.quantity = tradeModel.franctionalEstimatedQuantity
    }
    
    
    @objc lazy var preAfterView: YXTradePreAfterView = {
        let view = YXTradePreAfterView { [weak self] type in
            self?.tradeModel.tradePeriod = type.tradePeriod
        }
        view.isHidden = true
        return view
    }()
    
    static let paymentHiddenKey = "paymentHiddenKey"
    lazy var paymentTypeView: YXTradePaymentTypeView = {
        var typeArr: [TradePaymentType] = [.cash]
        if tradeModel.market == kYXMarketUsOption {
            typeArr = [.optionBuy]
        } else if tradeModel.canMargin {
            typeArr = [.margin]
        }
        if tradeModel.direction == .sell {
            typeArr = [.sell]
        }
        let view = YXTradePaymentTypeView(typeArr: typeArr, axis: .horizontal) { [weak self] paymentType in
            self?.powerInfoView.paymentType = paymentType
        } paymentBlock: { [weak self] paymentLevel in
            self?.updateTradeNumber(paymentLevel)
        }
        
        view.selectView.typeButton.titleLabel?.font = .systemFont(ofSize: 14)
        view.selectView.typeButton.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
        view.selectView.typeButton.setTitleColor(QMUITheme().textColorLevel3(), for: .disabled)
        return view
    }()
    
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
                tradeNumberView.inputNumberView.updateInput(NSNumber(value: amount))
            }
        } else {
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
    
    func requestCanBuy(needReset: Bool = true) {
        if (needReset) {
            tradeModel.powerInfo = tradeModel.defaultPowerInfo()
            powerInfoView.powerInfo = tradeModel.powerInfo
            updateMoneyView()
        }
        
        if tradeModel.market == kYXMarketUsOption {
            if tradeModel.multiplier == nil {
                updateMoneyView()
                return
            }
        } else {
            if tradeModel.trdUnit == nil {
                needRequestCanBuy = true
                updateMoneyView()
                return
            }
        }
        
        YXTradePowerManager.shared.requestCanBuy(tradeModel) { [weak self] in
            self?.updatePowerInfo()
        }
    }
    
    func updatePowerInfo() {
        guard let powerInfo = tradeModel.powerInfo else {
            return
        }
        
        powerInfoView.powerInfo = powerInfo
        updateMoneyView()
        if tradeModel.tradeStatus == .limit, needSetSellEntrustAmount == true {
            if tradeModel.tradeType == .normal {
                if powerInfo.saleEnableAmount > 0 {
                    needSetSellEntrustAmount = false
                    tradeNumberView.inputNumberView.updateInput(NSNumber(value: powerInfo.saleEnableAmount))
                }
            } else if tradeModel.tradeType == .fractional {
                if powerInfo.saleEnableAmount > 0 {
                    needSetSellEntrustAmount = false
                    fractionalTradeNumberView.inputNumberView.updateInput(NSNumber(value: powerInfo.saleEnableAmount), needFix: false)
                }
            }
        }
    }

    func updatePaymentTypeView() {
        if tradeModel.direction == .sell {
            paymentTypeView.updateType([.sell])
        } else {
            if tradeModel.market == kYXMarketUsOption {
                paymentTypeView.updateType([.optionBuy], selected: .optionBuy)
            } else {
                if tradeModel.canMargin {
                    paymentTypeView.updateType([.margin])
                } else {
                    paymentTypeView.updateType([.cash])
                }
            }
        }
    }
    
//    var posBrokerRrequest: YXQuoteRequest?
        
//    func loadPosData() {
//        posBrokerRrequest?.cancel()
//
//        if tradeModel.market.count > 0 && tradeModel.symbol.count > 0 {
//            var level = YXUserManager.shared().getLevel(with: tradeModel.market)
//            if level != .delay || level != .bmp {
//                var extra: YXSocketExtraQuote = .none
//                if level == .usNational {
//                    extra = .usNation
//                    let type = YXStockDetailUtility.getUsAskBidSelect()
//                    if type == .nsdq {
//                        // 在全美行情下, 选择了纳斯达克, 就设置为none
//                        extra = .none
//                        level = .level1
//                    }
//                }
//                posBrokerRrequest = YXQuoteManager.sharedInstance.subPosAndBroker(secu: Secu(market: tradeModel.market, symbol: tradeModel.symbol, extra: extra), level: level, handler: { [weak self] posBroker, scheme in
//                    if posBroker.pos != nil {
//                        self?.askBidView.posBroker = posBroker
//                    }
//                })
//            }
//        }
//    }
    
    var tradeModel: TradeModel! {
        didSet {
            setupUI()
//            loadPosData()
        }
    }
    
    func setupUI(){
        if tradeModel.tradeStatus == .limit, tradeModel.direction == .sell {
            needSetSellEntrustAmount = true
        }
        //价格
        tradePriceView.inputPriceView.resetMinChange()
        tradePriceView.inputPriceView.updateInput(tradeModel.entrustPrice)
        tradePriceView.params = tradeModel.priceParams
        
        //数量
        tradeNumberView.inputNumberView.resetMinChange()
        tradeNumberView.inputNumberView.updateInput(tradeModel.entrustQuantity)
        
        updatePaymentTypeView()
        updateMoneyView()
        
        if tradeModel.tradeType == .fractional {
            fractionalTradeTypeView.isHidden = false
            
            tradeNumberView.isHidden = true
            paymentTypeView.isHidden = true
            
            fractionalTradeNumberView.inputNumberView.resetMinChange()
            fractionalTradeNumberView.inputNumberView.updateInput(tradeModel.fractionalQuantity)
            
            fractionalTradeAmountView.inputAmountView.updateInput(tradeModel.fractionalAmount, needFix: false)
            
            updateFractionalTradeType()
            updateFractionalTrade()
        } else {
            fractionalTradeTypeView.isHidden = true
            fractionalTradeNumberView.isHidden = true
            fractionalTradeAmountView.isHidden = true
            fractionalQuantityView.isHidden = true
            
            tradeNumberView.isHidden = false
            moneyView.isHidden = false
            
            if tradeNumberView.showPaymentButton.isSelected {
                paymentTypeView.isHidden = false
            } else {
                paymentTypeView.isHidden = true
            }
        }
        
        if tradeModel.tradeType == .normal,
           tradeModel.market == kYXMarketUS,
           !tradeModel.symbol.isEmpty {
            // 显示盘前盘后
            preAfterView.isHidden = false
            if tradeModel.tradeStatus == .change {
                if tradeModel.tradePeriod == .normal {
                    preAfterView.updateType([.notAllow])
                } else if tradeModel.tradePeriod == .preAfter {
                    preAfterView.updateType([.allow])
                }
            } else {
                preAfterView.updateType([.notAllow])
            }
        } else {
            preAfterView.updateType(selected: .notAllow)
            preAfterView.isHidden = true
        }
        
        // 买卖档
//        self.askBidView.usPosButton.isHidden = tradeModel.market != kYXMarketUS
    }
    
    var quote: YXV2Quote? {
        didSet {
            if needRequestCanBuy {
                if tradeModel.latestPrice != nil, tradeModel.trdUnit != nil {
                    requestCanBuy(needReset: false)
                    needRequestCanBuy = false
                }
            }

            if tradeModel.tradeStatus == .change, updateChangeErrorTip {
                errorTipsView.params = tradeModel.inputTipParams
                updateChangeErrorTip = false
            }
            
//            askBidView.quoteModel = quote
            
            tradePriceView.isInlineWarrant = quote?.isInlineWarrant
            tradePriceView.spreadTable = YXSpreadTableManager.shared.spreadTable(with: tradeModel.market, stc: quote?.stc?.value, spreadTab: quote?.spreadTab)
            tradePriceView.params = tradeModel.priceParams

            let trdUnit = quote?.trdUnit?.value ?? 1
            tradeModel.trdUnit = trdUnit
            tradeNumberView.inputNumberView.resetMinChange(String(trdUnit))
            
            if let multiplier = quote?.multiplier?.value {
                numberTipsView.show(String(format: YXLanguageUtility.kLang(key: "each_contract"), multiplier))
                if tradeModel.multiplier == nil {
                    tradeModel.multiplier = multiplier
                    requestCanBuy()
                }
            } else {
                numberTipsView.show("")
            }
        }
    }
    
    func singleUpdateSubViews() {
        guard let quote = quote else { return }
        
        let trdUnit = quote.trdUnit?.value ?? 1
        tradeModel.trdUnit = trdUnit
        if let latestPrice = quote.simpleQuote().latestPrice {
            tradePriceView.inputPriceView.updateInput(latestPrice)
            tradePriceView.inputPriceView.inputFixIfNeed(fixUp: tradeModel.direction == .sell)
            
            if !(tradeModel.tradeStatus == .limit && tradeModel.direction == .sell) {
                if tradeModel.tradeType == .normal {
                    tradeNumberView.inputNumberView.updateInput(NSNumber(value: trdUnit))
                } else if tradeModel.tradeType == .fractional {
                    fractionalTradeAmountView.inputAmountView.updateInput("")
                    fractionalTradeNumberView.inputNumberView.setupMinChange()
                }
            }
        }
        
        if tradeModel.tradeType == .normal, tradeModel.tradeStatus != .change, tradeModel.market == kYXMarketUS, let status = quote.msInfo?.status?.value {
            if status >= OBJECT_MARKETMarketStatus.msOpenCall.rawValue,
               status <= OBJECT_MARKETMarketStatus.msCloseCall.rawValue {
                preAfterView.updateType([.notAllow])
            } else {
                preAfterView.updateType([.allow, .notAllow], selected: .allow)
            }
        }
        
        if tradeModel.tradeType == .fractional {
            var tip = YXLanguageUtility.kLang(key: "trading_no_fractional")
            if quote.fractionnalTrade?.value != true {
                fractionalTipLabel.isHidden = false
            } else {
                if let status = quote.msInfo?.status?.value,
                   let marketStatus = OBJECT_MARKETMarketStatus(rawValue: status),
                   marketStatus == .msPreHours || marketStatus == .msAfterHours {
                    fractionalTipLabel.isHidden = false
                    if marketStatus == .msAfterHours {
                        tip = YXLanguageUtility.kLang(key: "trading_after_fractional")
                    } else {
                        tip = YXLanguageUtility.kLang(key: "trading_pre_fractional")
                    }
                } else {
                    fractionalTipLabel.isHidden = true
                }
            }
            fractionalTipLabel.text = tip
            fractionalTipLabel.contentHeight = tip.height(.systemFont(ofSize: 12), limitWidth: YXConstant.screenWidth - 56) + 22
        } else {
            fractionalTipLabel.isHidden = true
        }
                
        updateMoneyView()
    }
    
    func combineSubViews(_ oldOrderType: TradeOrderType) {
        if tradeModel.tradeOrderType == .market || tradeModel.tradeOrderType == .bidding {
            tradePriceView.isHidden = true
        } else {
            tradePriceView.isHidden = false
        }
        
        if tradeModel.tradeOrderType == .broken{ //碎股单时，有最大可卖就赋值最大可卖数量进去
            
        } else {
            if let trdUnit = quote?.trdUnit?.value, oldOrderType == .broken  {
                let trdUnitString = String(trdUnit)
                tradeNumberView.inputNumberView.updateInput(NSNumber(value:trdUnit), addMinChange: trdUnitString, cutMinChange: trdUnitString)
            }
        }
        
        requestCanBuy()
        tradePriceView.params = tradeModel.priceParams
        errorTipsView.params = tradeModel.inputTipParams
        
        if tradeModel.market == kYXMarketUS {
            if tradeModel.tradeOrderType == .market {
                preAfterView.updateType([.notAllow])
            } else {
                if tradeModel.tradeStatus != .change, let status = quote?.msInfo?.status?.value {
                    if status >= OBJECT_MARKETMarketStatus.msOpenCall.rawValue,
                       status <= OBJECT_MARKETMarketStatus.msCloseCall.rawValue {
                        preAfterView.updateType([.notAllow])
                    } else {
                        preAfterView.updateType([.allow, .notAllow], selected: .allow)
                    }
                }
            }
        }
        
        updateMoneyView()
    }
    
    var dataDidChange: (() -> Void)?
    convenience init(tradeModel: TradeModel, dataDidChange: (() -> Void)?) {
        self.init()
        
        self.tradeModel = tradeModel
        self.dataDidChange = dataDidChange
        
        if tradeModel.tradeStatus == .change {
            needRequestCanBuy = true
        }
        
        setupStackView()
        configStackView()
        
        setupUI()
    }
    
    lazy var fractionalTipLabel: TradeHeaderSubTipLabel = {
        let label = TradeHeaderSubTipLabel()
        let tip = YXLanguageUtility.kLang(key: "trading_no_fractional")
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.contentEdgeInsets = UIEdgeInsets(top: 18, left: 40, bottom: 4, right: 16)
        label.text = tip
        label.textColor = UIColor.themeColor(withNormalHex: "#F9A800", andDarkColor: "#C78600")
        label.contentHeight = tip.height(.systemFont(ofSize: 12), limitWidth: YXConstant.screenWidth - 56) + 22
        label.isHidden = true
        
        let iconView = UIImageView()
        iconView.image = UIImage(named: "fractional_tip")
        label.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(18)
            make.width.height.equalTo(16)
        }
        
        return label
    }()
    
    func setupStackView() {
        
        addSubview(stackView)
        
        stackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        stackView.addArrangedSubview(fractionalTradeTypeView)
        stackView.addArrangedSubview(fractionalTradeAmountView)
        stackView.addArrangedSubview(tradePriceView)
        stackView.addArrangedSubview(errorTipsView)
        stackView.addArrangedSubview(tradeNumberView)
        stackView.addArrangedSubview(fractionalTradeNumberView)
        stackView.addArrangedSubview(numberTipsView)
        stackView.addArrangedSubview(paymentTypeView)
        stackView.addArrangedSubview(preAfterView)
        stackView.addArrangedSubview(fractionalQuantityView)
        stackView.addArrangedSubview(moneyView)
        stackView.addArrangedSubview(powerInfoView)
        stackView.addArrangedSubview(fractionalTipLabel)
    }
    
//    var minContentHeight: CGFloat {
//        return 360
//    }
//
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
