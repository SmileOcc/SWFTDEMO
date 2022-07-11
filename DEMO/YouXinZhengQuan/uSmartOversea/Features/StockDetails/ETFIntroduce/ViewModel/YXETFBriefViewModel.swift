//
//  YXETFBriefViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2021/3/5.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import YYModel
import URLNavigator

class YXETFBriefViewModel: HUDServicesViewModel {
    // hud的信号
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    //step/service
    typealias Services = YXQuotesDataService
    var services: YXQuotesDataService! = YXQuotesDataService()

    var navigator: NavigatorServicesType!

    @objc var type3: OBJECT_SECUSecuType3 = OBJECT_SECUSecuType3.stEtf

    @objc var symbol: String = ""
    @objc var name: String = ""
    @objc var market: String = ""

    //init
    init() {

    }


    func requestBriefInfo() -> Single<YXETFBriefModel?> {

        return Single<YXETFBriefModel?>.create { [weak self] (single) -> Disposable in
            guard let `self` = self else { return Disposables.create() }

            let requestModel = YXETFBriefRequestModel()
            requestModel.code = self.market + self.symbol

            let request = YXRequest.init(request: requestModel)

            request.startWithBlock(success: { (responseModel) in

                if responseModel.code == .success, let data = responseModel.data {
                    let model = YXETFBriefModel.yy_model(with: data)
                    single(.success(model))
                } else {
                    single(.success(nil))
                }

            }, failure: { (request) in
                single(.error(NSError.init(domain: "", code: -1, userInfo: nil)))
            })

            return Disposables.create()
        }
    }


}

