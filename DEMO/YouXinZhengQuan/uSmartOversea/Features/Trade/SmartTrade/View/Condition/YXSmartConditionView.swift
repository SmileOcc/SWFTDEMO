//
//  YXSmartConditionView.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2021/12/28.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation

class YXSmartConditionView: UIView, YXTradeHeaderSubViewProtocol, YXTradeHeaderViewProtocol {
    
    var heightDidChange: (() -> Void)?
    var dataDidChange: (() -> Void)?
    
    @objc var subFollow: (() -> Void)?
    @objc var unSubFollow: (() -> Void)?
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = NSAttributedString(string: YXLanguageUtility.kLang(key: "trade_conditional_point"),
                                                  attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium),
                                                               .foregroundColor: QMUITheme().textColorLevel1()])
        return label
    }()
    
    lazy var shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().blockColor()
        
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    
    private var supportTrigger: Bool {
        TriggerType.supportTypes.contains(tradeModel.condition.smartOrderType)
    }
    
    private var supportPortfolio: Bool {
        SmartOrderType.portfolioTypes.contains(tradeModel.condition.smartOrderType)
    }
    
    private var isTralingStop: Bool {
        tradeModel.condition.smartOrderType == .tralingStop
    }
    
    private var isStockHandicap: Bool {
        tradeModel.condition.smartOrderType == .stockHandicap
    }
    
    @objc lazy var trackStockView: YXSmartTrackStockView = {
        let stockView = YXSmartTrackStockView()
        if tradeModel.tradeStatus == .change, tradeModel.condition.smartOrderType == .stockHandicap {
//            if let market = tradeModel.condition.releationStockMarket, let symbol = tradeModel.condition.releationStockCode {
//                let stockName =  tradeModel.condition.releationStockName ?? "--"
//                stockView.updateStockNameSymbol(name: stockName, market: market, symbol: symbol)
//                stockView.clearView()
//                let tip = stockName + "(\(symbol.uppercased() + "." + market.uppercased()))" + YXLanguageUtility.kLang(key: "trigger_price_tip")
//                trackTipLabel.text = tip
//                trackTipLabel.contentHeight = tip.height(.systemFont(ofSize: 12), limitWidth: YXConstant.screenWidth - 32 - 32) + 16
//            }
        } else {
            stockView.isHidden = true
        }
        return stockView
    }()
    
    @objc func showTrackView() {
        if let releationStockMarket = tradeModel.condition.releationStockMarket,
           let releationStockCode = tradeModel.condition.releationStockCode {
            let releationStockName = tradeModel.condition.releationStockName ?? "--"
            trackStockView.updateStockNameSymbol(name: releationStockName, market: releationStockMarket, symbol: releationStockCode)
            trackStockView.clearView()
            let tip = String(format: YXLanguageUtility.kLang(key: "trigger_price_tip"), tradeModel.name + "(\(tradeModel.symbol.uppercased() + "." + tradeModel.market.uppercased()))")
            trackTipLabel.text = tip
            trackTipLabel.contentHeight = tip.height(.systemFont(ofSize: 12), limitWidth: YXConstant.screenWidth - 32 - 32) + 16
            subFollow?()
        } else {
            trackStockView.clearStock()
            let tip = YXLanguageUtility.kLang(key: "trigger_price_tip_no_stock")
            trackTipLabel.text = tip
            trackTipLabel.contentHeight = tip.height(.systemFont(ofSize: 12), limitWidth: YXConstant.screenWidth - 32 - 32) + 16
            conditionPriceView.inputPriceView.updateInput("")
            conditionPriceView.inputPriceView.inputTextField.endEditing(true)
        }
        trackStockView.isHidden = false
        trackTipLabel.isHidden = false
    }
    
    func hideTrackView() {
        trackStockView.isHidden = true
        trackTipLabel.isHidden = true
        unSubFollow?()
    }
    
    lazy var trackTipLabel: TradeHeaderSubTipLabel = {
        let label = TradeHeaderSubTipLabel()
        let tip = YXLanguageUtility.kLang(key: "trigger_price_tip_no_stock")
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 8, right: 16)
        label.text = tip
        label.textColor = QMUITheme().textColorLevel1()
        label.contentHeight = tip.height(.systemFont(ofSize: 12), limitWidth: YXConstant.screenWidth - 32 - 32) + 8
        label.isHidden = true
        return label
    }()
    
    lazy var triggerTypeView: YXSmartTriggerTypeView = {
        var triggerType: TriggerType = .price
        
        if supportTrigger {
            if let amountIncrease = tradeModel.condition.amountIncrease {
                triggerType = .percent
            } else if isTralingStop {
                if let dropPriceValue = Double(tradeModel.condition.dropPrice ?? ""),
                   dropPriceValue > 0 {
                    triggerType = .price
                } else {
                    triggerType = .percent
                }
            }
        }
        let view = YXSmartTriggerTypeView(triggerType) { [weak self] type in
            self?.resetCondition(with: type)
        }
        return view
    }()
    
    lazy var conditionPriceView: YXSmartConditionPriceView = {
        let view = YXSmartConditionPriceView(params: tradeModel.priceParams) { [weak self] price in
            guard let strongSelf = self else { return }

            strongSelf.tradeModel.condition.conditionPrice = price
            strongSelf.tradeModel.condition.amountIncrease = nil
            strongSelf.errorTipsView.params = strongSelf.tradeModel.inputTipParams
            strongSelf.dataDidChange?()
        }

        view.inputPriceView.resetMinChange()
        
        if let amountIncrease = tradeModel.condition.amountIncrease {
            
        } else {
            view.inputPriceView.updateInput(tradeModel.condition.conditionPrice ?? "")
        }
        
        return view
    }()
    
    lazy var priceSpreadView: YXSmartPriceSpreadView = {
        let view = YXSmartPriceSpreadView(tradeModel.condition.dropPrice) { [weak self] (spread, price) in
            guard let strongSelf = self else { return }

            if strongSelf.tradeModel.condition.dropPrice != nil || spread != nil {
                strongSelf.tradeModel.condition.dropPrice = spread
                strongSelf.tradeModel.condition.conditionPrice = price
                strongSelf.dataDidChange?()
            }
        }
        view.isHidden = true
        return view
    }()
    
    @objc lazy var errorTipsView: YXTradeErrorTipsView = {
        let view = YXTradeErrorTipsView(params: tradeModel.inputTipParams, isCondition: true)
        view.isHidden = true
        return view
    }()
    
    lazy var amountIncreaseView: YXSmartAmountIncreaseView = {
        var amountIncreaseString: String?
        if let amountIncrease = tradeModel.condition.amountIncrease?.doubleValue {
            amountIncreaseString = String(format: "%.2f", amountIncrease * 100)
        }
        let view = YXSmartAmountIncreaseView(amountIncreaseString) { [weak self] (percent, price) in
            guard let strongSelf = self else { return }

            if strongSelf.tradeModel.condition.amountIncrease != nil || percent != nil {
                strongSelf.tradeModel.condition.amountIncrease = percent
                strongSelf.tradeModel.condition.conditionPrice = price
                strongSelf.dataDidChange?()
            }
        }
        
        view.currency = tradeModel.currency
        view.smartOrderType = tradeModel.condition.smartOrderType
        return view
    }()
    
    func resetCondition(with triggerType: TriggerType) {
        if supportTrigger {
            if isTralingStop {
                conditionPriceView.isHidden = true
                if triggerType == .price {
                    amountIncreaseView.isHidden = true
                    priceSpreadView.isHidden = false

                    amountIncreaseView.basicPrice = nil
                    amountIncreaseView.percentTextFld.text = nil
                    amountIncreaseView.percentTextFld.endEditing(true)

                } else if triggerType == .percent {
                    priceSpreadView.isHidden = true
                    amountIncreaseView.isHidden = false

                    priceSpreadView.textFld.text = nil
                    priceSpreadView.textFld.endEditing(true)
                    
                    amountIncreaseView.smartOrderType = tradeModel.condition.smartOrderType
                }
            } else {
                if triggerType == .price {
                    amountIncreaseView.isHidden = true
                    amountIncreaseView.basicPrice = nil
                    amountIncreaseView.percentTextFld.text = nil
                    amountIncreaseView.percentTextFld.endEditing(true)

                    conditionPriceView.isHidden = false
                } else if triggerType == .percent {
                    conditionPriceView.isHidden = true
                    conditionPriceView.inputPriceView.updateInput("")
                    conditionPriceView.inputPriceView.inputTextField.endEditing(true)
                    
                    amountIncreaseView.isHidden = false
                    amountIncreaseView.smartOrderType = tradeModel.condition.smartOrderType
                }
            }
            refreshTrigger()
        }
    }
    
    func refreshTrigger() {
        if triggerTypeView.triggerType == .price {
            if isTralingStop {
                priceSpreadView.currency = tradeModel.currency
                if isTralingStop, tradeModel.tradeStatus == .change {
                    priceSpreadView.basicPrice = tradeModel.condition.highestPrice
                } else {
                    priceSpreadView.basicPrice = tradeModel.latestPrice
                }
            } else {
                conditionPriceView.isInlineWarrant = quote?.isInlineWarrant
                conditionPriceView.spreadTable = YXSpreadTableManager.shared.spreadTable(with: tradeModel.market, stc: quote?.stc?.value, spreadTab: quote?.spreadTab, condition: true)
                conditionPriceView.params = tradeModel.priceParams
            }
        } else {
            amountIncreaseView.currency = tradeModel.currency
            if isTralingStop, tradeModel.tradeStatus == .change {
                amountIncreaseView.basicPrice = tradeModel.condition.highestPrice
            } else {
                amountIncreaseView.basicPrice = tradeModel.latestPrice
            }
        }
    }
    
    func refreshPortfolio() {
        amountIncreaseView.currency = tradeModel.currency
    }
    
    func setupUI() {
        if supportTrigger {
            hideTrackView()
            triggerTypeView.isHidden = false
            
            var triggerType: TriggerType = .price
            if let amountIncrease = tradeModel.condition.amountIncrease {
                triggerType = .percent
                conditionPriceView.isHidden = true
                priceSpreadView.isHidden = true
                amountIncreaseView.isHidden = false
                amountIncreaseView.smartOrderType = tradeModel.condition.smartOrderType
                amountIncreaseView.currency = tradeModel.currency
                amountIncreaseView.basicPrice = tradeModel.latestPrice
                
                amountIncreaseView.percentTextFld.text = String(format: "%.2f", amountIncrease.doubleValue * 100)
            } else {
                if isTralingStop {
                    conditionPriceView.isHidden = true
                    errorTipsView.isHidden = true
                    if let dropPriceValue = Double(tradeModel.condition.dropPrice ?? ""),
                       dropPriceValue > 0 {
                        triggerType = .price
                        amountIncreaseView.isHidden = true
                        priceSpreadView.isHidden = false
                        priceSpreadView.currency = tradeModel.currency
                        if tradeModel.tradeStatus == .change {
                            priceSpreadView.basicPrice = tradeModel.condition.highestPrice
                        } else {
                            priceSpreadView.basicPrice = tradeModel.latestPrice
                        }
                        priceSpreadView.textFld.text = tradeModel.condition.dropPrice
                    } else {
                        triggerType = .percent
                        priceSpreadView.isHidden = true
                        amountIncreaseView.isHidden = false
                        amountIncreaseView.smartOrderType = tradeModel.condition.smartOrderType
                        amountIncreaseView.currency = tradeModel.currency
                        amountIncreaseView.basicPrice = tradeModel.latestPrice
                    }

                } else {
                    conditionPriceView.isHidden = false
                    amountIncreaseView.isHidden = true
                    priceSpreadView.isHidden = true

                    conditionPriceView.inputPriceView.resetMinChange()
                    conditionPriceView.inputPriceView.updateInput(tradeModel.condition.conditionPrice ?? "")
                    conditionPriceView.params = tradeModel.priceParams
                    
                    errorTipsView.params = tradeModel.inputTipParams
                }
            }
            triggerTypeView.updateType(triggerType)
  
        } else if supportPortfolio {
            hideTrackView()
            triggerTypeView.isHidden = true
            conditionPriceView.isHidden = true
            priceSpreadView.isHidden = true
            amountIncreaseView.isHidden = false
            
            if let amountIncrease = tradeModel.condition.amountIncrease {
                amountIncreaseView.percentTextFld.text = String(format: "%.2f", amountIncrease.doubleValue * 100)
            } else {
                amountIncreaseView.percentTextFld.text = nil
            }
            
            amountIncreaseView.smartOrderType = tradeModel.condition.smartOrderType
            amountIncreaseView.currency = tradeModel.currency
            amountIncreaseView.basicPrice = nil
        } else if isStockHandicap {
            showTrackView()
            conditionPriceView.isHidden = false
            conditionPriceView.inputPriceView.customPlaceHolder = YXLanguageUtility.kLang(key: "reaching_price")
            triggerTypeView.isHidden = true
            priceSpreadView.isHidden = true
            amountIncreaseView.isHidden = true
        } else {
            hideTrackView()
            triggerTypeView.isHidden = true
            conditionPriceView.isHidden = true
            priceSpreadView.isHidden = true
            amountIncreaseView.isHidden = true
        }
    }
    
    
    
    var tradeModel: TradeModel! {
        didSet {
            setupUI()
        }
    }
    
    var quote: YXV2Quote? {
        didSet {
            if supportTrigger {
                refreshTrigger()
            } else if supportPortfolio {
                refreshPortfolio()
            } else if isStockHandicap {
                if tradeModel.condition.releationStockCode == nil,
                   let type1 = quote?.type1?.value,
                   type1 == 5 {
                   //(type3 == 50102 || type3 == 50103 || type3 == 50104) {
                    tradeModel.condition.releationStockCode = quote?.underlingSEC?.symbol
                    tradeModel.condition.releationStockMarket = quote?.underlingSEC?.market
                    tradeModel.condition.releationStockName = quote?.underlingSEC?.name
                    tradeModel.condition.releationStockCurrency = nil
                    showTrackView()
                }
            }
        }
    }
    
    var followQuote: YXV2Quote? {
        didSet {
            if followQuote != nil {
                if isStockHandicap {
                    trackStockView.updateUI(quote: followQuote)
                    tradeModel.condition.releationStockName = followQuote?.name
                    if let market = followQuote?.market, let symbol = followQuote?.symbol {
                        trackStockView.updateStockNameSymbol(name: tradeModel.condition.releationStockName ?? "--", market: market, symbol: symbol)
                    }
                    var currency = YXToolUtility.currency(market: followQuote?.market, quoteCurrency: followQuote?.currency?.value ?? 0)
                    tradeModel.condition.releationStockCurrency = currency
                    currency = currency.count > 0 ? "(\(currency))" : ""
                    conditionPriceView.inputPriceView.customPlaceHolder = YXLanguageUtility.kLang(key: "reaching_price") + currency
                    conditionPriceView.spreadTable = YXSpreadTableManager.shared.spreadTable(with: followQuote?.market, stc: followQuote?.stc?.value, spreadTab: followQuote?.spreadTab, condition: true)
                }
            } else {
                trackStockView.clearStock()
            }
            tradeModel.condition.trackMarketPrice = followQuote?.simpleQuote().latestPrice
        }
    }
    
    convenience init(tradeModel: TradeModel) {
        self.init()
        
        self.tradeModel = tradeModel
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(32)
        }
        
        setupStackView()
        configStackView()
        updateHeight()
    }
    
    
    func setupStackView() {
        addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(topMargin)
            make.bottom.equalToSuperview().offset(-bottomMargin)
        }
        
        stackView.addArrangedSubview(triggerTypeView)
        stackView.addArrangedSubview(priceSpreadView)
        stackView.addArrangedSubview(amountIncreaseView)
        stackView.addArrangedSubview(trackStockView)
        stackView.addArrangedSubview(conditionPriceView)
        stackView.addArrangedSubview(trackTipLabel)
        stackView.addArrangedSubview(errorTipsView)
        
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
        return 8
    }
}
