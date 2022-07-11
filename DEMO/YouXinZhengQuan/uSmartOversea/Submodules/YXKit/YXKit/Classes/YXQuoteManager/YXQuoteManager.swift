//
//  YXQuoteManager.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2019/8/28.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import Moya
import RxSwift

extension YXSocketGreyMarketType {
    var extra: YXSocketExtraQuote {
        if self == .futu {
            return .futu
        } else {
            return .none
        }
    }
}

@objcMembers public class Secu: NSObject {
    public let market: String
    public let symbol: String
    public var extra: YXSocketExtraQuote = .none
    
    public convenience init(market: String, symbol: String) {
        self.init(market: market, symbol: symbol, extra: .none)
    }
    
    public init(market: String, symbol: String, extra: YXSocketExtraQuote = .none) {
        self.market = market
        self.symbol = symbol
        self.extra = extra
    }
    
    public static func == (lhs: Secu, rhs: Secu) -> Bool {
//         && lhs.extra == rhs.extra
        return lhs.market == rhs.market && lhs.symbol == rhs.symbol
    }
    
    public override var hash: Int {
        return market.hashValue ^ symbol.hashValue
    }
    
    @objc public var stringValue: String {
        return market + symbol
    }

    @objc public var dictionaryValue: [String : Any] {
        //1、辉立，2：富途，默认是辉立
        var greyMarket = 1
        if self.extra == .futu {
            greyMarket = 2
        }
        return ["market" : market, "symbol" : symbol, "greyMarket" : self.greyMarketValue]
    }
    
    @objc public var greyMarketValue: Int {
        var greyMarket = 1
        if self.extra == .futu {
            greyMarket = 2
        }
        return greyMarket
    }
}

@objc public enum QuoteType: UInt32, Codable {
    case intraDay = 0   //日内
    case grey = 1       //暗盘全日, 港股
    case greyHalf = 2   //暗盘半日, 港股
    case star = 3       //科创板日内, A股
    case pre = 4        //盘前, 美股
    case after = 5      //盘后, 美股
    case sQuoteAll = 6  //全部的分时
}

typealias YXQuoteFlag = YXTimerFlag

@objcMembers public class YXQuoteRequest: NSObject {
    fileprivate var quoteFlag: YXQuoteFlag = 0
    fileprivate var seqFlag: YXSocketSeqFlag = 0
    fileprivate var extFlag: YXTimerFlag = 0
    fileprivate var scheme: Scheme = .none
    fileprivate var secus: [Secu] = []
    fileprivate var subType: SubType = .none
    fileprivate var level: QuoteLevel = .delay
    fileprivate var api: YXV2QuotesDataAPI?
    fileprivate var dispose: Disposable?
    fileprivate var rtHandler: RtHandler?
    fileprivate var timeLineHandler: TimeLineHandler?
    fileprivate var kLineHandler: KLineHandler?
    fileprivate var batchTimeLineHandler: BatchTimeLineHandler?
    fileprivate var batchKLineHandler: BatchKLineHandler?
    fileprivate var tickHandler: TickHandler?
    fileprivate var statisticalHandler: StatisticalHandler?
    fileprivate var depthOrderHandler: DepthOrderHandler?
    fileprivate var posBrokerHandler: PosBrokerHandler?
    fileprivate var quoteType: QuoteType = .intraDay
    
    public func cancel() {
        YXQuoteManager.sharedInstance.remove(self)
    }
    
    deinit {
        cancel()
    }
    
    @objc public func nextTick(succeed: NoMoreHandler?, failed: FailedHandler?) {
        if self.quoteType == .sQuoteAll {
            YXQuoteManager.sharedInstance.nextFullTick(self, succeed: succeed, failed: failed)
        } else {
            YXQuoteManager.sharedInstance.nextTick(self, succeed: succeed, failed: failed)
        }
    }
    
    @objc public func nextKLine(succeed: NoMoreHandler?, failed: FailedHandler?) {
        YXQuoteManager.sharedInstance.nextKLine(self, succeed: succeed, failed: failed)
    }
}

@objc public enum Scheme: Int {
    case none
    case http
    case tcp
}

@objc public enum SubType: Int {
    case none
    case rtFull
    case rtSimple
    case batchTimeLine
    case timeLine
    case kLine
    case tick
    case statistic
    case newStatistic
    case batchKLine
    case depthOrder
    case depthChart
    case posBroker
}

public typealias FailedHandler = () -> Void
public typealias NoMoreHandler = (Bool) -> Void

public typealias RtHandler = ([YXV2Quote], Scheme) -> Void
public typealias BatchTimeLineHandler = ([YXBatchTimeLine]) -> Void
public typealias BatchKLineHandler = ([YXKLineData]) -> Void
public typealias TimeLineHandler = (YXTimeLineData, Scheme) -> Void
public typealias KLineHandler = (YXKLineData, Scheme) -> Void
public typealias TickHandler = (YXTickData, Scheme) -> Void
public typealias StatisticalHandler = (YXAnalysisStatisticData, Scheme) -> Void
public typealias DepthOrderHandler = (YXDepthOrderData, Scheme) -> Void
public typealias PosBrokerHandler = (PosBroker, Scheme) -> Void

@objcMembers public class YXQuoteManager: NSObject, YXRequestable {
    @objc public static let sharedInstance = YXQuoteManager()

    public typealias API = YXV2QuotesDataAPI
    
    public var networking: MoyaProvider<API> {
        return v2quoteProvider
    }
    
    fileprivate var requestPool = [YXQuoteFlag: YXQuoteRequest]()
    
    fileprivate var rtDataPool = [String: YXV2Quote]()
    fileprivate var tsDataPool = [String: YXTimeLineData]()
    fileprivate var fullTsDataPool = [String: YXFullTimeLineData]()
    fileprivate var klDataPool = [String: YXKLineData]()
    fileprivate var tkDataPool = [String: YXTickData]()
    fileprivate var fullTkDataPool = [String: YXTickData]()
    fileprivate var depthDataPool = [String: YXDepthOrderData]()
    fileprivate var posBrokerDataPool = [String: PosBroker]()
    
    
    fileprivate let tickCount = 30
    fileprivate let kLineCount = 200
    fileprivate let btTimeLineCount = 1440

    fileprivate let btMarket = "cryptos"
    
    private override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(reconnectSocket), name: NSNotification.Name("kYXSocketReconnectNotification"), object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func reconnectSocket() {
        requestPool.values.forEach { [weak self] (request) in
            guard let strongSelf = self else { return }
            
            //let secus = request.secus
            let scheme = request.scheme
            //let level = request.level
            let subType = request.subType
            let api = request.api!
            let seqFlag = request.seqFlag
            let quoteType = request.quoteType
            
            if scheme == .http {
                if subType == .rtFull || subType == .rtSimple {
                    var greySecus = [Secu]()
                    request.secus.forEach { [weak self] (secu) in
                        var topic = YXSocketTopic(rtWithMarket: secu.market, symbol: secu.symbol, scene: .qsMobileBrief1, extraQuote: secu.extra)
                        if subType == .rtFull {
                            topic = YXSocketTopic(rtWithMarket: secu.market, symbol: secu.symbol, scene: .qsFull, extraQuote: secu.extra)
                        }
                        if let quote = self?.rtDataPool[topic.topicDescription()], let greyFlag = quote.greyFlag?.value, greyFlag > 0 {
                            greySecus.append(secu)
                        }
                    }
                    
                    if greySecus.count > 0 {
                        YXSocketSingleton.shareInstance().unSub(withFlag: seqFlag)
                        let handler = request.rtHandler
                        var api: API = .simple(greySecus, level: .level2)
                        if subType == .rtFull {
                            api = .detail(greySecus, props: nil, level: .level2)
                        }
                        _ = service.request(api) { (response: YXResponseType<YXV2QuoteList>) in
                            switch response {
                            case .success(let result, let code):
                                switch code {
                                case .success?:
                                    
                                  if let list = result.data?.list {
                                        var topics = [YXSocketTopic]()
                                        if subType == .rtSimple {
                                            handler?(list, .http)
                                            list.forEach({ (quote) in
                                                if let market = quote.market, let symbol = quote.symbol {
                                                    let topic = YXSocketTopic(rtWithMarket: market, symbol: symbol, scene: .qsMobileBrief1, extraQuote: quote.extraType())
                                                    strongSelf.rtDataPool[topic.topicDescription()] = quote
                                                    topics.append(topic)
                                                }
                                            })
                                        } else {
                                            var newList = [YXV2Quote]()
                                            list.forEach({ (quote) in
                                                if let market = quote.market, let symbol = quote.symbol {
                                                    let topic = YXSocketTopic(rtWithMarket: market, symbol: symbol, scene: .qsFull, extraQuote: quote.extraType())
                                                    let topicString = topic.topicDescription()
                                                    let newValue = strongSelf.rtDataPool[topicString]?.deepMerged(with: quote) ?? quote
                                                    strongSelf.rtDataPool[topicString] = newValue
                                                    newList.append(newValue)
                                                    topics.append(topic)
                                                }
                                            })
                                            handler?(newList, .http)
                                        }
                                        request.seqFlag = YXSocketSingleton.shareInstance().sub(withServer: topics, target: strongSelf)
                                    }
                                default:
                                    break
                                }
                            default:
                                break
                            }
                        }
                    }
                }
            }
            
            if scheme == .tcp {
                
                YXSocketSingleton.shareInstance().unSub(withFlag: seqFlag)
                
                switch subType {
                case .rtFull,
                     .rtSimple:
                    let handler = request.rtHandler
                    
                    _ = strongSelf.request(api) { [weak self] (response: YXResponseType<YXV2QuoteList>) in
                        guard let strongSelf = self else { return }
                        
                        switch response {
                        case .success(let result, let code):
                            switch code {
                            case .success?:
                                if let list = result.data?.list {
                                    #if OVERSEAS
                                    list.forEach { $0.supplementaryQuote() }
                                    #endif
                                    var topics = [YXSocketTopic]()
                                    if subType == .rtSimple {
                                        handler?(list, .http)
                                        list.forEach({ (quote) in
                                            if let market = quote.market, let symbol = quote.symbol {
                                                var extraType = quote.extraType()
                                                // 全美行情下,如果是低级adr,设为全美行情
                                                if request.level == .usNational && quote.isLowAdr() {
                                                    extraType = .usNation
                                                }
                                                let topic = YXSocketTopic(rtWithMarket: market, symbol: symbol, scene: .qsMobileBrief1, extraQuote: extraType)
                                                strongSelf.rtDataPool[topic.topicDescription()] = quote
                                                topics.append(topic)
                                            }
                                        })
                                    } else {
                                        var newList = [YXV2Quote]()
                                        list.forEach({ (quote) in
                                            if let market = quote.market, let symbol = quote.symbol {
                                                let topic = YXSocketTopic(rtWithMarket: market, symbol: symbol, scene: .qsFull, extraQuote: quote.extraType())
                                                let topicString = topic.topicDescription()
                                                let newValue = strongSelf.rtDataPool[topicString]?.deepMerged(with: quote) ?? quote
                                                strongSelf.rtDataPool[topicString] = newValue
                                                newList.append(newValue)
                                                topics.append(topic)
                                            }
                                        })
                                        handler?(newList, .http)
                                    }
                                    request.seqFlag = YXSocketSingleton.shareInstance().sub(withServer: topics, target: strongSelf)
                                }
                            default:
                                break
                            }
                        default:
                            break
                        }
                    }
                case .timeLine:
                    let handler = request.timeLineHandler
                    
                    
                    if request.quoteType == .sQuoteAll {
                        _ = strongSelf.request(api) { [weak self] (response: YXResponseType<YXFullTimeLineData>) in
                            guard let strongSelf = self else { return }
                            
                            switch response {
                            case .success(let result, let code):
                                switch code {
                                case .success?:
                                    if let data = result.data {
                                        // 解析json的数组
                                        data.decodeTimeList()
                                        handler?(data.transformTimeLineData(), .http)
                                        var topics = [YXSocketTopic]()
                                        if let market = data.market, let symbol = data.symbol, let secu = request.secus.first {
                                            let intraTopic = YXSocketTopic(tsWithMarket: market, symbol: symbol, status: .intraday, extraQuote: secu.extra)
                                            let preTopic = YXSocketTopic(tsWithMarket: market, symbol: symbol, status: .pre, extraQuote: secu.extra)
                                            let afterTopic = YXSocketTopic(tsWithMarket: market, symbol: symbol, status: .after, extraQuote: secu.extra)
                                            strongSelf.fullTsDataPool[(market + symbol)] = data
                                            topics.append(intraTopic)
                                            topics.append(preTopic)
                                            topics.append(afterTopic)
                                        }
                                        request.seqFlag = YXSocketSingleton.shareInstance().sub(withServer: topics, target: strongSelf)
                                    }
                                default:
                                    break
                                }
                            default:
                                break
                            }
                        }
                    } else {
                        _ = strongSelf.request(api) { [weak self] (response: YXResponseType<YXTimeLineData>) in
                            guard let strongSelf = self else { return }
                            
                            switch response {
                            case .success(let result, let code):
                                switch code {
                                case .success?:
                                    if let data = result.data {
                                        handler?(data, .http)
                                        
                                        var topics = [YXSocketTopic]()
                                        if let market = data.market, let symbol = data.symbol, let secu = request.secus.first {
                                            var topic = YXSocketTopic(tsWithMarket: market, symbol: symbol, status: .intraday, extraQuote: secu.extra)
                                            if quoteType == .pre {
                                                topic = YXSocketTopic(tsWithMarket: market, symbol: symbol, status: .pre, extraQuote: secu.extra)
                                            } else if quoteType == .after {
                                                topic = YXSocketTopic(tsWithMarket: market, symbol: symbol, status: .after, extraQuote: secu.extra)
                                            }
                                            strongSelf.tsDataPool[topic.topicDescription()] = data
                                            topics.append(topic)
                                        }
                                        request.seqFlag = YXSocketSingleton.shareInstance().sub(withServer: topics, target: strongSelf)
                                    }
                                default:
                                    break
                                }
                            default:
                                break
                            }
                        }
                    }
                    
                case .kLine:
                    let handler = request.kLineHandler
                    
                    _ = strongSelf.request(api) { [weak self] (response: YXResponseType<YXKLineData>) in
                        guard let strongSelf = self else { return }
                        
                        switch response {
                        case .success(let result, let code):
                            switch code {
                            case .success?:
                                if let data = result.data {
                                    if data.ID?.market == strongSelf.btMarket {
                                        data.direction = "0"
                                    }
                                    var topics = [YXSocketTopic]()
                                    
                                    var optionalMarket = data.market ?? data.ID?.market
                                    var optionalSymbol = data.symbol ?? data.ID?.symbol
                                    
                                    if
                                        let market = optionalMarket, let symbol = optionalSymbol,
                                        let directionString = data.direction,
                                        let typeValue = data.type?.value, let directionValue = Int32(directionString),
                                        let type = OBJECT_QUOTEKLineType(rawValue: Int32(typeValue)),
                                        let direction = OBJECT_QUOTEKLineDirection(rawValue: directionValue),
                                        let secu = request.secus.first
                                    {
                                        let topic = YXSocketTopic(klWithMarket: market, symbol: symbol, type: type, direction: direction, extraQuote: secu.extra)
                                        let topicString = topic.topicDescription()
                                        
                                        
                                        if market == strongSelf.btMarket, let count = data.count?.value, count == Int32(strongSelf.btTimeLineCount) { //数字货币分时不需要增加老的数据
                                            
                                        } else if let kl = strongSelf.klDataPool[topicString] {
                                            var oldList = kl.list ?? []
                                            let newList = data.list ?? []
                                            
                                            let lastLatestTime = oldList.last?.latestTime?.value ?? 0
                                            var targetIndex: Int? = nil
                                            for (index, value) in newList.enumerated().reversed() {
                                                if value.latestTime?.value == lastLatestTime {
                                                    targetIndex = index
                                                    break
                                                }
                                            }
                                            let newListCount = newList.count
                                            let oldListCount = oldList.count
                                            if let index = targetIndex, oldListCount > 0, newListCount > 0 {
                                                if index == newListCount - 1 {
                                                    oldList[oldListCount - 1] = newList.last!
                                                    data.list = oldList
                                                } else {
                                                    let list = Array(newList[index+1..<newListCount])
                                                    oldList[oldListCount - 1] = newList[index]
                                                    oldList += list
                                                    data.list = oldList
                                                }
                                            }
                                        }
                                        strongSelf.klDataPool[topicString] = data
                                        handler?(data, .http)
                                        topics.append(topic)
                                    }
                                    request.seqFlag = YXSocketSingleton.shareInstance().sub(withServer: topics, target: strongSelf)
                                }
                            default:
                                break
                            }
                        default:
                            break
                        }
                    }
                case .tick:
                    let handler = request.tickHandler
                    if request.quoteType == .sQuoteAll {
                        _ = strongSelf.request(api) { [weak self] (response: YXResponseType<YXTickData>) in
                            guard let strongSelf = self else { return }
                            
                            switch response {
                            case .success(let result, let code):
                                switch code {
                                case .success?:
                                    if let data = result.data {
                                        let list = data.list?.reversed() ?? []
                                        data.list = list
                                        handler?(data, .http)
                                        
                                        var optionalMarket = data.market ?? data.ID?.market
                                        var optionalSymbol = data.symbol ?? data.ID?.symbol
                                        
                                        var topics = [YXSocketTopic]()
                                        if let market = optionalMarket, let symbol = optionalSymbol, let secu = request.secus.first {
                                            let intradayTopic = YXSocketTopic(tkWithMarket: market, symbol: symbol, status: .intraday, extraQuote: secu.extra)
                                            let preTopic = YXSocketTopic(tkWithMarket: market, symbol: symbol, status: .pre, extraQuote: secu.extra)
                                            let afterTopic = YXSocketTopic(tkWithMarket: market, symbol: symbol, status: .after, extraQuote: secu.extra)
                                            strongSelf.fullTkDataPool[(market + symbol)] = data
                                            topics = [intradayTopic, preTopic, afterTopic]
                                        }
                                        request.seqFlag = YXSocketSingleton.shareInstance().sub(withServer: topics, target: strongSelf)
                                    }
                                default:
                                    break
                                }
                            default:
                                break
                            }
                        }
                    } else {
                        _ = strongSelf.request(api) { [weak self] (response: YXResponseType<YXTickData>) in
                            guard let strongSelf = self else { return }
                            
                            switch response {
                            case .success(let result, let code):
                                switch code {
                                case .success?:
                                    if let data = result.data {
                                        let list = data.list?.reversed() ?? []
                                        data.list = list
                                        handler?(data, .http)
                                        
                                        var optionalMarket = data.market ?? data.ID?.market
                                        var optionalSymbol = data.symbol ?? data.ID?.symbol
                                        
                                        var topics = [YXSocketTopic]()
                                        if let market = optionalMarket, let symbol = optionalSymbol, let secu = request.secus.first {
                                            var topic = YXSocketTopic(tkWithMarket: market, symbol: symbol, status: .intraday, extraQuote: secu.extra)
                                            if quoteType == .pre {
                                                topic = YXSocketTopic(tkWithMarket: market, symbol: symbol, status: .pre, extraQuote: secu.extra)
                                            } else if quoteType == .after {
                                                topic = YXSocketTopic(tkWithMarket: market, symbol: symbol, status: .after, extraQuote: secu.extra)
                                            }
                                            strongSelf.tkDataPool[topic.topicDescription()] = data
                                            topics.append(topic)
                                        }
                                        request.seqFlag = YXSocketSingleton.shareInstance().sub(withServer: topics, target: strongSelf)
                                    }
                                default:
                                    break
                                }
                            default:
                                break
                            }
                        }
                    }
                    
                case .depthOrder, .depthChart:
                    let handler = request.depthOrderHandler
                    
                    _ = strongSelf.request(api) { [weak self] (response: YXResponseType<YXDepthOrderData>) in
                        guard let strongSelf = self else { return }
                        
                        switch response {
                        case .success(let result, let code):
                            switch code {
                            case .success?:
                                if let data = result.data {
                                    handler?(data, .http)
                                    
                                    var topics = [YXSocketTopic]()
                                    if let market = data.market, let symbol = data.symbol {
                                        var depthType: YXSocketDepthType = .none
                                        if subType == .depthChart {
                                            depthType = .chart
                                        } else {
                                            if data.merge?.value ?? false {
                                                depthType = .merge
                                            }
                                        }
                                        var topic = YXSocketTopic(depthWithMarket: market, symbol: symbol, type:  depthType)

                                        strongSelf.depthDataPool[topic.topicDescription()] = data
                                        topics.append(topic)
                                    }
                                    request.seqFlag = YXSocketSingleton.shareInstance().sub(withServer: topics, target: strongSelf)
                                }
                            default:
                                break
                            }
                        default:
                            break
                        }
                    }
                case .posBroker:
                    let handler = request.posBrokerHandler
                    
                    _ = strongSelf.request(api) { [weak self] (response: YXResponseType<PosBrokerList>) in
                        guard let strongSelf = self else { return }
                        
                        switch response {
                        case .success(let result, let code):
                            switch code {
                            case .success?:
                                if let model = result.data?.list?.last {
                                    handler?(model, .http)
                                    if let market = model.market, let symbol = model.symbol, let secu = request.secus.first  {
                                        var topics = [YXSocketTopic]()
                                        let posTopic = YXSocketTopic.init(posWithMarket: market, symbol: symbol, extraQuote: secu.extra)
                                        topics.append(posTopic)
                                        let key = market + symbol + posTopic.getExtraQuoteStr()
                                        strongSelf.posBrokerDataPool[key] = model

                                        if market == "hk" {
                                            let brokerTopic = YXSocketTopic.init(brokerWithMarket: market, symbol: symbol, extraQuote: secu.extra)
                                            topics.append(brokerTopic)
                                        }
                                        request.seqFlag = YXSocketSingleton.shareInstance().sub(withServer: topics, target: strongSelf)
                                    }
                                }
                            default:
                                break
                            }
                        default:
                            break
                        }
                    }
                default:
                    break
                }
            }
        }
    }
    
    let service = YXV2QuoteService()
    
    @objc public func removeKlinePool() {
        klDataPool.removeAll()
    }
    
    fileprivate func remove(_ request: YXQuoteRequest) {
        request.rtHandler = nil
        request.kLineHandler = nil
        request.tickHandler = nil
        request.timeLineHandler = nil
        request.batchTimeLineHandler = nil
        request.depthOrderHandler = nil
        request.posBrokerHandler = nil
        
        let quoteFlag = request.quoteFlag
        let seqFlag = request.seqFlag
        let extFlag = request.extFlag
        
        YXTimerSingleton.shareInstance().invalidOperation(withFlag: quoteFlag)
        YXSocketSingleton.shareInstance().unSub(withFlag: seqFlag)
        YXTimerSingleton.shareInstance().invalidOperation(withFlag: extFlag)
        
        request.dispose?.dispose()
        
        requestPool.removeValue(forKey: quoteFlag)
    }
    
    @objc public func removeAllRequest() {
        requestPool.values.forEach { (request) in
            request.cancel()
        }
        requestPool.removeAll()
        rtDataPool.removeAll()
        tsDataPool.removeAll()
        fullTsDataPool.removeAll()
        fullTkDataPool.removeAll()
        klDataPool.removeAll()
        tkDataPool.removeAll()
        depthDataPool.removeAll()
        posBrokerDataPool.removeAll()
    }
    
    @objc public func onceRtSimpleQuote(secus: [Secu], level: QuoteLevel, handler: @escaping RtHandler, failed: FailedHandler? = nil) {
        let api: API = .simple(secus, level: level)
        
        _ = service.request(api) { (response: YXResponseType<YXV2QuoteList>) in
            switch response {
            case .success(let result, let code):
                switch code {
                case .success?:
                    let list = result.data?.list ?? []
                    handler(list, .http)
                default:
                    failed?()
                }
            case .failed(_):
                failed?()
            }
        }
    }
    
    @objc public func onceRtFullQuote(secus: [Secu], level: QuoteLevel, handler: @escaping RtHandler, failed: FailedHandler? = nil) {
        let api: API = .detail(secus, props: nil, level: level)
        
        _ = service.request(api) { (response: YXResponseType<YXV2QuoteList>) in
            
            switch response {
            case .success(let result, let code):
                switch code {
                case .success?:
                    let list = result.data?.list ?? []
                    handler(list, .http)
                default:
                    failed?()
                }
            case .failed(_):
                failed?()
            }
        }
    }
    
    fileprivate func subRtQuote(secus: [Secu], level: QuoteLevel, isAdr: Bool? = true, scene: OBJECT_QUOTEQuoteScene, handler: @escaping RtHandler, failed: FailedHandler? = nil) -> YXQuoteRequest {
        let timeInterval = TimeInterval(YXGlobalConfigManager.configFrequency(.delayQuoteRealtimeFreq))
        var repeatTimes = 1
        var isCryptos = false
        if level == .delay {
            repeatTimes = Int.max
        }
        
        secus.forEach { secu in
            if level == .usNational {
                secu.extra = .usNation
            }
        }
        
        let request = YXQuoteRequest()
        request.scheme = .http
        request.secus = secus
        request.rtHandler = handler
        request.subType = .rtFull
        request.level = level
        if let market = secus.first?.market, market == btMarket {
            request.api = .btDetail(secus)
            isCryptos = true
        } else {
            request.api = .detail(secus, props: nil, level: level)
        }

        if scene == .qsMobileBrief1 {
            request.subType = .rtSimple
            request.api = .simple(secus, level: level)
        }
        
        request.quoteFlag = YXTimerSingleton.shareInstance().transactOperation({ [weak self] (_) in
            guard let strongSelf = self else { return }
            
            request.dispose = strongSelf.service.request(request.api!) { [weak self] (response: YXResponseType<YXV2QuoteList>) in
                guard let strongSelf = self else { return }
                
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        var list = result.data?.list ?? []
                        if !isCryptos, level == .delay, scene == .qsFull  {
                            var newList = [YXV2Quote]()
                            list.forEach({ (quote) in
                                if let market = quote.market, let symbol = quote.symbol {
                                    let topic = YXSocketTopic(rtWithMarket: market, symbol: symbol, scene: .qsFull, extraQuote: quote.extraType())
                                    let topicString = topic.topicDescription()
                                    let newValue = strongSelf.rtDataPool[topicString]?.deepMerged(with: quote) ?? quote
                                    newList.append(newValue)
                                }
                            })
                            list = newList
                        }
                        #if OVERSEAS
                        list.forEach { $0.supplementaryQuote() }
                        #endif
                        handler(list, .http)
                        
                        var topics = [YXSocketTopic]()
                        
                        var greyTopics = [YXSocketTopic]()
                        var newSecus = secus
                        list.forEach { (quote) in
                            if let market = quote.market, let symbol = quote.symbol {
                                let greyFlag = quote.greyFlag?.value ?? 0
                                var extraType = quote.extraType()
                                // 全美行情下,如果是低级adr,设为全美行情
                                if level == .usNational && quote.isLowAdr() {
                                    extraType = .usNation
                                }
                                let topic = YXSocketTopic(rtWithMarket: market, symbol: symbol, scene: scene, extraQuote: extraType)
                                
                                topics.append(topic)
                                if greyFlag > 0  {
                                    newSecus = newSecus.filter{ $0.market != market && $0.symbol != symbol}
                                    greyTopics.append(topic)
                                }
                                strongSelf.rtDataPool[topic.topicDescription()] = quote
                                if level == .usNational {
                                    // 全美行情下,同步secu的extra值
                                    for secu in secus {
                                        if market == secu.market, symbol == secu.symbol {
                                            secu.extra = extraType
                                            break
                                        }
                                    }
                                }
                            }
                        }
                        
                        if level == .level2 || level == .level1 || level == .usNational {
                            request.scheme = .tcp
                            strongSelf.requestPool[request.quoteFlag] = request
                            request.seqFlag = YXSocketSingleton.shareInstance().sub(withServer: topics, target: strongSelf)
                        } else if greyTopics.count > 0 {
                            if newSecus.count > 0 {
                                request.subType = .rtFull
                                request.api = .detail(newSecus, props: nil, level: level)
                                if scene == .qsMobileBrief1 {
                                    request.subType = .rtSimple
                                    request.api = .simple(newSecus, level: level)
                                }
                            } else {
                                YXTimerSingleton.shareInstance().invalidOperation(withFlag: request.quoteFlag)
                            }

                            request.seqFlag = YXSocketSingleton.shareInstance().sub(withServer: greyTopics, target: strongSelf)
                        }
                        
                        if scene == .qsFull && request.extFlag == 0 {
                            let adr = isAdr ?? true
                            if let first = list.first, (first.ah != nil || first.adr != nil), adr {
                                request.extFlag = YXTimerSingleton.shareInstance().transactOperation({ [weak self] (_) in
                                    guard let strongSelf = self else { return }
                                    
                                    let mainSecu = Secu(market: first.market ?? "", symbol: first.symbol ?? "")
                                    var ahSecu: Secu?
                                    var adrSecu: Secu?
                                    if let ah = first.ah, let market = ah.market, let symbol = ah.symbol {
                                        ahSecu = Secu(market: market, symbol: symbol)
                                    }
                                    if let adr = first.adr, let market = adr.market, let symbol = adr.symbol {
                                        adrSecu = Secu(market: market, symbol: symbol)
                                    }
                                    
                                    let api: API = .ext(mainSecu, ah: ahSecu, adr: adrSecu)
                                    
                                    _ = strongSelf.service.request(api) { [weak self] (response: YXResponseType<Ext>) in
                                        guard let strongSelf = self else { return }
                                        
                                        switch response {
                                        case .success(let result, let code):
                                            switch code {
                                            case .success?:
                                                if let market = first.market, let symbol = first.symbol {
                                                    var extraType: YXSocketExtraQuote = .none
                                                    if level == .usNational {
                                                        extraType = .usNation
                                                    }
                                                    let topic = YXSocketTopic(rtWithMarket: market, symbol: symbol, scene: .qsFull, extraQuote: extraType)
                                                    if let value = strongSelf.rtDataPool[topic.topicDescription()] {
                                                        value.ah = value.ah?.deepMerged(with: result.data?.ah)
                                                        value.adr = value.adr?.deepMerged(with: result.data?.adr)
                                                        strongSelf.rtDataPool[topic.topicDescription()] = value
                                                        handler([value], .http)
                                                    }
                                                }
                                                break
                                            default:
                                                break
                                            }
                                        case .failed(_):
                                            break
                                        }
                                    }
                                    }, timeInterval: timeInterval, repeatTimes: Int.max, atOnce: true)
                            }
                        }
                    default:
                        failed?()
                    }
                case .failed(_):
                    failed?()
                }
            }
            }, timeInterval: timeInterval, repeatTimes: repeatTimes, atOnce: true)
        
        requestPool[request.quoteFlag] = request
        return request
    }
    
    @objc public func subRtFullQuote(secu: Secu, level: QuoteLevel, isAdr: Bool, handler: @escaping RtHandler, failed: FailedHandler? = nil) -> YXQuoteRequest {
        return subRtQuote(secus: [secu], level: level, isAdr: isAdr, scene: .qsFull, handler: handler, failed: failed)
    }
    
    @objc public func subRtSimpleQuote(secus: [Secu], level: QuoteLevel, handler: @escaping RtHandler, failed: FailedHandler? = nil) -> YXQuoteRequest {
        return subRtQuote(secus: secus, level: level, scene: .qsMobileBrief1, handler: handler, failed: failed)
    }
    
    @objc public func subRtFullQuote(secus: [Secu], level: QuoteLevel, handler: @escaping RtHandler, failed: FailedHandler? = nil) -> YXQuoteRequest {
        return subRtQuote(secus: secus, level: level, scene: .qsFull, handler: handler, failed: failed)
    }
    
    @objc public func subRtFullQuote(secu: Secu, level: QuoteLevel, handler: @escaping RtHandler, failed: FailedHandler? = nil) -> YXQuoteRequest {
        return subRtFullQuote(secus: [secu], level: level, handler: handler, failed: failed)
    }
    
    @objc public func subKLineQuote(secu: Secu, type: OBJECT_QUOTEKLineType, direction: OBJECT_QUOTEKLineDirection, level: QuoteLevel, handler: @escaping KLineHandler, failed: FailedHandler? = nil) -> YXQuoteRequest {
        
        return subKLineQuote(secu: secu, type: type, direction: direction, level: level, count: self.kLineCount, handler: handler, failed: failed)
    }
    
    @objc public func subKLineQuote(secu: Secu, type: OBJECT_QUOTEKLineType, direction: OBJECT_QUOTEKLineDirection, level: QuoteLevel, count: Int = 0, handler: @escaping KLineHandler, failed: FailedHandler? = nil) -> YXQuoteRequest {
        let timeInterval = TimeInterval(YXGlobalConfigManager.configFrequency(.delayKlineFreq))
        var repeatTimes = 1
        var isCryptos = false
        var tempDirection = direction
        if level == .delay {
            repeatTimes = Int.max
        }
        
        let request = YXQuoteRequest()
        request.scheme = .http
        request.secus = [secu]
        request.kLineHandler = handler
        request.subType = .kLine
        request.level = level
        if secu.market == btMarket {
            isCryptos = true
            tempDirection = .kdNone
            request.api = .btKLine(secu, type: type, start: 0, count: Int32(count > 0 ? count : self.kLineCount))
        } else {
            request.api = .kLine(secu, type: type, direction: direction, start: "0", count: (count > 0 ? String(count) : String(self.kLineCount)), level: level)
        }

        
        request.quoteFlag = YXTimerSingleton.shareInstance().transactOperation({ [weak self] (_) in
            guard let strongSelf = self else { return }
            
            request.dispose = strongSelf.service.request(request.api!) { [weak self] (response: YXResponseType<YXKLineData>) in
                guard let strongSelf = self else { return }
                
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        if let data = result.data {

                            if data.ID?.market == strongSelf.btMarket {
                                data.direction = "0"
                            }
                            let topic = YXSocketTopic(klWithMarket: secu.market, symbol: secu.symbol, type: type, direction: tempDirection, extraQuote: secu.extra)
                            let topicString = topic.topicDescription()
                            
                            if data.ID?.market == strongSelf.btMarket, count == Int32(strongSelf.btTimeLineCount) { //数字货币分时不需要增加老的数据
                                
                            } else if let kl = strongSelf.klDataPool[topicString] {
                                var oldList = kl.list ?? []
                                let newList = data.list ?? []
                                
                                let lastLatestTime = oldList.last?.latestTime?.value ?? 0
                                var targetIndex: Int? = nil
                                for (index, value) in newList.enumerated().reversed() {
                                    if value.latestTime?.value == lastLatestTime {
                                        targetIndex = index
                                        break
                                    }
                                }
                                let newListCount = newList.count
                                let oldListCount = oldList.count
                                if let index = targetIndex, oldListCount > 0, newListCount > 0 {
                                    if index == newListCount - 1 {
                                        oldList[oldListCount - 1] = newList.last!
                                        data.list = oldList
                                    } else {
                                        let list = Array(newList[index+1..<newListCount])
                                        oldList[oldListCount - 1] = newList[index]
                                        oldList += list
                                        data.list = oldList
                                    }
                                }
                            }
                            strongSelf.klDataPool[topicString] = data
                            handler(data, .http)
                            
                            if level == .level2 || level == .level1 || level == .usNational {
                                request.scheme = .tcp
                                strongSelf.requestPool[request.quoteFlag] = request
                                request.seqFlag = YXSocketSingleton.shareInstance().sub(withServer: [topic], target: strongSelf)
                            }
                        } else {
                            failed?()
                        }
                    default:
                        failed?()
                    }
                case .failed(_):
                    failed?()
                }
            }
            }, timeInterval: timeInterval, repeatTimes: repeatTimes, atOnce: true)
        
        requestPool[request.quoteFlag] = request
        
        return request
    }
    
    fileprivate func nextKLine(_ request: YXQuoteRequest, succeed: NoMoreHandler?, failed: FailedHandler?) {

        guard let api = request.api, case let .kLine(secu, type, direction, _, _, level) = api else {
            failed?()
            return
        }
        let topic = YXSocketTopic(klWithMarket: secu.market, symbol: secu.symbol, type: type, direction: direction, extraQuote: secu.extra)
        
        guard let klData = klDataPool[topic.topicDescription()],
            let first = klData.list?.first,
            let latestTime = first.latestTime?.value else {
                failed?()
                return
        }
        let nextApi: API = .kLine(secu, type: type, direction: direction, start: String(latestTime), count: String(kLineCount), level: level)
        let handler = request.kLineHandler
        _ = service.request(nextApi) { [weak self] (response: YXResponseType<YXKLineData>) in
            guard let strongSelf = self else { return }
            
            switch response {
            case .success(let result, let code):
                switch code {
                case .success?:
                    var list = result.data?.list ?? []
                    if
                        let last = list.last,
                        let originFirst = klData.list?.first,
                        last.latestTime?.value == originFirst.latestTime?.value
                    {
                        list.removeLast()
                    }
                    if list.count > 0 {
                        klData.list = list + (klData.list ?? [])
                        strongSelf.klDataPool[topic.topicDescription()] = klData
                        
                        handler?(klData, .http)
                    }
                    succeed?(list.count < strongSelf.kLineCount)
                default:
                    failed?()
                }
            case .failed(_):
                failed?()
            }
        }
    }

    @objc public func btKLineQuote(secu: Secu, type: OBJECT_QUOTEKLineType, direction: OBJECT_QUOTEKLineDirection, level: QuoteLevel, count: Int = 0, handler: @escaping KLineHandler, failed: FailedHandler? = nil) -> YXQuoteRequest {
        let timeInterval = TimeInterval(YXGlobalConfigManager.configFrequency(.delayKlineFreq))
        var repeatTimes = 1
        if level == .delay {
            repeatTimes = Int.max
        }

        let request = YXQuoteRequest()
        request.scheme = .http
        request.secus = [secu]
        request.kLineHandler = handler
        request.subType = .kLine
        request.level = level
        request.api = .kLine(secu, type: type, direction: direction, start: "0", count: String(self.kLineCount), level: level)

        request.quoteFlag = YXTimerSingleton.shareInstance().transactOperation({ [weak self] (_) in
            guard let strongSelf = self else { return }

            request.dispose = strongSelf.service.request(request.api!) { [weak self] (response: YXResponseType<YXKLineData>) in
                guard let strongSelf = self else { return }

                switch response {
                    case .success(let result, let code):
                        switch code {
                            case .success?:
                                if let data = result.data {

                                    let topic = YXSocketTopic(klWithMarket: secu.market, symbol: secu.symbol, type: type, direction: direction, extraQuote: .none)
                                    let topicString = topic.topicDescription()
                                    if let kl = strongSelf.klDataPool[topicString] {
                                        var oldList = kl.list ?? []
                                        let newList = data.list ?? []

                                        let lastLatestTime = oldList.last?.latestTime?.value ?? 0
                                        var targetIndex: Int? = nil
                                        for (index, value) in newList.enumerated().reversed() {
                                            if value.latestTime?.value == lastLatestTime {
                                                targetIndex = index
                                                break
                                            }
                                        }
                                        let newListCount = newList.count
                                        let oldListCount = oldList.count
                                        if let index = targetIndex, oldListCount > 0, newListCount > 0 {
                                            if index == newListCount - 1 {
                                                oldList[oldListCount - 1] = newList.last!
                                                data.list = oldList
                                            } else {
                                                let list = Array(newList[index+1..<newListCount])
                                                oldList[oldListCount - 1] = newList[index]
                                                oldList += list
                                                data.list = oldList
                                            }
                                        }
                                    }
                                    strongSelf.klDataPool[topicString] = data
                                    handler(data, .http)

                                    if level == .level2 || level == .level1 {
                                        request.scheme = .tcp
                                        strongSelf.requestPool[request.quoteFlag] = request
                                        request.seqFlag = YXSocketSingleton.shareInstance().sub(withServer: [topic], target: strongSelf)
                                    }
                                } else {
                                    failed?()
                                }
                            default:
                                failed?()
                        }
                    case .failed(_):
                        failed?()
                }
            }
        }, timeInterval: timeInterval, repeatTimes: repeatTimes, atOnce: true)

        requestPool[request.quoteFlag] = request

        return request
    }

    fileprivate func btNextKLine(_ request: YXQuoteRequest, succeed: NoMoreHandler?, failed: FailedHandler?) {

        guard let api = request.api, case let .btKLine(secu, type: type, start: _, count: count) = api else {
            failed?()
            return
        }

        let reqCount = count ?? Int32(self.kLineCount)
        let topic = YXSocketTopic(klWithMarket: secu.market, symbol: secu.symbol, type: type, direction: .kdNone, extraQuote: .none)

        guard let klData = klDataPool[topic.topicDescription()],
              let nextPageStart = klData.nextPageStart?.value else {
            failed?()
            return
        }
        let nextApi: API = .btKLine(secu, type: type, start: nextPageStart, count: count)
        let handler = request.kLineHandler
        _ = service.request(nextApi) { [weak self] (response: YXResponseType<YXKLineData>) in
            guard let strongSelf = self else { return }

            switch response {
                case .success(let result, let code):
                    switch code {
                        case .success?:
                            var list = result.data?.list ?? []
                            if
                                let last = list.last,
                                let originFirst = klData.list?.first,
                                last.latestTime?.value == originFirst.latestTime?.value
                            {
                                list.removeLast()
                            }
                            if list.count > 0 {
                                klData.list = list + (klData.list ?? [])
                                strongSelf.klDataPool[topic.topicDescription()] = klData

                                handler?(klData, .http)
                            }
                            succeed?(list.count < reqCount)
                        default:
                            failed?()
                    }
                case .failed(_):
                    failed?()
            }
        }
    }

    @objc public func subBatchKLine(params: [[String : Any]], level: QuoteLevel, handler: @escaping BatchKLineHandler, failed: FailedHandler? = nil) -> YXQuoteRequest {
        let timeInterval = TimeInterval(YXGlobalConfigManager.configFrequency(.quotesResendFreq))
        var repeatTimes = 1
        if level == .delay {
            repeatTimes = Int.max
        }

        let request = YXQuoteRequest()
        request.scheme = .http
        //request.secus = secus
        request.batchKLineHandler = handler
        request.subType = .batchKLine
        request.level = level
        
        request.api = .btBatchKLine(params)

        request.quoteFlag = YXTimerSingleton.shareInstance().transactOperation({ [weak self] (_) in
            guard let strongSelf = self else { return }

            request.dispose = strongSelf.service.request(request.api!) { (response: YXResponseType<YXBatchKLineData>) in

                switch response {
                    case .success(let result, let code):
                        switch code {
                            case .success?:
                                let list = result.data?.list ?? []
                                handler(list)
                            default:
                                failed?()
                        }
                    case .failed(_):
                        failed?()
                }
            }
        }, timeInterval: timeInterval, repeatTimes: repeatTimes, atOnce: true)

        requestPool[request.quoteFlag] = request
        return request
    }

    @objc public func onceKLineQuote(secu: Secu, type: OBJECT_QUOTEKLineType, direction: OBJECT_QUOTEKLineDirection, level: QuoteLevel, count: Int, handler: @escaping KLineHandler, failed: FailedHandler? = nil) {

        let request = YXQuoteRequest()
        request.scheme = .http
        request.secus = [secu]
        request.kLineHandler = handler
        request.subType = .kLine
        request.level = level
        request.api = .kLine(secu, type: type, direction: direction, start: "0", count: String(count), level: level)

        _ = self.service.request(request.api!) { [weak self] (response: YXResponseType<YXKLineData>) in
            guard let strongSelf = self else { return }

            switch response {
                case .success(let result, let code):
                    switch code {
                        case .success?:
                            if let data = result.data {
                                handler(data, .http)
                            } else {
                                failed?()
                            }
                        default:
                            failed?()
                    }
                case .failed(_):
                    failed?()
            }
        }
    }

    //MARK: subTickQuote
    @objc public func subTickQuote(secu: Secu, level: QuoteLevel, type:QuoteType, handler: @escaping TickHandler, failed: FailedHandler? = nil) -> YXQuoteRequest {

        let timeInterval = TimeInterval(YXGlobalConfigManager.configFrequency(.delayKlineFreq))
        
        let repeatTimes = 1
        
        let request = YXQuoteRequest()
        request.scheme = .http
        request.secus = [secu]
        request.tickHandler = handler
        request.subType = .tick
        request.level = level
        request.quoteType = type
        if secu.market == btMarket {
            request.api = .btTick(secu, start: 0, count: Int32(tickCount), sortDirection: 0)
        } else {
            request.api = .tick(secu, start: "0", tradeTime: "0", count: String(tickCount), level: level, sortDirection: 0, type: type)
        }

        request.quoteFlag = YXTimerSingleton.shareInstance().transactOperation({ [weak self] (_) in
            guard let strongSelf = self else { return }
            
            request.dispose = strongSelf.service.request(request.api!) { [weak self] (response: YXResponseType<YXTickData>) in
                guard let strongSelf = self else { return }
                
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        if let data = result.data {
                            let list = data.list?.reversed() ?? []
                            data.list = list
                            handler(data, .http)
                            
                            var topic = YXSocketTopic(tkWithMarket: secu.market, symbol: secu.symbol, status: .intraday, extraQuote: secu.extra)
                            if type == .pre {
                                topic = YXSocketTopic(tkWithMarket: secu.market, symbol: secu.symbol, status: .pre, extraQuote: secu.extra)
                            } else if type == .after {
                                topic = YXSocketTopic(tkWithMarket: secu.market, symbol: secu.symbol, status: .after, extraQuote: secu.extra)
                            }
                            strongSelf.tkDataPool[topic.topicDescription()] = data
                            
                            if level == .level2 || level == .level1 || level == .usNational {
                                request.scheme = .tcp
                                strongSelf.requestPool[request.quoteFlag] = request
                                request.seqFlag = YXSocketSingleton.shareInstance().sub(withServer: [topic], target: strongSelf)
                            }
                        } else {
                            failed?()
                        }
                    default:
                        failed?()
                    }
                case .failed(_):
                    failed?()
                }
            }
            }, timeInterval: timeInterval, repeatTimes: repeatTimes, atOnce: true)
        
        requestPool[request.quoteFlag] = request
        
        return request
    }
    
    //MARK: subTickQuote
    @objc public func subFullTickQuote(secu: Secu, level: QuoteLevel, type:QuoteType, handler: @escaping TickHandler, failed: FailedHandler? = nil) -> YXQuoteRequest {

        let timeInterval = TimeInterval(YXGlobalConfigManager.configFrequency(.delayKlineFreq))
        
        let repeatTimes = 1
        
        let request = YXQuoteRequest()
        request.scheme = .http
        request.secus = [secu]
        request.tickHandler = handler
        request.subType = .tick
        request.level = level
        request.quoteType = type
        if secu.market == btMarket {
            request.api = .btTick(secu, start: 0, count: Int32(tickCount), sortDirection: 0)
        } else {
            let page: [String: Int64] = ["seq": 0, "from": 0, "session": 0]
            request.api = .fullTick(secu, count: tickCount, level: level, sortDirection: 0, session: 0, pageCtx: page)
        }
        

        request.quoteFlag = YXTimerSingleton.shareInstance().transactOperation({ [weak self] (_) in
            guard let strongSelf = self else { return }
            
            request.dispose = strongSelf.service.request(request.api!) { [weak self] (response: YXResponseType<YXTickData>) in
                guard let strongSelf = self else { return }
                
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        if let data = result.data {
                            let list = data.list?.reversed() ?? []
                            data.list = list
                            handler(data, .http)
                            
                            let intraTopic = YXSocketTopic(tkWithMarket: secu.market, symbol: secu.symbol, status: .intraday, extraQuote: secu.extra)
                            let preTopic = YXSocketTopic(tkWithMarket: secu.market, symbol: secu.symbol, status: .pre, extraQuote: secu.extra)
                            let afterTopic = YXSocketTopic(tkWithMarket: secu.market, symbol: secu.symbol, status: .after, extraQuote: secu.extra)
                            strongSelf.fullTkDataPool[(secu.market + secu.symbol)] = data
                            
                            if level == .level2 || level == .level1 || level == .usNational {
                                request.scheme = .tcp
                                strongSelf.requestPool[request.quoteFlag] = request
                                request.seqFlag = YXSocketSingleton.shareInstance().sub(withServer: [intraTopic, preTopic, afterTopic], target: strongSelf)
                            }
                        } else {
                            failed?()
                        }
                    default:
                        failed?()
                    }
                case .failed(_):
                    failed?()
                }
            }
            }, timeInterval: timeInterval, repeatTimes: repeatTimes, atOnce: true)
        
        requestPool[request.quoteFlag] = request
        
        return request
    }
    
    
    //MARK: subStatisticQuote
    @objc public func subStatisticQuote(secu: Secu, type:Int, nextPageRef:Int, marketType:Int, handler: @escaping StatisticalHandler, failed: FailedHandler? = nil) -> YXQuoteRequest {
        
        let timeInterval = TimeInterval.init(30)//TimeInterval(30)   //30秒轮询一次 //TimeInterval(YXGlobalConfigManager.configFrequency(.delayKlineFreq))
        
        let repeatTimes = 1
        
        let request = YXQuoteRequest()
        request.scheme = .http
        request.secus = [secu]
        request.statisticalHandler = handler
        request.subType = .statistic
        /* http://szshowdoc.youxin.com/web/#/23?page_id=662 -->
        quotes-analysis(行情分析服务) --> v1 --> 成交统计接口
        quotes-analysis-app/api/v1/statistic
         type: 类型：0：最近20条，1：最近50条，2：全部 */
        request.api = .statistic(secu.market, symbol: secu.symbol, type: type, nextPageRef: nextPageRef, marketTimeType: marketType)

        request.quoteFlag = YXTimerSingleton.shareInstance().transactOperation({ [weak self] (_) in
            guard let strongSelf = self else { return }
            
            request.dispose = strongSelf.service.request(request.api!) { [weak self] (response: YXResponseType<YXAnalysisStatisticData>) in
                guard let strongSelf = self else { return }
                
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        print(result.data)
                        if let data = result.data {
                            let list = data.priceData ?? []//data.list?.reversed() ?? []
                            data.priceData = list
                            handler(data, .http)
                        } else {
                            failed?()
                        }
                    default:
                        failed?()
                    }
                case .failed(_):
                    failed?()
                }
            }
            }, timeInterval: timeInterval, repeatTimes: repeatTimes, atOnce: true)
        
        requestPool[request.quoteFlag] = request
        
        return request
    }
    
    //MARK: subStatisticQuote
    @objc public func subNewStatisticQuote(secu: Secu, type:Int, bidOrAskType: Int, marketTimeType: Int,  tradeDay: String, sortType: Int, sortMode: Int, handler: @escaping StatisticalHandler, failed: FailedHandler? = nil) -> YXQuoteRequest {
        
        let timeInterval = TimeInterval.init(30)//TimeInterval(30)   //30秒轮询一次 //TimeInterval(YXGlobalConfigManager.configFrequency(.delayKlineFreq))
        
        let repeatTimes = 1
        
        let request = YXQuoteRequest()
        request.scheme = .http
        request.secus = [secu]
        request.statisticalHandler = handler
        request.subType = .newStatistic
        request.api = .newStatistic(secu.market, symbol: secu.symbol, type: type, bidOrAskType: bidOrAskType, marketTimeType: marketTimeType, tradeDay: tradeDay, sortType: sortType, sortMode: sortMode)
        
        request.quoteFlag = YXTimerSingleton.shareInstance().transactOperation({ [weak self] (_) in
            guard let strongSelf = self else { return }
            
            request.dispose = strongSelf.service.request(request.api!) { [weak self] (response: YXResponseType<YXAnalysisStatisticData>) in
                guard let strongSelf = self else { return }
                
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        print(result.data)
                        if let data = result.data {
                            let list = data.priceData ?? []//data.list?.reversed() ?? []
                            data.priceData = list
                            handler(data, .http)
                        } else {
                            failed?()
                        }
                    default:
                        failed?()
                    }
                case .failed(_):
                    failed?()
                }
            }
            }, timeInterval: timeInterval, repeatTimes: repeatTimes, atOnce: true)
        
        requestPool[request.quoteFlag] = request
        
        return request
    }
    
    fileprivate func nextTick(_ request: YXQuoteRequest, succeed: NoMoreHandler?, failed: FailedHandler?) {

        if let market = request.secus.first?.market, market == btMarket {

            btNextTick(request, succeed: succeed, failed: failed)
            return
        }

        guard let api = request.api, case let .tick(secu, _, _, _, level, sortDirection, type) = api else {
            failed?()
            return
        }
        var topic = YXSocketTopic(tkWithMarket: secu.market, symbol: secu.symbol, status: .intraday, extraQuote: secu.extra)
        if type == .pre {
            topic = YXSocketTopic(tkWithMarket: secu.market, symbol: secu.symbol, status: .pre, extraQuote: secu.extra)
        } else if type == .after {
            topic = YXSocketTopic(tkWithMarket: secu.market, symbol: secu.symbol, status: .after, extraQuote: secu.extra)
        }
        
        guard let tickData = tkDataPool[topic.topicDescription()],
            let first = tickData.list?.first,
            let start = first.id?.value,
            let tradeTime = first.time?.value else {
                failed?()
                return
        }
        let nextApi: API = .tick(secu, start: String(start), tradeTime: String(tradeTime), count: String(tickCount), level: level, sortDirection: sortDirection, type: type)
        let handler = request.tickHandler
        _ = service.request(nextApi) { [weak self] (response: YXResponseType<YXTickData>) in
            guard let strongSelf = self else { return }
            
            switch response {
            case .success(let result, let code):
                switch code {
                case .success?:
                    let list = result.data?.list?.reversed() ?? []
                    if list.count > 0 {
                        tickData.list = list + (tickData.list ?? [])
                        strongSelf.tkDataPool[topic.topicDescription()] = tickData
                        
                        handler?(tickData, .http)
                    }
                    succeed?(list.count < strongSelf.tickCount)
                default:
                    failed?()
                }
            case .failed(_):
                failed?()
            }
        }
    }
    
    fileprivate func nextFullTick(_ request: YXQuoteRequest, succeed: NoMoreHandler?, failed: FailedHandler?) {

        if let market = request.secus.first?.market, market == btMarket {

            btNextTick(request, succeed: succeed, failed: failed)
            return
        }
        
        guard let api = request.api, case let .fullTick(secu, _, level, sortDirection, session, page) = api else {
            failed?()
            return
        }
        let key = secu.market + secu.symbol
        guard let tickData = fullTkDataPool[key],
              let page = tickData.nextPageCtx else {
                failed?()
                return
        }
        let nextApi: API = .fullTick(secu, count: tickCount, level: level, sortDirection: sortDirection, session: 0, pageCtx: ["seq": page.seq ?? 0, "from": page.from ?? 0, "session": page.session ?? 0])
        let handler = request.tickHandler
        _ = service.request(nextApi) { [weak self] (response: YXResponseType<YXTickData>) in
            guard let strongSelf = self else { return }
            
            switch response {
            case .success(let result, let code):
                switch code {
                case .success?:
                    let list = result.data?.list?.reversed() ?? []
                    if list.count > 0 {
                        tickData.list = list + (tickData.list ?? [])
                        tickData.nextPageCtx = result.data?.nextPageCtx
                        strongSelf.fullTkDataPool[key] = tickData
                        
                        handler?(tickData, .http)
                    }
                    succeed?(list.count < strongSelf.tickCount)
                default:
                    failed?()
                }
            case .failed(_):
                failed?()
            }
        }
    }


    fileprivate func btNextTick(_ request: YXQuoteRequest, succeed: NoMoreHandler?, failed: FailedHandler?) {

        guard let api = request.api, case let .btTick(secu, start: _, count: _, sortDirection: sortDirection) = api else {
            failed?()
            return
        }
        var topic = YXSocketTopic(tkWithMarket: secu.market, symbol: secu.symbol, status: .intraday, extraQuote: .none)

        guard let tickData = tkDataPool[topic.topicDescription()],
              let nextPageStart = tickData.nextPageStart?.value else {
            failed?()
            return
        }

        let nextApi: API = .btTick(secu, start: nextPageStart, count: Int32(tickCount), sortDirection: sortDirection)

        let handler = request.tickHandler
        _ = service.request(nextApi) { [weak self] (response: YXResponseType<YXTickData>) in
            guard let strongSelf = self else { return }

            switch response {
                case .success(let result, let code):
                    switch code {
                        case .success?:
                            let list = result.data?.list?.reversed() ?? []
                            if list.count > 0 {
                                tickData.list = list + (tickData.list ?? [])
                                strongSelf.tkDataPool[topic.topicDescription()] = tickData

                                handler?(tickData, .http)
                            }
                            succeed?(list.count < strongSelf.tickCount)
                        default:
                            failed?()
                    }
                case .failed(_):
                    failed?()
            }
        }
    }
    
    @objc public func subTimeLineQuote(secu: Secu, days: String, level: QuoteLevel, type: QuoteType, handler: @escaping TimeLineHandler, failed: FailedHandler? = nil) -> YXQuoteRequest {
        let timeInterval = TimeInterval(YXGlobalConfigManager.configFrequency(.delayTimesharingFreq))
        var repeatTimes = 1
        if level == .delay {
            repeatTimes = Int.max
        }
        
        let request = YXQuoteRequest()
        request.scheme = .http
        request.secus = [secu]
        request.timeLineHandler = handler
        request.subType = .timeLine
        request.level = level
        request.quoteType = type
        request.api = .timeLine(secu, days: days, level: level, type: type)
        
        request.quoteFlag = YXTimerSingleton.shareInstance().transactOperation({ [weak self] (_) in
            guard let strongSelf = self else { return }
            
            request.dispose = strongSelf.service.request(request.api!) { [weak self] (response: YXResponseType<YXTimeLineData>) in
                guard let strongSelf = self else { return }
                
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        if let data = result.data {
                            handler(data, .http)
                            
                            var topic = YXSocketTopic(tsWithMarket: secu.market, symbol: secu.symbol, status: .intraday, extraQuote: secu.extra)
                            if type == .pre {
                                topic = YXSocketTopic(tsWithMarket: secu.market, symbol: secu.symbol, status: .pre, extraQuote: secu.extra)
                            } else if type == .after {
                                topic = YXSocketTopic(tsWithMarket: secu.market, symbol: secu.symbol, status: .after, extraQuote: secu.extra)
                            }
                            strongSelf.tsDataPool[topic.topicDescription()] = data
                            
                            if level == .level2 || level == .level1 || level == .usNational {
                                request.scheme = .tcp
                                strongSelf.requestPool[request.quoteFlag] = request
                                request.seqFlag = YXSocketSingleton.shareInstance().sub(withServer: [topic], target: strongSelf)
                            }
                        } else {
                            failed?()
                        }
                    default:
                        failed?()
                    }
                case .failed(_):
                    failed?()
                }
                
            }
            }, timeInterval: timeInterval, repeatTimes: repeatTimes, atOnce: true)
        
        requestPool[request.quoteFlag] = request
        
        return request
    }
    
    @objc public func subFullTimeLineQuote(secu: Secu, days: String, level: QuoteLevel, type: QuoteType, handler: @escaping TimeLineHandler, failed: FailedHandler? = nil) -> YXQuoteRequest {
        let timeInterval = TimeInterval(YXGlobalConfigManager.configFrequency(.delayTimesharingFreq))
        var repeatTimes = 1
        if level == .delay {
            repeatTimes = Int.max
        }
        
        let request = YXQuoteRequest()
        request.scheme = .http
        request.secus = [secu]
        request.timeLineHandler = handler
        request.subType = .timeLine
        request.level = level
        request.quoteType = type
        request.api = .fullTimeLine(secu, days: days, level: level, type: type)
        
        request.quoteFlag = YXTimerSingleton.shareInstance().transactOperation({ [weak self] (_) in
            guard let strongSelf = self else { return }
            
            request.dispose = strongSelf.service.request(request.api!) { [weak self] (response: YXResponseType<YXFullTimeLineData>) in
                guard let strongSelf = self else { return }
                
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        if let data = result.data {
                            // 解析json的数组
                            data.decodeTimeList()
                            
                            handler(data.transformTimeLineData(), .http)
                            let intraTopic = YXSocketTopic(tsWithMarket: secu.market, symbol: secu.symbol, status: .intraday, extraQuote: secu.extra)
                            let preTopic = YXSocketTopic(tsWithMarket: secu.market, symbol: secu.symbol, status: .pre, extraQuote: secu.extra)
                            let afterTopic = YXSocketTopic(tsWithMarket: secu.market, symbol: secu.symbol, status: .after, extraQuote: secu.extra)
                            strongSelf.fullTsDataPool[(secu.market + secu.symbol)] = data
                            if level == .level2 || level == .level1 || level == .usNational {
                                request.scheme = .tcp
                                strongSelf.requestPool[request.quoteFlag] = request
                                request.seqFlag = YXSocketSingleton.shareInstance().sub(withServer: [intraTopic, preTopic, afterTopic], target: strongSelf)
                            }
                            
                            
                        } else {
                            failed?()
                        }
                    default:
                        failed?()
                    }
                case .failed(_):
                    failed?()
                }
                
            }
            }, timeInterval: timeInterval, repeatTimes: repeatTimes, atOnce: true)
        
        requestPool[request.quoteFlag] = request
        
        return request
    }
    
    
    @objc public func subBatchTimeLine(secus: [Secu], level: QuoteLevel, handler: @escaping BatchTimeLineHandler, failed: FailedHandler? = nil) -> YXQuoteRequest {
        let timeInterval = TimeInterval(YXGlobalConfigManager.configFrequency(.quotesResendFreq))
        var repeatTimes = 1
        if level == .delay {
            repeatTimes = Int.max
        }
        
        let request = YXQuoteRequest()
        request.scheme = .http
        request.secus = secus
        request.batchTimeLineHandler = handler
        request.subType = .batchTimeLine
        request.level = level
        request.api = .batchTimeLine(secus, days: "1", level: level)
        
        request.quoteFlag = YXTimerSingleton.shareInstance().transactOperation({ [weak self] (_) in
            guard let strongSelf = self else { return }
            
            request.dispose = strongSelf.service.request(request.api!) { (response: YXResponseType<YXBatchTimeLineData>) in

                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        let list = result.data?.list ?? []
                        handler(list)
                    default:
                        failed?()
                    }
                case .failed(_):
                    failed?()
                }
            }
            }, timeInterval: timeInterval, repeatTimes: repeatTimes, atOnce: true)
        
        requestPool[request.quoteFlag] = request
        return request
    }

    @objc public func onceHistoryTimeLineQuote(secu: Secu, days: String, level: QuoteLevel, type: QuoteType, date: Int64, handler: @escaping TimeLineHandler, failed: FailedHandler? = nil)  {

        let api: API = .historyTimeLine(secu, days: days, level: level, type: type, date: date)

        _ = service.request(api) { (response: YXResponseType<YXTimeLineData>) in

            switch response {
                case .success(let result, let code):
                    switch code {
                        case .success?:
                            if let data = result.data {
                                handler(data, .http)

                            } else {
                                failed?()
                            }
                        default:
                            failed?()
                    }
                case .failed(_):
                    failed?()
            }

        }
    }

    //MARK: 数字货币排行榜
    @objc public func cryptosRank(_ handler: @escaping RtHandler, failed: FailedHandler? = nil)  {

        let api: API = .btRank

        _ = self.service.request(api) { [weak self] (response: YXResponseType<YXV2QuoteList>) in
            guard let strongSelf = self else { return }

            switch response {
                case .success(let result, let code):
                    switch code {
                        case .success?:
                            var list = result.data?.list ?? []
                            handler(list, .http)

                        default:
                            failed?()
                    }
                case .failed(_):
                    failed?()
            }
        }
    }
    
    //MARK: DepthOrder 深度摆盘
    @objc public func subDepthOrder(secu: Secu, type: Int, depthType: YXSocketDepthType = .none, handler: @escaping DepthOrderHandler, failed: FailedHandler? = nil) -> YXQuoteRequest {

        let request = YXQuoteRequest()
        request.scheme = .http
        request.secus = [secu]
        request.depthOrderHandler = handler
        request.level = .level2
        if depthType == .chart {
            request.subType = .depthChart
            request.api = .depthChart(secu.market, symbol: secu.symbol, type: type)
        } else {
            request.subType = .depthOrder
            request.api = .depthOrder(secu.market, symbol: secu.symbol, type: type, merge: (depthType == .merge))
        }
        
        let timeInterval = TimeInterval(YXGlobalConfigManager.configFrequency(.delayKlineFreq))
        request.quoteFlag = YXTimerSingleton.shareInstance().transactOperation({ [weak self] (_) in
            guard let strongSelf = self else { return }
            
            request.dispose = strongSelf.service.request(request.api!) { [weak self] (response: YXResponseType<YXDepthOrderData>) in
                guard let strongSelf = self else { return }
                
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        if let data = result.data {
                            
                            handler(data, .http)
                            
                            var topic = YXSocketTopic(depthWithMarket: secu.market, symbol: secu.symbol, type: depthType)

                            strongSelf.depthDataPool[topic.topicDescription()] = data

                            request.scheme = .tcp
                            strongSelf.requestPool[request.quoteFlag] = request
                            request.seqFlag = YXSocketSingleton.shareInstance().sub(withServer: [topic], target: strongSelf)
                        } else {
                            failed?()
                        }
                    default:
                        failed?()
                    }
                case .failed(_):
                    failed?()
                }
            }
            
        }, timeInterval: timeInterval, repeatTimes: 1, atOnce: true)
        
        requestPool[request.quoteFlag] = request
        
        return request
    }
    
    @objc public func subPosAndBroker(secu: Secu, level: QuoteLevel, handler: @escaping PosBrokerHandler, failed: FailedHandler? = nil) -> YXQuoteRequest {

        let timeInterval = TimeInterval(YXGlobalConfigManager.configFrequency(.delayKlineFreq))
        let repeatTimes = 1
//        if level == .delay {
//            repeatTimes = Int.max
//        }
        ///兼容港版传统报价, bmp进来的时候,要获取delay的数据
        var changeLevel = level
        if level == .bmp {
            changeLevel = .delay
        }
        let request = YXQuoteRequest()
        request.scheme = .http
        request.secus = [secu]
        request.posBrokerHandler = handler
        request.subType = .posBroker
        request.level = level
        request.api = .detail([secu], props: ["brokerData", "pos", "greyMarket", "priceBase", "latestPrice", "msInfo", "preClose",  "greyFlag", "type1", "type2", "type3", "level"], level: changeLevel)
        
        request.quoteFlag = YXTimerSingleton.shareInstance().transactOperation({ [weak self] (_) in
            guard let strongSelf = self else { return }
            request.dispose = strongSelf.service.request(request.api!) { [weak self] (response: YXResponseType<PosBrokerList>) in
                guard let strongSelf = self else { return }
                
                switch response {
                case .success(let result, let code):
                    switch code {
    //                pos broker
                    case .success?:
                        if let model = result.data?.list?.last {
                            handler(model, .http)
                            if level == .level2 || level == .level1 || level == .usNational {
                                if let market = model.market, let symbol = model.symbol {
                                    var topics = [YXSocketTopic]()
                                    let posTopic = YXSocketTopic.init(posWithMarket: market, symbol: symbol, extraQuote: secu.extra)
                                    topics.append(posTopic)
                                    let key = market + symbol + posTopic.getExtraQuoteStr()
                                    strongSelf.posBrokerDataPool[key] = model
                                    
                                    if market == "hk" {
                                        let brokerTopic = YXSocketTopic.init(brokerWithMarket: market, symbol: symbol, extraQuote: secu.extra)
                                        topics.append(brokerTopic)
                                    }
                                    request.scheme = .tcp
                                    strongSelf.requestPool[request.quoteFlag] = request
                                    request.seqFlag = YXSocketSingleton.shareInstance().sub(withServer: topics, target: strongSelf)
                                }
                            }
                        } else {
                            failed?()
                        }
                                            
                    default:
                        failed?()
                    }
                case .failed(_):
                    failed?()
                }
            }
            
            }, timeInterval: timeInterval, repeatTimes: repeatTimes, atOnce: true)
        

        
        requestPool[request.quoteFlag] = request
        return request
    }
    
}

extension YXQuoteManager: YXSocketReceiveDataProtocol {
    public func socketDidReceive(_ clientPush: API_CLIENTPush) {
        if let topicString = clientPush.topic {
            let socketTopic = YXSocketTopic(string: topicString)

            if let quotePush = clientPush.quoteArray.firstObject as? API_CLIENTQuotePush {
                var extraStr: String = ""
                switch quotePush.type {
                    case .rt:
                        guard quotePush.hasRt, let rtPush = quotePush.rt else {
                            return
                        }
                        if socketTopic.pushType == .pos {
                            let key = socketTopic.market() + socketTopic.symbol + socketTopic.getExtraQuoteStr()
                            if rtPush.hasQuote, let pbQuote = rtPush.quote, let model = self.posBrokerDataPool[key] {
                                self.requestPool.values.forEach { (request) in
                                    if request.subType == .posBroker, request.secus.contains(where: { $0.market == socketTopic.market() && $0.symbol == socketTopic.symbol && $0.extra == socketTopic.extraQuote }) {
                                        model.pos = YXV2QuoteUtils.rtPosQuote(from: pbQuote)
                                        request.posBrokerHandler?(model, .tcp)
                                    }
                                }
                            }
                        } else if socketTopic.pushType == .broker {
                            let key = socketTopic.market() + socketTopic.symbol + socketTopic.getExtraQuoteStr()
                            if rtPush.hasQuote, let pbQuote = rtPush.quote, let model = self.posBrokerDataPool[key] {
                                self.requestPool.values.forEach { (request) in
                                    if request.subType == .posBroker, request.secus.contains(where: { $0.market == socketTopic.market() && $0.symbol == socketTopic.symbol && $0.extra == socketTopic.extraQuote }) {
                                        model.brokerData = YXV2QuoteUtils.rtBrokerQuote(from: pbQuote)
                                        request.posBrokerHandler?(model, .tcp)
                                    }
                                }
                            }
                        } else {
                            var tempRecvValue: YXV2Quote?
                            if rtPush.hasQuote, let pbQuote = rtPush.quote {
                                tempRecvValue = YXV2QuoteUtils.rtQuote(from: pbQuote)
                            } else if rtPush.hasCryptosData, let btData = rtPush.cryptosData {
                                tempRecvValue = YXV2QuoteUtils.btQuote(from: btData)
                            }

                            guard let recvValue = tempRecvValue else {
                                return
                            }

                            if rtPush.hasCryptosData {
                                recvValue.supplementaryQuote()
                            }

                            guard let newValue = self.rtDataPool[topicString]?.deepMerged(with: recvValue) else { return }

                            self.rtDataPool[topicString] = newValue
                            self.requestPool.values.forEach { (quoteRequest) in
                                if socketTopic.scene == .qsMobileBrief1 {
                                    if quoteRequest.subType == .rtSimple {
                                        if quoteRequest.secus.contains(where: { $0.market == socketTopic.market() && $0.symbol == socketTopic.symbol && $0.extra == socketTopic.extraQuote }) {
                                            quoteRequest.rtHandler?([newValue], .tcp)
                                        }
                                    }
                                } else {
                                    if quoteRequest.subType == .rtFull || quoteRequest.subType == .rtSimple {
                                        if quoteRequest.secus.contains(where: { $0.market == socketTopic.market() && $0.symbol == socketTopic.symbol && $0.extra == socketTopic.extraQuote }) {
                                            quoteRequest.rtHandler?([newValue], .tcp)
                                        }
                                    }
                                }
                            }
                        }
                    case .ts, .tspre, .tsafter:
                        guard quotePush.hasTs, let pbData = quotePush.ts?.data_p else {
                            return
                        }
                        let timeLine = YXV2QuoteUtils.tsQuote(from: pbData)
                        let time = pbData.latestTime
                        
                        var isAllTimeLine = false
                        var timeLineRequest: YXQuoteRequest?
                        self.requestPool.values.forEach { (quoteRequest) in
                            if quoteRequest.subType == .timeLine, quoteRequest.secus.contains(where: { $0.market == socketTopic.market() && $0.symbol == socketTopic.symbol && $0.extra == socketTopic.extraQuote }) {
                                
                                if quoteRequest.quoteType == .sQuoteAll {
                                    // 全部
                                    isAllTimeLine = true
                                    timeLineRequest = quoteRequest
                                } else {
                                    if quotePush.type == .tspre, quoteRequest.quoteType == .pre {
                                        timeLineRequest = quoteRequest
                                    } else if quotePush.type == .tsafter, quoteRequest.quoteType == .after {
                                        timeLineRequest = quoteRequest
                                    } else if quotePush.type == .ts, quoteRequest.quoteType == .intraDay {
                                        timeLineRequest = quoteRequest
                                    }
                                }
                                
                            }
                        }
                        
                        if !isAllTimeLine {
                            guard let ts = self.tsDataPool[topicString] else { return }

                            var isOneDay = false
                            if let api = timeLineRequest?.api, case let .timeLine(_, days: days, level: _, type: _) = api {
                                isOneDay = (days == "1")
                            }

                            var isContains = false
                            var replaceIndex = 0
                            var list = ts.list ?? []

                            let div = Int64(1e9)
                            let nowTime = Int64(time)
                            let oldTime = Int64(list.first?.latestTime?.value ?? 0)
                            if isOneDay, nowTime - oldTime >= div {
                                //判断不是同一天，且是1日分时，重置数据
                                list = [timeLine]
                            } else {
                                
                                if let lastLatestTime = list.last?.latestTime?.value, time <= lastLatestTime {
                                    
                                    if time == lastLatestTime {
                                        list[list.count - 1] = timeLine
                                    } else {
                                        
                                        for (index, value) in list.reversed().enumerated() {
                                            if value.latestTime?.value == time {
                                                isContains = true
                                                replaceIndex = list.count - index - 1
                                                break
                                            }
                                        }
                                        
                                        if (isContains) {
                                            list[replaceIndex] = timeLine
                                        } else {
                                            return
                                        }
                                    }
                                    
                                } else { //添加
                                    list.append(timeLine)
                                }
                                
                            }

                            ts.list = list

                            var newTs = ts
                            if let priceBase = quotePush.ts?.priceBase, priceBase > 0 {
                                newTs.priceBase = NumberUInt32(priceBase)
                                self.tsDataPool[topicString] = newTs
                            }
                            timeLineRequest?.timeLineHandler?(newTs, .tcp)
                        } else {
                            let key = socketTopic.market() + socketTopic.symbol
                            guard let ts = self.fullTsDataPool[key] else { return }
                            guard let timeData = ts.dayList?.last else { return }
                            
                            var isOneDay = false
                            if let api = timeLineRequest?.api, case let .timeLine(_, days: days, level: _, type: _) = api {
                                isOneDay = (days == "1")
                            }

                            var isContains = false
                            var replaceIndex = 0
                            var list: [YXTimeLine] = []
                            
                            
                            
                            if quotePush.type == .tspre {
                                list = timeData.preList ?? []
                            } else if quotePush.type == .tsafter {
                                list = timeData.afterList ?? []
                            } else {
                                list = timeData.intraList ?? []
                            }
                            
                            let div = Int64(1e9)
                            let nowTime = Int64(time)
                            let oldTime = Int64(list.first?.latestTime?.value ?? 0)
                            if isOneDay, nowTime - oldTime >= div {
                                //判断不是同一天，且是1日分时，重置数据
                                list = [timeLine]
                            } else {
                                
                                if let lastLatestTime = list.last?.latestTime?.value, time <= lastLatestTime {
                                    
                                    if time == lastLatestTime {
                                        list[list.count - 1] = timeLine
                                    } else {
                                        
                                        for (index, value) in list.reversed().enumerated() {
                                            if value.latestTime?.value == time {
                                                isContains = true
                                                replaceIndex = list.count - index - 1
                                                break
                                            }
                                        }
                                        
                                        if (isContains) {
                                            list[replaceIndex] = timeLine
                                        } else {
                                            return
                                        }
                                    }
                                    
                                } else { //添加
                                    list.append(timeLine)
                                }
                                
                            }
                            
                            if quotePush.type == .tspre {
                                timeData.preList = list
                            } else if quotePush.type == .tsafter {
                                timeData.afterList = list
                            } else {
                                timeData.intraList = list
                            }

                            var newTs = ts
                            if let priceBase = quotePush.ts?.priceBase, priceBase > 0 {
                                newTs.priceBase = NumberUInt32(priceBase)
                                self.fullTsDataPool[key] = newTs
                            }
                            timeLineRequest?.timeLineHandler?(newTs.transformTimeLineData(), .tcp)
                            
                        }

                    case .tk, .tkpre, .tkafter:
                        guard quotePush.hasTk, let tkData = quotePush.tk else {
                            return
                        }
                        var isFullTick = false
                        var tickRequest: YXQuoteRequest?
                        self.requestPool.values.forEach { (quoteRequest) in
                            if quoteRequest.subType == .tick, quoteRequest.secus.contains(where: { $0.market == socketTopic.market() && $0.symbol == socketTopic.symbol && $0.extra == socketTopic.extraQuote }) {
                                if quoteRequest.quoteType == .sQuoteAll {
                                    tickRequest = quoteRequest
                                    isFullTick = true
                                } else {
                                    if quotePush.type == .tkpre, quoteRequest.quoteType == .pre {
                                        tickRequest = quoteRequest
                                    } else if quotePush.type == .tkafter, quoteRequest.quoteType == .after {
                                        tickRequest = quoteRequest
                                    } else if quotePush.type == .tk, quoteRequest.quoteType == .intraDay {
                                        tickRequest = quoteRequest
                                    }
                                }
                            }
                        }
                        
                        var tempTick: YXTick?
                        var time: UInt64 = 0
                        var id_p: UInt64 = 0

                        var isCryptos = false

                        if tkData.hasCryptosData, let pbData = tkData.cryptosData {

                            tempTick = YXV2QuoteUtils.btTkQuote(from: pbData)
                            time = pbData.latestTime
                            id_p = UInt64(pbData.id_p)
                            isCryptos = true
                        } else if let pbData = tkData.data_p {
                            tempTick = YXV2QuoteUtils.tkQuote(from: pbData)
                            time = pbData.time
                            id_p = pbData.id_p
                        }
                        
                        guard let tick = tempTick else { return }
                                                
                        var tk: YXTickData?
                        if isFullTick {
                            let key = socketTopic.market() + socketTopic.symbol
                            tk = self.fullTkDataPool[key]
                        } else {
                            tk = self.tkDataPool[topicString]
                        }
                        guard let tk = tk else { return }

                        var isContains = false
                        var replaceIndex = 0
                        var list = tk.list ?? []

                        let valueTime = isCryptos ? list.last?.latestTime?.value : list.last?.time?.value
                        if let lastLatestTime = valueTime, time <= lastLatestTime,
                           let lastId = list.last?.id?.value, id_p <= lastId {
                            
                            if time == lastLatestTime, lastId == id_p {
                                list[list.count - 1] = tick
                            } else {
                                for (index, value) in list.reversed().enumerated() {
                                    let valueTime = isCryptos ? value.latestTime?.value : value.time?.value
                                    if valueTime == time, value.id?.value == id_p {
                                        isContains = true
                                        replaceIndex = list.count - index - 1
                                        break
                                    }
                                }
                                
                                if (isContains) {
                                    list[replaceIndex] = tick
                                } else {
                                    return
                                }
                            }
                            
                        } else {
                            list.append(tick)
                        }

                        tk.list = list

                        var newTk = tk
                        
                        
                        
                        if isCryptos {
//                            self.tkDataPool[topicString] = newTk
                        } else if let priceBase = quotePush.tk?.priceBase, priceBase > 0 {
                            newTk.priceBase = NumberUInt32(priceBase)
//                            self.tkDataPool[topicString] = newTk
                        }
                        
                        if isFullTick {
                            self.fullTkDataPool[(socketTopic.market() + socketTopic.symbol)] = newTk
                        } else {
                            self.tkDataPool[topicString] = newTk
                        }
                        
                        tickRequest?.tickHandler?(newTk, .tcp)

                    case .kl:
                        guard quotePush.hasKl, let klData = quotePush.kl else {
                            return
                        }
                        var tempKL: YXKLine?
                        var time: UInt64 = 0
                        var isCryptos = false
                        if klData.hasCryptosData, let pbData = klData.cryptosData {

                            tempKL = YXV2QuoteUtils.btKlQuote(from: pbData)
                            time = pbData.latestTime
                            isCryptos = true
                        } else if let pbData = klData.data_p {
                            tempKL = YXV2QuoteUtils.klQuote(from: pbData)
                            time = pbData.latestTime
                        }

                        guard let kLine = tempKL, let kl = self.klDataPool[topicString] else { return }

                        var isContains = false
                        var replaceIndex = 0
                        var list = kl.list ?? []

                        if let lastLatestTime = list.last?.latestTime?.value, time <= lastLatestTime {
                            
                            if time == lastLatestTime {
                                list[list.count - 1] = kLine
                            } else {
                                for (index, value) in list.reversed().enumerated() {
                                    if value.latestTime?.value == time {
                                        isContains = true
                                        replaceIndex = list.count - index - 1
                                        break
                                    }
                                }
                                
                                if (isContains) {
                                    list[replaceIndex] = kLine
                                } else {
                                    return
                                }
                            }
                            
                        } else {
                            
                            if isCryptos {
                                if let count = kl.count?.value, count == self.btTimeLineCount {
                                    //数字货币分时 固定1440个点
                                    list.removeFirst()
                                }
                                list.append(kLine)
                            } else {
                                list.append(kLine)
                            }
                        }

                        kl.list = list

                        var newKl = kl

                        if isCryptos {
                            self.klDataPool[topicString] = newKl
                        } else if let priceBase = quotePush.kl?.priceBase, priceBase > 0 {
                            newKl.priceBase = NumberUInt32(priceBase)
                            self.klDataPool[topicString] = newKl
                        }

                        self.requestPool.values.forEach { (quoteRequest) in
                            if
                                quoteRequest.subType == .kLine,
                                quoteRequest.secus.contains(where: { $0.market == socketTopic.market() && $0.symbol == socketTopic.symbol && $0.extra == socketTopic.extraQuote }),
                                let api = quoteRequest.api {

                                if case let .kLine(_, type, direction, _, _, _) = api,
                                   type == socketTopic.kLineType,
                                   direction == socketTopic.direction {
                                    quoteRequest.kLineHandler?(newKl, .tcp)
                                } else if case let .btKLine(_, type: type, start: _, count: _) = api, type == socketTopic.kLineType, socketTopic.direction == .kdNone  {
                                    quoteRequest.kLineHandler?(newKl, .tcp)
                                }

                            }
                        }
                case .ob, .obchart:
                    guard quotePush.hasOb, let ob = quotePush.ob, ob.hasOrderBook, let orderBook = ob.orderBook else {
                        return
                    }
                    
                    guard let tempDepthData = self.depthDataPool[topicString] else {
                        return
                    }
                    
                    let depthData = YXV2QuoteUtils.depthOrderQuote(from: orderBook)
                    depthData.priceBase = tempDepthData.priceBase
                    depthData.market = tempDepthData.market
                    depthData.symbol = tempDepthData.symbol
                    depthData.merge = tempDepthData.merge
                    
                    
                    self.requestPool.values.forEach { (quoteRequest) in
                        if socketTopic.depthType == .chart,
                           quoteRequest.subType == .depthChart,
                           quoteRequest.secus.contains(where: { $0.market == socketTopic.market() && $0.symbol == socketTopic.symbol }) {
                            
                            quoteRequest.depthOrderHandler?(depthData, .tcp)
                        } else if quoteRequest.subType == .depthOrder,
                                  (socketTopic.depthType == .merge || socketTopic.depthType == .none),
                                  quoteRequest.secus.contains(where: { $0.market == socketTopic.market() && $0.symbol == socketTopic.symbol }) {
                            
                            quoteRequest.depthOrderHandler?(depthData, .tcp)
                        }
                    }

                case .ms:
                    break
                case .cap:
                    break
                case .cn:
                    break
                default:
                    break
                }
            }
        }
    }
}

