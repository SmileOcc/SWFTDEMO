//
//  YXMarketAPI.swift
//  uSmartOversea
//
//  Created by youxin on 2019/12/12.
//  Copyright © 2019 RenRenDai. All rights reserved.
//
import Moya

let marketProvider = MoyaProvider<YXMarketAPI>(requestClosure: requestTimeoutClosure, session : YXMoyaConfig.session(), plugins: [YXNetworkLoggerPlugin(verbose: true)])

enum YXMarketAPI {
    case ipoCount
    case hsFund
    case ipoAD
    case dailyReplay(market: String)
    case recommendHotETF
}

extension YXMarketAPI: YXTargetType {
    var servicePath: String {
        switch self {
        case .ipoCount:
            return ""
        case .hsFund:
            return ""
        case .ipoAD:
            return ""
        case .dailyReplay:
            return ""
        case .recommendHotETF:
            return ""
        }
    }
    
    var contentType: String? {
        nil
    }
    
    var baseURL: URL {
        switch self {
        case .hsFund, .ipoAD, .dailyReplay,.recommendHotETF:
            return URL(string: YXUrlRouterConstant.hzBaseUrl())!
        default:
            return URL(string: YXUrlRouterConstant.jyBaseUrl())!
        }
    }
    
    public var requestType: YXRequestType {
        switch self {
        case .hsFund, .ipoAD, .dailyReplay,.recommendHotETF:
            return .hzRequest
        default:
            return .jyRequest
        }
    }
    
    var path: String {
        switch self {
        case .ipoCount:
            return "/stock-order-server/api/ipo-todycount/v2"
        case .hsFund:
            return "/quotes-dataservice-app/api/v2-2/scm"
        case .ipoAD:
            return "/news-configserver/api/v1/query/recommend"
        case .dailyReplay:
            return "/quotes-marketing/api/v1/everyday-review-get"
        case .recommendHotETF:
            return "/quotes-basic-service/api/hot-etf-push"
        }
        
    }
    
    var method: Moya.Method {
        switch self {
        case .hsFund, .ipoAD, .dailyReplay,.recommendHotETF:
            return .get
        default:
            return .post
        }
    }
    
    var sampleData: Data {
        switch self {
        default:
            return Data()
        }
    }
    
    var task: Task {
        var params: [String: Any] = [:]
        
        switch self {
        case .ipoCount:
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        case .hsFund:
            params["type"] = "2"
            return .requestParameters(parameters: params,
                                  encoding: URLEncoding.default)
        case .ipoAD:
            return .requestParameters(parameters: params,
            encoding: URLEncoding.default)
        case .dailyReplay(let market):
            params["market"] = market
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .recommendHotETF:
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
        
    }
    
    var headers: [String : String]? {
        yx_headers
    }
    
    
}
