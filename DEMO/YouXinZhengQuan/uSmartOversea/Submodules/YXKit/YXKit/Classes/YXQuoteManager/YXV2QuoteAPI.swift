//
//  YXV2QuoteAPI.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2019/8/28.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import Moya

let v2quoteProvider = MoyaProvider<YXV2QuotesDataAPI>(
    requestClosure: requestTimeoutClosure,
    session : YXMoyaConfig.session(),
    plugins: [YXNetworkLoggerPlugin(verbose: true)])

public enum YXV2QuotesDataAPI {

    case detail(_ ids: [Secu], props: [String]?, level: QuoteLevel?)
    case simple(_ ids: [Secu], level: QuoteLevel?)
    case batchTimeLine(_ ids: [Secu],  days: String?,  level: QuoteLevel?)
    case timeLine(_ id: Secu, days: String?, level: QuoteLevel?, type: QuoteType?)
    case fullTimeLine(_ id: Secu, days: String?, level: QuoteLevel?, type: QuoteType?)
    case kLine(_ id: Secu, type: OBJECT_QUOTEKLineType, direction: OBJECT_QUOTEKLineDirection, start: String?, count: String?, level: QuoteLevel?)
    case tick(_ id: Secu, start: String?, tradeTime: String?, count: String?, level: QuoteLevel?, sortDirection: Int?, type: QuoteType?)
    case fullTick(_ id: Secu, count: Int?, level: QuoteLevel?, sortDirection: Int?, session: Int, pageCtx: [String: Int64])
    case ext(_ main: Secu, ah: Secu?, adr: Secu?)
    /* http://szshowdoc.youxin.com/web/#/23?page_id=662 -->
    quotes-analysis(行情分析服务) --> v1 --> 成交统计接口
    quotes-analysis-app/api/v1/statistic */
    case statistic(_ market:String, symbol:String, type:Int, nextPageRef:Int, marketTimeType: Int)
    case newStatistic(_ market:String, symbol:String, type:Int, bidOrAskType:Int, marketTimeType: Int, tradeDay: String, sortType: Int, sortMode: Int)
    case historyTimeLine(_ id: Secu, days: String, level: QuoteLevel?, type: QuoteType?, date: Int64?)
    case btDetail(_ ids: [Secu])
    case btKLine(_ ids: Secu, type: OBJECT_QUOTEKLineType, start: Int64?, count: Int32?)
    case btTick(_ ids: Secu, start: Int64?, count: Int32?, sortDirection: Int32?)
    case btBatchKLine(_ params: [[String : Any]])
    case btRank
    //摆盘类型，1：ArcaBook，10：新交所LV2深度摆盘
    case depthOrder(_ market: String, symbol: String, type: Int = 1, merge: Bool = false)
    //摆盘类型，1：ArcaBook，10：新交所LV2深度摆盘
    case depthChart(_ market: String, symbol: String, type: Int = 1)
}

extension YXV2QuotesDataAPI: YXTargetType {
    public var path: String {
        switch self {
        case .detail,
             .simple:
            return servicePath + "detail"
        case .batchTimeLine:
            return servicePath + "batchtimesharing"
        case .timeLine, .historyTimeLine, .fullTimeLine:
            return servicePath + "timesharing"
        case .kLine:
            return servicePath + "kline"
        case .tick, .fullTick:
            return servicePath + "tick"
        case .ext:
            return servicePath + "extquote"
        case .statistic, .newStatistic:
            /* http://szshowdoc.youxin.com/web/#/23?page_id=662 -->
             quotes-analysis(行情分析服务) --> v1 --> 成交统计接口
             quotes-analysis-app/api/v1/statistic */
            return servicePath + "statistic"
        case .btDetail:
            /* http://szshowdoc.youxin.com/web/#/23?page_id=2155 */
            return servicePath + "realtime"
        case .btKLine:
            /* http://szshowdoc.youxin.com/web/#/23?page_id=2154 */
            return servicePath + "kline"
        case .btTick:
            /* http://szshowdoc.youxin.com/web/#/23?page_id=2156 */
            return servicePath + "tick"
        case .btBatchKLine:
            /* http://szshowdoc.youxin.com/web/#/23?page_id=2157 */
            return servicePath + "batchkline"
        case .btRank:
            return servicePath + "rank"
        case .depthOrder:
            return servicePath + "depthorderbook"
        case .depthChart:
            return servicePath + "depthchart"
        }
    }
    
    public var task: Task {
        var params: [String: Any] = [:]
        switch self {
        case .detail(let ids, let props, let level):
            params["ids"] = ids.map { $0.dictionaryValue }
            params["props"] = props
            params["level"] = level?.paramValue
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .simple(let ids, let level):
            params["ids"] = ids.map { $0.dictionaryValue }
            params["props"] = YXV2Quote.CodingKeys.simpleRawValues()
            params["level"] = level?.paramValue
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .batchTimeLine(let ids, let days, let level):
            params["ids"] = ids.map { $0.dictionaryValue }
            params["days"] = days ?? "1"
            params["level"] = level?.paramValue
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .timeLine(let id, let days, let level, let type):
            params["market"] = id.market
            params["symbol"] = id.symbol
            params["greyMarket"] = id.greyMarketValue
            params["days"] = days
            params["level"] = level?.paramValue
            params["type"] = type?.rawValue
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .fullTimeLine(let id, let days, let level, let type):
            params["market"] = id.market
            params["symbol"] = id.symbol
            params["greyMarket"] = id.greyMarketValue
            params["days"] = days
            params["level"] = level?.paramValue
            //行情类型，0：全部，1：盘中，2：盘前行情，3：盘后行情(只有全部的分时用到,暂时写死)
            params["session"] = 0
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .kLine(let id, let type, let direction, let start, let count, let level):
            params["market"] = id.market
            params["symbol"] = id.symbol
            params["greyMarket"] = id.greyMarketValue
            params["type"] = String(type.rawValue)
            params["direction"] = String(direction.rawValue)
            params["start"] = start
            params["count"] = count
            params["level"] = level?.paramValue
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .tick(let id, let start, let tradeTime, let count, let level, let sortDirection, let type):
            params["market"] = id.market
            params["symbol"] = id.symbol
            params["greyMarket"] = id.greyMarketValue
            params["start"] = start
            params["tradeTime"] = tradeTime
            params["count"] = count
            params["level"] = level?.paramValue
            params["sortDirection"] = sortDirection
            params["type"] = type?.rawValue
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .fullTick(let id, let count, let level, let sortDirection, let session, let pageCtx):
            params["id"] = ["symbol": id.symbol, "market": id.market, "greyMarket": 1]
//            params["market"] = id.market
//            params["symbol"] = id.symbol
            params["count"] = count
            params["level"] = level?.paramValue
            params["sortDirection"] = sortDirection
            params["pageCtx"] = pageCtx
            params["session"] = session
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .ext(let main, let ah, let adr):
            params["main"] = ["market": main.market, "symbol": main.symbol]
            if let ah = ah {
                params["ah"] = ["market": ah.market, "symbol": ah.symbol]
            }
            if let adr = adr {
                params["adr"] = ["market": adr.market, "symbol": adr.symbol]
            }
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .statistic(let market, let symbol, let type, let nextPageRef, let marketTimeType):
            /* http://szshowdoc.youxin.com/web/#/23?page_id=662 -->
            quotes-analysis(行情分析服务) --> v1 --> 成交统计接口
            quotes-analysis-app/api/v1/statistic */
            params["market"] = market
            params["symbol"] = symbol
            params["type"] = type   //类型：0：最近20条，1：最近50条，2：全部
            params["marketTimeType"] = marketTimeType
            if type == 2 {
                //下一页的起始点，由上一页的结果返回 ，只有type为2时支持
                params["nextPageRef"] = nextPageRef
            }
            
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        
        case .newStatistic(let market, let symbol, let type, let bidOrAskType, let marketTimeType, let tradeDay, let sortType,  let sortMode):
            // 买卖方向：0：全部，1：主动买入，2：主动卖出 ，3：主动买入&卖出 ，4：中性盘
            // 市场时段：0：盘中时段，1：开盘竞价(美股盘前)时段，2：收盘竞价(美股盘后)时段 ，3：全部时段
            // 交易日，格式20200619000000000
            // 排序类型，0：成交价，1：主买，2：主卖 ，3：中性，4：成交量，5：占比
            // 排序类型，0：降序，1：升序
            params["market"] = market
            params["symbol"] = symbol
            params["type"] = type   //类型：0：最近20条，1：最近50条，2：全部
            params["bidOrAskType"] = bidOrAskType
            params["marketTimeType"] = marketTimeType
            params["tradeDay"] = tradeDay
            params["sortType"] = sortType
            params["sortMode"] = sortMode
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case let .historyTimeLine(id, days: days, level: level, type: type, date: date):

            params["market"] = id.market
            params["symbol"] = id.symbol
            params["days"] = days
            params["level"] = level?.paramValue
            params["type"] = type?.rawValue
            params["date"] = date
            return .requestParameters(parameters: params, encoding: URLEncoding.default)

        case .btDetail(let ids):
            params["ids"] = ids.map { $0.dictionaryValue }
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .btKLine(let ids, type: let type, start: let start, count: let count):
            params["id"] = ids.dictionaryValue
            params["type"] = type.rawValue
            params["start"] = start
            params["count"] = count
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .btTick(let ids, start: let start, count: let count, sortDirection: let sortDirection):
            params["id"] = ids.dictionaryValue
            params["start"] = start
            params["count"] = count
            params["sortDirection"] = sortDirection
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)

        case .btBatchKLine(let para):
            params["params"] = para
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .btRank:
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case let .depthOrder(market, symbol: symbol, type: type, merge: merge):
            params["market"] = market
            params["symbol"] = symbol
            params["type"] = type
            params["merge"] = merge
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case let .depthChart(market, symbol: symbol, type: type):
            params["market"] = market
            params["symbol"] = symbol
            params["type"] = type
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }
    
    public var baseURL: URL {
        return URL(string: YXUrlRouterConstant.hzBaseUrl())!
    }
    
    public var servicePath: String {
        var qds = "quotes-dataservice-app"
        if YXConstant.appTypeValue == .ZTMASTER {
            qds = "ztqt-dataservice-app"
        }

        switch self {
        case .btDetail, .btKLine, .btTick, .btBatchKLine, .btRank:
            return "/quotes-bt-qtservice/api/v1/"
        case .statistic, .newStatistic, .depthOrder, .depthChart:
            return "/\(qds)/api/v1/"
        case .ext:
            return "/\(qds)/api/v2-2/"
        case .fullTimeLine, .fullTick:
            return "/\(qds)/api/v3-1/"
        default:
            return "/\(qds)/api/v3/"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .timeLine, .fullTimeLine, .kLine, .tick, .statistic, .newStatistic, .historyTimeLine:
            return .get
        default:
            return .post
        }
    }
    
    public var headers: [String : String]? {
        return yx_headers
    }
    
    public var requestType: YXRequestType {
        return .hzRequest
    }
    
    public var contentType: String? {
        return nil
    }
    
    public var sampleData: Data {
        switch self {
        default:
            return Data()
        }
    }
}
