//
//  OSSVGetePhoneAreaeCodeAip+rx.swift
//  Adorawe
//
//  Created by fan wang on 2021/12/10.
//  Copyright © 2021 starlink. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

extension OSSVGetePhoneAreaeCodeAip{
    func requestPhoneCode() -> Observable<(Bool,PhoneCodeRulesModel?)>{
        return Observable<(Bool,PhoneCodeRulesModel?)>.create { subscriber in
            self.start { req in
                if let reqJson = OSSVNSStringTool.desEncrypt(req) as? [String:Any],
                   let statusCode =  reqJson[String.kStatusCode] as? Int,
                   let resultMap = reqJson[String.kResult] as? [String:Any]{
                    if statusCode == 200{
                        let result = PhoneCodeRulesModel.yy_model(with: resultMap)
                        subscriber.onNext((true,result))
                    }else{
                        subscriber.onNext((false,nil))
                        HUDManager.showHUD(withMessage: .errorMsg)
                    }
                }else{
                    subscriber.onNext((false,nil))
                    HUDManager.showHUD(withMessage: .errorMsg)
                }
            } failure: { req, err in
                subscriber.onNext((false,nil))
                HUDManager.showHUD(withMessage: .errorMsg)
            }
            return Disposables.create()
        }
    }
}
