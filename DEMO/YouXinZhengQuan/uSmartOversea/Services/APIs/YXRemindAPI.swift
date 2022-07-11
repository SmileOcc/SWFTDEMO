//
//  YXRemindAPI.swift
//  uSmartOversea
//
//  Created by 陈明茂 on 2019/5/26.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Moya

let reminderDataProvider = MoyaProvider<YXRemindAPI>(requestClosure: requestTimeoutClosure, session : YXMoyaConfig.session(), plugins: [YXNetworkLoggerPlugin(verbose: true)])

enum YXRemindAPI {

    case load(_ stockCode: String, _ market: String)
    case save(_ stockCode: String, _ market: String, _ notifyType: Int, _ condition: [[String: Any]])
    case delete(_ stockCode: String, _ market: String)
}

extension YXRemindAPI: YXTargetType {
    var servicePath: String {
        switch self {
        case .load, .save, .delete:
            return "/quotes-stocknotify/api/"
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
        case .load:
            return servicePath + "v1/get/rules"
        case .save:
            return servicePath + "v1/create/rules"
        case .delete:
            return servicePath + "v1/delete/rule"
        }
        
    }
    
    var method: Moya.Method {
        switch self {
        case .load:
            return .get
        case .save:
            return .post
        case .delete:
            return .delete
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
        case .load(let code, let market):
            params["stock_code"] = code
            params["stock_market"] = market
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        case .save(let code, let market, let notifyType, let conditionArr):
            params["stock_code"] = code
            params["stock_market"] = market
            params["notify_type"] = notifyType
            params["condition"] = conditionArr
            return .requestParameters(parameters: params,
                                      encoding: JSONEncoding.default)
        case .delete(let code, let market):
            params["stock_code"] = code
            params["stock_market"] = market
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        }
        
    }
    
    var headers: [String : String]? {
        yx_headers
    }
    
    
}
