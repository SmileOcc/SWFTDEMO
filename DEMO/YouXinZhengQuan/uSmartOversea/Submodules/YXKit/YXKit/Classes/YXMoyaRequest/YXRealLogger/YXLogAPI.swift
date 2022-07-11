//
//  YXLogAPI.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2019/7/30.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import Moya

let YXLogProvider = MoyaProvider<YXLogAPI>(
    requestClosure: requestTimeoutClosure,
    session : YXMoyaConfig.session(),
    plugins: [YXNetworkLoggerPlugin(verbose: true)])

enum YXLogAPI {
    case realLog(_ list: [RealLog])
    case fileLog(_ filePath: String, _ fileName: String)
    case pathLog(_ path: String)
}

extension YXLogAPI: YXTargetType {
    public var path: String {
        switch self {
        case .realLog:
            return servicePath + "logjson"
        case .fileLog:
            return servicePath + "logfile"
        case .pathLog:
            return servicePath + "logpath"
        }
    }
    
    public var task: Task {
        var params: [String: Any] = [:]
        switch self {
        case .realLog(let list):
            if let data = try? JSONEncoder().encode(list), let dict = try? JSONSerialization.jsonObject(with: data, options: []) {
                params["list"] = dict
            }
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .fileLog(let filePath, let fileName):
            let formData = MultipartFormData(provider: .file(URL(fileURLWithPath: filePath)), name: "file", fileName: fileName, mimeType: "application/mulit-form")
            return .uploadCompositeMultipart([formData], urlParameters: [:])
        case .pathLog(let path):
            params["path"] = path
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }
    
    
    public var baseURL: URL {
        return URL(string: YXUrlRouterConstant.wjBuildInBaseUrl())!
    }
    
    public var servicePath: String {
        return "quotes-applogupload/api/v1/"
    }
    
    public var method: Moya.Method {
        return .post
    }
    
    public var headers: [String : String]? {
        return yx_headers
    }
    
    public var requestType: YXRequestType {
        return .wjRequest
    }
    
    var contentType: String? {
        return "application/json"
    }
    
    public var sampleData: Data {
        switch self {
        default:
            return Data()
        }
    }
}
