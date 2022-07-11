//
//  YXTradeAPI.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/5/7.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Moya
import YXKit

let tradeProvider = MoyaProvider<YXTradeAPI>(requestClosure: requestTimeoutClosure, session : YXMoyaConfig.session(), plugins: [YXNetworkLoggerPlugin(verbose: true)])

enum YXDateFlag: String {
    case all = "0"
    case week = "1"
    case month = "2"
    case threeMonth = "3"
    case year = "4"
    case thisYear = "5"
    case unknown

    var text: String {
        switch self {
        case .all,
             .unknown:
            return YXLanguageUtility.kLang(key: "common_all")
        case .week:
            return YXLanguageUtility.kLang(key: "history_date_type_last_week")
        case .month:
            return YXLanguageUtility.kLang(key: "history_date_type_last_month")
        case .threeMonth:
            return YXLanguageUtility.kLang(key: "history_date_type_last_three_month")
        case .year:
            return YXLanguageUtility.kLang(key: "history_date_type_last_year")
        case .thisYear:
            return YXLanguageUtility.kLang(key: "hold_within_this_year")
        }
    }
}

extension YXDateFlag: Codable {
    public init(from decoder: Decoder) throws {
        self = try YXDateFlag(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}


enum YXTradeAPI {
    /**  客户股票资产查询
     /aggregation-server/api/user-asset-aggregation/v1    */
    case stockAsset (_ exchange: YXExchangeType, _ extendStatusBit: Int)
    case bondHold
    case bondCancelOrder (_ orderNo: String, _ tradeToken: String)
    case hold (_ exchange: YXExchangeType?)
    case hisEntrust (_ market: YXMarketFilterType, _ dateFlag: String, _ pageNum: Int, _ pageSize: Int, _ entrustStatus: String, _ entrustBeginDate: String, _ entrustEndDate: String, _ stockCode: String, _ symbolType: String)
    case bondOrderList (_ market: Int, _ queryType: YXDateFlag, _ pageNum: Int, _ pageSize: Int)
    case orderDetail (_ entrustId: String)
    case dayMarginOrderDetail (_ entrustId: String)
    case shortSellOrderDetail (_ entrustId: String)
    
    // 獲取歷史記錄列表
    case historyList (_ dateType: Int, type: Int, pageNum: UInt, pageSize: UInt, startTime: String, endTime: String, status: String)
    /* http://jy-dev.yxzq.com/stock-capital-server/doc/doc.html
    -> 面向换汇 -> init-currency-exchange-page/v1
    换汇申请页面初始化信息 */
    case currencyExchange (_ sourceCurrency: String, targetCurrency: String)
    /* http://jy-dev.yxzq.com/stock-capital-server/doc/doc.html
    -> 面向换汇 -> apply-currency-exchange/v1
    申请兑换币种 */
    case applyCurrencyExchange (_ amount: String, sourceMoneyType: String, targetMoneyType: String)
    
    case bondOrderDetail(orderNo: Int64)
    
    case getAppSystem(_ ids: [String])

}

extension YXTradeAPI: YXTargetType {
    public var path: String {
        switch self {
        /**  客户股票资产查询
         /aggregation-server/api/user-asset-aggregation/v1    */
        case .stockAsset:
            return servicePath + "user-asset-aggregation/v1"
        case .hold:
            return servicePath + "stock-holding/v1"
        case .bondHold:
            return servicePath + "get-bond-position/v1"
        case .bondCancelOrder:
            return servicePath + "cancel-bond-order/v1"
        case .hisEntrust:
            return servicePath + "order/query-his-order"
        case .bondOrderList:
            return servicePath + "get-bond-order-history/v1"
        case .orderDetail:
            return servicePath + "order/query-order-detail"
        case .dayMarginOrderDetail:
            return servicePath + "intradayOrderDetailInfo/v1"
        case .shortSellOrderDetail:
            return servicePath + "user-stock-order-detail/v1"
//        case .deleteConditionOrder(_):
//            return servicePath + "del-condition/v1""
        case .historyList:
            return servicePath + "business-flow/v1"
        case .currencyExchange:
            /* http://jy-dev.yxzq.com/stock-capital-server/doc/doc.html
             -> 面向换汇 -> init-currency-exchange-page/v1
             换汇申请页面初始化信息 */
            return servicePath + "exchange-rate-query/v1"
        case .applyCurrencyExchange:
            /* http://jy-dev.yxzq.com/stock-capital-server/doc/doc.html
            -> 面向换汇 -> apply-currency-exchange/v1
            申请兑换币种 */
            return servicePath + "apply-currency-exchange/v1"
        case .bondOrderDetail:
            return servicePath + "get-bond-order-detail/v1"
        case .getAppSystem:
            return servicePath + "get-app-system/v1"
        }
    }
    
    public var task: Task {
        var params: [String: Any] = [:]
        switch self {
        case .hold(let exchange):
            if let exchangeType = exchange?.rawValue {
                params["exchangeType"] = exchangeType
            }
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .bondHold:
            params["market"] = 2
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .hisEntrust(let market, let dateFlag, let pageNum , let pageSize, let entrustStatus, let entrustBeginDate, let entrustEndDate, let stockCode, let symbolType):
            var query : [String: Any] = [:]
            query["market"] = market.filterRequestValue
            query["entrustBeginDate"] = entrustBeginDate
            query["entrustEndDate"] = entrustEndDate
            query["symbol"] = stockCode
            query["symbolType"] = symbolType
            query["status"] = entrustStatus
            query["dateFlag"] = dateFlag

            params["query"] = query
            params["pageNum"] = pageNum
            params["pageSize"] = pageSize
//            params["orderDirection"] = 0
//            params["entrustStatus"] = entrustStatus
//            params["stockCode"] = stockCode
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .bondCancelOrder(let orderNo, let tradeToken):
            params["orderNo"] = orderNo
            params["tradeToken"] = tradeToken
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .bondOrderList(let market, let dateFlag, let pageNum, let pageSize):
            params["market"] = market
            params["queryType"] = dateFlag.rawValue
            params["startDate"] = ""
            params["endDate"] = ""
            params["pageNum"] = pageNum
            params["pageSize"] = pageSize
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .orderDetail(let entrustId):
            params["orderId"] = entrustId
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .dayMarginOrderDetail(let entrustId):
            params["orderDetailId"] = entrustId
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .shortSellOrderDetail(let entrustId):
            params["orderId"] = entrustId
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .stockAsset(let exchange, let extendStatusBit):
            /**  客户股票资产查询
             /aggregation-server/api/user-asset-aggregation/v1     */
            params["exchangeType"] = exchange.rawValue
            params["extendStatusBit"] = extendStatusBit
            return .requestParameters(parameters: params,
                                      encoding: JSONEncoding.default)
        case .historyList(let dateType, let type, let pageNum, let pageSize, let startTime, let endTime, let status):
            params["dateType"] = dateType
            params["type"] = type
            params["pageNum"] = pageNum
            params["pageSize"] = pageSize
            params["startTime"] = startTime
            params["endTime"] = endTime
            params["status"] = status
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .currencyExchange(let sourceCurrency, let targetCurrency):
            /* http://jy-dev.yxzq.com/stock-capital-server/doc/doc.html
            -> 面向换汇 -> init-currency-exchange-page/v1
            换汇申请页面初始化信息 */
            params["sourceCurrency"] = sourceCurrency
            params["targetCurrency"] = targetCurrency
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .applyCurrencyExchange(let amount, let sourceMoneyType, let targetMoneyType):
            /* http://jy-dev.yxzq.com/stock-capital-server/doc/doc.html
            -> 面向换汇 -> apply-currency-exchange/v1
            申请兑换币种 */
            params["sourceAmount"] = amount
            params["sourceMoneyType"] = sourceMoneyType
            params["targetMoneyType"] = targetMoneyType
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .bondOrderDetail(orderNo: let orderNo):
            params["orderNo"] = orderNo
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .getAppSystem(let ids):
            params["serviceIdList"] = ids
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
        
    }
    
    public var baseURL: URL {
        switch self {
        default:
            return URL(string: YXUrlRouterConstant.jyBaseUrl())!
        }
    }
    
    public var requestType: YXRequestType {
        switch self {
        default:
            return .jyRequest
        }
    }
    
    public var servicePath: String {
        switch self {
        case .stockAsset:
            return "/aggregation-server/api/"
        case .getAppSystem:
            return "/config-manager-dolphin/api/"
        case .historyList, .currencyExchange, .applyCurrencyExchange:
            return "/capital-center-sg/api/"
        case .bondHold, .bondOrderList, .bondOrderDetail, .bondCancelOrder:
            return "/finance-server/api/"
        case .shortSellOrderDetail:
            return "/option-order-server/api/"
        case .hisEntrust,.orderDetail:
            return "/order-center-dolphin/api/"
        default:
            return "/stock-entrust-server-dolphin/api/"
        }
    }
    
    public var method: Moya.Method {
        switch self {

        case .historyList, .currencyExchange, .applyCurrencyExchange:
            return .post
        default:
            return .post
        }
    }
    
    public var headers: [String : String]? {
        let header = yx_headers
        return header
    }
    
    public var contentType: String? {
        nil
    }
    
    public var sampleData: Data {
        switch self {
        default:
            return Data()
        }
    }
}

