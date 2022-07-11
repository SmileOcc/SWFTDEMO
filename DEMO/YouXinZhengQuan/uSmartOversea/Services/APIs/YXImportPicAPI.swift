//
//  YXImportPicAPI.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/7/3.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Moya

let importProvider = MoyaProvider<YXImportAPI>(requestClosure: requestTimeoutClosure, session : YXMoyaConfig.session(), plugins: [YXNetworkLoggerPlugin(verbose: true)])

enum YXImportAPI {
    case upload(_ fileData: Data)
}

extension YXImportAPI: YXTargetType {
    
    var servicePath: String {
        "/news-imagetranslator/api/v1"
    }
    
    var contentType: String? {
        nil
    }
    
    var baseURL: URL {
        switch self {
        default:
            return URL(string: YXUrlRouterConstant.hzBaseUrl())!
        }
    }
    
    public var requestType: YXRequestType {
        switch self {
        default:
            return .hzRequest
        }
    }
    
    var path: String {
        switch self {
        case .upload:
            return servicePath + "/query/translation"
        }
        
    }
    
    var method: Moya.Method {
        .post
    }
    
    var sampleData: Data {
        switch self {
        default:
            return Data()
        }
    }
    
    var task: Task {
        //var params: [String: Any] = [:]
        
        switch self {
        case .upload(let fileData):
            let date = Date()
            let formatter = DateFormatter.en_US_POSIX()
            formatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
            var dateStr:String = formatter.string(from: date as Date)
            dateStr = dateStr + ".png"
            
            let formData = MultipartFormData(provider: .data(fileData), name: "file", fileName: dateStr, mimeType: "image/jpeg")
            return .uploadCompositeMultipart([formData], urlParameters: [:])
        }
        
    }
    
    var headers: [String : String]? {
        yx_headers
    }
    
    
}
