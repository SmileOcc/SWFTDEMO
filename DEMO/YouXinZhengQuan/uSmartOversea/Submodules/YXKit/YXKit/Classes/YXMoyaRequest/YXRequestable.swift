//
//  YXRequestable.swift
//  YouXinZhengQuan
//
//  Created by ellison on 2019/3/25.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import Moya
import RxSwift

public enum YXResponseType<T: Codable> {
    case success(_ result: YXResult<T>, _ code: YXResponseCode?)
    case failed(_ error: Error)
}

public typealias YXResultResponse<T: Codable> = ((YXResponseType<T>) -> Void)

public protocol YXRequestable {
    associatedtype API: YXTargetType

    var networking: MoyaProvider<API> { get }
}

public let TokenFailureNotification = "TokenFailureNotification"

public extension YXRequestable {
    func request<T: Codable>(_ target: API, response: YXResultResponse<T>?) -> Disposable {
        
        return networking.rx.request(target).map(YXResult<T>.self).subscribe(onSuccess: { (result) in
            
            if YXResponseCode(rawValue: result.code) == .accountTokenFailure {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: TokenFailureNotification), object: nil)
            } else {
                response?(.success(result, YXResponseCode(rawValue: result.code)))
            }
            
            if result.code != 0 {
                if result.code != 806901, result.code != 806916, result.code != 800002 && result.code != 800000 {
                    let url = target.baseURL.appendingPathComponent(target.path).absoluteString
                    YXRealLogger.shareInstance.realLog(type: "ApiError", name: "接口Error", url: url, code: "\(result.code)", desc: result.msg, extend_msg: nil)
                }
            }
            
        }, onError: { (error) in
            if let urlError = error as? URLError, urlError.code.rawValue == NSURLErrorTimedOut, let host = target.baseURL.host {
                YXUrlRouterConstant.ipAddressStatus[host] = false
            }
            if let urlError = error as? URLError, urlError.code.rawValue != NSURLErrorNotConnectedToInternet {
                let code = "\(urlError.code.rawValue)"
                var desc = urlError.localizedDescription
                // 4xx 或 5xx不上报body
                if code.hasPrefix("4") || code.hasPrefix("5") {
                    desc = ""
                }
                YXRealLogger.shareInstance.realLog(type: "ApiError", name: "接口Error", url: "\(target.baseURL)\(target.path)", code: code, desc: desc, extend_msg: nil)
            } else if !(error is URLError) {
                YXRealLogger.shareInstance.realLog(type: "ApiError", name: "接口Error", url: "\(target.baseURL)\(target.path)", code: "-1", desc: error.localizedDescription, extend_msg: nil)
            }
            
            response?(.failed(error))
        })
    }
}

