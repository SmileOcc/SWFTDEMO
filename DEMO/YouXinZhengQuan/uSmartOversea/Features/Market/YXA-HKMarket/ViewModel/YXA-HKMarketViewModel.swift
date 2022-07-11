//
//  YXA-HKMarketViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/3/17.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import URLNavigator

class YXA_HKMarketViewModel: YXViewModel {
    var direction: YXA_HKDirection!
    var offset: Int64 = 0
    var klineDatas = [YXA_HKFundTrendKlineCustomModel]()
    var hasMoreKlineDatas = true
    
    init(services: YXViewModelServices, direction: YXA_HKDirection) {
        super.init(services: services, params: [:])

        self.direction = direction
    }
    
    // 额度
    func getFundAmount() -> Single<YXA_HKFundAmountResModel?> {
        let single = Single<YXA_HKFundAmountResModel?>.create { single in
            let requestModel = YXA_HKFundAmountRequestModel()
            requestModel.direction = self.direction.rawValue
            
            let request = YXRequest.init(request: requestModel)
            
            request.startWithBlock(success: { (response) in
                if response.code == YXResponseStatusCode.success {
                    let amountModel = YXA_HKFundAmountResModel.yy_model(withJSON: response.data ?? [:])
                    single(.success(amountModel))
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
    
    // 额度k线
    func getKlineData() -> Single<[YXA_HKFundTrendKlineCustomModel]?> {
        
        let single = Single<[YXA_HKFundTrendKlineCustomModel]?>.create { single in
            let requestModel = YXA_HKFundTrendRequestModel()
            requestModel.ktype = "day"
            requestModel.offset = self.offset
            
            if self.direction == .north {
                requestModel.codeList = [YXA_HKMarket.hs.klineCode, YXA_HKMarket.sh.klineCode, YXA_HKMarket.sz.klineCode, kYXIndexSSE, kYXIndexSZSE]
            }else {
                requestModel.codeList = [YXA_HKMarket.hk.klineCode, YXA_HKMarket.hksh.klineCode, YXA_HKMarket.hksz.klineCode, kYXIndexHSI]
            }
            
            
            let request = YXRequest.init(request: requestModel)
            
            request.startWithBlock(success: { [weak self](response) in
                if response.code == YXResponseStatusCode.success {
                    let model = YXA_HKFundTrendResModel.yy_model(withJSON: response.data ?? [:])
                    guard let `self` = self else { return }
                    if self.offset == 0 {
                        self.klineDatas = []
                    }
                    if let klineModel = model {
    
                        var totalFundDatas = [YXA_HKFundTrendKlineItem]()
                        var shFundDatas = [YXA_HKFundTrendKlineItem]()
                        var szFundDatas = [YXA_HKFundTrendKlineItem]()
                        var indexDatas1 = [YXA_HKFundTrendKlineItem]()
                        var indexDatas2 = [YXA_HKFundTrendKlineItem]()
                        var totalFundPriceBase = 0
                        var shFundPriceBase = 0
                        var szFundPriceBase = 0
                        var shIndexPriceBase = 0
                        var szIndexPriceBase = 0
                        var nextReqDay:Int64 = 0
                        
                        for item in klineModel.codeKlineList {
                            switch item.code {
                            case YXA_HKMarket.hs.klineCode, YXA_HKMarket.hk.klineCode:
                                totalFundDatas = item.klineList
                                totalFundPriceBase = item.priceBase
                                nextReqDay = item.nextReqDay
                            case YXA_HKMarket.sh.klineCode, YXA_HKMarket.hksh.klineCode:
                                shFundDatas = item.klineList
                                shFundPriceBase = item.priceBase
                            case YXA_HKMarket.sz.klineCode, YXA_HKMarket.hksz.klineCode:
                                szFundDatas = item.klineList
                                szFundPriceBase = item.priceBase
                            case kYXIndexSSE, kYXIndexHSI:
                                indexDatas1 = item.klineList
                                shIndexPriceBase = item.priceBase
                            case kYXIndexSZSE:
                                indexDatas2 = item.klineList
                                szIndexPriceBase = item.priceBase
                            default:
                                break
                            }
                        }
                        
                        if totalFundDatas.count < requestModel.count {
                            self.hasMoreKlineDatas = false
                        }else {
                            self.offset = nextReqDay
                            self.hasMoreKlineDatas = true
                        }
                        
                        for (index, _) in totalFundDatas.enumerated() {
                            let model = YXA_HKFundTrendKlineCustomModel()
                            model.totalAmount = self.caculatedFundValue(value: totalFundDatas[index].amount, priceBase: totalFundPriceBase)
                            model.shAmount = self.caculatedFundValue(value: shFundDatas[index].amount, priceBase: shFundPriceBase)
                            model.szAmount = self.caculatedFundValue(value: szFundDatas[index].amount, priceBase: szFundPriceBase)
                            model.time = totalFundDatas[index].time
                            
                            if self.direction == .north {
                                if index < indexDatas1.count {
                                    model.shIndexPrice = self.caculatedIndexValue(value: indexDatas1[index].price, priceBase: shIndexPriceBase)
                                    model.shIndexChangeAmount = indexDatas1[index].amount
                                }
                                
                                if index < indexDatas2.count {
                                    model.szIndexPrice = self.caculatedIndexValue(value: indexDatas2[index].price, priceBase: szIndexPriceBase)
                                    model.szIndexChangeAmount = indexDatas2[index].amount
                                }
                                
                            }else {
                                if index < indexDatas1.count {
                                    model.HSIIndexPrice = self.caculatedIndexValue(value: indexDatas1[index].price, priceBase: shIndexPriceBase)
                                    model.HSIIndexChangeAmount = indexDatas1[index].amount
                                }
                            }
                            
                            self.klineDatas.append(model)
                        }
                        
                    }
                    
                    
                    single(.success(self.klineDatas))
                }else {
                    single(.success(self?.klineDatas))
                }
                
            }, failure: { (request) in
                single(.error(request.error ?? NSError.init(domain: "", code: -1, userInfo: nil)))
            })
            return Disposables.create()
        }
        
        return single
    }
    
    func caculatedFundValue(value: Int64, priceBase: Int) -> Double {
        // 转成亿
        Double(value)/pow(10.0, Double(priceBase))/100000000.0
    }
    
    func caculatedIndexValue(value: Int64, priceBase: Int) -> Double {
        Double(value)/pow(10.0, Double(priceBase))
    }
}
