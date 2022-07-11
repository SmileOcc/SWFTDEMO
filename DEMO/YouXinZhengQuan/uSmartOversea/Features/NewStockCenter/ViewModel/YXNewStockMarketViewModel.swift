//
//  YXNewStockMarketViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/4/9.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator

class YXNewStockMarketViewModel: HUDServicesViewModel, RefreshViewModel {
    
    typealias IdentifiableModel = YXMarketRankCodeListInfo
    typealias Services = YXNewStockService
    var navigator: NavigatorServicesType!
    
    var market: String = YXMarketType.HK.rawValue
    
    let contentOffsetRelay = BehaviorRelay<CGPoint>(value: CGPoint.zero)
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    let alertSubject = PublishSubject<Bool>()
    var services: Services! = YXNewStockService()
    
    lazy var userLevel: QuoteLevel = {

        YXUserManager.shared().getLevel(with: self.market)
    }()

    func updateLevel() {
        var level = YXUserManager.shared().getLevel(with: self.market)
        userLevel = level
    }
    
    //响应回调
    var resultResponse: YXResultResponse<YXMarketRankModel>?
    
    var sorttype: YXStockRankSortType  = .listDate
    var sortdirection: Int = 1
    //更新状态
    var needReloadData: Bool = false
    
    var endHeaderRefreshStatus: Driver<EndRefreshStatus>?
    var endFooterRefreshStatus: Driver<EndRefreshStatus>?
    
    var page: Int = 1
    var offset: Int = 0
    var perPage: Int = 30
    var total: Int?
    
    let dataSource: BehaviorRelay<[IdentifiableModel]> = BehaviorRelay<[IdentifiableModel]>(value:[])
    
    var dataSourceSingle: Single<[IdentifiableModel]> {
        Single<[YXMarketRankCodeListInfo]>.create(subscribe: { [weak self] (single) -> Disposable in
            guard let strongSelf = self else { return Disposables.create() }
            
            return strongSelf.services.request(.quotesRank(sortType: strongSelf.sorttype.rawValue, sortDirection: strongSelf.sortdirection, pageDirection: 0, from: strongSelf.offsetForPage(strongSelf.page), count: strongSelf.userLevel == .bmp ? 20 : strongSelf.perPage, code: "NEW_ALL", market: strongSelf.market, level: strongSelf.userLevel.rawValue), response: { (response: YXResponseType<YXMarketRankModel>) in
                strongSelf.hudSubject.onNext(.hide)
                switch response {
                case .success(let result, let code):
                    if code == .success, let dataModel = result.data?.list?.first?.data, let list = dataModel.list {
                        strongSelf.total = dataModel.total
                        single(.success(list))
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

