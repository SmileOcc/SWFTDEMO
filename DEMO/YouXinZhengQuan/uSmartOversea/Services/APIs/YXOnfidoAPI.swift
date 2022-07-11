//
//  YXOnfidoAPI.swift
//  uSmartOversea
//
//  Created by 欧冬冬 on 2022/6/1.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import Moya

let onfidoProvider = MoyaProvider<YXOnfidoAPI>(plugins: [YXNetworkLoggerPlugin(verbose: true)])

public enum YXOnfidoAPI {
    
    case onfidoApplicants (_ apiToken: String, _ firstName: String, _ lastName: String)
    
    case onfidoSDKToken (_ apiToken: String, _ applicant_id: String, _ application_id: String)
}

extension YXOnfidoAPI: TargetType {

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
        case .onfidoApplicants(let apiToken, let firstName, let lastName):
            
            params["Authorization"] = apiToken
            params["first_name"] = firstName
            params["last_name"] = lastName
//            if let liveConfig = liveConfig {
//                for (k, v) in liveConfig {
//                    params[k] = v
//                }
//            }
//            if let img = image {
//                if let data = img.jpegData(compressionQuality: 1) {
//                    //根据当前时间设置图片上传时候的名字
//                    let date = Date()
//                    let formatter = DateFormatter.en_US_POSIX()
//                    formatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
//                    var dateStr = formatter.string(from: date)
//                    dateStr = dateStr + ".png"
//
//                    let fileName = dateStr //保存的名字
//                    let name = "image_ref1" //必须要传 image_ref1
//                    let type = "image/jpeg" //上传的文件类型
//                    let formData = MultipartFormData(provider: .data(data), name: name, fileName: fileName, mimeType: type)
//
//                    return .uploadCompositeMultipart([formData], urlParameters: params)
//                }
//            }
            
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .onfidoSDKToken(let apiToken, let applicant_id, let application_id):
            params["Authorization"] = apiToken
            params["applicant_id"] = applicant_id
            params["application_id"] = application_id
            
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
        
    }
    
    public var path: String {
        switch self {
        case .onfidoApplicants(_, _, _):
            return "/v3/applicants"
        case .onfidoSDKToken(_, _, _):
            return "/v3/sdk_token"
        }
    }
    
    public var baseURL: URL {
        URL(string: "https://api.onfido.com")!
    }
    
    public var method: Moya.Method {
        .post
    }
}
