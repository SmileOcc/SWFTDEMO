//
//  YXSmartTradeHeaderView.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2021/12/26.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit


@objcMembers class YXSmartTradeHeaderView: UIView, YXTradeHeaderViewProtocol {

    @objc var needSingleUpdate = false
    
    @objc var updateSmartOrderType: ((String)->(Void))?
    @objc var tradeOrderFinished: (()->(Void))?
    @objc var updateAskBid: (()->(Void))?
    
    @objc var quote: YXV2Quote? {
        didSet {
            guard let quote = quote,
                  quote.market == tradeModel.market,
                  quote.symbol == tradeModel.symbol else {
                tradeModel.latestPrice = nil
                clearStockView()
                return
            }

            updateTradeModel()
            updateSubViews()
            
            if needSingleUpdate {
                singleUpdateSubViews()  //股票切换需要初使化  price numview
                needSingleUpdate = false
            }
        }
    }
    
    @objc var followQuote: YXV2Quote? {
        didSet {
            if let quote = followQuote,
               (quote.symbol != tradeModel.condition.releationStockCode ||
               quote.market != tradeModel.condition.releationStockMarket) {
                conditionView.followQuote = nil
                return
            }
            
            if tradeModel.condition.smartOrderType == .stockHandicap {
                conditionView.followQuote = followQuote
            }
        }
    }
    
    @objc var tradeModel: TradeModel! {
        didSet {
            if oldValue != tradeModel {
                quote = nil
                followQuote = nil
            }
            tradeModel.canMargin = YXUserManager.shared().canMargin
            setupUI()
        }
    }
    
    @objc var heightDidChange: (() -> Void)?
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    /// 股票行情
    @objc lazy var stockView: YXTradeStockView = {
        let stockView = YXTradeStockView()
        stockView.contentHeight = 50
        return stockView
    }()
    
    @objc func updatePrice(price: String) {
    }
    
    /// 下单类型
    lazy var smartOrderTypeView: YXSmartOrderTypeView = {
        let typeArr = SmartOrderType.typeArr(tradeModel: tradeModel)
        
        let view = YXSmartOrderTypeView(typeArr: typeArr, selected: tradeModel.condition.smartOrderType) { [weak self] (type) in
            guard let strongSelf = self else { return }
            
            if (strongSelf.tradeModel.condition.smartOrderType != type) {
                strongSelf.change(smartOrderType: type)
            }
            strongSelf.updateSmartOrderType?(type.text)
        }
        
        if tradeModel.tradeStatus != .change {
            view.infoButton.qmui_tapBlock = { [weak self] _ in
                guard let strongSelf = self else { return }
                YXWebViewModel.pushToWebVC(YXH5Urls.smartInfoUrl(with: strongSelf.tradeModel.market,
                                                                 smartOrderType: strongSelf.tradeModel.condition.smartOrderType))
            }
        } else {
            view.infoButton.isHidden = true
            view.infoIconView.isHidden = true
        }

        return view
    }()
    
    func change(smartOrderType: SmartOrderType) {

        var event = ""
        switch smartOrderType {
        case .breakBuy:
            event = "Breakthrough Buy_Tab"
        case .lowPriceBuy:
            event = "Buy-low_Tab"
        case .highPriceSell:
            event = "Sell-high_Tab"
        case .breakSell:
            event = "Breakdown-sell_Tab"
        default:
            break
        }
        trackViewClickEvent(name: event)
        
        let condition = ConditionModel()
        condition.smartOrderType = smartOrderType
        condition.strategyEnddateDesc = tradeModel.condition.strategyEnddateDesc
        condition.strategyEnddateTitle = tradeModel.condition.strategyEnddateTitle
        condition.strategyEnddateYearMsg = tradeModel.condition.strategyEnddateYearMsg
        condition.entrustGear = tradeModel.condition.entrustGear
        
        tradeModel.condition = condition
        tradeModel.direction = smartOrderType.direction
        
        setupUI()
                
        if quote != nil {
            updateSubViews()
        }
    }

    lazy var conditionView: YXSmartConditionView = {
        let view = YXSmartConditionView(tradeModel: tradeModel)
        view.dataDidChange = { [weak self] in
            self?.updateSubmitView()
            self?.updatePriceErrorTips()
        }
        return view
    }()
    
    lazy var placeOrderView: YXSmartPlaceOrderView = {
        let view = YXSmartPlaceOrderView(tradeModel: tradeModel)
        view.dataDidChange = { [weak self] in
            self?.updateSubmitView()
            self?.updateConfigView()
        }
        view.powerInfoDidChange = { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.conditionView.amountIncreaseView.updateCostPriceIfNeed(strongSelf.tradeModel.powerInfo?.costPrice ?? 0)
            if strongSelf.tradeModel.condition.smartOrderType == .tralingStop {
                strongSelf.conditionView.priceSpreadView.updateCostPriceIfNeed(strongSelf.tradeModel.powerInfo?.costPrice ?? 0)
            }
        }
        return view
    }()
    
    func updatePriceErrorTips() {
        placeOrderView.errorTipsView.params = tradeModel.inputTipParams
    }
    
    lazy var configView: YXSmartConfigView = {
        let view = YXSmartConfigView(tradeModel: tradeModel)
        return view
    }()
    
    func updateConfigView() {
        if tradeModel.market == kYXMarketUS,
           tradeModel.condition.entrustGear != .market,
           tradeModel.condition.smartOrderType != .tralingStop {
            configView.preAfterView.isHidden = false
        } else {
            configView.preAfterView.isHidden = true
            configView.preAfterView.updateType(selected: .notAllow)
        }
    }
    
    lazy var submitView: YXTradeSubmitView = {
        let view = YXTradeSubmitView(direction: tradeModel.direction, isSubmit: true)
        view.isSmart = true
        view.unLockBlock = { [weak self] in
            self?.updateSubmitView()
        }
        
        view.submitBlock = { [weak self] in
            guard let strongSelf = self else { return }

            YXTradeManager.shared.tradeOrder(tradeModel: strongSelf.tradeModel, currentViewController: strongSelf.viewController()) { [weak self] in
                strongSelf.tradeOrderFinished?()
                
                let secu = YXOptionalSecu()
                secu.name = strongSelf.tradeModel.name
                secu.market = strongSelf.tradeModel.market
                secu.symbol = strongSelf.tradeModel.symbol
                YXSecuGroupManager.shareInstance().append(secu)
            } brokenBlock: {
//                    self?.orderTypeView.selectView.updateType(selected: .broken)
            }
        }
        
        return view
    }()
    
    func updateSubmitView() {
        submitView.direction = tradeModel.direction
        submitView.canSubimt = tradeModel.canSubmit
    }

    lazy var smartTipLabel: TradeHeaderSubTipLabel = {
        let label = TradeHeaderSubTipLabel()
        let tip = YXLanguageUtility.kLang(key: "smart_order_trigger_tip")
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 24, right: 16)
        label.text = tip
        label.textColor = QMUITheme().textColorLevel3()
        label.contentHeight = tip.height(.systemFont(ofSize: 14), limitWidth: YXConstant.screenWidth - 32) + 24
        return label
    }()
    
    @objc convenience init(tradeModel: TradeModel) {
        self.init()
        
        backgroundColor = QMUITheme().foregroundColor()
        self.tradeModel = tradeModel
        tradeModel.canMargin = YXUserManager.shared().canMargin
        
        setupStackView()
        configStackView()
        updateHeight()
        
        setupUI()
    }
    
    func setupStackView() {
        addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        stackView.addArrangedSubview(stockView)
        stackView.addArrangedSubview(smartOrderTypeView)
        stackView.addArrangedSubview(conditionView)
        stackView.addArrangedSubview(placeOrderView)
        stackView.addArrangedSubview(configView)
        stackView.addArrangedSubview(submitView)
        stackView.addArrangedSubview(smartTipLabel)
        
        let line = TradeHeaderSubView()
        line.backgroundColor = QMUITheme().backgroundColor()
        line.contentHeight = 8
        stackView.addArrangedSubview(line)
    }
    
    func clearStockView() {
        if (tradeModel.symbol != "") {
            stockView.clearView()
        }
    }
    
    /// 依赖tradeModel而变的
    func setupUI() {
        //股票view
        if tradeModel.currency.isEmpty {
            tradeModel.currency = YXToolUtility.currency(market: tradeModel.market)
        }

        switch tradeModel.condition.smartOrderType {
        case .stopLossSell,
             .stopLossSellOption,
             .highPriceSell,
             .stopProfitSell,
             .stopProfitSellOption,
             .breakSell:
            tradeModel.direction = .sell
        default:
            break
        }
        
        stockView.updateStockNameSymbol(name: tradeModel.name, market: tradeModel.market, symbol: tradeModel.symbol)
        stockView.updateUI(quote: quote, tradeModel: tradeModel)
        
        conditionView.tradeModel = tradeModel
        placeOrderView.tradeModel = tradeModel
        configView.tradeModel = tradeModel

        if tradeModel.tradeStatus == .change{
            quoteCanMargin()
        }
        
        combineSubViews()
        updateSubmitView()
    }
    
    func singleUpdateSubViews() {
        guard let quote = quote else { return }
        
        if let name = quote.name {
            stockView.updateStockNameSymbol(name: name, market: quote.market, symbol: quote.symbol)
        }
        quoteCanMargin()
    }
    
    func combineSubViews() {
        
    }
    
    //quote不需要第一次设值，更新quote新数据的地方
    func updateSubViews() {
        stockView.updateUI(quote: quote, tradeModel: tradeModel)
        
        conditionView.quote = quote
        placeOrderView.quote = quote
        
        updateSubmitView()
    }
    
    func updateTradeModel() {
        if let name = quote?.name, name.count > 0 {
            tradeModel.name = name
        }

        tradeModel.currency = YXToolUtility.quoteCurrency(Int(quote?.currency?.value ?? 0))
        tradeModel.latestPrice = quote?.simpleQuote().latestPrice
        tradeModel.trdUnit = quote?.trdUnit?.value
        tradeModel.isDerivatives = quote?.isDerivatives ?? false
        
        placeOrderView.requestCanBuyIfNeed()
    }
    
    func quoteCanMargin()  {
        stockView.updataMargn()
        if tradeModel.market == kYXMarketUsOption {
            tradeModel.canMargin = true
            placeOrderView.updatePaymentTypeView()
            return
        }
        YXMarginManager.shared.requsetStockCanMargin(stockCode: tradeModel.symbol, market: tradeModel.market) {[weak self] res in
            guard let `self` = self else { return }
            guard let res = res else { return }
            
            self.placeOrderView.updatePaymentTypeView()
            self.stockView.updataMargn(canMargin: res.margin == 1, marginRatio: res.mortgageRatio * 100)
        }
    }
}

class TradeHeaderSubTipLabel: QMUILabel, YXTradeHeaderSubViewProtocol {
    
}

class TradeHeaderSubView: UIView, YXTradeHeaderSubViewProtocol {
    
}
