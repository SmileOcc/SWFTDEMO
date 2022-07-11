//
//  YXFinancialViewModel.swift
//  uSmartOversea
//
//  Created by Kelvin on 2019/5/1.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator
import YYCategories

class YXFinancialViewModel: HUDServicesViewModel {

    typealias Services = YXQuotesDataService
    
    var services: YXQuotesDataService! = YXQuotesDataService()
    var disposeBag = DisposeBag.init()
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    var navigator: NavigatorServicesType!
    
    var market: String = ""
    var symbol: String = ""
    
    var financialIncomesDataResponse: YXResultResponse<YXFinancialData>?
    var financialBalanceDataResponse: YXResultResponse<YXFinancialData>?
    var financialCashflowDataResponse: YXResultResponse<YXFinancialData>?
    
    var HSFinancialIncomesDataResponse: YXResultResponse<YXHSFinancialData>?
    var HSFinancialBalanceDataResponse: YXResultResponse<YXHSFinancialData>?
    var HSFinancialCashflowDataResponse: YXResultResponse<YXHSFinancialData>?
    
    var listProfitDataResponse: YXResultResponse<YXStockDetailFinancialListProfitModel>?
    var listAssetDataResponse: YXResultResponse<YXStockDetailFinancialListAssetModel>?
    var listCashflowDataResponse: YXResultResponse<YXStockDetailFinancialListCashFlowModel>?

    var hsListProfitResponse: YXResultResponse<YXStockDetailFinancialListAStockModel>?
    var hsListAssetResponse: YXResultResponse<YXStockDetailFinancialListAStockModel>?
    var hsListCashflowResponse: YXResultResponse<YXStockDetailFinancialListAStockModel>?
    
    var financialIncomesSubject = PublishSubject<Any?>()
    var financialBalanceSubject = PublishSubject<Any?>()
    var financialCashFlowSubject = PublishSubject<Any?>()

    var listProfitSubject = PublishSubject<Any?>()
    var listAssetSubject = PublishSubject<Any?>()
    var listCashFlowSubject = PublishSubject<Any?>()

    var hsListProfitSubject = PublishSubject<Any?>()
    var hsListAssetSubject = PublishSubject<Any?>()
    var hsListCashFlowSubject = PublishSubject<Any?>()

    var marketFinancialResponse: YXResultResponse<JSONAny>?
    let marketFinancialSubject = PublishSubject<[YXFinancialMarketDetaiModel]>()
    
    //models
    var financialIncomesData: YXFinancialData?
    var financialBalanceData: YXFinancialData?
    var financialCashFlowData: YXFinancialData?
    
    //models
    var HSFinancialIncomesData: YXHSFinancialData?
    var HSFinancialBalanceData: YXHSFinancialData?
    var HSFinancialCashFlowData: YXHSFinancialData?
    
    var listProfitData: YXStockDetailFinancialListProfitModel?
    var listAssetData: YXStockDetailFinancialListAssetModel?
    var listCashFlowData: YXStockDetailFinancialListCashFlowModel?
    var hsListProfitData: YXStockDetailFinancialListAStockModel?
    var hsListAssetData: YXStockDetailFinancialListAStockModel?
    var hsListCashFlowData: YXStockDetailFinancialListAStockModel?
    
    init() {
        //财务-盈利
        financialIncomesDataResponse = {[weak self] (response) in
            self?.hudSubject.onNext(.hide)
            switch response {
            case .success(let result, let code):
                if code == .success, let list = result.data?.list, list.count > 0  {
                    self?.financialIncomesData = result.data
                    self?.financialIncomesSubject.onNext(result.data as Any)
                } else {
                    self?.financialIncomesSubject.onNext(nil)
                }
            case .failed(_):
                self?.financialIncomesSubject.onNext(nil)
                break
                
            }
        }
        
        //财务-资产
        financialBalanceDataResponse = {[weak self] (response) in
            self?.hudSubject.onNext(.hide)
            switch response {
            case .success(let result, let code):
                
                if code == .success, let list = result.data?.list, list.count > 0 {
                    
                    self?.financialBalanceData = result.data
                    self?.financialBalanceSubject.onNext(result.data as Any)
                } else {
                    self?.financialBalanceSubject.onNext(nil)
                }

                break
            case .failed(_):
                self?.financialBalanceSubject.onNext(nil)
                break
                
            }
        }
        
        //财务-
        financialCashflowDataResponse = {[weak self] (response) in
            self?.hudSubject.onNext(.hide)
            switch response {
            case .success(let result, let code):
                
                if code == .success, let list = result.data?.list, list.count > 0 {
                    
                    self?.financialCashFlowData = result.data
                    self?.financialCashFlowSubject.onNext(result.data as Any)
                } else {
                    self?.financialCashFlowSubject.onNext(nil)
                }
                
                break
            case .failed(_):
                self?.financialCashFlowSubject.onNext(nil)
                break
                
            }
        }
        
        
        /*A股*/
        
        //财务-盈利
        HSFinancialIncomesDataResponse = {[weak self] (response) in
            self?.hudSubject.onNext(.hide)
            switch response {
            case .success(let result, let code):
                if code == .success, let list = result.data?.list, list.count > 0  {
                    self?.HSFinancialIncomesData = result.data
                    self?.financialIncomesSubject.onNext(result.data as Any)
                } else {
                    self?.financialIncomesSubject.onNext(nil)
                }
            case .failed(_):
                self?.financialIncomesSubject.onNext(nil)
                break
                
            }
        }
        
        //财务-资产
        HSFinancialBalanceDataResponse = {[weak self] (response) in
            self?.hudSubject.onNext(.hide)
            switch response {
            case .success(let result, let code):
                
                if code == .success, let list = result.data?.list, list.count > 0 {
                    
                    self?.HSFinancialBalanceData = result.data
                    self?.financialBalanceSubject.onNext(result.data as Any)
                } else {
                    self?.financialBalanceSubject.onNext(nil)
                }
                
                break
            case .failed(_):
                self?.financialBalanceSubject.onNext(nil)
                break
                
            }
        }
        
        //财务-
        HSFinancialCashflowDataResponse = {[weak self] (response) in
            self?.hudSubject.onNext(.hide)
            switch response {
            case .success(let result, let code):
                
                if code == .success, let list = result.data?.list, list.count > 0 {
                    
                    self?.HSFinancialCashFlowData = result.data
                    self?.financialCashFlowSubject.onNext(result.data as Any)
                } else {
                    self?.financialCashFlowSubject.onNext(nil)
                }
                
                break
            case .failed(_):
                self?.financialCashFlowSubject.onNext(nil)
                break
                
            }
        }
        
        //利润列表
        listProfitDataResponse = {[weak self] (response) in
            self?.hudSubject.onNext(.hide)
            switch response {
            case .success(let result, let code):
                
                if code == .success, let _ = result.data {
                    
                    self?.listProfitData = result.data
                    self?.listProfitSubject.onNext(result.data as Any)
                } else {
                    self?.listProfitSubject.onNext(nil)
                }
                
                break
            case .failed(_):
                self?.listProfitSubject.onNext(nil)
                break
                
            }
        }
        
        
        //资产列表
        listAssetDataResponse = {[weak self] (response) in
            self?.hudSubject.onNext(.hide)
            switch response {
            case .success(let result, let code):
                
                if code == .success, let _ = result.data?.list {
                    
                    self?.listAssetData = result.data
                    self?.listAssetSubject.onNext(result.data as Any)
                } else {
                    self?.listAssetSubject.onNext(nil)
                }
                
                break
            case .failed(_):
                self?.listAssetSubject.onNext(nil)
                break
                
            }
        }
        
        
        //现金流列表
        listCashflowDataResponse = {[weak self] (response) in
            self?.hudSubject.onNext(.hide)
            switch response {
            case .success(let result, let code):
                
                if code == .success, let _ = result.data?.list {
                    
                    self?.listCashFlowData = result.data
                    self?.listCashFlowSubject.onNext(result.data as Any)
                } else {
                    self?.listCashFlowSubject.onNext(nil)
                }
                
                break
            case .failed(_):
                self?.listCashFlowSubject.onNext(nil)
                break
                
            }
        }
        
        
        //A股 资产，利润， 现金流
        hsListProfitResponse = {[weak self] (response) in
            self?.hudSubject.onNext(.hide)
            switch response {
            case .success(let result, let code):
                
                if code == .success, let _ = result.data?.list {
                    
                    self?.hsListProfitData = result.data
                    self?.hsListProfitSubject.onNext(result.data as Any)
                } else {
                    self?.hsListProfitSubject.onNext(nil)
                }
                
                break
            case .failed(_):
                self?.hsListProfitSubject.onNext(nil)
                break
                
            }
        }

        hsListAssetResponse = {[weak self] (response) in
            self?.hudSubject.onNext(.hide)
            switch response {
                case .success(let result, let code):

                    if code == .success, let _ = result.data?.list {

                        self?.hsListAssetData = result.data
                        self?.hsListAssetSubject.onNext(result.data as Any)
                    } else {
                        self?.hsListAssetSubject.onNext(nil)
                    }

                    break
                case .failed(_):
                    self?.hsListAssetSubject.onNext(nil)
                    break

            }
        }

        hsListCashflowResponse = {[weak self] (response) in
            self?.hudSubject.onNext(.hide)
            switch response {
                case .success(let result, let code):

                    if code == .success, let _ = result.data?.list {

                        self?.hsListCashFlowData = result.data
                        self?.hsListCashFlowSubject.onNext(result.data as Any)
                    } else {
                        self?.hsListCashFlowSubject.onNext(nil)
                    }

                    break
                case .failed(_):
                    self?.hsListCashFlowSubject.onNext(nil)
                    break

            }
        }

        //主要指标
        marketFinancialResponse = {[weak self] (response) in
            guard let `self` = self else { return }
            self.hudSubject.onNext(.hide)
            switch response {
                case .success(let result, let code):

                    if code == .success, let data = result.data?.value as? [String : Any], let dic = data["list"] {

                        if let list = NSArray.yy_modelArray(with: YXFinancialMarketDetaiModel.self, json: dic) as? [YXFinancialMarketDetaiModel] {
                            self.marketFinancialSubject.onNext(list)
                        } else {
                            self.marketFinancialSubject.onNext([])
                        }
                    } else {
                        self.marketFinancialSubject.onNext([])
                    }

                    break
                case .failed(_):
                    self.marketFinancialSubject.onNext([])
                    break

            }
        }
        
    }
    
}
