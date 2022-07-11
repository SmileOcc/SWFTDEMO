//
//  YXNormalTradeHeaderView.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/3/25.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

@objcMembers class YXNormalTradeHeaderView: UIView, YXTradeHeaderViewProtocol {
   var needSingleUpdate = false

   var updateTradeType: (()->(Void))?
   var tradeOrderFinished: (()->(Void))?
   var updateAskBid: (()->(Void))?
   var clickSmartOrder: (()->(Void))?
    
   var quote: YXV2Quote? {
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
    
   var tradeModel: TradeModel! {
        didSet {
            if oldValue != tradeModel {
                quote = nil
            }
            tradeModel.canMargin = YXUserManager.shared().canMargin
            setupUI() //订单类型改变，股票改变 整体变
        }
    }
    
   var heightDidChange: (() -> Void)?
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    /// 股票行情
   lazy var stockView: YXTradeStockView = {
        let stockView = YXTradeStockView()
        stockView.contentHeight = 50
        return stockView
    }()
    
//    lazy var optionChainView: YXTradeOptionChainView = {
//        let view = YXTradeOptionChainView()
//        return view
//    }()
    
    lazy var directionView: YXTradeDirectionView = {
        let view = YXTradeDirectionView()
        
        view.selectTypeCallBack = { [weak self] selectType in
            self?.directionDidChange(selectType.direction)
        }
        
        return view
    }()
    
    func directionDidChange(_ direction: TradeDirection) {
        tradeModel.direction = direction
        placeOrderView.updateFractionalTradeType()
        placeOrderView.updatePaymentTypeView()
        placeOrderView.updateMoneyView()
        updateSubmitView()
    }
    
    /// 下单类型
    lazy var orderTypeView: YXTradeOrderTypeView = {
        let typeArr = TradeOrderType.typeArr(tradeModel: tradeModel, quote: quote)
        
        let view = YXTradeOrderTypeView(typeArr: typeArr, selected: tradeModel.tradeOrderType) { [weak self] (type) in
            self?.orderTypeDidChange(type)
        }
        view.selectView.ignoreTypes = [.smart]
        
        if tradeModel.tradeStatus != .change {
            view.infoButton.qmui_tapBlock = { [weak self] _ in
                guard let strongSelf = self else { return }
                YXWebViewModel.pushToWebVC(YXH5Urls.orderHelpUrl())
            }
        } else {
            view.infoButton.isHidden = true
            view.infoIconView.isHidden = true
        }
        
        return view
    }()
    
    func orderTypeDidChange(_ type: TradeOrderType) {
        
        let oldOrderType = tradeModel.tradeOrderType
        tradeModel.tradeOrderType = type
        
        var event = ""
        switch type {
        case .limitEnhanced,
             .limit:
            event = "Enhanced Limit Orde_Tab"
        case .market:
            event = "Market Order_Tab"
        case .limitBidding:
            event = "AUO_Tab"
        case .bidding:
            event = "AUC_Tab"
        default:
            break
        }
        trackViewClickEvent(name: event)
         
        placeOrderView.combineSubViews(oldOrderType)
        updateSubmitView()
    }

    lazy var placeOrderView: YXPlaceOrderView = {
        let view = YXPlaceOrderView(tradeModel: tradeModel) { [weak self] in
            self?.updateSubmitView()
        }
        return view
    }()
    
    lazy var submitView: YXTradeSubmitView = {
        let view = YXTradeSubmitView(direction: tradeModel.direction)
        view.isSmart = false
        view.unLockBlock = { [weak self] in
            self?.updateSubmitView()
        }
        
        view.submitBlock = { [weak self] in
            guard let strongSelf = self else { return }

            YXTradeManager.shared.tradeOrder(tradeModel: strongSelf.tradeModel, currentViewController: strongSelf.viewController()) { [weak self] in
                guard let `self` = self else { return }
                self.tradeOrderFinished?()
                
                let secu = YXOptionalSecu()
                secu.name = self.tradeModel.name
                secu.market = self.tradeModel.market
                secu.symbol = self.tradeModel.symbol
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
    
    convenience init(tradeModel: TradeModel) {
        self.init()
        
        self.tradeModel = tradeModel
        tradeModel.canMargin = YXUserManager.shared().canMargin
        
        setupStackView()
        configStackView()
        
        setupUI()
        
        backgroundColor = QMUITheme().foregroundColor()
    }
    
    func setupStackView() {
        
        addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        stackView.addArrangedSubview(stockView)
//        stackView.addArrangedSubview(optionChainView)
        stackView.addArrangedSubview(directionView)
        stackView.addArrangedSubview(orderTypeView)
        stackView.addArrangedSubview(placeOrderView)
        stackView.addArrangedSubview(submitView)
        
        let line = TradeHeaderSubView()
        line.backgroundColor = QMUITheme().backgroundColor()
        line.contentHeight = 8
        stackView.addArrangedSubview(line)
    }

    //MARK: --UI
    func clearStockView() {
        if (tradeModel.symbol != "") {
            stockView.clearView()
        }
    }
    
    /// 依赖tradeModel而变的
    func setupUI() {
        tradeModel.currency = YXToolUtility.currency(market: tradeModel.market)
        
        //股票
        stockView.updateStockNameSymbol(name: tradeModel.name, market: tradeModel.market, symbol: tradeModel.symbol)
        stockView.updateUI(quote: quote, tradeModel: tradeModel)
        
        placeOrderView.tradeModel = tradeModel

        //类型
        let typeArr = TradeOrderType.typeArr(tradeModel: tradeModel, quote: quote)
        orderTypeView.selectView.updateType(typeArr, selected: tradeModel.tradeOrderType)
        
        directionView.selectType = tradeModel.directionButtonType
        
        updateSubmitView()
        
        if tradeModel.tradeStatus == .change{
            quoteCanMargin()
        }
    }
    
    //quotemodel变了需要第一次赋值的地方
    func singleUpdateSubViews() {
        guard let quote = quote else { return }
        
        if let name = quote.name {
            stockView.updateStockNameSymbol(name: name, market: quote.market, symbol: quote.symbol)
        }
        
        placeOrderView.singleUpdateSubViews()
        
        quoteCanMargin()
    }
        
    //quote不需要第一次设值，更新quote新数据的地方
    func updateSubViews() {
        stockView.updateUI(quote: quote, tradeModel: tradeModel)

        let typeArr = TradeOrderType.typeArr(tradeModel: tradeModel, quote: quote)
        orderTypeView.selectView.updateType(typeArr)
        
        placeOrderView.quote = quote
     
        updateSubmitView()
    }
    
    func updateTradeModel() {
        if let name = quote?.name, name.count > 0 {
            tradeModel.name = name
        }
        tradeModel.currency = YXToolUtility.currency(quoteCurrency: quote?.currency?.value)
        tradeModel.latestPrice = quote?.simpleQuote().latestPrice
        tradeModel.trdUnit = quote?.trdUnit?.value
        tradeModel.isDerivatives = quote?.isDerivatives ?? false
    
        if let greyFlag = quote?.greyFlag?.value, greyFlag > 0, quote?.msInfo?.status?.value != OBJECT_MARKETMarketStatus.msGreyAfterOpen.rawValue {
            tradeModel.tradePeriod = .grey;
        } else if tradeModel.tradePeriod != .preAfter{
            tradeModel.tradePeriod = .normal;
        }
        
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
    
//    @objc func cancelPosRequest() {
//        self.placeOrderView.posBrokerRrequest?.cancel()
//    }
     
}


extension YXV2Quote {
    
    enum MarketStatus {
        case normal
        case pre
        case after
    }
    
    enum UpDownType {
        case normal
        case up
        case down
        
        var op: String {
            if self == .up {
                return "+"
            }
            return ""
        }
    }
    
    var isDerivatives: Bool {
        if let type1Value = type1?.value {
            return type1Value == 3 || type1Value == 5
        }
        return false
    }
    
    typealias SimpleQuote = (market: String?, latestPrice: String?, pctchng: String?, netchng: String?, marketStatus: MarketStatus, upDownType: UpDownType)

    var pClose: String {
        var pClose: String = ""
        if let value = preClose?.value {
            pClose = Double(value).value(priceBase: priceBase?.value)
        }
        
        var marketStatus: OBJECT_MARKETMarketStatus?
        if let status = msInfo?.status?.value {
            marketStatus = OBJECT_MARKETMarketStatus(rawValue: status)
        }

        if market == kYXMarketUS, let marketStatus = marketStatus, marketStatus == .msPreHours || marketStatus == .msClose || marketStatus == .msAfterHours ||  marketStatus == .msStart  {
            if let value = latestPrice?.value {
                pClose = Double(value).value(priceBase: priceBase?.value)
            }
        }
        
        return pClose
    }
    
    func simpleQuote(withPreAfter: Bool = true) -> SimpleQuote {
        let marketStr: String = market ?? ""
        var latestPrice: String?
        if let value = self.latestPrice?.value {
            latestPrice = Double(value).value(priceBase: priceBase?.value)
        } else if let value = preClose?.value {
            latestPrice = Double(value).value(priceBase: priceBase?.value)
        }

        var upDownType: UpDownType = .normal
        var netchng: String?
        if let value = self.netchng?.value {
            if value > 0 {
                upDownType = .up
            } else if value < 0 {
                upDownType = .down
            }
            netchng = upDownType.op + Double(value).value(priceBase: priceBase?.value)
        }

        var pctchng: String?
        if let value = self.pctchng?.value {
            pctchng = upDownType.op + String(format: "%.2f%%", Double(value)/100.0)
        }

        var statuts: MarketStatus = .normal
        if market == kYXMarketUS, withPreAfter {
            var marketStatus: OBJECT_MARKETMarketStatus?
            if let status = msInfo?.status?.value {
                marketStatus = OBJECT_MARKETMarketStatus(rawValue: status)
            }

            if let sLatestPrice = sQuote?.latestPrice?.value, sLatestPrice > 0,
               let sPctchng = sQuote?.pctchng?.value,
               let sNetchng = sQuote?.netchng?.value,
               let marketStatus = marketStatus, marketStatus == .msPreHours || marketStatus == .msClose || marketStatus == .msAfterHours ||  marketStatus == .msStart  {
                if marketStatus == .msClose || marketStatus == .msAfterHours ||  marketStatus == .msStart {
                    statuts = .after
                } else {
                    statuts = .pre
                }
                latestPrice = Double(sLatestPrice).value(priceBase: priceBase?.value)

                if sNetchng > 0 {
                    upDownType = .up
                } else if sNetchng < 0 {
                    upDownType = .down
                } else {
                    upDownType = .normal
                }
                netchng = upDownType.op + Double(sNetchng).value(priceBase: priceBase?.value)
                pctchng = upDownType.op + String(format: "%.2f%%", Double(sPctchng)/100.0)
            }
        }

        return (market: marketStr, latestPrice: latestPrice, pctchng: pctchng, netchng: netchng, marketStatus: statuts, upDownType: upDownType)
    }
    
    func simpleQuoteLastPrice(withPreAfter: Bool = true) -> Int64? {
        var latestPrice: Int64?
        
        if let value = self.latestPrice?.value {
            latestPrice = value
        } else if let value = preClose?.value {
            latestPrice = value
        }
        if market == kYXMarketUS, withPreAfter {
            var marketStatus: OBJECT_MARKETMarketStatus?
            if let status = msInfo?.status?.value {
                marketStatus = OBJECT_MARKETMarketStatus(rawValue: status)
            }

            if let sLatestPrice = sQuote?.latestPrice?.value, sLatestPrice > 0,
               let marketStatus = marketStatus, marketStatus == .msPreHours || marketStatus == .msClose || marketStatus == .msAfterHours ||  marketStatus == .msStart  {
                latestPrice = sLatestPrice

            }
        }

        return latestPrice
    }
}


extension YXToolUtility {
    class func currency(market: String? = nil, quoteCurrency: Int64? = nil) -> String {
        var curreryIndex: Int = 0
        if let quoteCurrency = quoteCurrency {
            curreryIndex = Int(quoteCurrency)
        }else{
            if market == kYXMarketHK {
                curreryIndex = 3
            } else if market == kYXMarketUS || market == kYXMarketUsOption {
                curreryIndex = 2
            } else if market == kYXMarketChinaSH || market == kYXMarketChinaSZ {
                curreryIndex = 1
            } else if market == kYXMarketSG {
                curreryIndex = 5
            }
        }
        return YXToolUtility.quoteCurrency(curreryIndex)
    }

    class func currencyName(_ currency: String) -> String {
        switch currency {
        case "HKD":
            return YXLanguageUtility.kLang(key: "common_hk_dollar")
        case "SGD":
            return YXLanguageUtility.kLang(key: "common_sg_dollar")
        case "USD":
            return YXLanguageUtility.kLang(key: "common_us_dollar")
        default:
            return ""
        }
    }
}

