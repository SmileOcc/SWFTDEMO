//
//  YXAccountAssetViewModel.swift
//  uSmartOversea
//
//  Created by 覃明明 on 2021/7/6.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import YXKit
import NSObject_Rx
import URLNavigator
import MMKV

class YXAccountAssetViewModel: HasDisposeBag {

    private let kUserAccountAssetMoneyTypeKey = "YXUserAccountAssetMoneyTypeKey"

    var navigator: NavigatorServicesType!

    var exchangeType : YXExchangeType = .us

    var moneyType: YXCurrencyType? {
        set {
            if let value = newValue {
                MMKV.default().set(value.requestParam, forKey: kUserAccountAssetMoneyTypeKey)
            }
        }

        get {
            if let currency = MMKV.default().string(forKey: kUserAccountAssetMoneyTypeKey) {
                let moneyType = YXCurrencyType.currenyType(currency)
                return moneyType
            }

            return nil
        }
    }
    
    var accountAssetModel: YXAccountAssetResModel?
    var exchangeRateList: [YXExchangeRateModel]?

    lazy var holdViewModel: YXHomeHoldViewModel = {
        let vm = YXHomeHoldViewModel(services: navigator, params: ["isAssetPage": true])
        return vm
    }()
    
    lazy var todayOrderViewModel: YXTodayOrderViewModel = {
        let todayOrderViewModel = YXTodayOrderViewModel(services: navigator, params: ["isAssetPage": true])
        return todayOrderViewModel
    }()
    
    func getData() -> Single<YXAccountAssetResModel?> {
        let single = Single<YXAccountAssetResModel?>.create { single in
            let requestModel = YXAccountAssetReqModel()
            requestModel.userId = String(YXUserManager.userUUID())
            if let moneyType = self.moneyType {
                requestModel.moneyType = moneyType.requestParam
            }
            requestModel.accountBusinessType = 100

            let request = YXRequest.init(request: requestModel)
            
            request.startWithBlock(success: { [weak self](response) in
                
                guard let `self` = self else { return }

                if response.code == YXResponseStatusCode.success {
                    self.accountAssetModel = YXAccountAssetResModel.yy_model(withJSON: response.data ?? [:])
                    self.accountAssetModel?.calculate()
                    if let m = self.accountAssetModel {
                        self.holdViewModel.assetModel = m
                        self.holdViewModel.reloadDataSource()
                    }

                    if let moneyTypeStr = self.accountAssetModel?.totalData?.moneyType {
                        self.moneyType = YXCurrencyType.currenyType(moneyTypeStr)
                    }
                }
        
                single(.success(self.accountAssetModel))
            }, failure: { (request) in
                single(.error(request.error ?? NSError.init(domain: "", code: -1, userInfo: nil)))
            })
            return Disposables.create()
        }
        
        return single
    }

    /// 查询即期汇率配置
    /// - Returns: 汇率列表
    func getExchangeRateList() -> Single<[YXExchangeRateModel]?> {
        let single = Single<[YXExchangeRateModel]?>.create { single in
            guard let moneyType = self.moneyType else {
                single(.success([]))
                return Disposables.create()
            }

            let requestModel = YXConfigSelectSpotRateReqModel()
            requestModel.targetMoneyType = moneyType.requestParam
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

    func requestTodayViewModel() {
        todayOrderViewModel.update(withExchangeType: exchangeType.rawValue)
    }

}
