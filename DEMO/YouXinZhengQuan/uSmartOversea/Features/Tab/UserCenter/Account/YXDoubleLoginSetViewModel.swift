//
//  YXDoubleLoginSetViewModel.swift
//  uSmartOversea
//
//  Created by ysx on 2022/2/15.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift


class YXDoubleLoginSetViewModel: HUDServicesViewModel {
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    typealias Services = HasYXAggregationService
    var navigator: NavigatorServicesType!
    var services: Services!
    var didSetSubject = PublishSubject<Bool>()
    var optionTyp = 0
    init() {
        
        
    }
    
    
    func switch2FARequest()  {
        let requestModel = YXDoubelLoginSetRequestModel()
        requestModel.optionType = self.optionTyp
        let request = YXRequest(request: requestModel)
        request.startWithBlock(success: { (responseModel) in
            if responseModel.code == .success {
                self.didSetSubject.onNext(true)
            } else {
                self.didSetSubject.onNext(false)
            }
        }, failure: { (request) in
            self.didSetSubject.onNext(false)
        })
    }
}
