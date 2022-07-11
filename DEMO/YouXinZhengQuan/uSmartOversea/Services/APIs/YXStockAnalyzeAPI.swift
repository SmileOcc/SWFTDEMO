//
//  YXStockAnalyzeAPI.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/7/29.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Moya

let stockAnalyzeDataProvider = MoyaProvider<YXStockAnalyzeAPI>(requestClosure: requestTimeoutClosure, session : YXMoyaConfig.session(), plugins: [YXNetworkLoggerPlugin(verbose: true)])

enum YXStockAnalyzeAPI {

    case capital(_ stockCode: String)
    case analyze(_ stockCode: String)
    case cashFlow(_ stockCode: String)
    case diagnoseScore(_ symbol: String)
}

extension YXStockAnalyzeAPI: YXTargetType {
    var servicePath: String {
        switch self {
        case .capital, .cashFlow:
            return "/quotes-dataservice-app/api/"
        case .analyze, .diagnoseScore:
            return "/news-stockdiagnosis/api/"
        }
    }
    
    var contentType: String? {
        nil
    }
    
    var baseURL: URL {
        switch self {
        default:
            return URL(string: YXUrlRouterConstant.hzBaseUrl())!
        }
    }
    
    public var requestType: YXRequestType {
        switch self {
        default:
            return .hzRequest
        }
    }
    
    var path: String {
        switch self {
        case .capital:
            return servicePath + "v2-2/mincapflow"
        case .analyze:
            return servicePath + "v1/query/diagnosescore"
        case .cashFlow:
            return servicePath + "v2-2/capflow"
        case .diagnoseScore:
            return servicePath + "v1/query/diagnosescore-app"
        }
        
    }
    
    var method: Moya.Method {
        switch self {
        case .capital, .analyze, .cashFlow, .diagnoseScore:
            return .get
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
        case .capital(let stockCode):
            params["id"] = stockCode
            params["type"] = "0"
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        case .analyze(let stockCode):
            params["symbol"] = stockCode
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        case .cashFlow(let stockCode):
            params["id"] = stockCode
            params["type"] = "0"
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        case .diagnoseScore(let symbol):
            params["symbol"] = symbol
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        }
        
    }
    
    var headers: [String : String]? {
        yx_headers
    }
    
    
}
