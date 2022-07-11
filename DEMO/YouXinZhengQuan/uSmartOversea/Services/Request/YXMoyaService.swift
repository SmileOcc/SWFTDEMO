//
//  YXMoyaRequestable.swift
//  uSmartOversea
//
//  Created by ZhiYun Huang on 2019/4/25.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import Moya
import RxSwift

class YXMoyaService<API: TargetType> {
    
    let provider =  MoyaProvider<API>(requestClosure: requestTimeoutClosure, session : YXMoyaConfig.session(), plugins: [YXMoyaReqPlugin(),YXMoyaRspPlugin(),YXNetworkLoggerPlugin(verbose: true)])
    
    func request<T: Codable>(_ target: API) -> Single<T?> {

        Single.create { [weak self] (singleFunc) -> Disposable in

            self?.provider.rx.request(target).map(YXResult<T>.self).subscribe(onSuccess: { (result) in
                
                if result.code == YXResponseCode.success.rawValue {
                    singleFunc(.success(result.data))
                } else {
                    if YXResponseCode(rawValue: result.code) == .accountTokenFailure {
                        YXUserManager.shared().tokenFailureAction()
                    }
                    singleFunc(.error(YXError.businessError(code: result.code, message: result.msg)))
                }
                
            }, onError: { (error) in
                if let err = error as? MoyaError {
                    switch err {
        
                    case .underlying(_):
                        YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "common_net_error"))
                    default: break
                    }
                }
                singleFunc(.error(error))
            }) ?? Disposables.create()
            
        }
    }
}
