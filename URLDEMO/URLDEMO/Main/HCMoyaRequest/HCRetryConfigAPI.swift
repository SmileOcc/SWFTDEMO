//
//  HCRetryConfigAPI.swift
//  URLDEMO
//
//  Created by odd on 7/3/22.
//

import UIKit
import Moya

public let HCRetryConfigProvider = MoyaProvider<HCRetryConfigAPI>(
    requestClosure: requestTimeoutClosure,
    session : HCMoyaConfig.session(),
    plugins: [HCNetworkLoggerPlugin(verbose: true)])


public enum HCRetryConfigAPI {
    case guests
}
    
extension HCRetryConfigAPI: HCTargetType {
    
    public var path: String {
           switch self {
            case .guests:
            return servicePath + "guests/v1"
        }
    }
    
    public var task: Task {
        var params: [String: Any] = [:]
        switch self {
        case .guests:
            params["source"] = "2"
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        default:
            return .requestPlain
        }
    }
    
    public var baseURL: URL {
        return URL(string: HCUrlRouterConstant.zxBaseUrl())!
    }
    
    public var servicePath: String {
        let path = "user-server"
        return "/\(path)/api/"
    }
    
    public var requestType: HCRequestType {
        return .hzRequest
    }
    
    public var method: Moya.Method {
        switch self {
        default:
            return .post
        }
    }
    
    public var headers: [String : String]? {
        switch self {
        default:
            return hc_headers
        }
    }
    
    public var contentType: String? {
        switch self {
        default:
            return nil
        }
    }
    
    public var sampleData: Data {
        switch self {
        default:
            return Data()
        }
    }
}

