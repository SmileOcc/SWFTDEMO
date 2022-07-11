//
//  AddressEditApi+Rx.swift
//  Adorawe
//
//  Created by fan wang on 2021/12/13.
//  Copyright © 2021 starlink. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON


extension OSSVAddresseAddeAip{
    func sendRequest(view:UIView) -> Observable<(Bool,String?)>{
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

extension OSSVModifyeAddresseAip{
    func sendRequest(view:UIView) -> Observable<(Bool,String?)>{
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
