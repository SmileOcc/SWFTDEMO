//
//  YXBullBearMoreViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/4/13.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXBullBearMoreViewModel: YXViewModel {
    var section: YXBullBearContractSectionType = .street
    var derivativeType: YXDerivativeType = .bullBear
    var financial = YXBullBearFinancialReportResModel()
    var fundFlow = YXBullBearFundFlowResModel()
    var pbSignal = YXBullBearPbSignalResModel()
    var maxFundFlow: Int64 = 0
    var nextPage = 0
    var hasMore = true
    var nextPageUnixTime = 0 // 多空信号时间入参
    var id: String?
    
    override init(services: YXViewModelServices, params: [AnyHashable : Any]!) {
        super.init(services: services, params: params)
        if let typeStr = params["type"] as? String {
            derivativeType = YXDerivativeType(rawValue: typeStr) ?? .warrantcbbc
        }else {
            derivativeType = .bullBear
        }
        
        id = params["id"] as? String
        
        if let sectionType = params["sectionType"] as? String {
            switch sectionType {
            case "street":
                section = .street
            
            case "longShortSignal":
                section = .longShortSignal
            default:
                section = .street
            }
        }else {
            section = .street
        }
    }
    
    convenience init(services: YXViewModelServices, type: YXDerivativeType, sectionType: YXBullBearContractSectionType, params: [AnyHashable : Any] = [:]) {
        self.init(services: services, params: params)
        self.derivativeType = type
        self.section = sectionType
    }
    
    // 财报牛熊
    func getFinancial() -> Single<YXBullBearFinancialReportResModel?> {
        
        let single = Single<YXBullBearFinancialReportResModel?>.create { single in
            let requestModel = YXBullBearFinancialReportReqModel()
            requestModel.type = self.derivativeType.rawValue
            requestModel.size = 20
            requestModel.nextPageRef = self.nextPage
        
            let request = YXRequest.init(request: requestModel)
            
            request.startWithBlock(success: { [weak self](response) in
                if response.code == YXResponseStatusCode.success {
                    let financialModel = YXBullBearFinancialReportResModel.yy_model(withJSON: response.data ?? [:])
                    guard let `self` = self else { return }
                    if self.nextPage == 0 {
                        self.financial.list = []
                    }
                    if let model = financialModel {
                        if model.nextPageRef != 0 {
                            self.nextPage = model.nextPageRef
                        }
                        self.hasMore = model.hasMore
                        
                        self.financial.list = self.financial.list + model.list
                    }
                }
        
                single(.success(self?.financial))
            }, failure: { (request) in
                single(.error(request.error ?? NSError.init(domain: "", code: -1, userInfo: nil)))
            })
            return Disposables.create()
        }
        
        return single
    }
    
    // 五大资金流入流出
    func getFundFlow(type: YXBullBearFundFlowType) -> Single<YXBullBearFundFlowResModel?> {
        
        let single = Single<YXBullBearFundFlowResModel?>.create { single in
            let requestModel = YXBullBearFundFlowListReqModel()
            requestModel.derivativeType = self.derivativeType.rawValue
            requestModel.capflowType = type.rawValue
            requestModel.nextPageRef = self.nextPage
        
            let request = YXRequest.init(request: requestModel)
            
            request.startWithBlock(success: { [weak self](response) in
                var fundFlowModel: YXBullBearFundFlowResModel?
                var maxValue: Int64 = 0
                if response.code == YXResponseStatusCode.success {
                    fundFlowModel = YXBullBearFundFlowResModel.yy_model(withJSON: response.data ?? [:])
                    guard let `self` = self else { return }
                    if self.nextPage == 0 {
                        self.fundFlow.list = []
                    }
                    if let model = fundFlowModel {
                        if model.nextPageRef != 0 {
                            self.nextPage = model.nextPageRef
                        }
                        self.hasMore = model.hasMore
                        
                        self.fundFlow.list = self.fundFlow.list + model.list
                        for item in self.fundFlow.list {
                            if let asset = item.asset, abs(asset.netInflow) > maxValue {
                                maxValue =  abs(asset.netInflow)
                            }
                        }
                        self.maxFundFlow = maxValue
                    }
                }
                
                single(.success(self?.fundFlow))
            }, failure: { (request) in
                single(.error(request.error ?? NSError.init(domain: "", code: -1, userInfo: nil)))
            })
            return Disposables.create()
        }
        
        return single
    }
    
    // 多空信号
    func getPbSignal() -> Single<YXBullBearPbSignalResModel?> {
        
        let single = Single<YXBullBearPbSignalResModel?>.create { single in
            let requestModel = YXBullBearPbSignalReqModel()
            requestModel.type = self.derivativeType.rawValue
            requestModel.size = 20
            requestModel.nextPageSeqNum = self.nextPage
            requestModel.nextPageUnixTime = self.nextPageUnixTime
            requestModel.idString = self.id
        
            let request = YXRequest.init(request: requestModel)
            
            request.startWithBlock(success: { [weak self](response) in
                var signalModel: YXBullBearPbSignalResModel?
                if response.code == YXResponseStatusCode.success {
                    signalModel = YXBullBearPbSignalResModel.yy_model(withJSON: response.data ?? [:])
                    guard let `self` = self else { return }
                    if self.nextPage == 0 {
                        self.pbSignal.list = []
                    }
                    if let model = signalModel {
                        if model.nextPageSeqNum != 0 {
                            self.nextPage = model.nextPageSeqNum
                        }
                        self.nextPageUnixTime = model.nextPageUnixTime
                        self.hasMore = model.hasMore
                        
                        self.pbSignal.list = self.pbSignal.list + model.list
                    }
                }
                single(.success(signalModel))
            }, failure: { (request) in
                single(.error(request.error ?? NSError.init(domain: "", code: -1, userInfo: nil)))
            })
            return Disposables.create()
        }
        
        return single
    }
    
    func gotoStockDetail(market: String, symbol: String) {

        let input = YXStockInputModel()
        input.market = market
        input.symbol = symbol
        input.name = ""

        self.services.pushPath(.stockDetail, context: ["dataSource": [input], "selectIndex": 0], animated: true)
    }
    
    func gotoWarrants(market: String, symbol: String, name: String, isFromFundFlow: Bool, bullBeartype: YXBullAndBellType? = nil) {
        var dic: [String: Any]
        if let type = bullBeartype {
            dic = ["symbol": symbol, "name": name, "market": market, "warrantType": YXStockWarrantsType.bullBear, "isFromFundFlow": isFromFundFlow, "bullBeartype": type]
        }else {
            dic = ["symbol": symbol, "name": name, "market": market, "warrantType": YXStockWarrantsType.bullBear, "isFromFundFlow": isFromFundFlow]
        }
        
        (YXNavigationMap.navigator as? NavigatorServices)?.push(YXModulePaths.warrantsAndStreet.url, context: dic)
    }
}
