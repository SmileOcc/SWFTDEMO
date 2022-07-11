//
//  OrderApi+Rx.swift
//  Adorawe
//
//  Created by fan wang on 2021/12/14.
//  Copyright © 2021 starlink. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

extension OSSVCartCheckAip{
    func sendRequest(view:UIView) -> Observable<JSON?> {
        self.accessoryArray.add(STLRequestAccessory(apperOn: view)!)
        let result = Observable<JSON?>.create { subscriber in
            self.start { req in
                if let requestJSON = OSSVNSStringTool.desEncrypt(req){
                    subscriber.onNext(JSON(requestJSON))
                }
            } failure: { req, err in
                if let err = err {
                    subscriber.onError(err)
                }
            }
            return Disposables.create()
        }
        return result
    }
}
