//
//  YXNewSearchViewModel.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/12/2.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import URLNavigator
import RxSwift
import RxCocoa
import NSObject_Rx

class YXNewSearchViewModel: ServicesViewModel, HasDisposeBag {
    var navigator: NavigatorServicesType!
    
    typealias Services = HasYXSearchService & HasYXStockSTService & HasYXQuotesDataService
    
    var defaultParam :YXSearchParam?
    var dailyMargin = 0 // 用来过滤日内融数据，0：全部 1：非日内融 2： 日内融
    var types: [YXSearchType] = []
    var showPopular = true
    var showHistory = true

    let resultViewModel = YXSearchResultViewModel()
    
    var hotSearchResponse: YXResultResponse<YXSearchList>?
    let hotSearchList: BehaviorRelay<[YXSearchItem]> = BehaviorRelay<[YXSearchItem]>(value:[])
    
    var multiassetResponse: YXResultResponse<YXMultiassetModel>?
    let multiasset: BehaviorRelay<YXStockMultiasset?> = BehaviorRelay<YXStockMultiasset?>(value:nil)
    
    var fundResponse: YXResultResponse<YXFundHomeModel>?
    let fundHomeOne: BehaviorRelay<FundHomeOne?> = BehaviorRelay<FundHomeOne?>(value:nil)
    
    var recommendResponse: YXResultResponse<YXRecommendModel>?
    let recommendList: BehaviorRelay<[YXRecommend]> = BehaviorRelay<[YXRecommend]>(value:[])
    
    var lastestSearchText :String?
    var doingSearch :Bool = false
    
    var hotSearchIsFinshed: Bool = false
    var multiassetIsFinshed: Bool = false
    var fundIsFinshed: Bool = false
    var recommendIsFinished: Bool = false
    
    var secuGroup: YXSecuGroup?
    
    var services: Services! {
        didSet {
            resultViewModel.secuGroup = secuGroup
            
            hotSearchResponse = { [weak self] (response) in
                guard let strongSelf = self else { return }
                
                strongSelf.hotSearchIsFinshed = true
                switch response {
                case .success(let result, let code):
                    if code == .success, let list = result.data?.list, list.count > 0 {
                        let  newlist =  list.filter
                        {
                            return ($0.market != "sz" && $0.market != "sh")
                        }
                        strongSelf.hotSearchList.accept(newlist)
                    } else {
                        strongSelf.hotSearchList.accept([])
                    }
                case .failed(let error):
                    strongSelf.hotSearchList.accept([])
                    log(.error, tag: kNetwork, content: "\(error)")
                }
            }
            
            multiassetResponse = { [weak self] (response) in
                guard let strongSelf = self else { return }
                
                strongSelf.multiassetIsFinshed = true
                switch response {
                case .success(let result, let code):
                    if code == .success, let model = result.data {
                        strongSelf.multiasset.accept(model.multiasset?.first)
                    } else {
                        strongSelf.multiasset.accept(nil)
                    }
                case .failed(let error):
                    strongSelf.multiasset.accept(nil)
                    log(.error, tag: kNetwork, content: "\(error)")
                }
            }
            
            fundResponse = { [weak self] (response) in
                guard let strongSelf = self else { return }
                
                strongSelf.fundIsFinshed = true
                switch response {
                case .success(let result, let code):
                    if code == .success, let model = result.data {
                        strongSelf.fundHomeOne.accept(model.fundHomepageOne)
                    } else {
                        strongSelf.fundHomeOne.accept(nil)
                    }
                case .failed(let error):
                    strongSelf.fundHomeOne.accept(nil)
                    log(.error, tag: kNetwork, content: "\(error)")
                }
            }
            
            recommendResponse = { [weak self] (response) in
                guard let strongSelf = self else { return }
                
                strongSelf.recommendIsFinished = true
                switch response {
                case .success(let result, let code):
                    if code == .success, let list = result.data?.list, list.count > 0 {
                        strongSelf.recommendList.accept(list)
                    } else {
                        strongSelf.recommendList.accept([])
                    }
                case .failed(let error):
                    strongSelf.recommendList.accept([])
                    log(.error, tag: kNetwork, content: "\(error)")
                }
            }
            
            resultViewModel.saveToHistory.asObservable().subscribe(onNext: { (item) in
                if let list = YXSearchHistoryManager.shared.list.value {
                    list.add(item: item)
                    YXSearchHistoryManager.shared.list.value = list
                    YXSearchHistoryManager.shared.saveToDisk()
                }
            }).disposed(by: disposeBag)
        }
    }
    
    func isShowEmpty() -> Bool {
//        guard hotSearchIsFinshed, multiassetIsFinshed, fundIsFinshed, recommendIsFinished else {
//            return false
//        }
        
        if hotSearchList.value.count > 0 {
            return false
        }
        
        if multiasset.value != nil {
           return false
        }
        
        if let array = fundHomeOne.value?.data, array.count > 0 {
            return false
        }
        
        if recommendList.value.count > 0 {
            return false
        }
        return true
    }
    
    //搜索
    func search(text :String) {
        
        lastestSearchText = text
        
        if doingSearch {
            return
        }
        
        doingSearch = true
        
        doSearch(text: text)
        
    }
    
    private func doSearch(text :String) {
        
        var param = YXSearchParam()
        
        if let defaultParam = self.defaultParam {
            param = defaultParam
        }
        
        param.q = text
        param.size = 50
        param.dailyMargin = self.dailyMargin
        
        if types != [] {
            param.markets = types.map{ $0.rawValue }
        }
        
        if param.markets != nil {
            param.markets = param.markets?.filter({ (market) -> Bool in
                return market != "sh" && market != "sz"
            })
        }else {
            param.markets = YXSearchType.allCases.map{ $0.rawValue }
        }
        
        _ = services.searchService.request(.search(param), response: { [weak self] (response: YXResponseType<YXSearchList>) in
            guard let strongSelf = self else { return }
            
            strongSelf.doingSearch = false
            switch response {
            case .success(let result, let code):
                if code == .success {
                    //如果最后一次传入的查询字符串，跟最近一次网络请求的不一致，则再次发送一次查询
                    if let lastestSearchText = strongSelf.lastestSearchText, lastestSearchText != "" {
                        let data = result.data
                        data?.param = param
                        
                        self?.resultViewModel.list.value = data
                        
                        if  param.q != nil, lastestSearchText != param.q {
                            self?.search(text: lastestSearchText)
                        }
                    }
                }
            case .failed(let error):
                log(.error, tag: kNetwork, content: "\(error)")
            }
        })
    }
    
    func removeHistory() {
        YXSearchHistoryManager.shared.list.value = YXSearchList()
        YXSearchHistoryManager.shared.saveToDisk()
    }
    
    deinit {
        print(">>>>>>> \(NSStringFromClass(YXNewSearchViewModel.self)) deinit")
    }
}

