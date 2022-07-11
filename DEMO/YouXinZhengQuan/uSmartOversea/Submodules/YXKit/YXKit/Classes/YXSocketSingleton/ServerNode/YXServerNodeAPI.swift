//
//  YXServerNodeAPI.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2019/4/19.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import Moya

let YXServerNodeProvider = MoyaProvider<YXServerNodeAPI>(
    requestClosure: requestTimeoutClosure,
    session : YXMoyaConfig.session(),
    plugins: [YXNetworkLoggerPlugin(verbose: true)])

enum YXServerNodeAPI {
    case hzBaseUrl
    case hzIPUrl
    case hzConfigIPUrl
    case none
}

extension YXServerNodeAPI: YXTargetType {
    
    public var path: String {
        var tcpslb = "quotes-tcpslb"
        if YXConstant.appTypeValue == .ZTMASTER {
            tcpslb = "quotes-zt-tcpslb"
        }
        return "/\(tcpslb)/api/v1/tcpnodes"
    }
    
    public var task: Task {
       return .requestPlain
    }
    
    
    public var baseURL: URL {
        switch self {
        case .hzBaseUrl:
            return URL(string: YXUrlRouterConstant.hzBaseUrl())!
        case .hzIPUrl:
            var ipURL = YXUrlRouterConstant.hzIPUrl().first!
            if YXUrlRouterConstant.hzIPUrl().count > 1 {
                
                let index = Int(arc4random_uniform(UInt32(YXUrlRouterConstant.hzIPUrl().count)))
                ipURL = YXUrlRouterConstant.hzIPUrl()[index]
            }
            return URL(string: ipURL)!
        case .hzConfigIPUrl:
            if let ipUrl = YXGlobalConfigManager.tcpIpUrl(), ipUrl.count > 0 {
               return URL(string: ipUrl)!
            } else {
               return URL(string: YXUrlRouterConstant.hzBaseUrl())!
            }
        case .none:
            return URL(string: YXUrlRouterConstant.hzBaseUrl())!
        }
    }
    
    public var servicePath: String {
        return ""
    }
    
    public var requestType: YXRequestType {
        return .hzRequest
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    public var headers: [String : String]? {
        return yx_headers
    }
    
    public var contentType: String? {
        return "application/json"
    }
    
    public var sampleData: Data {
        switch self {
        default:
            return Data()
        }
    }
}

extension YXServerNodeAPI {
    
    func selfAdd() -> YXServerNodeAPI {
        var node: YXServerNodeAPI
        switch self {
        case .hzBaseUrl:
            node = .hzIPUrl
        case .hzIPUrl:
            if let ipUrl = YXGlobalConfigManager.tcpIpUrl(), ipUrl.count > 0 {
                node = .hzConfigIPUrl
            } else {
                node = .none
            }
        case .hzConfigIPUrl:
            node = .none
        default:
            node = .none
        }
        return node
    }
}


class YXServerNodeService: YXRequestable {
    
    typealias API = YXServerNodeAPI
    
    var networking: MoyaProvider<API> {
        return YXServerNodeProvider
    }
    
}
