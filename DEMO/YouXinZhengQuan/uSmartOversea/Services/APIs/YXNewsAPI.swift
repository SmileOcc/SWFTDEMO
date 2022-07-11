//
//  YXNewsAPI.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/20.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import Moya

let newsProvider = MoyaProvider<YXNewsAPI>(requestClosure: requestTimeoutClosure, session : YXMoyaConfig.session(), plugins: [YXNetworkLoggerPlugin(verbose: true)])

enum YXNewsAPI {
    /*news-msgdisplay（资讯首页）-- 收藏列表
     v1/collectlist */
    case collectList (_ offset: NSInteger, pagesize: NSInteger)
    case collect (_ newsids: String, collectflag: Bool)
    case isCollect (_ newsId: String)
    /* banner广告位（大陆版+香港版）
     v1/query/banner_advertisement */
    case userBanner(id: YXNewsType)
    case share(_ newsId: String)
    /*news-configserver --
     get请求
     get-flash-window/v1 */
    case splashScreenAdvertisement
    /*
      get-banner-app/v1     展示页面 1：自选股页；2：个人中心-首页；
     */
    case userBannerV2(id:YXNewsAdType)
    /**
     get-flow-window/v1 浮窗广告  1 自选 7 市场 8策略
     */
    case flowAd(id:YXNewsAdType)
    
    case getflashwindow(hasRead: [String], pageId: Int)
    case getflowwindow(hasRead: [String], pageId: Int)

}

extension YXNewsAPI: YXTargetType {
    
    public var path: String {
        switch self {
            /*news-msgdisplay（资讯首页）-- 收藏列表
             v1/collectlist */
        case .collectList:
            return servicePath + "v1/collectlist"
        case .collect:
            return servicePath + "v1/collect"
        case .isCollect:
            return servicePath + "v1/judgecollect"
            /* banner广告位（大陆版+香港版）
             v1/query/banner_advertisement */
        case .userBanner(id: _):
            return servicePath + "v1/query/banner_advertisement"
        case .share:
            return servicePath + "v1/share"
            /*news-configserver -- 闪屏广告
             get请求
            get-flash-window/v1 */
        case .splashScreenAdvertisement:
            return servicePath + "get-flash-window/v1"
            
        case .userBannerV2:
            return servicePath + "get-banner-app/v1"
            
        case .flowAd:
            return servicePath + "get-flow-window/v1"
            
        case .getflashwindow:
            return servicePath + "get-flash-window/v1"
        case .getflowwindow:
            return servicePath + "get-flow-window/v1"
        }
    }
    
    public var task: Task {
        var params: [String: Any] = [:]
        switch self {
            /*news-msgdisplay（资讯首页）-- 收藏列表
             v1/collectlist */
        case .collectList(let offset, let pagesize):
            params["offset"] = NSNumber(integerLiteral: offset)
            params["pagesize"] = NSNumber(integerLiteral: pagesize)
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .collect (let newsids, let collectflag):
            params["newsids"] = newsids
            params["collectflag"] = NSNumber(booleanLiteral: collectflag)
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .isCollect(let newsId):
            params["newsid"] = newsId
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
            /* banner广告位（大陆版+香港版）
             v1/query/banner_advertisement */
        case .userBanner(id: let id):
            params["show_page"] = NSNumber(integerLiteral: id.rawValue)
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .share(let newsId):
            params["newsid"] = newsId
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .splashScreenAdvertisement:
            /*news-configserver -- 闪屏广告（大陆版+香港版）
             get请求
             v1/query/splashscreen_advertisement */
            params["pageId"] = 9
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .userBannerV2(id: let id):
            params["pageId"] = id.rawValue
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .flowAd(id: let id):
            params["pageId"] = id.rawValue
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .getflashwindow(let hasRead, let pageId):
            params["hasRead"] = hasRead
//            params["pageId"] = pageId //后端说不需要这个入参了
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .getflowwindow(let hasRead, let pageId):
            params["hasRead"] = hasRead
            params["pageId"] = pageId
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }
    
    public var baseURL: URL {
        URL(string: YXUrlRouterConstant.jyBaseUrl())!
    }
    
    public var requestType: YXRequestType {
        return .jyRequest
    }
    
    public var servicePath: String {
        switch self {
            /* banner广告位（大陆版+香港版）
             v1/query/banner_advertisement */
        case .userBanner:
            return "/news-configserver/api/"
        case .isCollect,
             .share,
             .collectList,
             .collect:
            return "/news-msgdisplay/api/"
        case .splashScreenAdvertisement,
             .flowAd:
            return "/crm-server-dolphin/api/"
        case .getflashwindow,
             .getflowwindow,
             .userBannerV2:
            return "/activity-server-dolphin/api/"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .collectList,
             .collect,
             .userBanner,
             .isCollect,
             .share,
             .splashScreenAdvertisement,
             .userBannerV2,
             .flowAd:
            return .get
        case .getflashwindow,
             .getflowwindow:
            return .post
        }
    }
    
    public var headers: [String : String]? {
        yx_headers
    }
    
    public var contentType: String? {
        switch self {
        case .collect,
             .isCollect,
             .share,
             .collectList:
            return "application/x-www-form-urlencoded"
        case .getflowwindow,
             .getflashwindow:
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
