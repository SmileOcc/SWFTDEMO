//
//  YXDividendsViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/12/20.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator

class YXDividendsViewModel: HUDServicesViewModel, RefreshViewModel {
    typealias IdentifiableModel = YXMarketRankCodeListInfo
    typealias Services = YXNewStockService
    var navigator: NavigatorServicesType!
    
    let contentOffsetRelay = BehaviorRelay<CGPoint>(value: CGPoint.zero)
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    let alertSubject = PublishSubject<Bool>()
    var services: Services! = YXNewStockService()
    
    var rankModels:[YXDividendsYears] = []
    
    //响应回调
    var resultResponse: YXResultResponse<YXMarketRankModel>?
    
    var years:[String] = []
    
    var market = ""
    // 84：股息，85：股息率   
    var sortType:YXStockRankSortType = .dividendsYield
    
    var code:String = ""
    
    var selectYearIndex:Int = 0
    
    lazy var userLevel: QuoteLevel = {
        var level = YXUserManager.shared().getLevel(with: market)
        if level == .bmp {
            level = .delay
        }
        
        return level
    }()

    func updateLevel() {
        var level = YXUserManager.shared().getLevel(with: self.market)
        if level == .bmp {
            level = .delay
        }
        userLevel = level
    }
    
    //更新状态
    var needReloadData: Bool = false
    
    var endHeaderRefreshStatus: Driver<EndRefreshStatus>?
    var endFooterRefreshStatus: Driver<EndRefreshStatus>?
    //0 升 1降
    var direction: Int = 1
    var page: Int = 1
    var offset: Int = 0
    var perPage: Int = 30
    var total: Int?
    var count: Int {
        self.perPage
    }
    
    let dataSource: BehaviorRelay<[IdentifiableModel]> = BehaviorRelay<[IdentifiableModel]>(value:[])
    
    init(rankModels: [YXDividendsYears], market:String,selectYearIndex:Int) {
        self.selectYearIndex = selectYearIndex
        self.rankModels = rankModels
        self.market = market
        self.years = rankModels.map{ $0.year }
    }
    
    var dataSourceSingle: Single<[IdentifiableModel]> {
        Single<[IdentifiableModel]>.create(subscribe: { [weak self] (single) -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            
            let model = self.rankModels[self.selectYearIndex]
            self.code = model.rankCode
            return self.services.request(.quotesRank(sortType: self.sortType.rawValue, sortDirection: self.direction, pageDirection: 0, from: self.offsetForPage(self.page), count: self.count, code: model.rankCode, market: self.market, level: self.userLevel.rawValue), response: { (response: YXResponseType<YXMarketRankModel>) in
                self.hudSubject.onNext(.hide)
                switch response {
                case .success(let result, let code):
                    if code == .success, let dataModel = result.data, let adrModel = dataModel.list?.first {
                        if let total = adrModel.data?.total, let list = adrModel.data?.list {
                            self.total = total
                            single(.success(list))
                        }
                    } else {
                        single(.success([]))
                    }
                case .failed(let error):
                    log(.error, tag: kNetwork, content: "\(error)")
                    single(.error(error))
                }
            })
            
        })
    }
    
    init() {
        resultResponse = { [weak self] (response) in
            guard let strongSelf = self else { return }
            switch response {
            case .success(let result, let code):
                if code == .success, let dataModel = result.data?.list?.first?.data,
                    let list = dataModel.list, list.count > 0,
                    let fromIndex = dataModel.from, fromIndex < strongSelf.dataSource.value.count {
                    var totalList = strongSelf.dataSource.value
                    let totalCount = totalList.count
                    var replaceIndex = fromIndex
                    for model in list {
                        if replaceIndex < totalCount {
                            totalList[replaceIndex] = model
                        }
                        replaceIndex += 1
                    }
                    strongSelf.dataSource.accept(totalList)
                }
            case .failed(_):
                log(.info, tag: kNetwork, content: " ")
            }
        }
    }
    
}

