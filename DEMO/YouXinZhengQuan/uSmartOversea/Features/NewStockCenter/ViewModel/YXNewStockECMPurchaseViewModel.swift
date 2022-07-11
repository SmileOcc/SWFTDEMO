//
//  YXNewStockECMPurchaseViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/10/22.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator

class YXNewStockECMPurchaseViewModel: HUDServicesViewModel {
    typealias Services = YXNewStockService
    
    var navigator: NavigatorServicesType!
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    let alertSubject = PublishSubject<Bool>()
    
    var sourceParam: YXPurchaseDetailParams!
    //响应回调
    var availbleAmountResponse: YXResultResponse<YXNewStockAvailbleAmountModel>?
    var ecmResponse: YXResultResponse<YXNewStockECMOrderInfoModel>?
    //Rx代理回调
    typealias resultType = (isSuccess: Bool, msg: String?)
    let amountSubject = PublishSubject<resultType>()
    let ecmSubject = PublishSubject<resultType>()
    lazy var groupOberver: Observable<[resultType]> = { [unowned self] in
        Observable.zip([self.ecmSubject, self.amountSubject])
    }()

    var services: Services! = YXNewStockService()
    var ecmModel: YXNewStockECMOrderInfoModel?

    var availableAmount: Double = 0.0
    var unitString = YXToolUtility.moneyUnit(2)
    
    init() {
       
        ecmResponse = {
            [weak self] (response) in
            guard let strongSelf = self else { return }
            switch response {
            case .success(let result, let code):
                if code == .success, let model = result.data {
                    //认购股数/金额
                    if let moneyType = model.moneyType {
                        strongSelf.unitString = YXToolUtility.moneyUnit(moneyType)
                    }
                    strongSelf.ecmModel = model
                    strongSelf.ecmSubject.onNext((true, nil))
                } else if let msg = result.msg {
                    strongSelf.ecmSubject.onNext((false, msg))
                }
                
            case .failed(let error):
                log(.error, tag: kNetwork, content: "\(error)")
                strongSelf.ecmSubject.onNext((false, YXLanguageUtility.kLang(key: "common_net_error")))
            }
        }
        
        
        availbleAmountResponse = {
            [weak self] (response) in
            guard let strongSelf = self else { return }
            switch response {
            case .success(let result, let code):
                if code == .success, let model = result.data {
                    if let yxIpoBalance = model.yxIpoBalance, let amount = Double(yxIpoBalance) {
                        strongSelf.availableAmount = amount + strongSelf.sourceParam.applied_amount + strongSelf.sourceParam.interestAmount
                        strongSelf.amountSubject.onNext((true,nil))
                    } else {
                        strongSelf.amountSubject.onNext((false,nil))
                    }
                    
                } else if let _ = result.msg {
                    strongSelf.amountSubject.onNext((false,nil))
                }
            case .failed(let error):
                log(.error, tag: kNetwork, content: "\(error)")
                strongSelf.amountSubject.onNext((false,nil))
            }
        }
    }
    
}
