//
//  YXBondDetailViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/8/14.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import URLNavigator
import NSObject_Rx

class YXBondDetailViewModel: HUDServicesViewModel, HasDisposeBag {
    typealias Services = HasYXTradeService
    
    var navigator: NavigatorServicesType!
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    let orderNo: Int64
    
    var detailResponse: YXResultResponse<YXBondDetailModel>?
    
    let detailRelay: BehaviorRelay<YXBondDetailModel?> = BehaviorRelay<YXBondDetailModel?>(value: nil)
    
    var services: Services! {
        didSet {
            detailResponse = { [weak self] (response) in
                
                self?.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    if code == .success {
                        self?.detailRelay.accept(result.data)
                    } else {
                        if let msg = result.msg {
                            self?.hudSubject.onNext(.error(msg, false))
                        }
                    }
                case .failed(_):
                    self?.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
        }
    }
    
    init(orderNo: Int64) {
        self.orderNo = orderNo
    }
    
    func requestDetail() {
        hudSubject.onNext(.loading(nil, false))
        services.tradeService.request(.bondOrderDetail(orderNo: self.orderNo), response: detailResponse).disposed(by: disposeBag)
    }
}
