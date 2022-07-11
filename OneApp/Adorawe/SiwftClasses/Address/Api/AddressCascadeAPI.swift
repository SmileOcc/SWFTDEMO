//
//  AddressCascadeAPI.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/14.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import RxSwift

class AddressCascadeAPI: OSSVBasesRequests {
    
    var val:String
    var type:Int
    var level:Int
    
    
    init(val:String,type:Int,level:Int){
        self.val = val
        self.type = type
        self.level = level
        super.init()
    }
    
    
    
    override func requestPath() -> String! {
        OSSVNSStringTool.buildRequestPath(String.cascadeAddress)
    }
    
    override func requestMethod() -> STLRequestMethod {
        .POST
    }
    
    override func requestSerializerType() -> STLRequestSerializerType {
        .JSON
    }
    
    override func enableAccessory() -> Bool {
        true
    }
    
    override func requestParameters() -> Any! {
        return [
            "val":val,
            "type":type,
            "level":level
        ]
    }
    
    func loadData()->Observable<CascadeApiResponseModel?>{
        let result = Observable<CascadeApiResponseModel?>.create { subscriber in
            self.start { req in
                if let reqJson = OSSVNSStringTool.desEncrypt(toString: req),
                   let respMode =  CascadeApiResponseModel(JSONString: reqJson){
                    subscriber.onNext(respMode)
                }
            } failure: { req, err in
                if let err = err {
                    subscriber.onError(err)
                }
                HUDManager.showHUD(withMessage: .errorMsg)
            }
            
            return Disposables.create()
        }
        return result
    }

}
