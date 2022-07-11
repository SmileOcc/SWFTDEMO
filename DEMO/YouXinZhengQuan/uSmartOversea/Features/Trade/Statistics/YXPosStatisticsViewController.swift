//
//  YXStatisticsViewController.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2022/2/14.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import Foundation
import SwiftyJSON

@objcMembers class YXPosStatisticsViewModel: YXViewModel {

}

@objcMembers class YXPosStatisticsViewController: YXViewController {
    
    var quoteModel: YXV2Quote? {
        didSet {
            if quoteModel != nil {
                posStatisticsView.isHidden = false
                posStatisticsView.quote = quoteModel
                
                loadPosBrokerData()
                loadDepthTradeData()
                loadDepthChartData()
            } else {
                posStatisticsView.isHidden = true
            }
            contentScrollView.reloadEmptyDataSet()
        }
    }
    
    var scrollCallBack: YXTabPageScrollBlock?
    
    lazy var contentScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = QMUITheme().foregroundColor()
        scrollView.delegate = self
        scrollView.emptyDataSetDelegate = self
        scrollView.emptyDataSetSource = self

        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            scrollView.contentInset = .zero
        }
        scrollView.delaysContentTouches = false
        scrollView.showsHorizontalScrollIndicator = false

        return scrollView
    }()
    
    var depthOrderRequest: YXQuoteRequest?
    var depthChartRequest: YXQuoteRequest?
    var posBrokerRequest: YXQuoteRequest?

    var tapBlock: (([String: Any])->Void)?

    lazy var posStatisticsView: YXPosStatisticsView = {
        let view = YXPosStatisticsView.init()
        view.depthOrderView.isTrade = true
        view.backgroundColor = QMUITheme().foregroundColor()
        
        view.heightDidChange = { [weak self] in
            guard let `self` = self else { return }
            self.posStatisticsView.snp.updateConstraints { (make) in
                make.height.equalTo(self.posStatisticsView.height)
            }
        }
        
        view.depthOrderView.settingChangeBlock = {
            [weak self] type in
            guard let `self` = self else { return }

            if type == .combineSamePrice {
                self.loadDepthTradeData()
            } else if type == .priceDistribution {
                
                if YXStockDetailUtility.showDepthTradePriceDistribution() {
                    self.loadDepthChartData()
                } else {
                    self.depthChartRequest?.cancel()
                    self.depthChartRequest = nil
                }
                
//                if self.depthOrderView.contentHeight != self.depthOrderView.totalHeight {
//                    self.updateDepthOrderView(self.viewModel.quoteModel)
//                }
            }
        }
        
        view.tapBlock = { [weak self] priceString, number in
            guard let `self` = self else { return }

            var mutDic: [String: Any] = [:]
                       if let string = priceString, string.count > 0 {
                        mutDic["price"] = string
                       }
            mutDic["number"] = number
            self.tapBlock?(mutDic)
        }
        
        view.clickItemBlock = { [weak self] type in
            self?.loadPosBrokerData()
        }
        
        return view
    }()
    
    func loadPosBrokerData() {
        guard let quote = quoteModel, YXStockDetailTool.isShowAskBid(quote) else { return }
        posBrokerRequest?.cancel()

        var level = QuoteLevel(rawValue: Int(quote.level?.value ?? 0)) ?? .delay
        var extra = quote.extraType()
        let type = YXStockDetailUtility.getUsAskBidSelect()
        if extra == .usNation && type == .nsdq {
            // 在全美行情下, 选择了纳斯达克, 就设置为none
            extra = .none
            level = .level1
        }

        posBrokerRequest = YXQuoteManager.sharedInstance.subPosAndBroker(secu: Secu(market: quote.market ?? "", symbol: quote.symbol ?? "", extra: extra), level: level, handler: { [weak self] posBroker, scheme in
            guard let `self` = self else { return }
            
            //买卖档经纪商名称匹配
            func configBroker(_ posBroker: PosBroker?) {
                if let posBroker = posBroker {
                    if let list = posBroker.brokerData?.askBroker {
                        for model in list {
                            if let code = model.Id, code.count > 0 {
                                model.Name = self.brokerDic[code]
                            }
                        }
                    }

                    if let list = posBroker.brokerData?.bidBroker {
                        for model in list {
                            if let code = model.Id, code.count > 0 {
                                model.Name = self.brokerDic[code]
                            }
                        }
                    }
                }
            }
            if scheme == .tcp {
                configBroker(posBroker)
                self.posBrokerFilter.onNext(posBroker)
            } else {
                configBroker(posBroker)
                self.updatePosBrokerData(posBroker)
            }
        })
    }
    
    
    func loadDepthTradeData() {
        if let quote = quoteModel, YXStockDetailTool.showDepthOrder(quote) {

            depthOrderRequest?.cancel()

            let type: Int = quote.market == kYXMarketSG ? 10 : 1
            depthOrderRequest = YXQuoteManager.sharedInstance.subDepthOrder(secu: Secu(market: quote.market ?? "", symbol: quote.symbol ?? ""), type: type, depthType: (YXStockDetailUtility.showDepthTradeCombineSamePrice() ? .merge : .none)) { [weak self] model, scheme in
                guard let `self` = self else { return }
                self.depthOrderTcpFilter.onNext(model)
            }
        }
    }
    
    func loadDepthChartData() {
        if let quote = quoteModel, YXStockDetailTool.showDepthOrder(quote), YXStockDetailUtility.showDepthTradePriceDistribution() {

            depthChartRequest?.cancel()
            let type: Int = quote.market == kYXMarketSG ? 10 : 1
            depthChartRequest = YXQuoteManager.sharedInstance.subDepthOrder(secu: Secu(market: quote.market ?? "", symbol: quote.symbol ?? ""), type: type, depthType: .chart) { [weak self] model, scheme in
                guard let `self` = self else { return }

                self.depthChartTcpFilter.onNext(model)

            }
        }
    }
    
    func updatePosBrokerData(_ posBroker: PosBroker) {
//        if posBroker.pos != nil {
//            self.headerView.parameterView.updateCittenValue(posBroker)
//        }
        self.posStatisticsView.posBroker = posBroker
    }

    
    lazy var posBrokerFilter: YXStockDetailTcpFilter<PosBroker> = {

        let filter = YXStockDetailTcpFilter<PosBroker>(interval: 0.3) { [weak self] posBroker in
            guard let `self` = self else { return }
            self.updatePosBrokerData(posBroker)
        }
    
        return filter
    }()
    
    
    lazy var depthOrderTcpFilter: YXStockDetailTcpFilter<YXDepthOrderData> = {

        let filter = YXStockDetailTcpFilter<YXDepthOrderData>(interval: 0.3) { [weak self] tickModel in
            guard let `self` = self else { return }
            self.posStatisticsView.depthOrderView.model = tickModel
        }
        
        return filter
    }()
    
    lazy var depthChartTcpFilter: YXStockDetailTcpFilter<YXDepthOrderData> = {

        let filter = YXStockDetailTcpFilter<YXDepthOrderData>(interval: 0.3) { [weak self] tickModel in
            guard let `self` = self else { return }
            self.posStatisticsView.depthOrderView.chartModel = tickModel
        }
        return filter
    }()
    
    lazy var brokerDic: [String: String] = {
        var dic = [String: String]()
        let data = MMKV.default().data(forKey: brokerListPath)
        if let data = data, let json = try? JSON(data: data) {
            if let arr = json["broker_list"].arrayObject {
                for model in arr {
                    let subJson = JSON.init(model)
                    var loacalId = subJson["broker_code"].stringValue
                    let ids = loacalId.components(separatedBy: ",")
                    var name = ""
                    //泰语、马来语先用英文
                    if YXUserManager.isENMode() {
                        name = subJson["english_abb_name"].stringValue
                    } else if YXUserManager.curLanguage() == .CN {
                        name = subJson["simplified_abb_name"].stringValue
                    } else {
                        name = subJson["traditional_abb_name"].stringValue
                    }
                    
                    for str in ids {
                        let tempId = str.replacingOccurrences(of: " ", with: "")
                        if str.count > 0 {
                            dic[tempId] = name
                        }
                    }
                }
            }
        }
        return dic
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(contentScrollView)
        contentScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentScrollView.addSubview(posStatisticsView)
        posStatisticsView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(view)
            make.height.equalTo(posStatisticsView.height)
        }
        
        posStatisticsView.isHidden = true
        contentScrollView.reloadEmptyDataSet()
    }

}


extension YXPosStatisticsViewController: YXTabPageScrollViewProtocol, UIScrollViewDelegate {
    func pageScrollView() -> UIScrollView {
        contentScrollView
    }
    
    func pageScrollViewDidScrollCallback(_ callback: @escaping YXTabPageScrollBlock) {
        scrollCallBack = callback
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollCallBack?(scrollView)
    }
}

extension YXPosStatisticsViewController: DZNEmptyDataSetDelegate {
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return quoteModel == nil
    }
}

extension YXPosStatisticsViewController: DZNEmptyDataSetSource {
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        UIImage(named: "empty_noData")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        NSAttributedString(string: YXLanguageUtility.kLang(key: "trading_no_ask_bid_data"), attributes: [.foregroundColor: QMUITheme().textColorLevel3(), .font: UIFont.systemFont(ofSize: 14)])
    }
}
