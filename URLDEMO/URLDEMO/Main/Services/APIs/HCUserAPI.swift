//
//  HCUserAPI.swift
//  URLDEMO
//
//  Created by odd on 7/3/22.
//

import Foundation
import Moya

let userProvider = MoyaProvider<HCUserAPI>(requestClosure: requestTimeoutClosure, session : HCMoyaConfig.session(), plugins: [HCNetworkLoggerPlugin(verbose: true)])

public enum HCUserAPI {
    case changePwd (_ oldPassword: String, password: String)
    case bindWechat (_ accessToken: String, _ openId: String)
}

extension HCUserAPI: HCTargetType {
    
    public var path: String {
        switch self {
        case .changePwd:
             return servicePath + "update-login-password/v1"
        case .bindWechat:
             return servicePath + "wechat-bind/v1"
        }
    }
    
    public var task: Task {
        var params: [String: Any] = [:]
        switch self {
        
        case .changePwd(let oldPassword, let password):
            params["oldPassword"] = oldPassword
            params["password"] = password
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .bindWechat(let accessToken, let openId):
            params["accessToken"] = accessToken
            params["openId"] = openId
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        default:
            return .requestPlain
        }
    }
    
    public var baseURL: URL {
        return URL(string: HCUrlRouterConstant.zxBaseUrl())!
    }
    
    public var requestType: HCRequestType {
        switch self {
        case .changePwd:
            return .hzRequest
        default:
            return .hzRequest
        }
    }
    
    public var servicePath: String {
        switch self {
        case .changePwd:
            return "user-server/api/"
        default:
            return "/user-server/api/"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .changePwd:
            return .get
        default:
            return .post
        }
    }
    
    public var headers: [String : String]? {
        var headers = hc_headers
        if let contentType = contentType {
            headers["Content-Type"] = contentType
        }
        return headers
    }
    
    public var contentType: String? {
        switch self {
        case .changePwd:
            return "application/x-www-form-urlencoded"
        case .bindWechat:
            return "application/json"
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
