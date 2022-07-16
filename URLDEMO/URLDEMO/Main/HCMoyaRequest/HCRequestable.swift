//
//  HCRequestable.swift
//  URLDEMO
//
//  Created by odd on 7/3/22.
//

import Foundation
import Moya
import RxSwift

public enum HCResponseType<T: Codable> {
    case success(_ result: HCResult<T>, _ code: HCResponseCode?)
    case failed(_ error: Error)
}

public typealias HCResultResponse<T: Codable> = ((HCResponseType<T>) -> Void)

public protocol HCRequestable {
    associatedtype API: HCTargetType

    var networking: MoyaProvider<API> { get }
}

public let TokenFailureNotification = "TokenFailureNotification"

public extension HCRequestable {
    
//    func requesttttt<T: Codable>(_ target: API, response: HCResultResponse<T>?) {
//        networking.request(target, completion: { result in
//            print("restul: ====ccccc \(result)")
//
//            
//        })
//
//    }
    func request<T: Codable>(_ target: API, response: HCResultResponse<T>?) -> Disposable {
        
        
        return networking.rx.request(target).map(HCResult<T>.self).subscribe(onSuccess: { (result) in
            
            print("restul: ====ccccc \(result)")
            if HCResponseCode(rawValue: result.statusCode) == .accountTokenFailure {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: TokenFailureNotification), object: nil)
            } else {
                response?(.success(result, HCResponseCode(rawValue: result.statusCode)))
            }
            
            if result.statusCode != 0 {
//                if result.statusCode != 806901, result.code != 806916, result.code != 800002 && result.code != 800000 {
//                    let url = target.baseURL.appendingPathComponent(target.path).absoluteString
//                    //YXRealLogger.shareInstance.realLog(type: "ApiError", name: "接口Error", url: url, code: "\(result.code)", desc: result.msg, extend_msg: nil)
//                }
            }
            
        }, onFailure: { (error) in
            if let urlError = error as? URLError, urlError.code.rawValue == NSURLErrorTimedOut, let host = target.baseURL.host {
                HCUrlRouterConstant.ipAddressStatus[host] = false
            }
            if let urlError = error as? URLError, urlError.code.rawValue != NSURLErrorNotConnectedToInternet {
                let code = "\(urlError.code.rawValue)"
                var desc = urlError.localizedDescription
                // 4xx 或 5xx不上报body
                if code.hasPrefix("4") || code.hasPrefix("5") {
                    desc = ""
                }
//                YXRealLogger.shareInstance.realLog(type: "ApiError", name: "接口Error", url: "\(target.baseURL)\(target.path)", code: code, desc: desc, extend_msg: nil)
            } else if !(error is URLError) {
//                YXRealLogger.shareInstance.realLog(type: "ApiError", name: "接口Error", url: "\(target.baseURL)\(target.path)", code: "-1", desc: error.localizedDescription, extend_msg: nil)
            }
            
            response?(.failed(error))
        })
    }
}


