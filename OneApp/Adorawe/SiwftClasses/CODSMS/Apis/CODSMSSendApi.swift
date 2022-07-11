//
//  CODSMSSendReq.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/9/7.
//  Copyright © 2021 starlink. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON


@objc enum RequestType:Int{
    case sendSMS
    case sendCheck
}


@objcMembers class CODSMSSendApi:OSSVBasesRequests{
    
    private var phone:String
    private var phoneCode:String
    private var orderId:String
    private var reqType:RequestType
    var code:String?
    
    init(phone:String,phoneCode:String,orderId:String,reqType:RequestType = .sendSMS) {
        self.phone = phone
        self.phoneCode = phoneCode.replacingOccurrences(of: "+", with: "")
        self.orderId = orderId
        self.reqType = reqType
    }
    
    override func requestPath() -> String! {
        switch reqType {
        case .sendSMS:
            return OSSVNSStringTool.buildRequestPath(.codSMSSend)
        case .sendCheck:
            return OSSVNSStringTool.buildRequestPath(.codConfirm)
        }
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
    
    override func isNewENC() -> Bool {
        if OSSVConfigDomainsManager.domainEnvironment() == .deveTrunk || OSSVConfigDomainsManager.domainEnvironment() == .deveInput{
            return false
        }
        return true
    }
    
    
    override func requestParameters() -> Any! {
        switch reqType {
        case .sendSMS:
            return [
                "phone":phone,
                "phone_code":phoneCode,
                "order_id":orderId
            ]
        case .sendCheck:
            return [
                "phone":phone,
                "phone_code":phoneCode,
                "order_id":orderId,
                "code":Int(code ?? "") ?? ""
            ]
        }
    }
   
    
    func requesSendCode(view:UIView) -> Observable<(Bool,String?,Int?,Bool?,Int?)>{
        return Observable<(Bool,String?,Int?,Bool?,Int?)>.create { subscriber in
            self.accessoryArray.add(STLRequestAccessory(apperOn: view)!)
            
            self.start { req in
                if let requestJSON = OSSVNSStringTool.desEncrypt(req){
                    let result = JSON(requestJSON)
                    let message = result["message"].string
                    if result["statusCode"] == 200{
                        subscriber.onNext((success:true,
                                           message:nil,
                                           countDown:result["result"]["countdown"].int,
                                           showSkip:result["result"]["show_skip"].boolValue,
                                           status:result["statusCode"].int))
                    }else if result["statusCode"] == 201{
                        subscriber.onNext((success:false,
                                           message:message,
                                           countDown:nil,
                                           showSkip:result["result"]["show_skip"].boolValue,
                                           status:result["statusCode"].int))
                    }else{
                        subscriber.onNext((success:false,
                                           message:message,
                                           countDown:nil,
                                           showSkip:result["result"]["show_skip"].boolValue,
                                           status:result["statusCode"].int))
                    }
                }
            } failure: { req, err in
                HUDManager.showHUD(withMessage: .errorMsg)
            }
            return Disposables.create()
        }
    }
}
