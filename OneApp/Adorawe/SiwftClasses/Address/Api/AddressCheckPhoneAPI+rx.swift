//
//  OSSVAddresseCheckePhoneAip+rx.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/8/23.
//  Copyright © 2021 starlink. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import SwiftyJSON


extension OSSVAddresseCheckePhoneAip{
    func requestCheckPhone(view:UIView) -> Observable<(Bool,String?)>{
        return Observable<(Bool,String?)>.create { subscriber in
            self.accessoryArray.add(STLRequestAccessory(apperOn: view)!)
            
            self.start { req in
                if let requestJSON = OSSVNSStringTool.desEncrypt(req){
                    let result = JSON(requestJSON)
                    let message = result["message"].string
                    if result["statusCode"] == 200{
                        subscriber.onNext((true,nil))
                    }else if result["statusCode"] == 201{
                        subscriber.onNext((false,message))
                    }else{
                        HUDManager.showHUD(withMessage: message)
                    }
                }
            } failure: { req, err in
                HUDManager.showHUD(withMessage: .errorMsg)
            }
            return Disposables.create()
        }
    }
}
