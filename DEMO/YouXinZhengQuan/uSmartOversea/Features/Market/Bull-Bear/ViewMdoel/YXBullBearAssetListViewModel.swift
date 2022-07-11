//
//  YXBullBearAssetListViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/4/10.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

enum YXAssetListSortType: Int {
    case price = 0
    case roc = 1
}

enum YXAssetListSortDirection: Int {
    case ascending = 0
    case descending = 1
}

class YXBullBearAssetListViewModel: YXViewModel {
    
    var derivativeType: YXDerivativeType = .bullBear
    var dataSource: [YXBullBearAsset]?
    var selectedItemSubject = PublishSubject<YXBullBearAsset>()
    
    override init(services: YXViewModelServices, params: [AnyHashable : Any]?) {
        super.init(services: services, params: params)
        
        if let typeStr = params?["type"] as? String {
            if typeStr == "cbbc" {
                derivativeType = .bullBear
            }else {
                derivativeType = .warrant
            }
        }else {
            derivativeType = .bullBear
        }
    }
    
    init(services: YXViewModelServices, type: YXDerivativeType) {
        super.init(services: services, params: [:])
        derivativeType = type
    }
    
    // 资产列表
    func getAssetlist(sortType: YXAssetListSortType, sortDirection: YXAssetListSortDirection) -> Single<[YXBullBearAsset]?> {
        
        let single = Single<[YXBullBearAsset]?>.create { single in
            let requestModel = YXBullBearAssetListReqModel()
            requestModel.type = self.derivativeType.rawValue
            requestModel.sortType = sortType.rawValue
            requestModel.sortDirection = sortDirection.rawValue
        
            let request = YXRequest.init(request: requestModel)
            
            request.startWithBlock(success: { [weak self](response) in
                var assetModel: YXBullBearAssetListModel?
                if response.code == YXResponseStatusCode.success {
                    assetModel = YXBullBearAssetListModel.yy_model(withJSON: response.data ?? [:])
                }
                self?.dataSource = assetModel?.list
                single(.success(assetModel?.list))
            }, failure: { (request) in
                single(.error(request.error ?? NSError.init(domain: "", code: -1, userInfo: nil)))
            })
            return Disposables.create()
        }
        
        return single
    }
    
    @objc func isInAssetList(market: String, symbol: String) -> Bool {
        if let arr = self.dataSource {
            for item in arr {
                if item.market == market, item.symbol == symbol {
                    return true
                }
            }
            self.showToast()
            return false
        }else {
            self.showToast()
            return false
        }
    }
    
    func showToast() {
        let msg = self.derivativeType == .bullBear ? YXLanguageUtility.kLang(key: "bullbear_noCBBC_asset") : YXLanguageUtility.kLang(key: "bullbear_noWarrant_asset")
        YXProgressHUD.showMessage(msg)
    }
}
