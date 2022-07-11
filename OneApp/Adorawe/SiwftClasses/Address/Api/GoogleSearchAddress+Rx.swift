//
//  GoogleSearchAddress+Rx.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/9/8.
//  Copyright © 2021 starlink. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON


extension OSSVGoogleeSearcheAddressApi{
    func requestAddressList(view:UIView) -> Observable<[NSDictionary]>{
        return Observable<[NSDictionary]>.create { subscriber in
            self.accessoryArray.add(STLRequestAccessory(apperOn: view)!)
            self.start { req in
                let result = JSON(req?.responseJSONObject ?? [:])
                if let resultArr = result["predictions"].rawValue as? [NSDictionary]{
                    subscriber.onNext(resultArr)
                }else{
                    subscriber.onNext([])
                }
            } failure: { req, err in
                HUDManager.showHUD(withMessage: .errorMsg)
            }
            return Disposables.create()
        }
    }
}

extension String{
    static func googleSearchApi(input:String,components:String,language:String,sessionToken:String)->String{
        let key = OSSVLocaslHosstManager.googleSearchAddressApiKey()
//        return "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(input)&location=\(location)&radius=\(radius)&strictbounds=true&language=\(language)&types=address&key=\(key)"
        
        return "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(input)&components=\(components)&language=\(language)&types=establishment&sessiontoken=\(sessionToken)&key=\(key)"

    }
}

