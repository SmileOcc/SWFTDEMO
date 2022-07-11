//
//  YXStockDetailViewModel.swift
//  uSmartOversea
//
//  Created by Kelvin on 2019/4/10.
//  Copyright © 2019年 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import YYModel
import URLNavigator
import YXKit
import UIKit

enum StockDetailViewTabType: UInt {
    case quote = 0
    case news
    case discussions
    case announcements
    case financials
    case profile
    case etfList
    case constituents
    case dividens //股息
    case optionChain //股息
}

extension StockDetailViewTabType {
 
    var title: String {
        switch self {
        case .quote:
            return YXLanguageUtility.kLang(key: "stock_detail_quote")
        case .news:
            return YXLanguageUtility.kLang(key: "quote_tab_news")
        case .discussions:
            return YXLanguageUtility.kLang(key: "quote_tab_comments")
        case .announcements:
            return YXLanguageUtility.kLang(key: "stock_detail_announcement")
        case .financials:
            return YXLanguageUtility.kLang(key: "quote_tab_finance")
        case .profile:
            return YXLanguageUtility.kLang(key: "stock_detail_briefing")
        case .etfList:
            return YXLanguageUtility.kLang(key: "stock_tab_etf")
        case .constituents:
            return YXLanguageUtility.kLang(key: "stock_tab_constituents")
        case .dividens:
            return YXLanguageUtility.kLang(key: "market_entrance_dividens")
        case .optionChain:
            return YXLanguageUtility.kLang(key: "options")
        }
    }
}

class YXStockDetailViewModel: HUDServicesViewModel  {
    static var stockDetailTab: Int = -1
    // hud的信号
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    //step/service
    typealias Services = HasYXQuotesDataService & HasYXMessageCenterService & HasYXStockAnalyzeService
    var navigator: NavigatorServicesType!
    let newStockService = YXNewStockService()
    
    //MARK: tabTiles and PageControllers
    var tabTypes: [StockDetailViewTabType] = [.quote]

    //MARK:- Quote数据变量 及 股票数据变量
    var quoteModel: YXV2Quote?
    var dataSource: [YXStockInputModel] = []
    var selectIndex: Int = 0 //当前数据源在 dataSource 中的位置

    var shortSellModel: YXStockShortSellModel?
    var optionChainQuoteModel: YXV2Quote?

    //market/symbol/name
    var market = ""
    var exchangeType: YXExchangeType = .hk
    var symbol = ""
    var name: String?
    var type1: Int32?
    var type2: Int32?
    var type3: Int32?
    var marketSymbol = ""
    var ygExit = false

    var hasOptionChain: Bool = false
    var optionChainVC: YXShareOptionsViewController?
    var isOptionChainShowing: Bool = false

    var greyFlag: Bool = false
    var greyTradingType = YXNewStockDetailStatusView.GreyTradingType.none
    var isADR: Bool = false
    var isLowADR: Bool = false

    var tempCode: String = ""

    var quoteVC: YXStockDetailQuoteVC?
    var quoteViewModel: YXStockDetailQuoteViewModel?


    //MARK:- 接口响应 及 处理相关变量（Response & Subject）
    var stockYgExitDataResponse: YXResultResponse<JSONAny>?
    var stockYgExitDataSubject = PublishSubject<Any>()
        
    var stockBondResponse: YXResultResponse<YXStockDetailBondModel>?
    var stockBondSubject = PublishSubject<Bool>()

    var optionAggravateResponse: YXResultResponse<JSONAny>?
    var optionAggravateSubject = PublishSubject<Int>()

    var shortSellResponse: YXResultResponse<YXStockShortSellModel>?
    
    var selectTabType: StockDetailViewTabType = (StockDetailViewTabType.init(rawValue: 0) ?? .news)
    
    lazy var sheet:YXBottomSheetViewTool = {
        let sheet = YXBottomSheetViewTool()
        sheet.rightBtnOnlyImage(iamge: UIImage.init(named: "nav_info"))
        sheet.rightButtonAction = {
            if let vc = UIViewController.current() as? QMUIModalPresentationViewController {
                vc.hideWith(animated: true) { (finish) in
                    YXWebViewModel.pushToWebVC(YXH5Urls.smartHelpUrl())
                }
            }
        }
        sheet.leftButtonAction = {
            if let vc = UIViewController.current() as? QMUIModalPresentationViewController {
                vc.hideWith(animated: true)
            }
        }
        sheet.titleLabel.text = YXLanguageUtility.kLang(key: "account_stock_order_title")
        return sheet
    }()
    
    //MARK: 用户权限
    var level: QuoteLevel {
        
        if self.greyFlag {
            if YXUserManager.isLogin() {
                return .level2
            } else {
                return .delay
            }
        }

        if self.stockType == .cryptos {
            return .level1
        }
        
        if let quote = self.quoteModel,
            let type2 = OBJECT_SECUSecuType2(rawValue: Int32(quote.type2?.value ?? 0)), type2 == .stLowAdr {
            return .delay
        }
        
        return YXUserManager.shared().getLevel(with: self.market)
    }
    
    var extra: YXSocketExtraQuote {
        if self.level == .usNational {
            return .usNation
        } else {
            return .none
        }
    }

    //是否是A股市场
    var isAStockMarket: Bool {
        (self.market == YXMarketType.ChinaHS.rawValue ||
            self.market == YXMarketType.ChinaSZ.rawValue ||
            self.market == YXMarketType.ChinaSH.rawValue)
    }
    
    //MARK: 股票类型
    var stockType: YXStockDetailStockType = .hkStock

    var services: Services! {
        didSet {
            bindRequestResponse()
        }
    }

    init(dataSource: [YXStockInputModel], selectIndex: Int) {
        self.dataSource = dataSource
        self.selectIndex = selectIndex

        if self.selectIndex >= self.dataSource.count {
            self.selectIndex = self.dataSource.count - 1
        }
        let input = self.dataSource[self.selectIndex]
        setCurrentDataSource(input)
    }


    //临时代码小黄条请求信号
    var tempCodeRequestSignal: Single<String?>  {

        return Single<String?>.create { [weak self] (single) -> Disposable in
            guard let `self` = self else { return Disposables.create() }

            let requestModel = YXStockDetailTempCodeRequestModel()
            requestModel.code = self.symbol

            let request = YXRequest.init(request: requestModel)
            request.startWithBlock(success: { (responseModel) in
                var text = ""
                if responseModel.code == .success {
                    if let data = responseModel.data, let str = data["text"] as? String {
                        text = str
                    }

                    if let data = responseModel.data {
                        if let code = data["tempCode"] as? String, code != self.symbol {
                            self.tempCode = code
                        } else if let code = data["originCode"] as? String, code != self.symbol {
                            self.tempCode = code
                        }
                    }
                }

                single(.success(text))
            }, failure: { (request) in
                single(.error(NSError.init(domain: "", code: -1, userInfo: nil)))
            })

            return Disposables.create()
        }
    }
    
    
    //盘口字段类型
    var detailParameters: [YXStockDetailBasicType] {

        return stockParameters()
    }

}

//MARK:- 股票切换时重置股票信息 及 变量状态重置
extension YXStockDetailViewModel {
    //股票信息 及 状态重置
    func setCurrentDataSource(_ input: YXStockInputModel) {

        self.market = input.market
        self.symbol = input.symbol
        self.name = input.name
        self.marketSymbol = String(format: "%@%@", self.market, self.symbol)

        self.type1 = input.type1

        self.type2 = input.type2

        self.type3 = input.type3

        if market == YXMarketType.HK.rawValue {
            self.exchangeType = .hk
        } else if market == YXMarketType.US.rawValue {
            self.exchangeType = .us
        } else if market == YXMarketType.ChinaHS.rawValue {
            self.exchangeType = .hs
        } else if market == YXMarketType.ChinaSZ.rawValue {
            self.exchangeType = .sz
        } else if market == YXMarketType.ChinaSH.rawValue {
            self.exchangeType = .sh
        } else if market == YXMarketType.USOption.rawValue {
            self.exchangeType = .usop
        }


        greyFlag = false
        greyTradingType = YXNewStockDetailStatusView.GreyTradingType.none
        isADR = false
        isLowADR = false

        self.quoteModel = nil
        ygExit = false

        hasOptionChain = false
        isOptionChainShowing = false

        self.quoteVC = nil
        self.quoteViewModel = nil

        self.shortSellModel = nil
    }
}

//MARK:- 处理接口响应Response
extension YXStockDetailViewModel {

    func bindRequestResponse() {
        // 月供
        stockYgExitDataResponse = {[weak self] (response) in
            switch response {
                case .success(let result, let code):
                    if code == .success, let data = result.data?.value as? [String: Any] {
                        if let isExit = data["ygStock"] as? Bool {
                            self?.ygExit = isExit
                            self?.stockYgExitDataSubject.onNext(result.data as Any)
                        }
                    }
                    break
                case .failed(_):
                    break
            }
        }

        // 获取美股债券信息
        stockBondResponse = {[weak self] (response) in
            switch response {
                case .success(let result, let code):
                    if code == .success, let _ = result.data?.bondInfo {
                        self?.stockBondSubject.onNext(true)
                    } else {
                        self?.stockBondSubject.onNext(false)
                    }
                case .failed(_):
                    self?.stockBondSubject.onNext(false)
                    break
            }
        }

        //获取期权张数
        optionAggravateResponse = {
            [weak self] (response) in
            guard let `self` = self else { return }
            switch response {
                case let .success(result, code):
                    if let code = code, code == .success, let dic = result.data?.value as? [String : Any]  {
                        if let options = dic["options"] as? [String : Any] {
                            if let count = options["total"] as? NSNumber, count.intValue > 0 {
                                self.hasOptionChain = true
                                self.optionAggravateSubject.onNext(count.intValue)
                            }
                        }
                    }

                case .failed(_):
                    break
            }
        }

        // 卖空
        shortSellResponse = {[weak self] (response) in
            switch response {
                case .success(let result, let code):
                    if code == .success, let data = result.data {
                        self?.shortSellModel = data
                    }
                    break
                case .failed(_):

                    break
            }
        }


        //
    }
}


//MARK:- 更新股票对应的子VC和titles
extension YXStockDetailViewModel {
    
    func updateTitlesAndControllers() {

        tabTypes = [.quote]
        if self.isLowADR {
            tabTypes.append(.discussions)
            tabTypes.append(.dividens)
            return
        }
        if self.stockType == .cryptos {
            return
        }
        let stocktype = self.stockType
        switch stocktype {
        case .bond:
            tabTypes.append(.financials)
            
        case .hkStock, .usStock, .sgStock:
            
            tabTypes.append(.news)
            tabTypes.append(.discussions)
            if self.market != kYXMarketSG {
                tabTypes.append(.announcements)
            }
            tabTypes.append(.financials)
            tabTypes.append(.profile)
            tabTypes.append(.dividens)
        case .stIndex:
            tabTypes.append(.news)
            tabTypes.append(.discussions)
            tabTypes.append(.constituents)
            //美股指数增加etf
            if market == YXMarketType.US.rawValue {
                tabTypes.append(.etfList)
            } else if YXStockDetailTool.isHKThreeIndex(self.quoteModel) {
                tabTypes.append(.etfList)
            }
        case .stWarrant, .stCbbc, .stInlineWarrant:
            tabTypes.append(.news)
            tabTypes.append(.announcements)
            tabTypes.append(.discussions)
        case .fund:
            tabTypes.append(.news)
            tabTypes.append(.discussions)
            if let type3 = self.quoteModel?.type3?.value, (type3 == OBJECT_SECUSecuType3.stEtf.rawValue || type3 == OBJECT_SECUSecuType3.stFundUsEtn.rawValue), (self.market == kYXMarketUS || self.market == kYXMarketHK) {
                tabTypes.append(.announcements)
                tabTypes.append(.profile)
            }
            
            if market == kYXMarketUS || market == kYXMarketSG {
                tabTypes.append(.dividens)
            }
        case .stSector:
            tabTypes.append(.constituents)
        case .stUsWarrant:
            tabTypes.append(.financials)
            tabTypes.append(.discussions)
        case .stUsStockOpt:
            tabTypes.append(.optionChain)
            break
        case .stTrustFundReit:
            tabTypes.append(.news)
            tabTypes.append(.discussions)
            tabTypes.append(.dividens)
        case .stSgWarrant, .stSgDlc:
            tabTypes.append(.news)
            tabTypes.append(.discussions)
        default:
            tabTypes.append(.discussions)
        }
    }
        
    func getSubViewController(with type: StockDetailViewTabType) -> UIViewController {
        
        switch type {
        case .quote:
            return quoteQuoteVC()
        case .news:
            return stockNewsVC()
        case .discussions:
            return discussCommentVC()
        case .announcements:
            return stockAnnouncementVC()
        case .financials:
            return stockFinancialVC()
        case .profile:
            return stockIntroduceVC()
        case .etfList:
            return etfVC()
        case .constituents:
            return stockIndustryVC()
        case .dividens:
            return dividensVC()
        case .optionChain:
            return optionStockVC()
        }
    }

    func quoteQuoteVC() -> UIViewController {

        if let vc = self.quoteVC {
            return vc
        }

        let viewModel = YXStockDetailQuoteViewModel(dataSource: self.dataSource, selectIndex: selectIndex)
        let vc = YXStockDetailQuoteVC.instantiate(withViewModel: viewModel, andServices: services, andNavigator: navigator)

        self.quoteVC = vc
        self.quoteViewModel = viewModel
        return vc
    }

    func stockNewsVC() -> UIViewController {
        let vc = YXStockDetailNewsVC()
        vc.viewModel.navigator = navigator
        vc.viewModel.symbol = symbol
        vc.viewModel.market = market
        return vc
    }

    func stockAnnouncementVC() -> UIViewController {
        let vc = YXStockDetailAnnounceVC()
        vc.viewModel.navigator = navigator
        vc.viewModel.symbol = symbol
        vc.viewModel.market = market
        vc.viewModel.name = name
        let stocktype = self.stockType
        if stocktype == .stWarrant || stocktype == .stInlineWarrant || stocktype == .stCbbc || stocktype == .fund {
            vc.isShowTotalButton = false
        }

        if YXStockDetailTool.canShowEventReminder(self.quoteModel) {
            vc.viewModel.isShowEventReminder = true
        }
        return vc
    }

    func stockFinancialVC() -> UIViewController {
        let vc = YXStockDetailFinancialVC()
        vc.viewModel.navigator = navigator
        vc.viewModel.symbol = symbol
        vc.viewModel.market = market
        return vc
    }

    //简况
    func stockIntroduceVC() -> UIViewController {

        let vc = YXStockDetailIntroduceVC()
        vc.viewModel.navigator = navigator
        vc.viewModel.symbol = symbol
        vc.viewModel.market = market
        return vc
    }
    
    func discussCommentVC() -> UIViewController {

        let viewModel = YXStockDetailDiscussViewModel.init(services: navigator, params: nil);
        viewModel.symbol = self.symbol
        viewModel.market = self.market
        viewModel.name = self.name ?? ""
        if self.stockType == .hkStock || self.stockType == .usStock || self.stockType == .shStock || self.stockType == .stIndex || self.stockType == .sgStock || self.stockType == .fund {
            // 正股和指数支持猜涨跌
            viewModel.supportGuess = true
        }
        let vc = SwiftStockDetailDiscussViewController.init(viewModel: viewModel)
        
        return vc
    }
    
    func dividensVC() -> UIViewController {
        
        let viewModel = StockDetailDividensViewModel.init(services: navigator, params: ["market" : self.market,
                                                                                        "symbol" : self.symbol]);
        let vc = StockDetailDividensViewController.init(viewModel: viewModel)
        return vc
    }

//    func stockWarrantsIntroduceVC() -> UIViewController {
//        let vc = YXStockDetailWarrantIntroduceVC()
//        vc.viewModel.navigator = navigator
//        vc.viewModel.symbol = symbol
//        vc.viewModel.market = market
//        vc.viewModel.name = self.quoteModel?.name ?? ""
//        vc.viewModel.relatedName = self.quoteModel?.underlingSEC?.name ?? ""
//        vc.viewModel.relatedSymbol = self.quoteModel?.underlingSEC?.symbol ?? ""
//        vc.viewModel.relatedMarket = self.quoteModel?.underlingSEC?.market ?? ""
//        vc.viewModel.stockType = self.stockType
//        return vc
//    }


    func stockIndustryVC() -> UIViewController {
        let vc = YXStockDetailIndustryVC()
        vc.viewModel.navigator = navigator
        if self.stockType == .stIndex {
            vc.viewModel.code = symbol + "_ALL"
            vc.viewModel.isShowBMP = true
        } else {
            vc.viewModel.code = symbol
        }
        vc.viewModel.market = market
        vc.viewModel.title = name
        vc.viewModel.isDetailIndustry = true
        vc.contentHeightBlock = {
            [weak self] height in
            guard let `self` = self else { return }
    
        }
        return vc
    }
    
    func etfVC() -> UIViewController {
        let vc = YXStockDetailIndustryVC()
        vc.viewModel.navigator = navigator
        
        if symbol == YXMarketIndex.DJI.rawValue {
            vc.viewModel.code = "HOTETFSECONDCONS_EBK00102"
        } else if symbol == YXMarketIndex.IXIC.rawValue {
            vc.viewModel.code = "HOTETFSECONDCONS_EBK00103"
        } else if symbol == YXMarketIndex.SPX.rawValue {
            vc.viewModel.code = "HOTETFSECONDCONS_EBK00101"
        } else if YXStockDetailTool.isHKThreeIndex(self.quoteModel) {
            vc.viewModel.code = symbol + "_ETF"
        }
        vc.viewModel.market = market
        vc.viewModel.title = name
        vc.viewModel.isDetailIndustry = true
        return vc
    }

    func stockBrokerAnalyzeVC() -> UIViewController? {
        var isHKVolumn = false
        if let scmType = self.quoteModel?.scmType?.value, ((scmType & 0x8) > 0 || (scmType & 0x4) > 0) {
            isHKVolumn = true
        }
        var isStock = false
        if self.stockType == .hkStock || self.stockType == .usStock || self.stockType == .shStock || self.stockType == .sgStock {
            if !self.isLowADR {
                isStock = true
            }
        }
        
        var isWarrantCbbc = false
        if self.stockType == .stCbbc || self.stockType == .stWarrant {
            isWarrantCbbc = true
        }
        let model = YXStockDetailAnalyzeViewModel.init(services: navigator, params: ["market" : self.market,
                                                                               "symbol" : self.symbol,
                                                                               "name" : self.name ?? "",
                                                                               "isHKVolumn" : NSNumber.init(booleanLiteral: isHKVolumn),
                                                                               "greyFlag" : NSNumber.init(booleanLiteral: self.greyFlag),
                                                                               "preClose" : self.quoteModel?.preClose?.value ?? 0])
        model.isStock = isStock
        model.isWarrantCbbc = isWarrantCbbc
        return YXStockDetailBrokerAnalyzeVC.init(viewModel: model)
    }

    //期权链VC
    func optionStockVC() -> UIViewController {

        var optionMarket = self.market
        var optionSymbol = self.symbol
        if self.stockType == .stUsStockOpt {
            optionMarket = self.quoteModel?.underlingSEC?.market ?? ""
            optionSymbol = self.quoteModel?.underlingSEC?.symbol ?? ""
        }
        let vm = YXShareOptionsViewModel.init(services: navigator, params: ["market": optionMarket, "code": optionSymbol])
        vm.style = .inStockDetail
        let vc = YXShareOptionsViewController.init(viewModel: vm)
        self.optionChainVC = vc
        return vc
    }

    //Fund ETF 简况VC
    func etfBriefVC() -> UIViewController {

        let vc = YXETFBriefViewController()
        vc.viewModel.navigator = self.navigator
        if let value = self.quoteModel?.type3?.value, let type3 = OBJECT_SECUSecuType3(rawValue: value) {
            vc.viewModel.type3 = type3
        }
        vc.viewModel.name = self.name ?? ""
        vc.viewModel.market = self.market
        vc.viewModel.symbol = self.symbol

        return vc
    }
}

//MARK:- 交易相关
extension YXStockDetailViewModel {
    func pushToTrade(_ type: BottomTradeExpandType) {
        // 对应大陆版文件：YXStockDetailViewModel.m  搜索pushToTrade
        if self.quoteModel != nil {
            let tradeModel = TradeModel()
            tradeModel.market = self.quoteModel?.market ?? ""
            tradeModel.symbol = self.quoteModel?.symbol ?? ""
            tradeModel.name = self.quoteModel?.name ?? ""
            tradeModel.tradeType = .normal
            
            if type == .smart {
                let viewModel = YXSmartTradeGuideViewModel(services:self.navigator, params:["tradeModel": tradeModel])
                let vc = YXSmartTradeGuideViewController(viewModel: viewModel)
                sheet.showViewController(vc: vc)
            } else if type == .fractional {
                tradeModel.tradeType = .fractional
                let viewModel = YXTradeViewModel(services: self.navigator, params: ["tradeModel": tradeModel])
                self.navigator.push(viewModel, animated: true)
            } else {
                YXTradeManager.getOrderType(market: market) { [weak self] (orderType) in
                    guard let `self` = self else { return }

                    tradeModel.tradeOrderType = orderType

                    let viewModel = YXTradeViewModel(services: self.navigator, params: ["tradeModel": tradeModel])
                    self.navigator.push(viewModel, animated: true)
                }
            }
        }
    }
    
    class func pushSafty(paramDic: [String : Any]) {
        if let root = UIApplication.shared.delegate as? YXAppDelegate {
            root.navigator.push(YXModulePaths.stockDetail.url, context: paramDic)
        }
    }
}


extension YXStockDetailViewModel {

    func requestNewDiscuss() -> Single<Bool> {
        return Single<Bool>.create { [weak self] (single) -> Disposable in
            guard let `self` = self else { return Disposables.create() }

            let requestModel = YXNewDiscussRequestModel()
            requestModel.stock_id = self.market + self.symbol

            let request = YXRequest.init(request: requestModel)
            request.startWithBlock(success: { (responseModel) in

                if responseModel.code == .success, let data = responseModel.data {
                    if let hasNew = data["has_new_post"] as? Bool {
                        single(.success(hasNew))
                    } else if let hasNew = data["has_new_post"] as? NSNumber {
                        single(.success(hasNew.intValue > 0 ? true : false))
                    } else {
                        single(.success(false))
                    }
                } else {
                    single(.success(false))
                }
            }, failure: { (request) in
                single(.error(NSError.init(domain: "", code: -1, userInfo: nil)))
            })

            return Disposables.create()
        }
    }
}

//MARK: - 股票盘口字段处理
extension YXStockDetailViewModel {

    func stockParameters() -> [YXStockDetailBasicType] {
        switch self.stockType {
            case .hkStock:
                return [.high, .now, .volume,
                        .low, .pclose, .amount,
                        .marketValue, .peTTM, .highP1Y,
                        .total, .pe, .lowP1Y,
                        .circulationValue, .pb, .cittthan,
                        .share, .turnoverRate, .volumeRatio,
                        .amp, .dividend, .gx,
                        .tradingUnit, .historyHigh, .historyLow,
                        .avg]
                
            case .usStock, .stUsWarrant, .sgStock: //正股

                var arr: [YXStockDetailBasicType] = [.high, .now, .volume,
                                                     .low, .pclose, .amount,
                                                     .marketValue, .peTTM, .highP1Y,
                                                     .total, .pe, .lowP1Y,
                                                     .circulationValue, .pb, .cittthan,
                                                     .share, .turnoverRate, .volumeRatio,
                                                     .amp, .dividend, .gx,
                                                     .tradingUnit, .historyHigh, .historyLow,
                                                     .avg]
                        
                if isADR || self.isLowADR  {
                    arr = arr + [ .conversionRatio ]
                }
                        
                if self.market == YXMarketType.SG.rawValue {
                    arr = arr + [ .currency ]
                }
                

                return arr

            case .shStock:
                var arr: [YXStockDetailBasicType] = [ .high, .now, .volume,
                                                      .low, .pclose, .amount,
                                                      .marketValue, .peTTM, .highP1Y,
                                                      .total, .pe, .lowP1Y,
                                                      .circulationValue, .pb, .cittthan,
                                                      .share, .turnoverRate, .volumeRatio,
                                                      .upperLimit, .lowerLimit, .amp,
                                                      .historyHigh, .historyLow, .avg]
                if let sector = self.quoteModel?.listSector?.value {
                    if sector == OBJECT_MARKETListedSector.lsGemb.rawValue {
                        arr = [ .high, .now, .volume,
                                .low, .pclose, .amount,
                                .marketValue, .peTTM, .highP1Y,
                                .total, .pe, .lowP1Y,
                                .circulationValue, .pb, .cittthan,
                                .share, .turnoverRate, .volumeRatio,
                                .upperLimit, .lowerLimit, .amp,
                                .historyHigh, .historyLow, .avg,
                                .postVolume, .profitable, .votingRights,
                                .postAmount, .controlArc, .register]
                        
                    } else if sector == OBJECT_MARKETListedSector.lsStar.rawValue {
                        arr = [ .high, .now, .volume,
                                .low, .pclose, .amount,
                                .marketValue, .peTTM, .highP1Y,
                                .total, .pe, .lowP1Y,
                                .circulationValue, .pb, .cittthan,
                                .share, .turnoverRate, .volumeRatio,
                                .upperLimit, .lowerLimit, .amp,
                                .historyHigh, .historyLow, .avg,
                                .postVolume, .profitable, .SharesEqualRights,
                                .postAmount]
                        
            
                    }

                }
                return arr
            case .stSector:
                return [ .high, .now, .volume,
                         .low, .pclose, .amount,
                         .marketValue, .pe, .volumeRatio,
                         .circulationValue, .turnoverRate, .amp,
                         .up, .unchange, .down]
            case .stIndex: //指数
                if self.market == YXMarketType.US.rawValue {
                    return [ .high, .now, .volume,
                             .low, .pclose, .volumeRatio,
                             .highP1Y, .lowP1Y, .amp,
                             .up, .unchange, .down]
                } else if self.market == YXMarketType.HK.rawValue {
                    return [ .high, .now, .amount,
                             .low, .pclose, .volumeRatio,
                             .highP1Y, .lowP1Y, .amp,
                             .up, .unchange, .down]
                } else {
                    return [ .high, .now, .amount,
                             .low, .pclose, .volumeRatio,
                             .highP1Y, .lowP1Y, .amp,
                             .up, .unchange, .down]
                }
            case .fund: //ETF

                var arr: [YXStockDetailBasicType] = []
            
                if self.market == YXMarketType.US.rawValue {
                    arr = [.high, .now, .volume,
                           .low, .pclose, .amount,
                           .marketValue, .peTTM, .highP1Y,
                           .total, .pe, .lowP1Y,
                           .circulationValue, .pb, .cittthan,
                           .share, .turnoverRate, .volumeRatio,
                           .amp, .dividend, .gx,
                           .tradingUnit]
                
                } else if self.market == YXMarketType.HK.rawValue {
                    arr =  [.high, .now, .volume,
                            .low, .pclose, .amount,
                            .marketValue, .peTTM, .highP1Y,
                            .total, .pe, .lowP1Y,
                            .circulationValue, .pb, .cittthan,
                            .share, .turnoverRate, .volumeRatio,
                            .amp, .dividend, .gx,
                            .tradingUnit]
                } else if self.market == YXMarketType.SG.rawValue {
                    arr =  [.high, .now, .volume,
                            .low, .pclose, .amount,
                            .dividend, .totalAsset, .highP1Y,
                            .gx, .circulation, .lowP1Y,
                            .turnoverRate,.volumeRatio, .historyHigh,
                            .currency, .cittthan, .historyLow,
                            .premium, .amp, .tradingUnit
                            ]
                    return arr
                } else {
                    arr = [ .high, .now, .volume,
                            .low, .pclose, .amount,
                            .highP1Y, .amp, .upperLimit,
                            .lowP1Y, .marketValue, .lowerLimit]
                }

                if let type3 = self.quoteModel?.type3?.value, (type3 == OBJECT_SECUSecuType3.stEtf.rawValue || type3 == OBJECT_SECUSecuType3.stFundUsEtn.rawValue) {

                    if self.market == YXMarketType.US.rawValue {
                        arr = arr + [.navPs, .premium, .totalAsset, .currency]
                    } else {
                        arr = arr + [.navPs, .premium, .assetType, .totalAsset]
                    }
                }

                return arr

            case .stWarrant:
                return [ .high, .now, .volume,
                         .low, .pclose, .amount,
                         .outstanding_pct, .premium, .effgearing,
                         .outstandingQty, .convertPrice, .impliedVolatility,
                         .delta, .conversionRatio, .maturity_date,
                         .strike, .gearing, .last_trade_day,
                         .breakevenPoint, .tradingUnit]
                
            case .stCbbc:
                return [ .high, .now, .volume,
                         .low, .pclose, .amount,
                         .outstanding_pct, .premium, .callPrice,
                         .outstandingQty, .convertPrice, .diffRatio,
                         .moneyness, .conversionRatio, .maturity_date,
                         .strike, .gearing, .last_trade_day,
                         .breakevenPoint, .tradingUnit]
                
            case .bond:
                if self.market == kYXMarketHK {
                    return  [.high, .now, .volume,
                             .low, .pclose, .amount,
                             .marketValue, .peTTM, .highP1Y,
                             .total, .pe, .lowP1Y,
                             .circulationValue, .pb, .cittthan,
                             .share, .turnoverRate, .volumeRatio,
                             .amp, .dividend, .gx,
                             .tradingUnit, .historyHigh, .historyLow,
                             .avg]
                    
                } else if self.market == kYXMarketHK {
                    return  [.high, .now, .volume,
                             .low, .pclose, .amount,
                             .marketValue, .peTTM, .highP1Y,
                             .total, .pe, .lowP1Y,
                             .circulationValue, .pb, .cittthan,
                             .share, .turnoverRate, .volumeRatio,
                             .amp, .dividend, .gx,
                             .tradingUnit, .historyHigh, .historyLow,
                             .avg]
                } else {
                    return [ .high, .now, .volume,
                             .low, .pclose, .amount,
                             .marketValue, .peTTM, .highP1Y,
                             .total, .pe, .lowP1Y,
                             .circulationValue, .pb, .cittthan,
                             .share, .turnoverRate, .volumeRatio,
                             .upperLimit, .lowerLimit, .amp,
                             .historyHigh, .historyLow, .avg]
                }
            case .stInlineWarrant:
                return [ .high, .now, .volume,
                         .low, .pclose, .amount,
                         .outstanding_pct, .upperStrike, .lowerStrike,
                         .outstandingQty, .toUpperStrike, .toLowerStrike,
                         .tradingUnit, .conversionRatio, .maturity_date,
                         .last_trade_day]

            case .stUsStockOpt: //美股期权

                return [ .high, .now, .volume,
                         .low, .pclose, .amount,
                         .strike, .openInt, .expDate,
                         .optionImpliedVolatility, .contractSize, .exerciseStyle,
                         .optionDelta, .gamma, .vega,
                         .theta, .rho]
            case .cryptos: //数字货币

                return [ .high24, .open24,   .high52w,
                         .low24,  .volume24, .low52w,
                         .amount24]
            case .stSgDlc: //每日杠杆证书
                return [.high, .now, .volume,
                        .low, .pclose, .amount,
                        .highP1Y, .maturity_date, .amp,
                        .lowP1Y,.volumeRatio, .currency,
                        .historyHigh, .cittthan, .wc_trading_unit,
                        .historyLow]
            case .stTrustFundReit:
                return [.high, .now, .volume,
                        .low, .pclose, .amount,
                        .marketValue, .peTTM, .turnoverRate,
                        .circulationValue, .epsTTM, .highP1Y,
                        .total, .pe, .lowP1Y,
                        .share, .eps, .historyHigh,
                        .dividend, .pb, .historyLow,
                        .gx, .amp, .wc_trading_unit,
                        .volumeRatio, .cittthan , .currency]
        case .stSgWarrant: //sg涡轮
            return [ .high, .now, .volume,
                     .low, .pclose,.amount,
                     .effgearing, .convertPrice, .premium,
                     .gearing, .conversionRatio, .delta,
                     .impliedVolatility, .breakevenPoint, .strike,
                     .wc_trading_unit, .maturity_date, .last_trade_day, .currency,
                    ]
        }
    }
}
