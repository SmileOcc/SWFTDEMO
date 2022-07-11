//
//  ServerResponse.swift
//  zhilian
//
//  Created by ZhiYun Huang on 08/06/2017.
//  Copyright © 2017 feixun. All rights reserved.
//

import UIKit
import Moya
import YXKit

//HTTP请求拦截，添加一些必要的header信息
public struct YXMoyaReqPlugin: PluginType {
    
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        
//        var request = request
        
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue(YXUserManager.shared().curLoginUser?.token ?? "", forHTTPHeaderField: "Authorization")
//        request.setValue("t2", forHTTPHeaderField: "X-Dt")
//        request.setValue( String(format: "%.0lf", Date().timeIntervalSince1970*1000), forHTTPHeaderField: "X-Time")
//        request.setValue(NSUUID().uuidString, forHTTPHeaderField: "X-Trans-Id")
//        request.setValue("n1", forHTTPHeaderField: "YXNetworkUtil")
//        request.setValue(String(format: "%lld", YXUserManager.userUUID()), forHTTPHeaderField: "X-Uid")
//        request.setValue(YXConstant.appVersion ?? "", forHTTPHeaderField: "X-Ver")
//        request.setValue(YXConstant.deviceInfo(), forHTTPHeaderField: "X-Dev-Info")
//        request.setValue("\(YXConstant.flakeId(withXorNumber: Int64(YXUserManager.userUUID())))", forHTTPHeaderField: "X-Request-Id")
//        request.setValue(YXConstant.deviceUUID(), forHTTPHeaderField: "X-Dev-Id")
//
//        request.setValue("2", forHTTPHeaderField: "X-Lang")
//        request.setValue("2", forHTTPHeaderField: "X-Type")

        request
    }
    
}

//HTTP响应拦截
struct YXMoyaRspPlugin: PluginType {
    
    public func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
        
//        switch result {
//            
//        case .success(let response):
//            
//            let status = 0
//            
//            //success
//            if status == 200 || status == 0 {
//                
//                let data = Data()
//                
//                let mappedResponse = Moya.Response(statusCode: response.statusCode, data: data , request: response.request, response: response.response)
//                
//                return Result.success(mappedResponse)
//            }
//            
//            
//        case .failure(let error):
//            
//            return Result.failure(error)
//            
//        }

        result
    }
}
