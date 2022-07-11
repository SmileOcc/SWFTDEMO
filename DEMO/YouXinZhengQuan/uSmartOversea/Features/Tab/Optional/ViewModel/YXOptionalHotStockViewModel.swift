//
//  YXOptionalHotStockViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/6/30.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import YXKit
import RxSwift

class YXOptionalHotStockViewModel: NSObject {

    @objc var currentOffset: Int = 0
    var quoteRequest: YXQuoteRequest?
    var hkIndexRequest: YXQuoteRequest?
    var usIndexRequest: YXQuoteRequest?
    var cnIndexRequest: YXQuoteRequest?
    var secuArray: [Secu] = []
    var currentMarket: String = kYXMarketHK
    var hotStockModel: YXOptionalHotStockModel?
    let hotStockSubject = PublishSubject<(YXOptionalHotStockModel?, Bool)>()
    let indexSubject = PublishSubject<[YXV2Quote]>()
    let singleSubject = PublishSubject<YXV2Quote>()

    var hkIndexDataSource: [YXV2Quote] =  [YXV2Quote(), YXV2Quote(), YXV2Quote()]
    var usIndexDataSource: [YXV2Quote] =  [YXV2Quote(), YXV2Quote(), YXV2Quote()]
    var cnIndexDataSource: [YXV2Quote] =  [YXV2Quote(), YXV2Quote(), YXV2Quote()]

    var isSingle: Bool = true


    @objc func requestQuoteData(isSingle: Bool) {

        self.cancelQuoteRequest()
        self.isSingle = isSingle
        if isSingle {
            requestSingleIndexQuote()
        } else {
            requestHKIndexData()
            requestUSIndexData()
            requestCNIndexData()

            requestHotStockQuoteInfo()
        }
    }

    @objc func cancelQuoteRequest() {

        hkIndexRequest?.cancel()
        hkIndexRequest = nil

        usIndexRequest?.cancel()
        usIndexRequest = nil

        cnIndexRequest?.cancel()
        cnIndexRequest = nil

        quoteRequest?.cancel()
        quoteRequest = nil
    }

    @objc func requestSingleIndexQuote() {

        if let hotStocks = self.hotStockModel?.hot_stocks, let market = hotStocks.first?.market {
            if market == kYXMarketHK {
                requestHKIndexData()
            } else if market == kYXMarketUS {
                requestUSIndexData()
            } else {
                requestCNIndexData()
            }
        }
    }


    lazy var hkIndexs: [Secu] = {
        let market = YXMarketType.HK.rawValue
        // 恒生
        let HSI = Secu.init(market: market, symbol: YXMarketIndex.HSI.rawValue)
        // 国企
        let HSCEI = Secu.init(market: market, symbol: YXMarketIndex.HSCEI.rawValue)
        // 红筹
        let HSCCI = Secu.init(market: market, symbol: YXMarketIndex.HSCCI.rawValue)

        return [HSI, HSCEI, HSCCI]
    }()

    lazy var usIndexs: [Secu] = {
        let market = YXMarketType.US.rawValue
        // 道琼斯指数
        let DIA = Secu.init(market: market, symbol: YXMarketIndex.DIA.rawValue)
        // 纳指100ETF
        let QQQ = Secu.init(market: market, symbol: YXMarketIndex.QQQ.rawValue)
        // 标普500指数
        let SPY = Secu.init(market: market, symbol: YXMarketIndex.SPY.rawValue)

        return [DIA, QQQ, SPY]
    }()

    lazy var chinaIndexs: [Secu] = {
        // 上证指数
        let HSSSE = Secu.init(market: YXMarketType.ChinaSH.rawValue, symbol: YXMarketIndex.HSSSE.rawValue)
        // 深证指数
        let HSSZSE = Secu.init(market: YXMarketType.ChinaSZ.rawValue, symbol: YXMarketIndex.HSSZSE.rawValue)
        // 创业板指
        let HSGEM = Secu.init(market: YXMarketType.ChinaSZ.rawValue, symbol: YXMarketIndex.HSGEM.rawValue)

        return [HSSSE, HSSZSE, HSGEM]
    }()

}

//MARK: Hot Stock Method
extension YXOptionalHotStockViewModel {

    @objc func resetHotStock() {
        currentOffset = 0
        quoteRequest?.cancel()
        quoteRequest = nil
        //secuArray = []
    }

    @objc func requestHotStockData() {

//        let requestModel = YXOptionalHotStockRequestModel()
//        requestModel.offset = self.currentOffset
//        let request = YXRequest.init(request: requestModel)
//        request.startWithBlock(success: { [weak self] (responseModel) in
//            guard let `self` = self else { return }
//            if responseModel.code == YXResponseStatusCode.success,
//                let data = responseModel.data {
//                let model = YXOptionalHotStockModel.yy_model(withJSON: data)
//                self.currentOffset = model?.next_offset ?? 0
//                self.currentMarket = model?.hot_stocks?.first?.market ?? kYXMarketHK
//
//                if self.hotStockModel == nil && self.isSingle {
//                    self.hotStockModel = model
//                    self.requestQuoteData(isSingle: true)
//                } else {
//                    self.hotStockModel = model
//                }
//                self.mergeIndexToHotStock()
//                self.hotStockSubject.onNext((self.hotStockModel, false))
//                var tempSecuArray: [Secu] = []
//                if let hotStocks = model?.hot_stocks {
//                    for info in hotStocks {
//                        let secu = Secu(market: info.market, symbol: info.symbol)
//                        tempSecuArray.append(secu)
//                    }
//                }
//                self.secuArray = tempSecuArray
//                if !self.isSingle {
//                    self.requestHotStockQuoteInfo()
//                }
//            } else {
//                self.hotStockSubject.onNext((nil, false))
//            }
//            }, failure: { [weak self] (tkRequest) in
//                self?.hotStockSubject.onNext((nil, false))
//        })
    }

    @objc func requestHotStockQuoteInfo() {

        guard secuArray.count > 0 else {
            return
        }

        var level = YXUserManager.shared().getLevel(with: self.currentMarket)
        if level == .bmp {
            level = .delay
        }

        quoteRequest?.cancel()
        quoteRequest = YXQuoteManager.sharedInstance.subRtSimpleQuote(secus: secuArray, level: level, handler: { [weak self] (quotes, scheme) in
            guard let `self` = self else { return }

            if let hotStocks = self.hotStockModel?.hot_stocks, hotStocks.count > 0 {

                for quote in quotes {
                    for model in hotStocks {
                        if quote.market == model.market, quote.symbol == model.symbol {

                            if let value = quote.pctchng?.value {
                                model.roc = String(value)
                            } else {
                                model.roc = ""
                            }
                        }
                    }
                }
                self.hotStockSubject.onNext((self.hotStockModel, true))
            }

        })

    }



}


//MARK: Index Method
extension YXOptionalHotStockViewModel {

    func requestHKIndexData() {
        var level = YXUserManager.shared().getLevel(with: YXMarketType.HK.rawValue)
        if level == .bmp {
            level = .delay
        }
        hkIndexRequest?.cancel()
        hkIndexRequest = YXQuoteManager.sharedInstance.subRtSimpleQuote(secus: hkIndexs, level: level, handler: { [weak self](list, scheme) in
            guard let `self` = self else { return }
            var indexDataSource = self.hkIndexDataSource
            if scheme == .http {
                for item in list {
                    if item.market == YXMarketType.HK.rawValue, item.symbol == YXMarketIndex.HSI.rawValue {
                        indexDataSource[0] = item
                    }else if item.market == YXMarketType.HK.rawValue, item.symbol == YXMarketIndex.HSCEI.rawValue {
                        indexDataSource[1] = item
                    }else if item.market == YXMarketType.HK.rawValue, item.symbol == YXMarketIndex.HSCCI.rawValue {
                        indexDataSource[2] = item
                    }
                }
                self.hkIndexDataSource = indexDataSource
                self.handleIndexData()

            } else if scheme == .tcp {

                if let quote = list.first {
                    for (index, item) in indexDataSource.enumerated() {
                        if quote.symbol == item.symbol, quote.market == item.market {
                            indexDataSource[index] = quote
                            self.hkIndexDataSource = indexDataSource
                            break
                        }
                    }
                    self.handleIndexData()
                }
            }
        })

    }

    func requestUSIndexData() {
        let level = YXUserManager.shared().getUsaThreeLevel()
        usIndexRequest?.cancel()
        usIndexRequest = YXQuoteManager.sharedInstance.subRtSimpleQuote(secus: usIndexs, level: level, handler: { [weak self](list, scheme) in
            guard let `self` = self else { return }
            var indexDataSource = self.usIndexDataSource
            if scheme == .http {
                for item in list {
                    if item.market == YXMarketType.US.rawValue, item.symbol == YXMarketIndex.DIA.rawValue {
                        indexDataSource[0] = item
                    }else if item.market == YXMarketType.US.rawValue, item.symbol == YXMarketIndex.QQQ.rawValue {
                        indexDataSource[1] = item
                    }else if item.market == YXMarketType.US.rawValue, item.symbol == YXMarketIndex.SPY.rawValue {
                        indexDataSource[2] = item
                    }
                }
                self.usIndexDataSource = indexDataSource
                self.handleIndexData()

            } else if scheme == .tcp {

                if let quote = list.first {
                    for (index, item) in indexDataSource.enumerated() {
                        if quote.symbol == item.symbol, quote.market == item.market {
                            indexDataSource[index] = quote
                            self.usIndexDataSource = indexDataSource
                            break
                        }
                    }
                    self.handleIndexData()
                }
            }
        })

    }

    func requestCNIndexData() {
        let level = YXUserManager.shared().getLevel(with: YXMarketType.ChinaHS.rawValue)
        cnIndexRequest?.cancel()
        cnIndexRequest = YXQuoteManager.sharedInstance.subRtSimpleQuote(secus: chinaIndexs, level: level, handler: { [weak self](list, scheme) in
            guard let `self` = self else { return }
            var indexDataSource = self.cnIndexDataSource
            if scheme == .http {
                for item in list {
                    if item.market == YXMarketType.ChinaSH.rawValue, item.symbol == YXMarketIndex.HSSSE.rawValue {
                        indexDataSource[0] = item
                    }else if item.market == YXMarketType.ChinaSZ.rawValue, item.symbol == YXMarketIndex.HSSZSE.rawValue {
                        indexDataSource[1] = item
                    }else if item.market == YXMarketType.ChinaSZ.rawValue, item.symbol == YXMarketIndex.HSGEM.rawValue {
                        indexDataSource[2] = item
                    }
                }
                self.cnIndexDataSource = indexDataSource
                self.handleIndexData()
            } else if scheme == .tcp {

                if let quote = list.first {
                    for (index, item) in indexDataSource.enumerated() {
                        if quote.symbol == item.symbol, quote.market == item.market {
                            indexDataSource[index] = quote
                            self.cnIndexDataSource = indexDataSource
                            break
                        }
                    }
                    self.handleIndexData()
                }
            }
        })

    }


    func handleIndexData() {

        var dataSource: [YXV2Quote] = []

        dataSource += self.hkIndexDataSource
        dataSource += self.usIndexDataSource
        dataSource += self.cnIndexDataSource

        self.mergeIndexToHotStock()
        self.indexSubject.onNext(dataSource)
    }


    func mergeIndexToHotStock() {

        if let hotStocks = self.hotStockModel?.hot_stocks, let market = hotStocks.first?.market {
            var quoteModel: YXV2Quote?
            if market == kYXMarketHK {

                quoteModel = hkIndexDataSource.first
            } else if market == kYXMarketUS {

                quoteModel = usIndexDataSource.first
            } else {

                quoteModel = cnIndexDataSource.first
            }

            if let model = quoteModel {
                self.singleSubject.onNext(model)
            }
        }
    }
}

