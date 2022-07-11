//
//  GMSPlaceHelper.swift
//  Adorawe
//
//  Created by fan wang on 2021/12/10.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import GooglePlaces
import RxSwift

class GMSPlaceHelper: NSObject {
    static let sessionToken = GMSAutocompleteSessionToken()
    static func getDetailsInfo(placeId:String)->Observable<GMSPlace?>{
        let result = Observable<GMSPlace?>.create { subscriber in
            GMSPlacesClient.shared().fetchPlace(fromPlaceID: placeId, placeFields: GMSPlaceField(rawValue: UInt.max) , sessionToken: sessionToken) { place, err in
                if let err = err{
                    subscriber.onError(err)
                }else{
                    subscriber.onNext(place)
                }
            }
            return Disposables.create()
        }
        return result
    }
}
