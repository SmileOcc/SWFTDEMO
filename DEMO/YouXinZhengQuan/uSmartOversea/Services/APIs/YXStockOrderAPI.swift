//
//  YXStockOrderAPI.swift
//  uSmartOversea
//
//  Created by ellison on 2019/4/26.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import Moya

let stockOrderProvider = MoyaProvider<YXStockOrderAPI>(requestClosure: requestTimeoutClosure, session : YXMoyaConfig.session(), plugins: [YXNetworkLoggerPlugin(verbose: true)])

enum YXStockOrderAPI {
    case hold(_ exchangeType: YXExchangeType?)
}

extension YXStockOrderAPI: YXTargetType {
    var servicePath: String {
        "/stock-order-server/api/"
    }
    
    var contentType: String? {
        switch self {
        default:
            return nil
        }
    }
    
    var baseURL: URL {
        URL(string: YXUrlRouterConstant.jyBaseUrl())!
    }
    
    public var requestType: YXRequestType {
        return .jyRequest
    }
    
    var path: String {
        switch self {
        case .hold:
            return servicePath + "stock-holding/v1"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .hold:
            return .post
        }
    }
    
    var sampleData: Data {
        Data()
    }
    
    var task: Task {
        var params: [String: Any] = [:]
        switch self {
        case .hold(let exchangeType):
            if let exchangeType = exchangeType?.rawValue {
                params["exchangeType"] = exchangeType
            }
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        yx_headers
    }
}
