//
//  YXHKADRViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/12/20.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator

class YXHKADRViewModel: HUDServicesViewModel, RefreshViewModel {
    typealias IdentifiableModel = YXMarketRankCodeListInfo
    typealias Services = YXNewStockService
    var navigator: NavigatorServicesType!
    
    let contentOffsetRelay = BehaviorRelay<CGPoint>(value: CGPoint.zero)
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    let alertSubject = PublishSubject<Bool>()
    var services: Services! = YXNewStockService()
    
//    let code = "ADR_ALL"
    var rankType = YXRankType.adr
    
    let market = YXMarketType.HK.rawValue
    
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
    
    var orderDirection: Int = 1
    var page: Int = 1
    var offset: Int = 0
    var perPage: Int = 30
    var total: Int?
    var count: Int {
        self.perPage
    }
    
    let dataSource: BehaviorRelay<[IdentifiableModel]> = BehaviorRelay<[IdentifiableModel]>(value:[])
    
    init(type: YXRankType) {
        self.rankType = type
    }
    
    var dataSourceSingle: Single<[IdentifiableModel]> {
        Single<[IdentifiableModel]>.create(subscribe: { [weak self] (single) -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            
            return self.services.request(.quotesRank(sortType: 1, sortDirection: self.orderDirection, pageDirection: 0, from: self.offsetForPage(self.page), count: self.count, code: self.rankType.rankCode, market: self.market, level: self.userLevel.rawValue), response: { (response: YXResponseType<YXMarketRankModel>) in
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
    
}
