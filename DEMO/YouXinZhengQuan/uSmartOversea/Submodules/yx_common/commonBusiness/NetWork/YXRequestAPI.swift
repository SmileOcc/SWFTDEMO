//
//  YXRequestAPI.swift
//  uSmartEducation
//
//  Created by 覃明明 on 2021/10/11.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation
import RxSwift
import YXKit

public protocol YXRequestAPI {
//    var yx_requestType: YXRequestType { get }
    var yx_path: String { get }
    var yx_params: [String: Any] { get }
    var yx_method: YTKRequestMethod { get }
    var yx_contentType: String { get }
    
    var yx_requestSerializerType: YTKRequestSerializerType { get }
    var yx_responseSerializerType: YTKResponseSerializerType { get }
    var yx_responseModelClass: NSObject.Type { get }
    
    var yx_baseUrlType: YXRequestType { get }
    var yx_timeoutInterval: TimeInterval { get }
    
    func request() -> Single<YXResponseModel?>
}

public extension YXRequestAPI {
    
    func request() -> Single<YXResponseModel?> {
        let single = Single<YXResponseModel?>.create { single in
            
            let request = YXRequestV2.init(api: self)
            
            request.startWithBlock { (response) in

                single(.success(response))
        
            } failure: { request in
                single(.error(request.error ?? NSError.init(domain: "", code: -1, userInfo: nil)))
            }

            return Disposables.create()
        }
        
        return single
    }
    
    var yx_baseUrlType: YXRequestType {
        return .jyRequest
    }
    
    var yx_contentType: String {
        return "application/json"
    }
    
    var yx_requestSerializerType: YTKRequestSerializerType {
        switch self {
        default:
            return .JSON
        }
    }
    
    var yx_responseSerializerType: YTKResponseSerializerType {
        switch self {
        default:
            return .JSON
        }
    }
    
    var yx_timeoutInterval: TimeInterval {
        return 10
    }
}
