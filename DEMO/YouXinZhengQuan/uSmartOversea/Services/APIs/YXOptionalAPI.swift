//
//  YXSelfStockAPI.swift
//  uSmartOversea
//
//  Created by ellison on 2019/4/25.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import Moya

let optionalProvider = MoyaProvider<YXOptionalAPI>(requestClosure: requestTimeoutClosure, session : YXMoyaConfig.session())

enum YXOptionalAPI {
    case setGroup(_ version: Int, _ sortflag:Int, _ group: [SecuGroup])
    case getGroup(_ version: Int)
}

extension YXOptionalAPI: YXTargetType {
    var servicePath: String {
        "quotes-selfstock/api/"
    }
    
    var contentType: String? {
        nil
    }
    
    public var baseURL: URL {
        URL(string: YXUrlRouterConstant.hzBaseUrl())!
    }
    
    public var requestType: YXRequestType {
        return .hzRequest
    }
    
    public var path: String {
        switch self {
        case .setGroup:
            return servicePath + "v2/setgroup"
        case .getGroup:
            return servicePath + "v2/getgroup"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .setGroup:
            return .post
        case .getGroup:
            return .get
        }
    }
    
    public var sampleData: Data {
        Data()
    }
    
    public var task: Task {
        var params: [String: Any] = [:]
        switch self {
        case .setGroup(let version, let sortflag, let groups):
            params["version"] = version
            params["sortflag"] = sortflag
            if let data = try? JSONEncoder().encode(groups), let dict = try? JSONSerialization.jsonObject(with: data, options: []) {
                params["group"] = dict
            }
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .getGroup(let version):
            params["version"] = version
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }
    
    public var headers: [String : String]? {
        yx_headers
    }
}
