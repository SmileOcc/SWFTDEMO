//
//  YXStockDetailIntroduce.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/7/19.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator

class YXStockDetailIntroduceViewModel: HUDServicesViewModel {
    
    typealias Services = YXStockIntroduceService
    var services: YXStockIntroduceService! = YXStockIntroduceService()
    var disposeBag = DisposeBag.init()
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    var navigator: NavigatorServicesType!
    
    var introduceModel: YXStockIntroduceModel = YXStockIntroduceModel()
    
    var configModel = YXStockIntroduceConfigModel.init()
    
    var market: String = ""
    var symbol: String = ""
    
    
    var companyInfoSubject = PublishSubject<Any>()
    var companyInfoResponse: YXResultResponse<YXStockIntroduceModel>?
    
    var companyProfitSubject = PublishSubject<Any>()
    var companyProfitResponse: YXResultResponse<YXStockIntroduceModel>?

    var newStockDataSubject = PublishSubject<YXNewStockDetailInfoModel>()
    var newStockDataResponse: YXResultResponse<YXNewStockDetailInfoModel>?

    var newStockData: YXNewStockDetailInfoModel?

    var quotesDataService: YXQuotesDataService = YXQuotesDataService()

    var exchangeType: YXExchangeType {
        var type: YXExchangeType = .hk
        if market == YXMarketType.HK.rawValue {
            type = .hk
        } else if market == YXMarketType.US.rawValue {
            type = .us
        } else if market == YXMarketType.ChinaHS.rawValue {
            type = .hs
        } else if market == YXMarketType.ChinaSZ.rawValue {
            type = .sz
        } else if market == YXMarketType.ChinaSH.rawValue {
            type = .sh
        } else if market == YXMarketType.SG.rawValue {
            type = .sg
        }

        return type
    }
    
    init() {
        
        
        // 公司簡介
        companyInfoResponse = {[weak self] (response) in
            
            switch response {
            case .success(let result, let code):
                if code == .success, let data = result.data {
                    self?.introduceModel.profile = data.profile
                    self?.introduceModel.maincomparea = data.maincomparea
                    self?.introduceModel.maincompbus = data.maincompbus
                    self?.introduceModel.toptenshareholders = data.toptenshareholders
                    self?.companyInfoSubject.onNext(true)
                }else{
                    self?.companyInfoSubject.onNext(false)
                }
                break
            case .failed(_):
                self?.companyInfoSubject.onNext(false)
                break
            }
        }
        
        // 公司回购,分红
        companyProfitResponse = {[weak self] (response) in
            
            switch response {
            case .success(let result, let code):
                if code == .success, let data = result.data{
                    self?.introduceModel.buyback = data.buyback
                    self?.introduceModel.dividend = data.dividend
                    self?.introduceModel.splitshare = data.splitshare
                    self?.companyProfitSubject.onNext("")
                }
                break
            case .failed(_):
                break
                
            }
        }


        // 新股
        newStockDataResponse = {[weak self] (response) in
            switch response {
                case .success(let result, let code):
                    if code == .success, let data = result.data {
                        self?.newStockData = data
                        self?.newStockDataSubject.onNext(data)
                    }
                case .failed(_):
                    break
            }
        }
    }
}
