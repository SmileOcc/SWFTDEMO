//
//  YXHotIndustryViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/12/20.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator

class YXHotIndustryViewModel: HUDServicesViewModel, RefreshViewModel {
    typealias IdentifiableModel = YXMarketRankCodeListInfo
    typealias Services = YXNewStockService
    var navigator: NavigatorServicesType!
    
    let contentOffsetRelay = BehaviorRelay<CGPoint>(value: CGPoint.zero)
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    let alertSubject = PublishSubject<Bool>()
    var services: Services! = YXNewStockService()
    
    var rankCode: String!
    var market: String!
    var title: String?
    var showSearch: Bool?
    
    // 局部刷新响应回调
    var resultResponse: YXResultResponse<YXMarketRankModel>?
    
    lazy var userLevel: QuoteLevel = {
        YXUserManager.shared().getLevel(with: market)
    }()

    func updateLevel() {
        var level = YXUserManager.shared().getLevel(with: self.market)
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
    
    let dataSource: BehaviorRelay<[IdentifiableModel]> = BehaviorRelay<[IdentifiableModel]>(value:[])
    
    // viewModel.services.request(, response: (self.viewModel.deliverResponse)).disposed(by: rx.disposeBag)
    
    var dataSourceSingle: Single<[IdentifiableModel]> {
        Single<[IdentifiableModel]>.create(subscribe: { [weak self] (single) -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            
            return self.services.request(.quotesRank(sortType: 1, sortDirection: self.orderDirection, pageDirection: 0, from: self.offsetForPage(self.page), count: self.perPage, code: self.rankCode, market: self.market, level: self.userLevel.rawValue), response: { (response: YXResponseType<YXMarketRankModel>) in
                self.hudSubject.onNext(.hide)
                switch response {
                case .success(let result, let code):
                    if code == .success, let dataModel = result.data, let hotIndustryModel = dataModel.list?.first {
                        if let total = hotIndustryModel.data?.total, let list = hotIndustryModel.data?.list {
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
