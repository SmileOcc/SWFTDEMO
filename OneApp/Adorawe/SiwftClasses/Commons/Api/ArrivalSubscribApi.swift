//
//  ArrivalSubscribApi.swift
//  Adorawe
//
//  Created by fan wang on 2021/11/18.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import RxSwift

enum SubscribeStatus{
    case Success
    case AlreadySubscribe
    case Failed
}

class ArrivalSubscribApi: OSSVBasesRequests {
    
    var goods_sn:String?
    var email:String?
    
    override func requestPath() -> String! {
        OSSVNSStringTool.buildRequestPath(.arrivalSubscribpath)
    }
    
    override func requestSerializerType() -> STLRequestSerializerType {
        .JSON
    }
    
    override func requestMethod() -> STLRequestMethod {
        .POST
    }
    
    override func requestParameters() -> Any! {
        [
            "goods_sn":goods_sn ?? "",
            "email":email ?? ""
        ]
    }
    
    static func subscribe(email:String?,goodsSn:String?)->Observable<(SubscribeStatus,String?,String?)>{//success message email
        let result = Observable<(SubscribeStatus,String?,String?)>.create { observer in
            STLNetworkStateManager.shared().networkState {
                let api = ArrivalSubscribApi()
                api.email = email
                api.goods_sn = goodsSn
                HUDManager.showLoading()
                api.start { req in
                    HUDManager.hiddenHUD()
                    if let reqJson = OSSVNSStringTool.desEncrypt(req) as? [String:Any],
                       let message =  reqJson["message"] as? String,
                       let status = reqJson[String.kStatusCode] as? Int
                    {
                        if status == 200{
                            observer.onNext((.Success,message,email))
                        }else{
                            if let result = reqJson[String.kResult] as? Int,
                                result == 1{
                                observer.onNext((.AlreadySubscribe,message,email))
                            }else{
                                observer.onNext((.Failed,message,nil))
                            }
                        }
                        
                    }else{
                        observer.onNext((.Failed,STLLocalizedString_("BlankPage_NetworkError_tipTitle")!,nil))
                    }
                } failure: { req, err in
                    observer.onNext((.Failed,STLLocalizedString_("BlankPage_NetworkError_tipTitle")!,nil))
                }

            } exception: {
                observer.onNext((.Failed,STLLocalizedString_("BlankPage_NetworkError_tipTitle")!,nil))
            }
            return Disposables.create()
        }
        
        return result
    }
}
