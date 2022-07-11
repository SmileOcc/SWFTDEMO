//
//  YXGlobalConfigAPI.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2019/5/18.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import Moya

public let YXGlobalConfigProvider = MoyaProvider<YXGlobalConfigAPI>(
    requestClosure: requestTimeoutClosure,
    session : YXMoyaConfig.session(),
    plugins: [YXNetworkLoggerPlugin(verbose: true)])

public enum YXGlobalConfigAPI {
    case parameters(version: Int)
    case otherAdvertisement(_ showPage: Int)
    case service
    case kindlyReminder
    case links
    case getCredAppV1
    /* http://admin-dev.yxzq.com/config-manager/doc/doc.html -->
    国家区号 --> 获取国家区号
    /config-manager/api/get-country-area/v1 */
    case countryArea(_ version: Int)
    case getFilterModule
    case getFileCredAppV2(fileName: String, bucket: String, region: String)
    case strategyPop
}

extension YXGlobalConfigAPI: YXTargetType {
    
    public var path: String {
        switch self {
        case .parameters(version: _):
            return servicePath + "query/globalcfg"
        case .otherAdvertisement:
            return servicePath + "query/other_advertisement"
        case .service:
            return servicePath + "customer-status-select/v1"
        case .kindlyReminder:
            return servicePath + "kindly-reminder-select/v1"
        case .links:
            return servicePath + "cfg-pro-select/v1"
        case .getCredAppV1:
            return servicePath + "get-cred-app/v1"     //"feedback-tokens/v1"
        case .countryArea(version: _):
            /* http://admin-dev.yxzq.com/config-manager/doc/doc.html -->
             国家区号 --> 获取国家区号
             /config-manager/api/get-country-area/v1 */
            return servicePath + "get-country-area/v1"
        case .getFilterModule:
            return servicePath + "get-filter-module/v1"
        case .getFileCredAppV2(fileName: _, bucket: _, region: _):
            return servicePath + "get-file-cred-app/v2"
        case .strategyPop:
            return servicePath + "strategy-pop"
        }
    }
    
    public var task: Task {
        var params: [String: Any] = [:]
        switch self {
        case .parameters(version: let version):
            params["version"] = version
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .otherAdvertisement( let showPage):
            params["show_page"] = showPage;
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .getCredAppV1: //get请求
            //标识符 dev/sit/uat环境-DEV,prd环境-PRD
            var appIndentifier: String
            switch YXConstant.targetMode() {
            case .dev, .sit, .uat:
                appIndentifier = "DEV"
            case .prd,
                 .prd_hk:
                appIndentifier = "PRD"
            default:
                appIndentifier = "DEV"
            }
            params["appIndentifier"] = appIndentifier
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .countryArea(version: let version):
            /* http://admin-dev.yxzq.com/config-manager/doc/doc.html -->
            国家区号 --> 获取国家区号
            /config-manager/api/get-country-area/v1 */
             params["version"] = version
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .getFilterModule:
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .getFileCredAppV2(fileName: let fileName, bucket: let bucket, region: let region):
            params["fileName"] = fileName
            params["region"] = region
            params["bucket"] = bucket
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .strategyPop:
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        default:
             return .requestPlain
        }
    }
    
    
    public var baseURL: URL {
        switch self {
        case .parameters(version: _):
            return URL(string: YXUrlRouterConstant.hzBuildInBaseUrl())!
        case .otherAdvertisement,
             .strategyPop:
            return URL(string: YXUrlRouterConstant.hzBaseUrl())!
        case .service,
             .kindlyReminder,
             .links,
             .countryArea(version: _),
             .getCredAppV1,
             .getFilterModule,
             .getFileCredAppV2(fileName: _, bucket: _, region: _):
            return URL(string: YXUrlRouterConstant.jyBaseUrl())!
        }
    }
    
    public var servicePath: String {
        switch self {
        case .parameters(version: _),
             .otherAdvertisement:
            return "/news-configserver/api/v1/"
        case .strategyPop:
            return "/news-configserver/api/"
        case .service,
             .kindlyReminder,
             .links,
             .countryArea(version: _),
             .getCredAppV1,
             .getFilterModule,
             .getFileCredAppV2(fileName: _, bucket: _, region: _):
            if YXConstant.appTypeValue == .OVERSEA || YXConstant.appTypeValue == .OVERSEA_SG{
                return "/config-manager-dolphin/api/"
            } else if YXConstant.appTypeValue == .EDUCATION {
                return "/config-manager-rich/api/"
            } else {
                return "/config-manager/api/"
            }
        }
    }
    
    public var requestType: YXRequestType {
        switch self {
        case .parameters(version: _),
             .otherAdvertisement,
             .strategyPop:
            return .hzRequest
        case .service,
             .kindlyReminder,
             .links,
             .countryArea(version: _),
             .getCredAppV1,
             .getFilterModule,
             .getFileCredAppV2(fileName: _, bucket: _, region: _):
            return .jyRequest
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .countryArea(version: _),
             .getFileCredAppV2(fileName: _, bucket: _, region: _):
            return .post
        default:
            return .get
        }
    }
    
    public var headers: [String : String]? {
        var headers = yx_headers
        switch self {
        case .parameters(version: _):
            headers["X-Challenge"] = "Cancel"
        case .strategyPop:
            //用户权限位，0=未注册，1=注册用户,登陆用户才会推荐策略
            headers["X-AuthBitmap"] = "1"
        default:
            print("")
        }
        
        return headers
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

public protocol HasYXGlobalConfigService {
    var globalConfigService: YXGlobalConfigService { get }
}

public class YXGlobalConfigService: YXRequestable {
    
    public typealias API = YXGlobalConfigAPI
    
    public var networking: MoyaProvider<API> {
        return YXGlobalConfigProvider
    }
    
    public init() {
        
    }
}
