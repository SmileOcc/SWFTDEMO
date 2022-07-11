//
//  YXRetryConfigAPI.swift
//  Alamofire
//
//  Created by 井超 on 2019/11/7.
//

import UIKit
import Moya

public let YXRetryConfigProvider = MoyaProvider<YXRetryConfigAPI>(
    requestClosure: requestTimeoutClosure,
    session : YXMoyaConfig.session(),
    plugins: [YXNetworkLoggerPlugin(verbose: true)])


public enum YXRetryConfigAPI {
    case guests
}
    
extension YXRetryConfigAPI: YXTargetType {
    
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
        return URL(string: YXUrlRouterConstant.jyBaseUrl())!
    }
    
    public var servicePath: String {
        var path = "user-server"
        if YXConstant.appTypeValue == .ZTMASTER {
            path = "user-server-ztds"
        } else if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG{
            path = "user-server-dolphin"
        } else if YXConstant.appTypeValue == .EDUCATION {
            path = "user-server-rich"
        }
        return "/\(path)/api/"
    }
    
    public var requestType: YXRequestType {
        return .jyRequest
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
            return yx_headers
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


