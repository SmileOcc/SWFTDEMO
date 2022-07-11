//
//  YXHotETFViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/5/21.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXHotETFViewModel: YXViewModel {
    
    let hotETFFirstReqCode = "HOTETFFIRST_ALL"
    let hotETFSecondReqCodePre = "HOTETFSECOND"
    
    var rankServices = YXNewStockService()
    
    var etfSectionInfo: YXMarketResponseModel?
    var section_listDic = [String : YXMarketResponseModel]()
    
    var market = ""
    
    override func initialize() {
        super.initialize()
        
        if let market = self.params?["market"] as? String {
            self.market = market
        }
    }
    
    func getETF() -> Single<YXMarketResponseModel?> {
        // 先请求一级热门ETF,只会返回一级的类别（表现在界面上就是section）
        getETFFirst().flatMap { [weak self](marketResponseModel) in

            guard let `self` = self else { return Observable.empty().asSingle() }

            // 再把一级接口返回的类别的code拼到二级常数"HOTETFSECOND"的末尾，请求回该类别的二级数据，例如返回指数型的code为EBK001, 要取得指数型的二级数据，则需要拼接成“HOTETFSECOND_EBK001”发给服务端
            var codes = [String]()
            if let list = marketResponseModel?.item?.list {
                for dic in list {
                    if let code = dic["secuCode"] as? String {
                        let reqCode = String(format: "%@_%@", self.hotETFSecondReqCodePre, code)
                        codes.append(reqCode)
                    }
                }
            }

            return self.getETFSecond(codes: codes)
        }
    }
    
    func getETFFirst() -> Single<YXMarketResponseModel?> {
        
        let single = Single<YXMarketResponseModel?>.create { single in
            
            let requestModel = YXMarketMergeRequestModel()
            
            let authority = YXUserManager.shared().getLevel(with: self.market)//YXUserManager.shareInstance().getQuoteAuthority(self.market)
            let requestItem = YXMarketRequestItem.init()
            requestItem.code = self.hotETFFirstReqCode
            requestItem.market = self.market
            requestItem.level = authority.rawValue
            
            requestModel.codelist = [requestItem]
            
            let request = YXRequest.init(request: requestModel)
            
            request.startWithBlock(success: { [weak self](response) in
                
                if let res = response as? YXMarketMergeResponseModel, res.code == YXResponseStatusCode.success {
                    
                    let marketResponseModel = YXMarketResponseModel.yy_model(withJSON: res.list?.first as Any)
                    self?.etfSectionInfo = marketResponseModel
                    single(.success(marketResponseModel))
                }else {
                    single(.success(nil))
                }

            }, failure: { (request) in
                single(.error(request.error ?? NSError.init(domain: "", code: -1, userInfo: nil)))
            })
            
            return Disposables.create()
        }
        
        return single
    }
    
    func getETFSecond(codes: [String]) -> Single<YXMarketResponseModel?> {
        
        let single = Single<YXMarketResponseModel?>.create { single in
            let requestModel = YXMarketMergeRequestModel()
            
            let authority = YXUserManager.shared().getLevel(with: self.market)
            var requestItems = [YXMarketRequestItem]()
            
            for code in codes {
                let requestItem = YXMarketRequestItem.init()
                requestItem.code = code
                requestItem.market = self.market
                requestItem.level = authority.rawValue
                
                requestItems.append(requestItem)
            }
            
            requestModel.codelist = requestItems
            
            let request = YXRequest.init(request: requestModel)
            
            request.startWithBlock(success: { [weak self](response) in

                if let res = response as? YXMarketMergeResponseModel, res.code == YXResponseStatusCode.success, let list = res.list {
                    for dic in list {
                        let marketResponseModel = YXMarketResponseModel.yy_model(withJSON: dic as Any)
                        if let model = marketResponseModel, let code = model.item?.rankCode {
                            let arr = code.split(separator: "_")
                            if arr.count > 1 {
                                let key = String(arr[1])
                                self?.section_listDic[key] = model
                            }
                        }
                    }
                    
                    single(.success(nil))
                }else {
                    single(.success(nil))
                }
                
            }, failure: { (request) in
                single(.error(request.error ?? NSError.init(domain: "", code: -1, userInfo: nil)))
            })
            return Disposables.create()
        }
        
        return single
    }
    
}
