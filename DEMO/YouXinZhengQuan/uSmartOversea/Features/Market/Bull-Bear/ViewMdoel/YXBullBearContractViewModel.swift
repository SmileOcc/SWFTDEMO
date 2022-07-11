//
//  YXBullBearContractViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/4/8.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

enum YXDerivativeType: String {
    case warrantcbbc = "warrantcbbc"
    case warrant = "warrant"
    case bullBear = "cbbc"
    
    
    var riseText: String {
        switch self {
        case .warrant:
            return YXLanguageUtility.kLang(key: "bullbear_call_warrant")
        case .bullBear:
            return YXLanguageUtility.kLang(key: "warrants_bull")
        default:
            return ""
        }
    }
    
    var fallText: String {
        switch self {
        case .warrant:
            return YXLanguageUtility.kLang(key: "bullbear_put_warrant")
        case .bullBear:
            return YXLanguageUtility.kLang(key: "warrants_bear")
            default:
                return ""
        }
    }
    
    var assetListNavTitle: String {
        switch self {
        case .warrant:
            return YXLanguageUtility.kLang(key: "bullbear_warrants_list")
        case .bullBear:
            return YXLanguageUtility.kLang(key: "bullbear_cbbc_list")
        default:
            return ""
        }
    }
    
    var financialReportSectionTitle: String {
        switch self {
        case .warrant:
            return YXLanguageUtility.kLang(key: "bullbear_warrants_financial")
        case .bullBear:
            return YXLanguageUtility.kLang(key: "bullbear_CBBC_financial")
        default:
            return ""
        }
    }
}

enum YXBullBearFundFlowType: String {
    case inflow = "inflow"
    case outflow = "outflow"
    
    var assetListTitle: String {
        switch self {
        case .inflow:
            return YXLanguageUtility.kLang(key: "bullbear_net_capital_inflow")//"资金净流入"
        case .outflow:
            return YXLanguageUtility.kLang(key: "bullbear_net_capital_outflow")//"资金净流出"
        }
    }
}

enum YXBullBearContractSectionType {
    // 街货分布
    case street
    case longShortSignal
    case fundFlow
    
    var sectionTitle: String {
        switch self {
        case .street:
            return YXLanguageUtility.kLang(key: "bullbear_CBBC_outstanding")//"街货分布"
        case .longShortSignal:
            return YXLanguageUtility.kLang(key: "technical_signal")//"多空信号"
        case .fundFlow:
            return YXLanguageUtility.kLang(key: "warrant_capital_flows")//轮证资金流向
        
        }
    }
    
    var morePageNavTitle: String {
        switch self {
        case .longShortSignal:
            return self.sectionTitle
        default:
            return ""
        }
    }
}

class YXBullBearContractViewModel: YXViewModel {
    
    var derivativeType: YXDerivativeType = .warrant
    var dataSource: [YXBullBearContractSectionType] = []
    var assetMarket = kYXMarketHK
    var assetSymbol = kYXIndexHSI
    var assetName = ""
    var maxOutStanding: Int64 = 0 // 牛熊街货最大出货量，用于画柱状图
    var street: YXBullBearaContractStreetResModel?
//    var financial: YXBullBearFinancialReportResModel?
//    var fundFlowIn: YXBullBearFundFlowResModel?
//    var maxFundFlowIn: Int64 = 0
//    var fundFlowOut: YXBullBearFundFlowResModel?
//    var maxFundFlowOut: Int64 = 0
    var pbSignal: YXBullBearPbSignalResModel?
    var fundFlowModel: YXWarrantCBBCFundFlowResModel?
    
    lazy var bearAssetListViewModel: YXBullBearAssetListViewModel = {
        let vm = YXBullBearAssetListViewModel.init(services: self.services, type: self.derivativeType)
        return vm
    }()
    
    init(services: YXViewModelServices, type: YXDerivativeType) {
        super.init(services: services, params: [ : ])
        derivativeType = type
//        dataSource = [.street, .longShortSignal, .fundFlow]
        dataSource = [.street, .longShortSignal]
    }
    
    // 资产精选
    func getAsset() -> Single<YXWarrantBullBearModel?> {
        
        let single = Single<YXWarrantBullBearModel?>.create { single in
            let requestModel = YXBullBearWarrantcbbctopReqModel()
            requestModel.market = self.assetMarket
            requestModel.symbol = self.assetSymbol
        
            let request = YXRequest.init(request: requestModel)
            
            request.startWithBlock(success: { [weak self](response) in
                var assetModel: YXWarrantBullBearModel?
                if response.code == YXResponseStatusCode.success {
                    assetModel = YXWarrantBullBearModel.yy_model(withJSON: response.data ?? [:])
                }
                single(.success(assetModel))
            }, failure: { (request) in
                single(.error(request.error ?? NSError.init(domain: "", code: -1, userInfo: nil)))
            })
            return Disposables.create()
        }
        
        return single
    }
    
    // 大市成交
    func getDeal() -> Single<YXWarrantsDealResModel?> {
        
        let single = Single<YXWarrantsDealResModel?>.create { single in
            let requestModel = YXWarrantsDealReqModel()
            requestModel.market = kYXMarketHK
        
            let request = YXRequest.init(request: requestModel)
            
            request.startWithBlock(success: { [weak self](response) in
                var model: YXWarrantsDealResModel?
                if response.code == YXResponseStatusCode.success {
                    model = YXWarrantsDealResModel.yy_model(withJSON: response.data ?? [:])
                }
                
                single(.success(model))
                
            }, failure: { (request) in
                single(.error(request.error ?? NSError.init(domain: "", code: -1, userInfo: nil)))
            })
            return Disposables.create()
        }
        
        return single
    }
    
    // 牛熊街货精选
    func getCBBCTop() -> Single<YXBullBearaContractStreetResModel?> {
        
        let single = Single<YXBullBearaContractStreetResModel?>.create { single in
            let requestModel = YXBullBearContractStreetReqModel()
            requestModel.market = self.assetMarket
            requestModel.symbol = self.assetSymbol
        
            let request = YXRequest.init(request: requestModel)
            
            request.startWithBlock(success: { [weak self](response) in
                var streetModel: YXBullBearaContractStreetResModel?
                if response.code == YXResponseStatusCode.success {
                    streetModel = YXBullBearaContractStreetResModel.yy_model(withJSON: response.data ?? [:])
                    // 牛熊有值才显示街货分布模块，没有则整个模块不显示
//                    if self?.derivativeType == .bullBear, let model = streetModel {
//                        guard let `self` = self else { return }
//                        // 检查数据源里是否有街货分布
//                        switch self.dataSource[1] {
//                        case .street:
//                            // 有街货分布，但是后台返回街货列表为空，则移除掉
//                            if model.bearList.count == 0, model.bullList.count == 0 {
//                                self.dataSource.remove(at: 1)
//                            }
//                        default:
//                            // 数据源中无街货分布，后台返回街货列表不空，则插入街货分布模块
//                            if model.bearList.count > 0, model.bullList.count > 0 {
//                                self.dataSource.insert(.street, at: 1)
//                            }
//                        }
//                    }
                    
                    var maxBearOutstanding: Int64 = 0
                    var maxBullOutstanding: Int64 = 0
                    
                    if let model = streetModel {
                        for item in model.bearList {
                            if let outStanding = item.outstanding?.Outstanding, outStanding > maxBearOutstanding {
                                maxBearOutstanding = outStanding
                            }
                        }
                        for item in model.bullList {
                            if let outStanding = item.outstanding?.Outstanding, outStanding > maxBullOutstanding {
                                maxBullOutstanding = outStanding
                            }
                        }
                    }
                    
                    self?.maxOutStanding = max(maxBearOutstanding, maxBullOutstanding)
                    
                }else { // 接口请求失败，则获取不到街货分布数据，直接移除这个模块
                    guard let `self` = self else { return }
                    switch self.dataSource[1] {
                    case .street:
                        // 有街货分布，则移除掉
                        self.dataSource.remove(at: 1)
                    default:
                        break
                    }
                }
                
                self?.street = streetModel
                single(.success(streetModel))
                
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
            requestModel.size = 4
            requestModel.nextPageSeqNum = 0
        
            let request = YXRequest.init(request: requestModel)
            
            request.startWithBlock(success: { [weak self](response) in
                guard let `self` = self else { return }
                var signalModel: YXBullBearPbSignalResModel?
                if response.code == YXResponseStatusCode.success {
                    signalModel = YXBullBearPbSignalResModel.yy_model(withJSON: response.data ?? [:])
                }
                self.pbSignal = signalModel
                single(.success(signalModel))
            }, failure: { (request) in
                single(.error(request.error ?? NSError.init(domain: "", code: -1, userInfo: nil)))
            })
            return Disposables.create()
        }
        
        return single
    }
    
    // 资金流向
    func getFundFlow() -> Single<Any?> {
        
        let single = Single<Any?>.create { single in
            let requestModel = YXWarrantCBBCFundFlowReqModel()
            requestModel.market = kYXMarketHK
        
            let request = YXRequest.init(request: requestModel)
            
            request.startWithBlock(success: { [weak self](response) in
                
                if response.code == YXResponseStatusCode.success {
                    self?.fundFlowModel = YXWarrantCBBCFundFlowResModel.yy_model(withJSON: response.data ?? [:])
                }
                
                single(.success(self?.fundFlowModel))
                
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
    
    func gotoAssetList() {
        self.services.push(bearAssetListViewModel, animated: true)
    }
    
    func gotoMorePage(withSectionType type: YXBullBearContractSectionType) {
        let vm = YXPbSignalViewModel.init(services: services, params: nil)
        services.push(vm, animated: true)
    }
    
    // 跳转涡轮牛熊
    func gotoWarrants(market: String, symbol: String, name: String, prcLower: String? = nil, prcUpper: String? = nil, bullBeartype: YXBullAndBellType? = nil, isFromFundFlow: Bool = false) {
        var dic: [String: Any]
        if let low = prcLower, let up = prcUpper, let type = bullBeartype {
            dic = ["symbol": symbol, "name": name, "market": market, "prcLower": low, "prcUpper": up, "bullBearType": type, "warrantType": YXStockWarrantsType.bullBear, "isFromFundFlow": isFromFundFlow]
        }else {
            if let type = bullBeartype {
                dic = ["symbol": symbol, "name": name, "market": market, "warrantType": YXStockWarrantsType.bullBear, "bullBeartype": type, "isFromFundFlow": isFromFundFlow]
            }else {
                dic = ["symbol": symbol, "name": name, "market": market, "warrantType": YXStockWarrantsType.bullBear, "isFromFundFlow": isFromFundFlow]
            }
        }
        
        YXNavigationMap.navigator.push(YXModulePaths.warrantsAndStreet.url, context: dic)
    }
    
    // 跳转街货分布
    func gotoCBBC(market: String, symbol: String, name: String) {
        let dic: [String: Any] = ["symbol": symbol, "name": name, "market": market, "warrantType": YXStockWarrantsType.bullBear, "tabIndex": 1]
        YXNavigationMap.navigator.push(YXModulePaths.warrantsAndStreet.url, context: dic)
    }
    
    func gotoInlineWarrant() {
        let dic: [String: Any] = ["ishideLZBButton": true, "warrantType": YXStockWarrantsType.inlineWarrants]
        YXNavigationMap.navigator.push(YXModulePaths.stockWarrants.url, context: dic)
    }
}
