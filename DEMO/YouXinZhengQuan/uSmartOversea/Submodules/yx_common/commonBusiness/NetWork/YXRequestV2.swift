//
//  YXRequestV2.swift
//  uSmartEducation
//
//  Created by 覃明明 on 2021/8/20.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation
import YXKit

@objcMembers class YXRequestV2: YXRequest {
    
    private(set) var params: [String: Any]?
    private(set) var customHeaders: [String: String]?
    
    private(set) var api: YXRequestAPI!
    convenience init(api: YXRequestAPI, object: NSObject? = nil,  customHeaders: [String: String]? = nil) {
        self.init()
        
        self.api = api
        self.customHeaders = customHeaders
        
        self.params = api.yx_params
        if let dict = object?.yy_modelToJSONObject() as? [String: Any]  {
            self.params = params?.merging(dict) { (_, new) in new }
        }
        
    }
    
    override func requestMethod() -> YTKRequestMethod {
        return api.yx_method
    }
    
    override func requestSerializerType() -> YTKRequestSerializerType {
        return api.yx_requestSerializerType
    }
    
    override func responseSerializerType() -> YTKResponseSerializerType {
        return api.yx_responseSerializerType
    }
    
    override func requestHeaderFieldValueDictionary() -> [String : String]? {
        var headers = YXHeaders.httpHeaders()
        
        headers["Content-Type"] = api.yx_contentType
        
        // 如果用的时全局配置的url，则host默认就是url的host，不用更改
        switch api.yx_baseUrlType {
        case .hzRequest:
            if YXGlobalConfigManager.configURL(type: .hzCenter) != self.baseUrl() {
                headers["Host"] = YXUrlRouterConstant.hzBaseUrlWithoutScheme()
            }
        case .jyRequest:
            if YXGlobalConfigManager.configURL(type: .jyCenter) != self.baseUrl() {
                headers["Host"] = YXUrlRouterConstant.jyBaseUrlWithoutScheme()
            }
        case .zxRequest:
            if YXGlobalConfigManager.configURL(type: .zxCenter) != self.baseUrl() {
                headers["Host"] = YXUrlRouterConstant.zxBaseUrlWithoutScheme()
            }
        case .wjRequest:
            if YXGlobalConfigManager.configURL(type: .wjCenter) != self.baseUrl() {
                headers["Host"] = YXUrlRouterConstant.wjBaseUrlWithoutScheme()
            }
        }
        
        if let customHeaders = customHeaders {
            headers = headers.merging(customHeaders) { (_, new) in new }
            
            var needUpdateXToken = false
            let xTokenKeys = ["X-Trans-Id", "X-Time", "X-Dt", "X-Dev-Id", "X-Uid", "X-Lang", "X-Type", "X-Ver"]
            for key in customHeaders.keys {
                if xTokenKeys.contains(key) {
                    needUpdateXToken = true
                    break
                }
            }
            if needUpdateXToken {
                let xToken = YXKitUtil.xTokenGenerate(withXTransId: headers["X-Trans-Id"] ?? "",
                                                      xTime: headers["X-Time"] ?? "",
                                                      xDt: headers["X-Dt"] ?? "",
                                                      xDevId: headers["X-Dev-Id"] ?? "",
                                                      xUid: headers["X-Uid"] ?? "",
                                                      xLang: headers["X-Lang"] ?? "",
                                                      xType: headers["X-Type"] ?? "",
                                                      xVer: headers["X-Ver"] ?? "")
                headers["X-Token"] = xToken
            }
        }
        
        return headers
    }
    
    override func baseUrl() -> String {
        switch api.yx_baseUrlType {
        case .hzRequest:
            return YXUrlRouterConstant.hzBaseUrl()
        case .jyRequest:
            return YXUrlRouterConstant.jyBaseUrl()
        case .zxRequest:
            return YXUrlRouterConstant.zxBaseUrl()
        case .wjRequest:
            return YXUrlRouterConstant.wjBaseUrl()
        }
    }

    override func requestUrl() -> String {
        return api.yx_path
    }
    
    override func requestArgument() -> Any? {
        return params
    }
    
    override func requestTimeoutInterval() -> TimeInterval {
        return api.yx_timeoutInterval
    }
    
    @objc func responseModelClass() -> NSObject.Type {
        return api.yx_responseModelClass
    }

//    func startWithBlock(success: ((YXResponseModel) -> Void)?, failure: YTKRequestCompletionBlock? = nil) {
//        startWithCompletionBlock { [weak self] request in
//            guard let strongSelf = self else { return }
//
//            if let jsonObject = request.responseJSONObject as? [String: Any],
//               let responseModel = strongSelf.api.yx_responseModelClass.yy_model(with: jsonObject) as? YXResponseModel {
//                success?(responseModel)
//
//                if strongSelf.customHeaders?["Authorization"] != nil {
//                    return
//                }
//
//                if (responseModel.code == .accountTokenFailure) {
////                    YXUserManager.shared().tokenFailureAction(withHud: true)
//                    YXUserManager.shared().tokenFailureAction()
//                }
//                if (responseModel.code == .mrTestError) {
//                    if let msg = responseModel.msg {
//                        YXProgressHUD.showError(msg)
//                    }
//                }
//                if responseModel.code != .success {
//                    if responseModel.code != .versionDifferent,
//                       responseModel.code != .versionEqual,
//                       responseModel.code.rawValue != 800002,
//                       responseModel.code.rawValue != 800000 {
//                        YXRealLogger.shareInstance.realLog(type: "ApiError", name: "接口Error", url: request.currentRequest.url?.absoluteString, code: "\(responseModel.code.rawValue)", desc: responseModel.msg, extend_msg: nil)
//                    }
//                }
//
//                log(.info, tag: kNetwork,content:"""
//                request_success
//                \(request),
//                response=\(request.responseString ?? "")
//                token=\(YXUserManager.shared().token())
//                """
//                )
//            } else {
//                failure?(request)
//            }
//
//        } failure: { request in
//            failure?(request)
//
//            if let error = request.error,
//               (error as NSError).code == NSURLErrorTimedOut,
//               let host = request.currentRequest.url?.host,
//               host.count > 0 {
//                YXUrlRouterConstant.setStatus(IP: host, status: false)
//            }
//
//            if request.statusCodeValidator() == false,
//               request.responseStatusCode != 0 {
//                // 如果请求失败则上报日志
//                YXRealLogger.shareInstance.realLog(type: "ApiError", name: "接口Error", url: request.currentRequest.url?.absoluteString, code: "\(request.responseStatusCode)", desc: nil, extend_msg: nil)
//            }
//
//            log(.warning, tag: kNetwork, content:"""
//            request_failure
//            \(request),
//            requestHeaders = \(request.requestHeaderFieldValueDictionary() ?? [:])
//            response=\(request.responseString ?? "")
//            token=\(YXUserManager.shared().token())
//            localizedDescription=\(request.error?.localizedDescription ?? "")
//            """
//            )
//        }
//
//    }

}
