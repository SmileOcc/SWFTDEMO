//
//  YXFaceIDAPI.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/4/15.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import Moya
import YXKit


/**
 接口：get_biz_token
 
  参数：get_liveness_video: 0 1 2 3
  0:不保存视频图片
  1：保存视频图片
  2：保存视频
  3：保存图片
 */

let faceIdProvider = MoyaProvider<YXFaceIDAPI>(plugins: [YXNetworkLoggerPlugin(verbose: true)])

public enum YXFaceIDAPI {
    case bizToken (_ liveness_type: String, _ liveConfig: Dictionary<String, String>?, _ image: UIImage?)
}

extension YXFaceIDAPI: TargetType {
    public var headers: [String : String]? {
        nil
    }
    
    public var sampleData: Data {
        switch self {
        default:
            return Data()
        }
    }
    
    public var task: Task {
        var params: [String: Any] = [:]
        switch self {
        case .bizToken(let liveness_type, let liveConfig, let image):
            
            params["liveness_type"] = liveness_type
            if let liveConfig = liveConfig {
                for (k, v) in liveConfig {
                    params[k] = v
                }
            }
            if let img = image {
                if let data = img.jpegData(compressionQuality: 1) {
                    //根据当前时间设置图片上传时候的名字
                    let date = Date()
                    let formatter = DateFormatter.en_US_POSIX()
                    formatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
                    var dateStr = formatter.string(from: date)
                    dateStr = dateStr + ".png"
                    
                    let fileName = dateStr //保存的名字
                    let name = "image_ref1" //必须要传 image_ref1
                    let type = "image/jpeg" //上传的文件类型
                    let formData = MultipartFormData(provider: .data(data), name: name, fileName: fileName, mimeType: type)
                    
                    return .uploadCompositeMultipart([formData], urlParameters: params)
                }
            }
            
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }
    
    public var path: String {
        switch self {
        case .bizToken(_, _, _):
            return "/faceid/v3/sdk/get_biz_token"
        }
    }
    
    public var baseURL: URL {
        URL(string: "https://api.megvii.com")!
    }
    
    public var method: Moya.Method {
        .post
    }
}



let facelIDAPPProvider = MoyaProvider<YXFaceIDAPPAPI>(requestClosure: requestTimeoutClosure, session : YXMoyaConfig.session(), plugins: [YXNetworkLoggerPlugin(verbose: true)])

public enum YXFaceIDAPPAPI {
    case saveVideoUrl (_ videoUrl: String)

}

extension YXFaceIDAPPAPI: YXTargetType {
    public var path: String {
        servicePath + "save-faceid-sdk-verify-video/v1"
    }
    
    public var task: Task {
        var params: [String: Any] = [:]
        switch self {
        case .saveVideoUrl(let videoUrl):
            params["livingVideo"] = videoUrl
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
        "user-account-server-sg/api/"
    }
    
    public var method: Moya.Method {
        .post
    }
    
    public var headers: [String : String]? {
        yx_headers
    }
    
    public var contentType: String? {
        nil
    }
    
    public var sampleData: Data {
        switch self {
        default:
            return Data()
        }
    }
}
