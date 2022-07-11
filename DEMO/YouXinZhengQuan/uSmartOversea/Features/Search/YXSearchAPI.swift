//
//  YXSearchAPI.swift
//  uSmartOversea
//
//  Created by ZhiYun Huang on 2019/4/20.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import Moya

let searchProvider = MoyaProvider<YXSearchAPI>(requestClosure: requestTimeoutClosure, session : YXMoyaConfig.session(), plugins: [YXNetworkLoggerPlugin(verbose: true)])

enum YXSearchAPI {
    case search(_ param :YXSearchParam)
    case hotSearch
    case recommend
}

extension YXSearchAPI: YXTargetType {
    
    var contentType: String? {
        nil
    }
    
    var headers: [String : String]? {
        yx_headers
    }
    
    public var path: String {
        switch self {
        case .search(_):
            return "quotes-search/api/v4-2/stocks"
        case .hotSearch:
            return "quotes-search/api/v2-3/top"
        case .recommend:
            return "quotes-marketing/api/v1/search/recommend"
        }
    }
    
    public var task: Task {

        switch self {
        case .search(let param):
            return .requestParameters(parameters: param.toDictionary(), encoding: URLEncoding.default)
        case .hotSearch:
            return .requestPlain
        case .recommend:
            return .requestPlain
        }
    }
    
    public var baseURL: URL {
        URL(string: YXUrlRouterConstant.hzBaseUrl())!
    }
    
    public var requestType: YXRequestType {
        return .hzRequest
    }
    
    public var servicePath: String {
        ""
    }
    
    public var method: Moya.Method {
        switch self {
        default:
            return .get
        }
    }
    
    public var sampleData: Data {
        switch self {
        default:
            return Data()
        }
    }
    
}

