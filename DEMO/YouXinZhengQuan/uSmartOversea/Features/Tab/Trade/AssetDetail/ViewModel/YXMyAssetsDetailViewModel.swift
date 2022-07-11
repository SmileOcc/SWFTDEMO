//
//  YXMyAssetsDetailViewModel.swift
//  uSmartOversea
//
//  Created by Evan on 2022/5/5.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

@objc enum YXMyAssetsDetailMode: Int {
    case category
    case market
}

extension YXMyAssetsDetailMode {

    var title: String {
        switch self {
        case .category:
            return YXLanguageUtility.kLang(key: "my_assets_mode_category")
        case .market:
            return YXLanguageUtility.kLang(key: "my_assets_mode_market")

        }
    }

}

class YXMyAssetsDetailViewModel: ServicesViewModel {

    typealias Services = AppServices
    var navigator: NavigatorServicesType!
    var services: Services!

    var mode: YXMyAssetsDetailMode = .category
    var moneyType: YXCurrencyType = .sg
    var exchangeRateList: [YXExchangeRateModel]?

    var assetsDetailModel: AnyObject {
        switch mode {
        case .category:
            return assetsDetailViaCategoryModel
        case .market:
            return assetsDetailViaMarketModel
        }
    }

    var assetDetailList: [AnyObject] {
        switch mode {
        case .category:
            return assetsDetailViaCategoryModel.assetDetailList
        case .market:
            return assetsDetailViaMarketModel.assetDetailList
        }
    }

    var assetsDetailViaCategoryModel = YXMyAssetsDetailViaCategoryResModel()
    var assetsDetailViaMarketModel = YXMyAssetsDetailViaMarketResModel()

    init(_ moneyType: YXCurrencyType?) {
        self.moneyType = moneyType ?? .sg
    }

    func fetchMyAssetsDetail(for mode: YXMyAssetsDetailMode = .category) -> Single<AnyObject?> {
        let single = Single<AnyObject?>.create { single in
            let requestModel = YXMyAssetsDetailReqModel()
            requestModel.myAssetsDetailMode = mode
            requestModel.moneyType = self.moneyType.requestParam

            let request = YXRequest.init(request: requestModel)
            request.startWithBlock(success: { [weak self] (response) in
                guard let `self` = self else { return }

                if let response = response as? YXMyAssetsDetailViaCategoryResModel, response.code == .success {
                    self.assetsDetailViaCategoryModel = response
                    single(.success(response))
                } else if let response = response as? YXMyAssetsDetailViaMarketResModel, response.code == .success {
                    self.assetsDetailViaMarketModel = response
                    single(.success(response))
                } else {
                    single(.error(NSError(domain: "", code: -1, userInfo: nil)))
                }
            }, failure: { (request) in
                single(.error(request.error ?? NSError(domain: "", code: -1, userInfo: nil)))
            })
            return Disposables.create()
        }

        return single
    }

    func getExchangeRateList() -> Single<[YXExchangeRateModel]?> {
        let single = Single<[YXExchangeRateModel]?>.create { single in
            let requestModel = YXConfigSelectSpotRateReqModel()
            requestModel.targetMoneyType = self.moneyType.requestParam
            let request = YXRequest.init(request: requestModel)
            request.startWithBlock(success: { [weak self] response in
                guard let `self` = self else { return }
                if let response = response as? YXConfigSelectSpotRateResModel {
                    self.exchangeRateList = response.list
                    single(.success(response.list))
                }
                single(.success([]))
            }, failure: { (request) in
                single(.error(request.error ?? NSError.init(domain: "", code: -1, userInfo: nil)))
            })

            return Disposables.create()
        }
        return single
    }

}

