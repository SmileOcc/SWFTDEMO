//
//  YXStockIntroduceAPI.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/7/19.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Moya

let introduceDataProvider = MoyaProvider<YXStockIntroduceAPI>(requestClosure: requestTimeoutClosure, session : YXMoyaConfig.session(), plugins: [YXNetworkLoggerPlugin(verbose: true)])

enum YXStockIntroduceAPI {
    case companyInfo(_ stockCode: String)
    case companyProfit(_ stockCode: String)
    case HSCompanyInfo(_ stockCode: String)
    case HSDividendInfo(_ stockCode: String)
}

extension YXStockIntroduceAPI: YXTargetType {
    var servicePath: String {
        switch self {
        case .companyInfo, .companyProfit, .HSCompanyInfo, .HSDividendInfo:
            return "/news-basicinfo/api/"
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
        case .companyInfo:
            return servicePath + "v1/companyprofile"
        case .companyProfit:
            return servicePath + "v1/stockdetail"
        case .HSCompanyInfo:
            return servicePath + "v1/a/companyprofile"
        case .HSDividendInfo:
            return servicePath + "v1/a/dividendrecord"
        }
        
    }
    
    var method: Moya.Method {
        switch self {
        case .companyInfo, .companyProfit, .HSCompanyInfo, .HSDividendInfo:
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
        case .companyInfo(let stockCode):
            params["stock"] = stockCode
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        case .companyProfit(let stockCode):
            params["stock"] = stockCode
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        case .HSCompanyInfo(let stockCode):
            params["stock"] = stockCode
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        case .HSDividendInfo(let stockCode):
            params["stock"] = stockCode
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        }
        
    }
    
    var headers: [String : String]? {
        yx_headers
    }
    
    
}
