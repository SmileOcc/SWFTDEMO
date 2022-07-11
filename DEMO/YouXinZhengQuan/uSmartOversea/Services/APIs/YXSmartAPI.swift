//
//  YXSmartAPI.swift
//  uSmartOversea
//
//  Created by youxin on 2019/4/10.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import Moya
import YXKit

let SmartDataProvider = MoyaProvider<YXSmartAPI>(requestClosure: requestTimeoutClosure, session : YXMoyaConfig.session(), plugins: [YXNetworkLoggerPlugin(verbose: true)])

typealias yxSmartSettingList = (groupid: Int, signalid: [Int])
typealias yxSmartPostQuota = (uid: String, smartType: Int, list: [yxSmartSettingList])
typealias yxSmartGetQuota = (uid: String, smartType: Int, fontType: Int)
typealias yxSmartPostSmart = (uid: String, smartType: Int, count: Int, stockList: [String]?, seqNum: Int64, fontType: Int, unixTime: Int64)

//接口地址 http://szshowdoc.youxin.com/web/#/23?page_id=238
enum YXSmartAPI {
    case postQuota(yxSmartPostQuota)
    case getQuota(yxSmartGetQuota)
    case postSmart(yxSmartPostSmart)
    
}

extension YXSmartAPI: YXTargetType {
    
    public var path: String {
        switch self {
        case .postQuota:
            return servicePath + "postquota"
        case .getQuota:
            return servicePath + "getquota"
        case .postSmart:
            return servicePath + "getsmart"
        }
    }
    
    public var task: Task {
        var params: [String: Any] = [:]
        switch self {
        case .postQuota(let tuple):
            if let dic = YXTupleTool.mirrorTuple(tuple) {
                params = dic
            }
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .getQuota(let tuple):
            if let dic = YXTupleTool.mirrorTuple(tuple) {
                params = dic
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
            
        case .postSmart(let tuple):
            if let dic = YXTupleTool.mirrorTuple(tuple) {
                params = dic
            }
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }
    
    
    public var baseURL: URL {
        URL(string: YXUrlRouterConstant.hzBaseUrl())!
    }
    
    public var requestType: YXRequestType {
        return .hzRequest
    }
    
    public var servicePath: String {
        "/quotes-smart/api/v1/"
    }
    
    public var method: Moya.Method {
        switch self {
        case .postQuota,
             .postSmart:
            return .post
        case .getQuota:
            return .get
        }
    }
    
    public var headers: [String : String]? {
        yx_headers
    }
    
    public var contentType: String? {
        switch self {
        case .postSmart:
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
