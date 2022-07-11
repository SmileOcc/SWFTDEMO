//
//  YXStockSTAPI.swift
//  uSmartOversea
//
//  Created by youxin on 2019/4/13.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import Moya

let StockSTProvider = MoyaProvider<YXStockSTAPI>(requestClosure: requestTimeoutClosure, session : YXMoyaConfig.session(), plugins: [YXNetworkLoggerPlugin(verbose: true)])

public enum YXStockSTAPI {
    /* 股王新增 多元资产专栏 – 主页
     query/homepage_unite  */
    case queryHomepageUnite(userAuth: Int)
    
    case queryCarousel(userAuth: Int)

    case queryMultiassethomepage
    
    case queryReturnrateList(strategyId: Int, strategyType: Int, pointCount: Int, monthCount: Int)

    case queryColumnList
}

extension YXStockSTAPI: YXTargetType {
    
    public var path: String {
        switch self {
            /* 股王新增 多元资产专栏 – 主页
             query/homepage_unite
             用户交易权限
             8：已交易
             4：已入金未交易
             2：已开户
             1：已注册
             0：未注册  */
        case .queryHomepageUnite:
            return servicePath + "home/homepage_unite"
            
        case .queryCarousel:
            return servicePath + "query/carousel"
        case .queryMultiassethomepage:
            return servicePath + "query/multiassethomepage"
        case .queryReturnrateList:
            return servicePath + "comm/returnratelist"

        case .queryColumnList:
            return servicePath + "query/columnlist"
        }
    }
    
    public var task: Task {
        switch self {
        case .queryHomepageUnite(let userAuth):
            var params: [String : Any] = [:]
            params["user_auth"] = userAuth //user_auth: 用户交易权限
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .queryCarousel(userAuth: let auth):
            var params: [String : Any] = [:]
            params["user_auth"] = auth //user_auth: 用户交易权限
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .queryMultiassethomepage:
            return .requestPlain
        case .queryReturnrateList(strategyId: let strategyId, strategyType: let strategyType, pointCount: let pointCount, monthCount: let monthCount):
            var params: [String : Any] = [:]
            params["strategy_id"] = strategyId
            params["strategy_type"] = strategyType
            params["point_count"] = pointCount
            params["month_count"] = monthCount
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .queryColumnList:
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
        switch self {
        case .queryCarousel,
            .queryMultiassethomepage:
            return "/news-strategyserver/api/v1/"
            case .queryHomepageUnite, .queryReturnrateList:
            return "/zt-strategy-apiserver/api/v1/"
        default:
            return "/news-strategyserver/api/v3/"
        }
        
    }
    
    public var method: Moya.Method {
        switch self {
        default:
            return .get
        }
    }
    
    public var headers: [String : String]? {
        yx_headers
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
